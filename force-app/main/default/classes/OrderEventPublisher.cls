/**
 * @description Service class for publishing Order-related Platform Events
 *
 * This class demonstrates event-driven architecture in Salesforce using Platform
 * Events. It publishes real-time notifications when orders change, enabling
 * decoupled, scalable system integration patterns.
 *
 * LEARNING OBJECTIVES:
 * - Understand Platform Events and publish/subscribe pattern
 * - Learn EventBus.publish() for event publishing
 * - Master event-driven architecture
 * - Implement decoupled system design
 * - Handle bulk event publishing
 * - Error handling for failed event delivery
 *
 * REAL-WORLD USE CASES:
 * - Real-time dashboard updates
 * - External system notifications
 * - Workflow triggering across org boundaries
 * - Audit trail and event logging
 * - Microservices communication
 *
 * @author TechSolutions Learning Team
 * @date 2025-11-04
 * @group Platform Events
 */
public with sharing class OrderEventPublisher {

    /**
     * @description Publishes a single order status change event
     *
     * LEARNING POINT: Platform Events enable real-time, fire-and-forget messaging.
     * Events are published via EventBus.publish() and delivered to all subscribers
     * asynchronously. This decouples the publisher from subscribers.
     *
     * @param orderId The ID of the order that changed
     * @param orderNumber The order number for display
     * @param previousStatus The status before the change (null for new orders)
     * @param newStatus The current status
     * @param eventType Type of event (Status_Change, Order_Created, etc.)
     * @param customerId The customer ID associated with the order
     * @param totalAmount The total amount of the order
     * @return Database.SaveResult indicating success or failure
     */
    public static Database.SaveResult publishOrderStatusChange(
        Id orderId,
        String orderNumber,
        String previousStatus,
        String newStatus,
        String eventType,
        Id customerId,
        Decimal totalAmount
    ) {
        // STEP 1: Create the Platform Event record
        // LEARNING POINT: Platform Events are SObjects with __e suffix
        OrderStatusChangeEvent__e event = new OrderStatusChangeEvent__e(
            Order_Id__c = orderId,
            Order_Number__c = orderNumber,
            Previous_Status__c = previousStatus,
            New_Status__c = newStatus,
            Event_Type__c = eventType,
            Customer_Id__c = customerId,
            Total_Amount__c = totalAmount,
            Changed_By_Name__c = UserInfo.getName()
        );

        // STEP 2: Publish the event
        // LEARNING POINT: EventBus.publish() is fire-and-forget.
        // The event is queued for delivery and delivered asynchronously.
        // Subscribers receive the event independently.
        Database.SaveResult result = EventBus.publish(event);

        // STEP 3: Log if publish failed
        // LEARNING POINT: Platform Events can fail to publish due to governor
        // limits or system issues. Always check the SaveResult.
        if (!result.isSuccess()) {
            handlePublishFailure(result, 'Single Event', orderId);
        }

        return result;
    }

    /**
     * @description Publishes multiple order status change events in bulk
     *
     * LEARNING POINT: For bulk operations, use EventBus.publish() with a list.
     * This is more efficient than publishing events individually and helps
     * avoid governor limits (max 150 event publishes per transaction).
     *
     * @param orders List of orders to publish events for
     * @param oldOrderMap Map of old order values (for comparing status changes)
     * @return List of Database.SaveResult for each event
     */
    public static List<Database.SaveResult> publishBulkOrderStatusChanges(
        List<Order__c> orders,
        Map<Id, Order__c> oldOrderMap
    ) {
        // STEP 1: Build list of events to publish
        List<OrderStatusChangeEvent__e> events = new List<OrderStatusChangeEvent__e>();

        for (Order__c order : orders) {
            // Get the old order for comparison (null if insert)
            Order__c oldOrder = oldOrderMap != null ? oldOrderMap.get(order.Id) : null;

            // Determine event type and previous status
            String eventType;
            String previousStatus;

            if (oldOrder == null) {
                // New order created
                eventType = 'Order_Created';
                previousStatus = null;
            } else if (order.Order_Status__c != oldOrder.Order_Status__c) {
                // Status changed
                eventType = 'Status_Change';
                previousStatus = oldOrder.Order_Status__c;
            } else {
                // Order updated but status didn't change - skip event
                continue;
            }

            // Create the event
            OrderStatusChangeEvent__e event = new OrderStatusChangeEvent__e(
                Order_Id__c = order.Id,
                Order_Number__c = order.Name,
                Previous_Status__c = previousStatus,
                New_Status__c = order.Order_Status__c,
                Event_Type__c = eventType,
                Customer_Id__c = order.Customer__c,
                Total_Amount__c = order.Total_Amount__c,
                Changed_By_Name__c = UserInfo.getName()
            );

            events.add(event);
        }

        // STEP 2: Publish all events in bulk
        // LEARNING POINT: Bulk publishing is atomic - either all events publish
        // successfully or none do (by default). Use allOrNone parameter to change this.
        if (events.isEmpty()) {
            return new List<Database.SaveResult>();
        }

        List<Database.SaveResult> results = EventBus.publish(events);

        // STEP 3: Handle any failures
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                handlePublishFailure(
                    results[i],
                    'Bulk Event ' + i,
                    events[i].Order_Id__c
                );
            }
        }

        return results;
    }

    /**
     * @description Publishes an order created event
     *
     * CONVENIENCE METHOD: Simplifies publishing when a new order is created.
     *
     * @param order The newly created order
     * @return Database.SaveResult
     */
    public static Database.SaveResult publishOrderCreated(Order__c order) {
        return publishOrderStatusChange(
            order.Id,
            order.Name,
            null, // No previous status for new orders
            order.Order_Status__c,
            'Order_Created',
            order.Customer__c,
            order.Total_Amount__c
        );
    }

    /**
     * @description Publishes an order cancelled event
     *
     * CONVENIENCE METHOD: Simplifies publishing when an order is cancelled.
     *
     * @param order The cancelled order
     * @param previousStatus The status before cancellation
     * @return Database.SaveResult
     */
    public static Database.SaveResult publishOrderCancelled(
        Order__c order,
        String previousStatus
    ) {
        return publishOrderStatusChange(
            order.Id,
            order.Name,
            previousStatus,
            'Cancelled',
            'Order_Cancelled',
            order.Customer__c,
            order.Total_Amount__c
        );
    }

    /**
     * @description Publishes an order completed event
     *
     * CONVENIENCE METHOD: Simplifies publishing when an order is completed.
     *
     * @param order The completed order
     * @param previousStatus The status before completion
     * @return Database.SaveResult
     */
    public static Database.SaveResult publishOrderCompleted(
        Order__c order,
        String previousStatus
    ) {
        return publishOrderStatusChange(
            order.Id,
            order.Name,
            previousStatus,
            'Completed',
            'Order_Completed',
            order.Customer__c,
            order.Total_Amount__c
        );
    }

    /**
     * @description Handles event publish failures by logging errors
     *
     * LEARNING POINT: Platform Event publish failures should be logged for
     * monitoring and debugging. Failures can occur due to:
     * - Governor limits exceeded (max 150 events per transaction)
     * - System maintenance
     * - Invalid field values
     *
     * IMPORTANT: Event publish failures do NOT cause DML operations to rollback.
     * The order will still be saved even if the event fails to publish.
     *
     * @param result The failed SaveResult
     * @param context Description of where the failure occurred
     * @param orderId The order ID associated with the event
     */
    private static void handlePublishFailure(
        Database.SaveResult result,
        String context,
        Id orderId
    ) {
        // Build error message from all errors
        String errorMessage = 'Failed to publish Platform Event: ' + context;
        for (Database.Error error : result.getErrors()) {
            errorMessage += '\n- ' + error.getMessage() +
                           ' (Status Code: ' + error.getStatusCode() + ')';
        }

        // Log the error for monitoring
        // LEARNING POINT: Use ErrorLogger to track event publish failures.
        // This helps diagnose integration issues and monitor event delivery.
        System.debug(LoggingLevel.ERROR, errorMessage + ' | Order ID: ' + orderId);

        // Create error log record for monitoring dashboards
        try {
            ErrorLogger.logError(
                'OrderEventPublisher',
                'publishEvent',
                new EventPublishException(errorMessage)
            );
        } catch (Exception e) {
            // If error logging fails, at least we have the System.debug above
            System.debug(LoggingLevel.ERROR,
                'Failed to log event publish error: ' + e.getMessage());
        }
    }

    /**
     * @description Custom exception for event publishing failures
     *
     * LEARNING POINT: Custom exceptions help categorize errors and make
     * debugging easier. They can be caught specifically in error handling code.
     */
    public class EventPublishException extends Exception {}

    // ========== HELPER METHODS FOR TESTING ==========

    /**
     * @description Returns the count of events published in the current transaction
     *
     * LEARNING POINT: Use Limits class to monitor governor limits.
     * Platform Events have a limit of 150 publishes per transaction.
     *
     * @return Number of Platform Events published so far
     */
    public static Integer getPublishCount() {
        return Limits.getPublishImmediateDML();
    }

    /**
     * @description Returns the limit of Platform Events that can be published
     *
     * @return Maximum number of Platform Events allowed per transaction (150)
     */
    public static Integer getPublishLimit() {
        return Limits.getLimitPublishImmediateDML();
    }

    /**
     * @description Checks if we're approaching the event publish limit
     *
     * LEARNING POINT: Always check governor limits before bulk operations.
     * If you're near the limit, consider batching operations.
     *
     * @return True if we've used more than 80% of the publish limit
     */
    public static Boolean isApproachingPublishLimit() {
        Decimal percentUsed = (Decimal)getPublishCount() / getPublishLimit();
        return percentUsed > 0.8; // More than 80% used
    }
}
