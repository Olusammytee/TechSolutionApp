/**
 * @description Trigger on Order__c for publishing Platform Events
 *
 * This trigger implements event-driven architecture by publishing Platform
 * Events when orders are created or their status changes. This enables:
 * - Real-time dashboard updates
 * - External system notifications
 * - Decoupled integration patterns
 * - Audit trail and event logging
 *
 * LEARNING OBJECTIVES:
 * - Understand trigger contexts and when to publish events
 * - Learn separation of concerns with trigger handlers
 * - Master bulk event publishing
 * - Implement event-driven architecture
 *
 * @author TechSolutions Learning Team
 * @date 2025-11-04
 * @group Platform Events
 */
trigger Order__cTrigger on Order__c (after insert, after update) {

    // LEARNING POINT: We use "after" triggers for Platform Events because:
    // 1. Events should only be published if the DML succeeds
    // 2. We need the final field values (after all before triggers run)
    // 3. We need the record ID (only available in after context)

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            // Publish events for newly created orders
            // LEARNING POINT: On insert, Trigger.oldMap is null
            OrderEventPublisher.publishBulkOrderStatusChanges(
                Trigger.new,
                null // No old values on insert
            );
        }

        if (Trigger.isUpdate) {
            // Publish events for orders that changed status
            // LEARNING POINT: On update, compare new vs old values
            // to detect changes and only publish events when needed
            OrderEventPublisher.publishBulkOrderStatusChanges(
                Trigger.new,
                Trigger.oldMap
            );
        }
    }
}
