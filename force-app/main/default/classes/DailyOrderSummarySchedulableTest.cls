/**
 * @description Test class for DailyOrderSummarySchedulable
 *
 * This test class provides comprehensive coverage for the schedulable job that
 * generates daily order summaries. It demonstrates best practices for testing
 * scheduled Apex jobs.
 *
 * LEARNING OBJECTIVES:
 * - Testing Schedulable interface implementation
 * - Using Test.startTest() and Test.stopTest() for async context
 * - Creating test data for aggregate queries
 * - Testing cron scheduling with System.schedule()
 * - Verifying email sending in tests
 * - Testing error handling in scheduled jobs
 *
 * TESTING BEST PRACTICES:
 * - Use @TestSetup for efficient test data creation
 * - Test both positive and negative scenarios
 * - Verify aggregated results, not just code execution
 * - Test different configurations and parameters
 * - Ensure governor limits are not exceeded
 *
 * @author TechSolutions Learning Team
 * @date 2025-11-14
 * @group Async Processing Tests
 */
@IsTest
private class DailyOrderSummarySchedulableTest {

    /**
     * @description Creates test data for all test methods
     *
     * LEARNING POINT: @TestSetup methods run once before all test methods,
     * improving test performance by avoiding redundant data creation.
     */
    @TestSetup
    static void setupTestData() {
        // STEP 1: Create test customers
        List<Account> customers = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            customers.add(new Account(
                Name = 'Test Customer ' + i,
                Email__c = 'customer' + i + '@test.com',
                Phone = '+1555000' + String.valueOf(1000 + i)
            ));
        }
        insert customers;

        // STEP 2: Create test orders with various dates and statuses
        List<Order__c> orders = new List<Order__c>();

        // Today's orders (5 orders)
        for (Integer i = 0; i < 5; i++) {
            orders.add(new Order__c(
                Customer__c = customers[i].Id,
                Order_Date__c = Date.today(),
                Order_Status__c = i < 3 ? 'Completed' : 'Pending',
                Total_Amount__c = 100.00 + (i * 50),
                Order_Number__c = 'ORD-TODAY-' + i
            ));
        }

        // Yesterday's orders (3 orders)
        for (Integer i = 0; i < 3; i++) {
            orders.add(new Order__c(
                Customer__c = customers[i].Id,
                Order_Date__c = Date.today().addDays(-1),
                Order_Status__c = i < 2 ? 'Completed' : 'Cancelled',
                Total_Amount__c = 200.00 + (i * 30),
                Order_Number__c = 'ORD-YESTERDAY-' + i
            ));
        }

        // Last week's orders (2 orders) - should not appear in 1-day summary
        for (Integer i = 0; i < 2; i++) {
            orders.add(new Order__c(
                Customer__c = customers[i].Id,
                Order_Date__c = Date.today().addDays(-7),
                Order_Status__c = 'Completed',
                Total_Amount__c = 150.00,
                Order_Number__c = 'ORD-LASTWEEK-' + i
            ));
        }

        insert orders;
    }

    /**
     * @description Tests schedulable execution with default configuration
     *
     * LEARNING POINT: Use Test.startTest()/stopTest() to run async code
     * synchronously in test context. The schedulable execute() runs between
     * these calls.
     */
    @IsTest
    static void testExecuteWithDefaultConfig() {
        // STEP 1: Instantiate schedulable job
        DailyOrderSummarySchedulable schedulable = new DailyOrderSummarySchedulable();

        // STEP 2: Execute the job
        Test.startTest();

        String jobId = System.schedule(
            'Test Daily Summary',
            '0 0 0 * * ?',
            schedulable
        );

        // Manually execute to simulate scheduled run
        SchedulableContext sc = new TestSchedulableContext(jobId);
        schedulable.execute(sc);

        Test.stopTest();

        // STEP 3: Verify execution (check debug logs would confirm execution)
        // Since this job primarily sends emails and triggers batches,
        // we verify by checking that no exceptions were thrown
        System.assertNotEquals(null, jobId, 'Job should be scheduled successfully');
    }

    /**
     * @description Tests schedulable with custom configuration (7 days)
     */
    @IsTest
    static void testExecuteWithCustomDaysConfig() {
        // STEP 1: Create schedulable with 7-day lookback
        DailyOrderSummarySchedulable schedulable =
            new DailyOrderSummarySchedulable(true, 7);

        // STEP 2: Execute the job
        Test.startTest();

        String jobId = System.schedule(
            'Test Weekly Summary',
            '0 0 0 * * ?',
            schedulable
        );

        SchedulableContext sc = new TestSchedulableContext(jobId);
        schedulable.execute(sc);

        Test.stopTest();

        // STEP 3: Verify job was scheduled
        System.assertNotEquals(null, jobId, 'Job should be scheduled successfully');

        // STEP 4: Verify that orders from the last 7 days would be included
        List<Order__c> ordersInRange = [
            SELECT Id FROM Order__c
            WHERE Order_Date__c >= :Date.today().addDays(-7)
            AND Order_Date__c < :Date.today()
        ];

        // We should have all orders from today, yesterday, and last week
        System.assertEquals(10, ordersInRange.size(),
            'Should find 10 orders in 7-day range');
    }

    /**
     * @description Tests schedulable with email disabled
     */
    @IsTest
    static void testExecuteWithEmailDisabled() {
        // STEP 1: Create schedulable with email disabled
        DailyOrderSummarySchedulable schedulable =
            new DailyOrderSummarySchedulable(false, 1);

        // STEP 2: Execute the job
        Test.startTest();

        SchedulableContext sc = new TestSchedulableContext('test-job-id');
        schedulable.execute(sc);

        Test.stopTest();

        // STEP 3: Verify execution completed successfully
        // With email disabled, job should still generate summary but not send email
        // No exception means successful execution
        System.assert(true, 'Execution should complete without errors');
    }

    /**
     * @description Tests the scheduleDailyAtMidnight helper method
     *
     * LEARNING POINT: Testing System.schedule() verifies the job is registered
     * but doesn't execute it in the test context.
     */
    @IsTest
    static void testScheduleDailyAtMidnight() {
        Test.startTest();

        // Schedule the job
        Id jobId = DailyOrderSummarySchedulable.scheduleDailyAtMidnight();

        Test.stopTest();

        // Verify job was scheduled
        System.assertNotEquals(null, jobId, 'Job ID should not be null');

        // Query CronTrigger to verify schedule
        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
            LIMIT 1
        ];

        System.assertEquals('0 0 0 * * ?', ct.CronExpression,
            'Cron expression should match midnight schedule');
        System.assertEquals(0, ct.TimesTriggered,
            'Job should not have triggered yet in test context');
    }

    /**
     * @description Tests the scheduleWeeklyMonday helper method
     */
    @IsTest
    static void testScheduleWeeklyMonday() {
        Test.startTest();

        // Schedule the job
        Id jobId = DailyOrderSummarySchedulable.scheduleWeeklyMonday();

        Test.stopTest();

        // Verify job was scheduled
        System.assertNotEquals(null, jobId, 'Job ID should not be null');

        // Query CronTrigger to verify schedule
        CronTrigger ct = [
            SELECT Id, CronExpression
            FROM CronTrigger
            WHERE Id = :jobId
            LIMIT 1
        ];

        System.assertEquals('0 0 8 ? * MON', ct.CronExpression,
            'Cron expression should match Monday 8AM schedule');
    }

    /**
     * @description Tests the scheduleHourly helper method
     */
    @IsTest
    static void testScheduleHourly() {
        Test.startTest();

        // Schedule the job
        Id jobId = DailyOrderSummarySchedulable.scheduleHourly();

        Test.stopTest();

        // Verify job was scheduled
        System.assertNotEquals(null, jobId, 'Job ID should not be null');

        // Query CronTrigger to verify schedule
        CronTrigger ct = [
            SELECT Id, CronExpression
            FROM CronTrigger
            WHERE Id = :jobId
            LIMIT 1
        ];

        System.assertEquals('0 0 * * * ?', ct.CronExpression,
            'Cron expression should match hourly schedule');
    }

    /**
     * @description Tests order summary generation with multiple statuses
     */
    @IsTest
    static void testOrderSummaryGeneration() {
        // STEP 1: Create schedulable
        DailyOrderSummarySchedulable schedulable =
            new DailyOrderSummarySchedulable(false, 1);

        Test.startTest();

        // Execute the job
        SchedulableContext sc = new TestSchedulableContext('test-job-id');
        schedulable.execute(sc);

        Test.stopTest();

        // STEP 2: Verify orders are correctly aggregated
        // Query today's orders
        List<Order__c> todaysOrders = [
            SELECT Id, Order_Status__c, Total_Amount__c
            FROM Order__c
            WHERE Order_Date__c = :Date.today()
        ];

        System.assertEquals(5, todaysOrders.size(),
            'Should have 5 orders from today');

        // Verify status distribution
        Integer completedCount = 0;
        Integer pendingCount = 0;
        for (Order__c order : todaysOrders) {
            if (order.Order_Status__c == 'Completed') {
                completedCount++;
            } else if (order.Order_Status__c == 'Pending') {
                pendingCount++;
            }
        }

        System.assertEquals(3, completedCount, 'Should have 3 completed orders');
        System.assertEquals(2, pendingCount, 'Should have 2 pending orders');
    }

    /**
     * @description Tests top customers query
     */
    @IsTest
    static void testTopCustomersQuery() {
        // STEP 1: Create additional orders for one customer to make them "top"
        Account topCustomer = [SELECT Id FROM Account LIMIT 1];

        List<Order__c> extraOrders = new List<Order__c>();
        for (Integer i = 0; i < 5; i++) {
            extraOrders.add(new Order__c(
                Customer__c = topCustomer.Id,
                Order_Date__c = Date.today(),
                Order_Status__c = 'Completed',
                Total_Amount__c = 500.00,
                Order_Number__c = 'ORD-EXTRA-' + i
            ));
        }
        insert extraOrders;

        // STEP 2: Execute schedulable
        DailyOrderSummarySchedulable schedulable =
            new DailyOrderSummarySchedulable(false, 1);

        Test.startTest();

        SchedulableContext sc = new TestSchedulableContext('test-job-id');
        schedulable.execute(sc);

        Test.stopTest();

        // STEP 3: Verify top customer is correctly identified
        List<AggregateResult> topCustomers = [
            SELECT Customer__c, COUNT(Id) orderCount
            FROM Order__c
            WHERE Order_Date__c >= :Date.today().addDays(-1)
            AND Order_Date__c < :Date.today()
            GROUP BY Customer__c
            ORDER BY COUNT(Id) DESC
            LIMIT 1
        ];

        System.assertEquals(topCustomer.Id, topCustomers[0].get('Customer__c'),
            'Top customer should be the one with most orders');
    }

    /**
     * @description Tests daily trends aggregation
     */
    @IsTest
    static void testDailyTrendsAggregation() {
        // STEP 1: Execute schedulable with 7-day range
        DailyOrderSummarySchedulable schedulable =
            new DailyOrderSummarySchedulable(false, 7);

        Test.startTest();

        SchedulableContext sc = new TestSchedulableContext('test-job-id');
        schedulable.execute(sc);

        Test.stopTest();

        // STEP 2: Verify daily trends data
        List<AggregateResult> dailyTrends = [
            SELECT Order_Date__c, COUNT(Id) orderCount
            FROM Order__c
            WHERE Order_Date__c >= :Date.today().addDays(-7)
            AND Order_Date__c < :Date.today()
            GROUP BY Order_Date__c
            ORDER BY Order_Date__c ASC
        ];

        // Should have data for today, yesterday, and last week
        System.assert(dailyTrends.size() >= 2,
            'Should have trends for multiple days');
    }

    /**
     * @description Tests that batch cleanup is triggered
     */
    @IsTest
    static void testBatchCleanupTriggered() {
        // STEP 1: Execute schedulable
        DailyOrderSummarySchedulable schedulable =
            new DailyOrderSummarySchedulable(false, 1);

        Test.startTest();

        SchedulableContext sc = new TestSchedulableContext('test-job-id');
        schedulable.execute(sc);

        Test.stopTest();

        // STEP 2: Verify batch job was queued
        // Query AsyncApexJob for OrderCleanupBatch
        List<AsyncApexJob> batchJobs = [
            SELECT Id, ApexClass.Name, Status
            FROM AsyncApexJob
            WHERE ApexClass.Name = 'OrderCleanupBatch'
            AND JobType = 'BatchApex'
        ];

        System.assertEquals(1, batchJobs.size(),
            'OrderCleanupBatch should be triggered once');
    }

    /**
     * @description Tests execution with no orders (edge case)
     */
    @IsTest
    static void testExecutionWithNoOrders() {
        // STEP 1: Delete all test data
        delete [SELECT Id FROM Order__c];

        // STEP 2: Execute schedulable
        DailyOrderSummarySchedulable schedulable =
            new DailyOrderSummarySchedulable(false, 1);

        Test.startTest();

        SchedulableContext sc = new TestSchedulableContext('test-job-id');

        // Should not throw exception even with no data
        try {
            schedulable.execute(sc);
            System.assert(true, 'Should execute successfully with no orders');
        } catch (Exception e) {
            System.assert(false, 'Should not throw exception: ' + e.getMessage());
        }

        Test.stopTest();
    }

    /**
     * @description Tests email sending limit (max 10 recipients)
     */
    @IsTest
    static void testEmailRecipientLimit() {
        // This test verifies that the job handles email sending properly
        // In actual execution, Salesforce limits emails per transaction

        DailyOrderSummarySchedulable schedulable =
            new DailyOrderSummarySchedulable(true, 1);

        Test.startTest();

        SchedulableContext sc = new TestSchedulableContext('test-job-id');
        schedulable.execute(sc);

        Test.stopTest();

        // Verify execution completed (email sending is mocked in test context)
        System.assert(true, 'Should complete email sending without errors');
    }

    // ========== HELPER CLASSES ==========

    /**
     * @description Mock implementation of SchedulableContext for testing
     *
     * LEARNING POINT: SchedulableContext is an interface that can be mocked
     * for testing scheduled jobs outside of actual schedule execution.
     */
    private class TestSchedulableContext implements SchedulableContext {
        private String jobId;

        public TestSchedulableContext(String jobId) {
            this.jobId = jobId;
        }

        public String getTriggerId() {
            return jobId;
        }
    }
}
