// Comprehensive Test Data Population for Dashboard Demonstration
System.debug('=== Starting Comprehensive Data Population ===');

try {
    // Execute comprehensive data generation using our automation framework
    EnterpriseDataGenerator.DataGenerationResult result = EnterpriseDataGenerator.generateComprehensiveTestData();
    
    System.debug('=== DATA GENERATION COMPLETE ===');
    System.debug('Success: ' + result.success);
    System.debug('Message: ' + result.message);
    
    if (!result.errors.isEmpty()) {
        System.debug('=== ERRORS ===');
        for (String error : result.errors) {
            System.debug('ERROR: ' + error);
        }
    }
    
    if (!result.warnings.isEmpty()) {
        System.debug('=== WARNINGS ===');
        for (String warning : result.warnings) {
            System.debug('WARNING: ' + warning);
        }
    }
    
    System.debug('=== GENERATION STATISTICS ===');
    for (String key : result.statistics.keySet()) {
        System.debug(key + ': ' + result.statistics.get(key));
    }
    
} catch (Exception e) {
    System.debug('=== AUTOMATION EXECUTION ERROR ===');
    System.debug('Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
    
    System.debug('=== FALLING BACK TO MANUAL DATA CREATION ===');
    
    // Manual data creation as fallback
    List<Supplier__c> suppliers = new List<Supplier__c>();
    
    // Create 6-8 Supplier records
    suppliers.add(new Supplier__c(
        Name = 'TechCorp Solutions',
        Company_Name__c = 'TechCorp Solutions Inc.',
        Contact_Person__c = 'John Smith',
        Email__c = 'john.smith@techcorp.com',
        Phone__c = '+1-555-0101',
        Country__c = 'United States',
        Supplier_Rating__c = 'Excellent',
        Active__c = true
    ));
    
    suppliers.add(new Supplier__c(
        Name = 'Global Hardware Ltd',
        Company_Name__c = 'Global Hardware Limited',
        Contact_Person__c = 'Sarah Johnson',
        Email__c = 'sarah.johnson@globalhw.com',
        Phone__c = '+1-555-0102',
        Country__c = 'Canada',
        Supplier_Rating__c = 'Good',
        Active__c = true
    ));
    
    suppliers.add(new Supplier__c(
        Name = 'Innovation Systems',
        Company_Name__c = 'Innovation Systems Corp',
        Contact_Person__c = 'Michael Chen',
        Email__c = 'michael.chen@innosys.com',
        Phone__c = '+1-555-0103',
        Country__c = 'United States',
        Supplier_Rating__c = 'Excellent',
        Active__c = true
    ));
    
    suppliers.add(new Supplier__c(
        Name = 'European Tech Hub',
        Company_Name__c = 'European Tech Hub GmbH',
        Contact_Person__c = 'Anna Mueller',
        Email__c = 'anna.mueller@eurotechu.de',
        Phone__c = '+49-555-0104',
        Country__c = 'Germany',
        Supplier_Rating__c = 'Good',
        Active__c = true
    ));
    
    suppliers.add(new Supplier__c(
        Name = 'Pacific Components',
        Company_Name__c = 'Pacific Components Pty Ltd',
        Contact_Person__c = 'David Wilson',
        Email__c = 'david.wilson@paccomp.au',
        Phone__c = '+61-555-0105',
        Country__c = 'Australia',
        Supplier_Rating__c = 'Average',
        Active__c = true
    ));
    
    suppliers.add(new Supplier__c(
        Name = 'Nordic Solutions',
        Company_Name__c = 'Nordic Solutions AB',
        Contact_Person__c = 'Erik Larsson',
        Email__c = 'erik.larsson@nordicsol.se',
        Phone__c = '+46-555-0106',
        Country__c = 'Sweden',
        Supplier_Rating__c = 'Excellent',
        Active__c = true
    ));
    
    insert suppliers;
    System.debug('Created ' + suppliers.size() + ' Supplier records');
    
    // Create Customer records
    List<Customer__c> customers = new List<Customer__c>();
    
    customers.add(new Customer__c(
        Name = 'Acme Corporation',
        Email__c = 'contact@acmecorp.com',
        Phone__c = '+1-555-1001',
        Address__c = '123 Business Ave, New York, NY 10001',
        Customer_Type__c = 'Enterprise',
        Customer_Status__c = 'VIP',
        Credit_Limit__c = 50000
    ));
    
    customers.add(new Customer__c(
        Name = 'StartUp Innovations',
        Email__c = 'hello@startupinno.com',
        Phone__c = '+1-555-1002',
        Address__c = '456 Innovation St, San Francisco, CA 94105',
        Customer_Type__c = 'Small Business',
        Customer_Status__c = 'Active',
        Credit_Limit__c = 15000
    ));
    
    customers.add(new Customer__c(
        Name = 'John Doe',
        Email__c = 'john.doe@email.com',
        Phone__c = '+1-555-1003',
        Address__c = '789 Residential Rd, Austin, TX 78701',
        Customer_Type__c = 'Individual',
        Customer_Status__c = 'Active',
        Credit_Limit__c = 5000
    ));
    
    customers.add(new Customer__c(
        Name = 'Global Enterprises',
        Email__c = 'procurement@globalent.com',
        Phone__c = '+1-555-1004',
        Address__c = '321 Corporate Blvd, Chicago, IL 60601',
        Customer_Type__c = 'Enterprise',
        Customer_Status__c = 'VIP',
        Credit_Limit__c = 100000
    ));
    
    customers.add(new Customer__c(
        Name = 'City University',
        Email__c = 'purchasing@cityuni.edu',
        Phone__c = '+1-555-1005',
        Address__c = '654 Campus Dr, Boston, MA 02101',
        Customer_Type__c = 'Government',
        Customer_Status__c = 'Active',
        Credit_Limit__c = 25000
    ));
    
    customers.add(new Customer__c(
        Name = 'Jane Smith',
        Email__c = 'jane.smith@email.com',
        Phone__c = '+1-555-1006',
        Address__c = '987 Home St, Seattle, WA 98101',
        Customer_Type__c = 'Individual',
        Customer_Status__c = 'Active',
        Credit_Limit__c = 3000
    ));
    
    customers.add(new Customer__c(
        Name = 'Tech Startup Hub',
        Email__c = 'orders@techstartup.com',
        Phone__c = '+1-555-1007',
        Address__c = '147 Innovation Park, Denver, CO 80201',
        Customer_Type__c = 'Small Business',
        Customer_Status__c = 'Prospect',
        Credit_Limit__c = 10000
    ));
    
    customers.add(new Customer__c(
        Name = 'Healthcare Systems Inc',
        Email__c = 'it@healthsys.com',
        Phone__c = '+1-555-1008',
        Address__c = '258 Medical Center Dr, Miami, FL 33101',
        Customer_Type__c = 'Enterprise',
        Customer_Status__c = 'Active',
        Credit_Limit__c = 75000
    ));
    
    insert customers;
    System.debug('Created ' + customers.size() + ' Customer records');
    
    System.debug('=== MANUAL DATA CREATION COMPLETE ===');
    System.debug('Next: Create Device and Order records through Salesforce UI for optimal compatibility');
}

System.debug('=== DATA POPULATION SCRIPT COMPLETE ===');
