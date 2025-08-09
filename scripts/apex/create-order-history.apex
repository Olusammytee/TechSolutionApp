// Create comprehensive Device_Order history for dashboard analytics
System.debug('=== Creating Order History ===');

// Get Customer and Device IDs for relationships
List<Customer__c> customers = [SELECT Id, Name FROM Customer__c LIMIT 10];
List<Device__c> devices = [SELECT Id, Name, Price__c FROM Device__c LIMIT 20];

System.debug('Found ' + customers.size() + ' customers and ' + devices.size() + ' devices');

if (customers.isEmpty() || devices.isEmpty()) {
    System.debug('ERROR: Need customers and devices first. Please create them.');
    return;
}

List<Device_Order__c> orders = new List<Device_Order__c>();

// Create orders spanning last 90 days with realistic business patterns
Date today = Date.today();

// Recent orders (last 7 days) - Higher volume
orders.add(new Device_Order__c(
    Device__c = devices[0].Id,
    Customer__c = customers[0].Id,
    Quantity__c = 5,
    Status__c = 'Confirmed',
    Priority__c = 'High',
    Order_Date__c = today.addDays(-2),
    Expected_Delivery_Date__c = today.addDays(3),
    Discount_Percentage__c = 5.0
));

orders.add(new Device_Order__c(
    Device__c = devices[1].Id,
    Customer__c = customers[1].Id,
    Quantity__c = 2,
    Status__c = 'Shipped',
    Priority__c = 'Medium',
    Order_Date__c = today.addDays(-1),
    Expected_Delivery_Date__c = today.addDays(5),
    Discount_Percentage__c = 0.0
));

orders.add(new Device_Order__c(
    Device__c = devices[2].Id,
    Customer__c = customers[2].Id,
    Quantity__c = 1,
    Status__c = 'Delivered',
    Priority__c = 'Low',
    Order_Date__c = today.addDays(-5),
    Expected_Delivery_Date__c = today.addDays(-1),
    Discount_Percentage__c = 10.0
));

orders.add(new Device_Order__c(
    Device__c = devices[3].Id,
    Customer__c = customers[3].Id,
    Quantity__c = 3,
    Status__c = 'Pending',
    Priority__c = 'Critical',
    Order_Date__c = today.addDays(-3),
    Expected_Delivery_Date__c = today.addDays(1),
    Discount_Percentage__c = 0.0
));

// Last 2 weeks
orders.add(new Device_Order__c(
    Device__c = devices[4].Id,
    Customer__c = customers[4].Id,
    Quantity__c = 10,
    Status__c = 'Delivered',
    Priority__c = 'High',
    Order_Date__c = today.addDays(-8),
    Expected_Delivery_Date__c = today.addDays(-3),
    Discount_Percentage__c = 15.0
));

orders.add(new Device_Order__c(
    Device__c = devices[5].Id,
    Customer__c = customers[5].Id,
    Quantity__c = 1,
    Status__c = 'Delivered',
    Priority__c = 'Medium',
    Order_Date__c = today.addDays(-12),
    Expected_Delivery_Date__c = today.addDays(-7),
    Discount_Percentage__c = 5.0
));

orders.add(new Device_Order__c(
    Device__c = devices[6].Id,
    Customer__c = customers[0].Id,
    Quantity__c = 25,
    Status__c = 'Delivered',
    Priority__c = 'Medium',
    Order_Date__c = today.addDays(-14),
    Expected_Delivery_Date__c = today.addDays(-9),
    Discount_Percentage__c = 20.0
));

// Last month
orders.add(new Device_Order__c(
    Device__c = devices[7].Id,
    Customer__c = customers[1].Id,
    Quantity__c = 4,
    Status__c = 'Delivered',
    Priority__c = 'Low',
    Order_Date__c = today.addDays(-18),
    Expected_Delivery_Date__c = today.addDays(-13),
    Discount_Percentage__c = 0.0
));

orders.add(new Device_Order__c(
    Device__c = devices[8].Id,
    Customer__c = customers[2].Id,
    Quantity__c = 2,
    Status__c = 'Delivered',
    Priority__c = 'High',
    Order_Date__c = today.addDays(-22),
    Expected_Delivery_Date__c = today.addDays(-17),
    Discount_Percentage__c = 8.0
));

orders.add(new Device_Order__c(
    Device__c = devices[9].Id,
    Customer__c = customers[3].Id,
    Quantity__c = 15,
    Status__c = 'Delivered',
    Priority__c = 'Medium',
    Order_Date__c = today.addDays(-25),
    Expected_Delivery_Date__c = today.addDays(-20),
    Discount_Percentage__c = 12.0
));

orders.add(new Device_Order__c(
    Device__c = devices[10].Id,
    Customer__c = customers[4].Id,
    Quantity__c = 1,
    Status__c = 'Delivered',
    Priority__c = 'Critical',
    Order_Date__c = today.addDays(-28),
    Expected_Delivery_Date__c = today.addDays(-26),
    Discount_Percentage__c = 0.0
));

orders.add(new Device_Order__c(
    Device__c = devices[11].Id,
    Customer__c = customers[5].Id,
    Quantity__c = 8,
    Status__c = 'Delivered',
    Priority__c = 'Medium',
    Order_Date__c = today.addDays(-30),
    Expected_Delivery_Date__c = today.addDays(-25),
    Discount_Percentage__c = 6.0
));

// 2 months ago
orders.add(new Device_Order__c(
    Device__c = devices[12].Id,
    Customer__c = customers[0].Id,
    Quantity__c = 3,
    Status__c = 'Delivered',
    Priority__c = 'Low',
    Order_Date__c = today.addDays(-35),
    Expected_Delivery_Date__c = today.addDays(-30),
    Discount_Percentage__c = 5.0
));

orders.add(new Device_Order__c(
    Device__c = devices[13].Id,
    Customer__c = customers[1].Id,
    Quantity__c = 12,
    Status__c = 'Delivered',
    Priority__c = 'High',
    Order_Date__c = today.addDays(-42),
    Expected_Delivery_Date__c = today.addDays(-37),
    Discount_Percentage__c = 18.0
));

orders.add(new Device_Order__c(
    Device__c = devices[14].Id,
    Customer__c = customers[2].Id,
    Quantity__c = 6,
    Status__c = 'Delivered',
    Priority__c = 'Medium',
    Order_Date__c = today.addDays(-45),
    Expected_Delivery_Date__c = today.addDays(-40),
    Discount_Percentage__c = 10.0
));

orders.add(new Device_Order__c(
    Device__c = devices[15].Id,
    Customer__c = customers[3].Id,
    Quantity__c = 20,
    Status__c = 'Delivered',
    Priority__c = 'Medium',
    Order_Date__c = today.addDays(-50),
    Expected_Delivery_Date__c = today.addDays(-45),
    Discount_Percentage__c = 25.0
));

orders.add(new Device_Order__c(
    Device__c = devices[16].Id,
    Customer__c = customers[4].Id,
    Quantity__c = 1,
    Status__c = 'Delivered',
    Priority__c = 'Low',
    Order_Date__c = today.addDays(-55),
    Expected_Delivery_Date__c = today.addDays(-50),
    Discount_Percentage__c = 0.0
));

// 3 months ago
orders.add(new Device_Order__c(
    Device__c = devices[17].Id,
    Customer__c = customers[5].Id,
    Quantity__c = 7,
    Status__c = 'Delivered',
    Priority__c = 'High',
    Order_Date__c = today.addDays(-60),
    Expected_Delivery_Date__c = today.addDays(-55),
    Discount_Percentage__c = 8.0
));

orders.add(new Device_Order__c(
    Device__c = devices[18].Id,
    Customer__c = customers[0].Id,
    Quantity__c = 4,
    Status__c = 'Delivered',
    Priority__c = 'Medium',
    Order_Date__c = today.addDays(-65),
    Expected_Delivery_Date__c = today.addDays(-60),
    Discount_Percentage__c = 12.0
));

orders.add(new Device_Order__c(
    Device__c = devices[19].Id,
    Customer__c = customers[1].Id,
    Quantity__c = 9,
    Status__c = 'Delivered',
    Priority__c = 'Low',
    Order_Date__c = today.addDays(-70),
    Expected_Delivery_Date__c = today.addDays(-65),
    Discount_Percentage__c = 15.0
));

orders.add(new Device_Order__c(
    Device__c = devices[0].Id,
    Customer__c = customers[2].Id,
    Quantity__c = 2,
    Status__c = 'Delivered',
    Priority__c = 'Critical',
    Order_Date__c = today.addDays(-75),
    Expected_Delivery_Date__c = today.addDays(-73),
    Discount_Percentage__c = 0.0
));

orders.add(new Device_Order__c(
    Device__c = devices[1].Id,
    Customer__c = customers[3].Id,
    Quantity__c = 11,
    Status__c = 'Delivered',
    Priority__c = 'Medium',
    Order_Date__c = today.addDays(-80),
    Expected_Delivery_Date__c = today.addDays(-75),
    Discount_Percentage__c = 20.0
));

orders.add(new Device_Order__c(
    Device__c = devices[2].Id,
    Customer__c = customers[4].Id,
    Quantity__c = 5,
    Status__c = 'Delivered',
    Priority__c = 'High',
    Order_Date__c = today.addDays(-85),
    Expected_Delivery_Date__c = today.addDays(-80),
    Discount_Percentage__c = 7.0
));

orders.add(new Device_Order__c(
    Device__c = devices[3].Id,
    Customer__c = customers[5].Id,
    Quantity__c = 3,
    Status__c = 'Delivered',
    Priority__c = 'Low',
    Order_Date__c = today.addDays(-90),
    Expected_Delivery_Date__c = today.addDays(-85),
    Discount_Percentage__c = 5.0
));

try {
    insert orders;
    System.debug('Successfully created ' + orders.size() + ' Device_Order records');
    
    // Analyze order distribution
    Map<String, Integer> statusCount = new Map<String, Integer>();
    Map<String, Integer> priorityCount = new Map<String, Integer>();
    
    for (Device_Order__c order : orders) {
        String status = order.Status__c;
        String priority = order.Priority__c;
        
        statusCount.put(status, statusCount.containsKey(status) ? statusCount.get(status) + 1 : 1);
        priorityCount.put(priority, priorityCount.containsKey(priority) ? priorityCount.get(priority) + 1 : 1);
    }
    
    System.debug('=== ORDER DISTRIBUTION ===');
    System.debug('Status Distribution:');
    for (String status : statusCount.keySet()) {
        System.debug('  ' + status + ': ' + statusCount.get(status));
    }
    
    System.debug('Priority Distribution:');
    for (String priority : priorityCount.keySet()) {
        System.debug('  ' + priority + ': ' + priorityCount.get(priority));
    }
    
} catch (Exception e) {
    System.debug('ERROR creating orders: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== Order History Creation Complete ===');
