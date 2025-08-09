/**
 * OrderDashboardMinimal - Enhanced Analytics Dashboard Controller
 *
 * Educational Purpose: Demonstrates advanced dashboard features with incremental enhancement
 * This enhanced controller provides comprehensive analytics, charts, and real-time data
 *
 * Part of: TechSolutionApp Phase 4.3 - Advanced Dashboard Features
 * Author: TechSolutionApp Educational Platform
 * Created: August 2024
 * Enhanced: August 2024 - Phase 4.3 Implementation
 *
 * Features:
 * - Chart data for visualizations (bar charts, pie charts, trend lines)
 * - Advanced filtering and search capabilities
 * - Real-time analytics and metrics
 * - Comprehensive dashboard widgets
 * - Enterprise-level error handling and performance optimization
 */
public with sharing class OrderDashboardMinimal {
    
    /**
     * Get basic order count - minimal implementation
     */
    @AuraEnabled(cacheable=true)
    public static Integer getOrderCount() {
        try {
            return [SELECT COUNT() FROM Device_Order__c];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving order count: ' + e.getMessage());
        }
    }
    
    /**
     * Get basic device count - minimal implementation
     */
    @AuraEnabled(cacheable=true)
    public static Integer getDeviceCount() {
        try {
            return [SELECT COUNT() FROM Device__c];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving device count: ' + e.getMessage());
        }
    }
    
    /**
     * Test method to verify controller functionality
     */
    @AuraEnabled
    public static String testConnection() {
        return 'OrderDashboardMinimal controller is working correctly!';
    }

    // ========================================
    // PHASE 4.3: ADVANCED ANALYTICS METHODS
    // ========================================

    /**
     * Get chart data for order trends over time
     * Educational Purpose: Demonstrates time-series data aggregation for charts
     */
    @AuraEnabled(cacheable=true)
    public static List<ChartDataPoint> getOrderTrendData() {
        try {
            List<ChartDataPoint> chartData = new List<ChartDataPoint>();

            // Get orders grouped by month for the last 6 months
            List<AggregateResult> results = [
                SELECT CALENDAR_MONTH(Order_Date__c) month,
                       CALENDAR_YEAR(Order_Date__c) year,
                       COUNT(Id) orderCount,
                       SUM(Total_Price__c) totalRevenue
                FROM Device_Order__c
                WHERE Order_Date__c = LAST_N_MONTHS:6
                GROUP BY CALENDAR_MONTH(Order_Date__c), CALENDAR_YEAR(Order_Date__c)
                ORDER BY CALENDAR_YEAR(Order_Date__c), CALENDAR_MONTH(Order_Date__c)
            ];

            for (AggregateResult result : results) {
                ChartDataPoint point = new ChartDataPoint();
                point.label = getMonthName((Integer)result.get('month')) + ' ' + result.get('year');
                point.value = (Integer)result.get('orderCount');
                point.revenue = (Decimal)result.get('totalRevenue');
                chartData.add(point);
            }

            return chartData;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving order trend data: ' + e.getMessage());
        }
    }

    /**
     * Get device popularity data for pie chart
     * Educational Purpose: Demonstrates aggregate data for pie chart visualization
     */
    @AuraEnabled(cacheable=true)
    public static List<ChartDataPoint> getDevicePopularityData() {
        try {
            List<ChartDataPoint> chartData = new List<ChartDataPoint>();

            List<AggregateResult> results = [
                SELECT Device__r.Name deviceName,
                       COUNT(Id) orderCount,
                       SUM(Quantity__c) totalQuantity
                FROM Device_Order__c
                WHERE Device__c != null
                GROUP BY Device__r.Name
                ORDER BY COUNT(Id) DESC
                LIMIT 10
            ];

            for (AggregateResult result : results) {
                ChartDataPoint point = new ChartDataPoint();
                point.label = (String)result.get('deviceName');
                point.value = (Integer)result.get('orderCount');
                point.quantity = (Integer)result.get('totalQuantity');
                chartData.add(point);
            }

            return chartData;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving device popularity data: ' + e.getMessage());
        }
    }

    /**
     * Get comprehensive dashboard metrics
     * Educational Purpose: Demonstrates complex analytics calculations
     */
    @AuraEnabled(cacheable=true)
    public static DashboardMetrics getDashboardMetrics() {
        try {
            DashboardMetrics metrics = new DashboardMetrics();

            // Total orders and revenue
            List<AggregateResult> orderStats = [
                SELECT COUNT(Id) totalOrders,
                       SUM(Total_Price__c) totalRevenue,
                       AVG(Total_Price__c) avgOrderValue
                FROM Device_Order__c
            ];

            if (!orderStats.isEmpty()) {
                AggregateResult stats = orderStats[0];
                metrics.totalOrders = (Integer)stats.get('totalOrders');
                metrics.totalRevenue = (Decimal)stats.get('totalRevenue') ?? 0;
                metrics.avgOrderValue = (Decimal)stats.get('avgOrderValue') ?? 0;
            }

            // Stock status summary
            List<AggregateResult> stockStats = [
                SELECT Stock_Status__c status, COUNT(Id) deviceCount
                FROM Device__c
                WHERE Stock_Status__c != null
                GROUP BY Stock_Status__c
            ];

            for (AggregateResult stat : stockStats) {
                String status = (String)stat.get('status');
                Integer count = (Integer)stat.get('deviceCount');

                if (status == 'In Stock') {
                    metrics.inStockDevices = count;
                } else if (status == 'Low Stock') {
                    metrics.lowStockDevices = count;
                } else if (status == 'Out of Stock') {
                    metrics.outOfStockDevices = count;
                }
            }

            // Recent activity (orders in last 7 days)
            metrics.recentOrders = [
                SELECT COUNT()
                FROM Device_Order__c
                WHERE Order_Date__c = LAST_N_DAYS:7
            ];

            return metrics;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving dashboard metrics: ' + e.getMessage());
        }
    }

    // ========================================
    // WRAPPER CLASSES FOR DATA TRANSFER
    // ========================================

    /**
     * Chart data point wrapper class
     * Educational Purpose: Demonstrates structured data transfer for charts
     */
    public class ChartDataPoint {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public Integer value { get; set; }
        @AuraEnabled public Decimal revenue { get; set; }
        @AuraEnabled public Integer quantity { get; set; }
    }

    /**
     * Dashboard metrics wrapper class
     * Educational Purpose: Demonstrates comprehensive metrics data structure
     */
    public class DashboardMetrics {
        @AuraEnabled public Integer totalOrders { get; set; }
        @AuraEnabled public Decimal totalRevenue { get; set; }
        @AuraEnabled public Decimal avgOrderValue { get; set; }
        @AuraEnabled public Integer inStockDevices { get; set; }
        @AuraEnabled public Integer lowStockDevices { get; set; }
        @AuraEnabled public Integer outOfStockDevices { get; set; }
        @AuraEnabled public Integer recentOrders { get; set; }

        public DashboardMetrics() {
            this.totalOrders = 0;
            this.totalRevenue = 0;
            this.avgOrderValue = 0;
            this.inStockDevices = 0;
            this.lowStockDevices = 0;
            this.outOfStockDevices = 0;
            this.recentOrders = 0;
        }
    }

    // ========================================
    // UTILITY METHODS
    // ========================================

    /**
     * Get filtered orders with advanced search capabilities
     * Educational Purpose: Demonstrates dynamic SOQL with filtering
     */
    @AuraEnabled
    public static List<OrderRecord> getFilteredOrders(String searchTerm, String deviceFilter,
                                                     String dateFrom, String dateTo, Integer limitSize) {
        try {
            String query = 'SELECT Id, Device__r.Name, Quantity__c, Total_Price__c, Order_Date__c, ' +
                          'Confirmation_Number__c FROM Device_Order__c WHERE Id != null';

            List<String> conditions = new List<String>();

            // Add search term filter
            if (String.isNotBlank(searchTerm)) {
                conditions.add('(Device__r.Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' OR ' +
                              'Confirmation_Number__c LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\')');
            }

            // Add device filter
            if (String.isNotBlank(deviceFilter) && deviceFilter != 'All') {
                conditions.add('Device__r.Name = \'' + String.escapeSingleQuotes(deviceFilter) + '\'');
            }

            // Add date range filters
            if (String.isNotBlank(dateFrom)) {
                conditions.add('Order_Date__c >= ' + dateFrom);
            }
            if (String.isNotBlank(dateTo)) {
                conditions.add('Order_Date__c <= ' + dateTo);
            }

            // Combine conditions
            if (!conditions.isEmpty()) {
                query += ' AND ' + String.join(conditions, ' AND ');
            }

            query += ' ORDER BY Order_Date__c DESC';

            // Add limit
            if (limitSize != null && limitSize > 0) {
                query += ' LIMIT ' + limitSize;
            } else {
                query += ' LIMIT 100'; // Default limit
            }

            List<Device_Order__c> orders = Database.query(query);
            List<OrderRecord> orderRecords = new List<OrderRecord>();

            for (Device_Order__c order : orders) {
                OrderRecord record = new OrderRecord();
                record.id = order.Id;
                record.deviceName = order.Device__r?.Name;
                record.quantity = order.Quantity__c;
                record.totalPrice = order.Total_Price__c;
                record.orderDate = order.Order_Date__c;
                record.confirmationNumber = order.Confirmation_Number__c;
                orderRecords.add(record);
            }

            return orderRecords;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving filtered orders: ' + e.getMessage());
        }
    }

    /**
     * Get available device options for filtering
     * Educational Purpose: Demonstrates picklist data for UI components
     */
    @AuraEnabled(cacheable=true)
    public static List<PicklistOption> getDeviceFilterOptions() {
        try {
            List<PicklistOption> options = new List<PicklistOption>();

            // Add "All" option
            PicklistOption allOption = new PicklistOption();
            allOption.label = 'All Devices';
            allOption.value = 'All';
            options.add(allOption);

            // Get unique device names
            List<AggregateResult> devices = [
                SELECT Device__r.Name deviceName
                FROM Device_Order__c
                WHERE Device__r.Name != null
                GROUP BY Device__r.Name
                ORDER BY Device__r.Name
            ];

            for (AggregateResult device : devices) {
                PicklistOption option = new PicklistOption();
                option.label = (String)device.get('deviceName');
                option.value = (String)device.get('deviceName');
                options.add(option);
            }

            return options;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving device filter options: ' + e.getMessage());
        }
    }

    // ========================================
    // ADDITIONAL WRAPPER CLASSES
    // ========================================

    /**
     * Order record wrapper class for filtered results
     * Educational Purpose: Demonstrates structured order data for UI display
     */
    public class OrderRecord {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String deviceName { get; set; }
        @AuraEnabled public Decimal quantity { get; set; }
        @AuraEnabled public Decimal totalPrice { get; set; }
        @AuraEnabled public Date orderDate { get; set; }
        @AuraEnabled public String confirmationNumber { get; set; }
    }

    /**
     * Picklist option wrapper class
     * Educational Purpose: Demonstrates option data structure for UI components
     */
    public class PicklistOption {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
    }

    /**
     * Convert month number to month name
     * Educational Purpose: Demonstrates utility method for data formatting
     */
    private static String getMonthName(Integer monthNumber) {
        List<String> months = new List<String>{
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        };

        if (monthNumber >= 1 && monthNumber <= 12) {
            return months[monthNumber - 1];
        }
        return 'Unknown';
    }
}
