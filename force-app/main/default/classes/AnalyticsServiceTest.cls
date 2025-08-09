/**
 * AnalyticsServiceTest - Comprehensive test class for AnalyticsService
 * Ensures 85%+ code coverage and validates all cacheable service methods
 * Tests enterprise patterns for performance and security
 */
@isTest
public class AnalyticsServiceTest {
    
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
        
        // Create test customer
        Customer__c testCustomer = new Customer__c(
            Name = 'Test Customer',
            Email__c = 'test@customer.com',
            Phone__c = '+1-555-CUSTOMER',
            Address__c = '123 Test Street, Test City, TC 12345',
            Customer_Type__c = 'Enterprise',
            Customer_Status__c = 'Active',
            Credit_Limit__c = 50000
        );
        insert testCustomer;
        
        // Create test devices
        List<Device__c> testDevices = new List<Device__c>();
        testDevices.add(new Device__c(
            Name = 'Test Device 1',
            Type__c = 'Computer',
            Stock_Quantity__c = 20,
            Price__c = 1000.00,
            Cost_Price__c = 700.00,
            Warranty_Period_Months__c = 12,
            Active__c = true,
            Supplier__c = testSupplier.Id,
            Minimum_Stock_Level__c = 5,
            Reorder_Point__c = 10,
            Stock_Status__c = 'In Stock'
        ));
        testDevices.add(new Device__c(
            Name = 'Test Device 2',
            Type__c = 'Software',
            Stock_Quantity__c = 3,
            Price__c = 500.00,
            Cost_Price__c = 300.00,
            Warranty_Period_Months__c = 12,
            Active__c = true,
            Supplier__c = testSupplier.Id,
            Minimum_Stock_Level__c = 10,
            Reorder_Point__c = 15,
            Stock_Status__c = 'Low Stock'
        ));
        insert testDevices;
        
        // Create test orders
        List<Order__c> testOrders = new List<Order__c>();
        testOrders.add(new Order__c(
            Customer__c = testCustomer.Id,
            Order_Date__c = Date.today(),
            Order_Status__c = 'Confirmed',
            Priority__c = 'High',
            Expected_Delivery_Date__c = Date.today().addDays(7),
            Tax_Rate__c = 8.25,
            Shipping_Cost__c = 25.00,
            Order_Discount_Percentage__c = 5.0
        ));
        testOrders.add(new Order__c(
            Customer__c = testCustomer.Id,
            Order_Date__c = Date.today().addDays(-1),
            Order_Status__c = 'Pending',
            Priority__c = 'Medium',
            Expected_Delivery_Date__c = Date.today().addDays(5),
            Tax_Rate__c = 8.25,
            Shipping_Cost__c = 15.00,
            Order_Discount_Percentage__c = 0
        ));
        insert testOrders;
        
        // Create test line items
        List<Order_Line_Item__c> testLineItems = new List<Order_Line_Item__c>();
        testLineItems.add(new Order_Line_Item__c(
            Order__c = testOrders[0].Id,
            Device__c = testDevices[0].Id,
            Quantity__c = 2,
            Unit_Price__c = 1000.00,
            Line_Number__c = 1,
            Line_Discount_Percentage__c = 10.0
        ));
        testLineItems.add(new Order_Line_Item__c(
            Order__c = testOrders[1].Id,
            Device__c = testDevices[1].Id,
            Quantity__c = 1,
            Unit_Price__c = 500.00,
            Line_Number__c = 1,
            Line_Discount_Percentage__c = 0
        ));
        insert testLineItems;
    }
    
    @isTest
    static void testGetDashboardData() {
        Date startDate = Date.today().addDays(-7);
        Date endDate = Date.today();
        
        Test.startTest();
        DashboardDTO.AnalyticsSummaryDTO result = AnalyticsService.getDashboardData(startDate, endDate);
        Test.stopTest();
        
        // Verify basic structure
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.ordersByStatus, 'Orders by status should not be null');
        System.assertNotEquals(null, result.devicesByType, 'Devices by type should not be null');
        System.assertNotEquals(null, result.revenueByDay, 'Revenue by day should not be null');
        
        // Verify metrics
        System.assert(result.totalOrders >= 0, 'Total orders should be non-negative');
        System.assert(result.totalRevenue >= 0, 'Total revenue should be non-negative');
        System.assert(result.totalDevices >= 0, 'Total devices should be non-negative');
        
        // Verify formatted values
        System.assertNotEquals(null, result.formattedTotalRevenue, 'Formatted total revenue should not be null');
        System.assertNotEquals(null, result.formattedAverageOrderValue, 'Formatted average order value should not be null');
    }
    
    @isTest
    static void testGetDashboardDataInvalidDates() {
        Date startDate = Date.today();
        Date endDate = Date.today().addDays(-7); // End before start
        
        Test.startTest();
        try {
            DashboardDTO.AnalyticsSummaryDTO result = AnalyticsService.getDashboardData(startDate, endDate);
            System.assert(false, 'Should throw exception for invalid date range');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Start date cannot be after end date'), 
                         'Should throw appropriate error message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetDashboardDataNullDates() {
        Test.startTest();
        try {
            DashboardDTO.AnalyticsSummaryDTO result = AnalyticsService.getDashboardData(null, null);
            System.assert(false, 'Should throw exception for null dates');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Start date and end date are required'), 
                         'Should throw appropriate error message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetInventoryAnalytics() {
        Test.startTest();
        List<DashboardDTO.DeviceDashboardDTO> result = AnalyticsService.getInventoryAnalytics();
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        
        // Should return at least the low stock device we created
        System.assert(result.size() >= 1, 'Should return at least 1 low stock device');
        
        for (DashboardDTO.DeviceDashboardDTO device : result) {
            System.assertNotEquals(null, device.deviceId, 'Device ID should not be null');
            System.assertNotEquals(null, device.deviceName, 'Device name should not be null');
            System.assertNotEquals(null, device.stockStatus, 'Stock status should not be null');
        }
    }
    
    @isTest
    static void testGetCustomerAnalytics() {
        Date startDate = Date.today().addDays(-7);
        Date endDate = Date.today();
        
        Test.startTest();
        List<AggregateResult> result = AnalyticsService.getCustomerAnalytics(startDate, endDate);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        
        // Should return customer analytics data
        for (AggregateResult ar : result) {
            System.assertNotEquals(null, ar.get('customerId'), 'Customer ID should not be null');
            System.assertNotEquals(null, ar.get('customerName'), 'Customer name should not be null');
        }
    }
    
    @isTest
    static void testGetCustomerAnalyticsInvalidDates() {
        Test.startTest();
        try {
            List<AggregateResult> result = AnalyticsService.getCustomerAnalytics(null, Date.today());
            System.assert(false, 'Should throw exception for null start date');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Start date and end date are required'), 
                         'Should throw appropriate error message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetOrderDetails() {
        Order__c testOrder = [SELECT Id FROM Order__c LIMIT 1];
        
        Test.startTest();
        DashboardDTO.OrderDashboardDTO result = AnalyticsService.getOrderDetails(testOrder.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(testOrder.Id, result.orderId, 'Order ID should match');
        System.assertNotEquals(null, result.orderNumber, 'Order number should not be null');
        System.assertNotEquals(null, result.customerName, 'Customer name should not be null');
        System.assertNotEquals(null, result.lineItems, 'Line items should not be null');
    }
    
    @isTest
    static void testGetOrderDetailsInvalidId() {
        Test.startTest();
        try {
            DashboardDTO.OrderDashboardDTO result = AnalyticsService.getOrderDetails(null);
            System.assert(false, 'Should throw exception for null order ID');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Order ID is required'), 
                         'Should throw appropriate error message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetRecentOrders() {
        Test.startTest();
        List<DashboardDTO.OrderDashboardDTO> result = AnalyticsService.getRecentOrders(5);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() <= 5, 'Should respect limit parameter');
        
        for (DashboardDTO.OrderDashboardDTO order : result) {
            System.assertNotEquals(null, order.orderId, 'Order ID should not be null');
            System.assertNotEquals(null, order.orderNumber, 'Order number should not be null');
        }
    }
    
    @isTest
    static void testGetRecentOrdersDefaultLimit() {
        Test.startTest();
        List<DashboardDTO.OrderDashboardDTO> result = AnalyticsService.getRecentOrders(null);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() <= 10, 'Should use default limit of 10');
    }
    
    @isTest
    static void testGetRecentOrdersMaxLimit() {
        Test.startTest();
        List<DashboardDTO.OrderDashboardDTO> result = AnalyticsService.getRecentOrders(200);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() <= 100, 'Should enforce maximum limit of 100');
    }
    
    @isTest
    static void testGetPerformanceMetrics() {
        Test.startTest();
        Map<String, Object> result = AnalyticsService.getPerformanceMetrics();
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        
        // Verify key metrics are present
        System.assert(result.containsKey('soqlQueries'), 'Should contain SOQL queries metric');
        System.assert(result.containsKey('soqlQueryLimit'), 'Should contain SOQL query limit');
        System.assert(result.containsKey('cpuTime'), 'Should contain CPU time metric');
        System.assert(result.containsKey('cpuTimeLimit'), 'Should contain CPU time limit');
        
        // Verify utilization calculations
        System.assert(result.containsKey('soqlUtilization'), 'Should contain SOQL utilization');
        System.assert(result.containsKey('cpuUtilization'), 'Should contain CPU utilization');
        
        // Verify values are reasonable
        Decimal soqlUtilization = (Decimal) result.get('soqlUtilization');
        System.assert(soqlUtilization >= 0 && soqlUtilization <= 100, 
                     'SOQL utilization should be between 0 and 100');
    }
}
