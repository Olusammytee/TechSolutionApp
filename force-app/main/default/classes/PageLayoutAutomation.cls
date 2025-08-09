/**
 * @description Enterprise utility for automated page layout generation and validation
 * @author Salesforce Architect
 * @date 2024
 */
public with sharing class PageLayoutAutomation {
    
    /**
     * @description Validates page layout deployment readiness
     * @return Map of object names to validation results
     */
    public static Map<String, Boolean> validatePageLayoutReadiness() {
        Map<String, Boolean> results = new Map<String, Boolean>();
        
        List<String> objects = new List<String>{'Device__c', 'Device_Order__c', 'Customer__c', 'Supplier__c'};
        
        for (String objectName : objects) {
            results.put(objectName, validateObjectFieldsForLayout(objectName));
        }
        
        return results;
    }
    
    /**
     * @description Validates that all required fields exist for page layout
     * @param objectName The API name of the object
     * @return True if all required fields exist
     */
    private static Boolean validateObjectFieldsForLayout(String objectName) {
        List<String> availableFields = FieldDiscoveryUtility.getPopulatableFields(objectName);
        Map<String, List<String>> requiredFields = getRequiredFieldsForLayouts();
        
        if (!requiredFields.containsKey(objectName)) {
            System.debug('No required fields defined for ' + objectName);
            return true;
        }
        
        List<String> required = requiredFields.get(objectName);
        Set<String> availableSet = new Set<String>(availableFields);
        
        // Add standard fields that should always be available
        availableSet.add('Name');
        availableSet.add('CreatedDate');
        availableSet.add('LastModifiedDate');
        availableSet.add('CreatedById');
        availableSet.add('LastModifiedById');
        
        List<String> missingFields = new List<String>();
        for (String field : required) {
            if (!availableSet.contains(field)) {
                missingFields.add(field);
            }
        }
        
        if (!missingFields.isEmpty()) {
            System.debug('Missing fields for ' + objectName + ' layout: ' + String.join(missingFields, ', '));
            return false;
        }
        
        System.debug('All required fields available for ' + objectName + ' layout');
        return true;
    }
    
    /**
     * @description Gets required fields for each object's page layout
     * @return Map of object names to required field lists
     */
    private static Map<String, List<String>> getRequiredFieldsForLayouts() {
        return new Map<String, List<String>>{
            'Device__c' => new List<String>{
                'Name', 'Type__c', 'Stock_Quantity__c', 'Price__c', 'Cost_Price__c',
                'Profit_Margin__c', 'Warranty_Period_Months__c', 'Minimum_Stock_Level__c',
                'Reorder_Point__c', 'Last_Restocked__c', 'Stock_Status__c', 'Supplier__c', 'Active__c'
            },
            'Device_Order__c' => new List<String>{
                'Name', 'Device__c', 'Customer__c', 'Quantity__c', 'Status__c', 'Priority__c',
                'Total_Price__c', 'Order_Date__c', 'Expected_Delivery_Date__c', 'Confirmation_Number__c',
                'Discount_Percentage__c', 'Final_Amount__c'
            },
            'Customer__c' => new List<String>{
                'Name', 'Email__c', 'Phone__c', 'Customer_Status__c', 'Credit_Limit__c'
            },
            'Supplier__c' => new List<String>{
                'Name', 'Company_Name__c', 'Contact_Person__c', 'Email__c', 'Phone__c',
                'Country__c', 'Supplier_Rating__c', 'Active__c'
            }
        };
    }
    
    /**
     * @description Generates dynamic page layout XML based on available fields
     * @param objectName The API name of the object
     * @return XML string for page layout
     */
    public static String generatePageLayoutXML(String objectName) {
        List<String> availableFields = FieldDiscoveryUtility.getPopulatableFields(objectName);
        Map<String, List<String>> requiredFields = getRequiredFieldsForLayouts();
        
        // Filter to only include fields that exist
        List<String> fieldsToInclude = new List<String>();
        if (requiredFields.containsKey(objectName)) {
            Set<String> availableSet = new Set<String>(availableFields);
            availableSet.add('Name'); // Always include Name
            
            for (String field : requiredFields.get(objectName)) {
                if (availableSet.contains(field)) {
                    fieldsToInclude.add(field);
                }
            }
        }
        
        return buildLayoutXML(objectName, fieldsToInclude);
    }
    
    /**
     * @description Builds the actual XML for page layout
     * @param objectName The API name of the object
     * @param fields List of fields to include
     * @return XML string for page layout
     */
    private static String buildLayoutXML(String objectName, List<String> fields) {
        List<String> xmlLines = new List<String>();
        
        xmlLines.add('<?xml version="1.0" encoding="UTF-8"?>');
        xmlLines.add('<Layout xmlns="http://soap.sforce.com/2006/04/metadata">');
        xmlLines.add('    <layoutSections>');
        xmlLines.add('        <customLabel>false</customLabel>');
        xmlLines.add('        <detailHeading>false</detailHeading>');
        xmlLines.add('        <editHeading>true</editHeading>');
        xmlLines.add('        <label>Information</label>');
        xmlLines.add('        <layoutColumns>');
        xmlLines.add('            <layoutItems>');
        xmlLines.add('                <behavior>Required</behavior>');
        xmlLines.add('                <field>Name</field>');
        xmlLines.add('            </layoutItems>');
        
        // Add other fields in pairs
        for (Integer i = 1; i < fields.size(); i += 2) {
            if (!fields[i].equals('Name')) {
                xmlLines.add('            <layoutItems>');
                xmlLines.add('                <behavior>Edit</behavior>');
                xmlLines.add('                <field>' + fields[i] + '</field>');
                xmlLines.add('            </layoutItems>');
            }
        }
        
        xmlLines.add('        </layoutColumns>');
        xmlLines.add('        <layoutColumns>');
        
        // Add remaining fields to second column
        for (Integer i = 2; i < fields.size(); i += 2) {
            xmlLines.add('            <layoutItems>');
            xmlLines.add('                <behavior>Edit</behavior>');
            xmlLines.add('                <field>' + fields[i] + '</field>');
            xmlLines.add('            </layoutItems>');
        }
        
        xmlLines.add('        </layoutColumns>');
        xmlLines.add('        <style>TwoColumnsTopToBottom</style>');
        xmlLines.add('    </layoutSections>');
        xmlLines.add('    <layoutSections>');
        xmlLines.add('        <customLabel>false</customLabel>');
        xmlLines.add('        <detailHeading>false</detailHeading>');
        xmlLines.add('        <editHeading>true</editHeading>');
        xmlLines.add('        <label>System Information</label>');
        xmlLines.add('        <layoutColumns>');
        xmlLines.add('            <layoutItems>');
        xmlLines.add('                <behavior>Readonly</behavior>');
        xmlLines.add('                <field>CreatedById</field>');
        xmlLines.add('            </layoutItems>');
        xmlLines.add('        </layoutColumns>');
        xmlLines.add('        <layoutColumns>');
        xmlLines.add('            <layoutItems>');
        xmlLines.add('                <behavior>Readonly</behavior>');
        xmlLines.add('                <field>LastModifiedById</field>');
        xmlLines.add('            </layoutItems>');
        xmlLines.add('        </layoutColumns>');
        xmlLines.add('        <style>TwoColumnsTopToBottom</style>');
        xmlLines.add('    </layoutSections>');
        xmlLines.add('    <showEmailCheckbox>false</showEmailCheckbox>');
        xmlLines.add('    <showHighlightsPanel>false</showHighlightsPanel>');
        xmlLines.add('    <showInteractionLogPanel>false</showInteractionLogPanel>');
        xmlLines.add('    <showRunAssignmentRulesCheckbox>false</showRunAssignmentRulesCheckbox>');
        xmlLines.add('    <showSubmitAndAttachButton>false</showSubmitAndAttachButton>');
        xmlLines.add('</Layout>');
        
        return String.join(xmlLines, '\n');
    }
    
    /**
     * @description Generates page layout readiness report
     * @return Deployment readiness report
     */
    public static String generateLayoutReadinessReport() {
        Map<String, Boolean> validationResults = validatePageLayoutReadiness();
        
        List<String> reportLines = new List<String>();
        reportLines.add('=== Page Layout Deployment Readiness Report ===');
        reportLines.add('Generated: ' + Datetime.now().format());
        reportLines.add('');
        
        Boolean allValid = true;
        for (String objectName : validationResults.keySet()) {
            Boolean isValid = validationResults.get(objectName);
            String status = isValid ? '✅ READY' : '❌ MISSING FIELDS';
            reportLines.add(objectName + ': ' + status);
            if (!isValid) {
                allValid = false;
            }
        }
        
        reportLines.add('');
        reportLines.add('Overall Status: ' + (allValid ? '✅ READY FOR DEPLOYMENT' : '❌ REQUIRES FIELD UPDATES'));
        
        String report = String.join(reportLines, '\n');
        System.debug(report);
        return report;
    }
}
