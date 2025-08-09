// Comprehensive Permission Fix - Resolve Edit and Visibility Issues
System.debug('=== COMPREHENSIVE PERMISSION FIX ===');

try {
    // 1. FORCE PERMISSION SET ASSIGNMENT
    System.debug('=== 1. FORCE PERMISSION SET ASSIGNMENT ===');
    
    User currentUser = [SELECT Id, Username, Name FROM User WHERE Id = :UserInfo.getUserId()];
    System.debug('Current User: ' + currentUser.Name + ' (' + currentUser.Username + ')');
    
    // Find TechSolutions_Admin permission set
    List<PermissionSet> techPS = [SELECT Id, Name, Label FROM PermissionSet WHERE Name = 'TechSolutions_Admin'];
    
    if (techPS.isEmpty()) {
        System.debug('❌ TechSolutions_Admin permission set not found');
        return;
    }
    
    PermissionSet ps = techPS[0];
    System.debug('Found Permission Set: ' + ps.Label);
    
    // Remove existing assignment if any
    List<PermissionSetAssignment> existingAssignments = [
        SELECT Id FROM PermissionSetAssignment 
        WHERE AssigneeId = :currentUser.Id AND PermissionSetId = :ps.Id
    ];
    
    if (!existingAssignments.isEmpty()) {
        delete existingAssignments;
        System.debug('Removed existing permission set assignment');
    }
    
    // Create fresh assignment
    PermissionSetAssignment psa = new PermissionSetAssignment();
    psa.AssigneeId = currentUser.Id;
    psa.PermissionSetId = ps.Id;
    
    insert psa;
    System.debug('✅ Fresh permission set assignment created');
    
    // 2. VERIFY OBJECT ACCESS AFTER ASSIGNMENT
    System.debug('=== 2. VERIFY OBJECT ACCESS AFTER ASSIGNMENT ===');
    
    System.debug('Object Access Verification:');
    System.debug('  Device__c - Create: ' + Schema.sObjectType.Device__c.isCreateable() + 
                 ', Read: ' + Schema.sObjectType.Device__c.isAccessible() + 
                 ', Update: ' + Schema.sObjectType.Device__c.isUpdateable());
    System.debug('  Customer__c - Create: ' + Schema.sObjectType.Customer__c.isCreateable() + 
                 ', Read: ' + Schema.sObjectType.Customer__c.isAccessible() + 
                 ', Update: ' + Schema.sObjectType.Customer__c.isUpdateable());
    System.debug('  Supplier__c - Create: ' + Schema.sObjectType.Supplier__c.isCreateable() + 
                 ', Read: ' + Schema.sObjectType.Supplier__c.isAccessible() + 
                 ', Update: ' + Schema.sObjectType.Supplier__c.isUpdateable());
    System.debug('  Device_Order__c - Create: ' + Schema.sObjectType.Device_Order__c.isCreateable() + 
                 ', Read: ' + Schema.sObjectType.Device_Order__c.isAccessible() + 
                 ', Update: ' + Schema.sObjectType.Device_Order__c.isUpdateable());
    
    // 3. VERIFY FIELD ACCESS
    System.debug('=== 3. VERIFY FIELD ACCESS ===');
    
    // Check key Device fields
    Map<String, Schema.SObjectField> deviceFields = Schema.SObjectType.Device__c.fields.getMap();
    List<String> keyFields = new List<String>{'Type__c', 'Price__c', 'Stock_Quantity__c', 'Active__c'};
    
    System.debug('Device Field Access:');
    for (String fieldName : keyFields) {
        if (deviceFields.containsKey(fieldName)) {
            Schema.DescribeFieldResult fieldDesc = deviceFields.get(fieldName).getDescribe();
            System.debug('  ' + fieldName + ' - Accessible: ' + fieldDesc.isAccessible() + 
                         ', Updateable: ' + fieldDesc.isUpdateable());
        }
    }
    
    // 4. TEST RECORD CREATION FOR ALL OBJECTS
    System.debug('=== 4. TEST RECORD CREATION FOR ALL OBJECTS ===');
    
    // Test Device creation
    if (Schema.sObjectType.Device__c.isCreateable()) {
        Device__c testDevice = new Device__c();
        testDevice.Name = 'Permission Test Device - ' + DateTime.now().format('HH:mm:ss');
        testDevice.Type__c = 'Test Equipment';
        testDevice.Price__c = 100.00;
        testDevice.Stock_Quantity__c = 10;
        testDevice.Active__c = true;
        
        try {
            insert testDevice;
            System.debug('✅ Device creation successful: ' + testDevice.Id);
            
            // Test update
            testDevice.Price__c = 150.00;
            update testDevice;
            System.debug('✅ Device update successful');
            
        } catch (Exception e) {
            System.debug('❌ Device creation/update failed: ' + e.getMessage());
        }
    } else {
        System.debug('❌ Device creation not allowed');
    }
    
    // Test Customer creation
    if (Schema.sObjectType.Customer__c.isCreateable()) {
        Customer__c testCustomer = new Customer__c();
        testCustomer.Name = 'Permission Test Customer - ' + DateTime.now().format('HH:mm:ss');
        testCustomer.Customer_Type__c = 'Individual';
        testCustomer.Customer_Status__c = 'Active';
        testCustomer.Email__c = 'test@permission.com';
        testCustomer.Credit_Limit__c = 5000;
        
        try {
            insert testCustomer;
            System.debug('✅ Customer creation successful: ' + testCustomer.Id);
        } catch (Exception e) {
            System.debug('❌ Customer creation failed: ' + e.getMessage());
        }
    } else {
        System.debug('❌ Customer creation not allowed');
    }
    
    // Test Supplier creation
    if (Schema.sObjectType.Supplier__c.isCreateable()) {
        Supplier__c testSupplier = new Supplier__c();
        testSupplier.Name = 'Permission Test Supplier - ' + DateTime.now().format('HH:mm:ss');
        testSupplier.Company_Name__c = 'Test Supplier Inc.';
        testSupplier.Contact_Person__c = 'Test Contact';
        testSupplier.Email__c = 'supplier@permission.com';
        testSupplier.Country__c = 'United States';
        testSupplier.Supplier_Rating__c = 'Good';
        testSupplier.Active__c = true;
        
        try {
            insert testSupplier;
            System.debug('✅ Supplier creation successful: ' + testSupplier.Id);
        } catch (Exception e) {
            System.debug('❌ Supplier creation failed: ' + e.getMessage());
        }
    } else {
        System.debug('❌ Supplier creation not allowed');
    }
    
    // Test Order creation
    List<Device__c> existingDevices = [SELECT Id FROM Device__c LIMIT 1];
    List<Customer__c> existingCustomers = [SELECT Id FROM Customer__c LIMIT 1];
    
    if (Schema.sObjectType.Device_Order__c.isCreateable() && !existingDevices.isEmpty() && !existingCustomers.isEmpty()) {
        Device_Order__c testOrder = new Device_Order__c();
        testOrder.Device__c = existingDevices[0].Id;
        testOrder.Customer__c = existingCustomers[0].Id;
        testOrder.Quantity__c = 2;
        testOrder.Status__c = 'Pending';
        testOrder.Priority__c = 'Medium';
        testOrder.Order_Date__c = Date.today();
        testOrder.Expected_Delivery_Date__c = Date.today().addDays(7);
        testOrder.Discount_Percentage__c = 5.0;
        
        try {
            insert testOrder;
            System.debug('✅ Order creation successful: ' + testOrder.Id);
        } catch (Exception e) {
            System.debug('❌ Order creation failed: ' + e.getMessage());
        }
    } else {
        System.debug('❌ Order creation not allowed or missing related records');
    }
    
    // 5. VERIFY RECORD COUNTS
    System.debug('=== 5. VERIFY RECORD COUNTS ===');
    
    try {
        Integer deviceCount = [SELECT COUNT() FROM Device__c];
        System.debug('Device Records: ' + deviceCount);
        
        Integer customerCount = [SELECT COUNT() FROM Customer__c];
        System.debug('Customer Records: ' + customerCount);
        
        Integer supplierCount = [SELECT COUNT() FROM Supplier__c];
        System.debug('Supplier Records: ' + supplierCount);
        
        Integer orderCount = [SELECT COUNT() FROM Device_Order__c];
        System.debug('Order Records: ' + orderCount);
        
        System.debug('Total Records: ' + (deviceCount + customerCount + supplierCount + orderCount));
        
    } catch (Exception e) {
        System.debug('❌ Error counting records: ' + e.getMessage());
    }
    
    // 6. PROVIDE SAMPLE RECORD IDS FOR UI TESTING
    System.debug('=== 6. SAMPLE RECORD IDS FOR UI TESTING ===');
    
    try {
        List<Device__c> sampleDevices = [SELECT Id, Name FROM Device__c LIMIT 3];
        System.debug('Sample Device Records for UI Testing:');
        for (Device__c device : sampleDevices) {
            System.debug('  ' + device.Name + ' - URL: /lightning/r/Device__c/' + device.Id + '/view');
        }
        
        List<Customer__c> sampleCustomers = [SELECT Id, Name FROM Customer__c LIMIT 3];
        System.debug('Sample Customer Records for UI Testing:');
        for (Customer__c customer : sampleCustomers) {
            System.debug('  ' + customer.Name + ' - URL: /lightning/r/Customer__c/' + customer.Id + '/view');
        }
        
        List<Supplier__c> sampleSuppliers = [SELECT Id, Name FROM Supplier__c LIMIT 3];
        System.debug('Sample Supplier Records for UI Testing:');
        for (Supplier__c supplier : sampleSuppliers) {
            System.debug('  ' + supplier.Name + ' - URL: /lightning/r/Supplier__c/' + supplier.Id + '/view');
        }
        
        List<Device_Order__c> sampleOrders = [SELECT Id, Name FROM Device_Order__c LIMIT 3];
        System.debug('Sample Order Records for UI Testing:');
        for (Device_Order__c order : sampleOrders) {
            System.debug('  ' + order.Name + ' - URL: /lightning/r/Device_Order__c/' + order.Id + '/view');
        }
        
    } catch (Exception e) {
        System.debug('❌ Error retrieving sample records: ' + e.getMessage());
    }
    
    // 7. UI TESTING INSTRUCTIONS
    System.debug('=== 7. UI TESTING INSTRUCTIONS ===');
    
    System.debug('To test UI functionality after permission fix:');
    System.debug('1. Open Salesforce org: sf org open --target-org GTP5org');
    System.debug('2. Navigate to App Launcher → TechSolutionApp');
    System.debug('3. Test each tab: Device, Customer, Supplier, Device Order');
    System.debug('4. Verify records are visible in list views');
    System.debug('5. Click on records to view detail pages');
    System.debug('6. Click "Edit" button and verify fields are editable');
    System.debug('7. Try creating new records using "New" button');
    System.debug('8. Test saving changes to verify full CRUD functionality');
    
    System.debug('=== COMPREHENSIVE PERMISSION FIX COMPLETE ===');
    
} catch (Exception e) {
    System.debug('ERROR in comprehensive permission fix: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== COMPREHENSIVE PERMISSION FIX COMPLETE ===');
