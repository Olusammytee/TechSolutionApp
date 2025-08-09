/**
 * OrderDashboardMinimalTest - Test Class for Minimal Dashboard Controller
 * 
 * Educational Purpose: Demonstrates incremental testing strategy
 * This test class provides basic coverage for the minimal dashboard controller
 * 
 * Part of: TechSolutionApp Phase 4.2 - Deployment Optimization
 * Author: TechSolutionApp Educational Platform
 * Created: August 2024
 */
@isTest
public class OrderDashboardMinimalTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test device
        Device__c testDevice = new Device__c(
            Name = 'Test Device',
            Price__c = 100.00,
            Stock_Quantity__c = 5
        );
        insert testDevice;
        
        // Create test order
        Device_Order__c testOrder = new Device_Order__c(
            Device__c = testDevice.Id,
            Quantity__c = 1
        );
        insert testOrder;
    }
    
    @isTest
    static void testGetOrderCount() {
        Test.startTest();
        
        Integer orderCount = OrderDashboardMinimal.getOrderCount();
        
        Test.stopTest();
        
        System.assertEquals(1, orderCount, 'Should return 1 test order');
    }
    
    @isTest
    static void testGetDeviceCount() {
        Test.startTest();
        
        Integer deviceCount = OrderDashboardMinimal.getDeviceCount();
        
        Test.stopTest();
        
        System.assertEquals(1, deviceCount, 'Should return 1 test device');
    }
    
    @isTest
    static void testConnection() {
        Test.startTest();
        
        String result = OrderDashboardMinimal.testConnection();
        
        Test.stopTest();
        
        System.assertEquals('OrderDashboardMinimal controller is working correctly!', result, 'Should return success message');
    }
}
