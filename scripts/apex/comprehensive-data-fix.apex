// Comprehensive Data Population Fix - Address All Data Quality Issues
System.debug('=== Starting Comprehensive Data Population Fix ===');

try {
    // 1. CREATE SUPPLIERS FIRST (Foundation for Device relationships)
    System.debug('=== Creating Suppliers ===');
    List<Supplier__c> suppliers = new List<Supplier__c>();
    
    suppliers.add(new Supplier__c(
        Name = 'Apple Inc',
        Company_Name__c = 'Apple Inc.',
        Contact_Person__c = 'Tim Cook',
        Email__c = 'business@apple.com',
        Phone__c = '+1-408-996-1010',
        Country__c = 'United States',
        Supplier_Rating__c = 'Excellent',
        Active__c = true
    ));
    
    suppliers.add(new Supplier__c(
        Name = 'Dell Technologies',
        Company_Name__c = 'Dell Technologies Inc.',
        Contact_Person__c = 'Michael Dell',
        Email__c = 'enterprise@dell.com',
        Phone__c = '+1-512-338-4400',
        Country__c = 'United States',
        Supplier_Rating__c = 'Excellent',
        Active__c = true
    ));
    
    suppliers.add(new Supplier__c(
        Name = 'HP Enterprise',
        Company_Name__c = 'Hewlett Packard Enterprise',
        Contact_Person__c = 'Antonio Neri',
        Email__c = 'sales@hpe.com',
        Phone__c = '+1-650-857-1501',
        Country__c = 'United States',
        Supplier_Rating__c = 'Good',
        Active__c = true
    ));
    
    suppliers.add(new Supplier__c(
        Name = 'Cisco Systems',
        Company_Name__c = 'Cisco Systems Inc.',
        Contact_Person__c = 'Chuck Robbins',
        Email__c = 'enterprise@cisco.com',
        Phone__c = '+1-408-526-4000',
        Country__c = 'United States',
        Supplier_Rating__c = 'Excellent',
        Active__c = true
    ));
    
    suppliers.add(new Supplier__c(
        Name = 'Microsoft Corp',
        Company_Name__c = 'Microsoft Corporation',
        Contact_Person__c = 'Satya Nadella',
        Email__c = 'business@microsoft.com',
        Phone__c = '+1-425-882-8080',
        Country__c = 'United States',
        Supplier_Rating__c = 'Excellent',
        Active__c = true
    ));
    
    suppliers.add(new Supplier__c(
        Name = 'Samsung Electronics',
        Company_Name__c = 'Samsung Electronics Co Ltd',
        Contact_Person__c = 'Jong-Hee Han',
        Email__c = 'b2b@samsung.com',
        Phone__c = '+82-2-2255-0114',
        Country__c = 'South Korea',
        Supplier_Rating__c = 'Good',
        Active__c = true
    ));
    
    suppliers.add(new Supplier__c(
        Name = 'Logitech International',
        Company_Name__c = 'Logitech International SA',
        Contact_Person__c = 'Bracken Darrell',
        Email__c = 'business@logitech.com',
        Phone__c = '+41-21-863-5111',
        Country__c = 'Switzerland',
        Supplier_Rating__c = 'Good',
        Active__c = true
    ));
    
    suppliers.add(new Supplier__c(
        Name = 'Adobe Systems',
        Company_Name__c = 'Adobe Inc.',
        Contact_Person__c = 'Shantanu Narayen',
        Email__c = 'enterprise@adobe.com',
        Phone__c = '+1-408-536-6000',
        Country__c = 'United States',
        Supplier_Rating__c = 'Excellent',
        Active__c = true
    ));
    
    insert suppliers;
    System.debug('Created ' + suppliers.size() + ' Supplier records');
    
    // 2. CREATE CUSTOMERS (Foundation for Order relationships)
    System.debug('=== Creating Customers ===');
    List<Customer__c> customers = new List<Customer__c>();
    
    customers.add(new Customer__c(
        Name = 'Acme Corporation',
        Email__c = 'procurement@acmecorp.com',
        Phone__c = '+1-555-0101',
        Address__c = '123 Business Plaza, New York, NY 10001',
        Customer_Type__c = 'Enterprise',
        Customer_Status__c = 'VIP',
        Credit_Limit__c = 100000
    ));
    
    customers.add(new Customer__c(
        Name = 'TechStart Innovations',
        Email__c = 'orders@techstart.com',
        Phone__c = '+1-555-0102',
        Address__c = '456 Innovation Drive, San Francisco, CA 94105',
        Customer_Type__c = 'Small Business',
        Customer_Status__c = 'Active',
        Credit_Limit__c = 25000
    ));
    
    customers.add(new Customer__c(
        Name = 'Global Enterprises Ltd',
        Email__c = 'purchasing@globalent.com',
        Phone__c = '+1-555-0103',
        Address__c = '789 Corporate Center, Chicago, IL 60601',
        Customer_Type__c = 'Enterprise',
        Customer_Status__c = 'VIP',
        Credit_Limit__c = 150000
    ));
    
    customers.add(new Customer__c(
        Name = 'City University',
        Email__c = 'it-procurement@cityuni.edu',
        Phone__c = '+1-555-0104',
        Address__c = '321 Campus Boulevard, Boston, MA 02101',
        Customer_Type__c = 'Government',
        Customer_Status__c = 'Active',
        Credit_Limit__c = 75000
    ));
    
    customers.add(new Customer__c(
        Name = 'Healthcare Systems Inc',
        Email__c = 'technology@healthsys.com',
        Phone__c = '+1-555-0105',
        Address__c = '654 Medical Plaza, Miami, FL 33101',
        Customer_Type__c = 'Enterprise',
        Customer_Status__c = 'Active',
        Credit_Limit__c = 80000
    ));
    
    customers.add(new Customer__c(
        Name = 'John Smith',
        Email__c = 'john.smith@email.com',
        Phone__c = '+1-555-0106',
        Address__c = '147 Residential Street, Austin, TX 78701',
        Customer_Type__c = 'Individual',
        Customer_Status__c = 'Active',
        Credit_Limit__c = 5000
    ));
    
    customers.add(new Customer__c(
        Name = 'Creative Agency Pro',
        Email__c = 'admin@creativeagency.com',
        Phone__c = '+1-555-0107',
        Address__c = '258 Design District, Los Angeles, CA 90210',
        Customer_Type__c = 'Small Business',
        Customer_Status__c = 'Active',
        Credit_Limit__c = 30000
    ));
    
    customers.add(new Customer__c(
        Name = 'Manufacturing Corp',
        Email__c = 'it@manufacturing.com',
        Phone__c = '+1-555-0108',
        Address__c = '369 Industrial Way, Detroit, MI 48201',
        Customer_Type__c = 'Enterprise',
        Customer_Status__c = 'Prospect',
        Credit_Limit__c = 120000
    ));
    
    customers.add(new Customer__c(
        Name = 'Sarah Johnson',
        Email__c = 'sarah.johnson@email.com',
        Phone__c = '+1-555-0109',
        Address__c = '741 Home Avenue, Seattle, WA 98101',
        Customer_Type__c = 'Individual',
        Customer_Status__c = 'Active',
        Credit_Limit__c = 3000
    ));
    
    customers.add(new Customer__c(
        Name = 'Consulting Partners LLC',
        Email__c = 'tech@consultingpartners.com',
        Phone__c = '+1-555-0110',
        Address__c = '852 Professional Center, Denver, CO 80201',
        Customer_Type__c = 'Small Business',
        Customer_Status__c = 'VIP',
        Credit_Limit__c = 40000
    ));
    
    insert customers;
    System.debug('Created ' + customers.size() + ' Customer records');
    
    System.debug('=== Phase 1 Complete: Suppliers and Customers Created ===');
    System.debug('Suppliers: ' + suppliers.size());
    System.debug('Customers: ' + customers.size());
    
} catch (Exception e) {
    System.debug('ERROR in Phase 1: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== Comprehensive Data Fix Phase 1 Complete ===');
