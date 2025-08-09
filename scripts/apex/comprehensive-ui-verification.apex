// Comprehensive UI/UX Verification - Test All Implemented Fixes
System.debug('=== COMPREHENSIVE UI/UX VERIFICATION ===');

try {
    // 1. RECORD VISIBILITY VERIFICATION
    System.debug('=== 1. RECORD VISIBILITY VERIFICATION ===');
    
    Integer deviceCount = [SELECT COUNT() FROM Device__c];
    Integer customerCount = [SELECT COUNT() FROM Customer__c];
    Integer supplierCount = [SELECT COUNT() FROM Supplier__c];
    Integer orderCount = [SELECT COUNT() FROM Device_Order__c];
    
    System.debug('Record Counts:');
    System.debug('  Devices: ' + deviceCount + ' records');
    System.debug('  Customers: ' + customerCount + ' records');
    System.debug('  Suppliers: ' + supplierCount + ' records');
    System.debug('  Orders: ' + orderCount + ' records');
    System.debug('  Total Records: ' + (deviceCount + customerCount + supplierCount + orderCount));
    
    // Sample records for UI testing
    List<Device__c> sampleDevices = [SELECT Id, Name FROM Device__c LIMIT 3];
    List<Customer__c> sampleCustomers = [SELECT Id, Name FROM Customer__c LIMIT 3];
    List<Supplier__c> sampleSuppliers = [SELECT Id, Name FROM Supplier__c LIMIT 3];
    List<Device_Order__c> sampleOrders = [SELECT Id, Name FROM Device_Order__c LIMIT 3];
    
    System.debug('Sample Records for UI Testing:');
    System.debug('  Sample Devices: ' + sampleDevices.size() + ' available');
    for (Device__c device : sampleDevices) {
        System.debug('    - ' + device.Name + ' (ID: ' + device.Id + ')');
    }
    System.debug('  Sample Customers: ' + sampleCustomers.size() + ' available');
    for (Customer__c customer : sampleCustomers) {
        System.debug('    - ' + customer.Name + ' (ID: ' + customer.Id + ')');
    }
    System.debug('  Sample Suppliers: ' + sampleSuppliers.size() + ' available');
    for (Supplier__c supplier : sampleSuppliers) {
        System.debug('    - ' + supplier.Name + ' (ID: ' + supplier.Id + ')');
    }
    System.debug('  Sample Orders: ' + sampleOrders.size() + ' available');
    for (Device_Order__c order : sampleOrders) {
        System.debug('    - ' + order.Name + ' (ID: ' + order.Id + ')');
    }
    
    // 2. PAGE LAYOUT FIELD VERIFICATION
    System.debug('=== 2. PAGE LAYOUT FIELD VERIFICATION ===');
    
    // Test Device fields accessibility
    List<Device__c> deviceFieldTest = [
        SELECT Id, Name, Type__c, Stock_Quantity__c, Price__c, Cost_Price__c, 
               Profit_Margin__c, Warranty_Period_Months__c, Active__c, Supplier__c,
               Minimum_Stock_Level__c, Reorder_Point__c, Last_Restocked__c, Stock_Status__c,
               CreatedDate, LastModifiedDate
        FROM Device__c 
        LIMIT 1
    ];
    
    if (!deviceFieldTest.isEmpty()) {
        Device__c device = deviceFieldTest[0];
        System.debug('Device Field Access Test - ' + device.Name + ':');
        System.debug('  ✅ Basic Fields: Name=' + device.Name + ', Type=' + device.Type__c + ', Active=' + device.Active__c);
        System.debug('  ✅ Pricing Fields: Price=$' + device.Price__c + ', Cost=$' + device.Cost_Price__c + ', Margin=' + device.Profit_Margin__c + '%');
        System.debug('  ✅ Inventory Fields: Stock=' + device.Stock_Quantity__c + ', Min=' + device.Minimum_Stock_Level__c + ', Status=' + device.Stock_Status__c);
        System.debug('  ✅ Relationship Fields: Supplier=' + device.Supplier__c);
        System.debug('  ✅ System Fields: Created=' + device.CreatedDate + ', Modified=' + device.LastModifiedDate);
    } else {
        System.debug('  ❌ No Device records found for field testing');
    }
    
    // Test Customer fields accessibility
    List<Customer__c> customerFieldTest = [
        SELECT Id, Name, Email__c, Phone__c, Address__c, Customer_Type__c, 
               Customer_Status__c, Credit_Limit__c, CreatedDate, LastModifiedDate
        FROM Customer__c 
        LIMIT 1
    ];
    
    if (!customerFieldTest.isEmpty()) {
        Customer__c customer = customerFieldTest[0];
        System.debug('Customer Field Access Test - ' + customer.Name + ':');
        System.debug('  ✅ Basic Fields: Name=' + customer.Name + ', Type=' + customer.Customer_Type__c + ', Status=' + customer.Customer_Status__c);
        System.debug('  ✅ Contact Fields: Email=' + customer.Email__c + ', Phone=' + customer.Phone__c);
        System.debug('  ✅ Financial Fields: Credit Limit=$' + customer.Credit_Limit__c);
        System.debug('  ✅ System Fields: Created=' + customer.CreatedDate);
    } else {
        System.debug('  ❌ No Customer records found for field testing');
    }
    
    // Test Supplier fields accessibility
    List<Supplier__c> supplierFieldTest = [
        SELECT Id, Name, Company_Name__c, Contact_Person__c, Email__c, Phone__c,
               Country__c, Supplier_Rating__c, Active__c, CreatedDate
        FROM Supplier__c 
        LIMIT 1
    ];
    
    if (!supplierFieldTest.isEmpty()) {
        Supplier__c supplier = supplierFieldTest[0];
        System.debug('Supplier Field Access Test - ' + supplier.Name + ':');
        System.debug('  ✅ Basic Fields: Name=' + supplier.Name + ', Company=' + supplier.Company_Name__c + ', Active=' + supplier.Active__c);
        System.debug('  ✅ Contact Fields: Person=' + supplier.Contact_Person__c + ', Email=' + supplier.Email__c + ', Phone=' + supplier.Phone__c);
        System.debug('  ✅ Business Fields: Country=' + supplier.Country__c + ', Rating=' + supplier.Supplier_Rating__c);
    } else {
        System.debug('  ❌ No Supplier records found for field testing');
    }
    
    // Test Order fields accessibility
    List<Device_Order__c> orderFieldTest = [
        SELECT Id, Name, Device__c, Customer__c, Quantity__c, Status__c, Priority__c,
               Total_Price__c, Order_Date__c, Expected_Delivery_Date__c, 
               Discount_Percentage__c, Final_Amount__c, Confirmation_Number__c
        FROM Device_Order__c 
        LIMIT 1
    ];
    
    if (!orderFieldTest.isEmpty()) {
        Device_Order__c order = orderFieldTest[0];
        System.debug('Order Field Access Test - ' + order.Name + ':');
        System.debug('  ✅ Basic Fields: Name=' + order.Name + ', Status=' + order.Status__c + ', Priority=' + order.Priority__c);
        System.debug('  ✅ Relationship Fields: Device=' + order.Device__c + ', Customer=' + order.Customer__c);
        System.debug('  ✅ Quantity Fields: Qty=' + order.Quantity__c);
        System.debug('  ✅ Financial Fields: Total=$' + order.Total_Price__c + ', Final=$' + order.Final_Amount__c + ', Discount=' + order.Discount_Percentage__c + '%');
        System.debug('  ✅ Date Fields: Order Date=' + order.Order_Date__c + ', Delivery=' + order.Expected_Delivery_Date__c);
        System.debug('  ✅ System Fields: Confirmation=' + order.Confirmation_Number__c);
    } else {
        System.debug('  ❌ No Order records found for field testing');
    }
    
    // 3. RELATIONSHIP NAVIGATION VERIFICATION
    System.debug('=== 3. RELATIONSHIP NAVIGATION VERIFICATION ===');
    
    // Test Device-Supplier relationships
    List<Device__c> deviceSupplierTest = [
        SELECT Id, Name, Supplier__c, Supplier__r.Name, Supplier__r.Company_Name__c, 
               Supplier__r.Contact_Person__c, Supplier__r.Supplier_Rating__c
        FROM Device__c 
        WHERE Supplier__c != null 
        LIMIT 3
    ];
    
    System.debug('Device-Supplier Relationship Test:');
    for (Device__c device : deviceSupplierTest) {
        System.debug('  ✅ ' + device.Name + ' → ' + device.Supplier__r.Name + 
                     ' (' + device.Supplier__r.Company_Name__c + ', Rating: ' + device.Supplier__r.Supplier_Rating__c + ')');
    }
    
    // Test Order-Customer-Device relationships
    List<Device_Order__c> orderRelationshipTest = [
        SELECT Id, Name, Customer__c, Customer__r.Name, Customer__r.Customer_Type__c,
               Device__c, Device__r.Name, Device__r.Type__c, Device__r.Price__c
        FROM Device_Order__c 
        WHERE Customer__c != null AND Device__c != null 
        LIMIT 3
    ];
    
    System.debug('Order Relationship Test:');
    for (Device_Order__c order : orderRelationshipTest) {
        System.debug('  ✅ ' + order.Name + ':');
        System.debug('    Customer: ' + order.Customer__r.Name + ' (' + order.Customer__r.Customer_Type__c + ')');
        System.debug('    Device: ' + order.Device__r.Name + ' (' + order.Device__r.Type__c + ', $' + order.Device__r.Price__c + ')');
    }
    
    // 4. FORMULA FIELD CALCULATION VERIFICATION
    System.debug('=== 4. FORMULA FIELD CALCULATION VERIFICATION ===');
    
    // Test Profit Margin calculations
    List<Device__c> profitMarginTest = [
        SELECT Id, Name, Price__c, Cost_Price__c, Profit_Margin__c
        FROM Device__c 
        WHERE Price__c != null AND Cost_Price__c != null AND Price__c > 0
        LIMIT 3
    ];
    
    System.debug('Profit Margin Formula Test:');
    for (Device__c device : profitMarginTest) {
        Decimal expectedMargin = ((device.Price__c - device.Cost_Price__c) / device.Price__c) * 100;
        Boolean isCorrect = Math.abs(device.Profit_Margin__c - expectedMargin) < 0.01;
        System.debug('  ' + (isCorrect ? '✅' : '❌') + ' ' + device.Name + ':');
        System.debug('    Price: $' + device.Price__c + ', Cost: $' + device.Cost_Price__c);
        System.debug('    Calculated: ' + device.Profit_Margin__c + '%, Expected: ' + expectedMargin.setScale(2) + '%');
    }
    
    // Test Order Final Amount calculations
    List<Device_Order__c> finalAmountTest = [
        SELECT Id, Name, Quantity__c, Device__r.Price__c, Discount_Percentage__c, 
               Total_Price__c, Final_Amount__c
        FROM Device_Order__c 
        WHERE Quantity__c != null AND Device__r.Price__c != null 
        LIMIT 3
    ];
    
    System.debug('Final Amount Formula Test:');
    for (Device_Order__c order : finalAmountTest) {
        Decimal expectedTotal = order.Quantity__c * order.Device__r.Price__c;
        Decimal expectedFinal = expectedTotal * (1 - (order.Discount_Percentage__c / 100));
        Boolean totalCorrect = Math.abs(order.Total_Price__c - expectedTotal) < 0.01;
        Boolean finalCorrect = Math.abs(order.Final_Amount__c - expectedFinal) < 0.01;
        System.debug('  ' + (totalCorrect && finalCorrect ? '✅' : '❌') + ' ' + order.Name + ':');
        System.debug('    Qty: ' + order.Quantity__c + ', Unit: $' + order.Device__r.Price__c + ', Discount: ' + order.Discount_Percentage__c + '%');
        System.debug('    Total: $' + order.Total_Price__c + ' (Expected: $' + expectedTotal.setScale(2) + ')');
        System.debug('    Final: $' + order.Final_Amount__c + ' (Expected: $' + expectedFinal.setScale(2) + ')');
    }
    
    // 5. PERMISSION SET VERIFICATION
    System.debug('=== 5. PERMISSION SET VERIFICATION ===');
    
    User currentUser = [SELECT Id, Username, Name FROM User WHERE Id = :UserInfo.getUserId()];
    System.debug('Current User: ' + currentUser.Name + ' (' + currentUser.Username + ')');
    
    List<PermissionSetAssignment> psAssignments = [
        SELECT Id, Assignee.Name, PermissionSet.Name, PermissionSet.Label
        FROM PermissionSetAssignment 
        WHERE AssigneeId = :currentUser.Id AND PermissionSet.Name = 'TechSolutions_Admin'
    ];
    
    if (!psAssignments.isEmpty()) {
        System.debug('✅ TechSolutions_Admin Permission Set Assigned');
        for (PermissionSetAssignment psa : psAssignments) {
            System.debug('  Assignment: ' + psa.Assignee.Name + ' → ' + psa.PermissionSet.Label);
        }
    } else {
        System.debug('❌ TechSolutions_Admin Permission Set NOT Assigned');
    }
    
    // 6. BUSINESS PROCESS VALIDATION
    System.debug('=== 6. BUSINESS PROCESS VALIDATION ===');
    
    // Test Stock Status automation
    List<Device__c> stockStatusTest = [
        SELECT Id, Name, Stock_Quantity__c, Minimum_Stock_Level__c, Stock_Status__c
        FROM Device__c 
        WHERE Stock_Quantity__c != null AND Minimum_Stock_Level__c != null
        LIMIT 5
    ];
    
    System.debug('Stock Status Automation Test:');
    for (Device__c device : stockStatusTest) {
        String expectedStatus;
        if (device.Stock_Quantity__c == 0) {
            expectedStatus = 'Out of Stock';
        } else if (device.Stock_Quantity__c <= device.Minimum_Stock_Level__c) {
            expectedStatus = 'Low Stock';
        } else {
            expectedStatus = 'In Stock';
        }
        Boolean isCorrect = device.Stock_Status__c == expectedStatus;
        System.debug('  ' + (isCorrect ? '✅' : '❌') + ' ' + device.Name + ':');
        System.debug('    Stock: ' + device.Stock_Quantity__c + ', Min: ' + device.Minimum_Stock_Level__c);
        System.debug('    Status: ' + device.Stock_Status__c + ' (Expected: ' + expectedStatus + ')');
    }
    
    System.debug('=== VERIFICATION COMPLETE ===');
    
} catch (Exception e) {
    System.debug('ERROR in UI verification: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== COMPREHENSIVE UI/UX VERIFICATION COMPLETE ===');
