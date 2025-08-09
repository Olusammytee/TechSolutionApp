// UI Validation Test - Verify Record Visibility and Field Access
System.debug('=== UI VALIDATION TEST ===');

try {
    // 1. VERIFY RECORD COUNTS AND VISIBILITY
    System.debug('=== RECORD VISIBILITY VERIFICATION ===');
    
    Integer deviceCount = [SELECT COUNT() FROM Device__c];
    Integer customerCount = [SELECT COUNT() FROM Customer__c];
    Integer supplierCount = [SELECT COUNT() FROM Supplier__c];
    Integer orderCount = [SELECT COUNT() FROM Device_Order__c];
    
    System.debug('Device Records: ' + deviceCount);
    System.debug('Customer Records: ' + customerCount);
    System.debug('Supplier Records: ' + supplierCount);
    System.debug('Order Records: ' + orderCount);
    
    // 2. TEST SAMPLE RECORD RETRIEVAL WITH ALL FIELDS
    System.debug('=== FIELD ACCESS VERIFICATION ===');
    
    // Test Device field access
    List<Device__c> sampleDevices = [
        SELECT Id, Name, Type__c, Stock_Quantity__c, Price__c, Cost_Price__c, 
               Profit_Margin__c, Warranty_Period_Months__c, Active__c, Supplier__c,
               Minimum_Stock_Level__c, Reorder_Point__c, Last_Restocked__c, Stock_Status__c
        FROM Device__c 
        LIMIT 3
    ];
    
    System.debug('Sample Device Records with All Fields:');
    for (Device__c device : sampleDevices) {
        System.debug('  Device: ' + device.Name);
        System.debug('    Type: ' + device.Type__c);
        System.debug('    Price: $' + device.Price__c);
        System.debug('    Stock: ' + device.Stock_Quantity__c);
        System.debug('    Status: ' + device.Stock_Status__c);
        System.debug('    Supplier ID: ' + device.Supplier__c);
    }
    
    // Test Customer field access
    List<Customer__c> sampleCustomers = [
        SELECT Id, Name, Email__c, Phone__c, Address__c, Customer_Type__c, 
               Customer_Status__c, Credit_Limit__c
        FROM Customer__c 
        LIMIT 3
    ];
    
    System.debug('Sample Customer Records with All Fields:');
    for (Customer__c customer : sampleCustomers) {
        System.debug('  Customer: ' + customer.Name);
        System.debug('    Type: ' + customer.Customer_Type__c);
        System.debug('    Status: ' + customer.Customer_Status__c);
        System.debug('    Credit Limit: $' + customer.Credit_Limit__c);
        System.debug('    Email: ' + customer.Email__c);
    }
    
    // Test Supplier field access
    List<Supplier__c> sampleSuppliers = [
        SELECT Id, Name, Company_Name__c, Contact_Person__c, Email__c, Phone__c,
               Country__c, Supplier_Rating__c, Active__c
        FROM Supplier__c 
        LIMIT 3
    ];
    
    System.debug('Sample Supplier Records with All Fields:');
    for (Supplier__c supplier : sampleSuppliers) {
        System.debug('  Supplier: ' + supplier.Name);
        System.debug('    Company: ' + supplier.Company_Name__c);
        System.debug('    Contact: ' + supplier.Contact_Person__c);
        System.debug('    Rating: ' + supplier.Supplier_Rating__c);
        System.debug('    Country: ' + supplier.Country__c);
    }
    
    // Test Order field access
    List<Device_Order__c> sampleOrders = [
        SELECT Id, Name, Device__c, Customer__c, Quantity__c, Status__c, Priority__c,
               Total_Price__c, Order_Date__c, Expected_Delivery_Date__c, 
               Discount_Percentage__c, Final_Amount__c, Confirmation_Number__c
        FROM Device_Order__c 
        LIMIT 3
    ];
    
    System.debug('Sample Order Records with All Fields:');
    for (Device_Order__c order : sampleOrders) {
        System.debug('  Order: ' + order.Name);
        System.debug('    Status: ' + order.Status__c);
        System.debug('    Priority: ' + order.Priority__c);
        System.debug('    Quantity: ' + order.Quantity__c);
        System.debug('    Final Amount: $' + order.Final_Amount__c);
        System.debug('    Device ID: ' + order.Device__c);
        System.debug('    Customer ID: ' + order.Customer__c);
    }
    
    // 3. TEST RELATIONSHIP QUERIES
    System.debug('=== RELATIONSHIP VERIFICATION ===');
    
    // Test Device-Supplier relationships
    List<Device__c> devicesWithSuppliers = [
        SELECT Id, Name, Supplier__r.Name, Supplier__r.Company_Name__c
        FROM Device__c 
        WHERE Supplier__c != null 
        LIMIT 5
    ];
    
    System.debug('Device-Supplier Relationships:');
    for (Device__c device : devicesWithSuppliers) {
        System.debug('  ' + device.Name + ' → ' + device.Supplier__r.Name + 
                     ' (' + device.Supplier__r.Company_Name__c + ')');
    }
    
    // Test Order-Customer-Device relationships
    List<Device_Order__c> ordersWithRelationships = [
        SELECT Id, Name, Customer__r.Name, Device__r.Name, Device__r.Type__c
        FROM Device_Order__c 
        WHERE Customer__c != null AND Device__c != null 
        LIMIT 5
    ];
    
    System.debug('Order-Customer-Device Relationships:');
    for (Device_Order__c order : ordersWithRelationships) {
        System.debug('  ' + order.Name + ': ' + order.Customer__r.Name + 
                     ' ordered ' + order.Device__r.Name + ' (' + order.Device__r.Type__c + ')');
    }
    
    // 4. TEST FORMULA FIELD CALCULATIONS
    System.debug('=== FORMULA FIELD VERIFICATION ===');
    
    List<Device__c> devicesWithCalculations = [
        SELECT Id, Name, Price__c, Cost_Price__c, Profit_Margin__c
        FROM Device__c 
        WHERE Price__c != null AND Cost_Price__c != null 
        LIMIT 3
    ];
    
    System.debug('Profit Margin Formula Verification:');
    for (Device__c device : devicesWithCalculations) {
        Decimal expectedMargin = ((device.Price__c - device.Cost_Price__c) / device.Price__c) * 100;
        System.debug('  ' + device.Name + ':');
        System.debug('    Price: $' + device.Price__c + ', Cost: $' + device.Cost_Price__c);
        System.debug('    Calculated Margin: ' + device.Profit_Margin__c + '%');
        System.debug('    Expected Margin: ' + expectedMargin.setScale(2) + '%');
        System.debug('    Match: ' + (Math.abs(device.Profit_Margin__c - expectedMargin) < 0.01));
    }
    
    List<Device_Order__c> ordersWithCalculations = [
        SELECT Id, Name, Quantity__c, Device__r.Price__c, Discount_Percentage__c, 
               Total_Price__c, Final_Amount__c
        FROM Device_Order__c 
        WHERE Quantity__c != null AND Device__r.Price__c != null 
        LIMIT 3
    ];
    
    System.debug('Order Amount Formula Verification:');
    for (Device_Order__c order : ordersWithCalculations) {
        Decimal expectedTotal = order.Quantity__c * order.Device__r.Price__c;
        Decimal expectedFinal = expectedTotal * (1 - (order.Discount_Percentage__c / 100));
        System.debug('  ' + order.Name + ':');
        System.debug('    Qty: ' + order.Quantity__c + ', Unit Price: $' + order.Device__r.Price__c);
        System.debug('    Discount: ' + order.Discount_Percentage__c + '%');
        System.debug('    Total Price: $' + order.Total_Price__c + ' (Expected: $' + expectedTotal.setScale(2) + ')');
        System.debug('    Final Amount: $' + order.Final_Amount__c + ' (Expected: $' + expectedFinal.setScale(2) + ')');
    }
    
    // 5. SUMMARY VALIDATION
    System.debug('=== UI VALIDATION SUMMARY ===');
    
    Boolean validationPassed = true;
    List<String> issues = new List<String>();
    List<String> successes = new List<String>();
    
    // Check record visibility
    if (deviceCount >= 15) {
        successes.add('✅ Device Records: ' + deviceCount + ' visible');
    } else {
        issues.add('❌ Device Records: Only ' + deviceCount + ' visible (expected 15+)');
        validationPassed = false;
    }
    
    if (customerCount >= 8) {
        successes.add('✅ Customer Records: ' + customerCount + ' visible');
    } else {
        issues.add('❌ Customer Records: Only ' + customerCount + ' visible (expected 8+)');
        validationPassed = false;
    }
    
    if (supplierCount >= 6) {
        successes.add('✅ Supplier Records: ' + supplierCount + ' visible');
    } else {
        issues.add('❌ Supplier Records: Only ' + supplierCount + ' visible (expected 6+)');
        validationPassed = false;
    }
    
    if (orderCount >= 20) {
        successes.add('✅ Order Records: ' + orderCount + ' visible');
    } else {
        issues.add('❌ Order Records: Only ' + orderCount + ' visible (expected 20+)');
        validationPassed = false;
    }
    
    // Check field access
    if (!sampleDevices.isEmpty()) {
        successes.add('✅ Device Fields: All custom fields accessible');
    } else {
        issues.add('❌ Device Fields: Cannot access device records');
        validationPassed = false;
    }
    
    if (!sampleCustomers.isEmpty()) {
        successes.add('✅ Customer Fields: All custom fields accessible');
    } else {
        issues.add('❌ Customer Fields: Cannot access customer records');
        validationPassed = false;
    }
    
    if (!sampleSuppliers.isEmpty()) {
        successes.add('✅ Supplier Fields: All custom fields accessible');
    } else {
        issues.add('❌ Supplier Fields: Cannot access supplier records');
        validationPassed = false;
    }
    
    if (!sampleOrders.isEmpty()) {
        successes.add('✅ Order Fields: All custom fields accessible');
    } else {
        issues.add('❌ Order Fields: Cannot access order records');
        validationPassed = false;
    }
    
    // Check relationships
    if (!devicesWithSuppliers.isEmpty()) {
        successes.add('✅ Device-Supplier Relationships: Working correctly');
    } else {
        issues.add('❌ Device-Supplier Relationships: Not accessible');
        validationPassed = false;
    }
    
    if (!ordersWithRelationships.isEmpty()) {
        successes.add('✅ Order Relationships: Working correctly');
    } else {
        issues.add('❌ Order Relationships: Not accessible');
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
        System.debug('🎉 UI VALIDATION PASSED: All records and fields accessible!');
        System.debug('✅ Ready for UI testing and record creation through Salesforce interface');
    } else {
        System.debug('⚠️ UI VALIDATION ISSUES: See above for details');
    }
    
} catch (Exception e) {
    System.debug('ERROR in UI validation: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== UI VALIDATION TEST COMPLETE ===');
