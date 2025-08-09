# Phase 2: Order Header/Line Item Architecture Design

## Executive Summary

This document outlines the comprehensive design for transitioning from the current single-object Device_Order__c model to an enterprise-grade Order__c (header) + Order_Line_Item__c (child) architecture that supports multi-line orders, proper business process separation, and advanced analytics capabilities.

## 🏗️ Current State Analysis

### Current Device_Order__c Limitations:
- **Single Line Orders Only**: Cannot handle multi-device orders efficiently
- **Mixed Abstraction Levels**: Order header and line item data combined in one object
- **Limited Taxation/Shipping**: No support for order-level taxes, shipping, or payment terms
- **Reporting Constraints**: Difficult to analyze order patterns vs. line item patterns
- **Scalability Issues**: Performance impact as order complexity grows

## 🎯 Target Architecture Design

### **Order__c (Header Object)**

#### **Core Business Purpose**:
- Represents the complete customer order transaction
- Contains order-level business information (customer, dates, totals, status)
- Supports order workflow management and customer communication
- Enables order-level analytics and reporting

#### **Field Architecture**:

**Customer Relationship & Identification**:
- `Customer__c` (Lookup to Customer__c) - Required
- `Order_Number__c` (Text, Auto-Number: ORD-{00000}) - External ID, Unique
- `Order_Date__c` (Date) - Required, Default: TODAY()
- `Order_Source__c` (Picklist: Online, Phone, Email, In-Person) - Required

**Order Status & Workflow**:
- `Order_Status__c` (Picklist: Draft, Submitted, Confirmed, Processing, Shipped, Delivered, Cancelled, Returned)
- `Order_Stage__c` (Picklist: New, In Progress, Fulfilled, Closed)
- `Priority__c` (Global Value Set: Order_Priority)
- `Rush_Order__c` (Checkbox) - For expedited processing

**Financial Information**:
- `Subtotal__c` (Currency, Rollup Summary from Line Items)
- `Tax_Rate__c` (Percent) - Default: 8.25%
- `Tax_Amount__c` (Currency, Formula: Subtotal__c * Tax_Rate__c)
- `Shipping_Cost__c` (Currency) - Default: 0
- `Order_Discount_Percentage__c` (Percent) - Order-level discount
- `Order_Discount_Amount__c` (Currency, Formula)
- `Total_Amount__c` (Currency, Formula: Subtotal + Tax + Shipping - Order Discount)

**Delivery & Logistics**:
- `Expected_Delivery_Date__c` (Date)
- `Actual_Delivery_Date__c` (Date)
- `Shipping_Address__c` (Text Area) - Can differ from customer address
- `Delivery_Instructions__c` (Text Area)
- `Tracking_Number__c` (Text) - External ID for shipping integration

**Payment & Terms**:
- `Payment_Terms__c` (Picklist: Net 30, Net 15, COD, Credit Card, Wire Transfer)
- `Payment_Status__c` (Picklist: Pending, Authorized, Paid, Refunded, Failed)
- `Payment_Method__c` (Picklist: Credit Card, Bank Transfer, Check, Cash)

**Audit & Analytics**:
- `Line_Item_Count__c` (Number, Rollup Summary)
- `Order_Notes__c` (Long Text Area)
- `Created_By_User__c` (Lookup to User) - Track order creator
- `Last_Modified_By_User__c` (Lookup to User) - Track last modifier

### **Order_Line_Item__c (Child Object)**

#### **Core Business Purpose**:
- Represents individual device/product lines within an order
- Contains item-specific pricing, quantity, and discount information
- Enables detailed order analytics and inventory impact tracking
- Supports complex pricing scenarios and product-specific terms

#### **Field Architecture**:

**Master-Detail Relationship**:
- `Order__c` (Master-Detail to Order__c) - Required, Cascade Delete

**Product Information**:
- `Device__c` (Lookup to Device__c) - Required
- `Product_Name__c` (Text, Formula: Device__r.Name) - For historical reference
- `Product_Type__c` (Text, Formula: Device__r.Type__c) - For reporting
- `Line_Number__c` (Number) - Auto-populated sequence within order

**Pricing & Quantity**:
- `Quantity__c` (Number) - Required, Min: 1
- `Unit_Price__c` (Currency) - Snapshot of Device price at order time
- `List_Price__c` (Currency, Formula: Device__r.Price__c) - Current device price
- `Line_Discount_Percentage__c` (Percent) - Line-specific discount
- `Line_Discount_Amount__c` (Currency, Formula)
- `Line_Total__c` (Currency, Formula: (Unit_Price__c * Quantity__c) - Line_Discount_Amount__c)

**Business Logic**:
- `Stock_Available__c` (Number, Formula: Device__r.Stock_Quantity__c) - Real-time stock check
- `Stock_Impact__c` (Number, Formula: Quantity__c) - For inventory planning
- `Delivery_Status__c` (Picklist: Pending, Shipped, Delivered, Backordered)
- `Special_Instructions__c` (Text Area) - Line-specific notes

**Analytics & Reporting**:
- `Profit_Margin__c` (Percent, Formula) - Line-level profitability
- `Cost_Total__c` (Currency, Formula) - For cost analysis
- `Revenue_Recognition_Date__c` (Date) - For financial reporting

## 🔄 Data Migration Strategy

### **Migration Approach**:

1. **Phase 1: Create New Objects** (Zero Downtime)
   - Deploy Order__c and Order_Line_Item__c objects
   - Maintain Device_Order__c during transition
   - Create migration mapping documentation

2. **Phase 2: Data Migration** (Scheduled Maintenance Window)
   - Create Order__c records from unique Device_Order__c combinations
   - Create Order_Line_Item__c records from Device_Order__c records
   - Preserve all relationships and historical data
   - Validate data integrity post-migration

3. **Phase 3: System Cutover** (Coordinated Deployment)
   - Update all automation to use new objects
   - Redirect UI components to new objects
   - Archive Device_Order__c (maintain for historical reference)
   - Update permission sets and security model

### **Migration Data Mapping**:

**Device_Order__c → Order__c**:
- Group by Customer__c + Order_Date__c to create order headers
- Aggregate totals and counts for rollup fields
- Preserve order-level metadata and audit information

**Device_Order__c → Order_Line_Item__c**:
- One-to-one mapping for each Device_Order__c record
- Snapshot current Device__c.Price__c as Unit_Price__c
- Preserve quantity, discount, and line-specific information

## 🔧 Enhanced Business Logic Requirements

### **Validation Rules**:

**Order__c Validation Rules**:
- Order_Date__c ≤ TODAY()
- Expected_Delivery_Date__c ≥ Order_Date__c
- Tax_Rate__c between 0% and 25%
- Order_Discount_Percentage__c between 0% and 50%
- Shipping_Cost__c ≥ 0

**Order_Line_Item__c Validation Rules**:
- Quantity__c > 0
- Unit_Price__c > 0
- Line_Discount_Percentage__c between 0% and 100%
- Delivery_Status__c logic based on Order__c.Order_Status__c

### **Automation Requirements**:

**Triggers/Flows**:
- Auto-populate Line_Number__c sequence within order
- Update Order__c.Order_Status__c based on line item delivery statuses
- Inventory impact tracking when orders are confirmed
- Customer lifetime value calculations
- Automatic tax calculation based on customer location

## 📊 Lightning Web Component Optimization

### **Apex Service Layer Design**:

**OrderService.cls**:
- `@AuraEnabled(cacheable=true) getOrderSummary(Id orderId)`
- `@AuraEnabled(cacheable=true) getOrderLineItems(Id orderId)`
- `@AuraEnabled(cacheable=true) getOrderAnalytics(Date startDate, Date endDate)`
- `@AuraEnabled createOrder(OrderWrapper orderData)`
- `@AuraEnabled updateOrderStatus(Id orderId, String newStatus)`

**Performance Optimization**:
- Selective SOQL with only required fields
- Proper LIMIT clauses for large datasets
- Cacheable methods for read-only dashboard data
- Bulk processing patterns for multi-line operations

## 🎯 Success Criteria

### **Functional Requirements**:
- ✅ Support multi-line orders with proper header/line separation
- ✅ Maintain all existing functionality during transition
- ✅ Preserve historical data integrity
- ✅ Enable advanced order analytics and reporting
- ✅ Support complex pricing scenarios (order + line discounts)

### **Technical Requirements**:
- ✅ Zero data loss during migration
- ✅ Maintain performance standards
- ✅ Follow Salesforce best practices for object relationships
- ✅ Optimize for Lightning Web Component consumption
- ✅ Enterprise-grade security and validation

### **Business Requirements**:
- ✅ Support enterprise order workflows
- ✅ Enable taxation and shipping calculations
- ✅ Support payment terms and financial tracking
- ✅ Maintain operational efficiency during transition
- ✅ Prepare foundation for advanced dashboard analytics

This architecture design provides the foundation for enterprise-level order management while maintaining backward compatibility and preparing for advanced Lightning Web Component implementations.
