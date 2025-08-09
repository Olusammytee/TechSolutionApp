/**
 * Simple Data Seed Script for Phase 4.3 Foundation
 * 
 * This script creates basic test data that works with our current field structure
 * and provides a foundation for advanced dashboard analytics.
 */

System.debug('=== PHASE 4.3 SIMPLE DATA SEED STARTING ===');

// Step 1: Clear existing data
System.debug('Step 1: Clearing existing data...');

List<Device_Order__c> existingOrders = [SELECT Id FROM Device_Order__c];
if (!existingOrders.isEmpty()) {
    delete existingOrders;
    System.debug('✅ Deleted ' + existingOrders.size() + ' existing orders');
}

List<Device__c> existingDevices = [SELECT Id FROM Device__c];
if (!existingDevices.isEmpty()) {
    delete existingDevices;
    System.debug('✅ Deleted ' + existingDevices.size() + ' existing devices');
}

// Step 2: Create diverse devices
System.debug('Step 2: Creating diverse devices...');

List<Device__c> devices = new List<Device__c>();

// Use only the basic fields we know exist
devices.add(new Device__c(
    Name = 'MacBook Pro 16"',
    Type__c = 'Laptop',
    Stock_Quantity__c = 12,
    Price__c = 2499.00,
    Active__c = true
));

devices.add(new Device__c(
    Name = 'iPhone 15 Pro',
    Type__c = 'Smartphone',
    Stock_Quantity__c = 25,
    Price__c = 999.00,
    Active__c = true
));

devices.add(new Device__c(
    Name = 'iPad Air',
    Type__c = 'Tablet',
    Stock_Quantity__c = 15,
    Price__c = 599.00,
    Active__c = true
));

devices.add(new Device__c(
    Name = 'Dell XPS 15',
    Type__c = 'Laptop',
    Stock_Quantity__c = 3,
    Price__c = 1899.00,
    Active__c = true
));

devices.add(new Device__c(
    Name = 'Samsung Galaxy S24',
    Type__c = 'Smartphone',
    Stock_Quantity__c = 18,
    Price__c = 899.00,
    Active__c = true
));

devices.add(new Device__c(
    Name = 'AirPods Pro',
    Type__c = 'Accessory',
    Stock_Quantity__c = 50,
    Price__c = 249.00,
    Active__c = true
));

insert devices;
System.debug('✅ Created ' + devices.size() + ' devices');

// Step 3: Create time-distributed orders
System.debug('Step 3: Creating time-distributed orders...');

List<Device_Order__c> orders = new List<Device_Order__c>();
Date today = Date.today();

// Recent orders
orders.add(new Device_Order__c(
    Device__c = devices[0].Id, // MacBook Pro
    Quantity__c = 2
));

orders.add(new Device_Order__c(
    Device__c = devices[1].Id, // iPhone 15 Pro
    Quantity__c = 3
));

orders.add(new Device_Order__c(
    Device__c = devices[5].Id, // AirPods Pro
    Quantity__c = 5
));

orders.add(new Device_Order__c(
    Device__c = devices[3].Id, // Dell XPS 15
    Quantity__c = 1
));

orders.add(new Device_Order__c(
    Device__c = devices[4].Id, // Samsung Galaxy S24
    Quantity__c = 4
));

orders.add(new Device_Order__c(
    Device__c = devices[2].Id, // iPad Air
    Quantity__c = 2
));

// Additional orders for analytics
orders.add(new Device_Order__c(
    Device__c = devices[1].Id, // iPhone 15 Pro (popular)
    Quantity__c = 2
));

orders.add(new Device_Order__c(
    Device__c = devices[5].Id, // AirPods Pro (popular)
    Quantity__c = 3
));

insert orders;
System.debug('✅ Created ' + orders.size() + ' orders');

// Step 4: Summary
System.debug('📊 DATA CREATION SUMMARY:');
System.debug('✅ Devices Created: ' + devices.size());
System.debug('✅ Orders Created: ' + orders.size());

System.debug('=== PHASE 4.3 SIMPLE DATA SEED COMPLETE ===');
System.debug('🎯 Ready for Dashboard Analytics!');
