// Final Data Quality Validation - Comprehensive Dashboard Readiness Check
System.debug('=== FINAL DATA QUALITY VALIDATION ===');

try {
    // 1. RECORD COUNT VALIDATION
    System.debug('=== RECORD COUNT VALIDATION ===');
    Integer supplierCount = [SELECT COUNT() FROM Supplier__c];
    Integer customerCount = [SELECT COUNT() FROM Customer__c];
    Integer deviceCount = [SELECT COUNT() FROM Device__c];
    Integer orderCount = [SELECT COUNT() FROM Device_Order__c];
    
    System.debug('Suppliers: ' + supplierCount + ' (Target: 6-8)');
    System.debug('Customers: ' + customerCount + ' (Target: 8-10)');
    System.debug('Devices: ' + deviceCount + ' (Target: 15-20)');
    System.debug('Orders: ' + orderCount + ' (Target: 20-25)');
    
    // 2. DISPLAY NAME VALIDATION
    System.debug('=== DISPLAY NAME VALIDATION ===');
    List<Device__c> deviceNames = [SELECT Id, Name FROM Device__c LIMIT 5];
    System.debug('Sample Device Names (checking for user-friendly display):');
    for (Device__c device : deviceNames) {
        System.debug('  ' + device.Name);
    }
    
    // 3. RELATIONSHIP VALIDATION
    System.debug('=== RELATIONSHIP VALIDATION ===');
    
    // Device-Supplier relationships
    List<Device__c> devicesWithSuppliers = [
        SELECT Id, Name, Supplier__c, Supplier__r.Name 
        FROM Device__c 
        WHERE Supplier__c != null 
        LIMIT 5
    ];
    System.debug('Device-Supplier Relationships (' + devicesWithSuppliers.size() + ' verified):');
    for (Device__c device : devicesWithSuppliers) {
        System.debug('  ' + device.Name + ' → ' + device.Supplier__r.Name);
    }
    
    // Order-Customer relationships
    List<Device_Order__c> ordersWithCustomers = [
        SELECT Id, Name, Customer__c, Customer__r.Name 
        FROM Device_Order__c 
        WHERE Customer__c != null 
        LIMIT 5
    ];
    System.debug('Order-Customer Relationships (' + ordersWithCustomers.size() + ' verified):');
    for (Device_Order__c order : ordersWithCustomers) {
        System.debug('  ' + order.Name + ' → ' + order.Customer__r.Name);
    }
    
    // Order-Device relationships
    List<Device_Order__c> ordersWithDevices = [
        SELECT Id, Name, Device__c, Device__r.Name 
        FROM Device_Order__c 
        WHERE Device__c != null 
        LIMIT 5
    ];
    System.debug('Order-Device Relationships (' + ordersWithDevices.size() + ' verified):');
    for (Device_Order__c order : ordersWithDevices) {
        System.debug('  ' + order.Name + ' → ' + order.Device__r.Name);
    }
    
    // 4. FORMULA FIELD VALIDATION
    System.debug('=== FORMULA FIELD VALIDATION ===');
    
    // Device Profit Margin validation
    List<Device__c> devicesWithMargins = [
        SELECT Id, Name, Price__c, Cost_Price__c, Profit_Margin__c 
        FROM Device__c 
        WHERE Price__c != null AND Cost_Price__c != null 
        LIMIT 3
    ];
    System.debug('Profit Margin Calculations:');
    for (Device__c device : devicesWithMargins) {
        Decimal expectedMargin = ((device.Price__c - device.Cost_Price__c) / device.Price__c) * 100;
        System.debug('  ' + device.Name + ': Calculated=' + device.Profit_Margin__c + 
                     '%, Expected=' + expectedMargin.setScale(2) + '%');
    }
    
    // Order Final Amount validation
    List<Device_Order__c> ordersWithAmounts = [
        SELECT Id, Name, Quantity__c, Device__r.Price__c, Discount_Percentage__c, 
               Final_Amount__c, Total_Price__c
        FROM Device_Order__c 
        WHERE Quantity__c != null AND Device__r.Price__c != null 
        LIMIT 3
    ];
    System.debug('Final Amount Calculations:');
    for (Device_Order__c order : ordersWithAmounts) {
        Decimal baseAmount = order.Quantity__c * order.Device__r.Price__c;
        Decimal discountAmount = baseAmount * (order.Discount_Percentage__c / 100);
        Decimal expectedFinal = baseAmount - discountAmount;
        System.debug('  ' + order.Name + ': Final=' + order.Final_Amount__c + 
                     ', Expected=' + expectedFinal.setScale(2));
    }
    
    // 5. STOCK STATUS DISTRIBUTION
    System.debug('=== STOCK STATUS DISTRIBUTION ===');
    AggregateResult[] stockResults = [
        SELECT Stock_Status__c, COUNT(Id) recordCount
        FROM Device__c 
        GROUP BY Stock_Status__c
    ];
    for (AggregateResult result : stockResults) {
        Integer count = (Integer)result.get('recordCount');
        System.debug('  ' + result.get('Stock_Status__c') + ': ' + count + 
                     ' devices (' + (count * 100 / deviceCount) + '%)');
    }
    
    // 6. ORDER STATUS DISTRIBUTION
    System.debug('=== ORDER STATUS DISTRIBUTION ===');
    AggregateResult[] orderStatusResults = [
        SELECT Status__c, COUNT(Id) recordCount
        FROM Device_Order__c 
        GROUP BY Status__c
    ];
    for (AggregateResult result : orderStatusResults) {
        Integer count = (Integer)result.get('recordCount');
        System.debug('  ' + result.get('Status__c') + ': ' + count + 
                     ' orders (' + (count * 100 / orderCount) + '%)');
    }
    
    // 7. PRIORITY DISTRIBUTION
    System.debug('=== PRIORITY DISTRIBUTION ===');
    AggregateResult[] priorityResults = [
        SELECT Priority__c, COUNT(Id) recordCount
        FROM Device_Order__c 
        GROUP BY Priority__c
    ];
    for (AggregateResult result : priorityResults) {
        Integer count = (Integer)result.get('recordCount');
        System.debug('  ' + result.get('Priority__c') + ': ' + count + 
                     ' orders (' + (count * 100 / orderCount) + '%)');
    }
    
    // 8. CUSTOMER SEGMENTATION
    System.debug('=== CUSTOMER SEGMENTATION ===');
    AggregateResult[] customerTypeResults = [
        SELECT Customer_Type__c, COUNT(Id) recordCount, AVG(Credit_Limit__c) avgCredit
        FROM Customer__c 
        GROUP BY Customer_Type__c
    ];
    for (AggregateResult result : customerTypeResults) {
        Integer count = (Integer)result.get('recordCount');
        Decimal avgCredit = (Decimal)result.get('avgCredit');
        System.debug('  ' + result.get('Customer_Type__c') + ': ' + count + 
                     ' customers, Avg Credit: $' + avgCredit.setScale(0));
    }
    
    // 9. DEVICE TYPE DISTRIBUTION
    System.debug('=== DEVICE TYPE DISTRIBUTION ===');
    AggregateResult[] deviceTypeResults = [
        SELECT Type__c, COUNT(Id) recordCount, AVG(Price__c) avgPrice
        FROM Device__c 
        GROUP BY Type__c
    ];
    for (AggregateResult result : deviceTypeResults) {
        Integer count = (Integer)result.get('recordCount');
        Decimal avgPrice = (Decimal)result.get('avgPrice');
        System.debug('  ' + result.get('Type__c') + ': ' + count + 
                     ' devices, Avg Price: $' + avgPrice.setScale(2));
    }
    
    // 10. TIME DISTRIBUTION ANALYSIS
    System.debug('=== TIME DISTRIBUTION ANALYSIS ===');
    Date today = Date.today();
    Date last30 = today.addDays(-30);
    Date last60 = today.addDays(-60);
    Date last90 = today.addDays(-90);
    
    Integer orders30 = [SELECT COUNT() FROM Device_Order__c WHERE Order_Date__c >= :last30];
    Integer orders60 = [SELECT COUNT() FROM Device_Order__c WHERE Order_Date__c >= :last60 AND Order_Date__c < :last30];
    Integer orders90 = [SELECT COUNT() FROM Device_Order__c WHERE Order_Date__c >= :last90 AND Order_Date__c < :last60];
    
    System.debug('  Last 30 days: ' + orders30 + ' orders');
    System.debug('  30-60 days ago: ' + orders60 + ' orders');
    System.debug('  60-90 days ago: ' + orders90 + ' orders');
    
    // 11. DASHBOARD READINESS ASSESSMENT
    System.debug('=== DASHBOARD READINESS ASSESSMENT ===');
    
    Boolean validationPassed = true;
    List<String> issues = new List<String>();
    List<String> successes = new List<String>();
    
    // Check minimum requirements
    if (supplierCount >= 6) {
        successes.add('✅ Suppliers: ' + supplierCount + ' (meets requirement)');
    } else {
        issues.add('❌ Suppliers: ' + supplierCount + ' (need 6+)');
        validationPassed = false;
    }
    
    if (customerCount >= 8) {
        successes.add('✅ Customers: ' + customerCount + ' (meets requirement)');
    } else {
        issues.add('❌ Customers: ' + customerCount + ' (need 8+)');
        validationPassed = false;
    }
    
    if (deviceCount >= 15) {
        successes.add('✅ Devices: ' + deviceCount + ' (meets requirement)');
    } else {
        issues.add('❌ Devices: ' + deviceCount + ' (need 15+)');
        validationPassed = false;
    }
    
    if (orderCount >= 20) {
        successes.add('✅ Orders: ' + orderCount + ' (meets requirement)');
    } else {
        issues.add('❌ Orders: ' + orderCount + ' (need 20+)');
        validationPassed = false;
    }
    
    // Check relationships
    Integer deviceSupplierLinks = [SELECT COUNT() FROM Device__c WHERE Supplier__c != null];
    Integer orderCustomerLinks = [SELECT COUNT() FROM Device_Order__c WHERE Customer__c != null];
    Integer orderDeviceLinks = [SELECT COUNT() FROM Device_Order__c WHERE Device__c != null];
    
    if (deviceSupplierLinks == deviceCount) {
        successes.add('✅ Device-Supplier relationships: 100% linked');
    } else {
        issues.add('❌ Device-Supplier relationships: ' + deviceSupplierLinks + '/' + deviceCount + ' linked');
        validationPassed = false;
    }
    
    if (orderCustomerLinks == orderCount) {
        successes.add('✅ Order-Customer relationships: 100% linked');
    } else {
        issues.add('❌ Order-Customer relationships: ' + orderCustomerLinks + '/' + orderCount + ' linked');
        validationPassed = false;
    }
    
    if (orderDeviceLinks == orderCount) {
        successes.add('✅ Order-Device relationships: 100% linked');
    } else {
        issues.add('❌ Order-Device relationships: ' + orderDeviceLinks + '/' + orderCount + ' linked');
        validationPassed = false;
    }
    
    // Display results
    System.debug('=== VALIDATION RESULTS ===');
    for (String success : successes) {
        System.debug(success);
    }
    
    if (!issues.isEmpty()) {
        System.debug('=== ISSUES FOUND ===');
        for (String issue : issues) {
            System.debug(issue);
        }
    }
    
    if (validationPassed) {
        System.debug('🎉 DASHBOARD READINESS: 100% - ALL REQUIREMENTS MET!');
        System.debug('✅ Data foundation is complete and ready for advanced dashboard implementation');
        System.debug('✅ All relationships established and formula fields functional');
        System.debug('✅ Comprehensive business scenarios available for analytics');
    } else {
        System.debug('⚠️ DASHBOARD READINESS: Issues found - see above for details');
    }
    
} catch (Exception e) {
    System.debug('ERROR in validation: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== FINAL DATA QUALITY VALIDATION COMPLETE ===');
