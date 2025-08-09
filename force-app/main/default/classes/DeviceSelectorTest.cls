/**
 * DeviceSelectorTest - Comprehensive test class for DeviceSelector
 * Ensures 85%+ code coverage and validates all selector methods
 * Tests enterprise patterns for performance and security
 */
@isTest
public class DeviceSelectorTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test supplier
        Supplier__c testSupplier = new Supplier__c(
            Name = 'Test Supplier',
            Company_Name__c = 'Test Supplier Inc',
            Contact_Person__c = 'Test Contact',
            Email__c = 'test@supplier.com',
            Phone__c = '+1-555-TEST',
            Country__c = 'United States',
            Supplier_Rating__c = 'Excellent',
            Active__c = true
        );
        insert testSupplier;
        
        // Create test devices with various stock levels
        List<Device__c> testDevices = new List<Device__c>();
        
        // In Stock device
        testDevices.add(new Device__c(
            Name = 'In Stock Device',
            Type__c = 'Computer',
            Stock_Quantity__c = 100,
            Price__c = 1000.00,
            Cost_Price__c = 700.00,
            Warranty_Period_Months__c = 12,
            Active__c = true,
            Supplier__c = testSupplier.Id,
            Minimum_Stock_Level__c = 10,
            Reorder_Point__c = 20,
            Stock_Status__c = 'In Stock'
        ));
        
        // Low Stock device
        testDevices.add(new Device__c(
            Name = 'Low Stock Device',
            Type__c = 'Software',
            Stock_Quantity__c = 5,
            Price__c = 500.00,
            Cost_Price__c = 300.00,
            Warranty_Period_Months__c = 12,
            Active__c = true,
            Supplier__c = testSupplier.Id,
            Minimum_Stock_Level__c = 10,
            Reorder_Point__c = 15,
            Stock_Status__c = 'Low Stock'
        ));
        
        // Out of Stock device
        testDevices.add(new Device__c(
            Name = 'Out of Stock Device',
            Type__c = 'Networking',
            Stock_Quantity__c = 0,
            Price__c = 750.00,
            Cost_Price__c = 500.00,
            Warranty_Period_Months__c = 24,
            Active__c = true,
            Supplier__c = testSupplier.Id,
            Minimum_Stock_Level__c = 5,
            Reorder_Point__c = 10,
            Stock_Status__c = 'Out of Stock'
        ));
        
        // Reorder Soon device
        testDevices.add(new Device__c(
            Name = 'Reorder Soon Device',
            Type__c = 'Mobile Device',
            Stock_Quantity__c = 12,
            Price__c = 800.00,
            Cost_Price__c = 600.00,
            Warranty_Period_Months__c = 12,
            Active__c = true,
            Supplier__c = testSupplier.Id,
            Minimum_Stock_Level__c = 5,
            Reorder_Point__c = 15,
            Stock_Status__c = 'Reorder Soon'
        ));
        
        // Inactive device
        testDevices.add(new Device__c(
            Name = 'Inactive Device',
            Type__c = 'Storage',
            Stock_Quantity__c = 50,
            Price__c = 600.00,
            Cost_Price__c = 400.00,
            Warranty_Period_Months__c = 36,
            Active__c = false,
            Supplier__c = testSupplier.Id,
            Minimum_Stock_Level__c = 10,
            Reorder_Point__c = 20,
            Stock_Status__c = 'In Stock'
        ));
        
        insert testDevices;
    }
    
    @isTest
    static void testSelectById() {
        List<Device__c> devices = [SELECT Id FROM Device__c LIMIT 3];
        Set<Id> deviceIds = new Set<Id>();
        for (Device__c device : devices) {
            deviceIds.add(device.Id);
        }
        
        Test.startTest();
        List<Device__c> result = DeviceSelector.selectById(deviceIds);
        Test.stopTest();
        
        System.assertEquals(3, result.size(), 'Should return 3 devices');
        System.assertNotEquals(null, result[0].Name, 'Device name should be populated');
        System.assertNotEquals(null, result[0].Type__c, 'Device type should be populated');
    }
    
    @isTest
    static void testSelectByIdEmpty() {
        Test.startTest();
        List<Device__c> result = DeviceSelector.selectById(new Set<Id>());
        Test.stopTest();
        
        System.assertEquals(0, result.size(), 'Should return empty list for empty input');
    }
    
    @isTest
    static void testSelectInventoryById() {
        List<Device__c> devices = [SELECT Id FROM Device__c WHERE Active__c = true LIMIT 2];
        Set<Id> deviceIds = new Set<Id>();
        for (Device__c device : devices) {
            deviceIds.add(device.Id);
        }
        
        Test.startTest();
        List<Device__c> result = DeviceSelector.selectInventoryById(deviceIds);
        Test.stopTest();
        
        System.assertEquals(2, result.size(), 'Should return 2 devices');
        System.assertNotEquals(null, result[0].Stock_Quantity__c, 'Stock quantity should be populated');
        System.assertNotEquals(null, result[0].Stock_Status__c, 'Stock status should be populated');
    }
    
    @isTest
    static void testSelectFinancialById() {
        List<Device__c> devices = [SELECT Id FROM Device__c WHERE Active__c = true LIMIT 2];
        Set<Id> deviceIds = new Set<Id>();
        for (Device__c device : devices) {
            deviceIds.add(device.Id);
        }
        
        Test.startTest();
        List<Device__c> result = DeviceSelector.selectFinancialById(deviceIds);
        Test.stopTest();
        
        System.assertEquals(2, result.size(), 'Should return 2 devices');
        System.assertNotEquals(null, result[0].Price__c, 'Price should be populated');
        System.assertNotEquals(null, result[0].Cost_Price__c, 'Cost price should be populated');
    }
    
    @isTest
    static void testSelectLowStock() {
        Test.startTest();
        List<Device__c> result = DeviceSelector.selectLowStock();
        Test.stopTest();
        
        // Should return devices with 'Low Stock' and 'Out of Stock' status
        System.assert(result.size() >= 2, 'Should return at least 2 low/out of stock devices');
        
        for (Device__c device : result) {
            System.assert(
                device.Stock_Status__c == 'Low Stock' || device.Stock_Status__c == 'Out of Stock',
                'Should only return low stock or out of stock devices'
            );
            System.assertEquals(true, device.Active__c, 'Should only return active devices');
        }
    }
    
    @isTest
    static void testSelectBelowReorderPoint() {
        Test.startTest();
        List<Device__c> result = DeviceSelector.selectBelowReorderPoint();
        Test.stopTest();
        
        System.assert(result.size() >= 1, 'Should return at least 1 device below reorder point');
        
        for (Device__c device : result) {
            System.assert(
                device.Stock_Quantity__c <= device.Reorder_Point__c,
                'Stock quantity should be at or below reorder point'
            );
            System.assertEquals(true, device.Active__c, 'Should only return active devices');
        }
    }
    
    @isTest
    static void testSelectForAnalytics() {
        Date startDate = Date.today().addDays(-30);
        Date endDate = Date.today();
        
        Test.startTest();
        List<Device__c> result = DeviceSelector.selectForAnalytics(startDate, endDate);
        Test.stopTest();
        
        System.assert(result.size() >= 4, 'Should return active devices');
        
        for (Device__c device : result) {
            System.assertEquals(true, device.Active__c, 'Should only return active devices');
            System.assertNotEquals(null, device.Name, 'Device name should be populated');
            System.assertNotEquals(null, device.Type__c, 'Device type should be populated');
        }
    }
    
    @isTest
    static void testSelectByType() {
        Set<String> deviceTypes = new Set<String>{'Computer', 'Software'};
        
        Test.startTest();
        List<Device__c> result = DeviceSelector.selectByType(deviceTypes);
        Test.stopTest();
        
        System.assert(result.size() >= 2, 'Should return devices of specified types');
        
        for (Device__c device : result) {
            System.assert(
                deviceTypes.contains(device.Type__c),
                'Should only return devices of specified types'
            );
            System.assertEquals(true, device.Active__c, 'Should only return active devices');
        }
    }
    
    @isTest
    static void testSelectByTypeEmpty() {
        Test.startTest();
        List<Device__c> result = DeviceSelector.selectByType(new Set<String>());
        Test.stopTest();
        
        System.assertEquals(0, result.size(), 'Should return empty list for empty input');
    }
    
    @isTest
    static void testSelectWithPendingOrders() {
        Test.startTest();
        List<Device__c> result = DeviceSelector.selectWithPendingOrders();
        Test.stopTest();
        
        // Should return active devices (may not have pending orders in test data)
        for (Device__c device : result) {
            System.assertEquals(true, device.Active__c, 'Should only return active devices');
        }
    }
    
    @isTest
    static void testSelectForDashboard() {
        Test.startTest();
        List<Device__c> result = DeviceSelector.selectForDashboard(3);
        Test.stopTest();
        
        System.assert(result.size() <= 3, 'Should respect limit parameter');
        System.assert(result.size() >= 1, 'Should return at least 1 active device');
        
        for (Device__c device : result) {
            System.assertEquals(true, device.Active__c, 'Should only return active devices');
        }
    }
    
    @isTest
    static void testSelectForDashboardDefaultLimit() {
        Test.startTest();
        List<Device__c> result = DeviceSelector.selectForDashboard(null);
        Test.stopTest();
        
        System.assert(result.size() <= 50, 'Should use default limit of 50');
    }
    
    @isTest
    static void testGetDeviceCountByStatus() {
        Test.startTest();
        Map<String, Integer> result = DeviceSelector.getDeviceCountByStatus();
        Test.stopTest();
        
        System.assert(result.size() > 0, 'Should return status counts');
        
        Integer totalCount = 0;
        for (String status : result.keySet()) {
            Integer count = result.get(status);
            System.assert(count > 0, 'Count should be positive for status: ' + status);
            totalCount += count;
        }
        
        // Should match the number of active devices we created
        System.assertEquals(4, totalCount, 'Total count should match active devices');
    }
}
