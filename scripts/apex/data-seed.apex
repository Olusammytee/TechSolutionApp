// Create sample devices
List<Device__c> devices = new List<Device__c>{
    new Device__c(Name='MacBook Pro', Type__c='Laptop', Stock_Quantity__c=25, Price__c=2499.00, Active__c=true),
    new Device__c(Name='iPhone 15', Type__c='Smartphone', Stock_Quantity__c=50, Price__c=999.00, Active__c=true),
    new Device__c(Name='iPad Air', Type__c='Tablet', Stock_Quantity__c=30, Price__c=599.00, Active__c=true),
    new Device__c(Name='Dell XPS 13', Type__c='Laptop', Stock_Quantity__c=15, Price__c=1299.00, Active__c=true),
    new Device__c(Name='Samsung Galaxy S24', Type__c='Smartphone', Stock_Quantity__c=40, Price__c=899.00, Active__c=true)
};

insert devices;

System.debug('Sample devices created: ' + devices.size());

// Create sample orders
List<Device_Order__c> orders = new List<Device_Order__c>{
    new Device_Order__c(Device__c=devices[0].Id, Quantity__c=2, Status__c='Confirmed'),
    new Device_Order__c(Device__c=devices[1].Id, Quantity__c=5, Status__c='Confirmed'),
    new Device_Order__c(Device__c=devices[2].Id, Quantity__c=3, Status__c='Draft')
};

insert orders;

System.debug('Sample orders created: ' + orders.size());
System.debug('Tech Solutions sample data setup complete!');
