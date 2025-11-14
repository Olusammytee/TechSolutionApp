# CLAUDE.md - AI Assistant Codebase Guide

**TechSolutionApp - Salesforce Device Management & Learning Platform**

Last Updated: 2025-11-14
API Version: 60.0
Project Type: Salesforce DX

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Quick Reference](#quick-reference)
3. [Architecture & Design Patterns](#architecture--design-patterns)
4. [Codebase Structure](#codebase-structure)
5. [Development Workflows](#development-workflows)
6. [Key Conventions](#key-conventions)
7. [Common Operations](#common-operations)
8. [Testing Strategy](#testing-strategy)
9. [Deployment Practices](#deployment-practices)
10. [Integration Points](#integration-points)
11. [Troubleshooting References](#troubleshooting-references)

---

## Project Overview

### Purpose
TechSolutionApp is a **dual-purpose** Salesforce platform:
1. **Functional Application**: Enterprise-grade device inventory and order management system
2. **Educational Resource**: Comprehensive learning platform demonstrating Salesforce best practices

### Key Statistics
- **Apex Code**: ~12,000 lines (33 classes + 33 test classes)
- **LWC Components**: 10 interactive dashboards
- **Custom Objects**: 11 with complex relationships
- **Documentation**: 37 markdown files (comprehensive guides)
- **Test Coverage**: 90%+ target
- **API Version**: 60.0

### Target Users
- Salesforce developers (beginner to advanced)
- AI assistants helping with Salesforce development
- Contributors extending the platform
- Students learning enterprise Salesforce patterns

---

## Quick Reference

### Core Data Model (Simplified)

```
Customer__c (1)
    ├── Order__c (M) [Lookup]
    │   └── Order_Line_Item__c (M) [Master-Detail]
    │       └── Device__c (1) [Lookup]
    │           └── Supplier__c (1) [Lookup]
    └── Device_Order__c (M) [Lookup - Legacy, being phased out]
```

### Key Objects

| Object | Purpose | Auto-Number | Key Fields |
|--------|---------|-------------|------------|
| `Order__c` | Order management | ORD-{00000} | Order_Status__c, Total_Amount__c, Customer__c |
| `Customer__c` | Customer/Account | CUST-{00000} | Customer_Type__c, Customer_Tier__c, Credit_Limit__c |
| `Device__c` | Product catalog | DEV-{00000} | Type__c, Stock_Quantity__c, Price__c, Active__c |
| `Order_Line_Item__c` | Order details | - | Order__c, Device__c, Quantity__c, Line_Total__c |
| `Supplier__c` | Vendor management | SUP-{00000} | Supplier_Code__c, Lead_Time_Days__c |
| `Device_Order__c` | Legacy orders | DO-{00000} | ⚠️ Being migrated to Order__c |

### Key Apex Classes

| Class | Purpose | Pattern |
|-------|---------|---------|
| `OrderTriggerHandler` | Order trigger logic | Handler Pattern |
| `OrderService` | Order business logic | Service Layer |
| `OrderSelector` | Order queries | Selector Pattern |
| `OrderRESTService` | REST API endpoint | REST API (`@RestResource`) |
| `OrderDashboardController` | LWC data provider | Controller |
| `AnalyticsService` | Analytics/reporting | Service Layer (12,299 lines) |
| `ErrorLogger` | Error logging | Utility |
| `TestDataFactory` | Test data creation | Factory Pattern |
| `OrderCleanupBatch` | Order archival | Batch Apex |
| `OrderNotificationQueueable` | Async notifications | Queueable Apex |

### Key LWC Components

| Component | Purpose | Location |
|-----------|---------|----------|
| `orderDashboard` | Main order UI | `force-app/main/default/lwc/orderDashboard/` |
| `orderAnalyticsDashboard` | Analytics UI | `force-app/main/default/lwc/orderAnalyticsDashboard/` |
| `customerDashboard` | Customer view | `force-app/main/default/lwc/customerDashboard/` |
| `inventoryDashboard` | Inventory management | `force-app/main/default/lwc/inventoryDashboard/` |

### Permission Sets

| Permission Set | Purpose | Access Level |
|----------------|---------|--------------|
| `TechSolutions_Admin` | Full admin access | CRUD + Modify All + View All |
| `TechSolutions_Sales` | Sales operations | Order & Customer CRUD |
| `TechSolutions_Inventory` | Inventory mgmt | Device & Supplier CRUD |
| `TechSolutions_Executive` | Executive dashboard | Read-only analytics |
| `TechSolutions_Procurement` | Procurement ops | Supplier & purchasing |

### Global Value Sets

- `Order_Status`: Draft, Pending, Confirmed, Processing, Shipped, Delivered, Cancelled
- `Order_Priority`: Low, Normal, High, Urgent
- `Customer_Status`: Active, Inactive, Suspended, VIP
- `Device_Type`: Laptop, Desktop, Smartphone, Tablet, Wearable, Accessory
- `Supplier_Rating`: Excellent, Good, Fair, Poor, Not Rated

---

## Architecture & Design Patterns

### Layered Architecture

```
┌─────────────────────────────────────┐
│   Presentation Layer                │
│   (LWC, FlexiPages, Tabs)          │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   Controller Layer                  │
│   (Apex Controllers)                │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   Service Layer                     │
│   (Business Logic)                  │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   Selector Layer                    │
│   (SOQL Queries)                    │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   Data Layer                        │
│   (Custom Objects, Triggers)        │
└─────────────────────────────────────┘
```

### Design Patterns Implemented

#### 1. **Trigger Handler Pattern**
- **Location**: `/force-app/main/default/classes/OrderTriggerHandler.cls`
- **Purpose**: Separation of trigger logic from trigger definition
- **Implementation**:
  ```apex
  trigger OrderTrigger on Order__c (before insert, before update, after insert, after update) {
      OrderTriggerHandler.handleBeforeInsert(Trigger.new);
      OrderTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
  }
  ```

#### 2. **Selector Pattern**
- **Location**: `/force-app/main/default/classes/OrderSelector.cls`
- **Purpose**: Centralized SOQL queries with relationship handling
- **Benefits**: Reusability, bulkification, consistent query structure
- **Example**:
  ```apex
  public static List<Order__c> getOrdersWithLineItems(Set<Id> orderIds) {
      return [SELECT Id, Name, (SELECT Id, Device__c FROM Order_Line_Items__r)
              FROM Order__c WHERE Id IN :orderIds];
  }
  ```

#### 3. **Service Layer Pattern**
- **Location**: `/force-app/main/default/classes/OrderService.cls`
- **Purpose**: Business logic encapsulation
- **Responsibilities**: Validation, calculation, orchestration
- **Security**: Uses `with sharing` for FLS enforcement

#### 4. **Factory Pattern**
- **Location**: `/force-app/main/default/classes/TestDataFactory.cls`
- **Purpose**: Consistent test data creation
- **Usage**: All test classes use this for data setup

#### 5. **DTO (Data Transfer Object) Pattern**
- **Location**: `/force-app/main/default/classes/DashboardDTO.cls`
- **Purpose**: Data serialization for LWC and API responses
- **Benefits**: Decoupling, controlled data exposure

### Event-Driven Architecture

- **Platform Events**: `OrderStatusChangeEvent__e`
- **Publisher**: `OrderEventPublisher.cls`
- **Trigger**: `OrderTrigger` publishes on status change
- **Use Case**: Real-time notifications, async processing

### Async Processing Patterns

| Pattern | Class | Use Case |
|---------|-------|----------|
| Batch Apex | `OrderCleanupBatch` | Large-scale data archival |
| Queueable | `OrderNotificationQueueable` | Async callouts with chaining |
| Schedulable | `DailyOrderSummarySchedulable` | Scheduled reports |

---

## Codebase Structure

### Directory Layout

```
TechSolutionApp/
├── force-app/main/default/          # Salesforce metadata
│   ├── applications/                # Lightning Apps (1)
│   │   └── Tech_Solutions.app-meta.xml
│   ├── classes/                     # Apex Classes (66 files)
│   │   ├── OrderService.cls
│   │   ├── OrderService.cls-meta.xml
│   │   ├── OrderServiceTest.cls
│   │   └── ...
│   ├── lwc/                         # Lightning Web Components (10)
│   │   ├── orderDashboard/
│   │   │   ├── orderDashboard.js
│   │   │   ├── orderDashboard.html
│   │   │   ├── orderDashboard.css
│   │   │   └── orderDashboard.js-meta.xml
│   │   └── ...
│   ├── objects/                     # Custom Objects (11)
│   │   ├── Order__c/
│   │   │   ├── Order__c.object-meta.xml
│   │   │   ├── fields/              # Field definitions
│   │   │   ├── listViews/           # List view definitions
│   │   │   ├── validationRules/     # Validation rules
│   │   │   └── compactLayouts/      # Compact layouts
│   │   └── ...
│   ├── triggers/                    # Apex Triggers (2)
│   │   ├── OrderTrigger.trigger
│   │   └── OrderTrigger.trigger-meta.xml
│   ├── flows/                       # Record-Triggered Flows (2)
│   ├── tabs/                        # Custom Tabs (6)
│   ├── permissionsets/              # Permission Sets (5)
│   ├── layouts/                     # Page Layouts (6)
│   ├── flexipages/                  # Lightning Pages (3)
│   └── globalValueSets/             # Global Picklists (5)
│
├── scripts/                         # Automation scripts
│   ├── apex/                        # Apex scripts (32 files)
│   │   ├── data-seed.apex           # Main data seeding
│   │   ├── comprehensive-data-population.apex
│   │   └── ...
│   └── data/                        # JSON data templates
│
├── config/                          # Org configuration
│   └── project-scratch-def.json     # Scratch org definition
│
├── docs/                            # Technical design docs
│   ├── PHASE_2_ORDER_ARCHITECTURE_DESIGN.md
│   └── ...
│
├── .github/workflows/               # CI/CD automation
│   └── bootstrap.yml
│
├── sfdx-project.json                # SFDX project config
├── .forceignore                     # Deployment exclusions
├── README.md                        # Main setup guide
├── CLAUDE.md                        # This file
└── [35+ documentation files]        # Comprehensive docs
```

### Metadata Organization

#### Objects Directory Structure
Each custom object follows this pattern:

```
objects/Order__c/
├── Order__c.object-meta.xml         # Object definition
├── fields/
│   ├── Order_Status__c.field-meta.xml
│   ├── Total_Amount__c.field-meta.xml
│   └── ...
├── listViews/
│   ├── All_Orders.listView-meta.xml
│   └── ...
├── validationRules/
│   ├── Valid_Order_Discount.validationRule-meta.xml
│   └── ...
├── compactLayouts/
│   └── Order_Compact_Layout.compactLayout-meta.xml
└── recordTypes/                     # If applicable
```

### Key Files

| File | Purpose | Notes |
|------|---------|-------|
| `sfdx-project.json` | Project configuration | Package name: "tech-solutions", API 60.0 |
| `.forceignore` | Deployment exclusions | Excludes logs, temp files, configs |
| `config/project-scratch-def.json` | Scratch org definition | Developer edition, Lightning enabled |
| `.github/workflows/bootstrap.yml` | CI/CD pipeline | Automated deployment |

---

## Development Workflows

### Adding a New Feature

Follow this workflow when adding new features:

#### 1. **Understand Requirements**
- Review related documentation in `/docs/` or root markdown files
- Identify affected objects and relationships
- Check existing patterns in similar features

#### 2. **Create Metadata** (if needed)

**New Custom Object:**
```bash
sf sobject create --label "Invoice" --plural "Invoices" --api-name Invoice__c
```

**New Field:**
- Navigate to `force-app/main/default/objects/{ObjectName}/fields/`
- Create XML file or use VS Code Salesforce extensions

**New Apex Class:**
```bash
sf apex class create --name InvoiceService --output-dir force-app/main/default/classes/
```

#### 3. **Follow Architecture Patterns**

**For Business Logic:**
1. Create service class (e.g., `InvoiceService.cls`)
2. Add corresponding test class (e.g., `InvoiceServiceTest.cls`)
3. Use selector pattern for queries (e.g., `InvoiceSelector.cls`)
4. If trigger needed, create handler class (e.g., `InvoiceTriggerHandler.cls`)

**For UI:**
1. Create LWC component in `lwc/` directory
2. Create controller class for data fetching
3. Follow existing component patterns (see `orderDashboard`)

#### 4. **Implement Tests**
- Use `TestDataFactory` for test data
- Achieve 90%+ code coverage
- Test bulk scenarios (200+ records)
- Include negative test cases

#### 5. **Documentation**
- Add inline comments (educational style)
- Update relevant markdown files if adding major features
- Follow existing documentation patterns

#### 6. **Validation**
- Run local tests: `sf apex test run --test-level RunLocalTests --wait 10`
- Validate deployment: `sf project deploy validate --target-org GTP5org`
- Check logs for errors

### Modifying Existing Features

#### 1. **Locate Components**
Use this guide to find what you need to modify:

| Change Type | Location | Example |
|-------------|----------|---------|
| Field modification | `objects/{Object}/fields/` | Add picklist value to `Order_Status__c` |
| Business logic | `classes/{ServiceName}.cls` | Modify order calculation in `OrderService.cls` |
| Trigger logic | `classes/{TriggerHandler}.cls` | Add validation in `OrderTriggerHandler.cls` |
| UI changes | `lwc/{componentName}/` | Modify dashboard in `orderDashboard` |
| Query optimization | `classes/{Selector}.cls` | Update query in `OrderSelector.cls` |
| Permission changes | `permissionsets/` | Modify `TechSolutions_Admin.permissionset-meta.xml` |

#### 2. **Read Before Modifying**
- Always read the file completely before making changes
- Review related test classes to understand test coverage
- Check for dependencies (e.g., other classes calling this method)

#### 3. **Maintain Patterns**
- Keep existing architecture patterns intact
- Follow naming conventions (see [Key Conventions](#key-conventions))
- Preserve bulkification in triggers and classes
- Maintain error handling patterns

#### 4. **Update Tests**
- Modify corresponding test class
- Ensure coverage remains above 90%
- Run tests after changes

### Data Migration Workflow

When migrating data (e.g., Device_Order__c → Order__c):

1. **Create Migration Script**
   - Location: `scripts/apex/migrate-{source}-to-{target}.apex`
   - Example: `migrate-device-orders-to-new-model.apex`

2. **Test in Sandbox**
   - Create small dataset
   - Validate mapping
   - Check relationships

3. **Backup Data**
   - Export existing records
   - Document current state

4. **Execute Migration**
   - Run script: `sf apex run --file scripts/apex/{migration-script}.apex --target-org GTP5org`
   - Monitor logs

5. **Validate Results**
   - Run validation script
   - Verify record counts
   - Check related records

---

## Key Conventions

### Naming Conventions

#### Salesforce Metadata

| Type | Convention | Example |
|------|------------|---------|
| Custom Object | `{Name}__c` | `Order__c` |
| Custom Field | `{Name}__c` | `Order_Status__c` |
| Lookup/Master-Detail | `{ObjectName}__c` | `Customer__c` |
| Formula Field | Descriptive name | `Total_Amount__c` |
| Rollup Summary | Descriptive with summary | `Line_Item_Count__c` |
| Custom Tab | Match object name | `Order__c` |
| Permission Set | `TechSolutions_{Role}` | `TechSolutions_Admin` |
| Global Value Set | Descriptive | `Order_Status` |
| Platform Event | `{Name}Event__e` | `OrderStatusChangeEvent__e` |

#### Apex Code

| Type | Convention | Example |
|------|------------|---------|
| Class | PascalCase | `OrderService` |
| Method | camelCase | `calculateOrderTotal` |
| Variable | camelCase | `orderList`, `totalAmount` |
| Constant | UPPER_CASE | `DEFAULT_TAX_RATE` |
| Test Class | `{ClassName}Test` | `OrderServiceTest` |
| Trigger | `{ObjectName}Trigger` | `OrderTrigger` |
| Trigger Handler | `{ObjectName}TriggerHandler` | `OrderTriggerHandler` |
| Selector | `{ObjectName}Selector` | `OrderSelector` |
| Controller | `{ComponentName}Controller` | `OrderDashboardController` |

#### LWC Components

| Type | Convention | Example |
|------|------------|---------|
| Component Folder | camelCase | `orderDashboard/` |
| JS File | Matches folder | `orderDashboard.js` |
| HTML File | Matches folder | `orderDashboard.html` |
| CSS File | Matches folder | `orderDashboard.css` |
| Method | camelCase | `handleOrderCreate` |
| Property | camelCase with @api/@track | `@track filteredOrders` |

### Code Structure Conventions

#### Apex Class Structure

```apex
/**
 * @description Service class for Order management
 * @author [Name]
 * @date [Date]
 * @group Services
 * @see OrderTriggerHandler, OrderSelector
 */
public with sharing class OrderService {

    // Constants
    private static final Decimal DEFAULT_TAX_RATE = 0.08;

    // Public methods
    public static void calculateOrderTotals(List<Order__c> orders) {
        // Implementation
    }

    // Private helper methods
    private static Decimal calculateTax(Decimal amount) {
        // Implementation
    }
}
```

#### Test Class Structure

```apex
@isTest
private class OrderServiceTest {

    @TestSetup
    static void setupTestData() {
        // Use TestDataFactory
    }

    @isTest
    static void testCalculateOrderTotals_Success() {
        // Test positive scenario
    }

    @isTest
    static void testCalculateOrderTotals_NegativeAmount() {
        // Test negative scenario
    }

    @isTest
    static void testCalculateOrderTotals_BulkRecords() {
        // Test bulk scenario (200+ records)
    }
}
```

#### LWC Component Structure

```javascript
import { LightningElement, wire, track } from 'lwc';
import getOrders from '@salesforce/apex/OrderDashboardController.getOrders';

export default class OrderDashboard extends LightningElement {
    // Properties
    @track orders = [];
    @track error;

    // Wire methods
    @wire(getOrders)
    wiredOrders({ error, data }) {
        // Handle wire response
    }

    // Event handlers
    handleRefresh() {
        // Handle refresh
    }

    // Helper methods
    processOrderData(data) {
        // Process data
    }
}
```

### Comment Conventions

This codebase uses **educational comments** that explain the "why" not just the "what":

```apex
/**
 * Calculate order totals including tax and discounts
 *
 * Learning Note: This method demonstrates proper bulkification by processing
 * all orders in a single pass. We avoid SOQL queries inside loops and use
 * collections (Maps/Sets) for efficient lookups.
 *
 * @param orders List of orders to calculate totals for
 */
public static void calculateOrderTotals(List<Order__c> orders) {
    // Bulkify: Collect all related IDs upfront to avoid queries in loops
    Set<Id> customerIds = new Set<Id>();
    for (Order__c order : orders) {
        if (order.Customer__c != null) {
            customerIds.add(order.Customer__c);
        }
    }
    // ... continue with implementation
}
```

### File Organization Conventions

#### Multi-File Components (Objects, LWC)
- Keep related files in dedicated directories
- Use consistent naming across all files
- Include meta.xml files for all metadata

#### Scripts Directory
- **Data scripts**: Prefix with `create-` or `data-`
- **Test scripts**: Prefix with `test-`
- **Diagnostic scripts**: Include `diagnostic` or `validation` in name
- **Migration scripts**: Prefix with `migrate-`

---

## Common Operations

### Deploying Metadata

#### Deploy All Metadata
```bash
sf project deploy start --target-org GTP5org
```

#### Deploy Specific Metadata
```bash
# Deploy single class
sf project deploy start --source-dir force-app/main/default/classes/OrderService.cls --target-org GTP5org

# Deploy object and all fields
sf project deploy start --source-dir force-app/main/default/objects/Order__c/ --target-org GTP5org

# Deploy specific component type
sf project deploy start --metadata CustomObject:Order__c --target-org GTP5org
```

#### Validate Deployment (Without Deploying)
```bash
sf project deploy validate --source-dir force-app/main/default/ --target-org GTP5org
```

### Running Tests

#### Run All Tests
```bash
sf apex test run --test-level RunLocalTests --wait 10 --target-org GTP5org
```

#### Run Specific Test Class
```bash
sf apex test run --class-names OrderServiceTest --wait 10 --target-org GTP5org
```

#### Run Multiple Test Classes
```bash
sf apex test run --class-names OrderServiceTest,OrderSelectorTest --wait 10 --target-org GTP5org
```

#### Get Test Results
```bash
sf apex test result --test-run-id {testRunId} --target-org GTP5org
```

### Running Apex Scripts

#### Execute Anonymous Apex
```bash
sf apex run --file scripts/apex/data-seed.apex --target-org GTP5org
```

#### Alternative Method (Developer Console)
If CLI fails:
1. `sf org open --target-org GTP5org`
2. Open Developer Console (Ctrl/Cmd + Shift + D)
3. Debug → Execute Anonymous Window
4. Paste script content
5. Execute

### Querying Data

#### Using SOQL
```bash
sf data query --query "SELECT Id, Name, Order_Status__c FROM Order__c WHERE Order_Status__c = 'Pending'" --target-org GTP5org
```

#### Export Data
```bash
sf data export tree --query "SELECT Id, Name FROM Order__c" --output-dir scripts/data/ --target-org GTP5org
```

### Managing Permission Sets

#### Assign Permission Set
```bash
sf org assign permset --name TechSolutions_Admin --target-org GTP5org
```

#### List Assigned Permission Sets
```bash
sf data query --query "SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = '{userId}'" --target-org GTP5org
```

### Creating Metadata

#### Create Apex Class
```bash
sf apex class create --name MyNewService --output-dir force-app/main/default/classes/
```

#### Create Apex Trigger
```bash
sf apex trigger create --name MyTrigger --sobject Order__c --output-dir force-app/main/default/triggers/
```

#### Create LWC Component
```bash
sf lightning component create --name myComponent --type lwc --output-dir force-app/main/default/lwc/
```

### Retrieving Metadata from Org

#### Retrieve All Metadata
```bash
sf project retrieve start --target-org GTP5org
```

#### Retrieve Specific Metadata
```bash
sf project retrieve start --metadata ApexClass:OrderService --target-org GTP5org
```

### Org Management

#### Open Org
```bash
sf org open --target-org GTP5org
```

#### Check Org Status
```bash
sf org display --target-org GTP5org
```

#### List All Orgs
```bash
sf org list
```

---

## Testing Strategy

### Test Coverage Requirements

- **Minimum Coverage**: 75% (Salesforce requirement)
- **Project Target**: 90%+ (best practice)
- **Current Status**: Maintained above 90%

### Testing Patterns

#### 1. **Use TestDataFactory**

Always use `TestDataFactory` for consistent test data:

```apex
@TestSetup
static void setupTestData() {
    // Good: Using TestDataFactory
    List<Device__c> devices = TestDataFactory.createDevices(10, true);
    List<Customer__c> customers = TestDataFactory.createCustomers(5, true);
    List<Order__c> orders = TestDataFactory.createOrders(customers, 3, true);
}

// Bad: Creating data manually
// Device__c device = new Device__c(Name = 'Test', Price__c = 100, ...);
```

#### 2. **Test Bulk Operations**

Always test with 200+ records to verify bulkification:

```apex
@isTest
static void testBulkOrderCreation() {
    // Create 200+ records
    List<Customer__c> customers = TestDataFactory.createCustomers(5, true);
    List<Order__c> orders = TestDataFactory.createOrders(customers, 50, false); // 250 orders

    Test.startTest();
    insert orders;
    Test.stopTest();

    // Verify no governor limit exceptions occurred
    System.assertEquals(250, [SELECT COUNT() FROM Order__c]);
}
```

#### 3. **Test Negative Scenarios**

Include tests for error conditions:

```apex
@isTest
static void testInvalidOrderDiscount() {
    Order__c order = TestDataFactory.createOrders(
        TestDataFactory.createCustomers(1, true), 1, false
    )[0];
    order.Order_Discount_Percentage__c = 150; // Invalid: > 100%

    Test.startTest();
    try {
        insert order;
        System.assert(false, 'Expected validation error');
    } catch (DmlException e) {
        System.assert(e.getMessage().contains('discount'));
    }
    Test.stopTest();
}
```

#### 4. **Use Test.startTest() / Test.stopTest()**

This resets governor limits for the test:

```apex
@isTest
static void testAsyncProcessing() {
    // Setup data
    List<Order__c> orders = TestDataFactory.createOrders(
        TestDataFactory.createCustomers(1, true), 10, true
    );

    Test.startTest(); // Governor limits reset here
    OrderCleanupBatch batch = new OrderCleanupBatch(30);
    Database.executeBatch(batch);
    Test.stopTest(); // Batch completes here

    // Assert results
    System.assertEquals(10, [SELECT COUNT() FROM Order__c]);
}
```

#### 5. **Test API Endpoints**

For REST API classes, test all HTTP methods:

```apex
@isTest
static void testRESTGetOrder() {
    Order__c order = TestDataFactory.createOrders(
        TestDataFactory.createCustomers(1, true), 1, true
    )[0];

    RestRequest req = new RestRequest();
    req.requestURI = '/services/apexrest/api/v1/orders/' + order.Id;
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = new RestResponse();

    Test.startTest();
    OrderRESTService.doGet();
    Test.stopTest();

    System.assertEquals(200, RestContext.response.statusCode);
}
```

### Test Class Organization

```
classes/
├── OrderService.cls
├── OrderServiceTest.cls          # Tests OrderService
├── OrderTriggerHandler.cls
├── OrderTriggerHandlerTest.cls   # Tests OrderTriggerHandler
├── OrderSelector.cls
└── OrderSelectorTest.cls         # Tests OrderSelector
```

### Running Tests Efficiently

#### During Development
```bash
# Run only the test class you're working on
sf apex test run --class-names OrderServiceTest --wait 10
```

#### Before Deployment
```bash
# Run all local tests
sf apex test run --test-level RunLocalTests --wait 10
```

#### Check Coverage
```bash
# Get code coverage for specific class
sf data query --query "SELECT ApexClassOrTrigger.Name, NumLinesCovered, NumLinesUncovered FROM ApexCodeCoverageAggregate WHERE ApexClassOrTrigger.Name = 'OrderService'"
```

---

## Deployment Practices

### Pre-Deployment Checklist

Before deploying to production:

- [ ] All tests passing locally
- [ ] Code coverage above 90%
- [ ] No hardcoded IDs or credentials
- [ ] Proper error handling implemented
- [ ] Bulkification verified (test with 200+ records)
- [ ] Documentation updated
- [ ] Validation rules tested
- [ ] Permission sets configured
- [ ] Related documentation updated

### Deployment Commands

#### 1. **Validate First**
```bash
# Validate without deploying
sf project deploy validate --target-org GTP5org
```

#### 2. **Deploy with Tests**
```bash
# Deploy and run tests
sf project deploy start --test-level RunLocalTests --wait 30 --target-org GTP5org
```

#### 3. **Quick Deploy** (after successful validation)
```bash
# Quick deploy using validation ID
sf project deploy quick --job-id {validationId} --target-org GTP5org
```

### Post-Deployment Validation

#### 1. **Verify Deployment**
```bash
# Check deployment status
sf project deploy report --job-id {deploymentId}
```

#### 2. **Run Validation Scripts**
```bash
# Execute validation script
sf apex run --file scripts/apex/final-data-validation.apex --target-org GTP5org
```

#### 3. **Assign Permission Sets**
```bash
# Assign necessary permission sets
sf org assign permset --name TechSolutions_Admin --target-org GTP5org
```

#### 4. **Seed Data** (if needed)
```bash
# Populate initial data
sf apex run --file scripts/apex/data-seed.apex --target-org GTP5org
```

### CI/CD Pipeline

This project includes GitHub Actions workflow:

**Location**: `.github/workflows/bootstrap.yml`

**Triggers**:
- Push to main branch
- Pull request to main branch

**Steps**:
1. Authenticate to org
2. Run validation
3. Run all tests
4. Deploy if validation passes
5. Report results

### Deployment Troubleshooting

#### Common Issues

**Issue**: `Element {http://soap.sforce.com/2006/04/metadata}object invalid`
**Fix**: Check CustomTab metadata structure (already fixed in this repo)
**Reference**: TROUBLESHOOTING.md

**Issue**: `FormFactors is required for Lightning apps`
**Fix**: Add `<formFactors>Large</formFactors>` to Lightning App (already fixed)
**Reference**: COMPLETE_SETUP_EXPERIENCE.md

**Issue**: Apex script execution fails
**Fix**: Use Developer Console method instead of CLI
**Reference**: TROUBLESHOOTING.md

### Rollback Strategy

If deployment fails:

1. **Quick Rollback**:
   ```bash
   # Retrieve previous version from git
   git checkout HEAD~1 -- force-app/
   sf project deploy start --target-org GTP5org
   ```

2. **Manual Rollback**:
   - Use org's deployment history
   - Revert specific components
   - Run validation scripts

---

## Integration Points

### REST API

#### Endpoint Structure
- **Base URL**: `/services/apexrest/api/v1/orders/*`
- **Authentication**: OAuth 2.0 or Session ID
- **Format**: JSON

#### Available Endpoints

| Method | Endpoint | Purpose | Request Body | Response |
|--------|----------|---------|--------------|----------|
| GET | `/api/v1/orders/{id}` | Get single order | - | Order details with line items |
| GET | `/api/v1/orders?status=Pending` | Query orders | - | List of orders |
| POST | `/api/v1/orders` | Create order | Order JSON | Created order |
| PUT | `/api/v1/orders/{id}` | Update order | Order JSON | Updated order |
| DELETE | `/api/v1/orders/{id}` | Delete order | - | Success status |

#### Example Request (cURL)
```bash
# Get order
curl -X GET \
  'https://your-instance.salesforce.com/services/apexrest/api/v1/orders/a015g000001234AAA' \
  -H 'Authorization: Bearer {access_token}' \
  -H 'Content-Type: application/json'

# Create order
curl -X POST \
  'https://your-instance.salesforce.com/services/apexrest/api/v1/orders' \
  -H 'Authorization: Bearer {access_token}' \
  -H 'Content-Type: application/json' \
  -d '{
    "customerId": "a025g000001234AAA",
    "orderDate": "2025-01-15",
    "status": "Pending",
    "lineItems": [
      {"deviceId": "a015g000005678AAA", "quantity": 2}
    ]
  }'
```

**Implementation**: `/force-app/main/default/classes/OrderRESTService.cls`
**Documentation**: REST_API_GUIDE.md (37,944 bytes)

### Platform Events

#### OrderStatusChangeEvent__e

**Publisher**: `OrderEventPublisher.cls`
**Published When**: Order status changes in `OrderTrigger`

**Event Fields**:
- `Order_Id__c`: Order record ID
- `Old_Status__c`: Previous status
- `New_Status__c`: Current status
- `Changed_By__c`: User who made the change

**Subscriber Example**:
```apex
trigger OrderStatusEventTrigger on OrderStatusChangeEvent__e (after insert) {
    for (OrderStatusChangeEvent__e event : Trigger.new) {
        // Send notification, update analytics, etc.
    }
}
```

**Use Cases**:
- Real-time notifications
- Async processing
- Event-driven workflows
- System integration

**Documentation**: PLATFORM_EVENTS_SUMMARY.md

### Callouts (External Systems)

#### Queueable Callouts

**Implementation**: `OrderNotificationQueueable.cls`

```apex
// Example: Send order notification to external system
OrderNotificationQueueable notification = new OrderNotificationQueueable(
    orderId,
    'webhook',
    'https://external-system.com/api/orders'
);
System.enqueueJob(notification);
```

**Features**:
- Async execution
- Callout support
- Job chaining
- Retry logic

### Batch Processing

#### OrderCleanupBatch

**Purpose**: Archive/delete old orders
**Schedule**: Weekly (configurable)

```apex
// Schedule batch to run weekly
String cronExpression = '0 0 2 ? * SUN'; // 2 AM every Sunday
System.schedule('Weekly Order Cleanup', cronExpression, new OrderCleanupSchedulable());
```

---

## Troubleshooting References

### Quick Reference

| Issue Type | Documentation | Location |
|------------|---------------|----------|
| Deployment errors | TROUBLESHOOTING.md | Root directory |
| Setup issues | COMPLETE_SETUP_EXPERIENCE.md | Root directory |
| API problems | REST_API_GUIDE.md | Root directory |
| Data issues | DATA_QUALITY_ISSUES_RESOLVED.md | Root directory |
| UI issues | UI_UX_ISSUES_RESOLVED.md | Root directory |
| Permission problems | SECURITY_FIX_INFORMATION_DISCLOSURE.md | Root directory |

### Common Issues & Solutions

#### 1. Deployment Fails

**Check**:
- Validation rules blocking deployment
- Missing dependencies (fields, objects)
- Test failures
- Code coverage below 75%

**Solution**:
```bash
# Validate first to see detailed errors
sf project deploy validate --target-org GTP5org
```

**Reference**: TROUBLESHOOTING.md

#### 2. Test Failures

**Common Causes**:
- Missing test data
- Governor limit exceptions (not using Test.startTest())
- SOQL queries in loops
- Incorrect assertions

**Solution**:
- Review test class structure
- Use TestDataFactory
- Check bulkification
- Review error logs

#### 3. Data Not Visible in Org

**Check**:
- Permission sets assigned
- Sharing rules
- Field-level security
- Record visibility

**Solution**:
```bash
# Assign admin permission set
sf org assign permset --name TechSolutions_Admin --target-org GTP5org

# Run diagnostic script
sf apex run --file scripts/apex/field-edit-permission-diagnostic.apex --target-org GTP5org
```

**Reference**: SECURITY_FIX_INFORMATION_DISCLOSURE.md

#### 4. LWC Not Loading Data

**Check**:
- Controller method signature
- Wire adapter configuration
- Apex sharing rules (`with sharing`)
- User permissions

**Debug**:
```javascript
// Add error handling in LWC
@wire(getOrders)
wiredOrders({ error, data }) {
    if (data) {
        this.orders = data;
        console.log('Orders loaded:', data);
    } else if (error) {
        console.error('Error loading orders:', error);
        this.error = error;
    }
}
```

#### 5. Validation Rule Blocking Save

**Check**: `validationRules/` directory for active rules

**Common Rules**:
- `Valid_Order_Discount`: Discount 0-100%
- `Valid_Tax_Rate`: Tax rate 0-100%
- `Positive_Price_Validation`: Price > 0
- `Logical_Stock_Levels`: Reorder point < minimum stock level

**Solution**: Ensure data meets validation criteria or temporarily disable rule for testing

### Logging & Debugging

#### Enable Debug Logs
```bash
# Set debug log level for user
sf apex log tail --color --target-org GTP5org
```

#### Error Logger Utility

Use `ErrorLogger` class for custom error logging:

```apex
try {
    // Your code
} catch (Exception e) {
    ErrorLogger.log(e, 'OrderService.processOrder', 'orderId: ' + orderId);
    throw e;
}
```

**Query Error Logs**:
```bash
sf data query --query "SELECT Id, Error_Message__c, Stack_Trace__c, CreatedDate FROM Error_Log__c ORDER BY CreatedDate DESC LIMIT 10" --target-org GTP5org
```

### Getting Help

1. **Documentation**: Check 37 markdown files in root directory
2. **Code Comments**: Read educational comments in classes
3. **GitHub Issues**: Search existing issues or create new one
4. **Salesforce Community**: Salesforce Stack Exchange, Developer Forums

---

## Best Practices for AI Assistants

When working with this codebase as an AI assistant:

### 1. Always Read Before Modifying
- Use `Read` tool to review files completely before making changes
- Check related test classes to understand coverage
- Review dependent classes (e.g., classes that call the method you're modifying)

### 2. Maintain Existing Patterns
- Follow the layered architecture (Trigger → Handler → Service → Selector)
- Use existing design patterns (Factory, DTO, etc.)
- Keep naming conventions consistent
- Preserve bulkification

### 3. Test Everything
- Run affected test classes after changes
- Ensure coverage remains above 90%
- Test bulk scenarios (200+ records)
- Include negative test cases

### 4. Document Changes
- Add educational comments explaining the "why"
- Update inline documentation if changing public methods
- Update relevant markdown files for major changes

### 5. Security First
- Use `with sharing` for classes handling user data
- Check FLS and CRUD permissions
- Validate user input
- Avoid SOQL injection

### 6. Use Existing Utilities
- `TestDataFactory` for test data
- `ErrorLogger` for error logging
- `OrderSelector` for queries
- Global Value Sets for picklist values

### 7. Consider Performance
- Bulkify all operations
- Avoid SOQL/DML in loops
- Use collections (Maps/Sets) for lookups
- Minimize query counts

### 8. Validate Deployments
- Run validation before deploying
- Check all tests pass
- Review deployment results
- Run post-deployment validation scripts

---

## Appendix

### Useful SOQL Queries

```sql
-- Get all orders with line items
SELECT Id, Name, Order_Status__c, Total_Amount__c,
       (SELECT Id, Device__c, Quantity__c, Line_Total__c FROM Order_Line_Items__r)
FROM Order__c
WHERE Order_Status__c = 'Pending'

-- Get low stock devices
SELECT Id, Name, Stock_Quantity__c, Minimum_Stock_Level__c
FROM Device__c
WHERE Stock_Quantity__c < Minimum_Stock_Level__c
AND Active__c = true

-- Get VIP customers with recent orders
SELECT Id, Name, Customer_Tier__c, Total_Order_Value__c,
       (SELECT Id, Order_Date__c, Total_Amount__c FROM Orders__r ORDER BY Order_Date__c DESC LIMIT 5)
FROM Customer__c
WHERE Customer_Tier__c IN ('Gold', 'Platinum')
AND Customer_Status__c = 'Active'

-- Get error logs from last 24 hours
SELECT Id, Error_Message__c, Class_Name__c, Method_Name__c, CreatedDate
FROM Error_Log__c
WHERE CreatedDate = LAST_N_DAYS:1
ORDER BY CreatedDate DESC
```

### Useful Links

- **Salesforce CLI**: https://developer.salesforce.com/tools/sfdxcli
- **LWC Dev Guide**: https://developer.salesforce.com/docs/component-library/documentation/en/lwc
- **Apex Dev Guide**: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/
- **REST API Guide**: https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/
- **Salesforce DX Guide**: https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/

### Project Statistics

- **Total Lines of Code**: ~12,000+ (Apex)
- **Test Classes**: 33
- **Test Coverage**: 90%+
- **Custom Objects**: 11
- **Custom Fields**: 100+
- **LWC Components**: 10
- **Apex Classes**: 66
- **Triggers**: 2
- **Flows**: 2
- **Permission Sets**: 5
- **Documentation Files**: 37

---

**Last Updated**: 2025-11-14
**Repository**: https://github.com/Olusammytee/TechSolutionApp
**License**: MIT

**For Questions or Issues**:
- Review comprehensive documentation in root directory
- Check TROUBLESHOOTING.md for common issues
- Create GitHub issue with detailed description

---

*This CLAUDE.md file is designed to help AI assistants understand and work effectively with the TechSolutionApp codebase. It serves as a comprehensive reference guide covering architecture, patterns, conventions, and best practices.*
