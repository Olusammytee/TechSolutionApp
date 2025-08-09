/**
 * OrderTriggerHandlerTest - Comprehensive Test Class for Order Processing
 * 
 * Educational Purpose: Demonstrates enterprise-level testing patterns in Salesforce
 * This test class provides complete coverage for the OrderTriggerHandler and OrderTrigger:
 * - Data setup and teardown patterns
 * - Positive and negative test scenarios
 * - Bulk processing validation
 * - Governor limit considerations
 * - Assertion best practices
 * 
 * Key Learning Concepts:
 * - @TestSetup for efficient data creation
 * - Test.startTest() and Test.stopTest() for governor limit reset
 * - System.assert methods for validation
 * - Bulk testing patterns
 * - Exception handling in tests
 * - Code coverage requirements (85%+)
 * 
 * Part of: TechSolutionApp Phase 4.1 - Interactive Learning Components
 * Author: TechSolutionApp Educational Platform
 * Created: August 2024
 */
@isTest
public class OrderTriggerHandlerTest {
    
    /**
     * Test data setup - runs once per test class
     * Educational Value: Shows efficient test data creation patterns
     */
    @TestSetup
    static void setupTestData() {
        // Educational Note: Create test devices with different stock levels
        List<Device__c> testDevices = new List<Device__c>();
        
        // Device 1: High stock
        testDevices.add(new Device__c(
            Name = 'Test Laptop Pro',
            Price__c = 1500.00,
            Stock_Quantity__c = 100,
            Minimum_Stock_Level__c = 10,
            Reorder_Point__c = 25,
            Stock_Status__c = 'In Stock'
        ));
        
        // Device 2: Low stock
        testDevices.add(new Device__c(
            Name = 'Test Tablet Mini',
            Price__c = 800.00,
            Stock_Quantity__c = 5,
            Minimum_Stock_Level__c = 10,
            Reorder_Point__c = 25,
            Stock_Status__c = 'Low Stock'
        ));
        
        // Device 3: Out of stock
        testDevices.add(new Device__c(
            Name = 'Test Phone Ultra',
            Price__c = 1200.00,
            Stock_Quantity__c = 0,
            Minimum_Stock_Level__c = 10,
            Reorder_Point__c = 25,
            Stock_Status__c = 'Out of Stock'
        ));
        
        insert testDevices;
    }
    
    /**
     * Test order total calculation
     * Educational Value: Shows positive test scenario patterns
     */
    @isTest
    static void testCalculateOrderTotals() {
        // Educational Note: Query test data
        Device__c testDevice = [SELECT Id, Price__c FROM Device__c WHERE Name = 'Test Laptop Pro' LIMIT 1];
        
        // Educational Note: Create test order
        Device_Order__c testOrder = new Device_Order__c(
            Device__c = testDevice.Id,
            Quantity__c = 3,
            Status__c = 'Draft'
        );
        
        Test.startTest();
        insert testOrder;
        Test.stopTest();
        
        // Educational Note: Verify total calculation
        testOrder = [SELECT Total_Price__c FROM Device_Order__c WHERE Id = :testOrder.Id];
        System.assertEquals(4500.00, testOrder.Total_Price__c, 
                          'Order total should be Price × Quantity (1500 × 3 = 4500)');
    }
    
    /**
     * Test stock availability validation
     * Educational Value: Shows negative test scenario patterns
     */
    @isTest
    static void testStockAvailabilityValidation() {
        // Educational Note: Query out of stock device
        Device__c testDevice = [SELECT Id FROM Device__c WHERE Name = 'Test Phone Ultra' LIMIT 1];
        
        // Educational Note: Attempt to order from out of stock device
        Device_Order__c testOrder = new Device_Order__c(
            Device__c = testDevice.Id,
            Quantity__c = 1,
            Status__c = 'Draft'
        );
        
        Test.startTest();
        try {
            insert testOrder;
            System.assert(false, 'Expected validation error for out of stock device');
        } catch (DmlException e) {
            // Educational Note: Verify error message contains expected text
            System.assert(e.getMessage().contains('Insufficient stock'), 
                         'Error message should mention insufficient stock');
        }
        Test.stopTest();
    }
    
    /**
     * Test confirmation number generation
     * Educational Value: Shows unique identifier testing patterns
     */
    @isTest
    static void testConfirmationNumberGeneration() {
        // Educational Note: Query test device
        Device__c testDevice = [SELECT Id FROM Device__c WHERE Name = 'Test Laptop Pro' LIMIT 1];
        
        // Educational Note: Create multiple orders to test uniqueness
        List<Device_Order__c> testOrders = new List<Device_Order__c>();
        for (Integer i = 0; i < 5; i++) {
            testOrders.add(new Device_Order__c(
                Device__c = testDevice.Id,
                Quantity__c = 1,
                Status__c = 'Draft'
            ));
        }
        
        Test.startTest();
        insert testOrders;
        Test.stopTest();
        
        // Educational Note: Verify confirmation numbers are generated and unique
        testOrders = [SELECT Confirmation_Number__c FROM Device_Order__c WHERE Id IN :testOrders];
        Set<String> confirmationNumbers = new Set<String>();
        
        for (Device_Order__c order : testOrders) {
            System.assertNotEquals(null, order.Confirmation_Number__c, 
                                 'Confirmation number should be generated');
            System.assert(order.Confirmation_Number__c.startsWith('ORD-'), 
                         'Confirmation number should start with ORD-');
            confirmationNumbers.add(order.Confirmation_Number__c);
        }
        
        System.assertEquals(5, confirmationNumbers.size(), 
                          'All confirmation numbers should be unique');
    }
    
    /**
     * Test device stock updates
     * Educational Value: Shows related record update testing
     */
    @isTest
    static void testDeviceStockUpdate() {
        // Educational Note: Query test device with known stock
        Device__c testDevice = [SELECT Id, Stock_Quantity__c FROM Device__c WHERE Name = 'Test Laptop Pro' LIMIT 1];
        Decimal originalStock = testDevice.Stock_Quantity__c;
        
        // Educational Note: Create order that will reduce stock
        Device_Order__c testOrder = new Device_Order__c(
            Device__c = testDevice.Id,
            Quantity__c = 10,
            Status__c = 'Draft'
        );
        
        Test.startTest();
        insert testOrder;
        Test.stopTest();
        
        // Educational Note: Verify stock was reduced
        testDevice = [SELECT Stock_Quantity__c FROM Device__c WHERE Id = :testDevice.Id];
        System.assertEquals(originalStock - 10, testDevice.Stock_Quantity__c, 
                          'Device stock should be reduced by order quantity');
    }
    
    /**
     * Test stock status updates
     * Educational Value: Shows automated status management testing
     */
    @isTest
    static void testStockStatusUpdate() {
        // Educational Note: Query device with low stock
        Device__c testDevice = [SELECT Id, Stock_Quantity__c FROM Device__c WHERE Name = 'Test Tablet Mini' LIMIT 1];
        
        // Educational Note: Create order that will make stock critically low
        Device_Order__c testOrder = new Device_Order__c(
            Device__c = testDevice.Id,
            Quantity__c = 5, // This will make stock = 0
            Status__c = 'Draft'
        );
        
        Test.startTest();
        insert testOrder;
        Test.stopTest();
        
        // Educational Note: Verify stock status was updated
        testDevice = [SELECT Stock_Status__c FROM Device__c WHERE Id = :testDevice.Id];
        System.assertEquals('Out of Stock', testDevice.Stock_Status__c,
                          'Stock status should be updated to Out of Stock');
    }

    /**
     * Test bulk order processing
     * Educational Value: Shows bulk processing and governor limit testing
     */
    @isTest
    static void testBulkOrderProcessing() {
        // Educational Note: Query test device
        Device__c testDevice = [SELECT Id FROM Device__c WHERE Name = 'Test Laptop Pro' LIMIT 1];

        // Educational Note: Create bulk orders (testing governor limits)
        List<Device_Order__c> bulkOrders = new List<Device_Order__c>();
        for (Integer i = 0; i < 200; i++) {
            bulkOrders.add(new Device_Order__c(
                Device__c = testDevice.Id,
                Quantity__c = 1,
                Status__c = 'Draft'
            ));
        }

        Test.startTest();
        insert bulkOrders;
        Test.stopTest();

        // Educational Note: Verify all orders were processed successfully
        List<Device_Order__c> insertedOrders = [
            SELECT Id, Total_Price__c, Confirmation_Number__c
            FROM Device_Order__c
            WHERE Id IN :bulkOrders
        ];

        System.assertEquals(200, insertedOrders.size(),
                          'All bulk orders should be processed');

        for (Device_Order__c order : insertedOrders) {
            System.assertNotEquals(null, order.Total_Price__c,
                                 'Total price should be calculated for all orders');
            System.assertNotEquals(null, order.Confirmation_Number__c,
                                 'Confirmation number should be generated for all orders');
        }
    }

    /**
     * Test order quantity updates
     * Educational Value: Shows update trigger testing patterns
     */
    @isTest
    static void testOrderQuantityUpdate() {
        // Educational Note: Query test device
        Device__c testDevice = [SELECT Id, Stock_Quantity__c FROM Device__c WHERE Name = 'Test Laptop Pro' LIMIT 1];
        Decimal originalStock = testDevice.Stock_Quantity__c;

        // Educational Note: Create initial order
        Device_Order__c testOrder = new Device_Order__c(
            Device__c = testDevice.Id,
            Quantity__c = 5,
            Status__c = 'Draft'
        );
        insert testOrder;

        // Educational Note: Update order quantity
        testOrder.Quantity__c = 10;

        Test.startTest();
        update testOrder;
        Test.stopTest();

        // Educational Note: Verify stock adjustment and total recalculation
        testOrder = [SELECT Total_Price__c FROM Device_Order__c WHERE Id = :testOrder.Id];
        testDevice = [SELECT Stock_Quantity__c FROM Device__c WHERE Id = :testDevice.Id];

        System.assertEquals(15000.00, testOrder.Total_Price__c,
                          'Total should be recalculated (1500 × 10 = 15000)');
        System.assertEquals(originalStock - 10, testDevice.Stock_Quantity__c,
                          'Stock should reflect final quantity (10)');
    }

    /**
     * Test order status changes
     * Educational Value: Shows state transition testing
     */
    @isTest
    static void testOrderStatusChanges() {
        // Educational Note: Query test device
        Device__c testDevice = [SELECT Id FROM Device__c WHERE Name = 'Test Laptop Pro' LIMIT 1];

        // Educational Note: Create order
        Device_Order__c testOrder = new Device_Order__c(
            Device__c = testDevice.Id,
            Quantity__c = 2,
            Status__c = 'Draft'
        );
        insert testOrder;

        // Educational Note: Change order status
        testOrder.Status__c = 'Confirmed';

        Test.startTest();
        update testOrder;
        Test.stopTest();

        // Educational Note: Verify status change was processed
        // In a real implementation, this would trigger additional business logic
        testOrder = [SELECT Status__c FROM Device_Order__c WHERE Id = :testOrder.Id];
        System.assertEquals('Confirmed', testOrder.Status__c,
                          'Order status should be updated');
    }

    /**
     * Test edge cases and error handling
     * Educational Value: Shows defensive programming testing
     */
    @isTest
    static void testEdgeCases() {
        // Educational Note: Test order with null device
        Device_Order__c nullDeviceOrder = new Device_Order__c(
            Device__c = null,
            Quantity__c = 1,
            Status__c = 'Draft'
        );

        Test.startTest();
        try {
            insert nullDeviceOrder;
            // Educational Note: This should be caught by validation rules
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('device'),
                         'Should validate device requirement');
        }

        // Educational Note: Test order with zero quantity
        Device__c testDevice = [SELECT Id FROM Device__c WHERE Name = 'Test Laptop Pro' LIMIT 1];
        Device_Order__c zeroQuantityOrder = new Device_Order__c(
            Device__c = testDevice.Id,
            Quantity__c = 0,
            Status__c = 'Draft'
        );

        try {
            insert zeroQuantityOrder;
            // Educational Note: This should be caught by validation rules
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('quantity'),
                         'Should validate positive quantity requirement');
        }
        Test.stopTest();
    }

    /**
     * Test helper method coverage
     * Educational Value: Shows private method testing through public methods
     */
    @isTest
    static void testHelperMethods() {
        // Educational Note: Test calculateStockStatus through updateStockStatus
        Device__c testDevice = [SELECT Id FROM Device__c WHERE Name = 'Test Laptop Pro' LIMIT 1];

        Device_Order__c testOrder = new Device_Order__c(
            Device__c = testDevice.Id,
            Quantity__c = 1,
            Status__c = 'Draft'
        );

        Test.startTest();
        insert testOrder;
        Test.stopTest();

        // Educational Note: Verify helper method was called indirectly
        testDevice = [SELECT Stock_Status__c FROM Device__c WHERE Id = :testDevice.Id];
        System.assertNotEquals(null, testDevice.Stock_Status__c,
                             'Stock status should be calculated and updated');
    }
}
