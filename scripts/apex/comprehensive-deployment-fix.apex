// Comprehensive Deployment Fix - Assign Permission Set and Verify Access
System.debug('=== COMPREHENSIVE DEPLOYMENT FIX ===');

try {
    // 1. ASSIGN PERMISSION SET TO CURRENT USER
    System.debug('=== 1. PERMISSION SET ASSIGNMENT ===');
    
    User currentUser = [SELECT Id, Username, Name FROM User WHERE Id = :UserInfo.getUserId()];
    System.debug('Current User: ' + currentUser.Name + ' (' + currentUser.Username + ')');
    
    // Check if TechSolutions_Admin permission set exists
    List<PermissionSet> techSolutionsPS = [SELECT Id, Name, Label FROM PermissionSet WHERE Name = 'TechSolutions_Admin'];
    
    if (techSolutionsPS.isEmpty()) {
        System.debug('❌ TechSolutions_Admin permission set not found');
        System.debug('Available permission sets:');
        List<PermissionSet> allPS = [SELECT Id, Name, Label FROM PermissionSet WHERE IsCustom = true];
        for (PermissionSet ps : allPS) {
            System.debug('  - ' + ps.Label + ' (' + ps.Name + ')');
        }
        return;
    }
    
    PermissionSet ps = techSolutionsPS[0];
    System.debug('Found Permission Set: ' + ps.Label + ' (' + ps.Name + ')');
    
    // Check if assignment already exists
    List<PermissionSetAssignment> existingAssignments = [
        SELECT Id, AssigneeId, PermissionSetId 
        FROM PermissionSetAssignment 
        WHERE AssigneeId = :currentUser.Id AND PermissionSetId = :ps.Id
    ];
    
    if (existingAssignments.isEmpty()) {
        // Create new assignment
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = currentUser.Id;
        psa.PermissionSetId = ps.Id;
        
        try {
            insert psa;
            System.debug('✅ Permission Set assigned successfully');
        } catch (Exception e) {
            System.debug('❌ Permission Set assignment failed: ' + e.getMessage());
        }
    } else {
        System.debug('✅ Permission Set already assigned');
    }
    
    // 2. VERIFY OBJECT ACCESS
    System.debug('=== 2. OBJECT ACCESS VERIFICATION ===');
    
    Boolean deviceAccess = Schema.sObjectType.Device__c.isAccessible();
    Boolean customerAccess = Schema.sObjectType.Customer__c.isAccessible();
    Boolean supplierAccess = Schema.sObjectType.Supplier__c.isAccessible();
    Boolean orderAccess = Schema.sObjectType.Device_Order__c.isAccessible();
    
    System.debug('Object Access Status:');
    System.debug('  Device__c: ' + (deviceAccess ? '✅ Accessible' : '❌ Not Accessible'));
    System.debug('  Customer__c: ' + (customerAccess ? '✅ Accessible' : '❌ Not Accessible'));
    System.debug('  Supplier__c: ' + (supplierAccess ? '✅ Accessible' : '❌ Not Accessible'));
    System.debug('  Device_Order__c: ' + (orderAccess ? '✅ Accessible' : '❌ Not Accessible'));
    
    // 3. VERIFY FIELD ACCESS
    System.debug('=== 3. FIELD ACCESS VERIFICATION ===');
    
    // Check Device fields
    Map<String, Schema.SObjectField> deviceFields = Schema.SObjectType.Device__c.fields.getMap();
    List<String> deviceTestFields = new List<String>{'Type__c', 'Price__c', 'Stock_Quantity__c', 'Supplier__c'};
    
    System.debug('Device Field Access:');
    for (String fieldName : deviceTestFields) {
        if (deviceFields.containsKey(fieldName)) {
            Schema.DescribeFieldResult fieldDesc = deviceFields.get(fieldName).getDescribe();
            System.debug('  ' + fieldName + ': Accessible=' + fieldDesc.isAccessible() + 
                         ', Updateable=' + fieldDesc.isUpdateable());
        } else {
            System.debug('  ' + fieldName + ': ❌ Field not found');
        }
    }
    
    // 4. TEST RECORD CREATION
    System.debug('=== 4. RECORD CREATION TEST ===');
    
    // Test creating a simple device record
    if (deviceAccess && Schema.sObjectType.Device__c.isCreateable()) {
        Device__c testDevice = new Device__c();
        testDevice.Name = 'UI Fix Test Device - ' + DateTime.now().format('HH:mm:ss');
        testDevice.Type__c = 'Test Equipment';
        testDevice.Price__c = 100.00;
        testDevice.Stock_Quantity__c = 5;
        testDevice.Active__c = true;
        
        try {
            insert testDevice;
            System.debug('✅ Test Device created successfully: ' + testDevice.Id);
            
            // Verify we can read it back
            Device__c verifyDevice = [SELECT Id, Name, Type__c, Price__c FROM Device__c WHERE Id = :testDevice.Id];
            System.debug('✅ Test Device verified: ' + verifyDevice.Name);
            
        } catch (Exception e) {
            System.debug('❌ Test Device creation failed: ' + e.getMessage());
        }
    } else {
        System.debug('❌ Cannot create Device records - insufficient permissions');
    }
    
    // 5. VERIFY EXISTING DATA ACCESS
    System.debug('=== 5. EXISTING DATA ACCESS VERIFICATION ===');
    
    try {
        Integer deviceCount = [SELECT COUNT() FROM Device__c];
        System.debug('✅ Can query Device__c: ' + deviceCount + ' records found');
        
        if (deviceCount > 0) {
            List<Device__c> sampleDevices = [
                SELECT Id, Name, Type__c, Price__c, Stock_Quantity__c, Active__c
                FROM Device__c 
                LIMIT 3
            ];
            
            System.debug('Sample Device Records:');
            for (Device__c device : sampleDevices) {
                System.debug('  - ' + device.Name + ' (Type: ' + device.Type__c + ', Price: $' + device.Price__c + ')');
            }
        }
    } catch (Exception e) {
        System.debug('❌ Cannot query Device__c: ' + e.getMessage());
    }
    
    try {
        Integer customerCount = [SELECT COUNT() FROM Customer__c];
        System.debug('✅ Can query Customer__c: ' + customerCount + ' records found');
    } catch (Exception e) {
        System.debug('❌ Cannot query Customer__c: ' + e.getMessage());
    }
    
    try {
        Integer supplierCount = [SELECT COUNT() FROM Supplier__c];
        System.debug('✅ Can query Supplier__c: ' + supplierCount + ' records found');
    } catch (Exception e) {
        System.debug('❌ Cannot query Supplier__c: ' + e.getMessage());
    }
    
    try {
        Integer orderCount = [SELECT COUNT() FROM Device_Order__c];
        System.debug('✅ Can query Device_Order__c: ' + orderCount + ' records found');
    } catch (Exception e) {
        System.debug('❌ Cannot query Device_Order__c: ' + e.getMessage());
    }
    
    // 6. PROVIDE UI TESTING GUIDANCE
    System.debug('=== 6. UI TESTING GUIDANCE ===');
    
    System.debug('To test UI functionality:');
    System.debug('1. Open Salesforce org in browser');
    System.debug('2. Navigate to App Launcher (9 dots) → TechSolutionApp');
    System.debug('3. Check tabs: Device, Customer, Supplier, Device Order');
    System.debug('4. Click on each tab to view list views');
    System.debug('5. Click on individual records to view detail pages');
    System.debug('6. Try creating new records using "New" button');
    
    // Get sample record IDs for direct testing
    List<Device__c> testDevices = [SELECT Id, Name FROM Device__c LIMIT 2];
    if (!testDevices.isEmpty()) {
        System.debug('Sample Device URLs for testing:');
        for (Device__c device : testDevices) {
            System.debug('  ' + device.Name + ': /lightning/r/Device__c/' + device.Id + '/view');
        }
    }
    
    List<Customer__c> testCustomers = [SELECT Id, Name FROM Customer__c LIMIT 2];
    if (!testCustomers.isEmpty()) {
        System.debug('Sample Customer URLs for testing:');
        for (Customer__c customer : testCustomers) {
            System.debug('  ' + customer.Name + ': /lightning/r/Customer__c/' + customer.Id + '/view');
        }
    }
    
    System.debug('=== COMPREHENSIVE DEPLOYMENT FIX COMPLETE ===');
    
} catch (Exception e) {
    System.debug('ERROR in deployment fix: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== COMPREHENSIVE DEPLOYMENT FIX COMPLETE ===');
