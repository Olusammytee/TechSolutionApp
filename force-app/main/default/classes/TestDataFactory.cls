/**
 * 🏭 TEST DATA FACTORY - Professional Test Data Management
 *
 * Welcome to the Factory Pattern for Test Data!
 *
 * 🎯 WHAT THIS SOLVES:
 * ✅ Eliminates duplicate test data creation code
 * ✅ Provides consistent test data across all tests
 * ✅ Makes tests more readable and maintainable
 * ✅ Centralizes test data logic in one place
 * ✅ Easy to update when data model changes
 *
 * 📚 DESIGN PATTERN: Factory Pattern
 * - Single responsibility: Create test data
 * - Reusable across all test classes
 * - Configurable with parameters
 * - Handles bulk creation efficiently
 *
 * 🎓 HOW TO USE:
 * Instead of:
 *   Device__c device = new Device__c(Name='Test', Price__c=100);
 *   insert device;
 *
 * Use:
 *   Device__c device = TestDataFactory.createDevice();
 *   // or
 *   List<Device__c> devices = TestDataFactory.createDevices(10);
 *
 * @author TechSolutionApp Educational Platform
 * @date 2025
 */
@isTest
public class TestDataFactory {

    // ============================================================================
    // CONSTANTS - Single source of truth for test values
    // ============================================================================

    // Device Constants
    public static final String DEFAULT_DEVICE_NAME = 'Test Device';
    public static final Decimal DEFAULT_DEVICE_PRICE = 1000.00;
    public static final Decimal DEFAULT_DEVICE_COST = 700.00;
    public static final Decimal DEFAULT_DEVICE_STOCK = 100;
    public static final String DEFAULT_DEVICE_TYPE = 'Laptop';

    // Customer Constants
    public static final String DEFAULT_CUSTOMER_NAME = 'Test Customer';
    public static final String DEFAULT_CUSTOMER_EMAIL = 'test@example.com';
    public static final String DEFAULT_CUSTOMER_PHONE = '555-0100';
    public static final String DEFAULT_CUSTOMER_TYPE = 'Business';

    // Order Constants
    public static final String DEFAULT_ORDER_STATUS = 'Pending';
    public static final String DEFAULT_ORDER_PRIORITY = 'Normal';
    public static final Decimal DEFAULT_ORDER_SUBTOTAL = 1000.00;
    public static final Decimal DEFAULT_TAX_RATE = 0.10;

    // Supplier Constants
    public static final String DEFAULT_SUPPLIER_NAME = 'Test Supplier';
    public static final String DEFAULT_SUPPLIER_EMAIL = 'supplier@example.com';

    // ============================================================================
    // DEVICE FACTORY METHODS
    // ============================================================================

    /**
     * Create a single Device with default values
     * @return Device__c with default test values (not inserted)
     */
    public static Device__c createDevice() {
        return createDevice(DEFAULT_DEVICE_NAME, DEFAULT_DEVICE_PRICE, DEFAULT_DEVICE_STOCK);
    }

    /**
     * Create a single Device with custom values
     * @param name Device name
     * @param price Device price
     * @param stock Stock quantity
     * @return Device__c with specified values (not inserted)
     */
    public static Device__c createDevice(String name, Decimal price, Decimal stock) {
        return new Device__c(
            Name = name,
            Price__c = price,
            Cost_Price__c = price * 0.7, // 30% profit margin
            Stock_Quantity__c = stock,
            Minimum_Stock_Level__c = 10,
            Reorder_Point__c = 20,
            Type__c = DEFAULT_DEVICE_TYPE,
            Active__c = true,
            Stock_Status__c = 'In Stock'
        );
    }

    /**
     * Create and INSERT a single Device
     * @return Device__c (inserted with Id)
     */
    public static Device__c createAndInsertDevice() {
        Device__c device = createDevice();
        insert device;
        return device;
    }

    /**
     * Create multiple Devices with sequential names
     * @param count Number of devices to create
     * @return List<Device__c> (not inserted)
     */
    public static List<Device__c> createDevices(Integer count) {
        List<Device__c> devices = new List<Device__c>();
        for (Integer i = 0; i < count; i++) {
            devices.add(createDevice(
                DEFAULT_DEVICE_NAME + ' ' + i,
                DEFAULT_DEVICE_PRICE + (i * 10),
                DEFAULT_DEVICE_STOCK - (i * 5)
            ));
        }
        return devices;
    }

    /**
     * Create and INSERT multiple Devices
     * @param count Number of devices to create
     * @return List<Device__c> (inserted with Ids)
     */
    public static List<Device__c> createAndInsertDevices(Integer count) {
        List<Device__c> devices = createDevices(count);
        insert devices;
        return devices;
    }

    /**
     * Create a Device with specific stock status scenario
     * @param stockStatus 'Out of Stock', 'Low Stock', or 'In Stock'
     * @return Device__c configured for the stock scenario
     */
    public static Device__c createDeviceWithStockStatus(String stockStatus) {
        Decimal stock;
        if (stockStatus == 'Out of Stock') {
            stock = 0;
        } else if (stockStatus == 'Low Stock') {
            stock = 5;
        } else {
            stock = 100;
        }

        Device__c device = createDevice(DEFAULT_DEVICE_NAME, DEFAULT_DEVICE_PRICE, stock);
        device.Stock_Status__c = stockStatus;
        return device;
    }

    // ============================================================================
    // CUSTOMER FACTORY METHODS
    // ============================================================================

    /**
     * Create a single Customer with default values
     * @return Customer__c (not inserted)
     */
    public static Customer__c createCustomer() {
        return createCustomer(DEFAULT_CUSTOMER_NAME, DEFAULT_CUSTOMER_EMAIL);
    }

    /**
     * Create a Customer with custom values
     * @param name Customer name
     * @param email Customer email
     * @return Customer__c (not inserted)
     */
    public static Customer__c createCustomer(String name, String email) {
        return new Customer__c(
            Name = name,
            Email__c = email,
            Phone__c = DEFAULT_CUSTOMER_PHONE,
            Customer_Type__c = DEFAULT_CUSTOMER_TYPE,
            Customer_Status__c = 'Active',
            Credit_Limit__c = 10000.00
        );
    }

    /**
     * Create and INSERT a single Customer
     * @return Customer__c (inserted with Id)
     */
    public static Customer__c createAndInsertCustomer() {
        Customer__c customer = createCustomer();
        insert customer;
        return customer;
    }

    /**
     * Create multiple Customers
     * @param count Number of customers to create
     * @return List<Customer__c> (not inserted)
     */
    public static List<Customer__c> createCustomers(Integer count) {
        List<Customer__c> customers = new List<Customer__c>();
        for (Integer i = 0; i < count; i++) {
            customers.add(createCustomer(
                DEFAULT_CUSTOMER_NAME + ' ' + i,
                'test' + i + '@example.com'
            ));
        }
        return customers;
    }

    /**
     * Create and INSERT multiple Customers
     * @param count Number of customers to create
     * @return List<Customer__c> (inserted with Ids)
     */
    public static List<Customer__c> createAndInsertCustomers(Integer count) {
        List<Customer__c> customers = createCustomers(count);
        insert customers;
        return customers;
    }

    // ============================================================================
    // ORDER FACTORY METHODS
    // ============================================================================

    /**
     * Create an Order (requires existing Customer)
     * @param customerId Id of the customer
     * @return Order__c (not inserted)
     */
    public static Order__c createOrder(Id customerId) {
        return new Order__c(
            Customer__c = customerId,
            Order_Date__c = Date.today(),
            Order_Status__c = DEFAULT_ORDER_STATUS,
            Priority__c = DEFAULT_ORDER_PRIORITY,
            Subtotal__c = DEFAULT_ORDER_SUBTOTAL,
            Tax_Amount__c = DEFAULT_ORDER_SUBTOTAL * DEFAULT_TAX_RATE,
            Total_Amount__c = DEFAULT_ORDER_SUBTOTAL * (1 + DEFAULT_TAX_RATE)
        );
    }

    /**
     * Create an Order with specific status and priority
     * @param customerId Customer Id
     * @param status Order status
     * @param priority Order priority
     * @return Order__c (not inserted)
     */
    public static Order__c createOrder(Id customerId, String status, String priority) {
        Order__c order = createOrder(customerId);
        order.Order_Status__c = status;
        order.Priority__c = priority;
        return order;
    }

    /**
     * Create multiple Orders for a customer
     * @param customerId Customer Id
     * @param count Number of orders
     * @return List<Order__c> (not inserted)
     */
    public static List<Order__c> createOrders(Id customerId, Integer count) {
        List<Order__c> orders = new List<Order__c>();
        for (Integer i = 0; i < count; i++) {
            Order__c order = createOrder(customerId);
            order.Order_Date__c = Date.today().addDays(-i);
            orders.add(order);
        }
        return orders;
    }

    // ============================================================================
    // DEVICE ORDER FACTORY METHODS
    // ============================================================================

    /**
     * Create a Device Order
     * @param deviceId Device Id
     * @param quantity Quantity to order
     * @return Device_Order__c (not inserted)
     */
    public static Device_Order__c createDeviceOrder(Id deviceId, Decimal quantity) {
        return new Device_Order__c(
            Device__c = deviceId,
            Quantity__c = quantity,
            Status__c = 'Draft',
            Order_Date__c = Date.today()
        );
    }

    /**
     * Create a Device Order with specific status
     * @param deviceId Device Id
     * @param quantity Quantity
     * @param status Order status
     * @return Device_Order__c (not inserted)
     */
    public static Device_Order__c createDeviceOrder(Id deviceId, Decimal quantity, String status) {
        Device_Order__c order = createDeviceOrder(deviceId, quantity);
        order.Status__c = status;
        return order;
    }

    /**
     * Create multiple Device Orders for a device
     * @param deviceId Device Id
     * @param count Number of orders
     * @return List<Device_Order__c> (not inserted)
     */
    public static List<Device_Order__c> createDeviceOrders(Id deviceId, Integer count) {
        List<Device_Order__c> orders = new List<Device_Order__c>();
        for (Integer i = 0; i < count; i++) {
            orders.add(createDeviceOrder(deviceId, i + 1));
        }
        return orders;
    }

    // ============================================================================
    // ORDER LINE ITEM FACTORY METHODS
    // ============================================================================

    /**
     * Create an Order Line Item
     * @param orderId Order Id
     * @param deviceId Device Id
     * @param quantity Quantity
     * @param unitPrice Unit price
     * @return Order_Line_Item__c (not inserted)
     */
    public static Order_Line_Item__c createOrderLineItem(
        Id orderId, Id deviceId, Decimal quantity, Decimal unitPrice
    ) {
        return new Order_Line_Item__c(
            Order__c = orderId,
            Device__c = deviceId,
            Product_Name__c = DEFAULT_DEVICE_NAME,
            Quantity__c = quantity,
            Unit_Price__c = unitPrice,
            Line_Total__c = quantity * unitPrice
        );
    }

    /**
     * Create multiple line items for an order
     * @param orderId Order Id
     * @param deviceIds List of Device Ids
     * @return List<Order_Line_Item__c> (not inserted)
     */
    public static List<Order_Line_Item__c> createOrderLineItems(
        Id orderId, List<Id> deviceIds
    ) {
        List<Order_Line_Item__c> lineItems = new List<Order_Line_Item__c>();
        for (Integer i = 0; i < deviceIds.size(); i++) {
            lineItems.add(createOrderLineItem(
                orderId,
                deviceIds[i],
                i + 1,
                DEFAULT_DEVICE_PRICE
            ));
        }
        return lineItems;
    }

    // ============================================================================
    // SUPPLIER FACTORY METHODS
    // ============================================================================

    /**
     * Create a Supplier
     * @return Supplier__c (not inserted)
     */
    public static Supplier__c createSupplier() {
        return createSupplier(DEFAULT_SUPPLIER_NAME);
    }

    /**
     * Create a Supplier with custom name
     * @param name Supplier name
     * @return Supplier__c (not inserted)
     */
    public static Supplier__c createSupplier(String name) {
        return new Supplier__c(
            Name = name,
            Contact_Email__c = DEFAULT_SUPPLIER_EMAIL,
            Supplier_Rating__c = 'A',
            Lead_Time_Days__c = 7
        );
    }

    /**
     * Create and INSERT a Supplier
     * @return Supplier__c (inserted with Id)
     */
    public static Supplier__c createAndInsertSupplier() {
        Supplier__c supplier = createSupplier();
        insert supplier;
        return supplier;
    }

    /**
     * Create multiple Suppliers
     * @param count Number of suppliers
     * @return List<Supplier__c> (not inserted)
     */
    public static List<Supplier__c> createSuppliers(Integer count) {
        List<Supplier__c> suppliers = new List<Supplier__c>();
        for (Integer i = 0; i < count; i++) {
            suppliers.add(createSupplier(DEFAULT_SUPPLIER_NAME + ' ' + i));
        }
        return suppliers;
    }

    // ============================================================================
    // COMPLETE SCENARIO FACTORY METHODS
    // ============================================================================

    /**
     * Create a complete test scenario with all related records
     * @return Map<String, List<SObject>> containing all created records
     */
    public static Map<String, List<SObject>> createCompleteScenario() {
        Map<String, List<SObject>> scenario = new Map<String, List<SObject>>();

        // Create and insert suppliers
        List<Supplier__c> suppliers = createSuppliers(2);
        insert suppliers;
        scenario.put('Suppliers', suppliers);

        // Create and insert devices
        List<Device__c> devices = createDevices(5);
        for (Integer i = 0; i < devices.size(); i++) {
            devices[i].Supplier__c = suppliers[Math.mod(i, suppliers.size())].Id;
        }
        insert devices;
        scenario.put('Devices', devices);

        // Create and insert customers
        List<Customer__c> customers = createCustomers(3);
        insert customers;
        scenario.put('Customers', customers);

        // Create and insert orders
        List<Order__c> orders = new List<Order__c>();
        for (Customer__c customer : customers) {
            orders.addAll(createOrders(customer.Id, 2));
        }
        insert orders;
        scenario.put('Orders', orders);

        // Create and insert device orders
        List<Device_Order__c> deviceOrders = new List<Device_Order__c>();
        for (Device__c device : devices) {
            deviceOrders.add(createDeviceOrder(device.Id, 5));
        }
        insert deviceOrders;
        scenario.put('DeviceOrders', deviceOrders);

        return scenario;
    }

    /**
     * Create a minimal test scenario (1 of each)
     * @return Map<String, SObject> containing one of each record type
     */
    public static Map<String, SObject> createMinimalScenario() {
        Map<String, SObject> scenario = new Map<String, SObject>();

        Supplier__c supplier = createAndInsertSupplier();
        scenario.put('Supplier', supplier);

        Device__c device = createDevice();
        device.Supplier__c = supplier.Id;
        insert device;
        scenario.put('Device', device);

        Customer__c customer = createAndInsertCustomer();
        scenario.put('Customer', customer);

        Order__c order = createOrder(customer.Id);
        insert order;
        scenario.put('Order', order);

        Device_Order__c deviceOrder = createDeviceOrder(device.Id, 5);
        insert deviceOrder;
        scenario.put('DeviceOrder', deviceOrder);

        return scenario;
    }
}
