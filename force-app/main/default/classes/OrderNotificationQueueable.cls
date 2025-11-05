/**
 * @description Queueable class for sending order notifications asynchronously
 *
 * This class demonstrates the Queueable interface for async processing with
 * the ability to chain jobs and make callouts. Queueable jobs are ideal for
 * operations that need async execution but also require chaining or callouts.
 *
 * LEARNING OBJECTIVES:
 * - Understand Queueable interface and execute() method
 * - Learn job chaining with System.enqueueJob()
 * - Master callout capabilities in async context
 * - Implement retry logic for failed operations
 * - Handle governor limits in queueable context
 *
 * REAL-WORLD USE CASES:
 * - Sending notifications (email, SMS, push)
 * - Making HTTP callouts to external systems
 * - Chaining multiple async operations
 * - Processing records that require external API calls
 * - Retry mechanisms for failed operations
 *
 * GOVERNOR LIMITS (Queueable Context):
 * - 50 queueable jobs per transaction (from synchronous code)
 * - 1 child queueable per parent queueable
 * - Callouts allowed (unlike @future)
 * - 12-hour max execution time
 *
 * QUEUEABLE vs @FUTURE vs BATCH:
 * - Queueable: Can chain jobs, make callouts, track job ID
 * - @future: Simple async, no chaining, can make callouts
 * - Batch: Large datasets, iterative processing, no callouts
 *
 * @author TechSolutions Learning Team
 * @date 2025-11-05
 * @group Async Processing
 */
public class OrderNotificationQueueable implements Queueable, Database.AllowsCallouts {

    // Instance variables to hold data for processing
    private List<Id> orderIds;
    private String notificationType;
    private Integer retryCount;

    // Notification types
    public static final String NOTIFICATION_EMAIL = 'Email';
    public static final String NOTIFICATION_SMS = 'SMS';
    public static final String NOTIFICATION_PUSH = 'Push';
    public static final String NOTIFICATION_WEBHOOK = 'Webhook';

    /**
     * @description Constructor with order IDs and notification type
     *
     * @param orderIds List of order IDs to send notifications for
     * @param notificationType Type of notification (Email, SMS, Push, Webhook)
     */
    public OrderNotificationQueueable(List<Id> orderIds, String notificationType) {
        this.orderIds = orderIds;
        this.notificationType = notificationType;
        this.retryCount = 0;
    }

    /**
     * @description Private constructor for retry attempts
     *
     * @param orderIds List of order IDs
     * @param notificationType Type of notification
     * @param retryCount Current retry attempt number
     */
    private OrderNotificationQueueable(
        List<Id> orderIds,
        String notificationType,
        Integer retryCount
    ) {
        this.orderIds = orderIds;
        this.notificationType = notificationType;
        this.retryCount = retryCount;
    }

    /**
     * @description Execute method - processes the queueable job
     *
     * LEARNING POINT: execute() runs asynchronously in a separate thread.
     * Unlike batch apex, this runs once (not iteratively) and processes
     * all records together. Use for < 50,000 records typically.
     *
     * @param context Queueable context containing job ID
     */
    public void execute(QueueableContext context) {
        System.debug(LoggingLevel.INFO,
            'OrderNotificationQueueable started: Job ID = ' + context.getJobId());

        try {
            // STEP 1: Query orders with customer information
            List<Order__c> orders = [
                SELECT Id, Name, Order_Status__c, Total_Amount__c,
                       Customer__c, Customer__r.Name, Customer__r.Email__c,
                       Customer__r.Phone__c, Order_Date__c
                FROM Order__c
                WHERE Id IN :orderIds
                LIMIT 200 // Process max 200 per job
            ];

            if (orders.isEmpty()) {
                System.debug(LoggingLevel.WARN,
                    'No orders found for IDs: ' + orderIds);
                return;
            }

            // STEP 2: Send notifications based on type
            switch on notificationType {
                when 'Email' {
                    sendEmailNotifications(orders);
                }
                when 'SMS' {
                    sendSMSNotifications(orders);
                }
                when 'Push' {
                    sendPushNotifications(orders);
                }
                when 'Webhook' {
                    sendWebhookNotifications(orders);
                }
                when else {
                    throw new NotificationException('Unknown notification type: ' + notificationType);
                }
            }

            // STEP 3: If more than 200 orders, chain another job for the rest
            // LEARNING POINT: Queueable can chain to process large datasets
            if (orderIds.size() > 200) {
                chainNextBatch(context);
            }

            System.debug(LoggingLevel.INFO,
                'Successfully sent ' + notificationType + ' notifications for ' +
                orders.size() + ' orders');

        } catch (Exception e) {
            // STEP 4: Handle errors and retry if needed
            handleError(e, context);
        }
    }

    /**
     * @description Sends email notifications to customers
     *
     * @param orders List of orders to send notifications for
     */
    private void sendEmailNotifications(List<Order__c> orders) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Order__c order : orders) {
            // Skip if no email address
            if (String.isBlank(order.Customer__r.Email__c)) {
                continue;
            }

            // Build email message
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[]{ order.Customer__r.Email__c });
            email.setSubject('Order ' + order.Name + ' Update');

            String emailBody = 'Dear ' + order.Customer__r.Name + ',\n\n' +
                              'Your order ' + order.Name + ' has been updated.\n' +
                              'Status: ' + order.Order_Status__c + '\n' +
                              'Total: $' + order.Total_Amount__c + '\n' +
                              'Order Date: ' + order.Order_Date__c + '\n\n' +
                              'Thank you for your business!\n' +
                              'TechSolutions Team';

            email.setPlainTextBody(emailBody);
            emails.add(email);
        }

        // Send all emails in bulk
        // LEARNING POINT: Messaging.sendEmail() has a limit of 10 emails per call
        // For more emails, batch into groups of 10
        if (!emails.isEmpty()) {
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(emails, false);

            // Check results
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    System.debug(LoggingLevel.ERROR,
                        'Failed to send email for order ' + orders[i].Name + ': ' +
                        results[i].getErrors()[0].getMessage());
                }
            }
        }
    }

    /**
     * @description Sends SMS notifications via external SMS service
     *
     * LEARNING POINT: Queueable supports callouts (unlike some async methods)
     *
     * @param orders List of orders
     */
    private void sendSMSNotifications(List<Order__c> orders) {
        for (Order__c order : orders) {
            // Skip if no phone number
            if (String.isBlank(order.Customer__r.Phone__c)) {
                continue;
            }

            try {
                // STEP 1: Build SMS message
                String message = 'Order ' + order.Name + ' status: ' + order.Order_Status__c;

                // STEP 2: Call external SMS API
                // LEARNING POINT: Named Credentials simplify authentication
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:SMS_Service/send'); // Named Credential
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');

                Map<String, Object> requestBody = new Map<String, Object>{
                    'to' => order.Customer__r.Phone__c,
                    'message' => message,
                    'orderId' => order.Id
                };
                req.setBody(JSON.serialize(requestBody));

                // STEP 3: Send request
                Http http = new Http();
                HttpResponse res = http.send(req);

                // STEP 4: Check response
                if (res.getStatusCode() != 200 && res.getStatusCode() != 201) {
                    throw new CalloutException(
                        'SMS API returned status ' + res.getStatusCode() +
                        ': ' + res.getBody()
                    );
                }

                System.debug(LoggingLevel.INFO,
                    'SMS sent successfully for order ' + order.Name);

            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR,
                    'Failed to send SMS for order ' + order.Name + ': ' + e.getMessage());
                // Log error but continue with other orders
                ErrorLogger.logError('OrderNotificationQueueable', 'sendSMS', e);
            }
        }
    }

    /**
     * @description Sends push notifications to mobile apps
     *
     * @param orders List of orders
     */
    private void sendPushNotifications(List<Order__c> orders) {
        // Implementation would call push notification service
        // (Firebase Cloud Messaging, Apple Push Notification Service, etc.)

        for (Order__c order : orders) {
            try {
                // STEP 1: Build push notification payload
                Map<String, Object> payload = new Map<String, Object>{
                    'title' => 'Order Update',
                    'body' => 'Order ' + order.Name + ' is now ' + order.Order_Status__c,
                    'orderId' => order.Id,
                    'customerId' => order.Customer__c
                };

                // STEP 2: Call push notification service
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:Push_Service/send');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setBody(JSON.serialize(payload));

                Http http = new Http();
                HttpResponse res = http.send(req);

                if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                    System.debug(LoggingLevel.INFO,
                        'Push notification sent for order ' + order.Name);
                }

            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR,
                    'Failed to send push notification: ' + e.getMessage());
                ErrorLogger.logError('OrderNotificationQueueable', 'sendPush', e);
            }
        }
    }

    /**
     * @description Sends webhook notifications to external systems
     *
     * @param orders List of orders
     */
    private void sendWebhookNotifications(List<Order__c> orders) {
        for (Order__c order : orders) {
            try {
                // STEP 1: Build webhook payload
                Map<String, Object> webhook = new Map<String, Object>{
                    'event' => 'order.updated',
                    'timestamp' => System.now().getTime(),
                    'data' => new Map<String, Object>{
                        'orderId' => order.Id,
                        'orderNumber' => order.Name,
                        'status' => order.Order_Status__c,
                        'totalAmount' => order.Total_Amount__c,
                        'customerId' => order.Customer__c
                    }
                };

                // STEP 2: Send to webhook endpoint
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:Webhook_Endpoint');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setBody(JSON.serialize(webhook));

                Http http = new Http();
                HttpResponse res = http.send(req);

                System.debug(LoggingLevel.INFO,
                    'Webhook sent for order ' + order.Name +
                    ' - Status: ' + res.getStatusCode());

            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR,
                    'Webhook failed for order ' + order.Name + ': ' + e.getMessage());
                ErrorLogger.logError('OrderNotificationQueueable', 'sendWebhook', e);
            }
        }
    }

    /**
     * @description Chains another queueable job for remaining orders
     *
     * LEARNING POINT: Queueable can enqueue exactly 1 child job per execution.
     * Use this to process large datasets in chunks.
     *
     * @param context Current queueable context
     */
    private void chainNextBatch(QueueableContext context) {
        // Get remaining order IDs (skip first 200 we just processed)
        List<Id> remainingIds = new List<Id>();
        for (Integer i = 200; i < orderIds.size(); i++) {
            remainingIds.add(orderIds[i]);
        }

        if (!remainingIds.isEmpty()) {
            // Enqueue next batch
            // LEARNING POINT: Can only enqueue 1 child job from a queueable
            OrderNotificationQueueable nextJob = new OrderNotificationQueueable(
                remainingIds,
                notificationType
            );

            Id jobId = System.enqueueJob(nextJob);

            System.debug(LoggingLevel.INFO,
                'Chained next batch: Job ID = ' + jobId +
                ', Remaining orders = ' + remainingIds.size());
        }
    }

    /**
     * @description Handles errors with retry logic
     *
     * LEARNING POINT: Implement retry logic for transient failures
     *
     * @param e The exception that occurred
     * @param context Current queueable context
     */
    private void handleError(Exception e, QueueableContext context) {
        System.debug(LoggingLevel.ERROR,
            'Error in OrderNotificationQueueable: ' + e.getMessage());

        // Log error
        ErrorLogger.logError('OrderNotificationQueueable', 'execute', e);

        // Retry logic (max 3 attempts)
        if (retryCount < 3) {
            System.debug(LoggingLevel.WARN,
                'Retrying notification job (attempt ' + (retryCount + 1) + ')');

            // Wait a bit before retry (not directly possible, but job will queue)
            OrderNotificationQueueable retryJob = new OrderNotificationQueueable(
                orderIds,
                notificationType,
                retryCount + 1
            );

            try {
                System.enqueueJob(retryJob);
            } catch (Exception retryException) {
                System.debug(LoggingLevel.ERROR,
                    'Failed to enqueue retry: ' + retryException.getMessage());
            }
        } else {
            System.debug(LoggingLevel.ERROR,
                'Max retries exceeded for notification job');
            // Could send alert to admin here
        }
    }

    /**
     * @description Custom exception for notification errors
     */
    public class NotificationException extends Exception {}
}
