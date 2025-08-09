// Ensure All Data Visible - Create Missing Records and Fix Visibility
System.debug('=== ENSURE ALL DATA VISIBLE ===');

try {
    // 1. CHECK CURRENT RECORD COUNTS
    System.debug('=== 1. CHECK CURRENT RECORD COUNTS ===');
    
    Integer deviceCount = [SELECT COUNT() FROM Device__c];
    Integer customerCount = [SELECT COUNT() FROM Customer__c];
    Integer supplierCount = [SELECT COUNT() FROM Supplier__c];
    Integer orderCount = [SELECT COUNT() FROM Device_Order__c];
    
    System.debug('Current Record Counts:');
    System.debug('  Devices: ' + deviceCount);
    System.debug('  Customers: ' + customerCount);
    System.debug('  Suppliers: ' + supplierCount);
    System.debug('  Orders: ' + orderCount);
    
    // 2. CREATE MISSING SUPPLIERS IF NEEDED
    System.debug('=== 2. CREATE MISSING SUPPLIERS IF NEEDED ===');
    
    if (supplierCount < 6) {
        List<Supplier__c> newSuppliers = new List<Supplier__c>();
        
        newSuppliers.add(new Supplier__c(
            Name = 'Apple Inc',
            Company_Name__c = 'Apple Inc.',
            Contact_Person__c = 'Tim Cook',
            Email__c = 'business@apple.com',
            Phone__c = '+1-408-996-1010',
            Country__c = 'United States',
            Supplier_Rating__c = 'Excellent',
            Active__c = true
        ));
        
        newSuppliers.add(new Supplier__c(
            Name = 'Dell Technologies',
            Company_Name__c = 'Dell Technologies Inc.',
            Contact_Person__c = 'Michael Dell',
            Email__c = 'enterprise@dell.com',
            Phone__c = '+1-512-338-4400',
            Country__c = 'United States',
            Supplier_Rating__c = 'Excellent',
            Active__c = true
        ));
        
        newSuppliers.add(new Supplier__c(
            Name = 'Microsoft Corp',
            Company_Name__c = 'Microsoft Corporation',
            Contact_Person__c = 'Satya Nadella',
            Email__c = 'business@microsoft.com',
            Phone__c = '+1-425-882-8080',
            Country__c = 'United States',
            Supplier_Rating__c = 'Excellent',
            Active__c = true
        ));
        
        newSuppliers.add(new Supplier__c(
            Name = 'Samsung Electronics',
            Company_Name__c = 'Samsung Electronics Co Ltd',
            Contact_Person__c = 'Jong-Hee Han',
            Email__c = 'b2b@samsung.com',
            Phone__c = '+82-2-2255-0114',
            Country__c = 'South Korea',
            Supplier_Rating__c = 'Good',
            Active__c = true
        ));
        
        newSuppliers.add(new Supplier__c(
            Name = 'Cisco Systems',
            Company_Name__c = 'Cisco Systems Inc.',
            Contact_Person__c = 'Chuck Robbins',
            Email__c = 'enterprise@cisco.com',
            Phone__c = '+1-408-526-4000',
            Country__c = 'United States',
            Supplier_Rating__c = 'Excellent',
            Active__c = true
        ));
        
        newSuppliers.add(new Supplier__c(
            Name = 'HP Enterprise',
            Company_Name__c = 'Hewlett Packard Enterprise',
            Contact_Person__c = 'Antonio Neri',
            Email__c = 'sales@hpe.com',
            Phone__c = '+1-650-857-1501',
            Country__c = 'United States',
            Supplier_Rating__c = 'Good',
            Active__c = true
        ));
        
        insert newSuppliers;
        System.debug('✅ Created ' + newSuppliers.size() + ' new Supplier records');
    } else {
        System.debug('✅ Sufficient Supplier records exist');
    }
    
    // 3. CREATE MISSING CUSTOMERS IF NEEDED
    System.debug('=== 3. CREATE MISSING CUSTOMERS IF NEEDED ===');
    
    if (customerCount < 8) {
        List<Customer__c> newCustomers = new List<Customer__c>();
        
        newCustomers.add(new Customer__c(
            Name = 'Acme Corporation',
            Email__c = 'procurement@acmecorp.com',
            Phone__c = '+1-555-0101',
            Address__c = '123 Business Plaza, New York, NY 10001',
            Customer_Type__c = 'Enterprise',
            Customer_Status__c = 'VIP',
            Credit_Limit__c = 100000
        ));
        
        newCustomers.add(new Customer__c(
            Name = 'TechStart Innovations',
            Email__c = 'orders@techstart.com',
            Phone__c = '+1-555-0102',
            Address__c = '456 Innovation Drive, San Francisco, CA 94105',
            Customer_Type__c = 'Small Business',
            Customer_Status__c = 'Active',
            Credit_Limit__c = 25000
        ));
        
        newCustomers.add(new Customer__c(
            Name = 'Global Enterprises Ltd',
            Email__c = 'purchasing@globalent.com',
            Phone__c = '+1-555-0103',
            Address__c = '789 Corporate Center, Chicago, IL 60601',
            Customer_Type__c = 'Enterprise',
            Customer_Status__c = 'VIP',
            Credit_Limit__c = 150000
        ));
        
        newCustomers.add(new Customer__c(
            Name = 'City University',
            Email__c = 'it-procurement@cityuni.edu',
            Phone__c = '+1-555-0104',
            Address__c = '321 Campus Boulevard, Boston, MA 02101',
            Customer_Type__c = 'Government',
            Customer_Status__c = 'Active',
            Credit_Limit__c = 75000
        ));
        
        newCustomers.add(new Customer__c(
            Name = 'Healthcare Systems Inc',
            Email__c = 'technology@healthsys.com',
            Phone__c = '+1-555-0105',
            Address__c = '654 Medical Plaza, Miami, FL 33101',
            Customer_Type__c = 'Enterprise',
            Customer_Status__c = 'Active',
            Credit_Limit__c = 80000
        ));
        
        newCustomers.add(new Customer__c(
            Name = 'John Smith',
            Email__c = 'john.smith@email.com',
            Phone__c = '+1-555-0106',
            Address__c = '147 Residential Street, Austin, TX 78701',
            Customer_Type__c = 'Individual',
            Customer_Status__c = 'Active',
            Credit_Limit__c = 5000
        ));
        
        newCustomers.add(new Customer__c(
            Name = 'Creative Agency Pro',
            Email__c = 'admin@creativeagency.com',
            Phone__c = '+1-555-0107',
            Address__c = '258 Design District, Los Angeles, CA 90210',
            Customer_Type__c = 'Small Business',
            Customer_Status__c = 'Active',
            Credit_Limit__c = 30000
        ));
        
        newCustomers.add(new Customer__c(
            Name = 'Manufacturing Corp',
            Email__c = 'it@manufacturing.com',
            Phone__c = '+1-555-0108',
            Address__c = '369 Industrial Way, Detroit, MI 48201',
            Customer_Type__c = 'Enterprise',
            Customer_Status__c = 'Prospect',
            Credit_Limit__c = 120000
        ));
        
        insert newCustomers;
        System.debug('✅ Created ' + newCustomers.size() + ' new Customer records');
    } else {
        System.debug('✅ Sufficient Customer records exist');
    }
    
    // 4. CREATE MISSING DEVICES IF NEEDED
    System.debug('=== 4. CREATE MISSING DEVICES IF NEEDED ===');
    
    List<Supplier__c> suppliers = [SELECT Id, Name FROM Supplier__c LIMIT 10];
    
    if (deviceCount < 15 && !suppliers.isEmpty()) {
        List<Device__c> newDevices = new List<Device__c>();
        
        newDevices.add(new Device__c(
            Name = 'MacBook Pro 16-inch M3 Max',
            Type__c = 'Computer',
            Stock_Quantity__c = 12,
            Price__c = 3999.99,
            Cost_Price__c = 3199.99,
            Warranty_Period_Months__c = 12,
            Active__c = true,
            Minimum_Stock_Level__c = 5,
            Reorder_Point__c = 8,
            Last_Restocked__c = Date.today().addDays(-10),
            Supplier__c = suppliers[0].Id
        ));
        
        newDevices.add(new Device__c(
            Name = 'Dell XPS 13 Plus Laptop',
            Type__c = 'Computer',
            Stock_Quantity__c = 3,
            Price__c = 1599.99,
            Cost_Price__c = 1199.99,
            Warranty_Period_Months__c = 12,
            Active__c = true,
            Minimum_Stock_Level__c = 8,
            Reorder_Point__c = 12,
            Last_Restocked__c = Date.today().addDays(-45),
            Supplier__c = suppliers[1].Id
        ));
        
        newDevices.add(new Device__c(
            Name = 'iPhone 15 Pro Max 256GB',
            Type__c = 'Mobile Device',
            Stock_Quantity__c = 25,
            Price__c = 1199.99,
            Cost_Price__c = 899.99,
            Warranty_Period_Months__c = 12,
            Active__c = true,
            Minimum_Stock_Level__c = 15,
            Reorder_Point__c = 20,
            Last_Restocked__c = Date.today().addDays(-5),
            Supplier__c = suppliers[0].Id
        ));
        
        newDevices.add(new Device__c(
            Name = 'Microsoft Office 365 Business Premium',
            Type__c = 'Software',
            Stock_Quantity__c = 100,
            Price__c = 264.00,
            Cost_Price__c = 199.00,
            Warranty_Period_Months__c = 12,
            Active__c = true,
            Minimum_Stock_Level__c = 50,
            Reorder_Point__c = 75,
            Last_Restocked__c = Date.today().addDays(-8),
            Supplier__c = suppliers[2].Id
        ));
        
        newDevices.add(new Device__c(
            Name = 'Dell PowerEdge R750 Server',
            Type__c = 'Server',
            Stock_Quantity__c = 6,
            Price__c = 4999.99,
            Cost_Price__c = 3999.99,
            Warranty_Period_Months__c = 36,
            Active__c = true,
            Minimum_Stock_Level__c = 2,
            Reorder_Point__c = 4,
            Last_Restocked__c = Date.today().addDays(-15),
            Supplier__c = suppliers[1].Id
        ));
        
        insert newDevices;
        System.debug('✅ Created ' + newDevices.size() + ' new Device records');
    } else {
        System.debug('✅ Sufficient Device records exist');
    }
    
    // 5. CREATE MISSING ORDERS IF NEEDED
    System.debug('=== 5. CREATE MISSING ORDERS IF NEEDED ===');
    
    List<Customer__c> customers = [SELECT Id, Name FROM Customer__c LIMIT 10];
    List<Device__c> devices = [SELECT Id, Name, Price__c FROM Device__c LIMIT 10];
    
    if (orderCount < 20 && !customers.isEmpty() && !devices.isEmpty()) {
        List<Device_Order__c> newOrders = new List<Device_Order__c>();
        Date today = Date.today();
        
        newOrders.add(new Device_Order__c(
            Device__c = devices[0].Id,
            Customer__c = customers[0].Id,
            Quantity__c = 3,
            Status__c = 'Confirmed',
            Priority__c = 'High',
            Order_Date__c = today.addDays(-1),
            Expected_Delivery_Date__c = today.addDays(5),
            Discount_Percentage__c = 10.0
        ));
        
        newOrders.add(new Device_Order__c(
            Device__c = devices[1].Id,
            Customer__c = customers[1].Id,
            Quantity__c = 5,
            Status__c = 'Shipped',
            Priority__c = 'Medium',
            Order_Date__c = today.addDays(-2),
            Expected_Delivery_Date__c = today.addDays(3),
            Discount_Percentage__c = 5.0
        ));
        
        newOrders.add(new Device_Order__c(
            Device__c = devices[2].Id,
            Customer__c = customers[2].Id,
            Quantity__c = 1,
            Status__c = 'Delivered',
            Priority__c = 'Low',
            Order_Date__c = today.addDays(-5),
            Expected_Delivery_Date__c = today.addDays(-1),
            Discount_Percentage__c = 0.0
        ));
        
        insert newOrders;
        System.debug('✅ Created ' + newOrders.size() + ' new Order records');
    } else {
        System.debug('✅ Sufficient Order records exist');
    }
    
    // 6. FINAL RECORD COUNT VERIFICATION
    System.debug('=== 6. FINAL RECORD COUNT VERIFICATION ===');
    
    deviceCount = [SELECT COUNT() FROM Device__c];
    customerCount = [SELECT COUNT() FROM Customer__c];
    supplierCount = [SELECT COUNT() FROM Supplier__c];
    orderCount = [SELECT COUNT() FROM Device_Order__c];
    
    System.debug('Final Record Counts:');
    System.debug('  Devices: ' + deviceCount);
    System.debug('  Customers: ' + customerCount);
    System.debug('  Suppliers: ' + supplierCount);
    System.debug('  Orders: ' + orderCount);
    System.debug('  TOTAL: ' + (deviceCount + customerCount + supplierCount + orderCount));
    
    // 7. PROVIDE SAMPLE RECORDS FOR UI TESTING
    System.debug('=== 7. SAMPLE RECORDS FOR UI TESTING ===');
    
    List<Device__c> sampleDevices = [SELECT Id, Name FROM Device__c LIMIT 3];
    System.debug('Sample Devices for UI Testing:');
    for (Device__c device : sampleDevices) {
        System.debug('  ' + device.Name + ' - /lightning/r/Device__c/' + device.Id + '/view');
    }
    
    List<Customer__c> sampleCustomers = [SELECT Id, Name FROM Customer__c LIMIT 3];
    System.debug('Sample Customers for UI Testing:');
    for (Customer__c customer : sampleCustomers) {
        System.debug('  ' + customer.Name + ' - /lightning/r/Customer__c/' + customer.Id + '/view');
    }
    
    List<Supplier__c> sampleSuppliers = [SELECT Id, Name FROM Supplier__c LIMIT 3];
    System.debug('Sample Suppliers for UI Testing:');
    for (Supplier__c supplier : sampleSuppliers) {
        System.debug('  ' + supplier.Name + ' - /lightning/r/Supplier__c/' + supplier.Id + '/view');
    }
    
    List<Device_Order__c> sampleOrders = [SELECT Id, Name FROM Device_Order__c LIMIT 3];
    System.debug('Sample Orders for UI Testing:');
    for (Device_Order__c order : sampleOrders) {
        System.debug('  ' + order.Name + ' - /lightning/r/Device_Order__c/' + order.Id + '/view');
    }
    
    System.debug('=== ENSURE ALL DATA VISIBLE COMPLETE ===');
    
} catch (Exception e) {
    System.debug('ERROR ensuring data visibility: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== ENSURE ALL DATA VISIBLE COMPLETE ===');
