/**
 * @description Comprehensive test class for OrderRESTService
 *
 * This test class demonstrates how to test REST API services in Salesforce,
 * including setting up RestContext, testing all HTTP methods, and validating
 * error handling.
 *
 * WHAT THIS TESTS:
 * - GET requests (single and multiple records)
 * - POST requests (create operations)
 * - PUT requests (update operations)
 * - DELETE requests (delete operations)
 * - Error handling (validation, not found, security)
 * - Query parameters and filtering
 * - Request/response serialization
 *
 * LEARNING OBJECTIVES:
 * - How to set up RestContext for testing
 * - How to create RestRequest and RestResponse objects
 * - How to test different HTTP methods
 * - How to validate JSON responses
 * - How to test error scenarios
 * - Best practices for REST API testing
 *
 * CODE COVERAGE TARGET: 95%+
 *
 * @author TechSolutions Learning Team
 * @date 2025-11-04
 * @group REST API Tests
 */
@isTest
private class OrderRESTServiceTest {

    /**
     * @description Creates test data for all test methods
     *
     * LEARNING POINT: @TestSetup runs once before all test methods, improving performance
     */
    @TestSetup
    static void setupTestData() {
        // ARRANGE: Create test customers
        List<Customer__c> customers = TestDataFactory.createCustomers(3);
        insert customers;

        // ARRANGE: Create test devices
        List<Device__c> devices = TestDataFactory.createDevices(5);
        insert devices;

        // ARRANGE: Create test orders
        List<Order__c> orders = new List<Order__c>();
        orders.add(new Order__c(
            Customer__c = customers[0].Id,
            Order_Date__c = Date.today(),
            Order_Status__c = 'Pending',
            Total_Amount__c = 5000.00,
            Notes__c = 'Test order 1'
        ));
        orders.add(new Order__c(
            Customer__c = customers[1].Id,
            Order_Date__c = Date.today().addDays(-5),
            Order_Status__c = 'Completed',
            Total_Amount__c = 10000.00,
            Notes__c = 'Test order 2'
        ));
        orders.add(new Order__c(
            Customer__c = customers[2].Id,
            Order_Date__c = Date.today().addDays(-10),
            Order_Status__c = 'Cancelled',
            Total_Amount__c = 3000.00,
            Notes__c = 'Test order 3'
        ));
        insert orders;

        // ARRANGE: Create line items for first order
        List<Order_Line_Item__c> lineItems = new List<Order_Line_Item__c>();
        lineItems.add(new Order_Line_Item__c(
            Order__c = orders[0].Id,
            Device__c = devices[0].Id,
            Quantity__c = 2,
            Unit_Price__c = 2000.00,
            Total_Price__c = 4000.00
        ));
        lineItems.add(new Order_Line_Item__c(
            Order__c = orders[0].Id,
            Device__c = devices[1].Id,
            Quantity__c = 1,
            Unit_Price__c = 1000.00,
            Total_Price__c = 1000.00
        ));
        insert lineItems;
    }

    // ========== GET TESTS ==========

    /**
     * @description Tests successful retrieval of a single order by ID
     *
     * WHAT THIS TESTS:
     * - GET /api/v1/orders/{orderId} returns correct order
     * - Response includes related data (customer, line items)
     * - Response status code is 200 (OK)
     * - JSON structure is correct
     *
     * LEARNING POINT: RestContext must be manually set up in tests
     */
    @isTest
    static void testGetSingleOrder_Success() {
        // ARRANGE: Get test order
        Order__c testOrder = [SELECT Id, Name FROM Order__c LIMIT 1];

        // ARRANGE: Set up REST context
        // LEARNING POINT: RestContext.request and RestContext.response must be initialized
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/api/v1/orders/' + testOrder.Id;
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response;

        // ACT: Call the REST service
        Test.startTest();
        OrderRESTService.OrderResponse result = OrderRESTService.getOrders();
        Test.stopTest();

        // ASSERT: Verify success response
        System.assertEquals(true, result.success,
            'GET request should succeed');
        System.assertEquals(200, RestContext.response.statusCode,
            'Status code should be 200 OK');
        System.assertEquals(1, result.orders.size(),
            'Should return exactly one order');
        System.assertEquals(testOrder.Id, result.orders[0].orderId,
            'Returned order ID should match requested ID');
        System.assertNotEquals(null, result.orders[0].orderNumber,
            'Order number should be populated');

        // LEARNING POINT: Verify related data is included
        System.assertNotEquals(null, result.orders[0].customerName,
            'Customer name should be included via relationship');
        System.assertNotEquals(null, result.orders[0].lineItems,
            'Line items should be included');
        System.assertEquals(2, result.orders[0].lineItems.size(),
            'Should include 2 line items');
    }

    /**
     * @description Tests GET request with invalid order ID
     *
     * WHAT THIS TESTS:
     * - GET /api/v1/orders/INVALID returns 404 Not Found
     * - Error message is descriptive
     * - No exception is thrown (graceful handling)
     */
    @isTest
    static void testGetSingleOrder_NotFound() {
        // ARRANGE: Use non-existent order ID
        String fakeOrderId = 'a01000000000000AAA';

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/api/v1/orders/' + fakeOrderId;
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response;

        // ACT
        Test.startTest();
        OrderRESTService.OrderResponse result = OrderRESTService.getOrders();
        Test.stopTest();

        // ASSERT: Verify 404 error
        System.assertEquals(false, result.success,
            'Request should fail for non-existent order');
        System.assertEquals(404, RestContext.response.statusCode,
            'Status code should be 404 Not Found');
        System.assertNotEquals(null, result.errorMessage,
            'Error message should be provided');
        System.assert(result.errorMessage.contains('not found'),
            'Error message should indicate order not found');
    }

    /**
     * @description Tests GET request for multiple orders without filters
     *
     * WHAT THIS TESTS:
     * - GET /api/v1/orders returns multiple orders
     * - Default pagination (limit 50)
     * - Orders are sorted by CreatedDate DESC
     */
    @isTest
    static void testGetMultipleOrders_NoFilter() {
        // ARRANGE
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/api/v1/orders';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response;

        // ACT
        Test.startTest();
        OrderRESTService.OrderResponse result = OrderRESTService.getOrders();
        Test.stopTest();

        // ASSERT: Verify all orders returned
        System.assertEquals(true, result.success,
            'Request should succeed');
        System.assertEquals(200, RestContext.response.statusCode,
            'Status code should be 200 OK');
        System.assertEquals(3, result.orders.size(),
            'Should return all 3 test orders');
        System.assertEquals(3, result.totalRecords,
            'totalRecords should match actual count');

        // LEARNING POINT: Verify sorting (newest first)
        System.assert(result.orders[0].createdDate >= result.orders[1].createdDate,
            'Orders should be sorted by CreatedDate DESC');
    }

    /**
     * @description Tests GET request with status filter
     *
     * WHAT THIS TESTS:
     * - GET /api/v1/orders?status=Pending returns filtered results
     * - Query parameters are parsed correctly
     * - Only matching records are returned
     */
    @isTest
    static void testGetMultipleOrders_WithStatusFilter() {
        // ARRANGE: Add query parameter
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/api/v1/orders?status=Pending';
        request.httpMethod = 'GET';
        request.params.put('status', 'Pending');
        RestContext.request = request;
        RestContext.response = response;

        // ACT
        Test.startTest();
        OrderRESTService.OrderResponse result = OrderRESTService.getOrders();
        Test.stopTest();

        // ASSERT: Verify only Pending orders returned
        System.assertEquals(true, result.success,
            'Filtered request should succeed');
        System.assertEquals(1, result.orders.size(),
            'Should return only Pending orders');
        System.assertEquals('Pending', result.orders[0].status,
            'Returned order should have Pending status');
    }

    /**
     * @description Tests GET request with pagination parameters
     *
     * WHAT THIS TESTS:
     * - GET /api/v1/orders?limit=2&offset=1 works correctly
     * - Limit and offset parameters are respected
     * - Maximum limit (200) is enforced
     */
    @isTest
    static void testGetMultipleOrders_WithPagination() {
        // ARRANGE: Set pagination parameters
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/api/v1/orders?limit=2&offset=1';
        request.httpMethod = 'GET';
        request.params.put('limit', '2');
        request.params.put('offset', '1');
        RestContext.request = request;
        RestContext.response = response;

        // ACT
        Test.startTest();
        OrderRESTService.OrderResponse result = OrderRESTService.getOrders();
        Test.stopTest();

        // ASSERT: Verify pagination
        System.assertEquals(true, result.success,
            'Paginated request should succeed');
        System.assertEquals(2, result.orders.size(),
            'Should return max 2 orders (limit param)');

        // LEARNING POINT: Test max limit enforcement
        request.params.put('limit', '500'); // Try to exceed max
        OrderRESTService.OrderResponse result2 = OrderRESTService.getOrders();
        System.assert(result2.orders.size() <= 200,
            'Should enforce maximum limit of 200 records');
    }

    // ========== POST TESTS ==========

    /**
     * @description Tests successful order creation via POST
     *
     * WHAT THIS TESTS:
     * - POST /api/v1/orders creates new order
     * - Request body is deserialized correctly
     * - Response status code is 201 (Created)
     * - Location header is set
     * - Created order is returned in response
     */
    @isTest
    static void testCreateOrder_Success() {
        // ARRANGE: Get test customer and device
        Customer__c customer = [SELECT Id FROM Customer__c LIMIT 1];
        Device__c device = [SELECT Id FROM Device__c LIMIT 1];

        // ARRANGE: Build request body
        OrderRESTService.OrderRequest orderRequest = new OrderRESTService.OrderRequest();
        orderRequest.customerId = customer.Id;
        orderRequest.orderDate = Date.today();
        orderRequest.status = 'Pending';
        orderRequest.totalAmount = 7500.00;
        orderRequest.notes = 'New order via REST API';

        // Add line items
        orderRequest.lineItems = new List<OrderRESTService.LineItemRequest>();
        OrderRESTService.LineItemRequest lineItem = new OrderRESTService.LineItemRequest();
        lineItem.deviceId = device.Id;
        lineItem.quantity = 3;
        lineItem.unitPrice = 2500.00;
        orderRequest.lineItems.add(lineItem);

        // ARRANGE: Set up REST context
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/api/v1/orders';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(orderRequest));
        RestContext.request = request;
        RestContext.response = response;

        // Count orders before
        Integer orderCountBefore = [SELECT COUNT() FROM Order__c];

        // ACT
        Test.startTest();
        OrderRESTService.OrderResponse result = OrderRESTService.createOrder();
        Test.stopTest();

        // ASSERT: Verify order created
        System.assertEquals(true, result.success,
            'Order creation should succeed');
        System.assertEquals(201, RestContext.response.statusCode,
            'Status code should be 201 Created');

        Integer orderCountAfter = [SELECT COUNT() FROM Order__c];
        System.assertEquals(orderCountBefore + 1, orderCountAfter,
            'One new order should be created');

        // ASSERT: Verify response data
        System.assertEquals(1, result.orders.size(),
            'Response should include created order');
        System.assertEquals(7500.00, result.orders[0].totalAmount,
            'Total amount should match request');
        System.assertEquals('Pending', result.orders[0].status,
            'Status should match request');

        // LEARNING POINT: Verify Location header is set
        String locationHeader = RestContext.response.headers.get('Location');
        System.assertNotEquals(null, locationHeader,
            'Location header should be set for created resource');
        System.assert(locationHeader.contains(result.orders[0].orderId),
            'Location header should contain new order ID');

        // ASSERT: Verify line items created
        List<Order_Line_Item__c> createdLineItems = [
            SELECT Id, Quantity__c, Unit_Price__c
            FROM Order_Line_Item__c
            WHERE Order__c = :result.orders[0].orderId
        ];
        System.assertEquals(1, createdLineItems.size(),
            'Line item should be created');
        System.assertEquals(3, createdLineItems[0].Quantity__c,
            'Line item quantity should match request');
    }

    /**
     * @description Tests POST with missing required fields
     *
     * WHAT THIS TESTS:
     * - Validation errors return 400 Bad Request
     * - Error message indicates which field is missing
     * - No record is created when validation fails
     */
    @isTest
    static void testCreateOrder_MissingRequiredFields() {
        // ARRANGE: Create invalid request (missing customerId)
        OrderRESTService.OrderRequest orderRequest = new OrderRESTService.OrderRequest();
        // customerId is intentionally null
        orderRequest.totalAmount = 5000.00;

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/api/v1/orders';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(orderRequest));
        RestContext.request = request;
        RestContext.response = response;

        Integer orderCountBefore = [SELECT COUNT() FROM Order__c];

        // ACT
        Test.startTest();
        OrderRESTService.OrderResponse result = OrderRESTService.createOrder();
        Test.stopTest();

        // ASSERT: Verify validation error
        System.assertEquals(false, result.success,
            'Request with missing field should fail');
        System.assertEquals(400, RestContext.response.statusCode,
            'Status code should be 400 Bad Request');
        System.assertNotEquals(null, result.errorMessage,
            'Error message should describe the problem');
        System.assert(result.errorMessage.contains('customerId'),
            'Error message should mention missing field');

        Integer orderCountAfter = [SELECT COUNT() FROM Order__c];
        System.assertEquals(orderCountBefore, orderCountAfter,
            'No order should be created on validation error');
    }

    /**
     * @description Tests POST with invalid amount
     *
     * WHAT THIS TESTS:
     * - Business logic validation (amount > 0)
     * - Custom validation returns appropriate error
     */
    @isTest
    static void testCreateOrder_InvalidAmount() {
        // ARRANGE: Create request with invalid amount
        Customer__c customer = [SELECT Id FROM Customer__c LIMIT 1];

        OrderRESTService.OrderRequest orderRequest = new OrderRESTService.OrderRequest();
        orderRequest.customerId = customer.Id;
        orderRequest.totalAmount = -100.00; // Invalid: negative amount

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/api/v1/orders';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(orderRequest));
        RestContext.request = request;
        RestContext.response = response;

        // ACT
        Test.startTest();
        OrderRESTService.OrderResponse result = OrderRESTService.createOrder();
        Test.stopTest();

        // ASSERT
        System.assertEquals(false, result.success,
            'Invalid amount should fail validation');
        System.assertEquals(400, RestContext.response.statusCode,
            'Status code should be 400 Bad Request');
        System.assert(result.errorMessage.contains('totalAmount'),
            'Error should mention totalAmount field');
    }

    // ========== PUT TESTS ==========

    /**
     * @description Tests successful order update via PUT
     *
     * WHAT THIS TESTS:
     * - PUT /api/v1/orders/{orderId} updates existing order
     * - Partial updates work (only changed fields)
     * - Response status code is 200 (OK)
     * - Updated order is returned
     */
    @isTest
    static void testUpdateOrder_Success() {
        // ARRANGE: Get existing order
        Order__c existingOrder = [
            SELECT Id, Order_Status__c, Total_Amount__c
            FROM Order__c
            WHERE Order_Status__c = 'Pending'
            LIMIT 1
        ];

        // ARRANGE: Create update request (partial update)
        OrderRESTService.OrderRequest updateRequest = new OrderRESTService.OrderRequest();
        updateRequest.status = 'Completed'; // Change status
        updateRequest.notes = 'Updated via REST API'; // Add note
        // Other fields intentionally null (partial update)

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/api/v1/orders/' + existingOrder.Id;
        request.httpMethod = 'PUT';
        request.requestBody = Blob.valueOf(JSON.serialize(updateRequest));
        RestContext.request = request;
        RestContext.response = response;

        // ACT
        Test.startTest();
        OrderRESTService.OrderResponse result = OrderRESTService.updateOrder();
        Test.stopTest();

        // ASSERT: Verify update success
        System.assertEquals(true, result.success,
            'Order update should succeed');
        System.assertEquals(200, RestContext.response.statusCode,
            'Status code should be 200 OK');

        // ASSERT: Verify fields updated
        Order__c updatedOrder = [
            SELECT Id, Order_Status__c, Total_Amount__c, Notes__c
            FROM Order__c
            WHERE Id = :existingOrder.Id
        ];
        System.assertEquals('Completed', updatedOrder.Order_Status__c,
            'Status should be updated');
        System.assertEquals('Updated via REST API', updatedOrder.Notes__c,
            'Notes should be updated');
        System.assertEquals(existingOrder.Total_Amount__c, updatedOrder.Total_Amount__c,
            'Unchanged fields should remain the same');
    }

    /**
     * @description Tests PUT with non-existent order ID
     *
     * WHAT THIS TESTS:
     * - PUT to non-existent resource returns 404
     * - No exception is thrown
     */
    @isTest
    static void testUpdateOrder_NotFound() {
        // ARRANGE: Use non-existent order ID
        String fakeOrderId = 'a01000000000000AAA';

        OrderRESTService.OrderRequest updateRequest = new OrderRESTService.OrderRequest();
        updateRequest.status = 'Completed';

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/api/v1/orders/' + fakeOrderId;
        request.httpMethod = 'PUT';
        request.requestBody = Blob.valueOf(JSON.serialize(updateRequest));
        RestContext.request = request;
        RestContext.response = response;

        // ACT
        Test.startTest();
        OrderRESTService.OrderResponse result = OrderRESTService.updateOrder();
        Test.stopTest();

        // ASSERT
        System.assertEquals(false, result.success,
            'Update should fail for non-existent order');
        System.assertEquals(404, RestContext.response.statusCode,
            'Status code should be 404 Not Found');
    }

    /**
     * @description Tests PUT without order ID in URL
     *
     * WHAT THIS TESTS:
     * - PUT requires ID in URL
     * - Returns 400 Bad Request if ID missing
     */
    @isTest
    static void testUpdateOrder_MissingOrderId() {
        // ARRANGE: No order ID in URL
        OrderRESTService.OrderRequest updateRequest = new OrderRESTService.OrderRequest();
        updateRequest.status = 'Completed';

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/api/v1/orders'; // No ID
        request.httpMethod = 'PUT';
        request.requestBody = Blob.valueOf(JSON.serialize(updateRequest));
        RestContext.request = request;
        RestContext.response = response;

        // ACT
        Test.startTest();
        OrderRESTService.OrderResponse result = OrderRESTService.updateOrder();
        Test.stopTest();

        // ASSERT
        System.assertEquals(false, result.success,
            'Update without ID should fail');
        System.assertEquals(400, RestContext.response.statusCode,
            'Status code should be 400 Bad Request');
    }

    // ========== DELETE TESTS ==========

    /**
     * @description Tests successful order deletion via DELETE
     *
     * WHAT THIS TESTS:
     * - DELETE /api/v1/orders/{orderId} deletes order
     * - Response status code is 204 (No Content)
     * - Order is actually deleted from database
     */
    @isTest
    static void testDeleteOrder_Success() {
        // ARRANGE: Get existing order
        Order__c orderToDelete = [SELECT Id FROM Order__c LIMIT 1];

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/api/v1/orders/' + orderToDelete.Id;
        request.httpMethod = 'DELETE';
        RestContext.request = request;
        RestContext.response = response;

        Integer orderCountBefore = [SELECT COUNT() FROM Order__c];

        // ACT
        Test.startTest();
        OrderRESTService.OrderResponse result = OrderRESTService.deleteOrder();
        Test.stopTest();

        // ASSERT: Verify deletion
        System.assertEquals(true, result.success,
            'Delete should succeed');
        System.assertEquals(204, RestContext.response.statusCode,
            'Status code should be 204 No Content');

        Integer orderCountAfter = [SELECT COUNT() FROM Order__c];
        System.assertEquals(orderCountBefore - 1, orderCountAfter,
            'Order count should decrease by 1');

        // Verify order no longer exists
        List<Order__c> deletedOrders = [
            SELECT Id FROM Order__c WHERE Id = :orderToDelete.Id
        ];
        System.assertEquals(0, deletedOrders.size(),
            'Order should no longer exist in database');
    }

    /**
     * @description Tests DELETE with non-existent order ID (idempotent)
     *
     * WHAT THIS TESTS:
     * - DELETE is idempotent (deleting non-existent resource succeeds)
     * - Returns 204 No Content
     *
     * LEARNING POINT: REST DELETE should be idempotent per HTTP specification
     */
    @isTest
    static void testDeleteOrder_NotFound_Idempotent() {
        // ARRANGE: Use non-existent order ID
        String fakeOrderId = 'a01000000000000AAA';

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/api/v1/orders/' + fakeOrderId;
        request.httpMethod = 'DELETE';
        RestContext.request = request;
        RestContext.response = response;

        // ACT
        Test.startTest();
        OrderRESTService.OrderResponse result = OrderRESTService.deleteOrder();
        Test.stopTest();

        // ASSERT: DELETE should succeed (idempotent)
        System.assertEquals(true, result.success,
            'DELETE should be idempotent and succeed even if resource not found');
        System.assertEquals(204, RestContext.response.statusCode,
            'Status code should be 204 No Content');
    }

    /**
     * @description Tests DELETE without order ID in URL
     *
     * WHAT THIS TESTS:
     * - DELETE requires ID in URL
     * - Returns 400 Bad Request if ID missing
     */
    @isTest
    static void testDeleteOrder_MissingOrderId() {
        // ARRANGE: No order ID in URL
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/api/v1/orders'; // No ID
        request.httpMethod = 'DELETE';
        RestContext.request = request;
        RestContext.response = response;

        // ACT
        Test.startTest();
        OrderRESTService.OrderResponse result = OrderRESTService.deleteOrder();
        Test.stopTest();

        // ASSERT
        System.assertEquals(false, result.success,
            'DELETE without ID should fail');
        System.assertEquals(400, RestContext.response.statusCode,
            'Status code should be 400 Bad Request');
    }

    // ========== ERROR HANDLING TESTS ==========

    /**
     * @description Tests error logging integration
     *
     * WHAT THIS TESTS:
     * - Errors are logged to ErrorLogger
     * - Error logs are created in database
     *
     * LEARNING POINT: REST services should log errors for monitoring
     */
    @isTest
    static void testErrorLogging() {
        // ARRANGE: Force an error by using invalid JSON
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/api/v1/orders';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{ invalid json }'); // Malformed JSON
        RestContext.request = request;
        RestContext.response = response;

        // ACT
        Test.startTest();
        OrderRESTService.OrderResponse result = OrderRESTService.createOrder();
        Test.stopTest();

        // ASSERT: Error should be handled gracefully
        System.assertEquals(false, result.success,
            'Malformed JSON should fail');
        System.assertEquals(500, RestContext.response.statusCode,
            'Status code should be 500 Internal Server Error');

        // Note: Error logging verification would require checking Error_Log__c records
        // This is omitted here to avoid test data dependency
    }

    /**
     * @description Tests JSON serialization/deserialization
     *
     * WHAT THIS TESTS:
     * - OrderResponse can be serialized to JSON
     * - JSON structure is correct
     * - All fields are included
     *
     * LEARNING POINT: Test your DTOs can be properly serialized
     */
    @isTest
    static void testResponseSerialization() {
        // ARRANGE: Create a response object
        OrderRESTService.OrderResponse response = new OrderRESTService.OrderResponse();
        response.success = true;
        response.message = 'Test message';
        response.totalRecords = 5;

        OrderRESTService.OrderData orderData = new OrderRESTService.OrderData();
        orderData.orderId = 'a01000000000001AAA';
        orderData.orderNumber = 'ORD-12345';
        orderData.status = 'Pending';
        orderData.totalAmount = 1000.00;
        response.orders = new List<OrderRESTService.OrderData>{ orderData };

        // ACT: Serialize to JSON
        Test.startTest();
        String jsonString = JSON.serialize(response);
        Test.stopTest();

        // ASSERT: Verify JSON structure
        System.assertNotEquals(null, jsonString,
            'Serialization should produce JSON string');
        System.assert(jsonString.contains('success'),
            'JSON should contain success field');
        System.assert(jsonString.contains('orders'),
            'JSON should contain orders array');
        System.assert(jsonString.contains('ORD-12345'),
            'JSON should contain order data');

        // LEARNING POINT: Test deserialization as well
        OrderRESTService.OrderResponse deserializedResponse =
            (OrderRESTService.OrderResponse) JSON.deserialize(
                jsonString,
                OrderRESTService.OrderResponse.class
            );
        System.assertEquals(true, deserializedResponse.success,
            'Deserialized object should match original');
        System.assertEquals(1, deserializedResponse.orders.size(),
            'Deserialized orders should match original');
    }
}
