// Field Edit Permission Diagnostic - Investigate Edit Restrictions
System.debug('=== FIELD EDIT PERMISSION DIAGNOSTIC ===');

try {
    // 1. DETAILED FIELD-LEVEL SECURITY ANALYSIS
    System.debug('=== 1. DETAILED FIELD-LEVEL SECURITY ANALYSIS ===');
    
    // Check Device field permissions in detail
    Map<String, Schema.SObjectField> deviceFields = Schema.SObjectType.Device__c.fields.getMap();
    
    List<String> deviceBusinessFields = new List<String>{
        'Type__c', 'Price__c', 'Cost_Price__c', 'Stock_Quantity__c', 'Active__c', 
        'Supplier__c', 'Warranty_Period_Months__c', 'Minimum_Stock_Level__c', 
        'Reorder_Point__c', 'Last_Restocked__c'
    };
    
    System.debug('Device Field Edit Permissions Analysis:');
    for (String fieldName : deviceBusinessFields) {
        if (deviceFields.containsKey(fieldName)) {
            Schema.DescribeFieldResult fieldDesc = deviceFields.get(fieldName).getDescribe();
            System.debug('  ' + fieldName + ':');
            System.debug('    Accessible: ' + fieldDesc.isAccessible());
            System.debug('    Updateable: ' + fieldDesc.isUpdateable());
            System.debug('    Createable: ' + fieldDesc.isCreateable());
            System.debug('    Type: ' + fieldDesc.getType());
            System.debug('    Label: ' + fieldDesc.getLabel());
            System.debug('    Required: ' + fieldDesc.isNillable());
        } else {
            System.debug('  ❌ ' + fieldName + ': Field not found');
        }
    }
    
    // Check formula fields (should be read-only)
    List<String> deviceFormulaFields = new List<String>{'Profit_Margin__c', 'Stock_Status__c'};
    System.debug('Device Formula Fields (Should be Read-Only):');
    for (String fieldName : deviceFormulaFields) {
        if (deviceFields.containsKey(fieldName)) {
            Schema.DescribeFieldResult fieldDesc = deviceFields.get(fieldName).getDescribe();
            System.debug('  ' + fieldName + ':');
            System.debug('    Accessible: ' + fieldDesc.isAccessible());
            System.debug('    Updateable: ' + fieldDesc.isUpdateable() + ' (Should be false)');
            System.debug('    Type: ' + fieldDesc.getType());
        }
    }
    
    // 2. PERMISSION SET ASSIGNMENT VERIFICATION
    System.debug('=== 2. PERMISSION SET ASSIGNMENT VERIFICATION ===');
    
    User currentUser = [SELECT Id, Username, Name, ProfileId, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
    System.debug('Current User: ' + currentUser.Name + ' (' + currentUser.Username + ')');
    System.debug('Profile: ' + currentUser.Profile.Name);
    
    // Check all permission set assignments
    List<PermissionSetAssignment> allPSAssignments = [
        SELECT Id, Assignee.Name, PermissionSet.Name, PermissionSet.Label, PermissionSet.Type
        FROM PermissionSetAssignment 
        WHERE AssigneeId = :currentUser.Id
    ];
    
    System.debug('All Permission Set Assignments:');
    if (allPSAssignments.isEmpty()) {
        System.debug('  ❌ No permission sets assigned to user');
    } else {
        for (PermissionSetAssignment psa : allPSAssignments) {
            System.debug('  ✅ ' + psa.PermissionSet.Label + ' (' + psa.PermissionSet.Name + ') - Type: ' + psa.PermissionSet.Type);
        }
    }
    
    // 3. OBJECT-LEVEL PERMISSION VERIFICATION
    System.debug('=== 3. OBJECT-LEVEL PERMISSION VERIFICATION ===');
    
    System.debug('Object Permissions:');
    System.debug('  Device__c:');
    System.debug('    Accessible: ' + Schema.sObjectType.Device__c.isAccessible());
    System.debug('    Createable: ' + Schema.sObjectType.Device__c.isCreateable());
    System.debug('    Updateable: ' + Schema.sObjectType.Device__c.isUpdateable());
    System.debug('    Deletable: ' + Schema.sObjectType.Device__c.isDeletable());
    
    System.debug('  Customer__c:');
    System.debug('    Accessible: ' + Schema.sObjectType.Customer__c.isAccessible());
    System.debug('    Createable: ' + Schema.sObjectType.Customer__c.isCreateable());
    System.debug('    Updateable: ' + Schema.sObjectType.Customer__c.isUpdateable());
    System.debug('    Deletable: ' + Schema.sObjectType.Customer__c.isDeletable());
    
    System.debug('  Supplier__c:');
    System.debug('    Accessible: ' + Schema.sObjectType.Supplier__c.isAccessible());
    System.debug('    Createable: ' + Schema.sObjectType.Supplier__c.isCreateable());
    System.debug('    Updateable: ' + Schema.sObjectType.Supplier__c.isUpdateable());
    System.debug('    Deletable: ' + Schema.sObjectType.Supplier__c.isDeletable());
    
    System.debug('  Device_Order__c:');
    System.debug('    Accessible: ' + Schema.sObjectType.Device_Order__c.isAccessible());
    System.debug('    Createable: ' + Schema.sObjectType.Device_Order__c.isCreateable());
    System.debug('    Updateable: ' + Schema.sObjectType.Device_Order__c.isUpdateable());
    System.debug('    Deletable: ' + Schema.sObjectType.Device_Order__c.isDeletable());
    
    // 4. RECORD VISIBILITY TEST FOR ALL OBJECTS
    System.debug('=== 4. RECORD VISIBILITY TEST FOR ALL OBJECTS ===');
    
    try {
        Integer deviceCount = [SELECT COUNT() FROM Device__c];
        System.debug('✅ Device__c: ' + deviceCount + ' records accessible');
        
        if (deviceCount > 0) {
            List<Device__c> sampleDevices = [SELECT Id, Name, Type__c, Price__c FROM Device__c LIMIT 2];
            System.debug('  Sample Device Records:');
            for (Device__c device : sampleDevices) {
                System.debug('    - ' + device.Name + ' (ID: ' + device.Id + ')');
            }
        }
    } catch (Exception e) {
        System.debug('❌ Device__c access error: ' + e.getMessage());
    }
    
    try {
        Integer customerCount = [SELECT COUNT() FROM Customer__c];
        System.debug('✅ Customer__c: ' + customerCount + ' records accessible');
        
        if (customerCount > 0) {
            List<Customer__c> sampleCustomers = [SELECT Id, Name, Customer_Type__c FROM Customer__c LIMIT 2];
            System.debug('  Sample Customer Records:');
            for (Customer__c customer : sampleCustomers) {
                System.debug('    - ' + customer.Name + ' (ID: ' + customer.Id + ')');
            }
        } else {
            System.debug('  ⚠️ No Customer records found - may indicate visibility issue');
        }
    } catch (Exception e) {
        System.debug('❌ Customer__c access error: ' + e.getMessage());
    }
    
    try {
        Integer supplierCount = [SELECT COUNT() FROM Supplier__c];
        System.debug('✅ Supplier__c: ' + supplierCount + ' records accessible');
        
        if (supplierCount > 0) {
            List<Supplier__c> sampleSuppliers = [SELECT Id, Name, Company_Name__c FROM Supplier__c LIMIT 2];
            System.debug('  Sample Supplier Records:');
            for (Supplier__c supplier : sampleSuppliers) {
                System.debug('    - ' + supplier.Name + ' (ID: ' + supplier.Id + ')');
            }
        } else {
            System.debug('  ⚠️ No Supplier records found - may indicate visibility issue');
        }
    } catch (Exception e) {
        System.debug('❌ Supplier__c access error: ' + e.getMessage());
    }
    
    try {
        Integer orderCount = [SELECT COUNT() FROM Device_Order__c];
        System.debug('✅ Device_Order__c: ' + orderCount + ' records accessible');
        
        if (orderCount > 0) {
            List<Device_Order__c> sampleOrders = [SELECT Id, Name, Status__c FROM Device_Order__c LIMIT 2];
            System.debug('  Sample Order Records:');
            for (Device_Order__c order : sampleOrders) {
                System.debug('    - ' + order.Name + ' (ID: ' + order.Id + ')');
            }
        } else {
            System.debug('  ⚠️ No Order records found - may indicate visibility issue');
        }
    } catch (Exception e) {
        System.debug('❌ Device_Order__c access error: ' + e.getMessage());
    }
    
    // 5. TEST RECORD EDITING CAPABILITY
    System.debug('=== 5. TEST RECORD EDITING CAPABILITY ===');
    
    // Try to update a Device record to test edit permissions
    List<Device__c> testDevices = [SELECT Id, Name, Type__c, Price__c, Active__c FROM Device__c LIMIT 1];
    if (!testDevices.isEmpty()) {
        Device__c testDevice = testDevices[0];
        System.debug('Testing edit capability on Device: ' + testDevice.Name);
        
        // Store original values
        String originalType = testDevice.Type__c;
        Decimal originalPrice = testDevice.Price__c;
        Boolean originalActive = testDevice.Active__c;
        
        // Try to update fields
        testDevice.Type__c = 'Test Edit Type';
        testDevice.Price__c = 999.99;
        testDevice.Active__c = !originalActive;
        
        try {
            update testDevice;
            System.debug('✅ Device record update successful');
            
            // Restore original values
            testDevice.Type__c = originalType;
            testDevice.Price__c = originalPrice;
            testDevice.Active__c = originalActive;
            update testDevice;
            System.debug('✅ Device record restored to original values');
            
        } catch (Exception e) {
            System.debug('❌ Device record update failed: ' + e.getMessage());
            System.debug('This indicates field-level security or validation issues');
        }
    } else {
        System.debug('❌ No Device records available for edit testing');
    }
    
    // 6. PROFILE PERMISSION ANALYSIS
    System.debug('=== 6. PROFILE PERMISSION ANALYSIS ===');
    
    // Check if user has System Administrator profile
    if (currentUser.Profile.Name.contains('System Administrator')) {
        System.debug('✅ User has System Administrator profile - should have full access');
    } else {
        System.debug('⚠️ User profile: ' + currentUser.Profile.Name + ' - may need permission sets');
    }
    
    // 7. RECOMMENDATIONS
    System.debug('=== 7. DIAGNOSTIC RECOMMENDATIONS ===');
    
    System.debug('Based on diagnostic results:');
    System.debug('1. Check if TechSolutions_Admin permission set is properly assigned');
    System.debug('2. Verify field-level security permissions in permission set');
    System.debug('3. Ensure page layout field behaviors are set to "Edit" not "Readonly"');
    System.debug('4. Check for any validation rules blocking field updates');
    System.debug('5. Verify all objects have proper sharing settings');
    
    System.debug('=== FIELD EDIT PERMISSION DIAGNOSTIC COMPLETE ===');
    
} catch (Exception e) {
    System.debug('ERROR in field edit permission diagnostic: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== FIELD EDIT PERMISSION DIAGNOSTIC COMPLETE ===');
