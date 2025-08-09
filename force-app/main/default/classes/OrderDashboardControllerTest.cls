/**
 * OrderDashboardControllerTest - Test Class for Order Dashboard Controller
 * 
 * Educational Purpose: Demonstrates comprehensive Apex testing patterns for LWC controllers
 * This test class showcases enterprise-level testing practices:
 * - Complete method coverage with positive/negative scenarios
 * - Data setup patterns for complex relationships
 * - Exception handling validation
 * - Performance testing considerations
 * - Mock data generation for UI testing
 * 
 * Key Learning Concepts:
 * - @TestSetup for efficient test data creation
 * - Test.startTest()/Test.stopTest() for governor limit testing
 * - System.assert patterns for validation
 * - Exception testing with try/catch blocks
 * - Data isolation and cleanup
 * - Bulk testing patterns
 * 
 * Part of: TechSolutionApp Phase 4.1 - Interactive Learning Components
 * Author: TechSolutionApp Educational Platform
 * Created: August 2024
 */
@isTest
public class OrderDashboardControllerTest {
    
    /**
     * Test data setup method
     * Educational Value: Demonstrates efficient test data creation patterns
     */
    @TestSetup
    static void setupTestData() {
        // Educational Note: Create test devices with various stock levels
        List<Device__c> testDevices = new List<Device__c>();
        
        // Device 1: In Stock
        testDevices.add(new Device__c(
            Name = 'Test Laptop Pro',
            Price__c = 1299.99,
            Stock_Quantity__c = 50,
            Minimum_Stock_Level__c = 10,
            Reorder_Point__c = 15,
            Stock_Status__c = 'In Stock',
            Last_Restocked__c = Date.today().addDays(-5)
        ));
        
        // Device 2: Low Stock
        testDevices.add(new Device__c(
            Name = 'Test Tablet Ultra',
            Price__c = 899.99,
            Stock_Quantity__c = 8,
            Minimum_Stock_Level__c = 10,
            Reorder_Point__c = 15,
            Stock_Status__c = 'Low Stock',
            Last_Restocked__c = Date.today().addDays(-10)
        ));
        
        // Device 3: Out of Stock
        testDevices.add(new Device__c(
            Name = 'Test Phone Max',
            Price__c = 1099.99,
            Stock_Quantity__c = 0,
            Minimum_Stock_Level__c = 5,
            Reorder_Point__c = 10,
            Stock_Status__c = 'Out of Stock',
            Last_Restocked__c = Date.today().addDays(-20)
        ));
        
        insert testDevices;
        
        // Educational Note: Create test orders with various statuses and dates
        List<Device_Order__c> testOrders = new List<Device_Order__c>();
        
        for (Integer i = 0; i < 15; i++) {
            Device__c device = testDevices[Math.mod(i, testDevices.size())];
            testOrders.add(new Device_Order__c(
                Device__c = device.Id,
                Quantity__c = Math.mod(i, 5) + 1,
                Status__c = getTestStatus(i),
                Order_Date__c = Date.today().addDays(-Math.mod(i, 30))
            ));
        }
        
        insert testOrders;
    }
    
    /**
     * Helper method to generate test order statuses
     * Educational Value: Demonstrates test data variation patterns
     */
    private static String getTestStatus(Integer index) {
        List<String> statuses = new List<String>{'Draft', 'Confirmed', 'Shipped', 'Delivered'};
        return statuses[Math.mod(index, statuses.size())];
    }
    
    /**
     * Test getRecentOrders method - Positive scenario
     * Educational Value: Demonstrates successful data retrieval testing
     */
    @isTest
    static void testGetRecentOrdersSuccess() {
        Test.startTest();
        
        // Educational Note: Test with various limit values
        List<OrderDashboardController.OrderData> orders5 = OrderDashboardController.getRecentOrders(5);
        List<OrderDashboardController.OrderData> orders10 = OrderDashboardController.getRecentOrders(10);
        List<OrderDashboardController.OrderData> orders20 = OrderDashboardController.getRecentOrders(20);
        
        Test.stopTest();
        
        // Educational Note: Validate returned data structure and limits
        System.assertEquals(5, orders5.size(), 'Should return exactly 5 orders');
        System.assertEquals(10, orders10.size(), 'Should return exactly 10 orders');
        System.assertEquals(15, orders20.size(), 'Should return all 15 test orders');
        
        // Educational Note: Validate data completeness
        OrderDashboardController.OrderData firstOrder = orders5[0];
        System.assertNotEquals(null, firstOrder.id, 'Order ID should not be null');
        System.assertNotEquals(null, firstOrder.deviceName, 'Device name should not be null');
        System.assertNotEquals(null, firstOrder.confirmationNumber, 'Confirmation number should not be null');
        System.assert(firstOrder.quantity > 0, 'Quantity should be positive');
        System.assert(firstOrder.totalPrice > 0, 'Total price should be positive');
    }
    
    /**
     * Test getStockSummary method - Positive scenario
     * Educational Value: Demonstrates aggregate data testing
     */
    @isTest
    static void testGetStockSummarySuccess() {
        Test.startTest();
        
        OrderDashboardController.StockSummary summary = OrderDashboardController.getStockSummary();
        
        Test.stopTest();
        
        // Educational Note: Validate aggregate calculations
        System.assertEquals(3, summary.totalDevices, 'Should have 3 total devices');
        System.assertEquals(1, summary.inStock, 'Should have 1 device in stock');
        System.assertEquals(1, summary.lowStock, 'Should have 1 device with low stock');
        System.assertEquals(1, summary.outOfStock, 'Should have 1 device out of stock');
        
        // Educational Note: Validate data consistency
        Integer calculatedTotal = summary.inStock + summary.lowStock + summary.outOfStock;
        System.assertEquals(summary.totalDevices, calculatedTotal, 'Total should equal sum of categories');
    }
    
    /**
     * Test getOrderTrends method - Positive scenario
     * Educational Value: Demonstrates time-based data analysis testing
     */
    @isTest
    static void testGetOrderTrendsSuccess() {
        Test.startTest();
        
        // Educational Note: Test different time ranges
        List<OrderDashboardController.OrderTrend> trends7 = OrderDashboardController.getOrderTrends(7);
        List<OrderDashboardController.OrderTrend> trends30 = OrderDashboardController.getOrderTrends(30);
        
        Test.stopTest();
        
        // Educational Note: Validate trend data structure
        System.assert(trends7.size() <= 7, 'Should not exceed 7 days of trends');
        System.assert(trends30.size() <= 30, 'Should not exceed 30 days of trends');
        System.assert(trends30.size() >= trends7.size(), '30-day trends should include 7-day data');
        
        // Educational Note: Validate trend data completeness
        if (!trends30.isEmpty()) {
            OrderDashboardController.OrderTrend firstTrend = trends30[0];
            System.assertNotEquals(null, firstTrend.orderDate, 'Order date should not be null');
            System.assert(firstTrend.orderCount >= 0, 'Order count should be non-negative');
            System.assert(firstTrend.totalRevenue >= 0, 'Total revenue should be non-negative');
        }
    }
    
    /**
     * Test createOrder method - Positive scenario
     * Educational Value: Demonstrates DML operation testing
     */
    @isTest
    static void testCreateOrderSuccess() {
        // Educational Note: Get test device for order creation
        Device__c testDevice = [SELECT Id FROM Device__c WHERE Stock_Quantity__c > 0 LIMIT 1];
        
        Test.startTest();
        
        String confirmationNumber = OrderDashboardController.createOrder(testDevice.Id, 2);
        
        Test.stopTest();
        
        // Educational Note: Validate order creation
        System.assertNotEquals(null, confirmationNumber, 'Confirmation number should not be null');
        System.assert(confirmationNumber.startsWith('ORD-'), 'Confirmation should start with ORD-');
        
        // Educational Note: Verify order was actually created
        List<Device_Order__c> createdOrders = [
            SELECT Id, Confirmation_Number__c, Quantity__c, Device__c 
            FROM Device_Order__c 
            WHERE Confirmation_Number__c = :confirmationNumber
        ];
        System.assertEquals(1, createdOrders.size(), 'Should create exactly one order');
        System.assertEquals(2, createdOrders[0].Quantity__c, 'Should have correct quantity');
        System.assertEquals(testDevice.Id, createdOrders[0].Device__c, 'Should have correct device');
    }
    
    /**
     * Test createOrder method - Negative scenarios
     * Educational Value: Demonstrates exception handling testing
     */
    @isTest
    static void testCreateOrderFailure() {
        Test.startTest();
        
        // Educational Note: Test null device ID
        try {
            OrderDashboardController.createOrder(null, 1);
            System.assert(false, 'Should throw exception for null device ID');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Invalid order parameters'), 'Should have appropriate error message');
        }
        
        // Educational Note: Test zero quantity
        Device__c testDevice = [SELECT Id FROM Device__c LIMIT 1];
        try {
            OrderDashboardController.createOrder(testDevice.Id, 0);
            System.assert(false, 'Should throw exception for zero quantity');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Invalid order parameters'), 'Should have appropriate error message');
        }
        
        // Educational Note: Test negative quantity
        try {
            OrderDashboardController.createOrder(testDevice.Id, -1);
            System.assert(false, 'Should throw exception for negative quantity');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Invalid order parameters'), 'Should have appropriate error message');
        }
        
        Test.stopTest();
    }
    
    /**
     * Test getAvailableDevices method - Positive scenario
     * Educational Value: Demonstrates filtered data retrieval testing
     */
    @isTest
    static void testGetAvailableDevicesSuccess() {
        Test.startTest();
        
        List<OrderDashboardController.DeviceOption> devices = OrderDashboardController.getAvailableDevices();
        
        Test.stopTest();
        
        // Educational Note: Validate filtered results (only devices with stock > 0)
        System.assertEquals(2, devices.size(), 'Should return only devices with stock > 0');
        
        // Educational Note: Validate device data structure
        for (OrderDashboardController.DeviceOption device : devices) {
            System.assertNotEquals(null, device.id, 'Device ID should not be null');
            System.assertNotEquals(null, device.name, 'Device name should not be null');
            System.assert(device.price > 0, 'Device price should be positive');
            System.assert(device.stockQuantity > 0, 'Stock quantity should be positive');
            System.assertNotEquals(null, device.stockStatus, 'Stock status should not be null');
        }
    }
    
    /**
     * Test bulk data operations
     * Educational Value: Demonstrates performance and governor limit testing
     */
    @isTest
    static void testBulkOperations() {
        Test.startTest();
        
        // Educational Note: Test with maximum reasonable limits
        List<OrderDashboardController.OrderData> bulkOrders = OrderDashboardController.getRecentOrders(50);
        List<OrderDashboardController.OrderTrend> bulkTrends = OrderDashboardController.getOrderTrends(90);
        
        Test.stopTest();
        
        // Educational Note: Validate bulk operations don't exceed limits
        System.assert(bulkOrders.size() <= 50, 'Bulk orders should respect limit');
        System.assert(bulkTrends.size() <= 90, 'Bulk trends should respect limit');
        
        // Educational Note: Verify no governor limit exceptions occurred
        System.assertEquals(15, bulkOrders.size(), 'Should return all available test orders');
    }
    
    /**
     * Test wrapper class data integrity
     * Educational Value: Demonstrates data structure validation
     */
    @isTest
    static void testWrapperClassIntegrity() {
        Test.startTest();
        
        // Educational Note: Test all wrapper classes can be instantiated
        OrderDashboardController.OrderData orderData = new OrderDashboardController.OrderData();
        OrderDashboardController.StockSummary stockSummary = new OrderDashboardController.StockSummary();
        OrderDashboardController.OrderTrend orderTrend = new OrderDashboardController.OrderTrend();
        OrderDashboardController.DeviceOption deviceOption = new OrderDashboardController.DeviceOption();
        
        Test.stopTest();
        
        // Educational Note: Validate wrapper classes are properly initialized
        System.assertNotEquals(null, orderData, 'OrderData should be instantiable');
        System.assertNotEquals(null, stockSummary, 'StockSummary should be instantiable');
        System.assertNotEquals(null, orderTrend, 'OrderTrend should be instantiable');
        System.assertNotEquals(null, deviceOption, 'DeviceOption should be instantiable');
    }
}
