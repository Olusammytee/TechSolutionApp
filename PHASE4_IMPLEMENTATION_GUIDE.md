# Phase 4 Implementation Guide: Interactive Learning Components

**📊 Difficulty Level: Intermediate**
**⏱️ Estimated Time: 2-3 weeks**
**🎯 Priority: Phase 4.1 - Advanced Order Processing Workflow**
**📚 Part of: [Enhancement Roadmap](ENHANCEMENT_ROADMAP.md)**

## 🎯 Implementation Overview

Transform our basic device ordering system into a sophisticated, real-time order processing workflow that demonstrates advanced Salesforce development concepts while providing an engaging learning experience.

## 📋 **Feature 1: Enhanced Validation Rules**

### **Educational Objective**: Learn data integrity and business logic implementation

#### **Validation Rules to Implement:**

1. **Device Selection Required**
   ```
   Rule Name: Device_Required
   Error Condition: ISBLANK(Device__c)
   Error Message: "Please select a device for this order."
   Error Location: Device__c field
   ```

2. **Positive Quantity Validation**
   ```
   Rule Name: Positive_Quantity_Required
   Error Condition: Quantity__c <= 0
   Error Message: "Order quantity must be greater than zero."
   Error Location: Quantity__c field
   ```

3. **Stock Availability Check**
   ```
   Rule Name: Stock_Availability_Check
   Error Condition: Quantity__c > Device__r.Stock_Quantity__c
   Error Message: "Order quantity cannot exceed available stock ({!Device__r.Stock_Quantity__c} units)."
   Error Location: Quantity__c field
   ```

4. **Business Hours Ordering**
   ```
   Rule Name: Business_Hours_Only
   Error Condition: NOT(AND(HOUR(NOW()) >= 9, HOUR(NOW()) <= 17, MOD(WEEKDAY(TODAY()), 7) >= 2))
   Error Message: "Orders can only be placed during business hours (9 AM - 5 PM, Monday-Friday)."
   Error Location: Top of Page
   ```

#### **Implementation Steps:**
1. Navigate to Setup → Object Manager → Device_Order__c → Validation Rules
2. Create each validation rule with provided formulas
3. Test with various scenarios to ensure proper functionality
4. Document each rule's purpose and business logic

#### **Learning Outcomes:**
- Understand formula syntax and functions
- Learn business rule implementation
- Master error handling and user experience
- Practice testing and validation strategies

## 🔧 **Feature 2: Intelligent Apex Triggers**

### **Educational Objective**: Master event-driven programming patterns

#### **OrderTrigger Implementation:**

```apex
trigger OrderTrigger on Device_Order__c (before insert, before update, after insert, after update) {
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            OrderTriggerHandler.calculateOrderTotals(Trigger.new);
            OrderTriggerHandler.validateStockAvailability(Trigger.new);
        }
    }
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            OrderTriggerHandler.updateDeviceStock(Trigger.new);
            OrderTriggerHandler.sendOrderConfirmation(Trigger.new);
            OrderTriggerHandler.createAuditTrail(Trigger.new);
        }
        
        if (Trigger.isUpdate) {
            OrderTriggerHandler.handleStatusChanges(Trigger.new, Trigger.oldMap);
            OrderTriggerHandler.adjustStockLevels(Trigger.new, Trigger.oldMap);
        }
    }
}
```

#### **OrderTriggerHandler Class:**

```apex
public class OrderTriggerHandler {
    
    public static void calculateOrderTotals(List<Device_Order__c> orders) {
        // Query related device prices
        Set<Id> deviceIds = new Set<Id>();
        for (Device_Order__c order : orders) {
            if (order.Device__c != null) {
                deviceIds.add(order.Device__c);
            }
        }
        
        Map<Id, Device__c> deviceMap = new Map<Id, Device__c>(
            [SELECT Id, Price__c FROM Device__c WHERE Id IN :deviceIds]
        );
        
        // Calculate totals
        for (Device_Order__c order : orders) {
            if (order.Device__c != null && deviceMap.containsKey(order.Device__c)) {
                Device__c device = deviceMap.get(order.Device__c);
                order.Total_Price__c = device.Price__c * order.Quantity__c;
            }
        }
    }
    
    public static void updateDeviceStock(List<Device_Order__c> orders) {
        // Implementation for stock updates
        Map<Id, Decimal> stockUpdates = new Map<Id, Decimal>();
        
        for (Device_Order__c order : orders) {
            if (order.Status__c == 'Confirmed' && order.Device__c != null) {
                if (stockUpdates.containsKey(order.Device__c)) {
                    stockUpdates.put(order.Device__c, 
                        stockUpdates.get(order.Device__c) + order.Quantity__c);
                } else {
                    stockUpdates.put(order.Device__c, order.Quantity__c);
                }
            }
        }
        
        if (!stockUpdates.isEmpty()) {
            List<Device__c> devicesToUpdate = new List<Device__c>();
            for (Id deviceId : stockUpdates.keySet()) {
                devicesToUpdate.add(new Device__c(
                    Id = deviceId,
                    Stock_Quantity__c = stockUpdates.get(deviceId)
                ));
            }
            
            update devicesToUpdate;
        }
    }
    
    // Additional methods for notifications, audit trails, etc.
}
```

#### **Implementation Steps:**
1. Create the trigger file in force-app/main/default/triggers/
2. Create the handler class in force-app/main/default/classes/
3. Add comprehensive test classes with 100% code coverage
4. Deploy and test with various scenarios

#### **Learning Outcomes:**
- Understand trigger context and execution order
- Learn separation of concerns with handler classes
- Master SOQL queries and DML operations
- Practice bulk processing and governor limits

## 📊 **Feature 3: Real-time Stock Management**

### **Educational Objective**: Implement business process automation

#### **Custom Fields to Add:**

1. **Device__c Object:**
   ```
   - Minimum_Stock_Level__c (Number)
   - Reorder_Point__c (Number)
   - Last_Restocked__c (Date)
   - Stock_Status__c (Picklist: In Stock, Low Stock, Out of Stock)
   ```

2. **Device_Order__c Object:**
   ```
   - Total_Price__c (Currency)
   - Order_Date__c (Date, auto-populated)
   - Confirmation_Number__c (Text, auto-generated)
   ```

#### **Automated Stock Status Updates:**

```apex
public class StockManagementService {
    
    public static void updateStockStatus(List<Device__c> devices) {
        for (Device__c device : devices) {
            if (device.Stock_Quantity__c <= 0) {
                device.Stock_Status__c = 'Out of Stock';
            } else if (device.Stock_Quantity__c <= device.Minimum_Stock_Level__c) {
                device.Stock_Status__c = 'Low Stock';
            } else {
                device.Stock_Status__c = 'In Stock';
            }
        }
    }
    
    public static void generateLowStockAlerts(List<Device__c> devices) {
        List<Task> alertTasks = new List<Task>();
        
        for (Device__c device : devices) {
            if (device.Stock_Status__c == 'Low Stock') {
                alertTasks.add(new Task(
                    Subject = 'Low Stock Alert: ' + device.Name,
                    Description = 'Device stock is below minimum level. Current: ' + 
                                device.Stock_Quantity__c + ', Minimum: ' + 
                                device.Minimum_Stock_Level__c,
                    Priority = 'High',
                    Status = 'Not Started',
                    WhatId = device.Id
                ));
            }
        }
        
        if (!alertTasks.isEmpty()) {
            insert alertTasks;
        }
    }
}
```

## 🎨 **Feature 4: Lightning Web Components Dashboard**

### **Educational Objective**: Build modern, reactive user interfaces

#### **Order Dashboard Component Structure:**

```
orderDashboard/
├── orderDashboard.html
├── orderDashboard.js
├── orderDashboard.css
└── orderDashboard.js-meta.xml
```

#### **orderDashboard.html:**
```html
<template>
    <lightning-card title="Order Processing Dashboard" icon-name="standard:orders">
        <div class="slds-grid slds-wrap">
            <!-- Real-time Order Stats -->
            <div class="slds-col slds-size_1-of-3">
                <lightning-tile label="Total Orders Today" href="#" type="media">
                    <lightning-icon icon-name="standard:orders" slot="media"></lightning-icon>
                    <p class="slds-text-heading_large">{todayOrderCount}</p>
                </lightning-tile>
            </div>
            
            <!-- Stock Alerts -->
            <div class="slds-col slds-size_1-of-3">
                <lightning-tile label="Low Stock Alerts" href="#" type="media">
                    <lightning-icon icon-name="standard:warning" slot="media"></lightning-icon>
                    <p class="slds-text-heading_large slds-text-color_error">{lowStockCount}</p>
                </lightning-tile>
            </div>
            
            <!-- Revenue Today -->
            <div class="slds-col slds-size_1-of-3">
                <lightning-tile label="Revenue Today" href="#" type="media">
                    <lightning-icon icon-name="standard:currency" slot="media"></lightning-icon>
                    <p class="slds-text-heading_large">{formattedRevenue}</p>
                </lightning-tile>
            </div>
        </div>
        
        <!-- Interactive Order Form -->
        <div class="slds-m-top_large">
            <c-order-creation-form onordercreated={handleOrderCreated}></c-order-creation-form>
        </div>
        
        <!-- Recent Orders Table -->
        <div class="slds-m-top_large">
            <lightning-datatable
                data={recentOrders}
                columns={orderColumns}
                key-field="Id"
                onrowaction={handleRowAction}>
            </lightning-datatable>
        </div>
    </lightning-card>
</template>
```

#### **orderDashboard.js:**
```javascript
import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTodayOrderStats from '@salesforce/apex/OrderDashboardController.getTodayOrderStats';
import getRecentOrders from '@salesforce/apex/OrderDashboardController.getRecentOrders';

export default class OrderDashboard extends LightningElement {
    @track todayOrderCount = 0;
    @track lowStockCount = 0;
    @track todayRevenue = 0;
    @track recentOrders = [];
    
    orderColumns = [
        { label: 'Order Number', fieldName: 'Name', type: 'text' },
        { label: 'Device', fieldName: 'DeviceName', type: 'text' },
        { label: 'Quantity', fieldName: 'Quantity__c', type: 'number' },
        { label: 'Total', fieldName: 'Total_Price__c', type: 'currency' },
        { label: 'Status', fieldName: 'Status__c', type: 'text' }
    ];
    
    @wire(getTodayOrderStats)
    wiredStats({ error, data }) {
        if (data) {
            this.todayOrderCount = data.orderCount;
            this.lowStockCount = data.lowStockCount;
            this.todayRevenue = data.revenue;
        } else if (error) {
            this.showToast('Error', 'Failed to load dashboard stats', 'error');
        }
    }
    
    @wire(getRecentOrders)
    wiredOrders({ error, data }) {
        if (data) {
            this.recentOrders = data;
        } else if (error) {
            this.showToast('Error', 'Failed to load recent orders', 'error');
        }
    }
    
    get formattedRevenue() {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD'
        }).format(this.todayRevenue);
    }
    
    handleOrderCreated() {
        // Refresh dashboard data
        return refreshApex(this.wiredStats);
    }
    
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }
}
```

## 📈 **Implementation Timeline**

### **Week 1: Foundation**
- Day 1-2: Create validation rules and test scenarios
- Day 3-4: Implement basic Apex trigger structure
- Day 5: Add custom fields and update page layouts

### **Week 2: Advanced Logic**
- Day 1-3: Complete trigger handler implementation
- Day 4-5: Build comprehensive test classes
- Weekend: Documentation and code review

### **Week 3: UI Components**
- Day 1-3: Develop Lightning Web Components
- Day 4-5: Integration testing and refinement
- Weekend: User acceptance testing and documentation

## 🎓 **Learning Assessment**

### **Knowledge Check Questions:**
1. What are the different trigger contexts and when should each be used?
2. How do validation rules differ from trigger validation?
3. What are the benefits of using handler classes in triggers?
4. How do Lightning Web Components communicate with Apex?

### **Practical Exercises:**
1. Create a custom validation rule for your specific business case
2. Modify the trigger to handle additional business logic
3. Build a custom LWC component for order reporting
4. Implement error handling and user feedback

---

**🎯 This implementation guide provides hands-on experience with advanced Salesforce development while building practical, real-world functionality that enhances our educational platform.**
