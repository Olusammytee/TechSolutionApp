/**
 * OrderDashboardControllerSimple - Simplified Apex Controller for Order Dashboard LWC
 * 
 * Educational Purpose: Demonstrates basic Lightning Web Component backend integration
 * This simplified controller provides essential data for the interactive order dashboard
 * 
 * Part of: TechSolutionApp Phase 4.1 - Interactive Learning Components
 * Author: TechSolutionApp Educational Platform
 * Created: August 2024
 */
public with sharing class OrderDashboardControllerSimple {
    
    /**
     * Get recent orders - simplified version
     */
    @AuraEnabled(cacheable=true)
    public static List<OrderData> getRecentOrders(Integer limitCount) {
        try {
            List<Device_Order__c> orders = [
                SELECT Id, Name, Device__r.Name, Quantity__c, Total_Price__c, 
                       Status__c, Order_Date__c, Confirmation_Number__c
                FROM Device_Order__c 
                ORDER BY CreatedDate DESC 
                LIMIT :limitCount
            ];
            
            List<OrderData> orderDataList = new List<OrderData>();
            for (Device_Order__c order : orders) {
                OrderData orderData = new OrderData();
                orderData.id = order.Id;
                orderData.name = order.Name;
                orderData.deviceName = order.Device__r.Name;
                orderData.quantity = order.Quantity__c;
                orderData.totalPrice = order.Total_Price__c;
                orderData.status = order.Status__c;
                orderData.orderDate = order.Order_Date__c;
                orderData.confirmationNumber = order.Confirmation_Number__c;
                orderDataList.add(orderData);
            }
            
            return orderDataList;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving orders: ' + e.getMessage());
        }
    }
    
    /**
     * Get stock summary - simplified version
     */
    @AuraEnabled(cacheable=true)
    public static StockSummary getStockSummary() {
        try {
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
     * Create a new order - simplified version
     */
    @AuraEnabled
    public static String createOrder(Id deviceId, Decimal quantity) {
        try {
            if (deviceId == null || quantity == null || quantity <= 0) {
                throw new AuraHandledException('Invalid order parameters');
            }
            
            Device_Order__c newOrder = new Device_Order__c(
                Device__c = deviceId,
                Quantity__c = quantity,
                Status__c = 'Draft'
            );
            
            insert newOrder;
            
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
     * Get available devices - simplified version
     */
    @AuraEnabled(cacheable=true)
    public static List<DeviceOption> getAvailableDevices() {
        try {
            List<Device__c> devices = [
                SELECT Id, Name, Price__c, Stock_Quantity__c
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
                deviceOptions.add(option);
            }
            
            return deviceOptions;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving devices: ' + e.getMessage());
        }
    }
    
    // Wrapper classes
    public class OrderData {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String deviceName { get; set; }
        @AuraEnabled public Decimal quantity { get; set; }
        @AuraEnabled public Decimal totalPrice { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public Date orderDate { get; set; }
        @AuraEnabled public String confirmationNumber { get; set; }
    }
    
    public class StockSummary {
        @AuraEnabled public Integer totalDevices { get; set; }
        @AuraEnabled public Integer inStock { get; set; }
        @AuraEnabled public Integer lowStock { get; set; }
        @AuraEnabled public Integer outOfStock { get; set; }
    }
    
    public class DeviceOption {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public Decimal price { get; set; }
        @AuraEnabled public Decimal stockQuantity { get; set; }
    }
}
