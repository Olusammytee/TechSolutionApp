/**
 * Enhanced Data Seed Script for TechSolutionApp Phase 4.3
 *
 * This comprehensive script creates diverse, realistic test data to support
 * advanced dashboard analytics, chart visualizations, and business scenarios.
 *
 * Educational Purpose: Demonstrates enterprise-level test data patterns
 * Part of: TechSolutionApp Phase 4.3 - Advanced Dashboard Features
 * Author: TechSolutionApp Educational Platform
 * Created: August 2024
 * Enhanced: August 2024 - Phase 4.3 Data Foundation
 *
 * Features:
 * - Diverse device categories with realistic pricing
 * - Varied stock levels for analytics testing
 * - Time-distributed orders for trend analysis
 * - Multiple business scenarios for comprehensive testing
 * - Proper relationship integrity and data validation
 */

System.debug('=== PHASE 4.3 ENHANCED DATA SEED PROCESS STARTING ===');

// Step 1: Clear existing data for clean slate
System.debug('Step 1: Clearing existing data for fresh start...');

// Delete existing orders first (due to lookup relationship)
List<Device_Order__c> existingOrders = [SELECT Id FROM Device_Order__c];
if (!existingOrders.isEmpty()) {
    delete existingOrders;
    System.debug('✅ Deleted ' + existingOrders.size() + ' existing orders');
} else {
    System.debug('ℹ️ No existing orders to delete');
}

// Delete existing devices
List<Device__c> existingDevices = [SELECT Id FROM Device__c];
if (!existingDevices.isEmpty()) {
    delete existingDevices;
    System.debug('✅ Deleted ' + existingDevices.size() + ' existing devices');
} else {
    System.debug('ℹ️ No existing devices to delete');
}

// Step 2: Create comprehensive device catalog with varied categories and stock levels
System.debug('Step 2: Creating comprehensive device catalog...');

List<Device__c> devices = new List<Device__c>();

// Premium Laptops - High value, varied stock
devices.add(new Device__c(
    Name = 'MacBook Pro 16"',
    Type__c = 'Laptop',
    Stock_Quantity__c = 12,
    Price__c = 2499.00,
    Active__c = true,
    Minimum_Stock_Level__c = 5,
    Reorder_Point__c = 3,
    Last_Restocked__c = Date.today().addDays(-15),
    Stock_Status__c = 'In Stock'
));

devices.add(new Device__c(
    Name = 'Dell XPS 15',
    Type__c = 'Laptop',
    Stock_Quantity__c = 3,
    Price__c = 1899.00,
    Active__c = true,
    Minimum_Stock_Level__c = 5,
    Reorder_Point__c = 3,
    Last_Restocked__c = Date.today().addDays(-30),
    Stock_Status__c = 'Low Stock'
));

devices.add(new Device__c(
    Name = 'ThinkPad X1 Carbon',
    Type__c = 'Laptop',
    Stock_Quantity__c = 0,
    Price__c = 1699.00,
    Active__c = true,
    Minimum_Stock_Level__c = 5,
    Reorder_Point__c = 3,
    Last_Restocked__c = Date.today().addDays(-45),
    Stock_Status__c = 'Out of Stock'
));

// Smartphones - Popular category with high turnover
devices.add(new Device__c(
    Name = 'iPhone 15 Pro',
    Type__c = 'Smartphone',
    Stock_Quantity__c = 25,
    Price__c = 999.00,
    Active__c = true,
    Minimum_Stock_Level__c = 10,
    Reorder_Point__c = 5,
    Last_Restocked__c = Date.today().addDays(-5),
    Stock_Status__c = 'In Stock'
));

devices.add(new Device__c(
    Name = 'Samsung Galaxy S24',
    Type__c = 'Smartphone',
    Stock_Quantity__c = 18,
    Price__c = 899.00,
    Active__c = true,
    Minimum_Stock_Level__c = 10,
    Reorder_Point__c = 5,
    Last_Restocked__c = Date.today().addDays(-10),
    Stock_Status__c = 'In Stock'
));

devices.add(new Device__c(
    Name = 'Google Pixel 8',
    Type__c = 'Smartphone',
    Stock_Quantity__c = 4,
    Price__c = 699.00,
    Active__c = true,
    Minimum_Stock_Level__c = 10,
    Reorder_Point__c = 5,
    Last_Restocked__c = Date.today().addDays(-20),
    Stock_Status__c = 'Low Stock'
));

// Tablets - Mid-range category
devices.add(new Device__c(
    Name = 'iPad Air',
    Type__c = 'Tablet',
    Stock_Quantity__c = 15,
    Price__c = 599.00,
    Active__c = true,
    Minimum_Stock_Level__c = 8,
    Reorder_Point__c = 4,
    Last_Restocked__c = Date.today().addDays(-12),
    Stock_Status__c = 'In Stock'
));

devices.add(new Device__c(
    Name = 'Surface Pro 9',
    Type__c = 'Tablet',
    Stock_Quantity__c = 8,
    Price__c = 1099.00,
    Active__c = true,
    Minimum_Stock_Level__c = 8,
    Reorder_Point__c = 4,
    Last_Restocked__c = Date.today().addDays(-18),
    Stock_Status__c = 'In Stock'
));

// Accessories - Lower value, higher volume
devices.add(new Device__c(
    Name = 'AirPods Pro',
    Type__c = 'Accessory',
    Stock_Quantity__c = 50,
    Price__c = 249.00,
    Active__c = true,
    Minimum_Stock_Level__c = 20,
    Reorder_Point__c = 10,
    Last_Restocked__c = Date.today().addDays(-3),
    Stock_Status__c = 'In Stock'
));

devices.add(new Device__c(
    Name = 'Magic Mouse',
    Type__c = 'Accessory',
    Stock_Quantity__c = 2,
    Price__c = 79.00,
    Active__c = true,
    Minimum_Stock_Level__c = 15,
    Reorder_Point__c = 8,
    Last_Restocked__c = Date.today().addDays(-25),
    Stock_Status__c = 'Low Stock'
));

insert devices;
System.debug('✅ Created ' + devices.size() + ' diverse devices with varied stock levels');

// Step 3: Create time-distributed orders for trend analysis
System.debug('Step 3: Creating time-distributed orders for analytics...');

List<Device_Order__c> orders = new List<Device_Order__c>();

// Recent orders (last 7 days) - for "recent activity" metrics
Date today = Date.today();

// High-value recent orders
orders.add(new Device_Order__c(
    Device__c = devices[0].Id, // MacBook Pro
    Quantity__c = 2,
    Order_Date__c = today.addDays(-2),
    Total_Price__c = 4998.00,
    Confirmation_Number__c = 'ORD-' + String.valueOf(Math.round(Math.random() * 10000))
));

orders.add(new Device_Order__c(
    Device__c = devices[3].Id, // iPhone 15 Pro
    Quantity__c = 3,
    Order_Date__c = today.addDays(-1),
    Total_Price__c = 2997.00,
    Confirmation_Number__c = 'ORD-' + String.valueOf(Math.round(Math.random() * 10000))
));

orders.add(new Device_Order__c(
    Device__c = devices[8].Id, // AirPods Pro
    Quantity__c = 5,
    Order_Date__c = today,
    Total_Price__c = 1245.00,
    Confirmation_Number__c = 'ORD-' + String.valueOf(Math.round(Math.random() * 10000))
));

// Medium-term orders (last 30 days) - for monthly trends
orders.add(new Device_Order__c(
    Device__c = devices[1].Id, // Dell XPS 15
    Quantity__c = 1,
    Order_Date__c = today.addDays(-15),
    Total_Price__c = 1899.00,
    Confirmation_Number__c = 'ORD-' + String.valueOf(Math.round(Math.random() * 10000))
));

orders.add(new Device_Order__c(
    Device__c = devices[4].Id, // Samsung Galaxy S24
    Quantity__c = 4,
    Order_Date__c = today.addDays(-20),
    Total_Price__c = 3596.00,
    Confirmation_Number__c = 'ORD-' + String.valueOf(Math.round(Math.random() * 10000))
));

orders.add(new Device_Order__c(
    Device__c = devices[6].Id, // iPad Air
    Quantity__c = 2,
    Order_Date__c = today.addDays(-25),
    Total_Price__c = 1198.00,
    Confirmation_Number__c = 'ORD-' + String.valueOf(Math.round(Math.random() * 10000))
));

// Longer-term orders (last 90 days) - for quarterly analysis
orders.add(new Device_Order__c(
    Device__c = devices[7].Id, // Surface Pro 9
    Quantity__c = 1,
    Order_Date__c = today.addDays(-45),
    Total_Price__c = 1099.00,
    Confirmation_Number__c = 'ORD-' + String.valueOf(Math.round(Math.random() * 10000))
));

orders.add(new Device_Order__c(
    Device__c = devices[5].Id, // Google Pixel 8
    Quantity__c = 6,
    Order_Date__c = today.addDays(-60),
    Total_Price__c = 4194.00,
    Confirmation_Number__c = 'ORD-' + String.valueOf(Math.round(Math.random() * 10000))
));

orders.add(new Device_Order__c(
    Device__c = devices[9].Id, // Magic Mouse
    Quantity__c = 10,
    Order_Date__c = today.addDays(-75),
    Total_Price__c = 790.00,
    Confirmation_Number__c = 'ORD-' + String.valueOf(Math.round(Math.random() * 10000))
));

// Additional orders for device popularity analysis
orders.add(new Device_Order__c(
    Device__c = devices[3].Id, // iPhone 15 Pro (popular device)
    Quantity__c = 2,
    Order_Date__c = today.addDays(-10),
    Total_Price__c = 1998.00,
    Confirmation_Number__c = 'ORD-' + String.valueOf(Math.round(Math.random() * 10000))
));

orders.add(new Device_Order__c(
    Device__c = devices[3].Id, // iPhone 15 Pro (popular device)
    Quantity__c = 1,
    Order_Date__c = today.addDays(-30),
    Total_Price__c = 999.00,
    Confirmation_Number__c = 'ORD-' + String.valueOf(Math.round(Math.random() * 10000))
));

orders.add(new Device_Order__c(
    Device__c = devices[8].Id, // AirPods Pro (popular accessory)
    Quantity__c = 3,
    Order_Date__c = today.addDays(-5),
    Total_Price__c = 747.00,
    Confirmation_Number__c = 'ORD-' + String.valueOf(Math.round(Math.random() * 10000))
));

insert orders;
System.debug('✅ Created ' + orders.size() + ' time-distributed orders for analytics');

// Step 4: Verification and summary
System.debug('Step 4: Verifying data integrity and relationships...');

// Verify device-order relationships
Integer totalOrderValue = 0;
for (Device_Order__c order : orders) {
    totalOrderValue += Integer.valueOf(order.Total_Price__c);
}

System.debug('📊 DATA CREATION SUMMARY:');
System.debug('✅ Devices Created: ' + devices.size());
System.debug('✅ Orders Created: ' + orders.size());
System.debug('💰 Total Order Value: $' + totalOrderValue);
System.debug('📅 Order Date Range: ' + today.addDays(-75) + ' to ' + today);

// Verify stock status distribution
Integer inStock = 0, lowStock = 0, outOfStock = 0;
for (Device__c device : devices) {
    if (device.Stock_Status__c == 'In Stock') inStock++;
    else if (device.Stock_Status__c == 'Low Stock') lowStock++;
    else if (device.Stock_Status__c == 'Out of Stock') outOfStock++;
}

System.debug('📦 STOCK STATUS DISTRIBUTION:');
System.debug('✅ In Stock: ' + inStock + ' devices');
System.debug('⚠️ Low Stock: ' + lowStock + ' devices');
System.debug('❌ Out of Stock: ' + outOfStock + ' devices');

System.debug('=== PHASE 4.3 ENHANCED DATA SEED PROCESS COMPLETE ===');
System.debug('🎯 Ready for Advanced Dashboard Analytics!');
