/**
 * OrderDashboardController - Apex Controller for Order Dashboard LWC
 * 
 * Educational Purpose: Demonstrates Lightning Web Component backend integration
 * This controller provides data and methods for the interactive order dashboard:
 * - Real-time order data retrieval
 * - Stock level monitoring
 * - Order analytics and trends
 * - Integration with OrderTriggerHandler business logic
 * 
 * Key Learning Concepts:
 * - @AuraEnabled methods for LWC integration
 * - Cacheable vs non-cacheable data patterns
 * - SOQL optimization for dashboard performance
 * - Real-time data aggregation
 * - Error handling for UI components
 * 
 * Part of: TechSolutionApp Phase 4.1 - Interactive Learning Components
 * Author: TechSolutionApp Educational Platform
 * Created: August 2024
 */
public with sharing class OrderDashboardController {
    
    /**
     * Get recent orders with device and stock information
     * Educational Value: Demonstrates complex SOQL with relationships
     * Used by: Order list component in dashboard
     */
    @AuraEnabled(cacheable=true)
    public static List<OrderData> getRecentOrders(Integer limitCount) {
        try {
            // Educational Note: Complex SOQL with relationships and calculated fields
            List<Device_Order__c> orders = [
                SELECT Id, Name, Device__c, Device__r.Name, Device__r.Price__c, 
                       Device__r.Stock_Quantity__c, Device__r.Stock_Status__c,
                       Quantity__c, Total_Price__c, Status__c, Order_Date__c,
                       Confirmation_Number__c, CreatedDate, LastModifiedDate
                FROM Device_Order__c 
                ORDER BY CreatedDate DESC 
                LIMIT :limitCount
            ];
            
            // Educational Note: Transform Salesforce objects to LWC-friendly format
            List<OrderData> orderDataList = new List<OrderData>();
            for (Device_Order__c order : orders) {
                OrderData orderData = new OrderData();
                orderData.id = order.Id;
                orderData.name = order.Name;
                orderData.deviceName = order.Device__r.Name;
                orderData.devicePrice = order.Device__r.Price__c;
                orderData.quantity = order.Quantity__c;
                orderData.totalPrice = order.Total_Price__c;
                orderData.status = order.Status__c;
                orderData.orderDate = order.Order_Date__c;
                orderData.confirmationNumber = order.Confirmation_Number__c;
                orderData.stockQuantity = order.Device__r.Stock_Quantity__c;
                orderData.stockStatus = order.Device__r.Stock_Status__c;
                orderData.createdDate = order.CreatedDate;
                orderData.lastModifiedDate = order.LastModifiedDate;
                orderDataList.add(orderData);
            }
            
            return orderDataList;
            
        } catch (Exception e) {
            // Educational Note: Proper error handling for LWC
            throw new AuraHandledException('Error retrieving orders: ' + e.getMessage());
        }
    }
    
    /**
     * Get stock status summary for dashboard widgets
     * Educational Value: Demonstrates data aggregation patterns
     * Used by: Stock status widgets and charts
     */
    @AuraEnabled(cacheable=true)
    public static StockSummary getStockSummary() {
        try {
            // Educational Note: Aggregate queries for dashboard metrics
            List<AggregateResult> stockResults = [
                SELECT Stock_Status__c status, COUNT(Id) count
                FROM Device__c 
                GROUP BY Stock_Status__c
            ];
            
            StockSummary summary = new StockSummary();
            summary.totalDevices = 0;
            summary.inStock = 0;
            summary.lowStock = 0;
            summary.outOfStock = 0;
            
            for (AggregateResult result : stockResults) {
                String status = (String) result.get('status');
                Integer count = (Integer) result.get('count');
                summary.totalDevices += count;
                
                if (status == 'In Stock') {
                    summary.inStock = count;
                } else if (status == 'Low Stock') {
                    summary.lowStock = count;
                } else if (status == 'Out of Stock') {
                    summary.outOfStock = count;
                }
            }
            
            return summary;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving stock summary: ' + e.getMessage());
        }
    }
    
    /**
     * Get order trends for chart visualization
     * Educational Value: Demonstrates time-based data analysis
     * Used by: Order trends chart component
     */
    @AuraEnabled(cacheable=true)
    public static List<OrderTrend> getOrderTrends(Integer days) {
        try {
            Date startDate = Date.today().addDays(-days);
            
            // Educational Note: Date-based aggregation for trend analysis
            List<AggregateResult> trendResults = [
                SELECT DAY_ONLY(CreatedDate) orderDate, COUNT(Id) orderCount,
                       SUM(Total_Price__c) totalRevenue
                FROM Device_Order__c 
                WHERE CreatedDate >= :startDate
                GROUP BY DAY_ONLY(CreatedDate)
                ORDER BY DAY_ONLY(CreatedDate)
            ];
            
            List<OrderTrend> trends = new List<OrderTrend>();
            for (AggregateResult result : trendResults) {
                OrderTrend trend = new OrderTrend();
                trend.orderDate = (Date) result.get('orderDate');
                trend.orderCount = (Integer) result.get('orderCount');
                trend.totalRevenue = (Decimal) result.get('totalRevenue');
                trends.add(trend);
            }
            
            return trends;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving order trends: ' + e.getMessage());
        }
    }
    
    /**
     * Create a new order from the dashboard
     * Educational Value: Demonstrates LWC to Apex DML operations
     * Used by: Quick order creation component
     */
    @AuraEnabled
    public static String createOrder(Id deviceId, Decimal quantity) {
        try {
            // Educational Note: Validate input parameters
            if (deviceId == null || quantity == null || quantity <= 0) {
                throw new AuraHandledException('Invalid order parameters');
            }
            
            // Educational Note: Create order record (triggers will handle automation)
            Device_Order__c newOrder = new Device_Order__c(
                Device__c = deviceId,
                Quantity__c = quantity,
                Status__c = 'Draft'
            );
            
            insert newOrder;
            
            // Educational Note: Return confirmation number for UI feedback
            Device_Order__c insertedOrder = [
                SELECT Confirmation_Number__c 
                FROM Device_Order__c 
                WHERE Id = :newOrder.Id 
                LIMIT 1
            ];
            
            return insertedOrder.Confirmation_Number__c;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error creating order: ' + e.getMessage());
        }
    }
    
    /**
     * Get available devices for order creation
     * Educational Value: Demonstrates filtered data retrieval
     * Used by: Device selection component
     */
    @AuraEnabled(cacheable=true)
    public static List<DeviceOption> getAvailableDevices() {
        try {
            List<Device__c> devices = [
                SELECT Id, Name, Price__c, Stock_Quantity__c, Stock_Status__c
                FROM Device__c 
                WHERE Stock_Quantity__c > 0
                ORDER BY Name
            ];
            
            List<DeviceOption> deviceOptions = new List<DeviceOption>();
            for (Device__c device : devices) {
                DeviceOption option = new DeviceOption();
                option.id = device.Id;
                option.name = device.Name;
                option.price = device.Price__c;
                option.stockQuantity = device.Stock_Quantity__c;
                option.stockStatus = device.Stock_Status__c;
                deviceOptions.add(option);
            }
            
            return deviceOptions;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving devices: ' + e.getMessage());
        }
    }
    
    // Educational Note: Wrapper classes for LWC data transfer
    // These classes provide clean, structured data for the UI components
    
    public class OrderData {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String deviceName { get; set; }
        @AuraEnabled public Decimal devicePrice { get; set; }
        @AuraEnabled public Decimal quantity { get; set; }
        @AuraEnabled public Decimal totalPrice { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public Date orderDate { get; set; }
        @AuraEnabled public String confirmationNumber { get; set; }
        @AuraEnabled public Decimal stockQuantity { get; set; }
        @AuraEnabled public String stockStatus { get; set; }
        @AuraEnabled public DateTime createdDate { get; set; }
        @AuraEnabled public DateTime lastModifiedDate { get; set; }
    }
    
    public class StockSummary {
        @AuraEnabled public Integer totalDevices { get; set; }
        @AuraEnabled public Integer inStock { get; set; }
        @AuraEnabled public Integer lowStock { get; set; }
        @AuraEnabled public Integer outOfStock { get; set; }
    }
    
    public class OrderTrend {
        @AuraEnabled public Date orderDate { get; set; }
        @AuraEnabled public Integer orderCount { get; set; }
        @AuraEnabled public Decimal totalRevenue { get; set; }
    }
    
    public class DeviceOption {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public Decimal price { get; set; }
        @AuraEnabled public Decimal stockQuantity { get; set; }
        @AuraEnabled public String stockStatus { get; set; }
    }
}
