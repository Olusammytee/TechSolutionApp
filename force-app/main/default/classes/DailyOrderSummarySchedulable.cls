/**
 * @description Schedulable class for generating daily order summary reports
 *
 * This class demonstrates the Schedulable interface for running Apex code
 * on a defined schedule (daily, weekly, hourly, etc.). It's ideal for regular
 * maintenance tasks, reports, data synchronization, and batch job triggers.
 *
 * LEARNING OBJECTIVES:
 * - Understand Schedulable interface and execute() method
 * - Learn cron expressions for scheduling
 * - Master System.schedule() API
 * - Implement scheduled job monitoring
 * - Combine Schedulable with Batch/Queueable for complex workflows
 *
 * REAL-WORLD USE CASES:
 * - Daily/weekly/monthly report generation
 * - Scheduled data cleanup and maintenance
 * - Regular data synchronization with external systems
 * - Nightly batch job execution
 * - Periodic health checks and monitoring
 *
 * GOVERNOR LIMITS (Schedulable):
 * - 100 scheduled jobs per org
 * - Jobs can trigger batch/queueable jobs
 * - Max 10 concurrent batch jobs
 * - Cannot make callouts directly (use @future or Queueable)
 *
 * CRON EXPRESSION FORMAT:
 * Seconds Minutes Hours Day_of_Month Month Day_of_Week Optional_Year
 * Example: '0 0 0 * * ?' = Daily at midnight
 *
 * @author TechSolutions Learning Team
 * @date 2025-11-05
 * @group Async Processing
 */
public class DailyOrderSummarySchedulable implements Schedulable {

    // Configuration
    private Boolean sendEmailReport;
    private Integer daysToInclude;

    /**
     * @description Constructor with configuration options
     *
     * @param sendEmailReport If true, email summary to administrators
     * @param daysToInclude Number of days to include in report (default 1)
     */
    public DailyOrderSummarySchedulable(Boolean sendEmailReport, Integer daysToInclude) {
        this.sendEmailReport = sendEmailReport != null ? sendEmailReport : true;
        this.daysToInclude = daysToInclude != null ? daysToInclude : 1;
    }

    /**
     * @description Default constructor (email enabled, 1 day)
     */
    public DailyOrderSummarySchedulable() {
        this(true, 1);
    }

    /**
     * @description Execute method - runs when scheduled job fires
     *
     * LEARNING POINT: execute() runs at the scheduled time defined by cron expression.
     * Keep this method lightweight - use it to trigger batch jobs or queueable jobs
     * for heavy processing.
     *
     * @param context Schedulable context containing trigger ID and job details
     */
    public void execute(SchedulableContext context) {
        System.debug(LoggingLevel.INFO,
            'DailyOrderSummarySchedulable started: Trigger ID = ' + context.getTriggerId());

        try {
            // STEP 1: Generate order summary
            OrderSummary summary = generateOrderSummary();

            // STEP 2: Send email report if configured
            if (sendEmailReport) {
                sendSummaryEmail(summary);
            }

            // STEP 3: Optionally trigger batch cleanup
            // LEARNING POINT: Schedulable can trigger batch jobs
            // This is a common pattern for nightly maintenance
            triggerBatchCleanup();

            // STEP 4: Log completion
            System.debug(LoggingLevel.INFO,
                'Daily order summary completed: ' +
                summary.totalOrders + ' orders processed');

        } catch (Exception e) {
            // STEP 5: Handle errors
            System.debug(LoggingLevel.ERROR,
                'Error in DailyOrderSummarySchedulable: ' + e.getMessage());

            // Log error
            ErrorLogger.logError('DailyOrderSummarySchedulable', 'execute', e);

            // Send alert to admin
            sendErrorAlert(e);
        }
    }

    /**
     * @description Generates order summary for the specified period
     *
     * @return OrderSummary wrapper with aggregated data
     */
    private OrderSummary generateOrderSummary() {
        // STEP 1: Calculate date range
        Date startDate = Date.today().addDays(-daysToInclude);
        Date endDate = Date.today();

        // STEP 2: Aggregate order data
        // LEARNING POINT: Use aggregate queries for efficient summary statistics
        List<AggregateResult> results = [
            SELECT
                COUNT(Id) totalCount,
                SUM(Total_Amount__c) totalRevenue,
                AVG(Total_Amount__c) avgOrderValue,
                Order_Status__c status
            FROM Order__c
            WHERE Order_Date__c >= :startDate
            AND Order_Date__c < :endDate
            GROUP BY Order_Status__c
        ];

        // STEP 3: Build summary object
        OrderSummary summary = new OrderSummary();
        summary.startDate = startDate;
        summary.endDate = endDate;
        summary.totalOrders = 0;
        summary.totalRevenue = 0;
        summary.ordersByStatus = new Map<String, Integer>();
        summary.revenueByStatus = new Map<String, Decimal>();

        for (AggregateResult result : results) {
            Integer count = (Integer) result.get('totalCount');
            Decimal revenue = (Decimal) result.get('totalRevenue');
            String status = (String) result.get('status');

            summary.totalOrders += count;
            summary.totalRevenue += revenue;
            summary.ordersByStatus.put(status, count);
            summary.revenueByStatus.put(status, revenue);
        }

        // Calculate average order value
        summary.avgOrderValue = summary.totalOrders > 0 ?
            summary.totalRevenue / summary.totalOrders : 0;

        // STEP 4: Query top customers
        summary.topCustomers = queryTopCustomers(startDate, endDate);

        // STEP 5: Query order trends
        summary.dailyTrends = queryDailyTrends(startDate, endDate);

        return summary;
    }

    /**
     * @description Queries top customers by order count
     *
     * @param startDate Start of date range
     * @param endDate End of date range
     * @return List of customer names and order counts
     */
    private List<CustomerSummary> queryTopCustomers(Date startDate, Date endDate) {
        List<AggregateResult> results = [
            SELECT
                Customer__c customerId,
                Customer__r.Name customerName,
                COUNT(Id) orderCount,
                SUM(Total_Amount__c) totalSpent
            FROM Order__c
            WHERE Order_Date__c >= :startDate
            AND Order_Date__c < :endDate
            GROUP BY Customer__c, Customer__r.Name
            ORDER BY COUNT(Id) DESC
            LIMIT 10
        ];

        List<CustomerSummary> topCustomers = new List<CustomerSummary>();
        for (AggregateResult result : results) {
            CustomerSummary customer = new CustomerSummary();
            customer.customerId = (Id) result.get('customerId');
            customer.customerName = (String) result.get('customerName');
            customer.orderCount = (Integer) result.get('orderCount');
            customer.totalSpent = (Decimal) result.get('totalSpent');
            topCustomers.add(customer);
        }

        return topCustomers;
    }

    /**
     * @description Queries daily order trends
     *
     * @param startDate Start of date range
     * @param endDate End of date range
     * @return List of daily order counts
     */
    private List<DailyTrend> queryDailyTrends(Date startDate, Date endDate) {
        List<AggregateResult> results = [
            SELECT
                Order_Date__c orderDate,
                COUNT(Id) orderCount,
                SUM(Total_Amount__c) dailyRevenue
            FROM Order__c
            WHERE Order_Date__c >= :startDate
            AND Order_Date__c < :endDate
            GROUP BY Order_Date__c
            ORDER BY Order_Date__c ASC
        ];

        List<DailyTrend> trends = new List<DailyTrend>();
        for (AggregateResult result : results) {
            DailyTrend trend = new DailyTrend();
            trend.orderDate = (Date) result.get('orderDate');
            trend.orderCount = (Integer) result.get('orderCount');
            trend.dailyRevenue = (Decimal) result.get('dailyRevenue');
            trends.add(trend);
        }

        return trends;
    }

    /**
     * @description Sends summary email to administrators
     *
     * @param summary OrderSummary to email
     */
    private void sendSummaryEmail(OrderSummary summary) {
        // STEP 1: Build email body
        String emailBody = buildEmailBody(summary);

        // STEP 2: Get admin email addresses
        List<String> adminEmails = getAdminEmails();

        if (adminEmails.isEmpty()) {
            System.debug(LoggingLevel.WARN,
                'No admin emails configured, skipping summary email');
            return;
        }

        // STEP 3: Send email
        try {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(adminEmails);
            email.setSubject('Daily Order Summary - ' + Date.today().format());
            email.setPlainTextBody(emailBody);

            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ email });

            System.debug(LoggingLevel.INFO, 'Summary email sent successfully');

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,
                'Failed to send summary email: ' + e.getMessage());
        }
    }

    /**
     * @description Builds formatted email body from summary data
     *
     * @param summary OrderSummary
     * @return Formatted email body
     */
    private String buildEmailBody(OrderSummary summary) {
        String body = 'DAILY ORDER SUMMARY REPORT\n';
        body += '================================\n\n';
        body += 'Period: ' + summary.startDate.format() + ' to ' +
                summary.endDate.format() + '\n\n';

        // Overall statistics
        body += 'OVERALL STATISTICS\n';
        body += '------------------\n';
        body += 'Total Orders: ' + summary.totalOrders + '\n';
        body += 'Total Revenue: $' + summary.totalRevenue.setScale(2) + '\n';
        body += 'Average Order Value: $' + summary.avgOrderValue.setScale(2) + '\n\n';

        // Orders by status
        body += 'ORDERS BY STATUS\n';
        body += '----------------\n';
        for (String status : summary.ordersByStatus.keySet()) {
            Integer count = summary.ordersByStatus.get(status);
            Decimal revenue = summary.revenueByStatus.get(status);
            body += status + ': ' + count + ' orders ($' + revenue.setScale(2) + ')\n';
        }
        body += '\n';

        // Top customers
        body += 'TOP 10 CUSTOMERS\n';
        body += '----------------\n';
        for (CustomerSummary customer : summary.topCustomers) {
            body += customer.customerName + ': ' + customer.orderCount +
                   ' orders ($' + customer.totalSpent.setScale(2) + ')\n';
        }
        body += '\n';

        // Daily trends
        body += 'DAILY TRENDS\n';
        body += '------------\n';
        for (DailyTrend trend : summary.dailyTrends) {
            body += trend.orderDate.format() + ': ' + trend.orderCount +
                   ' orders ($' + trend.dailyRevenue.setScale(2) + ')\n';
        }

        return body;
    }

    /**
     * @description Gets admin email addresses for reports
     *
     * @return List of admin email addresses
     */
    private List<String> getAdminEmails() {
        // OPTION 1: Query users with admin profile
        List<User> admins = [
            SELECT Email
            FROM User
            WHERE Profile.Name = 'System Administrator'
            AND IsActive = true
            LIMIT 10
        ];

        List<String> emails = new List<String>();
        for (User admin : admins) {
            if (String.isNotBlank(admin.Email)) {
                emails.add(admin.Email);
            }
        }

        // OPTION 2: Use Custom Metadata for configured emails
        // List<Report_Recipient__mdt> recipients = [
        //     SELECT Email__c FROM Report_Recipient__mdt
        // ];

        return emails;
    }

    /**
     * @description Triggers batch cleanup job
     *
     * LEARNING POINT: Schedulable commonly triggers batch jobs for heavy processing
     */
    private void triggerBatchCleanup() {
        try {
            // Trigger OrderCleanupBatch to run nightly
            OrderCleanupBatch batchJob = new OrderCleanupBatch(365, false);
            Id batchId = Database.executeBatch(batchJob, 200);

            System.debug(LoggingLevel.INFO,
                'Triggered OrderCleanupBatch: Batch ID = ' + batchId);

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,
                'Failed to trigger batch cleanup: ' + e.getMessage());
        }
    }

    /**
     * @description Sends error alert to administrators
     *
     * @param e The exception that occurred
     */
    private void sendErrorAlert(Exception e) {
        try {
            List<String> adminEmails = getAdminEmails();
            if (adminEmails.isEmpty()) return;

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(adminEmails);
            email.setSubject('ERROR: Daily Order Summary Failed');
            email.setPlainTextBody(
                'The daily order summary job encountered an error:\n\n' +
                'Error: ' + e.getMessage() + '\n' +
                'Type: ' + e.getTypeName() + '\n' +
                'Stack Trace:\n' + e.getStackTraceString()
            );

            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ email });

        } catch (Exception emailException) {
            System.debug(LoggingLevel.ERROR,
                'Failed to send error alert: ' + emailException.getMessage());
        }
    }

    // ========== INNER CLASSES (Data Transfer Objects) ==========

    /**
     * @description Wrapper class for order summary data
     */
    public class OrderSummary {
        public Date startDate;
        public Date endDate;
        public Integer totalOrders;
        public Decimal totalRevenue;
        public Decimal avgOrderValue;
        public Map<String, Integer> ordersByStatus;
        public Map<String, Decimal> revenueByStatus;
        public List<CustomerSummary> topCustomers;
        public List<DailyTrend> dailyTrends;

        public OrderSummary() {
            this.totalOrders = 0;
            this.totalRevenue = 0;
            this.avgOrderValue = 0;
            this.ordersByStatus = new Map<String, Integer>();
            this.revenueByStatus = new Map<String, Decimal>();
            this.topCustomers = new List<CustomerSummary>();
            this.dailyTrends = new List<DailyTrend>();
        }
    }

    /**
     * @description Wrapper class for customer summary data
     */
    public class CustomerSummary {
        public Id customerId;
        public String customerName;
        public Integer orderCount;
        public Decimal totalSpent;
    }

    /**
     * @description Wrapper class for daily trend data
     */
    public class DailyTrend {
        public Date orderDate;
        public Integer orderCount;
        public Decimal dailyRevenue;
    }

    // ========== SCHEDULING HELPER METHODS ==========

    /**
     * @description Schedules the job to run daily at midnight
     *
     * LEARNING POINT: Use cron expressions to define schedule
     * Format: Seconds Minutes Hours Day_of_Month Month Day_of_Week Year
     *
     * @return Scheduled job ID
     */
    public static Id scheduleDailyAtMidnight() {
        // Cron: '0 0 0 * * ?' = Every day at 12:00 AM
        String cronExp = '0 0 0 * * ?';
        String jobName = 'Daily Order Summary - Midnight';

        DailyOrderSummarySchedulable job = new DailyOrderSummarySchedulable();
        return System.schedule(jobName, cronExp, job);
    }

    /**
     * @description Schedules the job to run weekly on Monday mornings
     *
     * @return Scheduled job ID
     */
    public static Id scheduleWeeklyMonday() {
        // Cron: '0 0 8 ? * MON' = Every Monday at 8:00 AM
        String cronExp = '0 0 8 ? * MON';
        String jobName = 'Weekly Order Summary - Monday 8AM';

        DailyOrderSummarySchedulable job = new DailyOrderSummarySchedulable(true, 7);
        return System.schedule(jobName, cronExp, job);
    }

    /**
     * @description Schedules the job to run hourly
     *
     * @return Scheduled job ID
     */
    public static Id scheduleHourly() {
        // Cron: '0 0 * * * ?' = Every hour at the top of the hour
        String cronExp = '0 0 * * * ?';
        String jobName = 'Hourly Order Summary';

        DailyOrderSummarySchedulable job = new DailyOrderSummarySchedulable();
        return System.schedule(jobName, cronExp, job);
    }
}
