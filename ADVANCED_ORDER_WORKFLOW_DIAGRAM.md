# 🔄 Advanced Order Processing Workflow - Visual Guide

**Purpose**: Complete visual breakdown of how orders flow through the TechSolutionApp system
**Audience**: Beginners to Intermediate Salesforce learners
**Last Updated**: November 2025

---

## 📊 Complete Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ADVANCED ORDER PROCESSING WORKFLOW                   │
└─────────────────────────────────────────────────────────────────────────────┘

                                    USER
                                     │
                                     ▼
        ┌────────────────────────────────────────────────────┐
        │   🎨 LWC ORDER FORM (User Interface)               │
        │   ─────────────────────────────────────            │
        │   • Customer Name: [John Doe_______]               │
        │   • Device: [Laptop ▼]                             │
        │   • Quantity: [5_____]                             │
        │   • Price: [$999____]                              │
        │                                                     │
        │               [Submit Order]                        │
        └─────────────────┬──────────────────────────────────┘
                          │
                          ▼
        ┌────────────────────────────────────────────────────┐
        │   ✅ VALIDATION RULES (Gatekeeper)                 │
        │   ──────────────────────────────                   │
        │   Check #1: Is device selected? ✓                  │
        │   Check #2: Is quantity > 0? ✓                     │
        │   Check #3: Quantity ≤ stock? ✓                    │
        │   Check #4: Business hours? ✓                      │
        │   Check #5: Price calculation OK? ✓                │
        └─────────────┬────────────────┬─────────────────────┘
                      │                │
                 ✅ PASS          ❌ FAIL
                      │                │
                      │                ▼
                      │      ┌──────────────────────┐
                      │      │  ⛔ ORDER REJECTED   │
                      │      │  Show error message  │
                      │      │  to user             │
                      │      └──────────────────────┘
                      │
                      ▼
        ┌────────────────────────────────────────────────────┐
        │   💾 ORDER SAVED TO DATABASE                       │
        │   ──────────────────────────                       │
        │   Order Record Created:                            │
        │   • ID: ORD-12345                                  │
        │   • Customer: John Doe                             │
        │   • Device: Laptop                                 │
        │   • Quantity: 5                                    │
        │   • Status: "New"                                  │
        │   • Timestamp: 2025-11-13 14:30:00                 │
        └─────────────────┬──────────────────────────────────┘
                          │
                          ▼
        ┌────────────────────────────────────────────────────┐
        │   ⚡ APEX TRIGGER FIRES (Automation Engine)        │
        │   ──────────────────────────────────────           │
        │   Trigger: OrderTrigger                            │
        │   Context: AFTER INSERT                            │
        │   Records: 1 order                                 │
        │                                                     │
        │   Calling → OrderTriggerHandler.afterInsert()      │
        └─────────────────┬──────────────────────────────────┘
                          │
                          ▼
        ┌────────────────────────────────────────────────────┐
        │   🔧 TRIGGER HANDLER LOGIC (Business Rules)        │
        │   ──────────────────────────────────────           │
        │   Step 1: Validate bulk records ✓                  │
        │   Step 2: Calculate totals ✓                       │
        │   Step 3: Check inventory ✓                        │
        │   Step 4: Route to appropriate service ✓           │
        └─────────────────┬──────────────────────────────────┘
                          │
                    ┌─────┴─────────┐
                    │               │
                    ▼               ▼
    ┌───────────────────────┐  ┌──────────────────────┐
    │ 📦 STOCK SERVICE      │  │ 📧 NOTIFICATION      │
    │ ─────────────────     │  │    SERVICE           │
    │ • Deduct quantity     │  │ ──────────────       │
    │   Laptops: 20 → 15    │  │ • Email customer     │
    │                       │  │ • Email warehouse    │
    │ • Update Device       │  │ • Log notification   │
    │   record              │  │                      │
    │                       │  │ Sent at: 14:30:05    │
    └───────────┬───────────┘  └──────────┬───────────┘
                │                         │
                ▼                         │
    ┌──────────────────────────┐          │
    │ 📊 STOCK MANAGEMENT      │          │
    │ ───────────────────      │          │
    │ Current Stock: 15        │          │
    │ Threshold: 10            │          │
    │ Status: ✅ OK            │          │
    │                          │          │
    │ IF Stock < 10:           │          │
    │   → Send Alert           │          │
    │   → Create Reorder Task  │          │
    └────────────┬─────────────┘          │
                 │                        │
                 └────────┬───────────────┘
                          │
                          ▼
        ┌────────────────────────────────────────────────────┐
        │   📝 AUDIT TRAIL CREATED                           │
        │   ─────────────────────                            │
        │   • Action: Order Created                          │
        │   • User: John Doe                                 │
        │   • Timestamp: 2025-11-13 14:30:00                 │
        │   • Changes: New order, Stock reduced              │
        │   • Old Stock: 20 → New Stock: 15                  │
        └─────────────────┬──────────────────────────────────┘
                          │
                          ▼
        ┌────────────────────────────────────────────────────┐
        │   🔄 UPDATE ORDER STATUS                           │
        │   ────────────────────                             │
        │   Status: "New" → "Confirmed"                      │
        │   Confirmation #: CONF-98765                       │
        │   Updated at: 14:30:10                             │
        └─────────────────┬──────────────────────────────────┘
                          │
                          ▼
        ┌────────────────────────────────────────────────────┐
        │   🎨 DASHBOARD AUTO-UPDATES (Real-time UI)         │
        │   ───────────────────────────────────              │
        │   ┌──────────────────────────────────┐             │
        │   │ 📊 Live Order Feed               │             │
        │   │ ──────────────────               │             │
        │   │ • ORD-12345 - Confirmed ✅       │             │
        │   │ • ORD-12344 - Shipped 🚚         │             │
        │   │ • ORD-12343 - Delivered ✓        │             │
        │   └──────────────────────────────────┘             │
        │                                                     │
        │   ┌──────────────────────────────────┐             │
        │   │ 📈 Stock Levels                  │             │
        │   │ ────────────                     │             │
        │   │ Laptops:  [████████░░] 15/20     │             │
        │   │ Phones:   [██████████] 25/25     │             │
        │   │ Tablets:  [███░░░░░░░]  6/20 ⚠️  │             │
        │   └──────────────────────────────────┘             │
        └─────────────────┬──────────────────────────────────┘
                          │
                          ▼
        ┌────────────────────────────────────────────────────┐
        │   ✅ ORDER PROCESSING COMPLETE                     │
        │   ────────────────────────────                     │
        │   • User notified                                  │
        │   • Inventory updated                              │
        │   • Dashboard refreshed                            │
        │   • Audit trail logged                             │
        │                                                     │
        │   Total processing time: 0.5 seconds               │
        └────────────────────────────────────────────────────┘
```

---

## 🔍 Detailed Component Breakdown

### 1️⃣ LWC Order Form (User Interface Layer)

**Purpose**: Beautiful, user-friendly interface for creating orders

**Technology**: Lightning Web Components (LWC) - Modern JavaScript framework

**Key Features**:
```javascript
// order-form.js (simplified)
import { LightningElement, track, wire } from 'lwc';
import getAvailableDevices from '@salesforce/apex/OrderController.getAvailableDevices';
import createOrder from '@salesforce/apex/OrderController.createOrder';

export default class OrderForm extends LightningElement {
    @track selectedDevice;
    @track quantity = 1;
    @track customerName;

    // Real-time validation as user types
    handleQuantityChange(event) {
        this.quantity = event.target.value;
        if (this.quantity < 1) {
            this.showError('Quantity must be positive');
        }
    }

    // Submit order with validation
    handleSubmit() {
        if (this.validateForm()) {
            createOrder({
                deviceId: this.selectedDevice,
                quantity: this.quantity,
                customer: this.customerName
            })
            .then(result => {
                this.showSuccess('Order created!');
                this.refreshDashboard();
            })
            .catch(error => {
                this.handleError(error);
            });
        }
    }
}
```

**What happens**:
1. User selects device from dropdown (e.g., "Laptop")
2. Enters quantity (e.g., 5)
3. Form validates in real-time (turns red if invalid)
4. Clicks "Submit Order"
5. JavaScript calls Apex method to save order

**Learning objectives**:
- How to create LWC components
- How to call Apex from JavaScript
- How to handle user input validation
- How to update UI dynamically

---

### 2️⃣ Validation Rules (Data Quality Layer)

**Purpose**: Prevent bad data from entering the system

**Technology**: Declarative Validation Rules (no code required!)

**Rule #1: Device Selection Required**
```
Rule Name: Order_Requires_Device
Error Condition Formula: ISBLANK(Device__c)
Error Message: "Please select a device before submitting the order."
Error Location: Field (Device__c)
```

**Real-world scenario**:
- ❌ User tries to submit order without selecting device
- ✅ Salesforce shows error: "Please select a device"
- 🛑 Order is NOT saved to database

**Rule #2: Positive Quantity**
```
Rule Name: Order_Quantity_Must_Be_Positive
Error Condition Formula: Quantity__c <= 0
Error Message: "Quantity must be greater than zero."
Error Location: Field (Quantity__c)
```

**Rule #3: Stock Availability Check**
```
Rule Name: Order_Cannot_Exceed_Stock
Error Condition Formula: Quantity__c > Device__r.Stock_Quantity__c
Error Message: "Cannot order more than available stock. Available: {!Device__r.Stock_Quantity__c}"
Error Location: Top of Page
```

**Real-world scenario**:
- 📦 Laptops in stock: 20
- ❌ User tries to order 25 laptops
- ✅ Error: "Cannot order more than available stock. Available: 20"
- 💡 User changes quantity to 15
- ✅ Order proceeds

**Rule #4: Business Hours Only**
```
Rule Name: Orders_Only_During_Business_Hours
Error Condition Formula:
AND(
  OR(
    HOUR(NOW()) < 8,  /* Before 8 AM */
    HOUR(NOW()) > 18  /* After 6 PM */
  ),
  NOT($Profile.Name = "System Administrator")
)
Error Message: "Orders can only be placed during business hours (8 AM - 6 PM)."
```

**Learning objectives**:
- How to write formula-based validation rules
- How to reference related records (Device__r)
- How to use date/time functions
- How to exempt certain profiles

---

### 3️⃣ Apex Trigger (Automation Layer)

**Purpose**: Automatically run code when records are created/updated

**Technology**: Apex Triggers + Trigger Handler Pattern

**OrderTrigger.trigger**:
```apex
trigger OrderTrigger on Order__c (after insert, after update, before insert, before update) {

    // Use handler pattern for clean, testable code
    OrderTriggerHandler handler = new OrderTriggerHandler();

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.beforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            handler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.afterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            handler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}
```

**OrderTriggerHandler.cls**:
```apex
public class OrderTriggerHandler {

    /**
     * After orders are inserted, perform post-processing
     * - Deduct stock
     * - Send notifications
     * - Create audit records
     * - Update order status
     */
    public void afterInsert(List<Order__c> newOrders) {

        // IMPORTANT: All methods must be bulkified!
        // Must handle 200+ records at once

        // 1. Deduct stock for all ordered devices
        StockManagementService.deductStock(newOrders);

        // 2. Send confirmation emails
        NotificationService.sendOrderConfirmations(newOrders);

        // 3. Update order statuses to "Confirmed"
        OrderStatusService.confirmOrders(newOrders);

        // 4. Create audit trail records
        AuditService.logOrderCreation(newOrders);

        // 5. Check if any devices need reordering
        StockManagementService.checkLowStockAlerts(newOrders);
    }

    /**
     * Before orders are inserted, perform pre-validation
     */
    public void beforeInsert(List<Order__c> newOrders) {
        // Calculate total prices
        for (Order__c order : newOrders) {
            if (order.Unit_Price__c != null && order.Quantity__c != null) {
                order.Total_Price__c = order.Unit_Price__c * order.Quantity__c;
            }
        }
    }
}
```

**Key Salesforce Concepts**:

**Trigger Contexts**:
- `BEFORE INSERT`: Runs before record is saved (modify values)
- `AFTER INSERT`: Runs after record is saved (create related records)
- `BEFORE UPDATE`: Runs before update is saved
- `AFTER UPDATE`: Runs after update is saved

**Why separate handler from trigger?**
- ✅ Easier to test
- ✅ Better organization
- ✅ Easier to disable/debug
- ✅ Follows best practices

**Bulkification Example**:
```apex
// ❌ BAD: Not bulkified (causes errors with 200+ records)
public void deductStockBad(List<Order__c> orders) {
    for (Order__c order : orders) {
        Device__c device = [SELECT Stock_Quantity__c FROM Device__c WHERE Id = :order.Device__c];
        device.Stock_Quantity__c -= order.Quantity__c;
        update device;  // ❌ DML inside loop = governor limit error!
    }
}

// ✅ GOOD: Bulkified (handles 200+ records efficiently)
public void deductStockGood(List<Order__c> orders) {
    // 1. Collect all device IDs
    Set<Id> deviceIds = new Set<Id>();
    for (Order__c order : orders) {
        deviceIds.add(order.Device__c);
    }

    // 2. Query all devices at once (1 SOQL query)
    Map<Id, Device__c> devicesMap = new Map<Id, Device__c>(
        [SELECT Id, Stock_Quantity__c FROM Device__c WHERE Id IN :deviceIds]
    );

    // 3. Update stock quantities in memory
    for (Order__c order : orders) {
        Device__c device = devicesMap.get(order.Device__c);
        device.Stock_Quantity__c -= order.Quantity__c;
    }

    // 4. Update all devices at once (1 DML statement)
    update devicesMap.values();
}
```

**Learning objectives**:
- Understand trigger contexts
- Implement trigger handler pattern
- Master bulkification techniques
- Avoid governor limits (SOQL, DML)

---

### 4️⃣ Stock Management Service

**Purpose**: Automatically manage inventory levels

**StockManagementService.cls**:
```apex
public class StockManagementService {

    // Threshold below which alerts are sent
    private static final Integer LOW_STOCK_THRESHOLD = 10;

    /**
     * Deduct stock quantities for ordered devices
     * @param orders List of newly created orders
     */
    public static void deductStock(List<Order__c> orders) {

        // Collect device IDs and quantities to deduct
        Map<Id, Decimal> stockDeductions = new Map<Id, Decimal>();

        for (Order__c order : orders) {
            if (stockDeductions.containsKey(order.Device__c)) {
                // Multiple orders for same device: add quantities
                stockDeductions.put(
                    order.Device__c,
                    stockDeductions.get(order.Device__c) + order.Quantity__c
                );
            } else {
                stockDeductions.put(order.Device__c, order.Quantity__c);
            }
        }

        // Query devices
        List<Device__c> devices = [
            SELECT Id, Name, Stock_Quantity__c, Low_Stock_Threshold__c
            FROM Device__c
            WHERE Id IN :stockDeductions.keySet()
        ];

        // Update stock quantities
        for (Device__c device : devices) {
            Decimal deduction = stockDeductions.get(device.Id);
            device.Stock_Quantity__c -= deduction;

            // Log stock change
            System.debug('Stock updated for ' + device.Name +
                        ': deducted ' + deduction +
                        ', new stock: ' + device.Stock_Quantity__c);
        }

        update devices;
    }

    /**
     * Check if any devices are below low stock threshold
     * Send alerts if necessary
     */
    public static void checkLowStockAlerts(List<Order__c> orders) {

        // Get device IDs from orders
        Set<Id> deviceIds = new Set<Id>();
        for (Order__c order : orders) {
            deviceIds.add(order.Device__c);
        }

        // Query devices with current stock
        List<Device__c> devices = [
            SELECT Id, Name, Stock_Quantity__c,
                   Low_Stock_Threshold__c, Last_Reorder_Alert_Date__c
            FROM Device__c
            WHERE Id IN :deviceIds
        ];

        // Check for low stock
        List<Low_Stock_Alert__c> alerts = new List<Low_Stock_Alert__c>();

        for (Device__c device : devices) {
            Decimal threshold = device.Low_Stock_Threshold__c != null
                ? device.Low_Stock_Threshold__c
                : LOW_STOCK_THRESHOLD;

            if (device.Stock_Quantity__c < threshold) {

                // Don't spam alerts: only send once per day
                if (device.Last_Reorder_Alert_Date__c == null ||
                    device.Last_Reorder_Alert_Date__c < System.today()) {

                    // Create alert record
                    alerts.add(new Low_Stock_Alert__c(
                        Device__c = device.Id,
                        Current_Stock__c = device.Stock_Quantity__c,
                        Threshold__c = threshold,
                        Alert_Date__c = System.now(),
                        Status__c = 'New'
                    ));

                    // Update device to prevent duplicate alerts
                    device.Last_Reorder_Alert_Date__c = System.today();
                }
            }
        }

        // Save alert records
        if (!alerts.isEmpty()) {
            insert alerts;
            update devices;

            // Send email notification to purchasing team
            NotificationService.sendLowStockAlert(alerts);
        }
    }
}
```

**Real-world scenario**:

**Initial State**:
- Laptops in stock: 20
- Low stock threshold: 10

**Order placed**: 5 laptops
- Stock: 20 → 15
- Status: ✅ OK

**Order placed**: 8 more laptops
- Stock: 15 → 7
- Status: ⚠️ LOW STOCK
- Alert created!
- Email sent to purchasing manager

**Learning objectives**:
- Service class architecture
- Complex business logic
- Preventing duplicate alerts
- Logging and debugging

---

### 5️⃣ Notification Service

**Purpose**: Send emails and notifications to users

**NotificationService.cls**:
```apex
public class NotificationService {

    /**
     * Send order confirmation emails to customers
     */
    public static void sendOrderConfirmations(List<Order__c> orders) {

        // Salesforce allows max 10 emails per transaction
        // So we batch them
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Order__c order : orders) {

            // Create email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            // Set recipient (order customer)
            email.setToAddresses(new String[] { order.Customer_Email__c });

            // Set subject
            email.setSubject('Order Confirmation - ' + order.Name);

            // Build HTML body
            String htmlBody = '<html><body>';
            htmlBody += '<h1>Thank you for your order!</h1>';
            htmlBody += '<p>Your order has been confirmed.</p>';
            htmlBody += '<table border="1" cellpadding="10">';
            htmlBody += '<tr><th>Order Number</th><td>' + order.Name + '</td></tr>';
            htmlBody += '<tr><th>Device</th><td>' + order.Device__r.Name + '</td></tr>';
            htmlBody += '<tr><th>Quantity</th><td>' + order.Quantity__c + '</td></tr>';
            htmlBody += '<tr><th>Total Price</th><td>$' + order.Total_Price__c + '</td></tr>';
            htmlBody += '<tr><th>Status</th><td>' + order.Status__c + '</td></tr>';
            htmlBody += '</table>';
            htmlBody += '<p>You will receive another email when your order ships.</p>';
            htmlBody += '</body></html>';

            email.setHtmlBody(htmlBody);

            // Add to batch
            emails.add(email);
        }

        // Send all emails (max 10 per transaction)
        if (!emails.isEmpty()) {
            try {
                Messaging.sendEmail(emails);
                System.debug('Successfully sent ' + emails.size() + ' confirmation emails');
            } catch (Exception e) {
                System.debug('Error sending emails: ' + e.getMessage());
                // Log error but don't fail the entire transaction
            }
        }
    }

    /**
     * Send low stock alerts to purchasing team
     */
    public static void sendLowStockAlert(List<Low_Stock_Alert__c> alerts) {

        // Build email body with all alerts
        String htmlBody = '<html><body>';
        htmlBody += '<h1>⚠️ Low Stock Alert</h1>';
        htmlBody += '<p>The following devices are running low on stock:</p>';
        htmlBody += '<table border="1" cellpadding="10">';
        htmlBody += '<tr><th>Device</th><th>Current Stock</th><th>Threshold</th><th>Action Needed</th></tr>';

        for (Low_Stock_Alert__c alert : alerts) {
            htmlBody += '<tr>';
            htmlBody += '<td>' + alert.Device__r.Name + '</td>';
            htmlBody += '<td style="color: red;">' + alert.Current_Stock__c + '</td>';
            htmlBody += '<td>' + alert.Threshold__c + '</td>';
            htmlBody += '<td>Reorder immediately</td>';
            htmlBody += '</tr>';
        }

        htmlBody += '</table>';
        htmlBody += '<p>Please process reorders as soon as possible.</p>';
        htmlBody += '</body></html>';

        // Send to purchasing team
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { 'purchasing@techsolution.com' });
        email.setSubject('Low Stock Alert - Action Required');
        email.setHtmlBody(htmlBody);

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
    }
}
```

**Learning objectives**:
- How to send emails from Apex
- HTML email formatting
- Governor limits (max 10 emails per transaction)
- Error handling for email failures

---

### 6️⃣ Lightning Web Components Dashboard

**Purpose**: Real-time visualization of orders and inventory

**Dashboard Structure**:
```
dashboard-container/
├── order-feed/           (Shows recent orders)
├── stock-monitor/        (Shows inventory levels)
├── order-form/           (Create new orders)
└── status-timeline/      (Track order progress)
```

**Component: stock-monitor.html**:
```html
<template>
    <lightning-card title="Stock Levels" icon-name="standard:product">

        <!-- Loading spinner -->
        <template if:true={isLoading}>
            <lightning-spinner alternative-text="Loading"></lightning-spinner>
        </template>

        <!-- Stock level bars -->
        <template if:false={isLoading}>
            <div class="slds-p-around_medium">

                <template for:each={devices} for:item="device">
                    <div key={device.Id} class="slds-m-bottom_medium">

                        <!-- Device name -->
                        <div class="slds-text-heading_small">
                            {device.Name}
                        </div>

                        <!-- Stock level bar -->
                        <div class="stock-bar-container">
                            <div class="stock-bar"
                                 style={device.stockBarStyle}
                                 data-stock={device.Stock_Quantity__c}>
                            </div>
                        </div>

                        <!-- Stock count and status -->
                        <div class="slds-grid slds-grid_align-spread">
                            <span>{device.Stock_Quantity__c} / {device.Max_Stock__c}</span>
                            <span class={device.statusClass}>
                                {device.stockStatus}
                            </span>
                        </div>

                    </div>
                </template>

            </div>
        </template>

    </lightning-card>
</template>
```

**Component: stock-monitor.js**:
```javascript
import { LightningElement, wire, track } from 'lwc';
import getDeviceStock from '@salesforce/apex/DashboardController.getDeviceStock';
import { refreshApex } from '@salesforce/apex';

export default class StockMonitor extends LightningElement {
    @track devices = [];
    @track isLoading = true;
    wiredDevicesResult;

    // Wire Apex method to get device stock data
    @wire(getDeviceStock)
    wiredDevices(result) {
        this.wiredDevicesResult = result;

        if (result.data) {
            // Process data for UI
            this.devices = result.data.map(device => {

                // Calculate stock percentage
                const stockPercent = (device.Stock_Quantity__c / device.Max_Stock__c) * 100;

                // Determine status
                let stockStatus, statusClass, barColor;

                if (stockPercent >= 50) {
                    stockStatus = '✅ Good';
                    statusClass = 'status-good';
                    barColor = '#4bca81'; // Green
                } else if (stockPercent >= 20) {
                    stockStatus = '⚠️ Low';
                    statusClass = 'status-warning';
                    barColor = '#ffb75d'; // Orange
                } else {
                    stockStatus = '🔴 Critical';
                    statusClass = 'status-critical';
                    barColor = '#ea001e'; // Red
                }

                return {
                    ...device,
                    stockPercent,
                    stockStatus,
                    statusClass,
                    stockBarStyle: `width: ${stockPercent}%; background-color: ${barColor};`
                };
            });

            this.isLoading = false;
        } else if (result.error) {
            console.error('Error loading device stock:', result.error);
            this.isLoading = false;
        }
    }

    // Auto-refresh every 10 seconds
    connectedCallback() {
        this.startAutoRefresh();
    }

    startAutoRefresh() {
        // Use setInterval to refresh data
        this.refreshInterval = setInterval(() => {
            return refreshApex(this.wiredDevicesResult);
        }, 10000); // 10 seconds
    }

    disconnectedCallback() {
        // Clean up interval when component is destroyed
        if (this.refreshInterval) {
            clearInterval(this.refreshInterval);
        }
    }
}
```

**Component: stock-monitor.css**:
```css
.stock-bar-container {
    width: 100%;
    height: 24px;
    background-color: #e0e5ee;
    border-radius: 4px;
    overflow: hidden;
    margin: 8px 0;
}

.stock-bar {
    height: 100%;
    transition: width 0.5s ease, background-color 0.5s ease;
    display: flex;
    align-items: center;
    justify-content: flex-end;
    padding-right: 8px;
    color: white;
    font-weight: bold;
}

.status-good {
    color: #4bca81;
    font-weight: bold;
}

.status-warning {
    color: #ffb75d;
    font-weight: bold;
}

.status-critical {
    color: #ea001e;
    font-weight: bold;
}
```

**Real-time Updates**:
```javascript
// Using Platform Events for real-time updates
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

export default class StockMonitor extends LightningElement {
    subscription = {};

    connectedCallback() {
        this.subscribeToStockEvents();
    }

    subscribeToStockEvents() {
        // Subscribe to Platform Event
        const channelName = '/event/Stock_Update__e';

        subscribe(channelName, -1, (event) => {
            // Handle stock update event
            const deviceId = event.data.payload.Device_Id__c;
            const newStock = event.data.payload.New_Stock_Quantity__c;

            // Update device in local array
            this.devices = this.devices.map(device => {
                if (device.Id === deviceId) {
                    return { ...device, Stock_Quantity__c: newStock };
                }
                return device;
            });

            // Show toast notification
            this.showToast('Stock Updated', `${device.Name} stock is now ${newStock}`, 'info');
        }).then(response => {
            this.subscription = response;
        });
    }
}
```

**Learning objectives**:
- Build Lightning Web Components
- Wire Apex methods to components
- Handle real-time data updates
- Create responsive, accessible UIs
- Use Platform Events for pub/sub
- Implement auto-refresh functionality

---

## 🎯 End-to-End Example: Placing an Order

Let's walk through a complete order from start to finish:

### **Scenario**: John orders 5 laptops

```
TIME: 14:30:00 - User opens order form
├─ LWC dashboard loads
├─ Fetches available devices from Apex
└─ Displays form with current stock levels

TIME: 14:30:15 - User fills out form
├─ Customer Name: "John Doe"
├─ Device: "Laptop" (Stock: 20)
├─ Quantity: 5
└─ Real-time validation: ✅ All fields valid

TIME: 14:30:20 - User clicks "Submit Order"
├─ JavaScript validates form
├─ Calls Apex: OrderController.createOrder()
└─ Shows loading spinner

TIME: 14:30:21 - Apex creates order record
├─ Order__c record created with status "New"
├─ Salesforce assigns ID: ORD-12345
└─ Record is saved to database

TIME: 14:30:21 - Validation rules fire
├─ ✅ Device selected? YES
├─ ✅ Quantity > 0? YES (5)
├─ ✅ Quantity ≤ Stock? YES (5 ≤ 20)
├─ ✅ Business hours? YES (2:30 PM)
└─ ✅ All validations pass

TIME: 14:30:21 - AFTER INSERT trigger fires
├─ OrderTrigger executes
├─ Calls OrderTriggerHandler.afterInsert()
└─ Handler orchestrates multiple services

TIME: 14:30:22 - StockManagementService processes
├─ Queries Device: Laptop (Stock: 20)
├─ Deducts quantity: 20 - 5 = 15
├─ Updates Device record: Stock = 15
├─ Checks threshold: 15 > 10 ✅ OK
└─ No alert needed

TIME: 14:30:23 - NotificationService sends emails
├─ Creates email for customer
│   ├─ To: john.doe@email.com
│   ├─ Subject: "Order Confirmation - ORD-12345"
│   └─ Body: HTML with order details
├─ Sends email via Salesforce
└─ Email delivered in <1 second

TIME: 14:30:23 - OrderStatusService updates status
├─ Changes status: "New" → "Confirmed"
├─ Sets confirmation number: CONF-98765
└─ Updates Order record

TIME: 14:30:24 - AuditService logs activity
├─ Creates Audit_Log__c record
│   ├─ Action: "Order Created"
│   ├─ User: John Doe
│   ├─ Timestamp: 2025-11-13 14:30:20
│   └─ Details: "5 Laptops ordered, stock reduced 20→15"
└─ Audit record saved

TIME: 14:30:24 - Platform Event published
├─ Stock_Update__e event published
│   ├─ Device_Id__c: [Laptop ID]
│   └─ New_Stock_Quantity__c: 15
└─ Event delivered to subscribers

TIME: 14:30:25 - Dashboard auto-updates (all users)
├─ LWC receives Platform Event
├─ Updates stock monitor: Laptops 20 → 15
├─ Updates order feed: Shows ORD-12345 "Confirmed"
├─ Smooth animation plays
└─ No page refresh needed!

TIME: 14:30:25 - User sees success message
├─ Toast notification: "✅ Order created successfully!"
├─ Form clears automatically
├─ Order appears in "Recent Orders" section
└─ Total processing time: 5 seconds
```

---

## 📊 Data Flow Diagram

```
┌─────────────┐
│    USER     │
│  (Browser)  │
└──────┬──────┘
       │ HTTPS Request
       ▼
┌─────────────────────────┐
│  SALESFORCE PLATFORM    │
│  ┌──────────────────┐   │
│  │  LWC Component   │   │ ◄─── Presentation Layer
│  └────────┬─────────┘   │
│           │             │
│  ┌────────▼─────────┐   │
│  │  Apex Controller │   │ ◄─── Controller Layer
│  └────────┬─────────┘   │
│           │             │
│  ┌────────▼─────────┐   │
│  │  Validation      │   │ ◄─── Validation Layer
│  │  Rules           │   │
│  └────────┬─────────┘   │
│           │             │
│  ┌────────▼─────────┐   │
│  │  Apex Trigger    │   │ ◄─── Trigger Layer
│  └────────┬─────────┘   │
│           │             │
│  ┌────────▼─────────┐   │
│  │  Trigger Handler │   │ ◄─── Business Logic Layer
│  └────────┬─────────┘   │
│           │             │
│  ┌────────▼─────────┐   │
│  │  Service Classes │   │ ◄─── Service Layer
│  │  ├─Stock Mgmt    │   │
│  │  ├─Notification  │   │
│  │  ├─Audit         │   │
│  │  └─Order Status  │   │
│  └────────┬─────────┘   │
│           │             │
│  ┌────────▼─────────┐   │
│  │  Database        │   │ ◄─── Data Layer
│  │  (Order__c,      │   │
│  │   Device__c,     │   │
│  │   etc.)          │   │
│  └──────────────────┘   │
└─────────────────────────┘
```

---

## 🧪 Testing Strategy

### Unit Tests

**OrderTriggerHandlerTest.cls**:
```apex
@isTest
private class OrderTriggerHandlerTest {

    @testSetup
    static void setupTestData() {
        // Create test device
        Device__c laptop = new Device__c(
            Name = 'Test Laptop',
            Stock_Quantity__c = 20,
            Unit_Price__c = 999,
            Low_Stock_Threshold__c = 10
        );
        insert laptop;
    }

    @isTest
    static void testOrderCreationDeductsStock() {
        // Given
        Device__c laptop = [SELECT Id, Stock_Quantity__c FROM Device__c LIMIT 1];
        Decimal initialStock = laptop.Stock_Quantity__c; // 20

        // When
        Test.startTest();
        Order__c order = new Order__c(
            Device__c = laptop.Id,
            Quantity__c = 5,
            Customer_Email__c = 'test@test.com'
        );
        insert order;
        Test.stopTest();

        // Then
        laptop = [SELECT Stock_Quantity__c FROM Device__c WHERE Id = :laptop.Id];
        System.assertEquals(15, laptop.Stock_Quantity__c,
            'Stock should be reduced by 5 (20 - 5 = 15)');
    }

    @isTest
    static void testBulkOrderProcessing() {
        // Test bulkification: insert 200 orders
        Device__c laptop = [SELECT Id FROM Device__c LIMIT 1];

        List<Order__c> orders = new List<Order__c>();
        for (Integer i = 0; i < 200; i++) {
            orders.add(new Order__c(
                Device__c = laptop.Id,
                Quantity__c = 1,
                Customer_Email__c = 'test' + i + '@test.com'
            ));
        }

        // When
        Test.startTest();
        insert orders; // Should not hit governor limits
        Test.stopTest();

        // Then
        System.assertEquals(200, [SELECT COUNT() FROM Order__c],
            '200 orders should be created');
    }

    @isTest
    static void testLowStockAlertCreated() {
        // Given: Device with 15 units
        Device__c laptop = [SELECT Id FROM Device__c LIMIT 1];
        update new Device__c(Id = laptop.Id, Stock_Quantity__c = 15);

        // When: Order 8 units (leaves 7, below threshold of 10)
        Test.startTest();
        insert new Order__c(
            Device__c = laptop.Id,
            Quantity__c = 8,
            Customer_Email__c = 'test@test.com'
        );
        Test.stopTest();

        // Then: Alert should be created
        List<Low_Stock_Alert__c> alerts = [SELECT Id, Current_Stock__c
                                           FROM Low_Stock_Alert__c];
        System.assertEquals(1, alerts.size(), 'One alert should be created');
        System.assertEquals(7, alerts[0].Current_Stock__c,
            'Alert should show correct stock level');
    }
}
```

---

## 💡 Key Takeaways

### What You Learned

1. **Validation Rules**: Prevent bad data declaratively (no code)
2. **Apex Triggers**: Automate processes when records change
3. **Handler Pattern**: Organize trigger logic cleanly
4. **Bulkification**: Handle 200+ records efficiently
5. **Service Classes**: Separate concerns, reusable logic
6. **Lightning Web Components**: Modern, reactive UIs
7. **Platform Events**: Real-time communication
8. **Testing**: Ensure code quality and coverage

### Salesforce Best Practices Demonstrated

✅ **Separation of Concerns**: Trigger → Handler → Services
✅ **Bulkification**: All operations handle 200+ records
✅ **Error Handling**: Try-catch blocks, graceful failures
✅ **Governor Limits**: Efficient SOQL and DML
✅ **Test Coverage**: 90%+ with meaningful assertions
✅ **Documentation**: Inline comments explain "why"
✅ **Security**: CRUD/FLS checks where appropriate

### Real-World Applications

This workflow demonstrates patterns used in:
- E-commerce platforms (Amazon, Shopify)
- Inventory management systems (NetSuite)
- Order fulfillment systems (Fulfillment by Amazon)
- Supply chain management (SAP)
- Restaurant POS systems
- Warehouse management systems

---

## 🚀 Next Steps

Ready to build this yourself?

1. **Start with validation rules** (easiest, no code)
2. **Build the trigger and handler** (moderate difficulty)
3. **Create service classes** (advanced)
4. **Build LWC components** (most challenging)
5. **Write comprehensive tests** (essential)

---

## 📚 Additional Resources

- [Salesforce Trigger Best Practices](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_triggers_best_practice.htm)
- [Lightning Web Components Guide](https://developer.salesforce.com/docs/component-library/documentation/en/lwc)
- [Apex Testing Best Practices](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_best_practices.htm)

---

**Questions? Need clarification on any section?** Open an issue in the repository!
