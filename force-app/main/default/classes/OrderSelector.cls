/**
 * OrderSelector - Apex selector pattern for Order__c and Order_Line_Item__c queries
 * Provides centralized, optimized SOQL queries with proper security enforcement
 * Optimized for Lightning Web Component dashboard consumption
 */
public with sharing class OrderSelector {
    
    // Standard field sets for different use cases
    private static final String ORDER_BASIC_FIELDS = 'Id, Name, Customer__c, Order_Date__c, Order_Status__c, Priority__c';
    private static final String ORDER_FINANCIAL_FIELDS = 'Id, Name, Subtotal__c, Tax_Amount__c, Total_Amount__c, Line_Item_Count__c';
    private static final String ORDER_ANALYTICS_FIELDS = 'Id, Name, Customer__c, Customer__r.Name, Customer__r.Customer_Type__c, Order_Date__c, Order_Status__c, Priority__c, Total_Amount__c, Line_Item_Count__c';
    
    /**
     * Select orders by IDs with basic information
     * @param orderIds Set of Order record IDs
     * @return List of Order__c records
     */
    public static List<Order__c> selectById(Set<Id> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            return new List<Order__c>();
        }
        
        return Database.query(
            'SELECT ' + ORDER_BASIC_FIELDS + ', Expected_Delivery_Date__c ' +
            'FROM Order__c ' +
            'WHERE Id IN :orderIds ' +
            'WITH SECURITY_ENFORCED'
        );
    }
    
    /**
     * Select orders with financial information
     * @param orderIds Set of Order record IDs
     * @return List of Order__c records with financial fields
     */
    public static List<Order__c> selectFinancialById(Set<Id> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            return new List<Order__c>();
        }
        
        return Database.query(
            'SELECT ' + ORDER_BASIC_FIELDS + ', ' + ORDER_FINANCIAL_FIELDS.replace('Id, Name, ', '') + 
            ', Tax_Rate__c, Shipping_Cost__c, Order_Discount_Percentage__c ' +
            'FROM Order__c ' +
            'WHERE Id IN :orderIds ' +
            'WITH SECURITY_ENFORCED'
        );
    }
    
    /**
     * Select orders by customer for relationship analysis
     * @param customerIds Set of Customer record IDs
     * @return List of Order__c records for specified customers
     */
    public static List<Order__c> selectByCustomer(Set<Id> customerIds) {
        if (customerIds == null || customerIds.isEmpty()) {
            return new List<Order__c>();
        }
        
        return Database.query(
            'SELECT ' + ORDER_ANALYTICS_FIELDS + ', Expected_Delivery_Date__c ' +
            'FROM Order__c ' +
            'WHERE Customer__c IN :customerIds ' +
            'WITH SECURITY_ENFORCED ' +
            'ORDER BY Order_Date__c DESC'
        );
    }
    
    /**
     * Select orders for dashboard analytics with date range
     * @param startDate Start date for analytics period
     * @param endDate End date for analytics period
     * @return List of Order__c records for dashboard display
     */
    public static List<Order__c> selectForDashboard(Date startDate, Date endDate) {
        return Database.query(
            'SELECT ' + ORDER_ANALYTICS_FIELDS + ', Expected_Delivery_Date__c ' +
            'FROM Order__c ' +
            'WHERE Order_Date__c >= :startDate AND Order_Date__c <= :endDate ' +
            'WITH SECURITY_ENFORCED ' +
            'ORDER BY Order_Date__c DESC'
        );
    }
    
    /**
     * Select high priority orders for operational focus
     * @return List of Order__c records with high priority
     */
    public static List<Order__c> selectHighPriority() {
        return Database.query(
            'SELECT ' + ORDER_ANALYTICS_FIELDS + ', Expected_Delivery_Date__c ' +
            'FROM Order__c ' +
            'WHERE Priority__c IN (\'Critical\', \'High\') ' +
            'AND Order_Status__c NOT IN (\'Delivered\', \'Cancelled\') ' +
            'WITH SECURITY_ENFORCED ' +
            'ORDER BY Priority__c ASC, Order_Date__c ASC'
        );
    }
    
    /**
     * Select pending orders for processing workflow
     * @return List of Order__c records with pending status
     */
    public static List<Order__c> selectPending() {
        return Database.query(
            'SELECT ' + ORDER_ANALYTICS_FIELDS + ', Expected_Delivery_Date__c ' +
            'FROM Order__c ' +
            'WHERE Order_Status__c IN (\'Pending\', \'Confirmed\') ' +
            'WITH SECURITY_ENFORCED ' +
            'ORDER BY Priority__c ASC, Order_Date__c ASC'
        );
    }
    
    /**
     * Select orders with line items for detailed analysis
     * @param orderIds Set of Order record IDs
     * @return List of Order__c records with related line items
     */
    public static List<Order__c> selectWithLineItems(Set<Id> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            return new List<Order__c>();
        }
        
        return Database.query(
            'SELECT ' + ORDER_ANALYTICS_FIELDS + ', ' +
            '(SELECT Id, Name, Line_Number__c, Device__c, Device__r.Name, Device__r.Type__c, ' +
            'Product_Name__c, Quantity__c, Unit_Price__c, Line_Discount_Percentage__c, ' +
            'Line_Total__c, Line_Profit_Margin__c, Stock_Available__c ' +
            'FROM Order_Line_Items__r ORDER BY Line_Number__c ASC) ' +
            'FROM Order__c ' +
            'WHERE Id IN :orderIds ' +
            'WITH SECURITY_ENFORCED'
        );
    }
    
    /**
     * Select order line items by order IDs
     * @param orderIds Set of Order record IDs
     * @return List of Order_Line_Item__c records
     */
    public static List<Order_Line_Item__c> selectLineItemsByOrder(Set<Id> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            return new List<Order_Line_Item__c>();
        }
        
        return Database.query(
            'SELECT Id, Name, Order__c, Line_Number__c, Device__c, Device__r.Name, Device__r.Type__c, ' +
            'Product_Name__c, Quantity__c, Unit_Price__c, Line_Discount_Percentage__c, ' +
            'Line_Discount_Amount__c, Line_Total__c, Line_Profit_Margin__c, Stock_Available__c ' +
            'FROM Order_Line_Item__c ' +
            'WHERE Order__c IN :orderIds ' +
            'WITH SECURITY_ENFORCED ' +
            'ORDER BY Order__c ASC, Line_Number__c ASC'
        );
    }
    
    /**
     * Select line items by device for inventory impact analysis
     * @param deviceIds Set of Device record IDs
     * @return List of Order_Line_Item__c records for specified devices
     */
    public static List<Order_Line_Item__c> selectLineItemsByDevice(Set<Id> deviceIds) {
        if (deviceIds == null || deviceIds.isEmpty()) {
            return new List<Order_Line_Item__c>();
        }
        
        return Database.query(
            'SELECT Id, Name, Order__c, Order__r.Order_Status__c, Order__r.Order_Date__c, ' +
            'Device__c, Device__r.Name, Quantity__c, Line_Total__c ' +
            'FROM Order_Line_Item__c ' +
            'WHERE Device__c IN :deviceIds ' +
            'AND Order__r.Order_Status__c IN (\'Pending\', \'Confirmed\', \'Processing\') ' +
            'WITH SECURITY_ENFORCED ' +
            'ORDER BY Device__c ASC, Order__r.Order_Date__c DESC'
        );
    }
    
    /**
     * Get order analytics aggregations for dashboard
     * @param startDate Start date for analytics period
     * @param endDate End date for analytics period
     * @return List of AggregateResult for order analytics
     */
    public static List<AggregateResult> getOrderAnalytics(Date startDate, Date endDate) {
        return Database.query(
            'SELECT Order_Status__c status, Priority__c priority, ' +
            'COUNT(Id) orderCount, SUM(Total_Amount__c) totalRevenue, ' +
            'AVG(Total_Amount__c) avgOrderValue, SUM(Line_Item_Count__c) totalLineItems ' +
            'FROM Order__c ' +
            'WHERE Order_Date__c >= :startDate AND Order_Date__c <= :endDate ' +
            'WITH SECURITY_ENFORCED ' +
            'GROUP BY Order_Status__c, Priority__c ' +
            'ORDER BY Order_Status__c ASC, Priority__c ASC'
        );
    }
    
    /**
     * Get customer order analytics for relationship insights
     * @param startDate Start date for analytics period
     * @param endDate End date for analytics period
     * @return List of AggregateResult for customer analytics
     */
    public static List<AggregateResult> getCustomerOrderAnalytics(Date startDate, Date endDate) {
        return Database.query(
            'SELECT Customer__c customerId, Customer__r.Name customerName, ' +
            'Customer__r.Customer_Type__c customerType, ' +
            'COUNT(Id) orderCount, SUM(Total_Amount__c) totalValue, ' +
            'AVG(Total_Amount__c) avgOrderValue, MAX(Order_Date__c) lastOrderDate ' +
            'FROM Order__c ' +
            'WHERE Order_Date__c >= :startDate AND Order_Date__c <= :endDate ' +
            'WITH SECURITY_ENFORCED ' +
            'GROUP BY Customer__c, Customer__r.Name, Customer__r.Customer_Type__c ' +
            'ORDER BY SUM(Total_Amount__c) DESC ' +
            'LIMIT 20'
        );
    }
    
    /**
     * Get daily order trends for time series analysis
     * @param startDate Start date for trend analysis
     * @param endDate End date for trend analysis
     * @return List of AggregateResult for daily trends
     */
    public static List<AggregateResult> getDailyOrderTrends(Date startDate, Date endDate) {
        return Database.query(
            'SELECT Order_Date__c orderDate, COUNT(Id) orderCount, ' +
            'SUM(Total_Amount__c) dailyRevenue, AVG(Total_Amount__c) avgOrderValue ' +
            'FROM Order__c ' +
            'WHERE Order_Date__c >= :startDate AND Order_Date__c <= :endDate ' +
            'WITH SECURITY_ENFORCED ' +
            'GROUP BY Order_Date__c ' +
            'ORDER BY Order_Date__c ASC'
        );
    }
}
