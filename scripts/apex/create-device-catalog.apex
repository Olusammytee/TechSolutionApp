// Create Comprehensive Device Catalog with Proper Display Names
System.debug('=== Creating Device Catalog ===');

// Get supplier IDs for relationships
List<Supplier__c> suppliers = [SELECT Id, Name FROM Supplier__c ORDER BY Name];
System.debug('Found ' + suppliers.size() + ' suppliers for device relationships');

if (suppliers.isEmpty()) {
    System.debug('ERROR: No suppliers found. Please create suppliers first.');
    return;
}

List<Device__c> devices = new List<Device__c>();

// COMPUTERS - High-value items with varied stock levels
devices.add(new Device__c(
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
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[0].Id // Apple Inc
));

devices.add(new Device__c(
    Name = 'MacBook Air 13-inch M3',
    Type__c = 'Computer',
    Stock_Quantity__c = 8,
    Price__c = 1299.99,
    Cost_Price__c = 999.99,
    Warranty_Period_Months__c = 12,
    Active__c = true,
    Minimum_Stock_Level__c = 10,
    Reorder_Point__c = 15,
    Last_Restocked__c = Date.today().addDays(-25),
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[0].Id // Apple Inc
));

devices.add(new Device__c(
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
    Stock_Status__c = 'Low Stock',
    Supplier__c = suppliers[1].Id // Dell Technologies
));

devices.add(new Device__c(
    Name = 'HP EliteBook 840 G10',
    Type__c = 'Computer',
    Stock_Quantity__c = 0,
    Price__c = 1899.99,
    Cost_Price__c = 1399.99,
    Warranty_Period_Months__c = 12,
    Active__c = true,
    Minimum_Stock_Level__c = 6,
    Reorder_Point__c = 10,
    Last_Restocked__c = Date.today().addDays(-60),
    Stock_Status__c = 'Out of Stock',
    Supplier__c = suppliers[2].Id // HP Enterprise
));

// SERVERS - Enterprise equipment
devices.add(new Device__c(
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
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[1].Id // Dell Technologies
));

devices.add(new Device__c(
    Name = 'HP ProLiant DL380 Gen11',
    Type__c = 'Server',
    Stock_Quantity__c = 2,
    Price__c = 3799.99,
    Cost_Price__c = 2999.99,
    Warranty_Period_Months__c = 36,
    Active__c = true,
    Minimum_Stock_Level__c = 3,
    Reorder_Point__c = 5,
    Last_Restocked__c = Date.today().addDays(-40),
    Stock_Status__c = 'Low Stock',
    Supplier__c = suppliers[2].Id // HP Enterprise
));

// NETWORKING - Infrastructure equipment
devices.add(new Device__c(
    Name = 'Cisco Catalyst 9300 Switch',
    Type__c = 'Networking',
    Stock_Quantity__c = 15,
    Price__c = 3299.99,
    Cost_Price__c = 2499.99,
    Warranty_Period_Months__c = 24,
    Active__c = true,
    Minimum_Stock_Level__c = 5,
    Reorder_Point__c = 8,
    Last_Restocked__c = Date.today().addDays(-20),
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[3].Id // Cisco Systems
));

devices.add(new Device__c(
    Name = 'Cisco ASA 5516-X Firewall',
    Type__c = 'Networking',
    Stock_Quantity__c = 4,
    Price__c = 2899.99,
    Cost_Price__c = 2199.99,
    Warranty_Period_Months__c = 24,
    Active__c = true,
    Minimum_Stock_Level__c = 3,
    Reorder_Point__c = 5,
    Last_Restocked__c = Date.today().addDays(-35),
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[3].Id // Cisco Systems
));

// MOBILE DEVICES - Consumer electronics
devices.add(new Device__c(
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
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[0].Id // Apple Inc
));

devices.add(new Device__c(
    Name = 'Samsung Galaxy S24 Ultra',
    Type__c = 'Mobile Device',
    Stock_Quantity__c = 2,
    Price__c = 1299.99,
    Cost_Price__c = 999.99,
    Warranty_Period_Months__c = 12,
    Active__c = true,
    Minimum_Stock_Level__c = 10,
    Reorder_Point__c = 15,
    Last_Restocked__c = Date.today().addDays(-50),
    Stock_Status__c = 'Low Stock',
    Supplier__c = suppliers[5].Id // Samsung Electronics
));

devices.add(new Device__c(
    Name = 'iPad Pro 12.9-inch M4',
    Type__c = 'Mobile Device',
    Stock_Quantity__c = 18,
    Price__c = 1099.99,
    Cost_Price__c = 799.99,
    Warranty_Period_Months__c = 12,
    Active__c = true,
    Minimum_Stock_Level__c = 8,
    Reorder_Point__c = 12,
    Last_Restocked__c = Date.today().addDays(-12),
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[0].Id // Apple Inc
));

// SOFTWARE - Digital products
devices.add(new Device__c(
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
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[4].Id // Microsoft Corp
));

devices.add(new Device__c(
    Name = 'Adobe Creative Cloud All Apps',
    Type__c = 'Software',
    Stock_Quantity__c = 25,
    Price__c = 659.88,
    Cost_Price__c = 499.99,
    Warranty_Period_Months__c = 12,
    Active__c = true,
    Minimum_Stock_Level__c = 20,
    Reorder_Point__c = 30,
    Last_Restocked__c = Date.today().addDays(-18),
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[7].Id // Adobe Systems
));

devices.add(new Device__c(
    Name = 'Windows 11 Pro License',
    Type__c = 'License',
    Stock_Quantity__c = 5,
    Price__c = 199.99,
    Cost_Price__c = 149.99,
    Warranty_Period_Months__c = 0,
    Active__c = true,
    Minimum_Stock_Level__c = 25,
    Reorder_Point__c = 35,
    Last_Restocked__c = Date.today().addDays(-55),
    Stock_Status__c = 'Low Stock',
    Supplier__c = suppliers[4].Id // Microsoft Corp
));

// STORAGE - Data storage solutions
devices.add(new Device__c(
    Name = 'Samsung 2TB NVMe SSD 980 PRO',
    Type__c = 'Storage',
    Stock_Quantity__c = 30,
    Price__c = 199.99,
    Cost_Price__c = 149.99,
    Warranty_Period_Months__c = 60,
    Active__c = true,
    Minimum_Stock_Level__c = 20,
    Reorder_Point__c = 25,
    Last_Restocked__c = Date.today().addDays(-14),
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[5].Id // Samsung Electronics
));

devices.add(new Device__c(
    Name = 'Dell EMC PowerVault ME5012',
    Type__c = 'Storage',
    Stock_Quantity__c = 1,
    Price__c = 8999.99,
    Cost_Price__c = 6999.99,
    Warranty_Period_Months__c = 36,
    Active__c = true,
    Minimum_Stock_Level__c = 2,
    Reorder_Point__c = 3,
    Last_Restocked__c = Date.today().addDays(-70),
    Stock_Status__c = 'Low Stock',
    Supplier__c = suppliers[1].Id // Dell Technologies
));

// ACCESSORIES - Peripherals and accessories
devices.add(new Device__c(
    Name = 'Logitech MX Master 3S Mouse',
    Type__c = 'Accessory',
    Stock_Quantity__c = 45,
    Price__c = 99.99,
    Cost_Price__c = 69.99,
    Warranty_Period_Months__c = 24,
    Active__c = true,
    Minimum_Stock_Level__c = 25,
    Reorder_Point__c = 35,
    Last_Restocked__c = Date.today().addDays(-7),
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[6].Id // Logitech International
));

devices.add(new Device__c(
    Name = 'Logitech MX Keys Advanced Keyboard',
    Type__c = 'Peripheral',
    Stock_Quantity__c = 22,
    Price__c = 109.99,
    Cost_Price__c = 79.99,
    Warranty_Period_Months__c = 24,
    Active__c = true,
    Minimum_Stock_Level__c = 15,
    Reorder_Point__c = 20,
    Last_Restocked__c = Date.today().addDays(-16),
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[6].Id // Logitech International
));

devices.add(new Device__c(
    Name = 'Dell UltraSharp 32" 4K Monitor',
    Type__c = 'Peripheral',
    Stock_Quantity__c = 8,
    Price__c = 799.99,
    Cost_Price__c = 599.99,
    Warranty_Period_Months__c = 36,
    Active__c = true,
    Minimum_Stock_Level__c = 6,
    Reorder_Point__c = 10,
    Last_Restocked__c = Date.today().addDays(-22),
    Stock_Status__c = 'In Stock',
    Supplier__c = suppliers[1].Id // Dell Technologies
));

devices.add(new Device__c(
    Name = 'USB-C Multiport Hub Pro',
    Type__c = 'Accessory',
    Stock_Quantity__c = 1,
    Price__c = 89.99,
    Cost_Price__c = 59.99,
    Warranty_Period_Months__c = 12,
    Active__c = true,
    Minimum_Stock_Level__c = 20,
    Reorder_Point__c = 30,
    Last_Restocked__c = Date.today().addDays(-65),
    Stock_Status__c = 'Low Stock',
    Supplier__c = suppliers[0].Id // Apple Inc
));

devices.add(new Device__c(
    Name = 'Premium HDMI Cable 6ft',
    Type__c = 'Cable',
    Stock_Quantity__c = 0,
    Price__c = 29.99,
    Cost_Price__c = 19.99,
    Warranty_Period_Months__c = 12,
    Active__c = true,
    Minimum_Stock_Level__c = 50,
    Reorder_Point__c = 75,
    Last_Restocked__c = Date.today().addDays(-80),
    Stock_Status__c = 'Out of Stock',
    Supplier__c = suppliers[6].Id // Logitech International
));

try {
    insert devices;
    System.debug('Successfully created ' + devices.size() + ' Device records');
    
    // Analyze stock distribution
    Integer inStock = 0, lowStock = 0, outOfStock = 0;
    for (Device__c device : devices) {
        if (device.Stock_Status__c == 'In Stock') inStock++;
        else if (device.Stock_Status__c == 'Low Stock') lowStock++;
        else if (device.Stock_Status__c == 'Out of Stock') outOfStock++;
    }
    
    System.debug('=== DEVICE INVENTORY SUMMARY ===');
    System.debug('Total Devices: ' + devices.size());
    System.debug('In Stock: ' + inStock + ' devices (' + (inStock * 100 / devices.size()) + '%)');
    System.debug('Low Stock: ' + lowStock + ' devices (' + (lowStock * 100 / devices.size()) + '%)');
    System.debug('Out of Stock: ' + outOfStock + ' devices (' + (outOfStock * 100 / devices.size()) + '%)');
    
} catch (Exception e) {
    System.debug('ERROR creating devices: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== Device Catalog Creation Complete ===');
