/**
 * OrderService - Apex service layer for Order management and Lightning Web Component consumption
 * Provides cacheable methods optimized for dashboard analytics and order operations
 * Follows enterprise security patterns with proper FLS and CRUD enforcement
 */
public with sharing class OrderService {
    
    /**
     * Get comprehensive order summary for dashboard display
     * @param orderId The Order record ID
     * @return OrderSummaryWrapper with order details and line items
     */
    @AuraEnabled(cacheable=true)
    public static OrderSummaryWrapper getOrderSummary(Id orderId) {
        try {
            // Security check
            if (!Schema.sObjectType.Order__c.isAccessible()) {
                throw new AuraHandledException('Insufficient permissions to access Order records');
            }
            
            Order__c order = [
                SELECT Id, Name, Customer__c, Customer__r.Name, Customer__r.Customer_Type__c,
                       Order_Date__c, Order_Status__c, Priority__c, Expected_Delivery_Date__c,
                       Subtotal__c, Tax_Rate__c, Tax_Amount__c, Shipping_Cost__c,
                       Order_Discount_Percentage__c, Order_Discount_Amount__c, Total_Amount__c,
                       Line_Item_Count__c, Shipping_Address__c
                FROM Order__c
                WHERE Id = :orderId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            
            List<Order_Line_Item__c> lineItems = [
                SELECT Id, Name, Line_Number__c, Device__c, Device__r.Name, Device__r.Type__c,
                       Product_Name__c, Quantity__c, Unit_Price__c, Line_Discount_Percentage__c,
                       Line_Discount_Amount__c, Line_Total__c, Line_Profit_Margin__c,
                       Stock_Available__c
                FROM Order_Line_Item__c
                WHERE Order__c = :orderId
                WITH SECURITY_ENFORCED
                ORDER BY Line_Number__c
            ];
            
            return new OrderSummaryWrapper(order, lineItems);
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving order summary: ' + e.getMessage());
        }
    }
    
    /**
     * Get order analytics data for dashboard charts
     * @param startDate Start date for analytics period
     * @param endDate End date for analytics period
     * @return OrderAnalyticsWrapper with aggregated data
     */
    @AuraEnabled(cacheable=true)
    public static OrderAnalyticsWrapper getOrderAnalytics(Date startDate, Date endDate) {
        try {
            // Security check
            if (!Schema.sObjectType.Order__c.isAccessible()) {
                throw new AuraHandledException('Insufficient permissions to access Order records');
            }
            
            // Order status distribution
            List<AggregateResult> statusDistribution = [
                SELECT Order_Status__c status, COUNT(Id) orderCount, SUM(Total_Amount__c) totalRevenue
                FROM Order__c
                WHERE Order_Date__c >= :startDate AND Order_Date__c <= :endDate
                WITH SECURITY_ENFORCED
                GROUP BY Order_Status__c
                ORDER BY COUNT(Id) DESC
            ];
            
            // Priority distribution
            List<AggregateResult> priorityDistribution = [
                SELECT Priority__c priority, COUNT(Id) orderCount
                FROM Order__c
                WHERE Order_Date__c >= :startDate AND Order_Date__c <= :endDate
                WITH SECURITY_ENFORCED
                GROUP BY Priority__c
                ORDER BY COUNT(Id) DESC
            ];
            
            // Top customers by order value
            List<AggregateResult> topCustomers = [
                SELECT Customer__c customerId, Customer__r.Name customerName, 
                       COUNT(Id) orderCount, SUM(Total_Amount__c) totalValue
                FROM Order__c
                WHERE Order_Date__c >= :startDate AND Order_Date__c <= :endDate
                WITH SECURITY_ENFORCED
                GROUP BY Customer__c, Customer__r.Name
                ORDER BY SUM(Total_Amount__c) DESC
                LIMIT 10
            ];
            
            // Daily order trends
            List<AggregateResult> dailyTrends = [
                SELECT Order_Date__c orderDate, COUNT(Id) orderCount, SUM(Total_Amount__c) dailyRevenue
                FROM Order__c
                WHERE Order_Date__c >= :startDate AND Order_Date__c <= :endDate
                WITH SECURITY_ENFORCED
                GROUP BY Order_Date__c
                ORDER BY Order_Date__c
            ];
            
            return new OrderAnalyticsWrapper(statusDistribution, priorityDistribution, topCustomers, dailyTrends);
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving order analytics: ' + e.getMessage());
        }
    }
    
    /**
     * Get inventory impact analysis from order line items
     * @return InventoryImpactWrapper with stock analysis
     */
    @AuraEnabled(cacheable=true)
    public static InventoryImpactWrapper getInventoryImpact() {
        try {
            // Security check
            if (!Schema.sObjectType.Order_Line_Item__c.isAccessible()) {
                throw new AuraHandledException('Insufficient permissions to access Order Line Item records');
            }
            
            // Devices with pending order impact
            List<AggregateResult> pendingImpact = [
                SELECT Device__c deviceId, Device__r.Name deviceName, Device__r.Stock_Quantity__c currentStock,
                       SUM(Quantity__c) pendingQuantity
                FROM Order_Line_Item__c
                WHERE Order__r.Order_Status__c IN ('Pending', 'Confirmed', 'Processing')
                WITH SECURITY_ENFORCED
                GROUP BY Device__c, Device__r.Name, Device__r.Stock_Quantity__c
                HAVING SUM(Quantity__c) > 0
                ORDER BY SUM(Quantity__c) DESC
            ];
            
            return new InventoryImpactWrapper(pendingImpact);
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving inventory impact: ' + e.getMessage());
        }
    }
    
    /**
     * Create new order with line items
     * @param orderData OrderCreationWrapper with order and line item data
     * @return Id of created order
     */
    @AuraEnabled
    public static Id createOrder(OrderCreationWrapper orderData) {
        try {
            // Security checks
            if (!Schema.sObjectType.Order__c.isCreateable()) {
                throw new AuraHandledException('Insufficient permissions to create Order records');
            }
            
            if (!Schema.sObjectType.Order_Line_Item__c.isCreateable()) {
                throw new AuraHandledException('Insufficient permissions to create Order Line Item records');
            }
            
            // Create order header
            Order__c newOrder = new Order__c(
                Customer__c = orderData.customerId,
                Order_Date__c = orderData.orderDate != null ? orderData.orderDate : Date.today(),
                Order_Status__c = 'Pending',
                Priority__c = orderData.priority != null ? orderData.priority : 'Medium',
                Expected_Delivery_Date__c = orderData.expectedDeliveryDate,
                Shipping_Address__c = orderData.shippingAddress,
                Tax_Rate__c = orderData.taxRate != null ? orderData.taxRate : 8.25,
                Shipping_Cost__c = orderData.shippingCost != null ? orderData.shippingCost : 0,
                Order_Discount_Percentage__c = orderData.orderDiscountPercentage != null ? orderData.orderDiscountPercentage : 0
            );
            
            insert newOrder;
            
            // Create line items
            List<Order_Line_Item__c> lineItems = new List<Order_Line_Item__c>();
            Integer lineNumber = 1;
            
            for (LineItemData lineData : orderData.lineItems) {
                Order_Line_Item__c lineItem = new Order_Line_Item__c(
                    Order__c = newOrder.Id,
                    Device__c = lineData.deviceId,
                    Quantity__c = lineData.quantity,
                    Unit_Price__c = lineData.unitPrice,
                    Line_Number__c = lineNumber,
                    Line_Discount_Percentage__c = lineData.lineDiscountPercentage != null ? lineData.lineDiscountPercentage : 0
                );
                
                lineItems.add(lineItem);
                lineNumber++;
            }
            
            if (!lineItems.isEmpty()) {
                insert lineItems;
            }
            
            return newOrder.Id;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error creating order: ' + e.getMessage());
        }
    }
    
    // Wrapper Classes for LWC Data Transfer
    
    public class OrderSummaryWrapper {
        @AuraEnabled public Order__c order { get; set; }
        @AuraEnabled public List<Order_Line_Item__c> lineItems { get; set; }
        
        public OrderSummaryWrapper(Order__c order, List<Order_Line_Item__c> lineItems) {
            this.order = order;
            this.lineItems = lineItems;
        }
    }
    
    public class OrderAnalyticsWrapper {
        @AuraEnabled public List<AggregateResult> statusDistribution { get; set; }
        @AuraEnabled public List<AggregateResult> priorityDistribution { get; set; }
        @AuraEnabled public List<AggregateResult> topCustomers { get; set; }
        @AuraEnabled public List<AggregateResult> dailyTrends { get; set; }
        
        public OrderAnalyticsWrapper(List<AggregateResult> statusDist, List<AggregateResult> priorityDist, 
                                   List<AggregateResult> topCust, List<AggregateResult> dailyTrends) {
            this.statusDistribution = statusDist;
            this.priorityDistribution = priorityDist;
            this.topCustomers = topCust;
            this.dailyTrends = dailyTrends;
        }
    }
    
    public class InventoryImpactWrapper {
        @AuraEnabled public List<AggregateResult> pendingImpact { get; set; }
        
        public InventoryImpactWrapper(List<AggregateResult> pendingImpact) {
            this.pendingImpact = pendingImpact;
        }
    }
    
    public class OrderCreationWrapper {
        @AuraEnabled public Id customerId { get; set; }
        @AuraEnabled public Date orderDate { get; set; }
        @AuraEnabled public String priority { get; set; }
        @AuraEnabled public Date expectedDeliveryDate { get; set; }
        @AuraEnabled public String shippingAddress { get; set; }
        @AuraEnabled public Decimal taxRate { get; set; }
        @AuraEnabled public Decimal shippingCost { get; set; }
        @AuraEnabled public Decimal orderDiscountPercentage { get; set; }
        @AuraEnabled public List<LineItemData> lineItems { get; set; }
    }
    
    public class LineItemData {
        @AuraEnabled public Id deviceId { get; set; }
        @AuraEnabled public Decimal quantity { get; set; }
        @AuraEnabled public Decimal unitPrice { get; set; }
        @AuraEnabled public Decimal lineDiscountPercentage { get; set; }
    }
}
