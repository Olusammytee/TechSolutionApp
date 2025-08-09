/**
 * @description Comprehensive test class for EnterpriseDataGenerator
 * @author Salesforce Architect
 * @date 2024
 */
@isTest
private class EnterpriseDataGeneratorTest {
    
    /**
     * @description Test complete data generation workflow
     */
    @isTest
    static void testCompleteDataGeneration() {
        Test.startTest();
        
        // Execute data generation
        EnterpriseDataGenerator.GenerationResult result = EnterpriseDataGenerator.generateAllTestData();
        
        Test.stopTest();
        
        // Verify generation was successful
        System.assert(result.success, 'Data generation should succeed: ' + result.message);
        System.assertNotEquals(null, result.recordCounts, 'Record counts should be populated');
        
        // Verify suppliers were created
        List<Supplier__c> suppliers = [SELECT Id, Name FROM Supplier__c];
        System.assert(suppliers.size() > 0, 'Suppliers should be created');
        System.assertEquals(suppliers.size(), result.recordCounts.get('Supplier__c'), 'Supplier count should match');
        
        // Verify devices were created
        List<Device__c> devices = [SELECT Id, Name FROM Device__c];
        System.assert(devices.size() > 0, 'Devices should be created');
        System.assertEquals(devices.size(), result.recordCounts.get('Device__c'), 'Device count should match');
        
        // Verify customers were created
        List<Customer__c> customers = [SELECT Id, Name FROM Customer__c];
        System.assert(customers.size() > 0, 'Customers should be created');
        System.assertEquals(customers.size(), result.recordCounts.get('Customer__c'), 'Customer count should match');
        
        // Verify orders were created
        List<Device_Order__c> orders = [SELECT Id, Name FROM Device_Order__c];
        System.assert(orders.size() > 0, 'Orders should be created');
        System.assertEquals(orders.size(), result.recordCounts.get('Device_Order__c'), 'Order count should match');
    }
    
    /**
     * @description Test field discovery utility
     */
    @isTest
    static void testFieldDiscoveryUtility() {
        Test.startTest();
        
        // Test field discovery for Device__c
        Map<String, Schema.SObjectField> deviceFields = FieldDiscoveryUtility.getAvailableFields('Device__c');
        System.assert(deviceFields.size() > 0, 'Device fields should be discovered');
        
        // Test field availability check
        Boolean nameFieldExists = FieldDiscoveryUtility.isFieldAvailable('Device__c', 'Name');
        System.assert(nameFieldExists, 'Name field should exist');
        
        // Test field type discovery
        Schema.DisplayType nameFieldType = FieldDiscoveryUtility.getFieldType('Device__c', 'Name');
        System.assertEquals(Schema.DisplayType.STRING, nameFieldType, 'Name field should be string type');
        
        // Test populatable fields
        List<String> populatableFields = FieldDiscoveryUtility.getPopulatableFields('Device__c');
        System.assert(populatableFields.size() > 0, 'Should have populatable fields');
        System.assert(populatableFields.contains('Name'), 'Name should be populatable');
        
        // Test field mapping generation
        Map<String, List<String>> fieldMapping = FieldDiscoveryUtility.generateFieldMapping();
        System.assert(fieldMapping.containsKey('Device__c'), 'Field mapping should include Device__c');
        
        Test.stopTest();
    }
    
    /**
     * @description Test picklist value discovery
     */
    @isTest
    static void testPicklistValueDiscovery() {
        Test.startTest();
        
        // Test picklist values for Type__c if it exists
        if (FieldDiscoveryUtility.isFieldAvailable('Device__c', 'Type__c')) {
            List<String> typeValues = FieldDiscoveryUtility.getPicklistValues('Device__c', 'Type__c');
            System.debug('Type__c picklist values: ' + typeValues);
        }
        
        // Test picklist values for Status__c if it exists
        if (FieldDiscoveryUtility.isFieldAvailable('Device_Order__c', 'Status__c')) {
            List<String> statusValues = FieldDiscoveryUtility.getPicklistValues('Device_Order__c', 'Status__c');
            System.debug('Status__c picklist values: ' + statusValues);
        }
        
        Test.stopTest();
    }
    
    /**
     * @description Test data relationships
     */
    @isTest
    static void testDataRelationships() {
        Test.startTest();
        
        // Generate test data
        EnterpriseDataGenerator.GenerationResult result = EnterpriseDataGenerator.generateAllTestData();
        
        Test.stopTest();
        
        // Verify relationships if fields exist
        if (FieldDiscoveryUtility.isFieldAvailable('Device__c', 'Supplier__c')) {
            List<Device__c> devicesWithSuppliers = [
                SELECT Id, Name, Supplier__c 
                FROM Device__c 
                WHERE Supplier__c != null
            ];
            System.assert(devicesWithSuppliers.size() > 0, 'Some devices should have supplier relationships');
        }
        
        if (FieldDiscoveryUtility.isFieldAvailable('Device_Order__c', 'Device__c')) {
            List<Device_Order__c> ordersWithDevices = [
                SELECT Id, Name, Device__c 
                FROM Device_Order__c 
                WHERE Device__c != null
            ];
            System.assert(ordersWithDevices.size() > 0, 'Some orders should have device relationships');
        }
        
        if (FieldDiscoveryUtility.isFieldAvailable('Device_Order__c', 'Customer__c')) {
            List<Device_Order__c> ordersWithCustomers = [
                SELECT Id, Name, Customer__c 
                FROM Device_Order__c 
                WHERE Customer__c != null
            ];
            System.assert(ordersWithCustomers.size() > 0, 'Some orders should have customer relationships');
        }
    }
    
    /**
     * @description Test error handling
     */
    @isTest
    static void testErrorHandling() {
        Test.startTest();
        
        // Test field discovery for non-existent object
        Map<String, Schema.SObjectField> nonExistentFields = FieldDiscoveryUtility.getAvailableFields('NonExistent__c');
        System.assertEquals(0, nonExistentFields.size(), 'Non-existent object should return empty map');
        
        // Test field availability for non-existent field
        Boolean nonExistentField = FieldDiscoveryUtility.isFieldAvailable('Device__c', 'NonExistentField__c');
        System.assertEquals(false, nonExistentField, 'Non-existent field should return false');
        
        // Test field type for non-existent field
        Schema.DisplayType nonExistentType = FieldDiscoveryUtility.getFieldType('Device__c', 'NonExistentField__c');
        System.assertEquals(null, nonExistentType, 'Non-existent field should return null type');
        
        Test.stopTest();
    }
    
    /**
     * @description Test bulk data generation performance
     */
    @isTest
    static void testBulkDataGeneration() {
        Test.startTest();
        
        // Generate data and measure performance
        Datetime startTime = Datetime.now();
        EnterpriseDataGenerator.GenerationResult result = EnterpriseDataGenerator.generateAllTestData();
        Datetime endTime = Datetime.now();
        
        Test.stopTest();
        
        // Verify performance is reasonable (should complete within test limits)
        System.assert(result.success, 'Bulk data generation should succeed');
        
        Long executionTime = endTime.getTime() - startTime.getTime();
        System.debug('Data generation execution time: ' + executionTime + 'ms');
        
        // Verify all objects have data
        System.assert(result.recordCounts.size() >= 4, 'Should have data for all 4 objects');
    }
}
