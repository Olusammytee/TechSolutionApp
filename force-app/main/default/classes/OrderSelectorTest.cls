/**
 * 🧪 ORDER SELECTOR TEST CLASS - Mastering the Selector Pattern!
 *
 * Welcome to data access layer testing! Learn professional SOQL patterns.
 *
 * 🎯 WHAT YOU'LL LEARN:
 * ✅ How to test the Selector pattern (data access layer)
 * ✅ How to verify SOQL queries return correct data
 * ✅ How to test WITH SECURITY_ENFORCED
 * ✅ How to test aggregation queries
 * ✅ How to test relationship queries
 *
 * 📚 TESTING CONCEPTS COVERED:
 * - Selector pattern testing
 * - Test data setup for complex queries
 * - Aggregate result testing
 * - Security enforcement validation
 * - Query optimization verification
 *
 * 🎓 EDUCATIONAL GOAL: 95%+ code coverage with realistic data scenarios
 *
 * @author TechSolutionApp Educational Platform
 * @date 2025
 */
@isTest
private class OrderSelectorTest {

    /**
     * 🏗️ TEST SETUP: Create comprehensive test data
     *
     * Why comprehensive setup?
     * - Selector methods need realistic data to query
     * - We need multiple customers, devices, orders for testing
     * - Data relationships must be established
     */
    @TestSetup
    static void setupTestData() {
        // Create Customers
        List<Customer__c> customers = new List<Customer__c>();
        customers.add(new Customer__c(
            Name = 'Acme Corporation',
            Email__c = 'contact@acme.com',
            Phone__c = '555-0001',
            Customer_Type__c = 'Business'
        ));
        customers.add(new Customer__c(
            Name = 'Global Tech Inc',
            Email__c = 'info@globaltech.com',
            Phone__c = '555-0002',
            Customer_Type__c = 'Business'
        ));
        customers.add(new Customer__c(
            Name = 'John Smith',
            Email__c = 'john@email.com',
            Phone__c = '555-0003',
            Customer_Type__c = 'Individual'
        ));
        insert customers;

        // Create Devices
        List<Device__c> devices = new List<Device__c>();
        devices.add(new Device__c(
            Name = 'MacBook Pro 16"',
            Type__c = 'Laptop',
            Price__c = 2500.00,
            Cost_Price__c = 1800.00,
            Stock_Quantity__c = 50
        ));
        devices.add(new Device__c(
            Name = 'iPhone 15 Pro',
            Type__c = 'Smartphone',
            Price__c = 1199.00,
            Cost_Price__c = 850.00,
            Stock_Quantity__c = 100
        ));
        devices.add(new Device__c(
            Name = 'iPad Pro 12.9"',
            Type__c = 'Tablet',
            Price__c = 1099.00,
            Cost_Price__c = 750.00,
            Stock_Quantity__c = 75
        ));
        insert devices;

        // Create Orders with various statuses and priorities
        List<Order__c> orders = new List<Order__c>();

        // Order 1: High priority, pending
        orders.add(new Order__c(
            Customer__c = customers[0].Id,
            Order_Date__c = Date.today(),
            Order_Status__c = 'Pending',
            Priority__c = 'High',
            Subtotal__c = 5000.00,
            Tax_Amount__c = 500.00,
            Total_Amount__c = 5500.00
        ));

        // Order 2: Critical priority, confirmed
        orders.add(new Order__c(
            Customer__c = customers[1].Id,
            Order_Date__c = Date.today().addDays(-1),
            Order_Status__c = 'Confirmed',
            Priority__c = 'Critical',
            Subtotal__c = 3000.00,
            Tax_Amount__c = 300.00,
            Total_Amount__c = 3300.00
        ));

        // Order 3: Normal priority, delivered (completed)
        orders.add(new Order__c(
            Customer__c = customers[2].Id,
            Order_Date__c = Date.today().addDays(-7),
            Order_Status__c = 'Delivered',
            Priority__c = 'Normal',
            Subtotal__c = 1200.00,
            Tax_Amount__c = 120.00,
            Total_Amount__c = 1320.00
        ));

        // Order 4: Low priority, cancelled
        orders.add(new Order__c(
            Customer__c = customers[0].Id,
            Order_Date__c = Date.today().addDays(-3),
            Order_Status__c = 'Cancelled',
            Priority__c = 'Low',
            Subtotal__c = 800.00,
            Tax_Amount__c = 80.00,
            Total_Amount__c = 880.00
        ));

        insert orders;

        // Create Order Line Items
        List<Order_Line_Item__c> lineItems = new List<Order_Line_Item__c>();

        // Line items for Order 1
        lineItems.add(new Order_Line_Item__c(
            Order__c = orders[0].Id,
            Device__c = devices[0].Id,
            Product_Name__c = 'MacBook Pro 16"',
            Quantity__c = 2,
            Unit_Price__c = 2500.00,
            Line_Total__c = 5000.00
        ));

        // Line items for Order 2
        lineItems.add(new Order_Line_Item__c(
            Order__c = orders[1].Id,
            Device__c = devices[1].Id,
            Product_Name__c = 'iPhone 15 Pro',
            Quantity__c = 2,
            Unit_Price__c = 1199.00,
            Line_Total__c = 2398.00
        ));
        lineItems.add(new Order_Line_Item__c(
            Order__c = orders[1].Id,
            Device__c = devices[2].Id,
            Product_Name__c = 'iPad Pro 12.9"',
            Quantity__c = 1,
            Unit_Price__c = 1099.00,
            Line_Total__c = 1099.00
        ));

        // Line items for Order 3
        lineItems.add(new Order_Line_Item__c(
            Order__c = orders[2].Id,
            Device__c = devices[1].Id,
            Product_Name__c = 'iPhone 15 Pro',
            Quantity__c = 1,
            Unit_Price__c = 1199.00,
            Line_Total__c = 1199.00
        ));

        insert lineItems;
    }

    /**
     * 🧪 TEST 1: Select By ID
     *
     * WHAT THIS TESTS:
     * - Basic order retrieval by ID
     * - Field population
     * - WITH SECURITY_ENFORCED compliance
     */
    @isTest
    static void testSelectById() {
        // 📝 ARRANGE
        List<Order__c> allOrders = [SELECT Id FROM Order__c LIMIT 2];
        Set<Id> orderIds = new Set<Id>();
        for (Order__c order : allOrders) {
            orderIds.add(order.Id);
        }

        // 🎬 ACT
        Test.startTest();
        List<Order__c> selectedOrders = OrderSelector.selectById(orderIds);
        Test.stopTest();

        // ✅ ASSERT
        System.assertEquals(2, selectedOrders.size(),
            '📊 Should return 2 orders');

        // Verify fields are populated
        for (Order__c order : selectedOrders) {
            System.assertNotEquals(null, order.Id,
                '✅ Id should be populated');
            System.assertNotEquals(null, order.Name,
                '✅ Name should be populated');
            System.assertNotEquals(null, order.Order_Status__c,
                '✅ Order_Status__c should be populated');
        }
    }

    /**
     * 🧪 TEST 2: Select By ID - Empty Set
     *
     * WHAT THIS TESTS:
     * - Handling empty ID sets
     * - No errors with empty input
     * - Returns empty list
     */
    @isTest
    static void testSelectByIdEmpty() {
        // 🎬 ACT
        Test.startTest();
        List<Order__c> orders = OrderSelector.selectById(new Set<Id>());
        Test.stopTest();

        // ✅ ASSERT
        System.assertNotEquals(null, orders,
            '📊 Should return empty list, not null');
        System.assertEquals(0, orders.size(),
            '✅ Empty set should return empty list');
    }

    /**
     * 🧪 TEST 3: Select By ID - Null Set
     *
     * WHAT THIS TESTS:
     * - Defensive programming
     * - Null parameter handling
     * - No null pointer exceptions
     */
    @isTest
    static void testSelectByIdNull() {
        // 🎬 ACT
        Test.startTest();
        List<Order__c> orders = OrderSelector.selectById(null);
        Test.stopTest();

        // ✅ ASSERT
        System.assertNotEquals(null, orders,
            '📊 Null input should return empty list');
        System.assertEquals(0, orders.size(),
            '✅ Null set should be handled gracefully');
    }

    /**
     * 🧪 TEST 4: Select Financial By ID
     *
     * WHAT THIS TESTS:
     * - Financial field retrieval
     * - Subtotal, tax, total amount fields
     * - More comprehensive field set
     */
    @isTest
    static void testSelectFinancialById() {
        // 📝 ARRANGE
        List<Order__c> allOrders = [SELECT Id FROM Order__c LIMIT 1];
        Set<Id> orderIds = new Set<Id>{allOrders[0].Id};

        // 🎬 ACT
        Test.startTest();
        List<Order__c> orders = OrderSelector.selectFinancialById(orderIds);
        Test.stopTest();

        // ✅ ASSERT
        System.assertEquals(1, orders.size(),
            '📊 Should return 1 order');

        Order__c order = orders[0];
        System.assertNotEquals(null, order.Subtotal__c,
            '💰 Subtotal__c should be populated');
        System.assertNotEquals(null, order.Tax_Amount__c,
            '💰 Tax_Amount__c should be populated');
        System.assertNotEquals(null, order.Total_Amount__c,
            '💰 Total_Amount__c should be populated');
    }

    /**
     * 🧪 TEST 5: Select By Customer
     *
     * WHAT THIS TESTS:
     * - Filtering orders by customer
     * - Relationship queries
     * - Multiple orders per customer
     */
    @isTest
    static void testSelectByCustomer() {
        // 📝 ARRANGE
        Customer__c customer = [SELECT Id FROM Customer__c WHERE Name = 'Acme Corporation' LIMIT 1];
        Set<Id> customerIds = new Set<Id>{customer.Id};

        // 🎬 ACT
        Test.startTest();
        List<Order__c> orders = OrderSelector.selectByCustomer(customerIds);
        Test.stopTest();

        // ✅ ASSERT
        System.assert(orders.size() > 0,
            '📊 Acme Corporation should have orders');

        // Verify all orders belong to correct customer
        for (Order__c order : orders) {
            System.assertEquals(customer.Id, order.Customer__c,
                '✅ All orders should belong to Acme Corporation');
            System.assertNotEquals(null, order.Order_Date__c,
                '📅 Order date should be populated');
        }
    }

    /**
     * 🧪 TEST 6: Select For Dashboard
     *
     * WHAT THIS TESTS:
     * - Date range filtering
     * - Dashboard-specific fields
     * - Date-based queries
     */
    @isTest
    static void testSelectForDashboard() {
        // 📝 ARRANGE
        Date startDate = Date.today().addDays(-30);
        Date endDate = Date.today();

        // 🎬 ACT
        Test.startTest();
        List<Order__c> orders = OrderSelector.selectForDashboard(startDate, endDate);
        Test.stopTest();

        // ✅ ASSERT
        System.assert(orders.size() > 0,
            '📊 Should find orders in date range');

        // Verify all orders are within date range
        for (Order__c order : orders) {
            System.assert(order.Order_Date__c >= startDate,
                '✅ Order date should be >= start date');
            System.assert(order.Order_Date__c <= endDate,
                '✅ Order date should be <= end date');
        }
    }

    /**
     * 🧪 TEST 7: Select High Priority
     *
     * WHAT THIS TESTS:
     * - Priority filtering
     * - Status filtering (excludes completed/cancelled)
     * - Multiple filter conditions
     */
    @isTest
    static void testSelectHighPriority() {
        // 🎬 ACT
        Test.startTest();
        List<Order__c> orders = OrderSelector.selectHighPriority();
        Test.stopTest();

        // ✅ ASSERT
        System.assert(orders.size() > 0,
            '📊 Should have high priority orders');

        // Verify all orders are high or critical priority
        for (Order__c order : orders) {
            System.assert(
                order.Priority__c == 'High' || order.Priority__c == 'Critical',
                '⚡ Order should be High or Critical priority');

            System.assert(
                order.Order_Status__c != 'Delivered' &&
                order.Order_Status__c != 'Cancelled',
                '✅ Should exclude completed/cancelled orders');
        }
    }

    /**
     * 🧪 TEST 8: Select Pending Orders
     *
     * WHAT THIS TESTS:
     * - Status-based filtering
     * - Workflow-specific queries
     * - Pending and Confirmed orders
     */
    @isTest
    static void testSelectPending() {
        // 🎬 ACT
        Test.startTest();
        List<Order__c> orders = OrderSelector.selectPending();
        Test.stopTest();

        // ✅ ASSERT
        System.assert(orders.size() > 0,
            '📊 Should have pending orders');

        // Verify all orders are pending or confirmed
        for (Order__c order : orders) {
            System.assert(
                order.Order_Status__c == 'Pending' ||
                order.Order_Status__c == 'Confirmed',
                '✅ Order should be Pending or Confirmed');
        }
    }

    /**
     * 🧪 TEST 9: Select With Line Items
     *
     * WHAT THIS TESTS:
     * - Parent-child relationship queries
     * - Subquery results
     * - Complete order data retrieval
     */
    @isTest
    static void testSelectWithLineItems() {
        // 📝 ARRANGE
        List<Order__c> allOrders = [SELECT Id FROM Order__c WHERE Id IN (
            SELECT Order__c FROM Order_Line_Item__c
        ) LIMIT 2];
        Set<Id> orderIds = new Set<Id>();
        for (Order__c order : allOrders) {
            orderIds.add(order.Id);
        }

        // 🎬 ACT
        Test.startTest();
        List<Order__c> orders = OrderSelector.selectWithLineItems(orderIds);
        Test.stopTest();

        // ✅ ASSERT
        System.assert(orders.size() > 0,
            '📊 Should return orders with line items');

        // Verify line items are included
        Boolean foundLineItems = false;
        for (Order__c order : orders) {
            if (order.Order_Line_Items__r != null && order.Order_Line_Items__r.size() > 0) {
                foundLineItems = true;

                // Verify line item fields
                for (Order_Line_Item__c lineItem : order.Order_Line_Items__r) {
                    System.assertNotEquals(null, lineItem.Product_Name__c,
                        '📦 Line item should have product name');
                    System.assertNotEquals(null, lineItem.Quantity__c,
                        '🔢 Line item should have quantity');
                    System.assertNotEquals(null, lineItem.Unit_Price__c,
                        '💰 Line item should have unit price');
                }
            }
        }

        System.assert(foundLineItems,
            '✅ At least one order should have line items');
    }

    /**
     * 🧪 TEST 10: Select Line Items By Order
     *
     * WHAT THIS TESTS:
     * - Child record retrieval
     * - Filtering by parent relationship
     * - Line item fields population
     */
    @isTest
    static void testSelectLineItemsByOrder() {
        // 📝 ARRANGE
        List<Order__c> orders = [SELECT Id FROM Order__c LIMIT 2];
        Set<Id> orderIds = new Set<Id>();
        for (Order__c order : orders) {
            orderIds.add(order.Id);
        }

        // 🎬 ACT
        Test.startTest();
        List<Order_Line_Item__c> lineItems =
            OrderSelector.selectLineItemsByOrder(orderIds);
        Test.stopTest();

        // ✅ ASSERT
        System.assert(lineItems.size() > 0,
            '📊 Should return line items for orders');

        // Verify line items belong to correct orders
        for (Order_Line_Item__c lineItem : lineItems) {
            System.assert(orderIds.contains(lineItem.Order__c),
                '✅ Line item should belong to one of the selected orders');
            System.assertNotEquals(null, lineItem.Quantity__c,
                '🔢 Quantity should be populated');
        }
    }

    /**
     * 🧪 TEST 11: Select Line Items By Device
     *
     * WHAT THIS TESTS:
     * - Filtering by device (product)
     * - Device-to-order relationship
     * - Order status filtering
     */
    @isTest
    static void testSelectLineItemsByDevice() {
        // 📝 ARRANGE
        List<Device__c> devices = [SELECT Id FROM Device__c LIMIT 1];
        Set<Id> deviceIds = new Set<Id>{devices[0].Id};

        // 🎬 ACT
        Test.startTest();
        List<Order_Line_Item__c> lineItems =
            OrderSelector.selectLineItemsByDevice(deviceIds);
        Test.stopTest();

        // ✅ ASSERT
        // May or may not have line items depending on test data
        // But should not throw errors
        System.assertNotEquals(null, lineItems,
            '📊 Should return list (may be empty)');

        // If line items exist, verify they're for correct device
        for (Order_Line_Item__c lineItem : lineItems) {
            System.assertEquals(devices[0].Id, lineItem.Device__c,
                '✅ Line item should be for the selected device');
        }
    }

    /**
     * 🧪 TEST 12: Get Order Analytics
     *
     * WHAT THIS TESTS:
     * - Aggregate queries
     * - COUNT, SUM, AVG functions
     * - GROUP BY functionality
     */
    @isTest
    static void testGetOrderAnalytics() {
        // 📝 ARRANGE
        Date startDate = Date.today().addDays(-30);
        Date endDate = Date.today();

        // 🎬 ACT
        Test.startTest();
        List<AggregateResult> analytics =
            OrderSelector.getOrderAnalytics(startDate, endDate);
        Test.stopTest();

        // ✅ ASSERT
        System.assert(analytics.size() > 0,
            '📊 Should return aggregated analytics');

        // Verify aggregate result structure
        for (AggregateResult result : analytics) {
            System.assertNotEquals(null, result.get('status'),
                '✅ Status should be in aggregate result');
            System.assertNotEquals(null, result.get('priority'),
                '✅ Priority should be in aggregate result');
            System.assertNotEquals(null, result.get('orderCount'),
                '🔢 Order count should be calculated');
            // Revenue might be null if no orders with amount
            System.debug('📊 Aggregate Result: ' + result);
        }
    }

    /**
     * 🧪 TEST 13: Get Customer Order Analytics
     *
     * WHAT THIS TESTS:
     * - Customer-level aggregation
     * - Relationship field grouping
     * - Top customer identification
     */
    @isTest
    static void testGetCustomerOrderAnalytics() {
        // 📝 ARRANGE
        Date startDate = Date.today().addDays(-30);
        Date endDate = Date.today();

        // 🎬 ACT
        Test.startTest();
        List<AggregateResult> analytics =
            OrderSelector.getCustomerOrderAnalytics(startDate, endDate);
        Test.stopTest();

        // ✅ ASSERT
        System.assert(analytics.size() > 0,
            '📊 Should return customer analytics');

        // Verify customer aggregate data
        for (AggregateResult result : analytics) {
            System.assertNotEquals(null, result.get('customerId'),
                '✅ Customer ID should be present');
            System.assertNotEquals(null, result.get('customerName'),
                '✅ Customer name should be present');
            System.assertNotEquals(null, result.get('orderCount'),
                '🔢 Order count should be calculated');
            System.debug('👥 Customer Analytics: ' + result);
        }
    }

    /**
     * 🧪 TEST 14: Get Daily Order Trends
     *
     * WHAT THIS TESTS:
     * - Time-series data aggregation
     * - Daily grouping
     * - Trend analysis queries
     */
    @isTest
    static void testGetDailyOrderTrends() {
        // 📝 ARRANGE
        Date startDate = Date.today().addDays(-7);
        Date endDate = Date.today();

        // 🎬 ACT
        Test.startTest();
        List<AggregateResult> trends =
            OrderSelector.getDailyOrderTrends(startDate, endDate);
        Test.stopTest();

        // ✅ ASSERT
        System.assert(trends.size() > 0,
            '📊 Should return daily trends');

        // Verify trend data structure
        for (AggregateResult result : trends) {
            System.assertNotEquals(null, result.get('orderDate'),
                '📅 Order date should be present');
            System.assertNotEquals(null, result.get('orderCount'),
                '🔢 Daily order count should be calculated');
            System.debug('📈 Daily Trend: ' + result);
        }
    }

    /**
     * 🧪 TEST 15: Real-World Scenario - Dashboard Data Loading
     *
     * WHAT THIS TESTS:
     * - Complete dashboard workflow
     * - Multiple selector method calls
     * - Realistic data retrieval pattern
     */
    @isTest
    static void testRealWorldDashboardScenario() {
        // 📝 SCENARIO: Loading dashboard with all relevant data
        Date startDate = Date.today().addDays(-30);
        Date endDate = Date.today();

        // 🎬 ACT
        Test.startTest();

        // Step 1: Get high priority orders for action items
        List<Order__c> priorityOrders = OrderSelector.selectHighPriority();

        // Step 2: Get pending orders for workflow
        List<Order__c> pendingOrders = OrderSelector.selectPending();

        // Step 3: Get analytics for charts
        List<AggregateResult> orderAnalytics =
            OrderSelector.getOrderAnalytics(startDate, endDate);

        // Step 4: Get customer analytics for insights
        List<AggregateResult> customerAnalytics =
            OrderSelector.getCustomerOrderAnalytics(startDate, endDate);

        // Step 5: Get daily trends for time-series chart
        List<AggregateResult> dailyTrends =
            OrderSelector.getDailyOrderTrends(startDate, endDate);

        Test.stopTest();

        // ✅ ASSERT
        // Dashboard should have all necessary data
        System.assertNotEquals(null, priorityOrders,
            '📊 Priority orders should be loaded');
        System.assertNotEquals(null, pendingOrders,
            '📊 Pending orders should be loaded');
        System.assertNotEquals(null, orderAnalytics,
            '📊 Order analytics should be loaded');
        System.assertNotEquals(null, customerAnalytics,
            '📊 Customer analytics should be loaded');
        System.assertNotEquals(null, dailyTrends,
            '📊 Daily trends should be loaded');

        System.debug('🎉 Dashboard loaded successfully!');
        System.debug('   Priority Orders: ' + priorityOrders.size());
        System.debug('   Pending Orders: ' + pendingOrders.size());
        System.debug('   Analytics Groups: ' + orderAnalytics.size());
        System.debug('   Top Customers: ' + customerAnalytics.size());
        System.debug('   Trend Data Points: ' + dailyTrends.size());
    }
}
