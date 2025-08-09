// Fix Edit Permissions - Resolve Field Edit Restrictions
System.debug('=== FIX EDIT PERMISSIONS ===');

try {
    // 1. VERIFY CURRENT USER AND PERMISSIONS
    System.debug('=== 1. VERIFY CURRENT USER AND PERMISSIONS ===');
    
    User currentUser = [SELECT Id, Username, Name, ProfileId, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
    System.debug('Current User: ' + currentUser.Name);
    System.debug('Username: ' + currentUser.Username);
    System.debug('Profile: ' + currentUser.Profile.Name);
    
    // Check if user is System Administrator
    Boolean isSystemAdmin = currentUser.Profile.Name.contains('System Administrator');
    System.debug('Is System Administrator: ' + isSystemAdmin);
    
    // 2. ASSIGN PERMISSION SET WITH FORCE
    System.debug('=== 2. ASSIGN PERMISSION SET WITH FORCE ===');
    
    List<PermissionSet> techPS = [SELECT Id, Name, Label FROM PermissionSet WHERE Name = 'TechSolutions_Admin'];
    
    if (!techPS.isEmpty()) {
        PermissionSet ps = techPS[0];
        System.debug('Found Permission Set: ' + ps.Label);
        
        // Delete any existing assignments
        List<PermissionSetAssignment> existingAssignments = [
            SELECT Id FROM PermissionSetAssignment 
            WHERE AssigneeId = :currentUser.Id AND PermissionSetId = :ps.Id
        ];
        
        if (!existingAssignments.isEmpty()) {
            delete existingAssignments;
            System.debug('Removed existing assignment');
        }
        
        // Create new assignment
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = currentUser.Id;
        psa.PermissionSetId = ps.Id;
        
        insert psa;
        System.debug('✅ Permission set assigned successfully');
        
        // Verify assignment
        List<PermissionSetAssignment> verifyAssignment = [
            SELECT Id, Assignee.Name, PermissionSet.Label
            FROM PermissionSetAssignment 
            WHERE AssigneeId = :currentUser.Id AND PermissionSetId = :ps.Id
        ];
        
        if (!verifyAssignment.isEmpty()) {
            System.debug('✅ Assignment verified: ' + verifyAssignment[0].PermissionSet.Label);
        } else {
            System.debug('❌ Assignment verification failed');
        }
        
    } else {
        System.debug('❌ TechSolutions_Admin permission set not found');
    }
    
    // 3. TEST FIELD EDIT PERMISSIONS
    System.debug('=== 3. TEST FIELD EDIT PERMISSIONS ===');
    
    // Test Device field permissions
    Map<String, Schema.SObjectField> deviceFields = Schema.SObjectType.Device__c.fields.getMap();
    List<String> testFields = new List<String>{'Type__c', 'Price__c', 'Stock_Quantity__c', 'Active__c'};
    
    System.debug('Device Field Edit Test:');
    for (String fieldName : testFields) {
        if (deviceFields.containsKey(fieldName)) {
            Schema.DescribeFieldResult fieldDesc = deviceFields.get(fieldName).getDescribe();
            System.debug('  ' + fieldName + ': Updateable=' + fieldDesc.isUpdateable() + 
                         ', Accessible=' + fieldDesc.isAccessible());
        }
    }
    
    // 4. TEST ACTUAL RECORD EDITING
    System.debug('=== 4. TEST ACTUAL RECORD EDITING ===');
    
    List<Device__c> testDevices = [SELECT Id, Name, Type__c, Price__c, Active__c FROM Device__c LIMIT 1];
    
    if (!testDevices.isEmpty()) {
        Device__c testDevice = testDevices[0];
        System.debug('Testing edit on Device: ' + testDevice.Name);
        
        // Store original values
        String originalType = testDevice.Type__c;
        Decimal originalPrice = testDevice.Price__c;
        
        // Try to update
        testDevice.Type__c = 'Edit Test Type';
        testDevice.Price__c = 999.99;
        
        try {
            update testDevice;
            System.debug('✅ Device edit successful');
            
            // Verify the update
            Device__c verifyDevice = [SELECT Id, Type__c, Price__c FROM Device__c WHERE Id = :testDevice.Id];
            System.debug('  Updated Type: ' + verifyDevice.Type__c);
            System.debug('  Updated Price: $' + verifyDevice.Price__c);
            
            // Restore original values
            testDevice.Type__c = originalType;
            testDevice.Price__c = originalPrice;
            update testDevice;
            System.debug('✅ Device restored to original values');
            
        } catch (Exception e) {
            System.debug('❌ Device edit failed: ' + e.getMessage());
            System.debug('Error details: ' + e.getStackTraceString());
        }
    } else {
        System.debug('❌ No Device records available for edit testing');
    }
    
    // 5. VERIFY ALL OBJECT RECORD COUNTS
    System.debug('=== 5. VERIFY ALL OBJECT RECORD COUNTS ===');
    
    Integer deviceCount = [SELECT COUNT() FROM Device__c];
    Integer customerCount = [SELECT COUNT() FROM Customer__c];
    Integer supplierCount = [SELECT COUNT() FROM Supplier__c];
    Integer orderCount = [SELECT COUNT() FROM Device_Order__c];
    
    System.debug('Current Record Counts:');
    System.debug('  Devices: ' + deviceCount + ' (Target: 15+)');
    System.debug('  Customers: ' + customerCount + ' (Target: 8+)');
    System.debug('  Suppliers: ' + supplierCount + ' (Target: 6+)');
    System.debug('  Orders: ' + orderCount + ' (Target: 20+)');
    
    // 6. PROVIDE UI TESTING INSTRUCTIONS
    System.debug('=== 6. UI TESTING INSTRUCTIONS ===');
    
    System.debug('To test edit functionality:');
    System.debug('1. Open Salesforce org: sf org open --target-org GTP5org');
    System.debug('2. Navigate to TechSolutionApp');
    System.debug('3. Go to Device tab');
    System.debug('4. Click on a Device record');
    System.debug('5. Click "Edit" button');
    System.debug('6. Try editing Type, Price, Stock Quantity fields');
    System.debug('7. Click "Save" to test update functionality');
    System.debug('8. Repeat for Customer, Supplier, and Order tabs');
    
    // Provide specific record URLs for testing
    if (deviceCount > 0) {
        List<Device__c> testDevices = [SELECT Id, Name FROM Device__c LIMIT 2];
        System.debug('Device Records for Edit Testing:');
        for (Device__c device : testDevices) {
            System.debug('  ' + device.Name + ': /lightning/r/Device__c/' + device.Id + '/view');
        }
    }
    
    if (customerCount > 0) {
        List<Customer__c> testCustomers = [SELECT Id, Name FROM Customer__c LIMIT 2];
        System.debug('Customer Records for Edit Testing:');
        for (Customer__c customer : testCustomers) {
            System.debug('  ' + customer.Name + ': /lightning/r/Customer__c/' + customer.Id + '/view');
        }
    }
    
    System.debug('=== FIX EDIT PERMISSIONS COMPLETE ===');
    
} catch (Exception e) {
    System.debug('ERROR in fix edit permissions: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== FIX EDIT PERMISSIONS COMPLETE ===');
