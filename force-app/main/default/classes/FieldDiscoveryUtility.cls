/**
 * @description Enterprise-level utility for dynamic field discovery and validation
 * @author Salesforce Architect
 * @date 2024
 */
public with sharing class FieldDiscoveryUtility {
    
    // Cache for field information to avoid repeated queries
    private static Map<String, Map<String, Schema.SObjectField>> fieldCache = 
        new Map<String, Map<String, Schema.SObjectField>>();
    
    /**
     * @description Discovers all available fields for a given SObject
     * @param objectApiName The API name of the SObject
     * @return Map of field API names to field tokens
     */
    public static Map<String, Schema.SObjectField> getAvailableFields(String objectApiName) {
        if (fieldCache.containsKey(objectApiName)) {
            return fieldCache.get(objectApiName);
        }
        
        try {
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectApiName);
            if (objectType == null) {
                System.debug('Object not found: ' + objectApiName);
                return new Map<String, Schema.SObjectField>();
            }
            
            Map<String, Schema.SObjectField> fields = objectType.getDescribe().fields.getMap();
            fieldCache.put(objectApiName, fields);
            return fields;
        } catch (Exception e) {
            System.debug('Error discovering fields for ' + objectApiName + ': ' + e.getMessage());
            return new Map<String, Schema.SObjectField>();
        }
    }
    
    /**
     * @description Validates if a field exists and is accessible
     * @param objectApiName The API name of the SObject
     * @param fieldApiName The API name of the field
     * @return True if field exists and is accessible
     */
    public static Boolean isFieldAvailable(String objectApiName, String fieldApiName) {
        Map<String, Schema.SObjectField> fields = getAvailableFields(objectApiName);
        
        if (!fields.containsKey(fieldApiName)) {
            return false;
        }
        
        Schema.DescribeFieldResult fieldDescribe = fields.get(fieldApiName).getDescribe();
        return fieldDescribe.isAccessible() && fieldDescribe.isCreateable();
    }
    
    /**
     * @description Gets field type for validation
     * @param objectApiName The API name of the SObject
     * @param fieldApiName The API name of the field
     * @return Field type or null if field doesn't exist
     */
    public static Schema.DisplayType getFieldType(String objectApiName, String fieldApiName) {
        Map<String, Schema.SObjectField> fields = getAvailableFields(objectApiName);
        
        if (!fields.containsKey(fieldApiName)) {
            return null;
        }
        
        return fields.get(fieldApiName).getDescribe().getType();
    }
    
    /**
     * @description Gets all available fields for data population
     * @param objectApiName The API name of the SObject
     * @return List of field API names that can be populated
     */
    public static List<String> getPopulatableFields(String objectApiName) {
        Map<String, Schema.SObjectField> fields = getAvailableFields(objectApiName);
        List<String> populatableFields = new List<String>();
        
        for (String fieldName : fields.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fields.get(fieldName).getDescribe();
            
            // Skip system fields and non-createable fields
            if (fieldDescribe.isCreateable() && 
                !fieldDescribe.isCalculated() && 
                !fieldName.equalsIgnoreCase('Id') &&
                !fieldName.equalsIgnoreCase('CreatedDate') &&
                !fieldName.equalsIgnoreCase('CreatedById') &&
                !fieldName.equalsIgnoreCase('LastModifiedDate') &&
                !fieldName.equalsIgnoreCase('LastModifiedById') &&
                !fieldName.equalsIgnoreCase('SystemModstamp')) {
                populatableFields.add(fieldName);
            }
        }
        
        return populatableFields;
    }
    
    /**
     * @description Validates picklist values for a field
     * @param objectApiName The API name of the SObject
     * @param fieldApiName The API name of the picklist field
     * @return List of valid picklist values
     */
    public static List<String> getPicklistValues(String objectApiName, String fieldApiName) {
        Map<String, Schema.SObjectField> fields = getAvailableFields(objectApiName);
        List<String> picklistValues = new List<String>();
        
        if (!fields.containsKey(fieldApiName)) {
            return picklistValues;
        }
        
        Schema.DescribeFieldResult fieldDescribe = fields.get(fieldApiName).getDescribe();
        
        if (fieldDescribe.getType() == Schema.DisplayType.PICKLIST || 
            fieldDescribe.getType() == Schema.DisplayType.MULTIPICKLIST) {
            
            for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                if (entry.isActive()) {
                    picklistValues.add(entry.getValue());
                }
            }
        }
        
        return picklistValues;
    }
    
    /**
     * @description Generates field mapping for data population
     * @return Map of object names to their available fields
     */
    public static Map<String, List<String>> generateFieldMapping() {
        Map<String, List<String>> fieldMapping = new Map<String, List<String>>();
        
        List<String> objects = new List<String>{
            'Device__c', 'Device_Order__c', 'Customer__c', 'Supplier__c'
        };
        
        for (String objectName : objects) {
            fieldMapping.put(objectName, getPopulatableFields(objectName));
        }
        
        return fieldMapping;
    }
    
    /**
     * @description Logs field discovery results for debugging
     * @param objectApiName The API name of the SObject
     */
    public static void logFieldDiscovery(String objectApiName) {
        List<String> fields = getPopulatableFields(objectApiName);
        System.debug('=== Field Discovery for ' + objectApiName + ' ===');
        System.debug('Available fields (' + fields.size() + '): ' + String.join(fields, ', '));
        
        // Log picklist fields specifically
        for (String fieldName : fields) {
            Schema.DisplayType fieldType = getFieldType(objectApiName, fieldName);
            if (fieldType == Schema.DisplayType.PICKLIST) {
                List<String> picklistValues = getPicklistValues(objectApiName, fieldName);
                System.debug('Picklist field ' + fieldName + ' values: ' + String.join(picklistValues, ', '));
            }
        }
    }
}
