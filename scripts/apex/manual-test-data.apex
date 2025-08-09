// Manual Test Data Creation Script
// This script creates basic test data using only verified fields
// Run this script via: sf apex run --file scripts/apex/manual-test-data.apex --target-org GTP5org

System.debug('=== Starting Manual Test Data Creation ===');

try {
    // Step 1: Create Suppliers (if they exist)
    List<Supplier__c> suppliers = new List<Supplier__c>();
    try {
        suppliers.add(new Supplier__c(Name = 'TechCorp Solutions'));
        suppliers.add(new Supplier__c(Name = 'Digital Innovations Inc'));
        suppliers.add(new Supplier__c(Name = 'Hardware Plus Ltd'));
        insert suppliers;
        System.debug('✅ Created ' + suppliers.size() + ' suppliers successfully');
    } catch (Exception e) {
        System.debug('⚠️ Supplier creation failed: ' + e.getMessage());
    }
    
    // Step 2: Create Customers (if they exist)
    List<Customer__c> customers = new List<Customer__c>();
    try {
        customers.add(new Customer__c(Name = 'Acme Corporation'));
        customers.add(new Customer__c(Name = 'Global Tech Services'));
        customers.add(new Customer__c(Name = 'Innovation Labs'));
        insert customers;
        System.debug('✅ Created ' + customers.size() + ' customers successfully');
    } catch (Exception e) {
        System.debug('⚠️ Customer creation failed: ' + e.getMessage());
    }
    
    // Step 3: Create Devices with only core fields
    List<Device__c> devices = new List<Device__c>();
    
    // Basic devices with minimal fields
    devices.add(new Device__c(
        Name = 'Laptop Pro 15',
        Type__c = 'Computer',
        Stock_Quantity__c = 25,
        Price__c = 1299.99
    ));
    
    devices.add(new Device__c(
        Name = 'Desktop Workstation',
        Type__c = 'Computer', 
        Stock_Quantity__c = 15,
        Price__c = 899.99
    ));
    
    devices.add(new Device__c(
        Name = 'Wireless Mouse',
        Type__c = 'Accessory',
        Stock_Quantity__c = 100,
        Price__c = 29.99
    ));
    
    devices.add(new Device__c(
        Name = 'USB Keyboard',
        Type__c = 'Accessory',
        Stock_Quantity__c = 75,
        Price__c = 49.99
    ));
    
    devices.add(new Device__c(
        Name = 'Network Router',
        Type__c = 'Networking',
        Stock_Quantity__c = 8,
        Price__c = 199.99
    ));
    
    devices.add(new Device__c(
        Name = 'External Monitor',
        Type__c = 'Computer',
        Stock_Quantity__c = 5,
        Price__c = 299.99
    ));
    
    insert devices;
    System.debug('✅ Created ' + devices.size() + ' devices successfully');
    
    // Step 4: Create Device Orders with minimal fields
    List<Device_Order__c> orders = new List<Device_Order__c>();
    
    // Create orders for the devices we just created
    if (devices.size() > 0) {
        orders.add(new Device_Order__c(
            Name = 'ORD-001',
            Device__c = devices[0].Id,
            Quantity__c = 2,
            Status__c = 'Pending'
        ));
        
        orders.add(new Device_Order__c(
            Name = 'ORD-002', 
            Device__c = devices[1].Id,
            Quantity__c = 1,
            Status__c = 'Confirmed'
        ));
        
        orders.add(new Device_Order__c(
            Name = 'ORD-003',
            Device__c = devices[2].Id,
            Quantity__c = 10,
            Status__c = 'Shipped'
        ));
        
        orders.add(new Device_Order__c(
            Name = 'ORD-004',
            Device__c = devices[3].Id,
            Quantity__c = 5,
            Status__c = 'Delivered'
        ));
        
        orders.add(new Device_Order__c(
            Name = 'ORD-005',
            Device__c = devices[4].Id,
            Quantity__c = 1,
            Status__c = 'Pending'
        ));
    }
    
    insert orders;
    System.debug('✅ Created ' + orders.size() + ' orders successfully');
    
    // Step 5: Display summary
    System.debug('=== Test Data Creation Summary ===');
    System.debug('Suppliers: ' + [SELECT COUNT() FROM Supplier__c]);
    System.debug('Customers: ' + [SELECT COUNT() FROM Customer__c]); 
    System.debug('Devices: ' + [SELECT COUNT() FROM Device__c]);
    System.debug('Orders: ' + [SELECT COUNT() FROM Device_Order__c]);
    
    System.debug('=== Manual Test Data Creation Complete ===');
    
} catch (Exception e) {
    System.debug('❌ Error during test data creation: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
