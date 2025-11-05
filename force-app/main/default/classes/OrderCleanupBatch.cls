/**
 * @description Batch Apex class for cleaning up old completed/cancelled orders
 *
 * This class demonstrates Database.Batchable interface for processing large
 * datasets that exceed synchronous governor limits. It processes orders in
 * chunks (batches) to stay within limits while handling millions of records.
 *
 * LEARNING OBJECTIVES:
 * - Understand Database.Batchable interface (start, execute, finish)
 * - Learn batch processing for large datasets
 * - Master scope and batch size concepts
 * - Implement stateful batch processing
 * - Handle governor limits in async context
 * - Use Database.QueryLocator for efficient queries
 *
 * REAL-WORLD USE CASES:
 * - Data cleanup and archival
 * - Bulk updates across large datasets
 * - Data migration and transformation
 * - Scheduled maintenance operations
 * - Report generation for large datasets
 *
 * GOVERNOR LIMITS (Batch Context):
 * - 50,000 SOQL queries per batch
 * - 10,000 DML statements per batch
 * - 5 batch jobs in queue
 * - 100 batch jobs per 24 hours
 *
 * @author TechSolutions Learning Team
 * @date 2025-11-05
 * @group Async Processing
 */
public class OrderCleanupBatch implements Database.Batchable<SObject>, Database.Stateful {

    // LEARNING POINT: Database.Stateful allows instance variables to persist
    // across batch executions. Use this for tracking totals, errors, etc.
    private Integer recordsProcessed = 0;
    private Integer recordsDeleted = 0;
    private Integer recordsArchived = 0;
    private List<String> errors = new List<String>();

    // Configuration
    private Integer daysToKeep;
    private Boolean archiveBeforeDelete;

    /**
     * @description Constructor with configuration options
     *
     * @param daysToKeep Number of days to retain completed/cancelled orders
     * @param archiveBeforeDelete If true, archive orders before deleting
     */
    public OrderCleanupBatch(Integer daysToKeep, Boolean archiveBeforeDelete) {
        this.daysToKeep = daysToKeep != null ? daysToKeep : 365; // Default 1 year
        this.archiveBeforeDelete = archiveBeforeDelete != null ? archiveBeforeDelete : false;
    }

    /**
     * @description Default constructor (1 year retention, no archival)
     */
    public OrderCleanupBatch() {
        this(365, false);
    }

    /**
     * @description Start method - defines the scope of records to process
     *
     * LEARNING POINT: The start() method runs once at the beginning and returns
     * either a Database.QueryLocator or an Iterable. QueryLocator is preferred
     * for large datasets as it bypasses the 50,000 row limit.
     *
     * @param context Batch context containing job ID and other metadata
     * @return Database.QueryLocator defining records to process
     */
    public Database.QueryLocator start(Database.BatchableContext context) {
        // STEP 1: Calculate cutoff date
        Date cutoffDate = Date.today().addDays(-daysToKeep);

        // STEP 2: Build query for orders to clean up
        // LEARNING POINT: QueryLocator can process up to 50 million records!
        // The query executes in chunks (batches) automatically.
        String query = 'SELECT Id, Name, Order_Status__c, Order_Date__c, ' +
                       'Total_Amount__c, Customer__c, CreatedDate ' +
                       'FROM Order__c ' +
                       'WHERE (Order_Status__c = \'Completed\' OR Order_Status__c = \'Cancelled\') ' +
                       'AND Order_Date__c < :cutoffDate ' +
                       'ORDER BY Order_Date__c ASC';

        // STEP 3: Log job start
        System.debug(LoggingLevel.INFO,
            'OrderCleanupBatch started: Processing orders older than ' + cutoffDate);

        return Database.getQueryLocator(query);
    }

    /**
     * @description Execute method - processes each batch of records
     *
     * LEARNING POINT: execute() runs multiple times, once per batch.
     * Default batch size is 200, but can be set when executing the job.
     * Each execution has its own governor limits!
     *
     * @param context Batch context
     * @param scope List of records in this batch (max 2000, default 200)
     */
    public void execute(Database.BatchableContext context, List<Order__c> scope) {
        // STEP 1: Track records in this batch
        recordsProcessed += scope.size();

        try {
            // STEP 2: Archive orders if configured
            if (archiveBeforeDelete) {
                archiveOrders(scope);
            }

            // STEP 3: Delete orders
            // LEARNING POINT: Use Database.delete() instead of 'delete' to handle
            // partial failures gracefully
            List<Database.DeleteResult> results = Database.delete(scope, false); // allOrNone = false

            // STEP 4: Process results
            for (Integer i = 0; i < results.size(); i++) {
                Database.DeleteResult result = results[i];

                if (result.isSuccess()) {
                    recordsDeleted++;
                } else {
                    // Handle deletion failure
                    String errorMsg = 'Failed to delete Order ' + scope[i].Name + ': ';
                    for (Database.Error error : result.getErrors()) {
                        errorMsg += error.getMessage() + '; ';
                    }
                    errors.add(errorMsg);

                    // Log error
                    System.debug(LoggingLevel.ERROR, errorMsg);
                }
            }

        } catch (Exception e) {
            // LEARNING POINT: Exceptions in execute() don't stop the batch.
            // The batch continues with the next scope. Always log errors!
            String errorMsg = 'Exception in batch execution: ' + e.getMessage();
            errors.add(errorMsg);
            System.debug(LoggingLevel.ERROR, errorMsg);

            // Log to error tracking system
            ErrorLogger.logError('OrderCleanupBatch', 'execute', e);
        }
    }

    /**
     * @description Finish method - runs once after all batches complete
     *
     * LEARNING POINT: Use finish() for final cleanup, sending summary emails,
     * chaining to other jobs, or logging completion status.
     *
     * @param context Batch context
     */
    public void finish(Database.BatchableContext context) {
        // STEP 1: Log completion summary
        System.debug(LoggingLevel.INFO,
            'OrderCleanupBatch completed:\n' +
            '  Records Processed: ' + recordsProcessed + '\n' +
            '  Records Deleted: ' + recordsDeleted + '\n' +
            '  Records Archived: ' + recordsArchived + '\n' +
            '  Errors: ' + errors.size());

        // STEP 2: Send summary email to admin
        sendCompletionEmail(context.getJobId());

        // STEP 3: Log any errors to error tracking system
        if (!errors.isEmpty()) {
            String errorSummary = 'OrderCleanupBatch completed with errors:\n' +
                                 String.join(errors, '\n');
            ErrorLogger.logError(
                'OrderCleanupBatch',
                'finish',
                new BatchException(errorSummary)
            );
        }

        // STEP 4: Optionally chain to another job
        // Example: After cleanup, run a report generation batch
        // Database.executeBatch(new OrderReportBatch(), 200);
    }

    /**
     * @description Archives orders to external system or Big Object
     *
     * LEARNING POINT: Before deleting data, consider archiving for compliance,
     * historical analysis, or audit requirements.
     *
     * @param orders List of orders to archive
     */
    private void archiveOrders(List<Order__c> orders) {
        try {
            // OPTION 1: Archive to Big Object (for massive scale)
            // Big Objects can store billions of records
            List<Order_Archive__b> archives = new List<Order_Archive__b>();
            for (Order__c order : orders) {
                // Create Big Object record
                // Order_Archive__b archive = new Order_Archive__b(
                //     Order_Id__c = order.Id,
                //     Order_Number__c = order.Name,
                //     Order_Date__c = order.Order_Date__c,
                //     Total_Amount__c = order.Total_Amount__c
                //     // ... map other fields
                // );
                // archives.add(archive);
            }
            // insert archives; // Big Object insert

            // OPTION 2: Archive to external system via API
            // ExternalArchiveService.archiveOrders(orders);

            // OPTION 3: Archive to Salesforce Files
            // Create CSV and attach to customer records
            // String csv = OrderCsvGenerator.generateCsv(orders);
            // ContentVersion file = createArchiveFile(csv);

            // For this example, we'll just count them
            recordsArchived += orders.size();

            System.debug(LoggingLevel.INFO,
                'Archived ' + orders.size() + ' orders');

        } catch (Exception e) {
            String errorMsg = 'Failed to archive orders: ' + e.getMessage();
            errors.add(errorMsg);
            System.debug(LoggingLevel.ERROR, errorMsg);
            // Continue with deletion even if archive fails (or throw if critical)
        }
    }

    /**
     * @description Sends completion summary email to system administrator
     *
     * @param jobId The batch job ID
     */
    private void sendCompletionEmail(Id jobId) {
        // LEARNING POINT: Query AsyncApexJob for batch job details
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                   TotalJobItems, CreatedDate, CompletedDate
            FROM AsyncApexJob
            WHERE Id = :jobId
        ];

        // Build email body
        String emailBody = 'Order Cleanup Batch Job Summary\n\n' +
                          'Job ID: ' + jobId + '\n' +
                          'Status: ' + job.Status + '\n' +
                          'Started: ' + job.CreatedDate + '\n' +
                          'Completed: ' + job.CompletedDate + '\n' +
                          'Batches Processed: ' + job.JobItemsProcessed +
                            ' of ' + job.TotalJobItems + '\n' +
                          'Errors: ' + job.NumberOfErrors + '\n\n' +
                          'Records Processed: ' + recordsProcessed + '\n' +
                          'Records Deleted: ' + recordsDeleted + '\n' +
                          'Records Archived: ' + recordsArchived + '\n\n';

        if (!errors.isEmpty()) {
            emailBody += 'Errors Encountered:\n' +
                        String.join(errors, '\n');
        }

        // Send email
        try {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[]{ UserInfo.getUserEmail() });
            email.setSubject('Order Cleanup Batch Completed - ' + job.Status);
            email.setPlainTextBody(emailBody);

            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ email });

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,
                'Failed to send completion email: ' + e.getMessage());
        }
    }

    /**
     * @description Custom exception for batch processing errors
     */
    public class BatchException extends Exception {}
}
