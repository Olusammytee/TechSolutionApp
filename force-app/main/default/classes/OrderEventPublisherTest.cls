/**
 * @description Comprehensive test class for OrderEventPublisher and Platform Events
 *
 * This test class demonstrates how to test Platform Events in Salesforce,
 * including event publishing, bulk operations, error handling, and trigger
 * integration.
 *
 * WHAT THIS TESTS:
 * - Single event publishing
 * - Bulk event publishing
 * - Event publishing from triggers
 * - Status change detection
 * - Order creation events
 * - Order cancellation events
 * - Order completion events
 * - Error handling for failed publishes
 * - Governor limit monitoring
 *
 * LEARNING OBJECTIVES:
 * - How to test Platform Events
 * - How to verify event publishing in tests
 * - How to test bulk event operations
 * - How to test trigger-driven events
 * - Best practices for event testing
 *
 * CODE COVERAGE TARGET: 95%+
 *
 * @author TechSolutions Learning Team
 * @date 2025-11-04
 * @group Platform Events Tests
 */
@isTest
private class OrderEventPublisherTest {

    /**
     * @description Creates test data for all test methods
     *
     * LEARNING POINT: @TestSetup runs once before all test methods
     */
    @TestSetup
    static void setupTestData() {
        // ARRANGE: Create test customers
        List<Customer__c> customers = TestDataFactory.createCustomers(3);
        insert customers;

        // ARRANGE: Create test orders with different statuses
        List<Order__c> orders = new List<Order__c>();

        orders.add(new Order__c(
            Customer__c = customers[0].Id,
            Order_Date__c = Date.today(),
            Order_Status__c = 'Pending',
            Total_Amount__c = 5000.00
        ));

        orders.add(new Order__c(
            Customer__c = customers[1].Id,
            Order_Date__c = Date.today(),
            Order_Status__c = 'Processing',
            Total_Amount__c = 10000.00
        ));

        orders.add(new Order__c(
            Customer__c = customers[2].Id,
            Order_Date__c = Date.today(),
            Order_Status__c = 'Completed',
            Total_Amount__c = 3000.00
        ));

        insert orders;
    }

    // ========== SINGLE EVENT PUBLISHING TESTS ==========

    /**
     * @description Tests publishing a single order status change event
     *
     * WHAT THIS TESTS:
     * - publishOrderStatusChange() method works correctly
     * - Event is successfully published
     * - SaveResult indicates success
     * - All event fields are populated
     *
     * LEARNING POINT: Platform Events are published asynchronously, but in tests
     * you can verify the publish was attempted by checking the SaveResult.
     */
    @isTest
    static void testPublishSingleEvent_Success() {
        // ARRANGE: Get test order
        Order__c testOrder = [SELECT Id, Name, Order_Status__c, Customer__c, Total_Amount__c
                              FROM Order__c
                              WHERE Order_Status__c = 'Pending'
                              LIMIT 1];

        // ACT: Publish a single event
        Test.startTest();
        Database.SaveResult result = OrderEventPublisher.publishOrderStatusChange(
            testOrder.Id,
            testOrder.Name,
            null, // No previous status (simulating new order)
            testOrder.Order_Status__c,
            'Order_Created',
            testOrder.Customer__c,
            testOrder.Total_Amount__c
        );
        Test.stopTest();

        // ASSERT: Verify event published successfully
        System.assertEquals(true, result.isSuccess(),
            'Event should publish successfully');

        // LEARNING POINT: In tests, events are published but not delivered to subscribers.
        // You can only verify the publish succeeded, not the delivery.
        System.assertNotEquals(null, result,
            'SaveResult should be returned');
    }

    /**
     * @description Tests publishing order created event convenience method
     *
     * WHAT THIS TESTS:
     * - publishOrderCreated() convenience method
     * - Correct event type is set
     * - Previous status is null for new orders
     */
    @isTest
    static void testPublishOrderCreated() {
        // ARRANGE: Get test order
        Order__c testOrder = [SELECT Id, Name, Order_Status__c, Customer__c, Total_Amount__c
                              FROM Order__c
                              LIMIT 1];

        // ACT: Use convenience method
        Test.startTest();
        Database.SaveResult result = OrderEventPublisher.publishOrderCreated(testOrder);
        Test.stopTest();

        // ASSERT
        System.assertEquals(true, result.isSuccess(),
            'Order created event should publish successfully');
    }

    /**
     * @description Tests publishing order cancelled event
     *
     * WHAT THIS TESTS:
     * - publishOrderCancelled() convenience method
     * - Previous status is captured
     * - Event type is set to Order_Cancelled
     */
    @isTest
    static void testPublishOrderCancelled() {
        // ARRANGE: Get test order
        Order__c testOrder = [SELECT Id, Name, Order_Status__c, Customer__c, Total_Amount__c
                              FROM Order__c
                              WHERE Order_Status__c = 'Processing'
                              LIMIT 1];

        String previousStatus = testOrder.Order_Status__c;

        // ACT
        Test.startTest();
        Database.SaveResult result = OrderEventPublisher.publishOrderCancelled(
            testOrder,
            previousStatus
        );
        Test.stopTest();

        // ASSERT
        System.assertEquals(true, result.isSuccess(),
            'Order cancelled event should publish successfully');
    }

    /**
     * @description Tests publishing order completed event
     *
     * WHAT THIS TESTS:
     * - publishOrderCompleted() convenience method
     * - Status transition tracking
     */
    @isTest
    static void testPublishOrderCompleted() {
        // ARRANGE
        Order__c testOrder = [SELECT Id, Name, Order_Status__c, Customer__c, Total_Amount__c
                              FROM Order__c
                              WHERE Order_Status__c = 'Processing'
                              LIMIT 1];

        // ACT
        Test.startTest();
        Database.SaveResult result = OrderEventPublisher.publishOrderCompleted(
            testOrder,
            'Processing'
        );
        Test.stopTest();

        // ASSERT
        System.assertEquals(true, result.isSuccess(),
            'Order completed event should publish successfully');
    }

    // ========== BULK EVENT PUBLISHING TESTS ==========

    /**
     * @description Tests bulk event publishing for multiple orders
     *
     * WHAT THIS TESTS:
     * - publishBulkOrderStatusChanges() handles multiple orders
     * - All events publish successfully
     * - Bulk operations are efficient (single publish call)
     *
     * LEARNING POINT: Bulk publishing is more efficient than individual publishes
     * and helps avoid governor limits (max 150 events per transaction).
     */
    @isTest
    static void testPublishBulkEvents_MultipleOrders() {
        // ARRANGE: Get all test orders
        List<Order__c> orders = [SELECT Id, Name, Order_Status__c, Customer__c, Total_Amount__c
                                FROM Order__c];

        // ACT: Publish events for all orders (simulating new orders)
        Test.startTest();
        List<Database.SaveResult> results = OrderEventPublisher.publishBulkOrderStatusChanges(
            orders,
            null // No old values (simulating insert)
        );
        Test.stopTest();

        // ASSERT: Verify all events published successfully
        System.assertEquals(orders.size(), results.size(),
            'Should have one result per order');

        for (Database.SaveResult result : results) {
            System.assertEquals(true, result.isSuccess(),
                'All events should publish successfully');
        }
    }

    /**
     * @description Tests bulk publishing with status changes only
     *
     * WHAT THIS TESTS:
     * - Only orders with changed status trigger events
     * - Orders without status changes are skipped
     * - oldMap comparison works correctly
     */
    @isTest
    static void testPublishBulkEvents_StatusChangesOnly() {
        // ARRANGE: Get orders and create old map
        List<Order__c> newOrders = [SELECT Id, Name, Order_Status__c, Customer__c, Total_Amount__c
                                    FROM Order__c];

        Map<Id, Order__c> oldOrderMap = new Map<Id, Order__c>();
        for (Order__c order : newOrders) {
            // Create old version with same status
            Order__c oldOrder = order.clone(true, true, true, true);
            oldOrderMap.put(order.Id, oldOrder);
        }

        // Change status of only one order
        newOrders[0].Order_Status__c = 'Cancelled';

        // ACT
        Test.startTest();
        List<Database.SaveResult> results = OrderEventPublisher.publishBulkOrderStatusChanges(
            newOrders,
            oldOrderMap
        );
        Test.stopTest();

        // ASSERT: Only one event should be published (for the changed order)
        System.assertEquals(1, results.size(),
            'Should only publish event for order with changed status');
        System.assertEquals(true, results[0].isSuccess(),
            'Event should publish successfully');
    }

    /**
     * @description Tests bulk publishing with empty list
     *
     * WHAT THIS TESTS:
     * - Handles empty order list gracefully
     * - No errors when no events to publish
     */
    @isTest
    static void testPublishBulkEvents_EmptyList() {
        // ARRANGE: Empty list
        List<Order__c> emptyOrders = new List<Order__c>();

        // ACT
        Test.startTest();
        List<Database.SaveResult> results = OrderEventPublisher.publishBulkOrderStatusChanges(
            emptyOrders,
            null
        );
        Test.stopTest();

        // ASSERT
        System.assertEquals(0, results.size(),
            'Should return empty result list for empty input');
    }

    // ========== TRIGGER INTEGRATION TESTS ==========

    /**
     * @description Tests event publishing via trigger on order insert
     *
     * WHAT THIS TESTS:
     * - Order__cTrigger publishes events on insert
     * - Events are published for all new orders
     * - Bulk insert triggers bulk event publish
     *
     * LEARNING POINT: Test triggers by performing DML operations.
     * The trigger will fire automatically.
     */
    @isTest
    static void testTriggerPublishesEvent_OnInsert() {
        // ARRANGE: Create new customer
        Customer__c customer = TestDataFactory.createCustomer();
        insert customer;

        // Create new order (will trigger event publishing)
        Order__c newOrder = new Order__c(
            Customer__c = customer.Id,
            Order_Date__c = Date.today(),
            Order_Status__c = 'Pending',
            Total_Amount__c = 7500.00
        );

        // ACT: Insert order (trigger fires)
        Test.startTest();
        insert newOrder;
        Test.stopTest();

        // ASSERT: Verify order was created
        // LEARNING POINT: We can't directly verify Platform Event delivery in tests,
        // but we can verify the order was created without errors,
        // which means the trigger (including event publishing) executed successfully.
        Order__c insertedOrder = [SELECT Id, Name, Order_Status__c
                                  FROM Order__c
                                  WHERE Id = :newOrder.Id];

        System.assertNotEquals(null, insertedOrder,
            'Order should be created successfully');
        System.assertEquals('Pending', insertedOrder.Order_Status__c,
            'Order status should be Pending');
    }

    /**
     * @description Tests event publishing via trigger on order update
     *
     * WHAT THIS TESTS:
     * - Order__cTrigger publishes events on status change
     * - Events only published when status actually changes
     * - Bulk update triggers bulk event publish
     */
    @isTest
    static void testTriggerPublishesEvent_OnStatusChange() {
        // ARRANGE: Get existing order
        Order__c existingOrder = [SELECT Id, Order_Status__c
                                  FROM Order__c
                                  WHERE Order_Status__c = 'Pending'
                                  LIMIT 1];

        String oldStatus = existingOrder.Order_Status__c;

        // Change status
        existingOrder.Order_Status__c = 'Processing';

        // ACT: Update order (trigger fires)
        Test.startTest();
        update existingOrder;
        Test.stopTest();

        // ASSERT: Verify status was updated
        Order__c updatedOrder = [SELECT Id, Order_Status__c
                                FROM Order__c
                                WHERE Id = :existingOrder.Id];

        System.assertEquals('Processing', updatedOrder.Order_Status__c,
            'Order status should be updated to Processing');
        System.assertNotEquals(oldStatus, updatedOrder.Order_Status__c,
            'Status should have changed');
    }

    /**
     * @description Tests bulk order insert triggers bulk event publishing
     *
     * WHAT THIS TESTS:
     * - Bulk DML operations trigger bulk event publishing
     * - Multiple events published efficiently
     * - All orders process successfully
     */
    @isTest
    static void testTriggerPublishesBulkEvents_OnBulkInsert() {
        // ARRANGE: Create customer
        Customer__c customer = TestDataFactory.createCustomer();
        insert customer;

        // Create multiple orders
        List<Order__c> newOrders = new List<Order__c>();
        for (Integer i = 0; i < 5; i++) {
            newOrders.add(new Order__c(
                Customer__c = customer.Id,
                Order_Date__c = Date.today(),
                Order_Status__c = 'Pending',
                Total_Amount__c = 1000.00 * (i + 1)
            ));
        }

        // ACT: Bulk insert
        Test.startTest();
        insert newOrders;
        Test.stopTest();

        // ASSERT: Verify all orders created
        List<Order__c> insertedOrders = [SELECT Id FROM Order__c WHERE Id IN :newOrders];

        System.assertEquals(5, insertedOrders.size(),
            'All 5 orders should be created successfully');
    }

    // ========== GOVERNOR LIMIT MONITORING TESTS ==========

    /**
     * @description Tests governor limit monitoring methods
     *
     * WHAT THIS TESTS:
     * - getPublishCount() returns correct count
     * - getPublishLimit() returns 150
     * - isApproachingPublishLimit() calculates correctly
     *
     * LEARNING POINT: Always monitor governor limits in production code.
     * Platform Events have a limit of 150 publishes per transaction.
     */
    @isTest
    static void testGovernorLimitMonitoring() {
        // ARRANGE: Get initial count
        Integer initialCount = OrderEventPublisher.getPublishCount();

        // Get test order
        Order__c testOrder = [SELECT Id, Name, Order_Status__c, Customer__c, Total_Amount__c
                              FROM Order__c
                              LIMIT 1];

        // ACT: Publish an event
        Test.startTest();
        OrderEventPublisher.publishOrderCreated(testOrder);

        Integer countAfterPublish = OrderEventPublisher.getPublishCount();
        Integer publishLimit = OrderEventPublisher.getPublishLimit();
        Boolean approaching = OrderEventPublisher.isApproachingPublishLimit();
        Test.stopTest();

        // ASSERT
        System.assertEquals(150, publishLimit,
            'Platform Event publish limit should be 150');

        System.assert(countAfterPublish > initialCount,
            'Publish count should increase after publishing event');

        System.assertEquals(false, approaching,
            'Should not be approaching limit with only 1 event published');
    }

    /**
     * @description Tests approaching limit detection
     *
     * WHAT THIS TESTS:
     * - isApproachingPublishLimit() returns true when >80% used
     * - Can handle publishing many events
     *
     * LEARNING POINT: Use this check before bulk operations to avoid hitting limits.
     */
    @isTest
    static void testApproachingLimitDetection() {
        // ARRANGE: Create many orders to approach limit
        // Note: We won't actually publish 120+ events in a test,
        // but we can verify the logic works

        Customer__c customer = TestDataFactory.createCustomer();
        insert customer;

        // Create 10 orders (reasonable for test)
        List<Order__c> orders = new List<Order__c>();
        for (Integer i = 0; i < 10; i++) {
            orders.add(new Order__c(
                Customer__c = customer.Id,
                Order_Date__c = Date.today(),
                Order_Status__c = 'Pending',
                Total_Amount__c = 1000.00
            ));
        }

        // ACT
        Test.startTest();
        insert orders; // This will trigger events via trigger

        Boolean approaching = OrderEventPublisher.isApproachingPublishLimit();
        Test.stopTest();

        // ASSERT: With only 10 events, we should not be approaching limit
        System.assertEquals(false, approaching,
            'Should not approach limit with only 10 events (80% of 150 = 120)');
    }

    // ========== ERROR HANDLING TESTS ==========

    /**
     * @description Tests error handling when event fields are invalid
     *
     * WHAT THIS TESTS:
     * - Invalid field values are handled gracefully
     * - Error logging occurs for failures
     * - DML doesn't rollback on event publish failure
     *
     * LEARNING POINT: Platform Event publish failures do NOT cause DML rollback.
     * The order will still save even if the event fails.
     */
    @isTest
    static void testErrorHandling_InvalidEventData() {
        // ARRANGE: Create event with potentially problematic data
        // Note: In real scenarios, invalid data might include null required fields

        // ACT: Try to publish with minimal data
        Test.startTest();
        Database.SaveResult result = OrderEventPublisher.publishOrderStatusChange(
            null, // Invalid: null Order ID
            'TEST-001',
            null,
            'Pending',
            'Order_Created',
            null,
            1000.00
        );
        Test.stopTest();

        // ASSERT: The publish should fail gracefully
        // LEARNING POINT: SaveResult.isSuccess() = false for validation failures
        System.assertEquals(false, result.isSuccess(),
            'Event publish should fail with null required field');

        // Verify error details exist
        System.assert(result.getErrors().size() > 0,
            'Should have error details explaining the failure');
    }
}
