// Comprehensive Data Quality Validation for Dashboard Preparation
System.debug('=== Starting Data Quality Validation ===');

// 1. Validate record counts
Integer supplierCount = [SELECT COUNT() FROM Supplier__c];
Integer customerCount = [SELECT COUNT() FROM Customer__c];
Integer deviceCount = [SELECT COUNT() FROM Device__c];
Integer orderCount = [SELECT COUNT() FROM Device_Order__c];

System.debug('=== RECORD COUNTS ===');
System.debug('Suppliers: ' + supplierCount);
System.debug('Customers: ' + customerCount);
System.debug('Devices: ' + deviceCount);
System.debug('Orders: ' + orderCount);

// 2. Validate cross-object relationships
System.debug('=== RELATIONSHIP VALIDATION ===');

// Check Device-Supplier relationships
List<Device__c> devicesWithSuppliers = [
    SELECT Id, Name, Supplier__c, Supplier__r.Name 
    FROM Device__c 
    WHERE Supplier__c != null 
    LIMIT 5
];
System.debug('Devices with Supplier relationships: ' + devicesWithSuppliers.size());
for (Device__c device : devicesWithSuppliers) {
    System.debug('  ' + device.Name + ' → ' + device.Supplier__r.Name);
}

// Check Order-Customer relationships
List<Device_Order__c> ordersWithCustomers = [
    SELECT Id, Name, Customer__c, Customer__r.Name 
    FROM Device_Order__c 
    WHERE Customer__c != null 
    LIMIT 5
];
System.debug('Orders with Customer relationships: ' + ordersWithCustomers.size());
for (Device_Order__c order : ordersWithCustomers) {
    System.debug('  ' + order.Name + ' → ' + order.Customer__r.Name);
}

// Check Order-Device relationships
List<Device_Order__c> ordersWithDevices = [
    SELECT Id, Name, Device__c, Device__r.Name 
    FROM Device_Order__c 
    WHERE Device__c != null 
    LIMIT 5
];
System.debug('Orders with Device relationships: ' + ordersWithDevices.size());
for (Device_Order__c order : ordersWithDevices) {
    System.debug('  ' + order.Name + ' → ' + order.Device__r.Name);
}

// 3. Validate formula fields
System.debug('=== FORMULA FIELD VALIDATION ===');

// Check Device Profit Margin calculations
List<Device__c> devicesWithProfitMargin = [
    SELECT Id, Name, Price__c, Cost_Price__c, Profit_Margin__c 
    FROM Device__c 
    WHERE Price__c != null AND Cost_Price__c != null 
    LIMIT 5
];
System.debug('Devices with Profit Margin calculations:');
for (Device__c device : devicesWithProfitMargin) {
    Decimal expectedMargin = ((device.Price__c - device.Cost_Price__c) / device.Price__c) * 100;
    System.debug('  ' + device.Name + ': Price=' + device.Price__c + 
                 ', Cost=' + device.Cost_Price__c + 
                 ', Calculated Margin=' + device.Profit_Margin__c + 
                 ', Expected=' + expectedMargin.setScale(2));
}

// Check Order Final Amount calculations
List<Device_Order__c> ordersWithFinalAmount = [
    SELECT Id, Name, Quantity__c, Device__r.Price__c, Discount_Percentage__c, Final_Amount__c, Total_Price__c
    FROM Device_Order__c 
    WHERE Quantity__c != null AND Device__r.Price__c != null 
    LIMIT 5
];
System.debug('Orders with Final Amount calculations:');
for (Device_Order__c order : ordersWithFinalAmount) {
    Decimal baseAmount = order.Quantity__c * order.Device__r.Price__c;
    Decimal discountAmount = baseAmount * (order.Discount_Percentage__c / 100);
    Decimal expectedFinal = baseAmount - discountAmount;
    System.debug('  ' + order.Name + ': Qty=' + order.Quantity__c + 
                 ', Price=' + order.Device__r.Price__c + 
                 ', Discount=' + order.Discount_Percentage__c + '%' +
                 ', Total=' + order.Total_Price__c +
                 ', Final=' + order.Final_Amount__c + 
                 ', Expected=' + expectedFinal.setScale(2));
}

// 4. Validate stock status distribution
System.debug('=== STOCK STATUS ANALYSIS ===');
AggregateResult[] stockStatusResults = [
    SELECT Stock_Status__c, COUNT(Id) recordCount
    FROM Device__c 
    GROUP BY Stock_Status__c
];
for (AggregateResult result : stockStatusResults) {
    System.debug('  ' + result.get('Stock_Status__c') + ': ' + result.get('recordCount') + ' devices');
}

// 5. Validate order status distribution
System.debug('=== ORDER STATUS ANALYSIS ===');
AggregateResult[] orderStatusResults = [
    SELECT Status__c, COUNT(Id) recordCount
    FROM Device_Order__c 
    GROUP BY Status__c
];
for (AggregateResult result : orderStatusResults) {
    System.debug('  ' + result.get('Status__c') + ': ' + result.get('recordCount') + ' orders');
}

// 6. Validate priority distribution
System.debug('=== PRIORITY ANALYSIS ===');
AggregateResult[] priorityResults = [
    SELECT Priority__c, COUNT(Id) recordCount
    FROM Device_Order__c 
    GROUP BY Priority__c
];
for (AggregateResult result : priorityResults) {
    System.debug('  ' + result.get('Priority__c') + ': ' + result.get('recordCount') + ' orders');
}

// 7. Validate time distribution for analytics
System.debug('=== TIME DISTRIBUTION ANALYSIS ===');
Date today = Date.today();
Date last30Days = today.addDays(-30);
Date last60Days = today.addDays(-60);
Date last90Days = today.addDays(-90);

Integer ordersLast30 = [SELECT COUNT() FROM Device_Order__c WHERE Order_Date__c >= :last30Days];
Integer ordersLast60 = [SELECT COUNT() FROM Device_Order__c WHERE Order_Date__c >= :last60Days AND Order_Date__c < :last30Days];
Integer ordersLast90 = [SELECT COUNT() FROM Device_Order__c WHERE Order_Date__c >= :last90Days AND Order_Date__c < :last60Days];

System.debug('Orders in last 30 days: ' + ordersLast30);
System.debug('Orders 30-60 days ago: ' + ordersLast60);
System.debug('Orders 60-90 days ago: ' + ordersLast90);

// 8. Validate customer segmentation
System.debug('=== CUSTOMER SEGMENTATION ANALYSIS ===');
AggregateResult[] customerTypeResults = [
    SELECT Customer_Type__c, COUNT(Id) recordCount
    FROM Customer__c 
    GROUP BY Customer_Type__c
];
for (AggregateResult result : customerTypeResults) {
    System.debug('  ' + result.get('Customer_Type__c') + ': ' + result.get('recordCount') + ' customers');
}

AggregateResult[] customerStatusResults = [
    SELECT Customer_Status__c, COUNT(Id) recordCount
    FROM Customer__c 
    GROUP BY Customer_Status__c
];
for (AggregateResult result : customerStatusResults) {
    System.debug('  ' + result.get('Customer_Status__c') + ': ' + result.get('recordCount') + ' customers');
}

// 9. Validate device type distribution
System.debug('=== DEVICE TYPE ANALYSIS ===');
AggregateResult[] deviceTypeResults = [
    SELECT Type__c, COUNT(Id) recordCount, AVG(Price__c) avgPrice
    FROM Device__c 
    GROUP BY Type__c
];
for (AggregateResult result : deviceTypeResults) {
    System.debug('  ' + result.get('Type__c') + ': ' + result.get('recordCount') + 
                 ' devices, Avg Price: $' + ((Decimal)result.get('avgPrice')).setScale(2));
}

// 10. Summary validation
System.debug('=== VALIDATION SUMMARY ===');
Boolean validationPassed = true;
List<String> issues = new List<String>();

if (supplierCount < 6) {
    issues.add('Insufficient suppliers: ' + supplierCount + ' (expected 6+)');
    validationPassed = false;
}
if (customerCount < 8) {
    issues.add('Insufficient customers: ' + customerCount + ' (expected 8+)');
    validationPassed = false;
}
if (deviceCount < 15) {
    issues.add('Insufficient devices: ' + deviceCount + ' (expected 15+)');
    validationPassed = false;
}
if (orderCount < 20) {
    issues.add('Insufficient orders: ' + orderCount + ' (expected 20+)');
    validationPassed = false;
}

if (validationPassed) {
    System.debug('✅ DATA QUALITY VALIDATION PASSED!');
    System.debug('All data requirements met for dashboard demonstration');
} else {
    System.debug('⚠️ DATA QUALITY ISSUES FOUND:');
    for (String issue : issues) {
        System.debug('  - ' + issue);
    }
}

System.debug('=== Data Quality Validation Complete ===');
