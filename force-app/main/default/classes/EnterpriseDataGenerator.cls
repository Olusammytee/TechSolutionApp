/**
 * @description Enterprise-level automated data generation with dynamic field handling
 * @author Salesforce Architect
 * @date 2024
 */
public with sharing class EnterpriseDataGenerator {
    
    // Configuration for data generation
    private static final Integer SUPPLIER_COUNT = 5;
    private static final Integer DEVICE_COUNT = 15;
    private static final Integer CUSTOMER_COUNT = 10;
    private static final Integer ORDER_COUNT = 20;
    
    // Results tracking
    public class GenerationResult {
        public Boolean success = true;
        public String message = '';
        public Map<String, Integer> recordCounts = new Map<String, Integer>();
        public List<String> errors = new List<String>();
    }
    
    /**
     * @description Main method to generate all test data with proper dependency handling
     * @return GenerationResult with success status and details
     */
    public static GenerationResult generateAllTestData() {
        GenerationResult result = new GenerationResult();
        
        try {
            // Log field discovery for all objects
            logFieldDiscovery();
            
            // Generate data in dependency order
            List<Supplier__c> suppliers = generateSuppliers();
            result.recordCounts.put('Supplier__c', suppliers.size());
            
            List<Device__c> devices = generateDevices(suppliers);
            result.recordCounts.put('Device__c', devices.size());
            
            List<Customer__c> customers = generateCustomers();
            result.recordCounts.put('Customer__c', customers.size());
            
            List<Device_Order__c> orders = generateOrders(devices, customers);
            result.recordCounts.put('Device_Order__c', orders.size());
            
            result.message = 'Successfully generated test data for all objects';
            System.debug('=== Data Generation Complete ===');
            System.debug(result.message);
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Data generation failed: ' + e.getMessage();
            result.errors.add(e.getStackTraceString());
            System.debug('=== Data Generation Failed ===');
            System.debug(result.message);
        }
        
        return result;
    }
    
    /**
     * @description Generates supplier records with dynamic field handling
     * @return List of created supplier records
     */
    private static List<Supplier__c> generateSuppliers() {
        List<Supplier__c> suppliers = new List<Supplier__c>();
        List<String> availableFields = FieldDiscoveryUtility.getPopulatableFields('Supplier__c');
        
        List<Map<String, Object>> supplierData = new List<Map<String, Object>>{
            new Map<String, Object>{
                'Name' => 'TechCorp Solutions',
                'Company_Name__c' => 'TechCorp Solutions Inc.',
                'Contact_Person__c' => 'John Smith',
                'Email__c' => 'john.smith@techcorp.com',
                'Phone__c' => '+1-555-0101',
                'Country__c' => 'United States',
                'Supplier_Rating__c' => 5,
                'Active__c' => true
            },
            new Map<String, Object>{
                'Name' => 'Global Hardware Ltd',
                'Company_Name__c' => 'Global Hardware Limited',
                'Contact_Person__c' => 'Sarah Johnson',
                'Email__c' => 'sarah.johnson@globalhw.com',
                'Phone__c' => '+1-555-0102',
                'Country__c' => 'Canada',
                'Supplier_Rating__c' => 4,
                'Active__c' => true
            },
            new Map<String, Object>{
                'Name' => 'Innovation Systems',
                'Company_Name__c' => 'Innovation Systems Corp',
                'Contact_Person__c' => 'Michael Chen',
                'Email__c' => 'michael.chen@innosys.com',
                'Phone__c' => '+1-555-0103',
                'Country__c' => 'United States',
                'Supplier_Rating__c' => 5,
                'Active__c' => true
            },
            new Map<String, Object>{
                'Name' => 'European Tech',
                'Company_Name__c' => 'European Technology GmbH',
                'Contact_Person__c' => 'Anna Mueller',
                'Email__c' => 'anna.mueller@eurotech.de',
                'Phone__c' => '+49-555-0104',
                'Country__c' => 'Germany',
                'Supplier_Rating__c' => 4,
                'Active__c' => true
            },
            new Map<String, Object>{
                'Name' => 'Asia Pacific Devices',
                'Company_Name__c' => 'Asia Pacific Devices Pte Ltd',
                'Contact_Person__c' => 'Hiroshi Tanaka',
                'Email__c' => 'hiroshi.tanaka@apdevices.com',
                'Phone__c' => '+65-555-0105',
                'Country__c' => 'Singapore',
                'Supplier_Rating__c' => 3,
                'Active__c' => true
            }
        };
        
        for (Map<String, Object> data : supplierData) {
            Supplier__c supplier = new Supplier__c();
            populateRecord(supplier, data, availableFields);
            suppliers.add(supplier);
        }
        
        try {
            insert suppliers;
            System.debug('Successfully created ' + suppliers.size() + ' suppliers');
        } catch (DmlException e) {
            System.debug('Error creating suppliers: ' + e.getMessage());
            throw e;
        }
        
        return suppliers;
    }
    
    /**
     * @description Generates device records with supplier relationships
     * @param suppliers List of supplier records for relationships
     * @return List of created device records
     */
    private static List<Device__c> generateDevices(List<Supplier__c> suppliers) {
        List<Device__c> devices = new List<Device__c>();
        List<String> availableFields = FieldDiscoveryUtility.getPopulatableFields('Device__c');
        
        // Get available picklist values for Type__c
        List<String> typeValues = FieldDiscoveryUtility.getPicklistValues('Device__c', 'Type__c');
        String defaultType = !typeValues.isEmpty() ? typeValues[0] : 'Computer';
        
        List<Map<String, Object>> deviceData = new List<Map<String, Object>>{
            new Map<String, Object>{
                'Name' => 'Laptop Pro 15',
                'Type__c' => defaultType,
                'Stock_Quantity__c' => 25,
                'Price__c' => 1299.99,
                'Cost_Price__c' => 899.99,
                'Warranty_Period_Months__c' => 24,
                'Minimum_Stock_Level__c' => 5,
                'Reorder_Point__c' => 10,
                'Active__c' => true
            },
            new Map<String, Object>{
                'Name' => 'Desktop Workstation',
                'Type__c' => defaultType,
                'Stock_Quantity__c' => 15,
                'Price__c' => 899.99,
                'Cost_Price__c' => 649.99,
                'Warranty_Period_Months__c' => 36,
                'Minimum_Stock_Level__c' => 3,
                'Reorder_Point__c' => 8,
                'Active__c' => true
            },
            new Map<String, Object>{
                'Name' => 'Wireless Mouse',
                'Type__c' => defaultType,
                'Stock_Quantity__c' => 100,
                'Price__c' => 29.99,
                'Cost_Price__c' => 15.99,
                'Warranty_Period_Months__c' => 12,
                'Minimum_Stock_Level__c' => 20,
                'Reorder_Point__c' => 50,
                'Active__c' => true
            }
        };
        
        Integer supplierIndex = 0;
        for (Map<String, Object> data : deviceData) {
            Device__c device = new Device__c();
            
            // Add supplier relationship if available
            if (!suppliers.isEmpty() && FieldDiscoveryUtility.isFieldAvailable('Device__c', 'Supplier__c')) {
                data.put('Supplier__c', suppliers[Math.mod(supplierIndex++, suppliers.size())].Id);
            }
            
            populateRecord(device, data, availableFields);
            devices.add(device);
        }
        
        try {
            insert devices;
            System.debug('Successfully created ' + devices.size() + ' devices');
        } catch (DmlException e) {
            System.debug('Error creating devices: ' + e.getMessage());
            throw e;
        }
        
        return devices;
    }
    
    /**
     * @description Populates SObject record with available fields only
     * @param record The SObject record to populate
     * @param data Map of field names to values
     * @param availableFields List of available field API names
     */
    private static void populateRecord(SObject record, Map<String, Object> data, List<String> availableFields) {
        for (String fieldName : data.keySet()) {
            if (availableFields.contains(fieldName)) {
                try {
                    record.put(fieldName, data.get(fieldName));
                } catch (Exception e) {
                    System.debug('Error setting field ' + fieldName + ': ' + e.getMessage());
                }
            } else {
                System.debug('Field not available: ' + fieldName);
            }
        }
    }
    
    /**
     * @description Generates customer records with dynamic field handling
     * @return List of created customer records
     */
    private static List<Customer__c> generateCustomers() {
        List<Customer__c> customers = new List<Customer__c>();
        List<String> availableFields = FieldDiscoveryUtility.getPopulatableFields('Customer__c');

        // Get available picklist values for Customer_Status__c
        List<String> statusValues = FieldDiscoveryUtility.getPicklistValues('Customer__c', 'Customer_Status__c');
        String defaultStatus = !statusValues.isEmpty() ? statusValues[0] : 'Active';

        List<Map<String, Object>> customerData = new List<Map<String, Object>>{
            new Map<String, Object>{
                'Name' => 'Acme Corporation',
                'Email__c' => 'contact@acmecorp.com',
                'Phone__c' => '+1-555-1001',
                'Customer_Status__c' => defaultStatus,
                'Credit_Limit__c' => 50000.00
            },
            new Map<String, Object>{
                'Name' => 'Global Enterprises',
                'Email__c' => 'info@globalent.com',
                'Phone__c' => '+1-555-1002',
                'Customer_Status__c' => defaultStatus,
                'Credit_Limit__c' => 75000.00
            },
            new Map<String, Object>{
                'Name' => 'Tech Startup Inc',
                'Email__c' => 'hello@techstartup.com',
                'Phone__c' => '+1-555-1003',
                'Customer_Status__c' => defaultStatus,
                'Credit_Limit__c' => 25000.00
            },
            new Map<String, Object>{
                'Name' => 'John Doe',
                'Email__c' => 'john.doe@email.com',
                'Phone__c' => '+1-555-1004',
                'Customer_Status__c' => defaultStatus,
                'Credit_Limit__c' => 5000.00
            },
            new Map<String, Object>{
                'Name' => 'Jane Smith',
                'Email__c' => 'jane.smith@email.com',
                'Phone__c' => '+1-555-1005',
                'Customer_Status__c' => defaultStatus,
                'Credit_Limit__c' => 3000.00
            }
        };

        for (Map<String, Object> data : customerData) {
            Customer__c customer = new Customer__c();
            populateRecord(customer, data, availableFields);
            customers.add(customer);
        }

        try {
            insert customers;
            System.debug('Successfully created ' + customers.size() + ' customers');
        } catch (DmlException e) {
            System.debug('Error creating customers: ' + e.getMessage());
            throw e;
        }

        return customers;
    }

    /**
     * @description Generates order records with device and customer relationships
     * @param devices List of device records for relationships
     * @param customers List of customer records for relationships
     * @return List of created order records
     */
    private static List<Device_Order__c> generateOrders(List<Device__c> devices, List<Customer__c> customers) {
        List<Device_Order__c> orders = new List<Device_Order__c>();
        List<String> availableFields = FieldDiscoveryUtility.getPopulatableFields('Device_Order__c');

        // Get available picklist values
        List<String> statusValues = FieldDiscoveryUtility.getPicklistValues('Device_Order__c', 'Status__c');
        List<String> priorityValues = FieldDiscoveryUtility.getPicklistValues('Device_Order__c', 'Priority__c');

        String defaultStatus = !statusValues.isEmpty() ? statusValues[0] : 'Pending';
        String defaultPriority = !priorityValues.isEmpty() ? priorityValues[0] : 'Medium';

        // Generate orders with realistic scenarios
        for (Integer i = 0; i < Math.min(ORDER_COUNT, devices.size() * 3); i++) {
            Map<String, Object> orderData = new Map<String, Object>{
                'Name' => 'ORD-' + String.valueOf(1000 + i),
                'Quantity__c' => Math.mod(i, 5) + 1,
                'Status__c' => defaultStatus,
                'Priority__c' => defaultPriority,
                'Order_Date__c' => Date.today().addDays(-Math.mod(i, 30)),
                'Expected_Delivery_Date__c' => Date.today().addDays(Math.mod(i, 14) + 1),
                'Discount_Percentage__c' => Math.mod(i, 3) * 5.0
            };

            Device_Order__c order = new Device_Order__c();

            // Add device relationship
            if (!devices.isEmpty() && FieldDiscoveryUtility.isFieldAvailable('Device_Order__c', 'Device__c')) {
                orderData.put('Device__c', devices[Math.mod(i, devices.size())].Id);
            }

            // Add customer relationship
            if (!customers.isEmpty() && FieldDiscoveryUtility.isFieldAvailable('Device_Order__c', 'Customer__c')) {
                orderData.put('Customer__c', customers[Math.mod(i, customers.size())].Id);
            }

            populateRecord(order, orderData, availableFields);
            orders.add(order);
        }

        try {
            insert orders;
            System.debug('Successfully created ' + orders.size() + ' orders');
        } catch (DmlException e) {
            System.debug('Error creating orders: ' + e.getMessage());
            throw e;
        }

        return orders;
    }

    /**
     * @description Logs field discovery for all objects
     */
    private static void logFieldDiscovery() {
        List<String> objects = new List<String>{'Supplier__c', 'Device__c', 'Customer__c', 'Device_Order__c'};
        for (String objectName : objects) {
            FieldDiscoveryUtility.logFieldDiscovery(objectName);
        }
    }
}
