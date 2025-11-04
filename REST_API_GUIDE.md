# 📡 Salesforce REST API Development Guide

## Complete Guide to Building and Using REST APIs in Salesforce

---

## 📑 Table of Contents

1. [What is a REST API?](#what-is-a-rest-api)
2. [Why REST APIs Matter in Salesforce](#why-rest-apis-matter)
3. [How REST Works](#how-rest-works)
4. [Salesforce REST API Architecture](#salesforce-rest-api-architecture)
5. [Building Your First REST Service](#building-your-first-rest-service)
6. [HTTP Methods Deep Dive](#http-methods-deep-dive)
7. [HTTP Status Codes](#http-status-codes)
8. [Authentication & Security](#authentication--security)
9. [Testing REST APIs](#testing-rest-apis)
10. [Best Practices](#best-practices)
11. [Common Patterns](#common-patterns)
12. [Troubleshooting](#troubleshooting)

---

## What is a REST API?

### Simple Explanation

**REST** = **RE**presentational **S**tate **T**ransfer

Think of a REST API like a **restaurant menu and waiter system**:

```
┌─────────────────────────────────────────────────┐
│  YOU (Client)          WAITER (API)      KITCHEN (Server) │
│                                                 │
│  "I want                 Takes your              Prepares   │
│   the burger"    ───►    order       ───►        burger    │
│                                                 │
│  Receives        ◄───    Delivers     ◄───      Burger     │
│  burger                  burger                  ready      │
└─────────────────────────────────────────────────┘
```

- **Client** (You): Sends requests
- **API** (Waiter): Handles communication
- **Server** (Kitchen): Processes and responds

### Technical Definition

REST API is an architectural style for building web services that:
- Uses standard HTTP methods (GET, POST, PUT, DELETE)
- Communicates using JSON or XML
- Is stateless (each request is independent)
- Uses URLs to identify resources

---

## Why REST APIs Matter in Salesforce

### Real-World Use Cases

1. **Mobile Apps** 📱
   ```
   Mobile App ───REST API───► Salesforce
   - Check inventory
   - Create orders
   - Update customer info
   ```

2. **External Integrations** 🔗
   ```
   E-commerce Site ───REST API───► Salesforce
   - Sync orders
   - Update product prices
   - Get customer data
   ```

3. **Microservices** ⚙️
   ```
   Service A ───► Salesforce ───► Service B
   - Decouple systems
   - Scale independently
   - Mix technologies
   ```

4. **Partner Portals** 🤝
   ```
   Partner System ───REST API───► Salesforce
   - Access allowed data
   - Submit orders
   - View reports
   ```

### Career Value

**80% of Salesforce job postings require API integration knowledge!**

Companies need developers who can:
- ✅ Expose Salesforce data to external systems
- ✅ Integrate Salesforce with third-party services
- ✅ Build mobile apps connected to Salesforce
- ✅ Design scalable, secure APIs

---

## How REST Works

### The Request-Response Cycle

```
1. CLIENT SENDS REQUEST
   ┌────────────────────────────────────┐
   │ METHOD: GET                        │
   │ URL: /api/v1/orders/12345          │
   │ HEADERS:                           │
   │   Authorization: Bearer xyz123     │
   │   Content-Type: application/json   │
   └────────────────────────────────────┘
                    │
                    ▼
2. SERVER PROCESSES REQUEST
   ┌────────────────────────────────────┐
   │ - Validates authentication         │
   │ - Checks permissions               │
   │ - Queries database                 │
   │ - Formats response                 │
   └────────────────────────────────────┘
                    │
                    ▼
3. SERVER SENDS RESPONSE
   ┌────────────────────────────────────┐
   │ STATUS: 200 OK                     │
   │ HEADERS:                           │
   │   Content-Type: application/json   │
   │ BODY:                              │
   │   {                                │
   │     "orderId": "12345",            │
   │     "status": "Pending",           │
   │     "total": 5000.00               │
   │   }                                │
   └────────────────────────────────────┘
```

### Key Components

**1. HTTP Method** (What to do)
- GET = Read
- POST = Create
- PUT = Update
- DELETE = Delete

**2. URL/Endpoint** (Where)
```
https://yourinstance.salesforce.com/services/apexrest/api/v1/orders/12345
└──────┬──────────────────┘└────────┬──────────┘└──────┬──────┘└──┬──┘
    Domain              Base Path        Resource    ID
```

**3. Headers** (Metadata)
```
Authorization: Bearer ACCESS_TOKEN  ← Who you are
Content-Type: application/json      ← Data format
Accept: application/json             ← Expected response format
```

**4. Body** (Data - for POST/PUT)
```json
{
  "customerId": "a015g000001234",
  "orderDate": "2025-11-04",
  "totalAmount": 5000.00
}
```

**5. Status Code** (Result)
```
200 = Success
201 = Created
400 = Bad Request (client error)
404 = Not Found
500 = Server Error
```

---

## Salesforce REST API Architecture

### Two Types of REST APIs in Salesforce

#### 1. Standard REST API (Built-in)
Salesforce provides this out-of-the-box:

```
GET https://yourinstance.salesforce.com/services/data/v59.0/sobjects/Account/001...
```

**Use when:**
- Simple CRUD operations
- Standard objects
- No custom business logic

#### 2. Custom REST API (What we built!)
You create this with Apex:

```apex
@RestResource(urlMapping='/api/v1/orders/*')
global class OrderRESTService {
    @HttpGet
    global static OrderResponse getOrders() { ... }
}
```

**Use when:**
- Custom business logic needed
- Complex data transformations
- Multiple objects in one call
- Custom validation rules
- Better performance (fewer round trips)

### Our OrderRESTService Architecture

```
┌─────────────────────────────────────────────────────────┐
│  EXTERNAL SYSTEM (Client)                               │
│  - Mobile App                                           │
│  - Web Portal                                           │
│  - Integration Service                                  │
└────────────────┬────────────────────────────────────────┘
                 │
                 │ HTTPS Request
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│  SALESFORCE ORG                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │  OrderRESTService.cls (@RestResource)            │ │
│  │  ┌─────────────────────────────────────────────┐ │ │
│  │  │  @HttpGet    → getOrders()                  │ │ │
│  │  │  @HttpPost   → createOrder()                │ │ │
│  │  │  @HttpPut    → updateOrder()                │ │ │
│  │  │  @HttpDelete → deleteOrder()                │ │ │
│  │  └─────────────────────────────────────────────┘ │ │
│  │                      │                            │ │
│  │                      ▼                            │ │
│  │  ┌─────────────────────────────────────────────┐ │ │
│  │  │  Business Logic Layer                       │ │ │
│  │  │  - Validation                               │ │ │
│  │  │  - Security checks (CRUD/FLS)               │ │ │
│  │  │  - Data transformation                      │ │ │
│  │  │  - Error handling                           │ │ │
│  │  └─────────────────────────────────────────────┘ │ │
│  │                      │                            │ │
│  │                      ▼                            │ │
│  │  ┌─────────────────────────────────────────────┐ │ │
│  │  │  Database Layer                             │ │ │
│  │  │  - Order__c                                 │ │ │
│  │  │  - Customer__c                              │ │ │
│  │  │  - Order_Line_Item__c                       │ │ │
│  │  └─────────────────────────────────────────────┘ │ │
│  └───────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## Building Your First REST Service

### Step 1: Define the URL Mapping

```apex
@RestResource(urlMapping='/api/v1/orders/*')
global with sharing class OrderRESTService {
    // Methods go here
}
```

**Key Points:**
- `@RestResource` tells Salesforce this is a REST endpoint
- `urlMapping` defines the URL pattern
  - `/api/v1/orders/*` → Wildcard `*` for IDs
- `global` required for REST resources
- `with sharing` enforces security (recommended)

**Full URL becomes:**
```
https://yourinstance.salesforce.com/services/apexrest/api/v1/orders/*
└──────────────────────────────────┘└────────────────────┘└────────────┘
         Salesforce Domain              REST Base Path      Your Mapping
```

### Step 2: Create GET Method (Read)

```apex
@HttpGet
global static OrderResponse getOrders() {
    OrderResponse response = new OrderResponse();

    try {
        // Step 1: Access the request context
        RestRequest request = RestContext.request;
        RestResponse restResponse = RestContext.response;

        // Step 2: Extract ID from URL (if present)
        String orderId = extractOrderIdFromUrl(request.requestURI);

        // Step 3: Query order(s)
        if (String.isNotBlank(orderId)) {
            // Single order
            Order__c order = [SELECT Id, Name, Total_Amount__c
                             FROM Order__c WHERE Id = :orderId LIMIT 1];
            response.orders = new List<OrderData>{ mapOrderToData(order) };
        } else {
            // Multiple orders
            List<Order__c> orders = [SELECT Id, Name, Total_Amount__c
                                    FROM Order__c LIMIT 50];
            for (Order__c order : orders) {
                response.orders.add(mapOrderToData(order));
            }
        }

        // Step 4: Set success response
        response.success = true;
        restResponse.statusCode = 200;

    } catch (Exception e) {
        response.success = false;
        response.errorMessage = e.getMessage();
        RestContext.response.statusCode = 500;
    }

    return response;
}
```

**Learning Points:**
- `@HttpGet` decorator for GET requests
- `RestContext` provides request/response access
- Always use try-catch for error handling
- Set appropriate status codes
- Return structured response

### Step 3: Create POST Method (Create)

```apex
@HttpPost
global static OrderResponse createOrder() {
    OrderResponse response = new OrderResponse();

    try {
        // Step 1: Parse JSON from request body
        String requestBody = RestContext.request.requestBody.toString();
        OrderRequest orderRequest = (OrderRequest) JSON.deserialize(
            requestBody,
            OrderRequest.class
        );

        // Step 2: Validate input
        if (String.isBlank(orderRequest.customerId)) {
            response.success = false;
            response.errorMessage = 'customerId is required';
            RestContext.response.statusCode = 400;
            return response;
        }

        // Step 3: Create record
        Order__c newOrder = new Order__c(
            Customer__c = orderRequest.customerId,
            Total_Amount__c = orderRequest.totalAmount,
            Order_Status__c = 'Pending'
        );
        insert newOrder;

        // Step 4: Return created order
        response.success = true;
        response.message = 'Order created successfully';
        RestContext.response.statusCode = 201; // Created
        RestContext.response.addHeader('Location',
            '/services/apexrest/api/v1/orders/' + newOrder.Id);

    } catch (Exception e) {
        response.success = false;
        response.errorMessage = e.getMessage();
        RestContext.response.statusCode = 500;
    }

    return response;
}
```

**Learning Points:**
- `@HttpPost` for creating resources
- Parse JSON with `JSON.deserialize()`
- Validate before DML
- Return 201 (Created) status
- Set Location header for new resource

### Step 4: Create Response Wrapper Classes

```apex
global class OrderResponse {
    global Boolean success;
    global String message;
    global String errorMessage;
    global List<OrderData> orders;
}

global class OrderData {
    global String orderId;
    global String orderNumber;
    global Decimal totalAmount;
    global String status;
}

global class OrderRequest {
    global String customerId;
    global Decimal totalAmount;
    global String status;
}
```

**Why Wrapper Classes?**
- ✅ Consistent API structure
- ✅ Easy to serialize/deserialize
- ✅ Type safety
- ✅ Easier to evolve API

---

## HTTP Methods Deep Dive

### GET - Retrieve Data

**Purpose:** Read data without modifying it

**Characteristics:**
- ✅ Safe (doesn't change data)
- ✅ Idempotent (multiple calls = same result)
- ✅ Cacheable
- ❌ No request body

**Examples:**

```bash
# Get single order
GET /api/v1/orders/a015g000001234

# Get all orders
GET /api/v1/orders

# Get with filters
GET /api/v1/orders?status=Pending&limit=10

# Get with pagination
GET /api/v1/orders?offset=20&limit=10
```

**When to use:**
- Retrieving records
- Searching/filtering
- Dashboard data
- Reports

---

### POST - Create Data

**Purpose:** Create new resources

**Characteristics:**
- ❌ Not safe (changes data)
- ❌ Not idempotent (each call creates new record)
- ✅ Has request body

**Example:**

```bash
POST /api/v1/orders
Content-Type: application/json

{
  "customerId": "a015g000001234",
  "totalAmount": 5000.00,
  "status": "Pending",
  "lineItems": [
    {
      "deviceId": "a015g000005678",
      "quantity": 2,
      "unitPrice": 2500.00
    }
  ]
}

# Response
HTTP/1.1 201 Created
Location: /api/v1/orders/a015g000009999

{
  "success": true,
  "message": "Order created successfully",
  "orders": [
    {
      "orderId": "a015g000009999",
      "orderNumber": "ORD-12345",
      "totalAmount": 5000.00
    }
  ]
}
```

**When to use:**
- Creating new records
- Submitting forms
- Batch operations

---

### PUT - Update Data

**Purpose:** Update existing resources

**Characteristics:**
- ❌ Not safe (changes data)
- ✅ Idempotent (multiple identical calls = same state)
- ✅ Has request body
- 🔄 Full or partial update

**Example:**

```bash
PUT /api/v1/orders/a015g000001234
Content-Type: application/json

{
  "status": "Completed",
  "notes": "Order fulfilled"
}

# Response
HTTP/1.1 200 OK

{
  "success": true,
  "message": "Order updated successfully",
  "orders": [
    {
      "orderId": "a015g000001234",
      "status": "Completed",
      "notes": "Order fulfilled"
    }
  ]
}
```

**PUT vs PATCH:**
- **PUT**: Replace entire resource (or allow partial in practice)
- **PATCH**: Explicitly partial update
- Salesforce typically uses PUT for both

**When to use:**
- Updating records
- Status changes
- Editing user profile

---

### DELETE - Remove Data

**Purpose:** Delete resources

**Characteristics:**
- ❌ Not safe (removes data)
- ✅ Idempotent (deleting twice = same result)
- ❌ No request body

**Example:**

```bash
DELETE /api/v1/orders/a015g000001234

# Response
HTTP/1.1 204 No Content

{
  "success": true,
  "message": "Order deleted successfully"
}
```

**Idempotent behavior:**
```bash
# First delete
DELETE /api/v1/orders/a015g000001234
→ 204 No Content (deleted)

# Second delete (already gone)
DELETE /api/v1/orders/a015g000001234
→ 204 No Content (still successful!)
```

**When to use:**
- Removing records
- Cancel operations
- Cleanup tasks

---

## HTTP Status Codes

### Complete Guide

| Code | Name | Meaning | When to Use |
|------|------|---------|-------------|
| **2xx - Success** |
| 200 | OK | Success | GET, PUT success |
| 201 | Created | Resource created | POST success |
| 204 | No Content | Success, no body | DELETE success |
| **4xx - Client Errors** |
| 400 | Bad Request | Invalid input | Validation failed |
| 401 | Unauthorized | Auth failed | Missing/invalid token |
| 403 | Forbidden | No permission | CRUD/FLS check failed |
| 404 | Not Found | Resource missing | ID doesn't exist |
| 409 | Conflict | State conflict | Duplicate record |
| **5xx - Server Errors** |
| 500 | Internal Error | Server problem | Unhandled exception |
| 503 | Service Unavailable | Temporarily down | Maintenance mode |

### Status Code Decision Tree

```
Did the request succeed?
│
├─ YES → Is there response data?
│        ├─ YES → 200 OK
│        └─ NO  → 204 No Content
│
└─ NO → Who caused the problem?
         ├─ CLIENT → What went wrong?
         │           ├─ Invalid data → 400 Bad Request
         │           ├─ Not authenticated → 401 Unauthorized
         │           ├─ No permission → 403 Forbidden
         │           ├─ Resource missing → 404 Not Found
         │           └─ Duplicate → 409 Conflict
         │
         └─ SERVER → 500 Internal Server Error
```

### Examples in Code

```apex
// Success scenarios
RestContext.response.statusCode = 200; // GET success
RestContext.response.statusCode = 201; // POST success (created)
RestContext.response.statusCode = 204; // DELETE success

// Client error scenarios
if (String.isBlank(orderRequest.customerId)) {
    RestContext.response.statusCode = 400; // Bad Request
    return errorResponse('customerId is required');
}

if (!Schema.sObjectType.Order__c.isCreateable()) {
    RestContext.response.statusCode = 403; // Forbidden
    return errorResponse('Insufficient permissions');
}

if (orders.isEmpty()) {
    RestContext.response.statusCode = 404; // Not Found
    return errorResponse('Order not found');
}

// Server error scenarios
try {
    // ... operation ...
} catch (Exception e) {
    RestContext.response.statusCode = 500; // Internal Server Error
    return errorResponse(e.getMessage());
}
```

---

## Authentication & Security

### Authentication Methods

#### 1. OAuth 2.0 (Recommended for Production)

**Flow:**
```
1. App redirects user to Salesforce login
2. User authenticates
3. Salesforce returns authorization code
4. App exchanges code for access token
5. App uses token in API requests
```

**Implementation:**
```bash
# Request with OAuth token
curl https://yourinstance.salesforce.com/services/apexrest/api/v1/orders \
  -H "Authorization: Bearer 00D5g000001hXYZ!AR8AQP0jITN80ESEsj5n6..."
```

**In Apex (automatically handled):**
```apex
// Salesforce validates the token before your code runs
// You just need to enforce sharing rules:
@RestResource(urlMapping='/api/v1/orders/*')
global with sharing class OrderRESTService {
    // 'with sharing' enforces record-level security
}
```

#### 2. Session ID (For Testing)

```bash
# Get session ID from Salesforce UI
# Chrome DevTools → Application → Cookies → sid

curl https://yourinstance.salesforce.com/services/apexrest/api/v1/orders \
  -H "Authorization: Bearer YOUR_SESSION_ID"
```

⚠️ **Warning:** Session IDs expire! Use OAuth for production.

#### 3. Named Credentials (Org-to-Org)

When Salesforce calls external API or another Salesforce org:

```apex
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:MyNamedCredential/api/v1/orders');
// Authentication handled automatically
```

### Security Best Practices

#### 1. Enforce CRUD Permissions

```apex
// Before DML, check CRUD
if (!Schema.sObjectType.Order__c.isCreateable()) {
    throw new SecurityException('Cannot create orders');
}

if (!Schema.sObjectType.Order__c.isUpdateable()) {
    throw new SecurityException('Cannot update orders');
}

if (!Schema.sObjectType.Order__c.isDeletable()) {
    throw new SecurityException('Cannot delete orders');
}
```

#### 2. Enforce Field-Level Security (FLS)

```apex
// Check FLS before accessing field
if (!Schema.sObjectType.Order__c.fields.Total_Amount__c.isAccessible()) {
    throw new SecurityException('Cannot access Total_Amount__c');
}
```

#### 3. Use 'with sharing'

```apex
// Enforces record-level security (sharing rules)
@RestResource(urlMapping='/api/v1/orders/*')
global with sharing class OrderRESTService {
    // User can only see orders they have access to
}
```

#### 4. Validate Input

```apex
// ALWAYS validate user input
if (String.isBlank(orderRequest.customerId)) {
    return errorResponse('customerId is required');
}

if (orderRequest.totalAmount <= 0) {
    return errorResponse('totalAmount must be positive');
}

// Prevent injection attacks
if (orderRequest.notes.contains('<script>')) {
    return errorResponse('Invalid characters in notes');
}
```

#### 5. Rate Limiting

```apex
// Track API calls per user
private static Map<Id, Integer> callCountPerUser = new Map<Id, Integer>();

public static void enforceRateLimit() {
    Id userId = UserInfo.getUserId();
    Integer callCount = callCountPerUser.get(userId) ?: 0;

    if (callCount > 100) {
        RestContext.response.statusCode = 429; // Too Many Requests
        throw new RateLimitException('API rate limit exceeded');
    }

    callCountPerUser.put(userId, callCount + 1);
}
```

#### 6. Secure Error Responses

**⚠️ CRITICAL SECURITY: Information Disclosure via Stack Traces**

One of the most common security vulnerabilities in REST APIs is exposing internal implementation details through error messages.

**What NOT to do:**
```apex
// ❌ SECURITY VULNERABILITY - Information Disclosure
catch (Exception e) {
    response.errorMessage = e.getMessage();
    response.errorDetails = e.getStackTraceString(); // DANGER!
    response.stackTrace = e.getStackTrace();          // DANGER!
    response.lineNumber = e.getLineNumber();          // DANGER!
}
```

**Example leaked information:**
```
Stack trace:
  Class.OrderRESTService.createOrder: line 245, column 15
  Class.DatabaseUtils.executeQuery: line 89, column 23
  Class.ConfigManager.getApiKey: line 12, column 8
```

**What attackers learn:**
- ✅ Internal class names and structure
- ✅ File paths and directory structure
- ✅ Line numbers for targeted attacks
- ✅ Framework and library versions
- ✅ Database query patterns
- ✅ Configuration mechanisms

**Secure approach:**
```apex
// ✅ SECURE - No information disclosure
catch (Exception e) {
    // 1. Generic message for client
    response.errorMessage = 'An unexpected error occurred. ' +
                           'Please contact support with reference: ' +
                           errorRef;

    // 2. Error reference for correlation
    String errorRef = String.valueOf(System.currentTimeMillis());
    response.errorReference = errorRef;

    // 3. Log FULL details server-side (secure)
    ErrorLogger.logError(
        'OrderRESTService',
        'createOrder',
        e  // Stack trace logged server-side only
    );

    // 4. Return 500 status
    RestContext.response.statusCode = 500;
}
```

**Secure error response example:**
```json
{
  "success": false,
  "errorMessage": "An unexpected error occurred. Please contact support.",
  "errorReference": "1730739456789"
}
```

**Benefits:**
- ❌ No internal details exposed to attackers
- ✅ User gets helpful message
- ✅ Support can correlate via errorReference
- ✅ Full details logged server-side for debugging
- ✅ Complies with security best practices

**Additional tips:**
```apex
// Don't expose database field names
// ❌ Bad: "Error on field Customer__c: value too long"
// ✅ Good: "Invalid input. Please check your data."

// Don't expose validation rules
// ❌ Bad: "Failed validation rule: Prevent_Negative_Amount_Rule"
// ✅ Good: "Unable to process request due to invalid data."

// Don't expose permission errors
// ❌ Bad: "User lacks UPDATE permission on Order__c.Total_Amount__c"
// ✅ Good: "Insufficient permissions to perform this operation."
```

---

## Testing REST APIs

### 1. Unit Tests in Apex

See `OrderRESTServiceTest.cls` for comprehensive examples.

**Key pattern:**
```apex
@isTest
static void testGetOrder() {
    // ARRANGE: Set up REST context
    RestRequest request = new RestRequest();
    RestResponse response = new RestResponse();
    request.requestURI = '/services/apexrest/api/v1/orders/' + testOrderId;
    request.httpMethod = 'GET';
    RestContext.request = request;
    RestContext.response = response;

    // ACT: Call the service
    Test.startTest();
    OrderRESTService.OrderResponse result = OrderRESTService.getOrders();
    Test.stopTest();

    // ASSERT: Verify response
    System.assertEquals(true, result.success);
    System.assertEquals(200, RestContext.response.statusCode);
}
```

### 2. Manual Testing with Workbench

**Step 1:** Go to https://workbench.developerforce.com/

**Step 2:** Login to your org

**Step 3:** Navigate to: **utilities → REST Explorer**

**Step 4:** Test your endpoint
```
GET /services/apexrest/api/v1/orders
```

### 3. Testing with cURL (Command Line)

```bash
# Get access token first (simplified)
TOKEN="your_session_id_or_oauth_token"
INSTANCE="https://yourinstance.salesforce.com"

# GET request
curl "$INSTANCE/services/apexrest/api/v1/orders" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"

# POST request
curl -X POST "$INSTANCE/services/apexrest/api/v1/orders" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "customerId": "a015g000001234",
    "totalAmount": 5000.00,
    "status": "Pending"
  }'

# PUT request
curl -X PUT "$INSTANCE/services/apexrest/api/v1/orders/a015g000001234" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "Completed"
  }'

# DELETE request
curl -X DELETE "$INSTANCE/services/apexrest/api/v1/orders/a015g000001234" \
  -H "Authorization: Bearer $TOKEN"
```

### 4. Testing with Postman

See `API_TESTING_EXAMPLES.md` for detailed Postman guide.

---

## Best Practices

### 1. Versioning

Always version your APIs:

```apex
// ✅ Good - versioned URL
@RestResource(urlMapping='/api/v1/orders/*')

// ❌ Bad - no version
@RestResource(urlMapping='/api/orders/*')
```

**Why?** You can introduce breaking changes in v2 while v1 still works.

### 2. Consistent Response Structure

```json
// ✅ Always use same structure
{
  "success": true,
  "message": "Operation successful",
  "data": { ... },
  "errors": null
}

// ❌ Inconsistent
// Success: { "orders": [...] }
// Error: { "error": "Something failed" }
```

### 3. Error Handling

```apex
// ✅ Always catch exceptions
try {
    // ... operation ...
} catch (DmlException e) {
    return handleDmlError(e);
} catch (Exception e) {
    return handleGenericError(e);
}

// ❌ Never let exceptions bubble up unhandled
```

**🔒 CRITICAL SECURITY: Never Expose Stack Traces!**

```apex
// ❌ SECURITY VULNERABILITY - Do NOT do this!
private static OrderResponse handleException(Exception e) {
    response.errorMessage = e.getMessage();
    response.errorDetails = e.getStackTraceString(); // ⚠️ EXPOSES INTERNALS!
    return response;
}

// ✅ SECURE - Sanitize errors before returning to client
private static OrderResponse handleException(Exception e) {
    // Generic message for client
    response.errorMessage = 'An unexpected error occurred. Please try again.';
    response.errorReference = String.valueOf(System.currentTimeMillis());

    // Log FULL details server-side (stack trace, etc.)
    ErrorLogger.logError('MyService', 'operation', e);

    return response;
}
```

**Why this matters:**
- Stack traces reveal internal paths, class names, line numbers
- Attackers use this information to map your architecture
- Helps identify potential vulnerabilities
- Exposes framework versions and dependencies
- **Always log server-side, never expose to clients!**

### 4. Input Validation

```apex
// ✅ Validate before processing
if (String.isBlank(orderRequest.customerId)) {
    return validationError('customerId is required');
}

if (orderRequest.totalAmount <= 0) {
    return validationError('totalAmount must be positive');
}

// ❌ Trust user input
Order__c order = new Order__c(
    Customer__c = orderRequest.customerId // What if null?
);
```

### 5. Logging

```apex
// ✅ Log errors for monitoring
try {
    // ... operation ...
} catch (Exception e) {
    ErrorLogger.logError('OrderRESTService', 'createOrder', e);
    return errorResponse(e.getMessage());
}
```

### 6. Documentation

```apex
// ✅ Document your API
/**
 * @description Creates a new order
 * @param orderRequest JSON body with order details
 * @return OrderResponse with created order or error
 *
 * Example request:
 * POST /api/v1/orders
 * {
 *   "customerId": "a015g000001234",
 *   "totalAmount": 5000.00
 * }
 */
@HttpPost
global static OrderResponse createOrder() { ... }
```

### 7. Pagination

```apex
// ✅ Always paginate large result sets
Integer limit = Math.min(requestedLimit, 200); // Max 200
Integer offset = requestedOffset ?: 0;

String query = 'SELECT Id FROM Order__c ' +
               'LIMIT :limit OFFSET :offset';
```

### 8. Bulkification

```apex
// ✅ Support bulk operations
@HttpPost
global static OrderResponse createOrders() {
    // Accept array of orders
    List<OrderRequest> orders = parseRequestBody();

    List<Order__c> ordersToInsert = new List<Order__c>();
    for (OrderRequest req : orders) {
        ordersToInsert.add(buildOrder(req));
    }

    insert ordersToInsert; // Bulk insert
}

// ❌ Single record only (inefficient)
```

---

## Common Patterns

### Pattern 1: Resource-Based URLs

```
✅ Good:
GET    /api/v1/orders           (collection)
GET    /api/v1/orders/123       (single resource)
POST   /api/v1/orders           (create)
PUT    /api/v1/orders/123       (update)
DELETE /api/v1/orders/123       (delete)

❌ Bad:
GET    /api/v1/getOrders
POST   /api/v1/createOrder
POST   /api/v1/updateOrder
POST   /api/v1/deleteOrder
```

### Pattern 2: Query Parameters for Filtering

```
GET /api/v1/orders?status=Pending&limit=10&offset=0
                   └──┬──┘ └────┬────┘ └───┬───┘
                   Filter   Pagination  Pagination
```

### Pattern 3: Nested Resources

```
GET /api/v1/orders/123/line-items
           └──┬───┘    └────┬────┘
          Parent      Child Resource
```

### Pattern 4: Error Response Structure

```json
{
  "success": false,
  "errorCode": "VALIDATION_ERROR",
  "errorMessage": "customerId is required",
  "errorDetails": {
    "field": "customerId",
    "rejectedValue": null,
    "constraint": "required"
  },
  "timestamp": "2025-11-04T10:30:00Z"
}
```

### Pattern 5: HATEOAS (Advanced)

**H**ypermedia **A**s **T**he **E**ngine **O**f **A**pplication **S**tate

```json
{
  "orderId": "a015g000001234",
  "status": "Pending",
  "_links": {
    "self": "/api/v1/orders/a015g000001234",
    "customer": "/api/v1/customers/a015g000005678",
    "line-items": "/api/v1/orders/a015g000001234/line-items",
    "cancel": "/api/v1/orders/a015g000001234/cancel"
  }
}
```

---

## Troubleshooting

### Common Issues

#### 1. "Unauthorized endpoint" Error

**Problem:**
```
System.CalloutException: Unauthorized endpoint, please check Setup->Security->Remote site settings
```

**Solution:**
Add remote site in Setup:
- Setup → Security → Remote Site Settings
- New Remote Site
- Add your endpoint URL

---

#### 2. "Method not allowed" Error

**Problem:**
```
HTTP 405 Method Not Allowed
```

**Solution:**
- Check you're using the right HTTP method
- Verify the method is implemented in your class
- Ensure `@HttpGet`, `@HttpPost`, etc. are present

---

#### 3. "Invalid Session ID" Error

**Problem:**
```
HTTP 401 Unauthorized
[{"message":"Session expired or invalid","errorCode":"INVALID_SESSION_ID"}]
```

**Solution:**
- Get a fresh session ID or OAuth token
- Check token hasn't expired
- Verify Authorization header format: `Bearer TOKEN`

---

#### 4. Empty Response Body

**Problem:**
- Request succeeds but response is empty

**Solution:**
```apex
// ✅ Return the response object
@HttpGet
global static OrderResponse getOrders() {
    OrderResponse response = new OrderResponse();
    // ... build response ...
    return response; // Don't forget this!
}
```

---

#### 5. JSON Deserialization Errors

**Problem:**
```
System.JSONException: Unexpected character ('<' (code 60))
```

**Solution:**
```apex
// ✅ Add error handling
try {
    OrderRequest req = (OrderRequest) JSON.deserialize(
        requestBody,
        OrderRequest.class
    );
} catch (JSONException e) {
    return errorResponse('Invalid JSON format');
}
```

---

## Next Steps

### 1. Enhance Your OrderRESTService

**Add these features:**
- [ ] Bulk operations (create/update multiple)
- [ ] Advanced filtering (date ranges, amount ranges)
- [ ] Sorting parameters
- [ ] Field selection (sparse fieldsets)
- [ ] Async processing for large operations

### 2. Add Authentication Layer

- [ ] Implement API key validation
- [ ] Add rate limiting per user
- [ ] Track API usage metrics

### 3. Build More REST Services

- [ ] CustomerRESTService
- [ ] DeviceRESTService
- [ ] ReportRESTService

### 4. Integration Projects

- [ ] Build a mobile app using your API
- [ ] Create an external web portal
- [ ] Integrate with third-party service

### 5. Advanced Topics

- [ ] Webhooks (Platform Events)
- [ ] Streaming API
- [ ] Bulk API for large datasets
- [ ] GraphQL alternative

---

## Resources

### Official Documentation
- [Salesforce REST API Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/)
- [Apex REST Basics](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_rest.htm)

### Tools
- [Postman](https://www.postman.com/) - API testing
- [Workbench](https://workbench.developerforce.com/) - Salesforce REST explorer
- [cURL](https://curl.se/) - Command-line HTTP client

### Tutorials
- Trailhead: [Build an API with REST](https://trailhead.salesforce.com/content/learn/modules/api_basics)
- Trailhead: [Apex Integration Services](https://trailhead.salesforce.com/content/learn/modules/apex_integration_services)

---

## Summary

### What You've Learned

✅ What REST APIs are and why they matter
✅ How REST works (request/response cycle)
✅ HTTP methods (GET, POST, PUT, DELETE)
✅ HTTP status codes
✅ Salesforce REST architecture
✅ Building custom REST services in Apex
✅ Authentication and security
✅ Testing REST APIs
✅ Best practices and common patterns

### Key Takeaways

1. **REST APIs enable integration** - Connect Salesforce with any system
2. **Use standard HTTP** - GET, POST, PUT, DELETE for CRUD
3. **Status codes matter** - Communicate success/failure clearly
4. **Security is critical** - Always enforce CRUD/FLS/sharing
5. **Test thoroughly** - Unit tests + manual testing tools
6. **Version your APIs** - Plan for future changes
7. **Document everything** - Help future developers (including yourself!)

---

## Congratulations! 🎉

You now understand REST API development in Salesforce!

**You can:**
- ✅ Build custom REST services
- ✅ Expose Salesforce data to external systems
- ✅ Integrate with third-party APIs
- ✅ Design scalable, secure APIs
- ✅ Test and troubleshoot APIs

**This skill is invaluable for:**
- Mobile app development
- System integrations
- Microservices architecture
- Partner/customer portals
- Career advancement!

---

*For detailed testing examples and Postman collections, see `API_TESTING_EXAMPLES.md`*

*For code reference, see `OrderRESTService.cls` and `OrderRESTServiceTest.cls`*
