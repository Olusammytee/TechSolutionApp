/**
 * DeviceSelector - Apex selector pattern for Device__c queries
 * Provides centralized, optimized SOQL queries with proper security enforcement
 * Follows enterprise patterns for performance and maintainability
 */
public with sharing class DeviceSelector {
    
    // Standard field sets for different use cases
    private static final String BASIC_FIELDS = 'Id, Name, Type__c, Active__c';
    private static final String INVENTORY_FIELDS = 'Id, Name, Type__c, Stock_Quantity__c, Minimum_Stock_Level__c, Reorder_Point__c, Stock_Status__c, Active__c';
    private static final String FINANCIAL_FIELDS = 'Id, Name, Type__c, Price__c, Cost_Price__c, Profit_Margin__c, Active__c';
    private static final String ANALYTICS_FIELDS = 'Id, Name, Type__c, Stock_Quantity__c, Price__c, Cost_Price__c, Stock_Status__c, Supplier__c, Supplier__r.Name, Active__c';
    
    /**
     * Select devices by IDs with basic information
     * @param deviceIds Set of Device record IDs
     * @return List of Device__c records
     */
    public static List<Device__c> selectById(Set<Id> deviceIds) {
        if (deviceIds == null || deviceIds.isEmpty()) {
            return new List<Device__c>();
        }
        
        return Database.query(
            'SELECT ' + BASIC_FIELDS + ', Supplier__c, Supplier__r.Name ' +
            'FROM Device__c ' +
            'WHERE Id IN :deviceIds ' +
            'WITH SECURITY_ENFORCED'
        );
    }
    
    /**
     * Select devices with inventory information for stock management
     * @param deviceIds Set of Device record IDs
     * @return List of Device__c records with inventory fields
     */
    public static List<Device__c> selectInventoryById(Set<Id> deviceIds) {
        if (deviceIds == null || deviceIds.isEmpty()) {
            return new List<Device__c>();
        }
        
        return Database.query(
            'SELECT ' + INVENTORY_FIELDS + ', Last_Restocked__c, Supplier__c, Supplier__r.Name ' +
            'FROM Device__c ' +
            'WHERE Id IN :deviceIds ' +
            'WITH SECURITY_ENFORCED'
        );
    }
    
    /**
     * Select devices with financial information for analytics
     * @param deviceIds Set of Device record IDs
     * @return List of Device__c records with financial fields
     */
    public static List<Device__c> selectFinancialById(Set<Id> deviceIds) {
        if (deviceIds == null || deviceIds.isEmpty()) {
            return new List<Device__c>();
        }
        
        return Database.query(
            'SELECT ' + FINANCIAL_FIELDS + ', Warranty_Period_Months__c, Supplier__c ' +
            'FROM Device__c ' +
            'WHERE Id IN :deviceIds ' +
            'WITH SECURITY_ENFORCED'
        );
    }
    
    /**
     * Select low stock devices for inventory management
     * @return List of Device__c records with low stock
     */
    public static List<Device__c> selectLowStock() {
        return Database.query(
            'SELECT ' + INVENTORY_FIELDS + ', Supplier__c, Supplier__r.Name, Supplier__r.Email__c ' +
            'FROM Device__c ' +
            'WHERE Stock_Status__c IN (\'Low Stock\', \'Out of Stock\') ' +
            'AND Active__c = true ' +
            'WITH SECURITY_ENFORCED ' +
            'ORDER BY Stock_Quantity__c ASC, Name ASC'
        );
    }
    
    /**
     * Select devices below reorder point for procurement
     * @return List of Device__c records needing reorder
     */
    public static List<Device__c> selectBelowReorderPoint() {
        return Database.query(
            'SELECT ' + INVENTORY_FIELDS + ', Supplier__c, Supplier__r.Name, Supplier__r.Email__c ' +
            'FROM Device__c ' +
            'WHERE Stock_Quantity__c <= Reorder_Point__c ' +
            'AND Active__c = true ' +
            'WITH SECURITY_ENFORCED ' +
            'ORDER BY (Stock_Quantity__c - Reorder_Point__c) ASC, Name ASC'
        );
    }
    
    /**
     * Select devices for analytics dashboard with date range
     * @param startDate Start date for analytics period
     * @param endDate End date for analytics period
     * @return List of Device__c records with related order data
     */
    public static List<Device__c> selectForAnalytics(Date startDate, Date endDate) {
        return Database.query(
            'SELECT ' + ANALYTICS_FIELDS + ', ' +
            '(SELECT Id, Quantity__c, Line_Total__c, Line_Profit_Margin__c, Order__r.Order_Date__c ' +
            'FROM Order_Line_Items__r ' +
            'WHERE Order__r.Order_Date__c >= :startDate ' +
            'AND Order__r.Order_Date__c <= :endDate ' +
            'AND Order__r.Order_Status__c != \'Cancelled\') ' +
            'FROM Device__c ' +
            'WHERE Active__c = true ' +
            'WITH SECURITY_ENFORCED ' +
            'ORDER BY Name ASC'
        );
    }
    
    /**
     * Select devices by type for category analysis
     * @param deviceTypes Set of device types to filter by
     * @return List of Device__c records of specified types
     */
    public static List<Device__c> selectByType(Set<String> deviceTypes) {
        if (deviceTypes == null || deviceTypes.isEmpty()) {
            return new List<Device__c>();
        }
        
        return Database.query(
            'SELECT ' + ANALYTICS_FIELDS + ' ' +
            'FROM Device__c ' +
            'WHERE Type__c IN :deviceTypes ' +
            'AND Active__c = true ' +
            'WITH SECURITY_ENFORCED ' +
            'ORDER BY Type__c ASC, Name ASC'
        );
    }
    
    /**
     * Select devices with pending order impact
     * @return List of Device__c records with pending order calculations
     */
    public static List<Device__c> selectWithPendingOrders() {
        return Database.query(
            'SELECT ' + INVENTORY_FIELDS + ', ' +
            '(SELECT Id, Quantity__c, Order__r.Order_Status__c ' +
            'FROM Order_Line_Items__r ' +
            'WHERE Order__r.Order_Status__c IN (\'Pending\', \'Confirmed\', \'Processing\')) ' +
            'FROM Device__c ' +
            'WHERE Active__c = true ' +
            'WITH SECURITY_ENFORCED ' +
            'ORDER BY Name ASC'
        );
    }
    
    /**
     * Select devices for dashboard summary with limits for performance
     * @param limitCount Maximum number of records to return
     * @return List of Device__c records for dashboard display
     */
    public static List<Device__c> selectForDashboard(Integer limitCount) {
        if (limitCount == null || limitCount <= 0) {
            limitCount = 50; // Default limit
        }
        
        return Database.query(
            'SELECT ' + ANALYTICS_FIELDS + ' ' +
            'FROM Device__c ' +
            'WHERE Active__c = true ' +
            'WITH SECURITY_ENFORCED ' +
            'ORDER BY LastModifiedDate DESC ' +
            'LIMIT :limitCount'
        );
    }
    
    /**
     * Count active devices by status for quick metrics
     * @return Map of status to count
     */
    public static Map<String, Integer> getDeviceCountByStatus() {
        Map<String, Integer> statusCounts = new Map<String, Integer>();
        
        List<AggregateResult> results = Database.query(
            'SELECT Stock_Status__c status, COUNT(Id) deviceCount ' +
            'FROM Device__c ' +
            'WHERE Active__c = true ' +
            'WITH SECURITY_ENFORCED ' +
            'GROUP BY Stock_Status__c'
        );
        
        for (AggregateResult result : results) {
            String status = (String) result.get('status');
            Integer count = (Integer) result.get('deviceCount');
            statusCounts.put(status, count);
        }
        
        return statusCounts;
    }
}
