/**
 * SIMPLIFIED AUTOMATED TEST DATA GENERATOR FOR TECHSOLUTIONAPP
 * 
 * This streamlined Apex script generates basic test data using only
 * standard fields that are guaranteed to exist in the org.
 * 
 * EXECUTION ORDER:
 * 1. Suppliers (7 records) - Basic company information
 * 2. Devices (15 records) - Basic device information  
 * 3. Customers (10 records) - Basic customer information
 * 4. Device Orders (20 records) - Basic order information
 */

System.debug('🚀 STARTING SIMPLIFIED AUTOMATED TEST DATA GENERATION');
System.debug('====================================================');

try {
    // ========================================================================
    // PHASE 1: CREATE SUPPLIER RECORDS (7 Records)
    // ========================================================================
    System.debug('📦 PHASE 1: Creating Supplier Records...');
    
    List<Supplier__c> suppliers = new List<Supplier__c>();
    
    suppliers.add(new Supplier__c(Name = 'TechCorp Solutions'));
    suppliers.add(new Supplier__c(Name = 'Global Hardware Inc'));
    suppliers.add(new Supplier__c(Name = 'European Tech Partners'));
    suppliers.add(new Supplier__c(Name = 'Asia Pacific Systems'));
    suppliers.add(new Supplier__c(Name = 'Budget Components Ltd'));
    suppliers.add(new Supplier__c(Name = 'Premium Solutions Group'));
    suppliers.add(new Supplier__c(Name = 'Local Tech Supplies'));
    
    insert suppliers;
    System.debug('✅ Successfully created ' + suppliers.size() + ' Supplier records');
    
    // ========================================================================
    // PHASE 2: CREATE DEVICE RECORDS (15 Records)
    // ========================================================================
    System.debug('💻 PHASE 2: Creating Device Records...');
    
    List<Device__c> devices = new List<Device__c>();
    
    // Hardware Devices
    devices.add(new Device__c(
        Name = 'Dell OptiPlex 7090',
        Type__c = 'Computer',
        Description__c = 'High-performance desktop computer for business use',
        Price__c = 1299.00,
        Stock_Quantity__c = 25,
        Active__c = true
    ));
    
    devices.add(new Device__c(
        Name = 'HP ProLiant DL380',
        Type__c = 'Server',
        Description__c = 'Enterprise-grade rack server for data centers',
        Price__c = 4599.00,
        Stock_Quantity__c = 8,
        Active__c = true
    ));
    
    devices.add(new Device__c(
        Name = 'Cisco Catalyst 2960',
        Type__c = 'Networking',
        Description__c = '24-port managed Ethernet switch',
        Price__c = 899.00,
        Stock_Quantity__c = 3,
        Active__c = true
    ));
    
    devices.add(new Device__c(
        Name = 'Synology DS920+',
        Type__c = 'Storage',
        Description__c = '4-bay NAS storage solution',
        Price__c = 549.00,
        Stock_Quantity__c = 15,
        Active__c = true
    ));
    
    devices.add(new Device__c(
        Name = 'iPad Pro 12.9"',
        Type__c = 'Mobile Device',
        Description__c = 'Professional tablet with M2 chip',
        Price__c = 1099.00,
        Stock_Quantity__c = 12,
        Active__c = true
    ));
    
    // Software Licenses
    devices.add(new Device__c(
        Name = 'Microsoft Office 365',
        Type__c = 'Software',
        Description__c = 'Business productivity suite annual license',
        Price__c = 149.00,
        Stock_Quantity__c = 100,
        Active__c = true
    ));
    
    devices.add(new Device__c(
        Name = 'Adobe Creative Cloud',
        Type__c = 'License',
        Description__c = 'Complete creative software suite license',
        Price__c = 599.00,
        Stock_Quantity__c = 20,
        Active__c = true
    ));
    
    devices.add(new Device__c(
        Name = 'Salesforce Enterprise',
        Type__c = 'Cloud Service',
        Description__c = 'CRM platform enterprise license per user',
        Price__c = 165.00,
        Stock_Quantity__c = 50,
        Active__c = true
    ));
    
    devices.add(new Device__c(
        Name = 'AutoCAD Professional',
        Type__c = 'Digital Asset',
        Description__c = 'Professional CAD software license',
        Price__c = 1775.00,
        Stock_Quantity__c = 10,
        Active__c = true
    ));
    
    devices.add(new Device__c(
        Name = 'Antivirus Enterprise',
        Type__c = 'Software',
        Description__c = 'Enterprise security software per device',
        Price__c = 45.00,
        Stock_Quantity__c = 200,
        Active__c = true
    ));
    
    // Accessories
    devices.add(new Device__c(
        Name = 'USB-C Hub',
        Type__c = 'Accessory',
        Description__c = '7-in-1 USB-C multiport adapter',
        Price__c = 79.00,
        Stock_Quantity__c = 35,
        Active__c = true
    ));
    
    devices.add(new Device__c(
        Name = 'HDMI Cable 6ft',
        Type__c = 'Cable',
        Description__c = 'High-speed HDMI cable with Ethernet',
        Price__c = 24.99,
        Stock_Quantity__c = 75,
        Active__c = true
    ));
    
    devices.add(new Device__c(
        Name = 'Wireless Mouse',
        Type__c = 'Peripheral',
        Description__c = 'Ergonomic wireless optical mouse',
        Price__c = 39.99,
        Stock_Quantity__c = 45,
        Active__c = true
    ));
    
    devices.add(new Device__c(
        Name = 'RAM Module 16GB',
        Type__c = 'Component',
        Description__c = 'DDR4 16GB memory module',
        Price__c = 129.00,
        Stock_Quantity__c = 22,
        Active__c = true
    ));
    
    devices.add(new Device__c(
        Name = 'Printer Toner',
        Type__c = 'Consumable',
        Description__c = 'Black toner cartridge for HP LaserJet',
        Price__c = 89.99,
        Stock_Quantity__c = 18,
        Active__c = true
    ));
    
    insert devices;
    System.debug('✅ Successfully created ' + devices.size() + ' Device records');
    
    // ========================================================================
    // PHASE 3: CREATE CUSTOMER RECORDS (10 Records)
    // ========================================================================
    System.debug('👥 PHASE 3: Creating Customer Records...');
    
    List<Customer__c> customers = new List<Customer__c>();
    
    // Business Customers
    customers.add(new Customer__c(Name = 'Acme Corporation', Type__c = 'Enterprise'));
    customers.add(new Customer__c(Name = 'StartUp Innovations LLC', Type__c = 'Small Business'));
    customers.add(new Customer__c(Name = 'City Government IT Dept', Type__c = 'Government'));
    customers.add(new Customer__c(Name = 'Education Foundation', Type__c = 'Non-Profit'));
    customers.add(new Customer__c(Name = 'Global Manufacturing Inc', Type__c = 'Enterprise'));
    customers.add(new Customer__c(Name = 'Local Consulting Group', Type__c = 'Small Business'));
    
    // Individual Customers
    customers.add(new Customer__c(Name = 'John Smith', Type__c = 'Individual'));
    customers.add(new Customer__c(Name = 'Emily Davis', Type__c = 'Student'));
    customers.add(new Customer__c(Name = 'Robert Johnson', Type__c = 'Senior'));
    customers.add(new Customer__c(Name = 'Sarah Wilson', Type__c = 'Individual'));
    
    insert customers;
    System.debug('✅ Successfully created ' + customers.size() + ' Customer records');
    
    // ========================================================================
    // PHASE 4: CREATE DEVICE ORDER RECORDS (20 Records)
    // ========================================================================
    System.debug('📋 PHASE 4: Creating Device Order Records...');
    
    List<Device_Order__c> orders = new List<Device_Order__c>();
    
    // Create orders with basic fields only
    orders.add(new Device_Order__c(
        Name = 'ORD-001',
        Device__c = devices[0].Id,
        Quantity__c = 5,
        Status__c = 'Delivered'
    ));
    
    orders.add(new Device_Order__c(
        Name = 'ORD-002',
        Device__c = devices[1].Id,
        Quantity__c = 2,
        Status__c = 'Shipped'
    ));
    
    orders.add(new Device_Order__c(
        Name = 'ORD-003',
        Device__c = devices[5].Id,
        Quantity__c = 25,
        Status__c = 'Delivered'
    ));
    
    orders.add(new Device_Order__c(
        Name = 'ORD-004',
        Device__c = devices[4].Id,
        Quantity__c = 1,
        Status__c = 'Delivered'
    ));
    
    orders.add(new Device_Order__c(
        Name = 'ORD-005',
        Device__c = devices[6].Id,
        Quantity__c = 1,
        Status__c = 'Confirmed'
    ));
    
    orders.add(new Device_Order__c(
        Name = 'ORD-006',
        Device__c = devices[7].Id,
        Quantity__c = 15,
        Status__c = 'Delivered'
    ));
    
    orders.add(new Device_Order__c(
        Name = 'ORD-007',
        Device__c = devices[2].Id,
        Quantity__c = 3,
        Status__c = 'Delivered'
    ));
    
    orders.add(new Device_Order__c(
        Name = 'ORD-008',
        Device__c = devices[3].Id,
        Quantity__c = 2,
        Status__c = 'Shipped'
    ));
    
    orders.add(new Device_Order__c(
        Name = 'ORD-009',
        Device__c = devices[8].Id,
        Quantity__c = 5,
        Status__c = 'Delivered'
    ));
    
    orders.add(new Device_Order__c(
        Name = 'ORD-010',
        Device__c = devices[9].Id,
        Quantity__c = 50,
        Status__c = 'Delivered'
    ));
    
    orders.add(new Device_Order__c(
        Name = 'ORD-011',
        Device__c = devices[10].Id,
        Quantity__c = 10,
        Status__c = 'Delivered'
    ));
    
    orders.add(new Device_Order__c(
        Name = 'ORD-012',
        Device__c = devices[11].Id,
        Quantity__c = 20,
        Status__c = 'Delivered'
    ));
    
    orders.add(new Device_Order__c(
        Name = 'ORD-013',
        Device__c = devices[12].Id,
        Quantity__c = 2,
        Status__c = 'Confirmed'
    ));
    
    orders.add(new Device_Order__c(
        Name = 'ORD-014',
        Device__c = devices[13].Id,
        Quantity__c = 8,
        Status__c = 'Delivered'
    ));
    
    orders.add(new Device_Order__c(
        Name = 'ORD-015',
        Device__c = devices[14].Id,
        Quantity__c = 6,
        Status__c = 'Delivered'
    ));
    
    orders.add(new Device_Order__c(
        Name = 'ORD-016',
        Device__c = devices[0].Id,
        Quantity__c = 10,
        Status__c = 'Pending'
    ));
    
    orders.add(new Device_Order__c(
        Name = 'ORD-017',
        Device__c = devices[5].Id,
        Quantity__c = 12,
        Status__c = 'Confirmed'
    ));
    
    orders.add(new Device_Order__c(
        Name = 'ORD-018',
        Device__c = devices[4].Id,
        Quantity__c = 1,
        Status__c = 'Draft'
    ));
    
    orders.add(new Device_Order__c(
        Name = 'ORD-019',
        Device__c = devices[7].Id,
        Quantity__c = 20,
        Status__c = 'Confirmed'
    ));
    
    orders.add(new Device_Order__c(
        Name = 'ORD-020',
        Device__c = devices[9].Id,
        Quantity__c = 75,
        Status__c = 'Shipped'
    ));
    
    insert orders;
    System.debug('✅ Successfully created ' + orders.size() + ' Device Order records');
    
    // ========================================================================
    // VERIFICATION AND SUMMARY
    // ========================================================================
    System.debug('🔍 VERIFICATION: Querying created records...');
    
    List<Supplier__c> verifySuppliers = [SELECT Id, Name FROM Supplier__c];
    List<Device__c> verifyDevices = [SELECT Id, Name, Type__c, Price__c, Stock_Quantity__c FROM Device__c];
    List<Customer__c> verifyCustomers = [SELECT Id, Name, Type__c FROM Customer__c];
    List<Device_Order__c> verifyOrders = [SELECT Id, Name, Status__c FROM Device_Order__c];
    
    System.debug('====================================================');
    System.debug('🎉 SIMPLIFIED TEST DATA GENERATION COMPLETE!');
    System.debug('====================================================');
    
    System.debug('📊 FINAL SUMMARY:');
    System.debug('- Suppliers Created: ' + verifySuppliers.size());
    System.debug('- Devices Created: ' + verifyDevices.size());
    System.debug('- Customers Created: ' + verifyCustomers.size());
    System.debug('- Orders Created: ' + verifyOrders.size());
    System.debug('- Total Records: ' + (verifySuppliers.size() + verifyDevices.size() + verifyCustomers.size() + verifyOrders.size()));
    
    System.debug('✅ SUCCESS! Basic test data created successfully!');
    System.debug('Navigate to the Tech Solutions app to explore the data.');
    System.debug('====================================================');

} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
    throw e;
}
