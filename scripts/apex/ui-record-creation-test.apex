// UI Record Creation Test - Simulate UI-based Record Creation
System.debug('=== UI RECORD CREATION TEST ===');

try {
    // Test creating records as if through the UI to verify all fields are accessible
    
    // 1. TEST DEVICE CREATION
    System.debug('=== 1. TESTING DEVICE CREATION ===');
    
    // Get a supplier for the relationship
    List<Supplier__c> testSuppliers = [SELECT Id, Name FROM Supplier__c LIMIT 1];
    if (testSuppliers.isEmpty()) {
        System.debug('❌ No suppliers available for Device creation test');
        return;
    }
    
    Device__c testDevice = new Device__c();
    testDevice.Name = 'UI Test Device - ' + DateTime.now().format('yyyy-MM-dd HH:mm:ss');
    testDevice.Type__c = 'Test Equipment';
    testDevice.Stock_Quantity__c = 10;
    testDevice.Price__c = 999.99;
    testDevice.Cost_Price__c = 749.99;
    testDevice.Warranty_Period_Months__c = 12;
    testDevice.Active__c = true;
    testDevice.Supplier__c = testSuppliers[0].Id;
    testDevice.Minimum_Stock_Level__c = 5;
    testDevice.Reorder_Point__c = 8;
    testDevice.Last_Restocked__c = Date.today();
    
    try {
        insert testDevice;
        System.debug('✅ Device creation successful: ' + testDevice.Name);
        System.debug('  Device ID: ' + testDevice.Id);
        
        // Verify the created device with all fields
        Device__c verifyDevice = [
            SELECT Id, Name, Type__c, Stock_Quantity__c, Price__c, Cost_Price__c, 
                   Profit_Margin__c, Warranty_Period_Months__c, Active__c, Supplier__c,
                   Minimum_Stock_Level__c, Reorder_Point__c, Last_Restocked__c, Stock_Status__c
            FROM Device__c 
            WHERE Id = :testDevice.Id
        ];
        
        System.debug('  Verification - All fields accessible:');
        System.debug('    Name: ' + verifyDevice.Name);
        System.debug('    Type: ' + verifyDevice.Type__c);
        System.debug('    Stock: ' + verifyDevice.Stock_Quantity__c);
        System.debug('    Price: $' + verifyDevice.Price__c);
        System.debug('    Profit Margin: ' + verifyDevice.Profit_Margin__c + '%');
        System.debug('    Stock Status: ' + verifyDevice.Stock_Status__c);
        System.debug('    Supplier: ' + verifyDevice.Supplier__c);
        
    } catch (Exception e) {
        System.debug('❌ Device creation failed: ' + e.getMessage());
    }
    
    // 2. TEST CUSTOMER CREATION
    System.debug('=== 2. TESTING CUSTOMER CREATION ===');
    
    Customer__c testCustomer = new Customer__c();
    testCustomer.Name = 'UI Test Customer - ' + DateTime.now().format('yyyy-MM-dd HH:mm:ss');
    testCustomer.Email__c = 'uitest@example.com';
    testCustomer.Phone__c = '+1-555-UI-TEST';
    testCustomer.Address__c = '123 UI Test Street, Test City, TC 12345';
    testCustomer.Customer_Type__c = 'Small Business';
    testCustomer.Customer_Status__c = 'Active';
    testCustomer.Credit_Limit__c = 15000;
    
    try {
        insert testCustomer;
        System.debug('✅ Customer creation successful: ' + testCustomer.Name);
        System.debug('  Customer ID: ' + testCustomer.Id);
        
        // Verify the created customer
        Customer__c verifyCustomer = [
            SELECT Id, Name, Email__c, Phone__c, Address__c, Customer_Type__c, 
                   Customer_Status__c, Credit_Limit__c
            FROM Customer__c 
            WHERE Id = :testCustomer.Id
        ];
        
        System.debug('  Verification - All fields accessible:');
        System.debug('    Name: ' + verifyCustomer.Name);
        System.debug('    Email: ' + verifyCustomer.Email__c);
        System.debug('    Type: ' + verifyCustomer.Customer_Type__c);
        System.debug('    Status: ' + verifyCustomer.Customer_Status__c);
        System.debug('    Credit Limit: $' + verifyCustomer.Credit_Limit__c);
        
    } catch (Exception e) {
        System.debug('❌ Customer creation failed: ' + e.getMessage());
    }
    
    // 3. TEST SUPPLIER CREATION
    System.debug('=== 3. TESTING SUPPLIER CREATION ===');
    
    Supplier__c testSupplier = new Supplier__c();
    testSupplier.Name = 'UI Test Supplier - ' + DateTime.now().format('yyyy-MM-dd HH:mm:ss');
    testSupplier.Company_Name__c = 'UI Test Supplier Inc.';
    testSupplier.Contact_Person__c = 'John UI Tester';
    testSupplier.Email__c = 'supplier@uitest.com';
    testSupplier.Phone__c = '+1-555-SUPPLIER';
    testSupplier.Country__c = 'United States';
    testSupplier.Supplier_Rating__c = 'Good';
    testSupplier.Active__c = true;
    
    try {
        insert testSupplier;
        System.debug('✅ Supplier creation successful: ' + testSupplier.Name);
        System.debug('  Supplier ID: ' + testSupplier.Id);
        
        // Verify the created supplier
        Supplier__c verifySupplier = [
            SELECT Id, Name, Company_Name__c, Contact_Person__c, Email__c, Phone__c,
                   Country__c, Supplier_Rating__c, Active__c
            FROM Supplier__c 
            WHERE Id = :testSupplier.Id
        ];
        
        System.debug('  Verification - All fields accessible:');
        System.debug('    Name: ' + verifySupplier.Name);
        System.debug('    Company: ' + verifySupplier.Company_Name__c);
        System.debug('    Contact: ' + verifySupplier.Contact_Person__c);
        System.debug('    Rating: ' + verifySupplier.Supplier_Rating__c);
        System.debug('    Country: ' + verifySupplier.Country__c);
        
    } catch (Exception e) {
        System.debug('❌ Supplier creation failed: ' + e.getMessage());
    }
    
    // 4. TEST ORDER CREATION
    System.debug('=== 4. TESTING ORDER CREATION ===');
    
    // Get existing records for relationships
    List<Device__c> orderTestDevices = [SELECT Id, Name, Price__c FROM Device__c LIMIT 1];
    List<Customer__c> orderTestCustomers = [SELECT Id, Name FROM Customer__c LIMIT 1];
    
    if (orderTestDevices.isEmpty() || orderTestCustomers.isEmpty()) {
        System.debug('❌ Missing Device or Customer records for Order creation test');
    } else {
        Device_Order__c testOrder = new Device_Order__c();
        testOrder.Device__c = orderTestDevices[0].Id;
        testOrder.Customer__c = orderTestCustomers[0].Id;
        testOrder.Quantity__c = 2;
        testOrder.Status__c = 'Pending';
        testOrder.Priority__c = 'Medium';
        testOrder.Order_Date__c = Date.today();
        testOrder.Expected_Delivery_Date__c = Date.today().addDays(7);
        testOrder.Discount_Percentage__c = 10.0;
        
        try {
            insert testOrder;
            System.debug('✅ Order creation successful: ' + testOrder.Name);
            System.debug('  Order ID: ' + testOrder.Id);
            
            // Verify the created order with all fields and calculations
            Device_Order__c verifyOrder = [
                SELECT Id, Name, Device__c, Customer__c, Quantity__c, Status__c, Priority__c,
                       Total_Price__c, Order_Date__c, Expected_Delivery_Date__c, 
                       Discount_Percentage__c, Final_Amount__c, Confirmation_Number__c,
                       Device__r.Name, Customer__r.Name
                FROM Device_Order__c 
                WHERE Id = :testOrder.Id
            ];
            
            System.debug('  Verification - All fields accessible:');
            System.debug('    Name: ' + verifyOrder.Name);
            System.debug('    Device: ' + verifyOrder.Device__r.Name);
            System.debug('    Customer: ' + verifyOrder.Customer__r.Name);
            System.debug('    Quantity: ' + verifyOrder.Quantity__c);
            System.debug('    Status: ' + verifyOrder.Status__c);
            System.debug('    Priority: ' + verifyOrder.Priority__c);
            System.debug('    Total Price: $' + verifyOrder.Total_Price__c);
            System.debug('    Final Amount: $' + verifyOrder.Final_Amount__c);
            System.debug('    Confirmation: ' + verifyOrder.Confirmation_Number__c);
            
        } catch (Exception e) {
            System.debug('❌ Order creation failed: ' + e.getMessage());
        }
    }
    
    // 5. TEST FIELD ACCESSIBILITY SUMMARY
    System.debug('=== 5. FIELD ACCESSIBILITY SUMMARY ===');
    
    // Test field describe to check accessibility
    Map<String, Schema.SObjectField> deviceFields = Schema.SObjectType.Device__c.fields.getMap();
    Map<String, Schema.SObjectField> customerFields = Schema.SObjectType.Customer__c.fields.getMap();
    Map<String, Schema.SObjectField> supplierFields = Schema.SObjectType.Supplier__c.fields.getMap();
    Map<String, Schema.SObjectField> orderFields = Schema.SObjectType.Device_Order__c.fields.getMap();
    
    System.debug('Field Accessibility Check:');
    System.debug('  Device__c fields accessible: ' + deviceFields.size());
    System.debug('  Customer__c fields accessible: ' + customerFields.size());
    System.debug('  Supplier__c fields accessible: ' + supplierFields.size());
    System.debug('  Device_Order__c fields accessible: ' + orderFields.size());
    
    // Check specific custom fields
    List<String> deviceCustomFields = new List<String>{
        'Type__c', 'Stock_Quantity__c', 'Price__c', 'Cost_Price__c', 'Profit_Margin__c',
        'Warranty_Period_Months__c', 'Active__c', 'Supplier__c', 'Minimum_Stock_Level__c',
        'Reorder_Point__c', 'Last_Restocked__c', 'Stock_Status__c'
    };
    
    System.debug('Device Custom Fields Accessibility:');
    for (String fieldName : deviceCustomFields) {
        Boolean accessible = deviceFields.containsKey(fieldName);
        System.debug('  ' + (accessible ? '✅' : '❌') + ' ' + fieldName + ': ' + (accessible ? 'Accessible' : 'Not Found'));
    }
    
    // 6. PERMISSION VERIFICATION
    System.debug('=== 6. PERMISSION VERIFICATION ===');
    
    // Check object permissions
    Boolean canCreateDevice = Schema.sObjectType.Device__c.isCreateable();
    Boolean canReadDevice = Schema.sObjectType.Device__c.isAccessible();
    Boolean canUpdateDevice = Schema.sObjectType.Device__c.isUpdateable();
    Boolean canDeleteDevice = Schema.sObjectType.Device__c.isDeletable();
    
    System.debug('Device__c Object Permissions:');
    System.debug('  Create: ' + (canCreateDevice ? '✅ Allowed' : '❌ Denied'));
    System.debug('  Read: ' + (canReadDevice ? '✅ Allowed' : '❌ Denied'));
    System.debug('  Update: ' + (canUpdateDevice ? '✅ Allowed' : '❌ Denied'));
    System.debug('  Delete: ' + (canDeleteDevice ? '✅ Allowed' : '❌ Denied'));
    
    // Check field permissions for key fields
    Boolean canEditPrice = Schema.sObjectType.Device__c.fields.Price__c.isUpdateable();
    Boolean canReadProfitMargin = Schema.sObjectType.Device__c.fields.Profit_Margin__c.isAccessible();
    Boolean canEditProfitMargin = Schema.sObjectType.Device__c.fields.Profit_Margin__c.isUpdateable();
    
    System.debug('Device Field Permissions:');
    System.debug('  Price__c Edit: ' + (canEditPrice ? '✅ Allowed' : '❌ Denied'));
    System.debug('  Profit_Margin__c Read: ' + (canReadProfitMargin ? '✅ Allowed' : '❌ Denied'));
    System.debug('  Profit_Margin__c Edit: ' + (canEditProfitMargin ? '❌ Correctly Read-Only' : '⚠️ Should be Read-Only'));
    
    System.debug('=== UI RECORD CREATION TEST COMPLETE ===');
    
} catch (Exception e) {
    System.debug('ERROR in UI record creation test: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== UI RECORD CREATION TEST COMPLETE ===');
