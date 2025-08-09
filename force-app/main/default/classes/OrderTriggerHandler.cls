/**
 * OrderTriggerHandler - Handler Class for Advanced Order Processing
 * 
 * Educational Purpose: Demonstrates separation of concerns pattern in Apex development
 * This handler implements intelligent business logic for the order processing workflow:
 * - Automatic price calculations
 * - Real-time inventory management
 * - Order confirmation automation
 * - Audit trail creation
 * - Stock status management
 * 
 * Key Learning Concepts:
 * - Static methods for trigger handlers
 * - Bulk processing with collections
 * - SOQL queries with relationships
 * - DML operations with error handling
 * - Business logic encapsulation
 * - Governor limit considerations
 * 
 * Part of: TechSolutionApp Phase 4.1 - Interactive Learning Components
 * Author: TechSolutionApp Educational Platform
 * Created: August 2024
 */
public class OrderTriggerHandler {
    
    // Educational Note: Static methods allow calling without instantiation
    // This is the standard pattern for trigger handlers in Salesforce
    
    /**
     * Calculate order totals automatically
     * Educational Value: Demonstrates formula field automation via Apex
     * Business Logic: Total Price = Device Price × Quantity
     */
    public static void calculateOrderTotals(List<Device_Order__c> orders) {
        // Educational Note: Collect Device IDs for bulk SOQL query
        Set<Id> deviceIds = new Set<Id>();
        for (Device_Order__c order : orders) {
            if (order.Device__c != null) {
                deviceIds.add(order.Device__c);
            }
        }
        
        // Educational Note: Single SOQL query for all devices (bulk processing)
        Map<Id, Device__c> deviceMap = new Map<Id, Device__c>([
            SELECT Id, Price__c 
            FROM Device__c 
            WHERE Id IN :deviceIds
        ]);
        
        // Educational Note: Calculate totals for each order
        for (Device_Order__c order : orders) {
            if (order.Device__c != null && deviceMap.containsKey(order.Device__c)) {
                Device__c device = deviceMap.get(order.Device__c);
                if (device.Price__c != null && order.Quantity__c != null) {
                    order.Total_Price__c = device.Price__c * order.Quantity__c;
                }
            }
        }
    }
    
    /**
     * Validate stock availability before saving
     * Educational Value: Shows complex validation logic in triggers
     * Business Logic: Prevent orders that exceed available stock
     */
    public static void validateStockAvailability(List<Device_Order__c> orders) {
        // Educational Note: Collect Device IDs for stock checking
        Set<Id> deviceIds = new Set<Id>();
        for (Device_Order__c order : orders) {
            if (order.Device__c != null) {
                deviceIds.add(order.Device__c);
            }
        }
        
        // Educational Note: Query current stock levels
        Map<Id, Device__c> deviceMap = new Map<Id, Device__c>([
            SELECT Id, Stock_Quantity__c, Name
            FROM Device__c 
            WHERE Id IN :deviceIds
        ]);
        
        // Educational Note: Validate each order against available stock
        for (Device_Order__c order : orders) {
            if (order.Device__c != null && deviceMap.containsKey(order.Device__c)) {
                Device__c device = deviceMap.get(order.Device__c);
                if (order.Quantity__c > device.Stock_Quantity__c) {
                    order.addError('Insufficient stock for ' + device.Name + 
                                 '. Available: ' + device.Stock_Quantity__c + 
                                 ', Requested: ' + order.Quantity__c);
                }
            }
        }
    }
    
    /**
     * Generate unique confirmation numbers
     * Educational Value: Demonstrates unique identifier generation patterns
     * Business Logic: Create trackable order references
     */
    public static void generateConfirmationNumbers(List<Device_Order__c> orders) {
        // Educational Note: Generate unique confirmation numbers for new orders
        for (Device_Order__c order : orders) {
            if (String.isBlank(order.Confirmation_Number__c)) {
                // Educational Note: Format: ORD-YYYYMMDD-HHMMSS-XXX
                String timestamp = DateTime.now().format('yyyyMMdd-HHmmss');
                String randomSuffix = String.valueOf(Math.round(Math.random() * 999)).leftPad(3, '0');
                order.Confirmation_Number__c = 'ORD-' + timestamp + '-' + randomSuffix;
            }
        }
    }
    
    /**
     * Update device stock levels after order creation
     * Educational Value: Shows after trigger usage for related record updates
     * Business Logic: Reduce stock quantity by ordered amount
     */
    public static void updateDeviceStock(List<Device_Order__c> orders) {
        // Educational Note: Collect devices that need stock updates
        Map<Id, Decimal> stockReductions = new Map<Id, Decimal>();
        
        for (Device_Order__c order : orders) {
            if (order.Device__c != null && order.Quantity__c != null) {
                if (stockReductions.containsKey(order.Device__c)) {
                    stockReductions.put(order.Device__c, 
                        stockReductions.get(order.Device__c) + order.Quantity__c);
                } else {
                    stockReductions.put(order.Device__c, order.Quantity__c);
                }
            }
        }
        
        // Educational Note: Query and update device stock levels
        List<Device__c> devicesToUpdate = [
            SELECT Id, Stock_Quantity__c 
            FROM Device__c 
            WHERE Id IN :stockReductions.keySet()
        ];
        
        for (Device__c device : devicesToUpdate) {
            device.Stock_Quantity__c -= stockReductions.get(device.Id);
            // Educational Note: Ensure stock doesn't go negative
            if (device.Stock_Quantity__c < 0) {
                device.Stock_Quantity__c = 0;
            }
        }
        
        // Educational Note: Bulk DML operation for efficiency
        if (!devicesToUpdate.isEmpty()) {
            update devicesToUpdate;
        }
    }

    /**
     * Send order confirmation notifications
     * Educational Value: Demonstrates automated communication patterns
     * Business Logic: Notify customers of successful order placement
     */
    public static void sendOrderConfirmation(List<Device_Order__c> orders) {
        // Educational Note: In a real implementation, this would integrate with:
        // - Email services (EmailTemplate, Messaging.SingleEmailMessage)
        // - SMS services (third-party APIs)
        // - Push notifications (mobile apps)

        // For educational purposes, we'll create a simple audit log
        List<String> confirmationLogs = new List<String>();

        for (Device_Order__c order : orders) {
            if (String.isNotBlank(order.Confirmation_Number__c)) {
                String logMessage = 'Order confirmation sent for: ' +
                                  order.Confirmation_Number__c +
                                  ' at ' + DateTime.now().format();
                confirmationLogs.add(logMessage);

                // Educational Note: In production, you would:
                // 1. Query customer contact information
                // 2. Use EmailTemplate for branded communications
                // 3. Handle delivery failures gracefully
                // 4. Log communication attempts for audit
            }
        }

        // Educational Note: Log confirmations for tracking
        if (!confirmationLogs.isEmpty()) {
            System.debug('Order confirmations sent: ' + confirmationLogs);
        }
    }

    /**
     * Create audit trail for order changes
     * Educational Value: Shows audit pattern implementation
     * Business Logic: Track all order modifications for compliance
     */
    public static void createAuditTrail(List<Device_Order__c> orders) {
        // Educational Note: Audit trails are crucial for:
        // - Compliance requirements
        // - Business intelligence
        // - Troubleshooting issues
        // - Customer service support

        List<String> auditEntries = new List<String>();

        for (Device_Order__c order : orders) {
            String auditEntry = 'Order created: ' +
                              'ID=' + order.Id +
                              ', Confirmation=' + order.Confirmation_Number__c +
                              ', Total=' + order.Total_Price__c +
                              ', Timestamp=' + DateTime.now().format();
            auditEntries.add(auditEntry);
        }

        // Educational Note: In production, you would:
        // 1. Create custom audit objects
        // 2. Use Platform Events for real-time audit streaming
        // 3. Integrate with external audit systems
        // 4. Implement data retention policies

        if (!auditEntries.isEmpty()) {
            System.debug('Audit trail created: ' + auditEntries);
        }
    }

    /**
     * Update stock status based on current levels
     * Educational Value: Demonstrates automated status management
     * Business Logic: Set status based on stock vs minimum levels
     */
    public static void updateStockStatus(List<Device_Order__c> orders) {
        // Educational Note: Collect unique device IDs
        Set<Id> deviceIds = new Set<Id>();
        for (Device_Order__c order : orders) {
            if (order.Device__c != null) {
                deviceIds.add(order.Device__c);
            }
        }

        // Educational Note: Query devices with stock information
        List<Device__c> devicesToUpdate = [
            SELECT Id, Stock_Quantity__c, Minimum_Stock_Level__c,
                   Reorder_Point__c, Stock_Status__c
            FROM Device__c
            WHERE Id IN :deviceIds
        ];

        // Educational Note: Update stock status based on business rules
        for (Device__c device : devicesToUpdate) {
            String newStatus = calculateStockStatus(device);
            if (device.Stock_Status__c != newStatus) {
                device.Stock_Status__c = newStatus;
            }
        }

        // Educational Note: Bulk update for efficiency
        if (!devicesToUpdate.isEmpty()) {
            update devicesToUpdate;
        }
    }

    /**
     * Handle order status changes
     * Educational Value: Shows state transition management
     * Business Logic: React to order status modifications
     */
    public static void handleStatusChanges(List<Device_Order__c> newOrders,
                                         Map<Id, Device_Order__c> oldOrderMap) {
        // Educational Note: Compare old vs new values to detect changes
        List<Device_Order__c> statusChangedOrders = new List<Device_Order__c>();

        for (Device_Order__c newOrder : newOrders) {
            Device_Order__c oldOrder = oldOrderMap.get(newOrder.Id);
            if (oldOrder.Status__c != newOrder.Status__c) {
                statusChangedOrders.add(newOrder);
            }
        }

        // Educational Note: Process status-specific logic
        for (Device_Order__c order : statusChangedOrders) {
            System.debug('Order status changed: ' + order.Id +
                        ' from ' + oldOrderMap.get(order.Id).Status__c +
                        ' to ' + order.Status__c);

            // Educational Note: In production, you would handle:
            // - Cancelled orders (restore stock)
            // - Shipped orders (update tracking)
            // - Delivered orders (customer satisfaction surveys)
        }
    }

    /**
     * Adjust stock levels for order modifications
     * Educational Value: Shows complex business logic for updates
     * Business Logic: Handle quantity changes in existing orders
     */
    public static void adjustStockLevels(List<Device_Order__c> newOrders,
                                       Map<Id, Device_Order__c> oldOrderMap) {
        // Educational Note: Track stock adjustments needed
        Map<Id, Decimal> stockAdjustments = new Map<Id, Decimal>();

        for (Device_Order__c newOrder : newOrders) {
            Device_Order__c oldOrder = oldOrderMap.get(newOrder.Id);

            // Educational Note: Check if quantity changed
            if (oldOrder.Quantity__c != newOrder.Quantity__c) {
                Decimal adjustment = oldOrder.Quantity__c - newOrder.Quantity__c;

                if (stockAdjustments.containsKey(newOrder.Device__c)) {
                    stockAdjustments.put(newOrder.Device__c,
                        stockAdjustments.get(newOrder.Device__c) + adjustment);
                } else {
                    stockAdjustments.put(newOrder.Device__c, adjustment);
                }
            }
        }

        // Educational Note: Apply stock adjustments
        if (!stockAdjustments.isEmpty()) {
            List<Device__c> devicesToUpdate = [
                SELECT Id, Stock_Quantity__c
                FROM Device__c
                WHERE Id IN :stockAdjustments.keySet()
            ];

            for (Device__c device : devicesToUpdate) {
                device.Stock_Quantity__c += stockAdjustments.get(device.Id);
                // Educational Note: Ensure stock doesn't go negative
                if (device.Stock_Quantity__c < 0) {
                    device.Stock_Quantity__c = 0;
                }
            }

            if (!devicesToUpdate.isEmpty()) {
                update devicesToUpdate;
            }
        }
    }

    /**
     * Helper method to calculate stock status
     * Educational Value: Shows utility method patterns
     * Business Logic: Determine status based on stock levels
     */
    private static String calculateStockStatus(Device__c device) {
        if (device.Stock_Quantity__c == 0) {
            return 'Out of Stock';
        } else if (device.Stock_Quantity__c <= device.Minimum_Stock_Level__c) {
            return 'Low Stock';
        } else {
            return 'In Stock';
        }
    }
}
