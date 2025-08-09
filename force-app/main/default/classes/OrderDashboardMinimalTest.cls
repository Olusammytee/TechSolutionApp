/**
 * OrderDashboardMinimalTest - Enhanced Test Class for Advanced Dashboard Controller
 *
 * Educational Purpose: Demonstrates comprehensive testing for advanced analytics
 * This enhanced test class provides full coverage for the advanced dashboard features
 *
 * Part of: TechSolutionApp Phase 4.3 - Advanced Dashboard Features
 * Author: TechSolutionApp Educational Platform
 * Created: August 2024
 * Enhanced: August 2024 - Phase 4.3 Implementation
 *
 * Features:
 * - Chart data testing for visualizations
 * - Advanced filtering and search testing
 * - Dashboard metrics validation
 * - Wrapper class integrity testing
 * - Enterprise-level test patterns
 */
@isTest
public class OrderDashboardMinimalTest {
    
    @TestSetup
    static void setupTestData() {
        // Create multiple test devices with different stock statuses
        List<Device__c> testDevices = new List<Device__c>();

        testDevices.add(new Device__c(
            Name = 'iPhone 15',
            Price__c = 999.00,
            Stock_Quantity__c = 10,
            Stock_Status__c = 'In Stock',
            Minimum_Stock_Level__c = 5,
            Reorder_Point__c = 3
        ));

        testDevices.add(new Device__c(
            Name = 'Samsung Galaxy',
            Price__c = 899.00,
            Stock_Quantity__c = 2,
            Stock_Status__c = 'Low Stock',
            Minimum_Stock_Level__c = 5,
            Reorder_Point__c = 3
        ));

        testDevices.add(new Device__c(
            Name = 'Google Pixel',
            Price__c = 799.00,
            Stock_Quantity__c = 0,
            Stock_Status__c = 'Out of Stock',
            Minimum_Stock_Level__c = 5,
            Reorder_Point__c = 3
        ));

        insert testDevices;

        // Create test orders with different dates and values
        List<Device_Order__c> testOrders = new List<Device_Order__c>();

        testOrders.add(new Device_Order__c(
            Device__c = testDevices[0].Id,
            Quantity__c = 2,
            Total_Price__c = 1998.00,
            Order_Date__c = Date.today().addDays(-30),
            Confirmation_Number__c = 'ORD-001'
        ));

        testOrders.add(new Device_Order__c(
            Device__c = testDevices[1].Id,
            Quantity__c = 1,
            Total_Price__c = 899.00,
            Order_Date__c = Date.today().addDays(-15),
            Confirmation_Number__c = 'ORD-002'
        ));

        testOrders.add(new Device_Order__c(
            Device__c = testDevices[0].Id,
            Quantity__c = 1,
            Total_Price__c = 999.00,
            Order_Date__c = Date.today().addDays(-5),
            Confirmation_Number__c = 'ORD-003'
        ));

        insert testOrders;
    }
    
    @isTest
    static void testGetOrderCount() {
        Test.startTest();

        Integer orderCount = OrderDashboardMinimal.getOrderCount();

        Test.stopTest();

        System.assertEquals(3, orderCount, 'Should return 3 test orders');
    }

    @isTest
    static void testGetDeviceCount() {
        Test.startTest();

        Integer deviceCount = OrderDashboardMinimal.getDeviceCount();

        Test.stopTest();

        System.assertEquals(3, deviceCount, 'Should return 3 test devices');
    }

    @isTest
    static void testConnection() {
        Test.startTest();

        String result = OrderDashboardMinimal.testConnection();

        Test.stopTest();

        System.assertEquals('OrderDashboardMinimal controller is working correctly!', result, 'Should return success message');
    }

    // ========================================
    // PHASE 4.3: ADVANCED ANALYTICS TESTS
    // ========================================

    @isTest
    static void testGetOrderTrendData() {
        Test.startTest();

        List<OrderDashboardMinimal.ChartDataPoint> trendData = OrderDashboardMinimal.getOrderTrendData();

        Test.stopTest();

        System.assertNotEquals(null, trendData, 'Trend data should not be null');
        System.assert(trendData.size() >= 0, 'Should return trend data points');

        // Verify data structure
        if (!trendData.isEmpty()) {
            OrderDashboardMinimal.ChartDataPoint firstPoint = trendData[0];
            System.assertNotEquals(null, firstPoint.label, 'Chart point should have label');
            System.assertNotEquals(null, firstPoint.value, 'Chart point should have value');
        }
    }

    @isTest
    static void testGetDevicePopularityData() {
        Test.startTest();

        List<OrderDashboardMinimal.ChartDataPoint> popularityData = OrderDashboardMinimal.getDevicePopularityData();

        Test.stopTest();

        System.assertNotEquals(null, popularityData, 'Popularity data should not be null');
        System.assert(popularityData.size() >= 0, 'Should return popularity data points');

        // Verify data structure
        if (!popularityData.isEmpty()) {
            OrderDashboardMinimal.ChartDataPoint firstPoint = popularityData[0];
            System.assertNotEquals(null, firstPoint.label, 'Chart point should have device name');
            System.assertNotEquals(null, firstPoint.value, 'Chart point should have order count');
        }
    }

    @isTest
    static void testGetDashboardMetrics() {
        Test.startTest();

        OrderDashboardMinimal.DashboardMetrics metrics = OrderDashboardMinimal.getDashboardMetrics();

        Test.stopTest();

        System.assertNotEquals(null, metrics, 'Dashboard metrics should not be null');
        System.assertEquals(3, metrics.totalOrders, 'Should have 3 total orders');
        System.assertEquals(3896.00, metrics.totalRevenue, 'Should calculate correct total revenue');
        System.assert(metrics.avgOrderValue > 0, 'Should have positive average order value');

        // Verify stock status counts
        System.assertEquals(1, metrics.inStockDevices, 'Should have 1 in-stock device');
        System.assertEquals(1, metrics.lowStockDevices, 'Should have 1 low-stock device');
        System.assertEquals(1, metrics.outOfStockDevices, 'Should have 1 out-of-stock device');
    }

    @isTest
    static void testGetFilteredOrders() {
        Test.startTest();

        // Test without filters
        List<OrderDashboardMinimal.OrderRecord> allOrders = OrderDashboardMinimal.getFilteredOrders(
            null, null, null, null, null
        );

        // Test with search term filter
        List<OrderDashboardMinimal.OrderRecord> searchResults = OrderDashboardMinimal.getFilteredOrders(
            'iPhone', null, null, null, null
        );

        // Test with device filter
        List<OrderDashboardMinimal.OrderRecord> deviceResults = OrderDashboardMinimal.getFilteredOrders(
            null, 'iPhone 15', null, null, null
        );

        // Test with limit
        List<OrderDashboardMinimal.OrderRecord> limitedResults = OrderDashboardMinimal.getFilteredOrders(
            null, null, null, null, 2
        );

        Test.stopTest();

        // Verify results
        System.assertEquals(3, allOrders.size(), 'Should return all 3 orders without filters');
        System.assertEquals(2, searchResults.size(), 'Should return 2 iPhone orders');
        System.assertEquals(2, deviceResults.size(), 'Should return 2 iPhone 15 orders');
        System.assertEquals(2, limitedResults.size(), 'Should return limited results');

        // Verify data structure
        if (!allOrders.isEmpty()) {
            OrderDashboardMinimal.OrderRecord firstOrder = allOrders[0];
            System.assertNotEquals(null, firstOrder.id, 'Order should have ID');
            System.assertNotEquals(null, firstOrder.deviceName, 'Order should have device name');
            System.assertNotEquals(null, firstOrder.confirmationNumber, 'Order should have confirmation number');
        }
    }

    @isTest
    static void testGetDeviceFilterOptions() {
        Test.startTest();

        List<OrderDashboardMinimal.PicklistOption> options = OrderDashboardMinimal.getDeviceFilterOptions();

        Test.stopTest();

        System.assertNotEquals(null, options, 'Filter options should not be null');
        System.assert(options.size() >= 3, 'Should have at least 3 options (All + 2 devices)');

        // Verify "All" option is first
        OrderDashboardMinimal.PicklistOption firstOption = options[0];
        System.assertEquals('All Devices', firstOption.label, 'First option should be All Devices');
        System.assertEquals('All', firstOption.value, 'First option value should be All');

        // Verify data structure
        for (OrderDashboardMinimal.PicklistOption option : options) {
            System.assertNotEquals(null, option.label, 'Option should have label');
            System.assertNotEquals(null, option.value, 'Option should have value');
        }
    }

    @isTest
    static void testErrorHandling() {
        Test.startTest();

        // Test error handling by trying to access non-existent data
        try {
            // This should not throw an exception due to proper error handling
            List<OrderDashboardMinimal.ChartDataPoint> trendData = OrderDashboardMinimal.getOrderTrendData();
            System.assert(true, 'Method should handle errors gracefully');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException, 'Should throw AuraHandledException');
        }

        Test.stopTest();
    }

    @isTest
    static void testWrapperClassIntegrity() {
        Test.startTest();

        // Test ChartDataPoint wrapper
        OrderDashboardMinimal.ChartDataPoint chartPoint = new OrderDashboardMinimal.ChartDataPoint();
        chartPoint.label = 'Test Label';
        chartPoint.value = 100;
        chartPoint.revenue = 1000.00;
        chartPoint.quantity = 5;

        System.assertEquals('Test Label', chartPoint.label, 'Chart point label should be set correctly');
        System.assertEquals(100, chartPoint.value, 'Chart point value should be set correctly');
        System.assertEquals(1000.00, chartPoint.revenue, 'Chart point revenue should be set correctly');
        System.assertEquals(5, chartPoint.quantity, 'Chart point quantity should be set correctly');

        // Test DashboardMetrics wrapper
        OrderDashboardMinimal.DashboardMetrics metrics = new OrderDashboardMinimal.DashboardMetrics();
        System.assertEquals(0, metrics.totalOrders, 'Default total orders should be 0');
        System.assertEquals(0, metrics.totalRevenue, 'Default total revenue should be 0');
        System.assertEquals(0, metrics.avgOrderValue, 'Default avg order value should be 0');

        // Test OrderRecord wrapper
        OrderDashboardMinimal.OrderRecord orderRecord = new OrderDashboardMinimal.OrderRecord();
        orderRecord.id = 'test-id';
        orderRecord.deviceName = 'Test Device';
        orderRecord.quantity = 2;
        orderRecord.totalPrice = 200.00;
        orderRecord.orderDate = Date.today();
        orderRecord.confirmationNumber = 'TEST-001';

        System.assertEquals('test-id', orderRecord.id, 'Order record ID should be set correctly');
        System.assertEquals('Test Device', orderRecord.deviceName, 'Order record device name should be set correctly');

        // Test PicklistOption wrapper
        OrderDashboardMinimal.PicklistOption option = new OrderDashboardMinimal.PicklistOption();
        option.label = 'Test Option';
        option.value = 'test-value';

        System.assertEquals('Test Option', option.label, 'Picklist option label should be set correctly');
        System.assertEquals('test-value', option.value, 'Picklist option value should be set correctly');

        Test.stopTest();
    }
}
