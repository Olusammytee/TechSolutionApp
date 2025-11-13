# 🚀 Advanced Data Management in TechSolutionApp

## How Async Processing Fits Into Your Device & Order Management System

---

## 📦 Your TechSolutionApp Overview

**What you have:**
- **Device__c** - Inventory of devices (laptops, phones, tablets)
- **Order__c** - Customer orders with line items
- **Order_Line_Item__c** - Individual items in orders
- **Customer__c** - Customer records
- **Supplier__c** - Supplier information

**The Challenge:** As your business grows, you need to:
- Process thousands of orders without timing out ⏰
- Run nightly maintenance jobs automatically 🌙
- Send notifications without slowing down the user 📧
- Make API calls to external systems 🌐

**The Solution:** Async Processing (Batch, Scheduled, Queueable, Future)

---

## 🎯 Real Examples from YOUR Project

### 1. **Batch Apex** - OrderCleanupBatch.cls

**Located at:** `force-app/main/default/classes/OrderCleanupBatch.cls`

#### What It Does in Your App:
```
SCENARIO: You have 50,000 completed orders from the past 5 years
PROBLEM: Can't delete them all at once (governor limits!)
SOLUTION: Batch Apex processes them 200 at a time
```

#### Visual Flow:
```
┌─────────────────────────────────────────────┐
│  50,000 Old Orders to Delete                │
│  (Status = Completed or Cancelled)          │
└─────────────────────────────────────────────┘
                    ↓
        ┌───────────────────────┐
        │   Split into Batches  │
        └───────────────────────┘
                    ↓
┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐
│ Batch 1 │  │ Batch 2 │  │ Batch 3 │  │ Batch N │
│ 200 rec │  │ 200 rec │  │ 200 rec │  │ 200 rec │
└─────────┘  └─────────┘  └─────────┘  └─────────┘
     ↓            ↓            ↓            ↓
  Archive     Archive     Archive      Archive
     ↓            ↓            ↓            ↓
  Delete      Delete      Delete       Delete
```

#### How to Use It in Your App:
```apex
// Execute from Anonymous Apex or Developer Console

// Option 1: Delete orders older than 1 year (no archiving)
OrderCleanupBatch cleanup = new OrderCleanupBatch(365, false);
Id batchId = Database.executeBatch(cleanup, 200);

// Option 2: Delete orders older than 2 years (with archiving)
OrderCleanupBatch cleanup = new OrderCleanupBatch(730, true);
Id batchId = Database.executeBatch(cleanup, 200);

// Check batch status
AsyncApexJob job = [SELECT Status, TotalJobItems, JobItemsProcessed
                     FROM AsyncApexJob WHERE Id = :batchId];
```

#### Real-World Scenario:
```
Your business has been running for 5 years
├── Year 1-4: 40,000 completed orders (old, archived)
└── Year 5: 10,000 active orders

ACTION: Run OrderCleanupBatch quarterly to:
1. Archive old orders to external storage
2. Delete them from Salesforce to save storage
3. Keep org performance optimal
4. Send admin an email summary when done
```

---

### 2. **Scheduled Apex** - DailyOrderSummarySchedulable.cls

**Located at:** `force-app/main/default/classes/DailyOrderSummarySchedulable.cls`

#### What It Does in Your App:
```
SCENARIO: Management wants daily sales reports every morning
PROBLEM: Can't manually run reports every day!
SOLUTION: Scheduled Apex runs automatically at specific times
```

#### Visual Timeline:
```
Monday 6:00 AM    → Generate order summary, email to admins
Tuesday 6:00 AM   → Generate order summary, email to admins
Wednesday 6:00 AM → Generate order summary, email to admins
(Repeats forever, automatically!)
```

#### What Gets Generated:
```
📊 DAILY ORDER SUMMARY REPORT
================================
Period: 2025-11-12 to 2025-11-13

OVERALL STATISTICS
------------------
Total Orders: 127
Total Revenue: $54,320.50
Average Order Value: $427.72

ORDERS BY STATUS
----------------
Confirmed: 82 orders ($35,240.00)
Pending: 30 orders ($12,450.50)
Shipped: 15 orders ($6,630.00)

TOP 10 CUSTOMERS
----------------
1. Acme Corp: 15 orders ($8,450.00)
2. Tech Innovations: 12 orders ($6,200.00)
...
```

#### How to Schedule It:
```apex
// Execute from Anonymous Apex

// Option 1: Daily at midnight
Id jobId = DailyOrderSummarySchedulable.scheduleDailyAtMidnight();
// Cron: '0 0 0 * * ?'

// Option 2: Weekly on Monday at 8 AM
Id jobId = DailyOrderSummarySchedulable.scheduleWeeklyMonday();
// Cron: '0 0 8 ? * MON'

// Option 3: Every hour
Id jobId = DailyOrderSummarySchedulable.scheduleHourly();
// Cron: '0 0 * * * ?'

// Check scheduled jobs in Setup → Scheduled Jobs
```

#### Real-World Scenario:
```
Your Sales Manager Sarah logs in every morning
├── 8:00 AM: Checks email
├── 8:01 AM: Sees "Daily Order Summary" email
├── 8:05 AM: Reviews yesterday's performance
└── 8:10 AM: Makes business decisions based on data

BONUS: The scheduled job also triggers OrderCleanupBatch
       nightly to keep the org clean!
```

---

### 3. **Queueable Apex** - OrderNotificationQueueable.cls

**Located at:** `force-app/main/default/classes/OrderNotificationQueueable.cls`

#### What It Does in Your App:
```
SCENARIO: Customer places an order, needs confirmation
PROBLEM: Sending emails/SMS immediately slows down the UI
SOLUTION: Queue the notification to run in the background
```

#### Visual Flow:
```
User places order → Order saved ✅ (instant, user sees success)
                         ↓
            [Background Queue Job Starts]
                         ↓
            ┌────────────────────────┐
            │  Job 1: Email Customer │
            └────────────────────────┘
                         ↓
            ┌────────────────────────┐
            │  Job 2: Send SMS       │
            └────────────────────────┘
                         ↓
            ┌────────────────────────┐
            │  Job 3: Webhook to ERP │
            └────────────────────────┘
```

#### Notification Types Supported:
```apex
// 1. EMAIL NOTIFICATION
OrderNotificationQueueable emailJob =
    new OrderNotificationQueueable(orderIds, 'Email');
System.enqueueJob(emailJob);
// → Sends order confirmation email to customer

// 2. SMS NOTIFICATION
OrderNotificationQueueable smsJob =
    new OrderNotificationQueueable(orderIds, 'SMS');
System.enqueueJob(smsJob);
// → Sends text message: "Order #12345 confirmed!"

// 3. PUSH NOTIFICATION
OrderNotificationQueueable pushJob =
    new OrderNotificationQueueable(orderIds, 'Push');
System.enqueueJob(pushJob);
// → Sends mobile app push notification

// 4. WEBHOOK TO EXTERNAL SYSTEM
OrderNotificationQueueable webhookJob =
    new OrderNotificationQueueable(orderIds, 'Webhook');
System.enqueueJob(webhookJob);
// → Notifies your ERP/warehouse system
```

#### Real-World Scenario:
```
Customer Bob places a large order for 50 MacBook Pros
├── 10:00:00 AM: Order saved to Salesforce ✅
├── 10:00:01 AM: Queue email notification (background)
├── 10:00:02 AM: Queue SMS notification (background)
├── 10:00:03 AM: Queue webhook to warehouse (background)
└── 10:00:05 AM: Bob sees "Order Placed Successfully!" immediately

BACKGROUND PROCESSING (Bob doesn't wait for this):
├── 10:00:10 AM: Email sent ✉️
├── 10:00:15 AM: SMS sent 📱
└── 10:00:20 AM: Warehouse notified 🏭

CHAINING: If you have 1,000 orders to notify:
Job 1: Process orders 1-200
   └─→ Job 2: Process orders 201-400
         └─→ Job 3: Process orders 401-600
               └─→ ... (continues)
```

---

### 4. **Future Methods** - (Used in OrderService.cls)

**Located at:** `force-app/main/default/classes/OrderService.cls` (can be added)

#### What It Does in Your App:
```
SCENARIO: Need to call external payment API when order is created
PROBLEM: Can't make API callouts from triggers directly
SOLUTION: Use @future method to call API in background
```

#### How to Add It to Your OrderService:
```apex
public class OrderService {

    // Existing code...

    /**
     * Process payment via external API (Future method example)
     * @param orderId The order to process payment for
     */
    @future(callout=true)
    public static void processPaymentAsync(Id orderId) {
        // STEP 1: Query order details
        Order__c order = [SELECT Id, Name, Total_Amount__c, Customer__c
                          FROM Order__c WHERE Id = :orderId LIMIT 1];

        // STEP 2: Call payment API
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Payment_Gateway/charge');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        Map<String, Object> payload = new Map<String, Object>{
            'orderId' => order.Name,
            'amount' => order.Total_Amount__c,
            'currency' => 'USD'
        };
        req.setBody(JSON.serialize(payload));

        // STEP 3: Send request
        Http http = new Http();
        HttpResponse res = http.send(req);

        // STEP 4: Update order status based on response
        if (res.getStatusCode() == 200) {
            order.Order_Status__c = 'Payment Confirmed';
            update order;
        }
    }

    /**
     * Send confirmation email (Future method example)
     * @param orderIds List of order IDs to send emails for
     */
    @future
    public static void sendConfirmationEmailsAsync(List<Id> orderIds) {
        List<Order__c> orders = [SELECT Id, Name, Customer__r.Email__c
                                 FROM Order__c WHERE Id IN :orderIds];

        for (Order__c order : orders) {
            // Send email logic
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[]{order.Customer__r.Email__c});
            email.setSubject('Order Confirmation - ' + order.Name);
            email.setPlainTextBody('Your order has been confirmed!');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        }
    }
}
```

#### How to Call It:
```apex
// From a trigger or another class
OrderService.processPaymentAsync(orderId);
OrderService.sendConfirmationEmailsAsync(orderIds);
```

#### Real-World Scenario:
```
Customer completes checkout
├── Order record created
├── Trigger fires
└── @future method called (background)
       ├── Call Stripe/PayPal API
       ├── Process payment
       └── Update order status
```

---

## 🎯 Decision Tree: Which Method to Use?

```
START: I need to process data...

│
├─ Do I have 10,000+ records?
│  └─ YES → Use BATCH APEX ✅
│           (OrderCleanupBatch.cls)
│
├─ Does it need to run at specific times?
│  └─ YES → Use SCHEDULED APEX ✅
│           (DailyOrderSummarySchedulable.cls)
│
├─ Do I need to chain jobs or make callouts?
│  └─ YES → Use QUEUEABLE APEX ✅
│           (OrderNotificationQueueable.cls)
│
└─ Is it a simple one-time background task?
   └─ YES → Use @FUTURE METHOD ✅
            (OrderService.processPaymentAsync)
```

---

## 📋 Complete Use Case Examples in TechSolutionApp

### Use Case 1: End-of-Day Processing (Scheduled → Batch)
```
8:00 PM Every Day (Scheduled Job runs)
├── DailyOrderSummarySchedulable executes
├── Generates report, emails admins
└── Triggers OrderCleanupBatch
    └── Deletes old orders (365+ days)
```

### Use Case 2: Order Confirmation Flow (Queueable → Future)
```
Customer places order
├── Order saved
├── OrderNotificationQueueable (email)
└── OrderService.processPaymentAsync (API call)
    └── Payment confirmed
```

### Use Case 3: Bulk Data Import (Batch → Queueable)
```
Import 50,000 orders from legacy system
├── OrderImportBatch processes 200 at a time
└── For each batch:
    └── OrderNotificationQueueable sends welcome emails
```

---

## 🛠️ How to Test These in Your Org

### 1. Test Batch Apex
```apex
// Anonymous Apex
OrderCleanupBatch batch = new OrderCleanupBatch(365, false);
Id batchId = Database.executeBatch(batch, 200);

// Monitor progress
AsyncApexJob job = [SELECT Status, JobItemsProcessed, TotalJobItems
                     FROM AsyncApexJob WHERE Id = :batchId];
System.debug('Status: ' + job.Status);
System.debug('Progress: ' + job.JobItemsProcessed + '/' + job.TotalJobItems);
```

### 2. Test Scheduled Apex
```apex
// Anonymous Apex
Id jobId = DailyOrderSummarySchedulable.scheduleDailyAtMidnight();
System.debug('Scheduled Job ID: ' + jobId);

// View scheduled jobs
// Setup → Scheduled Jobs
```

### 3. Test Queueable Apex
```apex
// Anonymous Apex
List<Id> orderIds = new List<Id>{
    '001XXXXXXXXXX',  // Replace with real order IDs
    '001YYYYYYYYYY'
};

OrderNotificationQueueable job =
    new OrderNotificationQueueable(orderIds, 'Email');

Id jobId = System.enqueueJob(job);
System.debug('Queued Job ID: ' + jobId);
```

### 4. Test Future Methods
```apex
// Anonymous Apex
OrderService.processPaymentAsync('001XXXXXXXXXX');
```

---

## 📚 Key Takeaways for TechSolutionApp

| Scenario | Use This | Your Class |
|----------|----------|------------|
| Nightly cleanup of old orders | Batch Apex | OrderCleanupBatch.cls |
| Daily sales reports | Scheduled Apex | DailyOrderSummarySchedulable.cls |
| Send order notifications | Queueable Apex | OrderNotificationQueueable.cls |
| Payment API callouts | @future | OrderService.processPaymentAsync |
| Process 50k+ orders | Batch Apex | Create OrderProcessingBatch.cls |
| Weekly inventory audit | Scheduled Apex | Create WeeklyInventorySchedulable.cls |

---

## 🚀 Next Steps

Based on the Learning Roadmap (Phase 5.3), you should:

1. **✅ Already Have:**
   - OrderCleanupBatch.cls (Batch example)
   - DailyOrderSummarySchedulable.cls (Scheduled example)
   - OrderNotificationQueueable.cls (Queueable example)

2. **🎯 To Add (from Roadmap):**
   - [ ] Future method examples in OrderService
   - [ ] Comprehensive test classes (90%+ coverage)
   - [ ] Documentation comparing when to use each approach
   - [ ] Job monitoring dashboard
   - [ ] Error handling and retry logic

3. **📖 Learning Activities:**
   - Run each example in your org
   - Modify the code to fit your specific needs
   - Create test data and observe the results
   - Read the inline comments to understand patterns

---

## 💡 Pro Tips

1. **Always Test Async Jobs:**
   ```apex
   Test.startTest();
   // Your async code here
   Test.stopTest();  // Forces async jobs to complete
   ```

2. **Monitor Job Status:**
   - Setup → Jobs → Apex Jobs (for batch/queueable)
   - Setup → Scheduled Jobs (for scheduled)

3. **Error Handling:**
   - Always use try-catch blocks
   - Log errors to Error_Log__c custom object
   - Send alerts to admins for failures

4. **Governor Limits:**
   - Batch: 50k SOQL, 10k DML per batch
   - Queueable: Same as synchronous
   - Future: Cannot call another future method

---

**🎓 You now understand how Advanced Data Management fits into YOUR TechSolutionApp!**

Next: Try running these examples in your org and modify them for your specific business needs.
