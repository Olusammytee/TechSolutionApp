/**
 * @description Enterprise utility for managing picklist values programmatically
 * @author Salesforce Architect
 * @date 2024
 */
public with sharing class PicklistManagementUtility {
    
    /**
     * @description Ensures required picklist values exist for record type deployment
     * @return Map of object names to validation results
     */
    public static Map<String, Boolean> ensurePicklistValuesForRecordTypes() {
        Map<String, Boolean> results = new Map<String, Boolean>();
        
        try {
            // Device__c Type__c picklist values
            results.put('Device__c.Type__c', validateDeviceTypeValues());
            
            // Customer__c Customer_Status__c picklist values  
            results.put('Customer__c.Customer_Status__c', validateCustomerStatusValues());
            
            // Device_Order__c Priority__c picklist values
            results.put('Device_Order__c.Priority__c', validateOrderPriorityValues());
            
            // Device_Order__c Status__c picklist values
            results.put('Device_Order__c.Status__c', validateOrderStatusValues());
            
            System.debug('=== Picklist Validation Results ===');
            for (String field : results.keySet()) {
                System.debug(field + ': ' + (results.get(field) ? 'VALID' : 'MISSING VALUES'));
            }
            
        } catch (Exception e) {
            System.debug('Error validating picklist values: ' + e.getMessage());
        }
        
        return results;
    }
    
    /**
     * @description Validates Device__c Type__c picklist values
     * @return True if all required values exist
     */
    private static Boolean validateDeviceTypeValues() {
        List<String> requiredValues = new List<String>{
            'Computer', 'Server', 'Networking', 'Storage', 'Mobile Device',
            'Software', 'License', 'Cloud Service', 'Digital Asset',
            'Accessory', 'Cable', 'Peripheral', 'Component', 'Consumable'
        };
        
        return validatePicklistField('Device__c', 'Type__c', requiredValues);
    }
    
    /**
     * @description Validates Customer__c Customer_Status__c picklist values
     * @return True if all required values exist
     */
    private static Boolean validateCustomerStatusValues() {
        List<String> requiredValues = new List<String>{
            'Active', 'VIP', 'Prospect', 'Inactive'
        };
        
        return validatePicklistField('Customer__c', 'Customer_Status__c', requiredValues);
    }
    
    /**
     * @description Validates Device_Order__c Priority__c picklist values
     * @return True if all required values exist
     */
    private static Boolean validateOrderPriorityValues() {
        List<String> requiredValues = new List<String>{
            'Critical', 'High', 'Medium', 'Low'
        };
        
        return validatePicklistField('Device_Order__c', 'Priority__c', requiredValues);
    }
    
    /**
     * @description Validates Device_Order__c Status__c picklist values
     * @return True if all required values exist
     */
    private static Boolean validateOrderStatusValues() {
        List<String> requiredValues = new List<String>{
            'Draft', 'Pending', 'Confirmed', 'Shipped', 'Delivered', 'Cancelled'
        };
        
        return validatePicklistField('Device_Order__c', 'Status__c', requiredValues);
    }
    
    /**
     * @description Validates if all required values exist in a picklist field
     * @param objectName The API name of the object
     * @param fieldName The API name of the picklist field
     * @param requiredValues List of required picklist values
     * @return True if all required values exist
     */
    private static Boolean validatePicklistField(String objectName, String fieldName, List<String> requiredValues) {
        if (!FieldDiscoveryUtility.isFieldAvailable(objectName, fieldName)) {
            System.debug('Field not available: ' + objectName + '.' + fieldName);
            return false;
        }
        
        List<String> existingValues = FieldDiscoveryUtility.getPicklistValues(objectName, fieldName);
        Set<String> existingValuesSet = new Set<String>(existingValues);
        
        List<String> missingValues = new List<String>();
        for (String requiredValue : requiredValues) {
            if (!existingValuesSet.contains(requiredValue)) {
                missingValues.add(requiredValue);
            }
        }
        
        if (!missingValues.isEmpty()) {
            System.debug('Missing picklist values for ' + objectName + '.' + fieldName + ': ' + String.join(missingValues, ', '));
            return false;
        }
        
        System.debug('All required values exist for ' + objectName + '.' + fieldName);
        return true;
    }
    
    /**
     * @description Generates record type deployment readiness report
     * @return Deployment readiness report
     */
    public static String generateRecordTypeReadinessReport() {
        Map<String, Boolean> validationResults = ensurePicklistValuesForRecordTypes();
        
        List<String> reportLines = new List<String>();
        reportLines.add('=== Record Type Deployment Readiness Report ===');
        reportLines.add('Generated: ' + Datetime.now().format());
        reportLines.add('');
        
        Boolean allValid = true;
        for (String field : validationResults.keySet()) {
            Boolean isValid = validationResults.get(field);
            String status = isValid ? '✅ READY' : '❌ MISSING VALUES';
            reportLines.add(field + ': ' + status);
            if (!isValid) {
                allValid = false;
            }
        }
        
        reportLines.add('');
        reportLines.add('Overall Status: ' + (allValid ? '✅ READY FOR DEPLOYMENT' : '❌ REQUIRES PICKLIST VALUE UPDATES'));
        
        if (!allValid) {
            reportLines.add('');
            reportLines.add('RECOMMENDED ACTIONS:');
            reportLines.add('1. Add missing picklist values via Setup > Object Manager');
            reportLines.add('2. Ensure all values are active and available');
            reportLines.add('3. Re-run this validation before record type deployment');
        }
        
        String report = String.join(reportLines, '\n');
        System.debug(report);
        return report;
    }
    
    /**
     * @description Gets record type configuration for deployment
     * @return Map of record type configurations
     */
    public static Map<String, Object> getRecordTypeConfiguration() {
        Map<String, Object> config = new Map<String, Object>();
        
        // Device__c record types
        config.put('Device__c', new Map<String, Object>{
            'Hardware_Device' => new List<String>{'Computer', 'Server', 'Networking', 'Storage', 'Mobile Device'},
            'Software_License' => new List<String>{'Software', 'License', 'Cloud Service', 'Digital Asset'},
            'Accessory_Item' => new List<String>{'Accessory', 'Cable', 'Peripheral', 'Component', 'Consumable'}
        });
        
        // Customer__c record types
        config.put('Customer__c', new Map<String, Object>{
            'Business_Customer' => new List<String>{'Active', 'VIP', 'Prospect', 'Inactive'},
            'Individual_Customer' => new List<String>{'Active', 'VIP', 'Prospect', 'Inactive'}
        });
        
        // Device_Order__c record types
        config.put('Device_Order__c', new Map<String, Object>{
            'Standard_Order' => new List<String>{'Medium', 'Low'},
            'Rush_Order' => new List<String>{'Critical', 'High'},
            'Bulk_Order' => new List<String>{'Medium', 'High'}
        });
        
        return config;
    }
    
    /**
     * @description Validates record type deployment prerequisites
     * @return True if ready for record type deployment
     */
    public static Boolean isReadyForRecordTypeDeployment() {
        Map<String, Boolean> validationResults = ensurePicklistValuesForRecordTypes();
        
        for (Boolean isValid : validationResults.values()) {
            if (!isValid) {
                return false;
            }
        }
        
        return true;
    }
}
