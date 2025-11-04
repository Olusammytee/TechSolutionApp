/**
 * @description REST API Service for Order Management
 *
 * This class exposes the Order system as a RESTful API, allowing external systems
 * to perform CRUD operations on orders. This is a production-ready implementation
 * demonstrating enterprise REST API patterns in Salesforce.
 *
 * LEARNING OBJECTIVES:
 * - Understand @RestResource annotation and URL mapping
 * - Learn HTTP method decorators (@HttpGet, @HttpPost, @HttpPut, @HttpDelete)
 * - Master RestRequest and RestResponse objects
 * - Implement proper error handling with HTTP status codes
 * - Apply security best practices (FLS, CRUD, sharing)
 * - Serialize/deserialize JSON for API communication
 *
 * API ENDPOINT: /services/apexrest/api/v1/orders/*
 *
 * SUPPORTED OPERATIONS:
 * - GET    /api/v1/orders/:orderId        - Retrieve a single order
 * - GET    /api/v1/orders?status=Pending  - Retrieve orders with filters
 * - POST   /api/v1/orders                 - Create a new order
 * - PUT    /api/v1/orders/:orderId        - Update an existing order
 * - DELETE /api/v1/orders/:orderId        - Delete an order
 *
 * EXAMPLE USAGE (with cURL):
 * ```bash
 * # Get order by ID
 * curl https://yourinstance.salesforce.com/services/apexrest/api/v1/orders/a015g00000XXXXX \
 *   -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
 *
 * # Create order
 * curl -X POST https://yourinstance.salesforce.com/services/apexrest/api/v1/orders \
 *   -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
 *   -H "Content-Type: application/json" \
 *   -d '{"customerName":"Acme Corp","totalAmount":5000,"status":"Pending"}'
 * ```
 *
 * @author TechSolutions Learning Team
 * @date 2025-11-04
 * @group REST API Services
 */
@RestResource(urlMapping='/api/v1/orders/*')
global with sharing class OrderRESTService {

    /**
     * @description Retrieves order(s) based on URL parameters
     *
     * LEARNING POINT: @HttpGet handles GET requests. The method is static and must return data.
     * RestContext provides access to the request/response objects.
     *
     * URL PATTERNS:
     * - /api/v1/orders/a015g00000XXXXX  → Returns single order
     * - /api/v1/orders?status=Pending   → Returns filtered orders
     * - /api/v1/orders                  → Returns all orders (paginated)
     *
     * QUERY PARAMETERS:
     * - status: Filter by Order_Status__c (e.g., Pending, Completed, Cancelled)
     * - limit: Max records to return (default: 50, max: 200)
     * - offset: Skip N records for pagination (default: 0)
     *
     * @return OrderResponse containing order data or error details
     */
    @HttpGet
    global static OrderResponse getOrders() {
        OrderResponse response = new OrderResponse();

        try {
            // STEP 1: Access the REST context
            // RestContext is a global variable providing request/response access
            RestRequest request = RestContext.request;
            RestResponse restResponse = RestContext.response;

            // STEP 2: Extract order ID from URL if present
            // URL format: /api/v1/orders/{orderId}
            String orderId = extractOrderIdFromUrl(request.requestURI);

            if (String.isNotBlank(orderId)) {
                // Single order retrieval by ID
                return getSingleOrder(orderId, restResponse);
            } else {
                // Multiple orders with optional filters
                return getMultipleOrders(request, restResponse);
            }

        } catch (Exception e) {
            // LEARNING POINT: Always catch exceptions and return proper HTTP status codes
            return handleException(e, RestContext.response);
        }
    }

    /**
     * @description Creates a new order from JSON request body
     *
     * LEARNING POINT: @HttpPost handles POST requests for creating resources.
     * The request body is automatically available via RestContext.request.requestBody
     *
     * REQUEST BODY EXAMPLE:
     * {
     *   "customerName": "Acme Corporation",
     *   "customerId": "a015g00000XXXXX",
     *   "orderDate": "2025-11-04",
     *   "totalAmount": 15000.00,
     *   "status": "Pending",
     *   "lineItems": [
     *     {
     *       "deviceId": "a015g00000YYYYY",
     *       "quantity": 5,
     *       "unitPrice": 3000.00
     *     }
     *   ]
     * }
     *
     * @return OrderResponse with created order details or error
     */
    @HttpPost
    global static OrderResponse createOrder() {
        OrderResponse response = new OrderResponse();

        try {
            RestRequest request = RestContext.request;
            RestResponse restResponse = RestContext.response;

            // STEP 1: Parse JSON request body
            // LEARNING POINT: Use JSON.deserialize() to convert JSON to Apex objects
            String requestBody = request.requestBody.toString();
            OrderRequest orderRequest = (OrderRequest) JSON.deserialize(
                requestBody,
                OrderRequest.class
            );

            // STEP 2: Validate required fields
            if (!validateOrderRequest(orderRequest, response)) {
                restResponse.statusCode = 400; // Bad Request
                return response;
            }

            // STEP 3: Create Order__c record
            Order__c newOrder = new Order__c(
                Customer__c = orderRequest.customerId,
                Order_Date__c = orderRequest.orderDate != null ?
                    orderRequest.orderDate : Date.today(),
                Order_Status__c = orderRequest.status != null ?
                    orderRequest.status : 'Pending',
                Total_Amount__c = orderRequest.totalAmount,
                Notes__c = orderRequest.notes
            );

            // STEP 4: Check CRUD permissions before DML
            // LEARNING POINT: Always enforce security (CRUD/FLS) in REST services
            if (!Schema.sObjectType.Order__c.isCreateable()) {
                response.success = false;
                response.errorMessage = 'Insufficient permissions to create orders';
                restResponse.statusCode = 403; // Forbidden
                return response;
            }

            // STEP 5: Insert the order
            insert newOrder;

            // STEP 6: Handle line items if provided
            if (orderRequest.lineItems != null && !orderRequest.lineItems.isEmpty()) {
                createLineItems(newOrder.Id, orderRequest.lineItems);
            }

            // STEP 7: Query back the created order with all fields
            Order__c createdOrder = [
                SELECT Id, Name, Customer__c, Customer__r.Name, Order_Date__c,
                       Order_Status__c, Total_Amount__c, Notes__c,
                       CreatedDate, CreatedBy.Name
                FROM Order__c
                WHERE Id = :newOrder.Id
                LIMIT 1
            ];

            // STEP 8: Build successful response
            response.success = true;
            response.message = 'Order created successfully';
            response.orders = new List<OrderData>{ mapOrderToData(createdOrder) };
            restResponse.statusCode = 201; // Created

            // LEARNING POINT: Set Location header for newly created resource
            restResponse.addHeader('Location',
                '/services/apexrest/api/v1/orders/' + createdOrder.Id);

            return response;

        } catch (DmlException e) {
            return handleDmlException(e, RestContext.response);
        } catch (Exception e) {
            return handleException(e, RestContext.response);
        }
    }

    /**
     * @description Updates an existing order
     *
     * LEARNING POINT: @HttpPut handles PUT requests for updating resources.
     * PUT is idempotent - calling it multiple times has the same effect as calling once.
     *
     * URL: /api/v1/orders/{orderId}
     *
     * REQUEST BODY: Same structure as POST, only include fields to update
     *
     * @return OrderResponse with updated order or error
     */
    @HttpPut
    global static OrderResponse updateOrder() {
        OrderResponse response = new OrderResponse();

        try {
            RestRequest request = RestContext.request;
            RestResponse restResponse = RestContext.response;

            // STEP 1: Extract order ID from URL
            String orderId = extractOrderIdFromUrl(request.requestURI);

            if (String.isBlank(orderId)) {
                response.success = false;
                response.errorMessage = 'Order ID is required in URL';
                restResponse.statusCode = 400; // Bad Request
                return response;
            }

            // STEP 2: Check if order exists
            List<Order__c> existingOrders = [
                SELECT Id, Customer__c, Order_Date__c, Order_Status__c,
                       Total_Amount__c, Notes__c
                FROM Order__c
                WHERE Id = :orderId
                LIMIT 1
            ];

            if (existingOrders.isEmpty()) {
                response.success = false;
                response.errorMessage = 'Order not found';
                restResponse.statusCode = 404; // Not Found
                return response;
            }

            Order__c orderToUpdate = existingOrders[0];

            // STEP 3: Parse request body
            String requestBody = request.requestBody.toString();
            OrderRequest orderRequest = (OrderRequest) JSON.deserialize(
                requestBody,
                OrderRequest.class
            );

            // STEP 4: Update only provided fields (partial update support)
            // LEARNING POINT: PUT can support partial updates by checking for nulls
            if (orderRequest.customerId != null) {
                orderToUpdate.Customer__c = orderRequest.customerId;
            }
            if (orderRequest.orderDate != null) {
                orderToUpdate.Order_Date__c = orderRequest.orderDate;
            }
            if (orderRequest.status != null) {
                orderToUpdate.Order_Status__c = orderRequest.status;
            }
            if (orderRequest.totalAmount != null) {
                orderToUpdate.Total_Amount__c = orderRequest.totalAmount;
            }
            if (orderRequest.notes != null) {
                orderToUpdate.Notes__c = orderRequest.notes;
            }

            // STEP 5: Check update permissions
            if (!Schema.sObjectType.Order__c.isUpdateable()) {
                response.success = false;
                response.errorMessage = 'Insufficient permissions to update orders';
                restResponse.statusCode = 403; // Forbidden
                return response;
            }

            // STEP 6: Update the order
            update orderToUpdate;

            // STEP 7: Query updated order
            Order__c updatedOrder = [
                SELECT Id, Name, Customer__c, Customer__r.Name, Order_Date__c,
                       Order_Status__c, Total_Amount__c, Notes__c,
                       LastModifiedDate, LastModifiedBy.Name
                FROM Order__c
                WHERE Id = :orderId
                LIMIT 1
            ];

            response.success = true;
            response.message = 'Order updated successfully';
            response.orders = new List<OrderData>{ mapOrderToData(updatedOrder) };
            restResponse.statusCode = 200; // OK

            return response;

        } catch (DmlException e) {
            return handleDmlException(e, RestContext.response);
        } catch (Exception e) {
            return handleException(e, RestContext.response);
        }
    }

    /**
     * @description Deletes an order
     *
     * LEARNING POINT: @HttpDelete handles DELETE requests.
     * DELETE should be idempotent - deleting a non-existent resource returns success.
     *
     * URL: /api/v1/orders/{orderId}
     *
     * @return OrderResponse with success/error status
     */
    @HttpDelete
    global static OrderResponse deleteOrder() {
        OrderResponse response = new OrderResponse();

        try {
            RestRequest request = RestContext.request;
            RestResponse restResponse = RestContext.response;

            // STEP 1: Extract order ID from URL
            String orderId = extractOrderIdFromUrl(request.requestURI);

            if (String.isBlank(orderId)) {
                response.success = false;
                response.errorMessage = 'Order ID is required in URL';
                restResponse.statusCode = 400; // Bad Request
                return response;
            }

            // STEP 2: Query order to delete
            List<Order__c> ordersToDelete = [
                SELECT Id, Name
                FROM Order__c
                WHERE Id = :orderId
                LIMIT 1
            ];

            if (ordersToDelete.isEmpty()) {
                // LEARNING POINT: Idempotent DELETE - return success even if not found
                response.success = true;
                response.message = 'Order does not exist or was already deleted';
                restResponse.statusCode = 204; // No Content
                return response;
            }

            // STEP 3: Check delete permissions
            if (!Schema.sObjectType.Order__c.isDeletable()) {
                response.success = false;
                response.errorMessage = 'Insufficient permissions to delete orders';
                restResponse.statusCode = 403; // Forbidden
                return response;
            }

            // STEP 4: Delete the order
            delete ordersToDelete[0];

            response.success = true;
            response.message = 'Order deleted successfully';
            restResponse.statusCode = 204; // No Content

            return response;

        } catch (DmlException e) {
            return handleDmlException(e, RestContext.response);
        } catch (Exception e) {
            return handleException(e, RestContext.response);
        }
    }

    // ========== PRIVATE HELPER METHODS ==========

    /**
     * @description Extracts order ID from URL path
     * Example: /api/v1/orders/a015g00000XXXXX → returns a015g00000XXXXX
     */
    private static String extractOrderIdFromUrl(String requestUri) {
        if (String.isBlank(requestUri)) {
            return null;
        }

        // Split URL by '/' and get the last segment
        String[] urlParts = requestUri.split('/');
        String lastSegment = urlParts[urlParts.size() - 1];

        // Check if it looks like a Salesforce ID (15 or 18 chars)
        if (lastSegment.length() == 15 || lastSegment.length() == 18) {
            return lastSegment;
        }

        return null;
    }

    /**
     * @description Retrieves a single order by ID
     */
    private static OrderResponse getSingleOrder(String orderId, RestResponse restResponse) {
        OrderResponse response = new OrderResponse();

        try {
            List<Order__c> orders = [
                SELECT Id, Name, Customer__c, Customer__r.Name, Order_Date__c,
                       Order_Status__c, Total_Amount__c, Notes__c,
                       CreatedDate, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name,
                       (SELECT Id, Name, Device__c, Device__r.Name, Quantity__c,
                               Unit_Price__c, Total_Price__c
                        FROM Order_Line_Items__r
                        LIMIT 100)
                FROM Order__c
                WHERE Id = :orderId
                LIMIT 1
            ];

            if (orders.isEmpty()) {
                response.success = false;
                response.errorMessage = 'Order not found';
                restResponse.statusCode = 404; // Not Found
                return response;
            }

            response.success = true;
            response.orders = new List<OrderData>{ mapOrderToData(orders[0]) };
            restResponse.statusCode = 200; // OK

        } catch (QueryException e) {
            response.success = false;
            response.errorMessage = 'Invalid order ID format';
            restResponse.statusCode = 400; // Bad Request
        }

        return response;
    }

    /**
     * @description Retrieves multiple orders with optional filters
     */
    private static OrderResponse getMultipleOrders(RestRequest request, RestResponse restResponse) {
        OrderResponse response = new OrderResponse();

        // Extract query parameters
        Map<String, String> params = request.params;
        String statusFilter = params.get('status');
        Integer limitParam = params.containsKey('limit') ?
            Integer.valueOf(params.get('limit')) : 50;
        Integer offsetParam = params.containsKey('offset') ?
            Integer.valueOf(params.get('offset')) : 0;

        // Enforce max limit
        limitParam = Math.min(limitParam, 200);

        // Build dynamic SOQL
        String query = 'SELECT Id, Name, Customer__c, Customer__r.Name, Order_Date__c, ' +
                       'Order_Status__c, Total_Amount__c, Notes__c, ' +
                       'CreatedDate, LastModifiedDate ' +
                       'FROM Order__c ';

        if (String.isNotBlank(statusFilter)) {
            query += 'WHERE Order_Status__c = :statusFilter ';
        }

        query += 'ORDER BY CreatedDate DESC ' +
                 'LIMIT :limitParam OFFSET :offsetParam';

        List<Order__c> orders = Database.query(query);

        List<OrderData> orderDataList = new List<OrderData>();
        for (Order__c order : orders) {
            orderDataList.add(mapOrderToData(order));
        }

        response.success = true;
        response.orders = orderDataList;
        response.totalRecords = orders.size();
        restResponse.statusCode = 200; // OK

        return response;
    }

    /**
     * @description Creates line items for an order
     */
    private static void createLineItems(Id orderId, List<LineItemRequest> lineItemRequests) {
        List<Order_Line_Item__c> lineItems = new List<Order_Line_Item__c>();

        for (LineItemRequest itemReq : lineItemRequests) {
            lineItems.add(new Order_Line_Item__c(
                Order__c = orderId,
                Device__c = itemReq.deviceId,
                Quantity__c = itemReq.quantity,
                Unit_Price__c = itemReq.unitPrice,
                Total_Price__c = itemReq.quantity * itemReq.unitPrice
            ));
        }

        if (!lineItems.isEmpty()) {
            insert lineItems;
        }
    }

    /**
     * @description Validates order request data
     */
    private static Boolean validateOrderRequest(OrderRequest orderRequest, OrderResponse response) {
        if (String.isBlank(orderRequest.customerId)) {
            response.success = false;
            response.errorMessage = 'customerId is required';
            return false;
        }

        if (orderRequest.totalAmount == null || orderRequest.totalAmount <= 0) {
            response.success = false;
            response.errorMessage = 'totalAmount must be greater than 0';
            return false;
        }

        return true;
    }

    /**
     * @description Maps Order__c to OrderData DTO
     */
    private static OrderData mapOrderToData(Order__c order) {
        OrderData data = new OrderData();
        data.orderId = order.Id;
        data.orderNumber = order.Name;
        data.customerId = order.Customer__c;
        data.customerName = order.Customer__r?.Name;
        data.orderDate = order.Order_Date__c;
        data.status = order.Order_Status__c;
        data.totalAmount = order.Total_Amount__c;
        data.notes = order.Notes__c;
        data.createdDate = order.CreatedDate;
        data.lastModifiedDate = order.LastModifiedDate;

        // Map line items if available
        if (order.Order_Line_Items__r != null) {
            data.lineItems = new List<LineItemData>();
            for (Order_Line_Item__c item : order.Order_Line_Items__r) {
                LineItemData itemData = new LineItemData();
                itemData.lineItemId = item.Id;
                itemData.deviceId = item.Device__c;
                itemData.deviceName = item.Device__r?.Name;
                itemData.quantity = item.Quantity__c;
                itemData.unitPrice = item.Unit_Price__c;
                itemData.totalPrice = item.Total_Price__c;
                data.lineItems.add(itemData);
            }
        }

        return data;
    }

    /**
     * @description Handles DML exceptions with specific error details
     */
    private static OrderResponse handleDmlException(DmlException e, RestResponse restResponse) {
        OrderResponse response = new OrderResponse();
        response.success = false;
        response.errorMessage = e.getDmlMessage(0);
        response.errorDetails = 'DML Error on field: ' + e.getDmlFieldNames(0);
        restResponse.statusCode = 400; // Bad Request

        // Log error for monitoring
        ErrorLogger.logError('OrderRESTService', 'DML Operation', e);

        return response;
    }

    /**
     * @description Handles general exceptions
     */
    private static OrderResponse handleException(Exception e, RestResponse restResponse) {
        OrderResponse response = new OrderResponse();
        response.success = false;
        response.errorMessage = e.getMessage();
        response.errorDetails = e.getStackTraceString();
        restResponse.statusCode = 500; // Internal Server Error

        // Log error for monitoring
        ErrorLogger.logError('OrderRESTService', 'REST Operation', e);

        return response;
    }

    // ========== INNER CLASSES (DTOs) ==========

    /**
     * @description Standard API response wrapper
     * LEARNING POINT: Always use consistent response structure for APIs
     */
    global class OrderResponse {
        global Boolean success;
        global String message;
        global String errorMessage;
        global String errorDetails;
        global List<OrderData> orders;
        global Integer totalRecords;

        global OrderResponse() {
            this.success = false;
            this.orders = new List<OrderData>();
        }
    }

    /**
     * @description Order data transfer object
     */
    global class OrderData {
        global String orderId;
        global String orderNumber;
        global String customerId;
        global String customerName;
        global Date orderDate;
        global String status;
        global Decimal totalAmount;
        global String notes;
        global DateTime createdDate;
        global DateTime lastModifiedDate;
        global List<LineItemData> lineItems;
    }

    /**
     * @description Line item data transfer object
     */
    global class LineItemData {
        global String lineItemId;
        global String deviceId;
        global String deviceName;
        global Decimal quantity;
        global Decimal unitPrice;
        global Decimal totalPrice;
    }

    /**
     * @description Request body structure for creating/updating orders
     */
    global class OrderRequest {
        global String customerId;
        global Date orderDate;
        global String status;
        global Decimal totalAmount;
        global String notes;
        global List<LineItemRequest> lineItems;
    }

    /**
     * @description Line item request structure
     */
    global class LineItemRequest {
        global String deviceId;
        global Decimal quantity;
        global Decimal unitPrice;
    }
}
