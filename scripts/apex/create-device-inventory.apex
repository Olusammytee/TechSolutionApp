// Create comprehensive Device inventory with supplier relationships
System.debug('=== Creating Device Inventory ===');

// Get supplier IDs for relationships
List<Supplier__c> suppliers = [SELECT Id, Name FROM Supplier__c LIMIT 10];
System.debug('Found ' + suppliers.size() + ' suppliers for device relationships');

if (suppliers.isEmpty()) {
    System.debug('ERROR: No suppliers found. Please create suppliers first.');
    return;
}

List<Device__c> devices = new List<Device__c>();

// Hardware Devices (High-value items)
devices.add(new Device__c(
    Name = 'MacBook Pro 16"',
    Type__c = 'Computer',
    Stock_Quantity__c = 15,
    Price__c = 2499.99,
    Cost_Price__c = 1999.99,
    Warranty_Period_Months__c = 12,
    Active__c = true,
    Minimum_Stock_Level__c = 5,
    Reorder_Point__c = 8,
    Last_Restocked__c = Date.today().addDays(-15),
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[0].Id
));

devices.add(new Device__c(
    Name = 'Dell XPS 13 Laptop',
    Type__c = 'Computer',
    Stock_Quantity__c = 3,
    Price__c = 1299.99,
    Cost_Price__c = 999.99,
    Warranty_Period_Months__c = 12,
    Active__c = true,
    Minimum_Stock_Level__c = 5,
    Reorder_Point__c = 8,
    Last_Restocked__c = Date.today().addDays(-45),
    Stock_Status__c = 'Low Stock',
    Supplier__c = suppliers[1].Id
));

devices.add(new Device__c(
    Name = 'HP EliteBook 840',
    Type__c = 'Computer',
    Stock_Quantity__c = 0,
    Price__c = 1599.99,
    Cost_Price__c = 1199.99,
    Warranty_Period_Months__c = 12,
    Active__c = true,
    Minimum_Stock_Level__c = 5,
    Reorder_Point__c = 8,
    Last_Restocked__c = Date.today().addDays(-60),
    Stock_Status__c = 'Out of Stock',
    Supplier__c = suppliers[2].Id
));

devices.add(new Device__c(
    Name = 'Dell PowerEdge R750',
    Type__c = 'Server',
    Stock_Quantity__c = 8,
    Price__c = 4999.99,
    Cost_Price__c = 3999.99,
    Warranty_Period_Months__c = 36,
    Active__c = true,
    Minimum_Stock_Level__c = 2,
    Reorder_Point__c = 3,
    Last_Restocked__c = Date.today().addDays(-10),
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[0].Id
));

devices.add(new Device__c(
    Name = 'Cisco Catalyst 9300',
    Type__c = 'Networking',
    Stock_Quantity__c = 12,
    Price__c = 3299.99,
    Cost_Price__c = 2499.99,
    Warranty_Period_Months__c = 24,
    Active__c = true,
    Minimum_Stock_Level__c = 3,
    Reorder_Point__c = 5,
    Last_Restocked__c = Date.today().addDays(-20),
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[1].Id
));

devices.add(new Device__c(
    Name = 'iPhone 15 Pro',
    Type__c = 'Mobile Device',
    Stock_Quantity__c = 25,
    Price__c = 999.99,
    Cost_Price__c = 749.99,
    Warranty_Period_Months__c = 12,
    Active__c = true,
    Minimum_Stock_Level__c = 10,
    Reorder_Point__c = 15,
    Last_Restocked__c = Date.today().addDays(-5),
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[2].Id
));

devices.add(new Device__c(
    Name = 'Samsung Galaxy S24',
    Type__c = 'Mobile Device',
    Stock_Quantity__c = 2,
    Price__c = 899.99,
    Cost_Price__c = 679.99,
    Warranty_Period_Months__c = 12,
    Active__c = true,
    Minimum_Stock_Level__c = 8,
    Reorder_Point__c = 12,
    Last_Restocked__c = Date.today().addDays(-30),
    Stock_Status__c = 'Low Stock',
    Supplier__c = suppliers[3].Id
));

// Software and Licenses
devices.add(new Device__c(
    Name = 'Microsoft Office 365',
    Type__c = 'Software',
    Stock_Quantity__c = 100,
    Price__c = 149.99,
    Cost_Price__c = 99.99,
    Warranty_Period_Months__c = 12,
    Active__c = true,
    Minimum_Stock_Level__c = 20,
    Reorder_Point__c = 30,
    Last_Restocked__c = Date.today().addDays(-7),
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[0].Id
));

devices.add(new Device__c(
    Name = 'Adobe Creative Suite',
    Type__c = 'Software',
    Stock_Quantity__c = 15,
    Price__c = 599.99,
    Cost_Price__c = 449.99,
    Warranty_Period_Months__c = 12,
    Active__c = true,
    Minimum_Stock_Level__c = 10,
    Reorder_Point__c = 15,
    Last_Restocked__c = Date.today().addDays(-25),
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[1].Id
));

devices.add(new Device__c(
    Name = 'Salesforce Enterprise',
    Type__c = 'License',
    Stock_Quantity__c = 5,
    Price__c = 1999.99,
    Cost_Price__c = 1499.99,
    Warranty_Period_Months__c = 12,
    Active__c = true,
    Minimum_Stock_Level__c = 10,
    Reorder_Point__c = 15,
    Last_Restocked__c = Date.today().addDays(-40),
    Stock_Status__c = 'Low Stock',
    Supplier__c = suppliers[2].Id
));

// Storage and Accessories
devices.add(new Device__c(
    Name = 'SanDisk 2TB SSD',
    Type__c = 'Storage',
    Stock_Quantity__c = 30,
    Price__c = 199.99,
    Cost_Price__c = 149.99,
    Warranty_Period_Months__c = 60,
    Active__c = true,
    Minimum_Stock_Level__c = 15,
    Reorder_Point__c = 20,
    Last_Restocked__c = Date.today().addDays(-12),
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[3].Id
));

devices.add(new Device__c(
    Name = 'Logitech MX Master 3',
    Type__c = 'Accessory',
    Stock_Quantity__c = 45,
    Price__c = 99.99,
    Cost_Price__c = 69.99,
    Warranty_Period_Months__c = 24,
    Active__c = true,
    Minimum_Stock_Level__c = 20,
    Reorder_Point__c = 25,
    Last_Restocked__c = Date.today().addDays(-8),
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[4].Id
));

devices.add(new Device__c(
    Name = 'USB-C Hub Pro',
    Type__c = 'Accessory',
    Stock_Quantity__c = 1,
    Price__c = 79.99,
    Cost_Price__c = 49.99,
    Warranty_Period_Months__c = 12,
    Active__c = true,
    Minimum_Stock_Level__c = 15,
    Reorder_Point__c = 20,
    Last_Restocked__c = Date.today().addDays(-50),
    Stock_Status__c = 'Low Stock',
    Supplier__c = suppliers[5].Id
));

devices.add(new Device__c(
    Name = 'HDMI Cable 6ft',
    Type__c = 'Cable',
    Stock_Quantity__c = 0,
    Price__c = 19.99,
    Cost_Price__c = 9.99,
    Warranty_Period_Months__c = 12,
    Active__c = true,
    Minimum_Stock_Level__c = 25,
    Reorder_Point__c = 30,
    Last_Restocked__c = Date.today().addDays(-35),
    Stock_Status__c = 'Out of Stock',
    Supplier__c = suppliers[0].Id
));

devices.add(new Device__c(
    Name = 'Wireless Keyboard',
    Type__c = 'Peripheral',
    Stock_Quantity__c = 18,
    Price__c = 129.99,
    Cost_Price__c = 89.99,
    Warranty_Period_Months__c = 24,
    Active__c = true,
    Minimum_Stock_Level__c = 10,
    Reorder_Point__c = 15,
    Last_Restocked__c = Date.today().addDays(-18),
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[1].Id
));

// High-end specialized equipment
devices.add(new Device__c(
    Name = 'MacBook Pro M3 Max',
    Type__c = 'Computer',
    Stock_Quantity__c = 6,
    Price__c = 3999.99,
    Cost_Price__c = 3199.99,
    Warranty_Period_Months__c = 12,
    Active__c = true,
    Minimum_Stock_Level__c = 3,
    Reorder_Point__c = 5,
    Last_Restocked__c = Date.today().addDays(-22),
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[2].Id
));

devices.add(new Device__c(
    Name = 'Dell UltraSharp 32" 4K',
    Type__c = 'Peripheral',
    Stock_Quantity__c = 8,
    Price__c = 799.99,
    Cost_Price__c = 599.99,
    Warranty_Period_Months__c = 36,
    Active__c = true,
    Minimum_Stock_Level__c = 5,
    Reorder_Point__c = 8,
    Last_Restocked__c = Date.today().addDays(-14),
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[3].Id
));

devices.add(new Device__c(
    Name = 'Printer Toner Cartridge',
    Type__c = 'Consumable',
    Stock_Quantity__c = 2,
    Price__c = 89.99,
    Cost_Price__c = 59.99,
    Warranty_Period_Months__c = 6,
    Active__c = true,
    Minimum_Stock_Level__c = 12,
    Reorder_Point__c = 18,
    Last_Restocked__c = Date.today().addDays(-28),
    Stock_Status__c = 'Low Stock',
    Supplier__c = suppliers[4].Id
));

devices.add(new Device__c(
    Name = 'Network Security Appliance',
    Type__c = 'Networking',
    Stock_Quantity__c = 4,
    Price__c = 2999.99,
    Cost_Price__c = 2299.99,
    Warranty_Period_Months__c = 24,
    Active__c = true,
    Minimum_Stock_Level__c = 2,
    Reorder_Point__c = 3,
    Last_Restocked__c = Date.today().addDays(-33),
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[5].Id
));

devices.add(new Device__c(
    Name = 'Cloud Storage 1TB',
    Type__c = 'Cloud Service',
    Stock_Quantity__c = 50,
    Price__c = 99.99,
    Cost_Price__c = 69.99,
    Warranty_Period_Months__c = 12,
    Active__c = true,
    Minimum_Stock_Level__c = 25,
    Reorder_Point__c = 35,
    Last_Restocked__c = Date.today().addDays(-6),
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[0].Id
));

try {
    insert devices;
    System.debug('Successfully created ' + devices.size() + ' Device records');
    
    // Verify stock status distribution
    Integer inStock = 0, lowStock = 0, outOfStock = 0;
    for (Device__c device : devices) {
        if (device.Stock_Status__c == 'In Stock') inStock++;
        else if (device.Stock_Status__c == 'Low Stock') lowStock++;
        else if (device.Stock_Status__c == 'Out of Stock') outOfStock++;
    }
    
    System.debug('=== INVENTORY DISTRIBUTION ===');
    System.debug('In Stock: ' + inStock + ' devices');
    System.debug('Low Stock: ' + lowStock + ' devices');
    System.debug('Out of Stock: ' + outOfStock + ' devices');
    
} catch (Exception e) {
    System.debug('ERROR creating devices: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== Device Inventory Creation Complete ===');
