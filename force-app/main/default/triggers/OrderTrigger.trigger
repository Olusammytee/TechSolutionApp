/**
 * OrderTrigger - Advanced Order Processing Workflow Trigger
 * 
 * Educational Purpose: Demonstrates event-driven programming patterns in Salesforce
 * This trigger implements the complete order lifecycle from the workflow diagram:
 * User Creates Order → Validation → Order Saved → Trigger Executes → 
 * Stock Calculation → Stock Update → Real-time UI Updates
 * 
 * Key Learning Concepts:
 * - Trigger contexts and execution order
 * - Separation of concerns with handler classes
 * - Bulk processing and governor limits
 * - Before vs After trigger logic
 * - Event-driven business process automation
 * 
 * Part of: TechSolutionApp Phase 4.1 - Interactive Learning Components
 * Author: TechSolutionApp Educational Platform
 * Created: August 2024
 */
trigger OrderTrigger on Device_Order__c (before insert, before update, after insert, after update) {
    
    // Educational Note: Using trigger handler pattern for separation of concerns
    // This approach makes code more maintainable, testable, and follows enterprise best practices
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            // Before Insert/Update: Calculate totals and validate data
            // Educational Value: Demonstrates data preparation before saving
            OrderTriggerHandler.calculateOrderTotals(Trigger.new);
            OrderTriggerHandler.validateStockAvailability(Trigger.new);
            OrderTriggerHandler.generateConfirmationNumbers(Trigger.new);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            // After Insert: Perform actions that require saved records with IDs
            // Educational Value: Shows when to use after triggers for related record updates
            OrderTriggerHandler.updateDeviceStock(Trigger.new);
            OrderTriggerHandler.sendOrderConfirmation(Trigger.new);
            OrderTriggerHandler.createAuditTrail(Trigger.new);
            OrderTriggerHandler.updateStockStatus(Trigger.new);
        }

        if (Trigger.isUpdate) {
            // After Update: Handle status changes and stock adjustments
            // Educational Value: Demonstrates handling record changes and state transitions
            OrderTriggerHandler.handleStatusChanges(Trigger.new, Trigger.oldMap);
            OrderTriggerHandler.adjustStockLevels(Trigger.new, Trigger.oldMap);
            OrderTriggerHandler.updateStockStatus(Trigger.new);
        }
    }
}
