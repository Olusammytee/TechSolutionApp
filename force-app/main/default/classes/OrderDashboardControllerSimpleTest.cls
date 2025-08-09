/**
 * OrderDashboardControllerSimpleTest - Test Class for Simplified Order Dashboard Controller
 * 
 * Educational Purpose: Demonstrates basic Apex testing patterns for LWC controllers
 * This test class provides essential test coverage for the simplified dashboard controller
 * 
 * Part of: TechSolutionApp Phase 4.1 - Interactive Learning Components
 * Author: TechSolutionApp Educational Platform
 * Created: August 2024
 */
@isTest
public class OrderDashboardControllerSimpleTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test device
        Device__c testDevice = new Device__c(
            Name = 'Test Laptop',
            Price__c = 999.99,
            Stock_Quantity__c = 10,
            Stock_Status__c = 'In Stock'
        );
        insert testDevice;
        
        // Create test order
        Device_Order__c testOrder = new Device_Order__c(
            Device__c = testDevice.Id,
            Quantity__c = 2,
            Status__c = 'Draft'
        );
        insert testOrder;
    }
    
    @isTest
    static void testGetRecentOrdersSuccess() {
        Test.startTest();
        
        List<OrderDashboardControllerSimple.OrderData> orders = 
            OrderDashboardControllerSimple.getRecentOrders(10);
        
        Test.stopTest();
        
        System.assertEquals(1, orders.size(), 'Should return 1 test order');
        System.assertNotEquals(null, orders[0].id, 'Order ID should not be null');
    }
    
    @isTest
    static void testGetStockSummarySuccess() {
        Test.startTest();
        
        OrderDashboardControllerSimple.StockSummary summary = 
            OrderDashboardControllerSimple.getStockSummary();
        
        Test.stopTest();
        
        System.assertEquals(1, summary.totalDevices, 'Should have 1 total device');
        System.assertEquals(1, summary.inStock, 'Should have 1 device in stock');
    }
    
    @isTest
    static void testCreateOrderSuccess() {
        Device__c testDevice = [SELECT Id FROM Device__c LIMIT 1];
        
        Test.startTest();
        
        String confirmationNumber = OrderDashboardControllerSimple.createOrder(testDevice.Id, 1);
        
        Test.stopTest();
        
        System.assertNotEquals(null, confirmationNumber, 'Confirmation number should not be null');
    }
    
    @isTest
    static void testGetAvailableDevicesSuccess() {
        Test.startTest();
        
        List<OrderDashboardControllerSimple.DeviceOption> devices = 
            OrderDashboardControllerSimple.getAvailableDevices();
        
        Test.stopTest();
        
        System.assertEquals(1, devices.size(), 'Should return 1 available device');
    }
}
