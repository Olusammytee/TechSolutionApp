// Page Layout and Data Rendering Diagnostic Script
System.debug('=== PAGE LAYOUT AND DATA RENDERING DIAGNOSTIC ===');

try {
    // 1. VERIFY RECORD EXISTENCE AND BASIC DATA ACCESS
    System.debug('=== 1. RECORD EXISTENCE VERIFICATION ===');
    
    Integer deviceCount = [SELECT COUNT() FROM Device__c];
    Integer customerCount = [SELECT COUNT() FROM Customer__c];
    Integer supplierCount = [SELECT COUNT() FROM Supplier__c];
    Integer orderCount = [SELECT COUNT() FROM Device_Order__c];
    
    System.debug('Record Counts in Database:');
    System.debug('  Devices: ' + deviceCount);
    System.debug('  Customers: ' + customerCount);
    System.debug('  Suppliers: ' + supplierCount);
    System.debug('  Orders: ' + orderCount);
    
    if (deviceCount == 0 || customerCount == 0 || supplierCount == 0 || orderCount == 0) {
        System.debug('❌ CRITICAL: Missing records in one or more objects');
        return;
    }
    
    // 2. FIELD ACCESSIBILITY DIAGNOSTIC
    System.debug('=== 2. FIELD ACCESSIBILITY DIAGNOSTIC ===');
    
    // Test Device field access with comprehensive field list
    try {
        List<Device__c> deviceTest = [
            SELECT Id, Name, Type__c, Stock_Quantity__c, Price__c, Cost_Price__c, 
                   Profit_Margin__c, Warranty_Period_Months__c, Active__c, Supplier__c,
                   Minimum_Stock_Level__c, Reorder_Point__c, Last_Restocked__c, Stock_Status__c
            FROM Device__c 
            LIMIT 1
        ];
        
        if (!deviceTest.isEmpty()) {
            System.debug('✅ Device fields accessible via SOQL');
            Device__c device = deviceTest[0];
            System.debug('  Sample Device: ' + device.Name);
            System.debug('  Type: ' + device.Type__c);
            System.debug('  Price: $' + device.Price__c);
            System.debug('  Stock: ' + device.Stock_Quantity__c);
            System.debug('  Status: ' + device.Stock_Status__c);
        } else {
            System.debug('❌ No Device records returned');
        }
    } catch (Exception e) {
        System.debug('❌ Device field access error: ' + e.getMessage());
    }
    
    // Test Customer field access
    try {
        List<Customer__c> customerTest = [
            SELECT Id, Name, Email__c, Phone__c, Address__c, Customer_Type__c, 
                   Customer_Status__c, Credit_Limit__c
            FROM Customer__c 
            LIMIT 1
        ];
        
        if (!customerTest.isEmpty()) {
            System.debug('✅ Customer fields accessible via SOQL');
            Customer__c customer = customerTest[0];
            System.debug('  Sample Customer: ' + customer.Name);
            System.debug('  Type: ' + customer.Customer_Type__c);
            System.debug('  Status: ' + customer.Customer_Status__c);
        } else {
            System.debug('❌ No Customer records returned');
        }
    } catch (Exception e) {
        System.debug('❌ Customer field access error: ' + e.getMessage());
    }
    
    // Test Supplier field access
    try {
        List<Supplier__c> supplierTest = [
            SELECT Id, Name, Company_Name__c, Contact_Person__c, Email__c, Phone__c,
                   Country__c, Supplier_Rating__c, Active__c
            FROM Supplier__c 
            LIMIT 1
        ];
        
        if (!supplierTest.isEmpty()) {
            System.debug('✅ Supplier fields accessible via SOQL');
            Supplier__c supplier = supplierTest[0];
            System.debug('  Sample Supplier: ' + supplier.Name);
            System.debug('  Company: ' + supplier.Company_Name__c);
            System.debug('  Rating: ' + supplier.Supplier_Rating__c);
        } else {
            System.debug('❌ No Supplier records returned');
        }
    } catch (Exception e) {
        System.debug('❌ Supplier field access error: ' + e.getMessage());
    }
    
    // Test Order field access
    try {
        List<Device_Order__c> orderTest = [
            SELECT Id, Name, Device__c, Customer__c, Quantity__c, Status__c, Priority__c,
                   Total_Price__c, Order_Date__c, Expected_Delivery_Date__c, 
                   Discount_Percentage__c, Final_Amount__c, Confirmation_Number__c
            FROM Device_Order__c 
            LIMIT 1
        ];
        
        if (!orderTest.isEmpty()) {
            System.debug('✅ Order fields accessible via SOQL');
            Device_Order__c order = orderTest[0];
            System.debug('  Sample Order: ' + order.Name);
            System.debug('  Status: ' + order.Status__c);
            System.debug('  Priority: ' + order.Priority__c);
            System.debug('  Final Amount: $' + order.Final_Amount__c);
        } else {
            System.debug('❌ No Order records returned');
        }
    } catch (Exception e) {
        System.debug('❌ Order field access error: ' + e.getMessage());
    }
    
    // 3. PERMISSION DIAGNOSTIC
    System.debug('=== 3. PERMISSION DIAGNOSTIC ===');
    
    // Check object-level permissions
    Boolean deviceCreateable = Schema.sObjectType.Device__c.isCreateable();
    Boolean deviceAccessible = Schema.sObjectType.Device__c.isAccessible();
    Boolean deviceUpdateable = Schema.sObjectType.Device__c.isUpdateable();
    
    System.debug('Device__c Object Permissions:');
    System.debug('  Createable: ' + deviceCreateable);
    System.debug('  Accessible: ' + deviceAccessible);
    System.debug('  Updateable: ' + deviceUpdateable);
    
    // Check field-level permissions for key fields
    Boolean priceEditable = Schema.sObjectType.Device__c.fields.Price__c.isUpdateable();
    Boolean priceAccessible = Schema.sObjectType.Device__c.fields.Price__c.isAccessible();
    Boolean typeEditable = Schema.sObjectType.Device__c.fields.Type__c.isUpdateable();
    Boolean typeAccessible = Schema.sObjectType.Device__c.fields.Type__c.isAccessible();
    
    System.debug('Device Field Permissions:');
    System.debug('  Price__c - Accessible: ' + priceAccessible + ', Editable: ' + priceEditable);
    System.debug('  Type__c - Accessible: ' + typeAccessible + ', Editable: ' + typeEditable);
    
    // 4. USER AND PERMISSION SET DIAGNOSTIC
    System.debug('=== 4. USER AND PERMISSION SET DIAGNOSTIC ===');
    
    User currentUser = [SELECT Id, Username, Name, ProfileId, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
    System.debug('Current User: ' + currentUser.Name + ' (' + currentUser.Username + ')');
    System.debug('Profile: ' + currentUser.Profile.Name);
    
    // Check permission set assignments
    List<PermissionSetAssignment> psAssignments = [
        SELECT Id, Assignee.Name, PermissionSet.Name, PermissionSet.Label
        FROM PermissionSetAssignment 
        WHERE AssigneeId = :currentUser.Id
    ];
    
    System.debug('Permission Set Assignments:');
    if (psAssignments.isEmpty()) {
        System.debug('  ❌ No permission sets assigned');
    } else {
        for (PermissionSetAssignment psa : psAssignments) {
            System.debug('  ✅ ' + psa.PermissionSet.Label + ' (' + psa.PermissionSet.Name + ')');
        }
    }
    
    // 5. RECORD TYPE DIAGNOSTIC
    System.debug('=== 5. RECORD TYPE DIAGNOSTIC ===');
    
    // Check if record types exist for our objects
    List<RecordType> deviceRecordTypes = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Device__c'];
    List<RecordType> customerRecordTypes = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Customer__c'];
    
    System.debug('Record Types:');
    System.debug('  Device__c Record Types: ' + deviceRecordTypes.size());
    for (RecordType rt : deviceRecordTypes) {
        System.debug('    - ' + rt.Name + ' (' + rt.DeveloperName + ')');
    }
    
    System.debug('  Customer__c Record Types: ' + customerRecordTypes.size());
    for (RecordType rt : customerRecordTypes) {
        System.debug('    - ' + rt.Name + ' (' + rt.DeveloperName + ')');
    }
    
    // 6. SAMPLE RECORD DETAILS FOR UI TESTING
    System.debug('=== 6. SAMPLE RECORD DETAILS FOR UI TESTING ===');
    
    // Get sample record IDs for manual UI testing
    List<Device__c> sampleDevices = [SELECT Id, Name FROM Device__c LIMIT 3];
    List<Customer__c> sampleCustomers = [SELECT Id, Name FROM Customer__c LIMIT 3];
    List<Supplier__c> sampleSuppliers = [SELECT Id, Name FROM Supplier__c LIMIT 3];
    List<Device_Order__c> sampleOrders = [SELECT Id, Name FROM Device_Order__c LIMIT 3];
    
    System.debug('Sample Record IDs for UI Testing:');
    System.debug('Devices:');
    for (Device__c device : sampleDevices) {
        System.debug('  ' + device.Name + ' - ID: ' + device.Id);
    }
    
    System.debug('Customers:');
    for (Customer__c customer : sampleCustomers) {
        System.debug('  ' + customer.Name + ' - ID: ' + customer.Id);
    }
    
    System.debug('Suppliers:');
    for (Supplier__c supplier : sampleSuppliers) {
        System.debug('  ' + supplier.Name + ' - ID: ' + supplier.Id);
    }
    
    System.debug('Orders:');
    for (Device_Order__c order : sampleOrders) {
        System.debug('  ' + order.Name + ' - ID: ' + order.Id);
    }
    
    // 7. FIELD DESCRIBE INFORMATION
    System.debug('=== 7. FIELD DESCRIBE INFORMATION ===');
    
    Map<String, Schema.SObjectField> deviceFields = Schema.SObjectType.Device__c.fields.getMap();
    System.debug('Device__c Total Fields Available: ' + deviceFields.size());
    
    // List key custom fields
    List<String> keyDeviceFields = new List<String>{
        'Type__c', 'Stock_Quantity__c', 'Price__c', 'Cost_Price__c', 'Profit_Margin__c',
        'Warranty_Period_Months__c', 'Active__c', 'Supplier__c'
    };
    
    System.debug('Key Device Custom Fields Status:');
    for (String fieldName : keyDeviceFields) {
        if (deviceFields.containsKey(fieldName)) {
            Schema.DescribeFieldResult fieldDescribe = deviceFields.get(fieldName).getDescribe();
            System.debug('  ✅ ' + fieldName + ' - Label: ' + fieldDescribe.getLabel() + 
                         ', Type: ' + fieldDescribe.getType() + 
                         ', Accessible: ' + fieldDescribe.isAccessible() + 
                         ', Updateable: ' + fieldDescribe.isUpdateable());
        } else {
            System.debug('  ❌ ' + fieldName + ' - Field not found');
        }
    }
    
    System.debug('=== DIAGNOSTIC COMPLETE ===');
    
} catch (Exception e) {
    System.debug('ERROR in page layout diagnostic: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== PAGE LAYOUT AND DATA RENDERING DIAGNOSTIC COMPLETE ===');
