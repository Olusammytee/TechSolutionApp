// Create Comprehensive Order Analytics Data - 90 Day History
System.debug('=== Creating Order Analytics Data ===');

// Get Customer and Device IDs for relationships
List<Customer__c> customers = [SELECT Id, Name FROM Customer__c ORDER BY Name];
List<Device__c> devices = [SELECT Id, Name, Price__c FROM Device__c ORDER BY Name];

System.debug('Found ' + customers.size() + ' customers and ' + devices.size() + ' devices');

if (customers.isEmpty() || devices.isEmpty()) {
    System.debug('ERROR: Need customers and devices first. Please create them.');
    return;
}

List<Device_Order__c> orders = new List<Device_Order__c>();
Date today = Date.today();

// RECENT ORDERS (Last 7 days) - Higher activity
orders.add(new Device_Order__c(
    Device__c = devices[0].Id, // MacBook Pro 16-inch M3 Max
    Customer__c = customers[0].Id, // Acme Corporation
    Quantity__c = 3,
    Status__c = 'Confirmed',
    Priority__c = 'High',
    Order_Date__c = today.addDays(-1),
    Expected_Delivery_Date__c = today.addDays(5),
    Discount_Percentage__c = 10.0
));

orders.add(new Device_Order__c(
    Device__c = devices[9].Id, // iPhone 15 Pro Max
    Customer__c = customers[1].Id, // TechStart Innovations
    Quantity__c = 5,
    Status__c = 'Shipped',
    Priority__c = 'Medium',
    Order_Date__c = today.addDays(-2),
    Expected_Delivery_Date__c = today.addDays(3),
    Discount_Percentage__c = 5.0
));

orders.add(new Device_Order__c(
    Device__c = devices[12].Id, // Microsoft Office 365
    Customer__c = customers[2].Id, // Global Enterprises Ltd
    Quantity__c = 50,
    Status__c = 'Delivered',
    Priority__c = 'Medium',
    Order_Date__c = today.addDays(-5),
    Expected_Delivery_Date__c = today.addDays(-2),
    Discount_Percentage__c = 15.0
));

orders.add(new Device_Order__c(
    Device__c = devices[4].Id, // Dell PowerEdge R750 Server
    Customer__c = customers[3].Id, // City University
    Quantity__c = 2,
    Status__c = 'Pending',
    Priority__c = 'Critical',
    Order_Date__c = today.addDays(-3),
    Expected_Delivery_Date__c = today.addDays(2),
    Discount_Percentage__c = 8.0
));

orders.add(new Device_Order__c(
    Device__c = devices[17].Id, // Logitech MX Master 3S Mouse
    Customer__c = customers[4].Id, // Healthcare Systems Inc
    Quantity__c = 25,
    Status__c = 'Confirmed',
    Priority__c = 'Low',
    Order_Date__c = today.addDays(-4),
    Expected_Delivery_Date__c = today.addDays(4),
    Discount_Percentage__c = 12.0
));

// LAST 2 WEEKS
orders.add(new Device_Order__c(
    Device__c = devices[1].Id, // MacBook Air 13-inch M3
    Customer__c = customers[5].Id, // John Smith
    Quantity__c = 1,
    Status__c = 'Delivered',
    Priority__c = 'Medium',
    Order_Date__c = today.addDays(-8),
    Expected_Delivery_Date__c = today.addDays(-3),
    Discount_Percentage__c = 0.0
));

orders.add(new Device_Order__c(
    Device__c = devices[13].Id, // Adobe Creative Cloud
    Customer__c = customers[6].Id, // Creative Agency Pro
    Quantity__c = 10,
    Status__c = 'Delivered',
    Priority__c = 'High',
    Order_Date__c = today.addDays(-10),
    Expected_Delivery_Date__c = today.addDays(-5),
    Discount_Percentage__c = 20.0
));

orders.add(new Device_Order__c(
    Device__c = devices[6].Id, // Cisco Catalyst 9300 Switch
    Customer__c = customers[7].Id, // Manufacturing Corp
    Quantity__c = 4,
    Status__c = 'Delivered',
    Priority__c = 'High',
    Order_Date__c = today.addDays(-12),
    Expected_Delivery_Date__c = today.addDays(-7),
    Discount_Percentage__c = 18.0
));

orders.add(new Device_Order__c(
    Device__c = devices[11].Id, // iPad Pro 12.9-inch M4
    Customer__c = customers[8].Id, // Sarah Johnson
    Quantity__c = 1,
    Status__c = 'Delivered',
    Priority__c = 'Low',
    Order_Date__c = today.addDays(-14),
    Expected_Delivery_Date__c = today.addDays(-9),
    Discount_Percentage__c = 5.0
));

// LAST MONTH (15-30 days ago)
orders.add(new Device_Order__c(
    Device__c = devices[19].Id, // Dell UltraSharp 32" 4K Monitor
    Customer__c = customers[9].Id, // Consulting Partners LLC
    Quantity__c = 6,
    Status__c = 'Delivered',
    Priority__c = 'Medium',
    Order_Date__c = today.addDays(-18),
    Expected_Delivery_Date__c = today.addDays(-13),
    Discount_Percentage__c = 10.0
));

orders.add(new Device_Order__c(
    Device__c = devices[15].Id, // Samsung 2TB NVMe SSD
    Customer__c = customers[0].Id, // Acme Corporation
    Quantity__c = 20,
    Status__c = 'Delivered',
    Priority__c = 'Medium',
    Order_Date__c = today.addDays(-22),
    Expected_Delivery_Date__c = today.addDays(-17),
    Discount_Percentage__c = 25.0
));

orders.add(new Device_Order__c(
    Device__c = devices[7].Id, // Cisco ASA 5516-X Firewall
    Customer__c = customers[1].Id, // TechStart Innovations
    Quantity__c = 2,
    Status__c = 'Delivered',
    Priority__c = 'Critical',
    Order_Date__c = today.addDays(-25),
    Expected_Delivery_Date__c = today.addDays(-23),
    Discount_Percentage__c = 0.0
));

orders.add(new Device_Order__c(
    Device__c = devices[18].Id, // Logitech MX Keys Advanced Keyboard
    Customer__c = customers[2].Id, // Global Enterprises Ltd
    Quantity__c = 15,
    Status__c = 'Delivered',
    Priority__c = 'Low',
    Order_Date__c = today.addDays(-28),
    Expected_Delivery_Date__c = today.addDays(-23),
    Discount_Percentage__c = 8.0
));

orders.add(new Device_Order__c(
    Device__c = devices[14].Id, // Windows 11 Pro License
    Customer__c = customers[3].Id, // City University
    Quantity__c = 100,
    Status__c = 'Delivered',
    Priority__c = 'Medium',
    Order_Date__c = today.addDays(-30),
    Expected_Delivery_Date__c = today.addDays(-25),
    Discount_Percentage__c = 30.0
));

// 2 MONTHS AGO (31-60 days)
orders.add(new Device_Order__c(
    Device__c = devices[2].Id, // Dell XPS 13 Plus Laptop
    Customer__c = customers[4].Id, // Healthcare Systems Inc
    Quantity__c = 8,
    Status__c = 'Delivered',
    Priority__c = 'High',
    Order_Date__c = today.addDays(-35),
    Expected_Delivery_Date__c = today.addDays(-30),
    Discount_Percentage__c = 12.0
));

orders.add(new Device_Order__c(
    Device__c = devices[5].Id, // HP ProLiant DL380 Gen11
    Customer__c = customers[5].Id, // John Smith
    Quantity__c = 1,
    Status__c = 'Delivered',
    Priority__c = 'Medium',
    Order_Date__c = today.addDays(-40),
    Expected_Delivery_Date__c = today.addDays(-35),
    Discount_Percentage__c = 5.0
));

orders.add(new Device_Order__c(
    Device__c = devices[10].Id, // Samsung Galaxy S24 Ultra
    Customer__c = customers[6].Id, // Creative Agency Pro
    Quantity__c = 3,
    Status__c = 'Delivered',
    Priority__c = 'Low',
    Order_Date__c = today.addDays(-45),
    Expected_Delivery_Date__c = today.addDays(-40),
    Discount_Percentage__c = 7.0
));

orders.add(new Device_Order__c(
    Device__c = devices[16].Id, // Dell EMC PowerVault ME5012
    Customer__c = customers[7].Id, // Manufacturing Corp
    Quantity__c = 1,
    Status__c = 'Delivered',
    Priority__c = 'Critical',
    Order_Date__c = today.addDays(-50),
    Expected_Delivery_Date__c = today.addDays(-48),
    Discount_Percentage__c = 0.0
));

orders.add(new Device_Order__c(
    Device__c = devices[20].Id, // USB-C Multiport Hub Pro
    Customer__c = customers[8].Id, // Sarah Johnson
    Quantity__c = 2,
    Status__c = 'Delivered',
    Priority__c = 'Low',
    Order_Date__c = today.addDays(-55),
    Expected_Delivery_Date__c = today.addDays(-50),
    Discount_Percentage__c = 10.0
));

// 3 MONTHS AGO (61-90 days)
orders.add(new Device_Order__c(
    Device__c = devices[3].Id, // HP EliteBook 840 G10
    Customer__c = customers[9].Id, // Consulting Partners LLC
    Quantity__c = 5,
    Status__c = 'Delivered',
    Priority__c = 'Medium',
    Order_Date__c = today.addDays(-65),
    Expected_Delivery_Date__c = today.addDays(-60),
    Discount_Percentage__c = 15.0
));

orders.add(new Device_Order__c(
    Device__c = devices[8].Id, // iPhone 15 Pro Max (repeat customer)
    Customer__c = customers[0].Id, // Acme Corporation
    Quantity__c = 12,
    Status__c = 'Delivered',
    Priority__c = 'High',
    Order_Date__c = today.addDays(-70),
    Expected_Delivery_Date__c = today.addDays(-65),
    Discount_Percentage__c = 20.0
));

orders.add(new Device_Order__c(
    Device__c = devices[12].Id, // Microsoft Office 365 (bulk order)
    Customer__c = customers[1].Id, // TechStart Innovations
    Quantity__c = 25,
    Status__c = 'Delivered',
    Priority__c = 'Medium',
    Order_Date__c = today.addDays(-75),
    Expected_Delivery_Date__c = today.addDays(-70),
    Discount_Percentage__c = 22.0
));

orders.add(new Device_Order__c(
    Device__c = devices[17].Id, // Logitech MX Master 3S Mouse (bulk)
    Customer__c = customers[2].Id, // Global Enterprises Ltd
    Quantity__c = 30,
    Status__c = 'Delivered',
    Priority__c = 'Low',
    Order_Date__c = today.addDays(-80),
    Expected_Delivery_Date__c = today.addDays(-75),
    Discount_Percentage__c = 18.0
));

orders.add(new Device_Order__c(
    Device__c = devices[6].Id, // Cisco Catalyst 9300 Switch
    Customer__c = customers[3].Id, // City University
    Quantity__c = 3,
    Status__c = 'Delivered',
    Priority__c = 'High',
    Order_Date__c = today.addDays(-85),
    Expected_Delivery_Date__c = today.addDays(-80),
    Discount_Percentage__c = 12.0
));

orders.add(new Device_Order__c(
    Device__c = devices[13].Id, // Adobe Creative Cloud
    Customer__c = customers[4].Id, // Healthcare Systems Inc
    Quantity__c = 5,
    Status__c = 'Delivered',
    Priority__c = 'Medium',
    Order_Date__c = today.addDays(-90),
    Expected_Delivery_Date__c = today.addDays(-85),
    Discount_Percentage__c = 10.0
));

try {
    insert orders;
    System.debug('Successfully created ' + orders.size() + ' Device_Order records');
    
    // Analyze order distribution
    Map<String, Integer> statusCount = new Map<String, Integer>();
    Map<String, Integer> priorityCount = new Map<String, Integer>();
    Decimal totalRevenue = 0;
    
    for (Device_Order__c order : orders) {
        String status = order.Status__c;
        String priority = order.Priority__c;
        
        statusCount.put(status, statusCount.containsKey(status) ? statusCount.get(status) + 1 : 1);
        priorityCount.put(priority, priorityCount.containsKey(priority) ? priorityCount.get(priority) + 1 : 1);
    }
    
    System.debug('=== ORDER ANALYTICS SUMMARY ===');
    System.debug('Total Orders: ' + orders.size());
    
    System.debug('Status Distribution:');
    for (String status : statusCount.keySet()) {
        Integer count = statusCount.get(status);
        System.debug('  ' + status + ': ' + count + ' (' + (count * 100 / orders.size()) + '%)');
    }
    
    System.debug('Priority Distribution:');
    for (String priority : priorityCount.keySet()) {
        Integer count = priorityCount.get(priority);
        System.debug('  ' + priority + ': ' + count + ' (' + (count * 100 / orders.size()) + '%)');
    }
    
    System.debug('Time Distribution:');
    System.debug('  Last 7 days: 5 orders');
    System.debug('  Last 30 days: 9 orders');
    System.debug('  30-60 days ago: 5 orders');
    System.debug('  60-90 days ago: 6 orders');
    
} catch (Exception e) {
    System.debug('ERROR creating orders: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== Order Analytics Creation Complete ===');
