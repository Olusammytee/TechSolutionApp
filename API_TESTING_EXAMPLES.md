# 🧪 REST API Testing Examples

## Complete Guide to Testing Your Salesforce REST API

This guide provides step-by-step instructions for testing the OrderRESTService API using various tools.

---

## 📑 Table of Contents

1. [Getting Your Access Token](#getting-your-access-token)
2. [Testing with Postman](#testing-with-postman)
3. [Testing with cURL](#testing-with-curl)
4. [Testing with Workbench](#testing-with-workbench)
5. [Testing with JavaScript](#testing-with-javascript)
6. [Testing with Python](#testing-with-python)
7. [Automated Testing](#automated-testing)
8. [Common Issues](#common-issues)

---

## Getting Your Access Token

Before testing, you need an access token. Here are multiple ways to get one:

### Method 1: Get Session ID from Browser (Easiest for Testing)

**Step 1:** Log into your Salesforce org

**Step 2:** Open Chrome DevTools (F12 or Right-click → Inspect)

**Step 3:** Go to **Console** tab

**Step 4:** Paste and run:
```javascript
console.log(window.$Api.getSessionId());
```

**Step 5:** Copy the token that appears

⚠️ **Note:** Session IDs expire after a few hours!

---

### Method 2: OAuth 2.0 (Production Method)

**For production apps**, use OAuth 2.0:

1. Create Connected App in Setup
2. Use OAuth flow to get access token
3. Token lasts longer and is more secure

**Detailed steps:**
1. Setup → App Manager → New Connected App
2. Enable OAuth Settings
3. Select scopes (api, refresh_token)
4. Save and note Client ID and Client Secret

**Get token via OAuth:**
```bash
# Step 1: Get authorization code (browser)
https://login.salesforce.com/services/oauth2/authorize?
  response_type=code&
  client_id=YOUR_CLIENT_ID&
  redirect_uri=YOUR_REDIRECT_URI

# Step 2: Exchange code for token
curl -X POST https://login.salesforce.com/services/oauth2/token \
  -d "grant_type=authorization_code" \
  -d "code=YOUR_AUTH_CODE" \
  -d "client_id=YOUR_CLIENT_ID" \
  -d "client_secret=YOUR_CLIENT_SECRET" \
  -d "redirect_uri=YOUR_REDIRECT_URI"

# Response includes access_token
{
  "access_token": "00D5g000001hXYZ!AR8AQP0jITN...",
  "instance_url": "https://yourinstance.salesforce.com",
  "token_type": "Bearer"
}
```

---

### Method 3: Username-Password Flow (Dev/Test Only)

⚠️ **Not recommended for production!**

```bash
curl -X POST https://login.salesforce.com/services/oauth2/token \
  -d "grant_type=password" \
  -d "client_id=YOUR_CLIENT_ID" \
  -d "client_secret=YOUR_CLIENT_SECRET" \
  -d "username=YOUR_USERNAME" \
  -d "password=YOUR_PASSWORD + SECURITY_TOKEN"
```

---

## Testing with Postman

### Setup Postman

**Step 1:** Download Postman
- Go to https://www.postman.com/downloads/
- Install Postman for your OS

**Step 2:** Create a new collection
- Click "New" → "Collection"
- Name it "Salesforce Order API"

**Step 3:** Set up environment variables
- Click "Environments" → "New Environment"
- Name it "Salesforce Dev"
- Add variables:

```
VARIABLE          | VALUE
------------------|----------------------------------
instance_url      | https://yourinstance.salesforce.com
access_token      | YOUR_SESSION_ID_OR_OAUTH_TOKEN
api_version       | v59.0
```

---

### Test 1: GET Single Order

**Request Setup:**
```
Method: GET
URL: {{instance_url}}/services/apexrest/api/v1/orders/YOUR_ORDER_ID

Headers:
  Authorization: Bearer {{access_token}}
  Content-Type: application/json
```

**Expected Response (200 OK):**
```json
{
  "success": true,
  "orders": [
    {
      "orderId": "a015g000001234AAA",
      "orderNumber": "ORD-00001",
      "customerId": "a015g000005678AAA",
      "customerName": "Acme Corporation",
      "orderDate": "2025-11-04",
      "status": "Pending",
      "totalAmount": 5000.00,
      "notes": "Urgent order",
      "createdDate": "2025-11-04T10:30:00.000Z",
      "lastModifiedDate": "2025-11-04T10:30:00.000Z",
      "lineItems": [
        {
          "lineItemId": "a015g000009999AAA",
          "deviceId": "a015g000007777AAA",
          "deviceName": "Smartphone Pro",
          "quantity": 2,
          "unitPrice": 2500.00,
          "totalPrice": 5000.00
        }
      ]
    }
  ]
}
```

**Postman Tests (Add to "Tests" tab):**
```javascript
// Verify status code
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

// Verify response structure
pm.test("Response has success field", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('success');
    pm.expect(jsonData.success).to.be.true;
});

// Verify order data
pm.test("Response contains order data", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.orders).to.be.an('array');
    pm.expect(jsonData.orders.length).to.equal(1);
    pm.expect(jsonData.orders[0]).to.have.property('orderId');
});

// Verify line items included
pm.test("Order includes line items", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.orders[0].lineItems).to.be.an('array');
});
```

---

### Test 2: GET Multiple Orders with Filters

**Request Setup:**
```
Method: GET
URL: {{instance_url}}/services/apexrest/api/v1/orders?status=Pending&limit=10

Headers:
  Authorization: Bearer {{access_token}}
  Content-Type: application/json
```

**Expected Response (200 OK):**
```json
{
  "success": true,
  "orders": [
    {
      "orderId": "a015g000001234AAA",
      "orderNumber": "ORD-00001",
      "status": "Pending",
      "totalAmount": 5000.00
    },
    {
      "orderId": "a015g000001235AAA",
      "orderNumber": "ORD-00002",
      "status": "Pending",
      "totalAmount": 3000.00
    }
  ],
  "totalRecords": 2
}
```

**Postman Tests:**
```javascript
pm.test("All orders have Pending status", function () {
    var jsonData = pm.response.json();
    jsonData.orders.forEach(function(order) {
        pm.expect(order.status).to.equal('Pending');
    });
});

pm.test("Returns no more than limit", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.orders.length).to.be.at.most(10);
});
```

---

### Test 3: POST Create Order

**Request Setup:**
```
Method: POST
URL: {{instance_url}}/services/apexrest/api/v1/orders

Headers:
  Authorization: Bearer {{access_token}}
  Content-Type: application/json

Body (raw JSON):
{
  "customerId": "a015g000005678AAA",
  "orderDate": "2025-11-04",
  "status": "Pending",
  "totalAmount": 7500.00,
  "notes": "Created via Postman",
  "lineItems": [
    {
      "deviceId": "a015g000007777AAA",
      "quantity": 3,
      "unitPrice": 2500.00
    }
  ]
}
```

**Expected Response (201 Created):**
```json
{
  "success": true,
  "message": "Order created successfully",
  "orders": [
    {
      "orderId": "a015g000009999AAA",
      "orderNumber": "ORD-00123",
      "customerId": "a015g000005678AAA",
      "customerName": "Acme Corporation",
      "status": "Pending",
      "totalAmount": 7500.00,
      "notes": "Created via Postman"
    }
  ]
}
```

**Postman Tests:**
```javascript
pm.test("Status code is 201", function () {
    pm.response.to.have.status(201);
});

pm.test("Location header is set", function () {
    pm.response.to.have.header("Location");
    var location = pm.response.headers.get("Location");
    pm.expect(location).to.include("/api/v1/orders/");
});

pm.test("Order ID is returned", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.orders[0].orderId).to.exist;
    // Save for later tests
    pm.environment.set("created_order_id", jsonData.orders[0].orderId);
});
```

---

### Test 4: PUT Update Order

**Request Setup:**
```
Method: PUT
URL: {{instance_url}}/services/apexrest/api/v1/orders/{{created_order_id}}

Headers:
  Authorization: Bearer {{access_token}}
  Content-Type: application/json

Body (raw JSON):
{
  "status": "Completed",
  "notes": "Order fulfilled and delivered"
}
```

**Expected Response (200 OK):**
```json
{
  "success": true,
  "message": "Order updated successfully",
  "orders": [
    {
      "orderId": "a015g000009999AAA",
      "status": "Completed",
      "notes": "Order fulfilled and delivered",
      "lastModifiedDate": "2025-11-04T15:45:00.000Z"
    }
  ]
}
```

**Postman Tests:**
```javascript
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Status was updated", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.orders[0].status).to.equal('Completed');
});

pm.test("Notes were updated", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.orders[0].notes).to.include('fulfilled');
});
```

---

### Test 5: DELETE Order

**Request Setup:**
```
Method: DELETE
URL: {{instance_url}}/services/apexrest/api/v1/orders/{{created_order_id}}

Headers:
  Authorization: Bearer {{access_token}}
  Content-Type: application/json
```

**Expected Response (204 No Content):**
```json
{
  "success": true,
  "message": "Order deleted successfully"
}
```

**Postman Tests:**
```javascript
pm.test("Status code is 204", function () {
    pm.response.to.have.status(204);
});

pm.test("Subsequent GET returns 404", function () {
    pm.sendRequest({
        url: pm.environment.get("instance_url") +
             "/services/apexrest/api/v1/orders/" +
             pm.environment.get("created_order_id"),
        method: 'GET',
        header: {
            'Authorization': 'Bearer ' + pm.environment.get("access_token")
        }
    }, function (err, response) {
        pm.expect(response.code).to.equal(404);
    });
});
```

---

### Test 6: Error Handling - Missing Required Field

**Request Setup:**
```
Method: POST
URL: {{instance_url}}/services/apexrest/api/v1/orders

Headers:
  Authorization: Bearer {{access_token}}
  Content-Type: application/json

Body (raw JSON):
{
  "orderDate": "2025-11-04",
  "totalAmount": 5000.00
}
```
Note: `customerId` is intentionally missing

**Expected Response (400 Bad Request):**
```json
{
  "success": false,
  "errorMessage": "customerId is required"
}
```

**Postman Tests:**
```javascript
pm.test("Status code is 400", function () {
    pm.response.to.have.status(400);
});

pm.test("Error message mentions missing field", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.errorMessage).to.include('customerId');
});
```

---

### Test 7: Error Handling - Invalid Amount

**Request Setup:**
```
Method: POST
URL: {{instance_url}}/services/apexrest/api/v1/orders

Body (raw JSON):
{
  "customerId": "a015g000005678AAA",
  "totalAmount": -100.00
}
```

**Expected Response (400 Bad Request):**
```json
{
  "success": false,
  "errorMessage": "totalAmount must be greater than 0"
}
```

---

### Running the Collection

**Sequential Test Run:**
1. Click the collection
2. Click "Run"
3. Select all requests
4. Click "Run Salesforce Order API"
5. View test results

**Expected results:**
```
✓ GET Single Order - 200 OK
✓ GET Multiple Orders - 200 OK
✓ POST Create Order - 201 Created
✓ PUT Update Order - 200 OK
✓ DELETE Order - 204 No Content
✓ Error: Missing Field - 400 Bad Request
✓ Error: Invalid Amount - 400 Bad Request
```

---

## Testing with cURL

### Setup

**Set variables (bash/zsh):**
```bash
export SF_INSTANCE="https://yourinstance.salesforce.com"
export SF_TOKEN="your_access_token_here"
export API_BASE="$SF_INSTANCE/services/apexrest/api/v1/orders"
```

---

### Test 1: GET Single Order

```bash
ORDER_ID="a015g000001234AAA"

curl -X GET "$API_BASE/$ORDER_ID" \
  -H "Authorization: Bearer $SF_TOKEN" \
  -H "Content-Type: application/json" \
  -w "\nHTTP Status: %{http_code}\n"
```

**Expected output:**
```json
{
  "success": true,
  "orders": [{
    "orderId": "a015g000001234AAA",
    "orderNumber": "ORD-00001",
    "status": "Pending"
  }]
}
HTTP Status: 200
```

---

### Test 2: GET Multiple Orders with Filters

```bash
curl -X GET "$API_BASE?status=Pending&limit=5" \
  -H "Authorization: Bearer $SF_TOKEN" \
  -H "Content-Type: application/json" \
  -w "\nHTTP Status: %{http_code}\n"
```

---

### Test 3: POST Create Order

```bash
curl -X POST "$API_BASE" \
  -H "Authorization: Bearer $SF_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "customerId": "a015g000005678AAA",
    "orderDate": "2025-11-04",
    "status": "Pending",
    "totalAmount": 5000.00,
    "notes": "Created via cURL"
  }' \
  -w "\nHTTP Status: %{http_code}\n"
```

**Save response to variable:**
```bash
RESPONSE=$(curl -s -X POST "$API_BASE" \
  -H "Authorization: Bearer $SF_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "customerId": "a015g000005678AAA",
    "totalAmount": 5000.00
  }')

# Extract order ID using jq
NEW_ORDER_ID=$(echo $RESPONSE | jq -r '.orders[0].orderId')
echo "Created order: $NEW_ORDER_ID"
```

---

### Test 4: PUT Update Order

```bash
curl -X PUT "$API_BASE/$NEW_ORDER_ID" \
  -H "Authorization: Bearer $SF_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "Completed",
    "notes": "Updated via cURL"
  }' \
  -w "\nHTTP Status: %{http_code}\n"
```

---

### Test 5: DELETE Order

```bash
curl -X DELETE "$API_BASE/$NEW_ORDER_ID" \
  -H "Authorization: Bearer $SF_TOKEN" \
  -H "Content-Type: application/json" \
  -w "\nHTTP Status: %{http_code}\n"
```

---

### Test 6: Verify Deletion (Should get 404)

```bash
curl -X GET "$API_BASE/$NEW_ORDER_ID" \
  -H "Authorization: Bearer $SF_TOKEN" \
  -H "Content-Type: application/json" \
  -w "\nHTTP Status: %{http_code}\n"

# Expected: HTTP Status: 404
```

---

### Complete Test Script

**Save as `test_api.sh`:**
```bash
#!/bin/bash

# Configuration
SF_INSTANCE="https://yourinstance.salesforce.com"
SF_TOKEN="your_access_token_here"
API_BASE="$SF_INSTANCE/services/apexrest/api/v1/orders"
CUSTOMER_ID="a015g000005678AAA"  # Replace with real ID

echo "🧪 Testing Salesforce Order API"
echo "================================"

# Test 1: Create Order
echo -e "\n✅ Test 1: Create Order"
CREATE_RESPONSE=$(curl -s -X POST "$API_BASE" \
  -H "Authorization: Bearer $SF_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"customerId\": \"$CUSTOMER_ID\",
    \"totalAmount\": 5000.00,
    \"status\": \"Pending\"
  }")

NEW_ORDER_ID=$(echo $CREATE_RESPONSE | jq -r '.orders[0].orderId')
echo "Created order: $NEW_ORDER_ID"

# Test 2: Get Order
echo -e "\n✅ Test 2: Get Order"
curl -s -X GET "$API_BASE/$NEW_ORDER_ID" \
  -H "Authorization: Bearer $SF_TOKEN" \
  | jq '.orders[0] | {orderId, status, totalAmount}'

# Test 3: Update Order
echo -e "\n✅ Test 3: Update Order"
curl -s -X PUT "$API_BASE/$NEW_ORDER_ID" \
  -H "Authorization: Bearer $SF_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "Completed"
  }' \
  | jq '.orders[0] | {orderId, status}'

# Test 4: Delete Order
echo -e "\n✅ Test 4: Delete Order"
curl -s -X DELETE "$API_BASE/$NEW_ORDER_ID" \
  -H "Authorization: Bearer $SF_TOKEN" \
  | jq '.success'

echo -e "\n================================"
echo "✅ All tests completed!"
```

**Run it:**
```bash
chmod +x test_api.sh
./test_api.sh
```

---

## Testing with Workbench

Salesforce Workbench is a free web-based tool for testing APIs.

### Setup

**Step 1:** Go to https://workbench.developerforce.com/

**Step 2:** Login to your Salesforce org
- Select environment (Production/Sandbox)
- Agree to terms
- Login

**Step 3:** Navigate to REST Explorer
- Click: **utilities** → **REST Explorer**

---

### Test GET Request

```
Endpoint: /services/apexrest/api/v1/orders
Method: GET
Headers: (automatically added)

Click "Execute"
```

**Response shown in browser with:**
- Status code
- Response headers
- JSON body with syntax highlighting

---

### Test POST Request

```
Endpoint: /services/apexrest/api/v1/orders
Method: POST
Request Body:
{
  "customerId": "a015g000005678AAA",
  "totalAmount": 5000.00,
  "status": "Pending"
}

Click "Execute"
```

---

## Testing with JavaScript

### Fetch API (Browser/Node.js)

```javascript
// Configuration
const INSTANCE_URL = 'https://yourinstance.salesforce.com';
const ACCESS_TOKEN = 'your_access_token_here';
const API_BASE = `${INSTANCE_URL}/services/apexrest/api/v1/orders`;

// Helper function
async function callAPI(endpoint, method = 'GET', body = null) {
  const options = {
    method,
    headers: {
      'Authorization': `Bearer ${ACCESS_TOKEN}`,
      'Content-Type': 'application/json'
    }
  };

  if (body) {
    options.body = JSON.stringify(body);
  }

  const response = await fetch(`${API_BASE}${endpoint}`, options);
  const data = await response.json();

  return {
    status: response.status,
    data: data
  };
}

// Test 1: Get all orders
async function testGetOrders() {
  console.log('📋 Getting all orders...');
  const result = await callAPI('');
  console.log('Status:', result.status);
  console.log('Orders:', result.data.orders);
}

// Test 2: Create order
async function testCreateOrder() {
  console.log('➕ Creating order...');
  const orderData = {
    customerId: 'a015g000005678AAA',
    totalAmount: 5000.00,
    status: 'Pending'
  };

  const result = await callAPI('', 'POST', orderData);
  console.log('Status:', result.status);
  console.log('Created:', result.data.orders[0]);

  return result.data.orders[0].orderId;
}

// Test 3: Update order
async function testUpdateOrder(orderId) {
  console.log('✏️  Updating order...');
  const updateData = {
    status: 'Completed'
  };

  const result = await callAPI(`/${orderId}`, 'PUT', updateData);
  console.log('Status:', result.status);
  console.log('Updated:', result.data.orders[0]);
}

// Test 4: Delete order
async function testDeleteOrder(orderId) {
  console.log('🗑️  Deleting order...');
  const result = await callAPI(`/${orderId}`, 'DELETE');
  console.log('Status:', result.status);
  console.log('Result:', result.data);
}

// Run all tests
async function runTests() {
  try {
    await testGetOrders();
    const newOrderId = await testCreateOrder();
    await testUpdateOrder(newOrderId);
    await testDeleteOrder(newOrderId);
    console.log('✅ All tests passed!');
  } catch (error) {
    console.error('❌ Test failed:', error);
  }
}

runTests();
```

---

## Testing with Python

### Using requests library

```python
import requests
import json

# Configuration
INSTANCE_URL = "https://yourinstance.salesforce.com"
ACCESS_TOKEN = "your_access_token_here"
API_BASE = f"{INSTANCE_URL}/services/apexrest/api/v1/orders"

headers = {
    "Authorization": f"Bearer {ACCESS_TOKEN}",
    "Content-Type": "application/json"
}

def test_get_orders():
    """Test GET all orders"""
    print("📋 Getting all orders...")
    response = requests.get(API_BASE, headers=headers)

    print(f"Status: {response.status_code}")
    data = response.json()
    print(f"Success: {data['success']}")
    print(f"Orders found: {len(data['orders'])}")

    return response.status_code == 200

def test_create_order():
    """Test POST create order"""
    print("\n➕ Creating order...")
    order_data = {
        "customerId": "a015g000005678AAA",
        "totalAmount": 5000.00,
        "status": "Pending",
        "notes": "Created via Python"
    }

    response = requests.post(API_BASE, headers=headers, json=order_data)

    print(f"Status: {response.status_code}")
    data = response.json()
    print(f"Success: {data['success']}")

    if response.status_code == 201:
        order_id = data['orders'][0]['orderId']
        print(f"Created order ID: {order_id}")
        return order_id

    return None

def test_update_order(order_id):
    """Test PUT update order"""
    print(f"\n✏️  Updating order {order_id}...")
    update_data = {
        "status": "Completed",
        "notes": "Updated via Python"
    }

    url = f"{API_BASE}/{order_id}"
    response = requests.put(url, headers=headers, json=update_data)

    print(f"Status: {response.status_code}")
    data = response.json()
    print(f"Success: {data['success']}")
    print(f"New status: {data['orders'][0]['status']}")

    return response.status_code == 200

def test_delete_order(order_id):
    """Test DELETE order"""
    print(f"\n🗑️  Deleting order {order_id}...")
    url = f"{API_BASE}/{order_id}"
    response = requests.delete(url, headers=headers)

    print(f"Status: {response.status_code}")
    data = response.json()
    print(f"Success: {data['success']}")

    return response.status_code == 204

def test_error_handling():
    """Test error handling with invalid data"""
    print("\n🔍 Testing error handling...")
    invalid_data = {
        "totalAmount": -100.00  # Missing customerId, invalid amount
    }

    response = requests.post(API_BASE, headers=headers, json=invalid_data)

    print(f"Status: {response.status_code}")
    data = response.json()
    print(f"Success: {data['success']}")
    print(f"Error: {data.get('errorMessage')}")

    return response.status_code == 400

# Run all tests
def run_tests():
    print("🧪 Testing Salesforce Order API")
    print("=" * 50)

    results = []

    # Test GET
    results.append(("GET Orders", test_get_orders()))

    # Test CREATE
    order_id = test_create_order()
    if order_id:
        results.append(("CREATE Order", True))

        # Test UPDATE
        results.append(("UPDATE Order", test_update_order(order_id)))

        # Test DELETE
        results.append(("DELETE Order", test_delete_order(order_id)))
    else:
        results.append(("CREATE Order", False))

    # Test ERROR handling
    results.append(("ERROR Handling", test_error_handling()))

    # Print summary
    print("\n" + "=" * 50)
    print("📊 Test Summary:")
    for test_name, passed in results:
        status = "✅ PASS" if passed else "❌ FAIL"
        print(f"{status} - {test_name}")

    total = len(results)
    passed = sum(1 for _, p in results if p)
    print(f"\n{passed}/{total} tests passed")

if __name__ == "__main__":
    run_tests()
```

**Run it:**
```bash
pip install requests
python test_api.py
```

---

## Automated Testing

### GitHub Actions CI/CD

**Create `.github/workflows/api-test.yml`:**

```yaml
name: API Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: Install SFDX
      run: |
        wget https://developer.salesforce.com/media/salesforce-cli/sfdx/channels/stable/sfdx-linux-x64.tar.xz
        mkdir ~/sfdx
        tar xJf sfdx-linux-x64.tar.xz -C ~/sfdx --strip-components 1
        echo "$HOME/sfdx/bin" >> $GITHUB_PATH

    - name: Authenticate to Salesforce
      run: |
        echo "${{ secrets.SF_AUTH_URL }}" > authurl.txt
        sfdx auth:sfdxurl:store -f authurl.txt -a devhub

    - name: Deploy to Scratch Org
      run: |
        sfdx force:org:create -f config/project-scratch-def.json -a scratch-org -s
        sfdx force:source:push

    - name: Run Apex Tests
      run: |
        sfdx force:apex:test:run -c -r human -w 10

    - name: Delete Scratch Org
      if: always()
      run: sfdx force:org:delete -p -u scratch-org
```

---

## Common Issues

### Issue 1: CORS Error (Browser)

**Error:**
```
Access to fetch at 'https://...' from origin 'http://localhost:3000'
has been blocked by CORS policy
```

**Solution:**
- CORS settings in Setup → Security → CORS
- Add your domain to allowed origins
- Or use server-side proxy

---

### Issue 2: Invalid Session ID

**Error:**
```
{"message":"Session expired or invalid","errorCode":"INVALID_SESSION_ID"}
```

**Solution:**
- Get fresh access token
- Check token hasn't expired
- Verify Authorization header format

---

### Issue 3: Request Entity Too Large

**Error:**
```
HTTP 413 Request Entity Too Large
```

**Solution:**
- Reduce request body size
- Use batch API for bulk operations
- Split large requests

---

### Issue 4: Rate Limiting

**Error:**
```
HTTP 429 Too Many Requests
```

**Solution:**
- Implement exponential backoff
- Cache responses
- Use bulk operations

---

## Summary

You now know how to test REST APIs with:
✅ Postman (GUI, comprehensive)
✅ cURL (command line, scripting)
✅ Workbench (Salesforce-specific)
✅ JavaScript (browser/Node.js)
✅ Python (automation)
✅ CI/CD (automated testing)

**Next steps:**
1. Set up your own Postman collection
2. Write automated tests in Python
3. Add API tests to CI/CD pipeline
4. Monitor API performance in production

---

*For API concepts and architecture, see `REST_API_GUIDE.md`*

*For code reference, see `OrderRESTService.cls` and `OrderRESTServiceTest.cls`*
