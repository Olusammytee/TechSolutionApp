/**
 * AnalyticsService - Enterprise cacheable service layer for Lightning Web Component analytics
 * Provides optimized, cacheable methods for dashboard consumption with proper security enforcement
 * Follows enterprise patterns for performance, security, and maintainability
 */
public with sharing class AnalyticsService {
    
    /**
     * Get comprehensive dashboard data for analytics components
     * @param startDate Start date for analytics period
     * @param endDate End date for analytics period
     * @return DashboardDTO.AnalyticsSummaryDTO with complete analytics data
     */
    @AuraEnabled(cacheable=true)
    public static DashboardDTO.AnalyticsSummaryDTO getDashboardData(Date startDate, Date endDate) {
        try {
            // Validate input parameters
            if (startDate == null || endDate == null) {
                throw new IllegalArgumentException('Start date and end date are required');
            }
            
            if (startDate > endDate) {
                throw new IllegalArgumentException('Start date cannot be after end date');
            }
            
            // Security checks
            if (!Schema.sObjectType.Order__c.isAccessible() || 
                !Schema.sObjectType.Device__c.isAccessible()) {
                throw new AuraHandledException('Insufficient permissions to access analytics data');
            }
            
            DashboardDTO.AnalyticsSummaryDTO summary = new DashboardDTO.AnalyticsSummaryDTO();
            
            // Get order analytics
            List<Order__c> orders = OrderSelector.selectForDashboard(startDate, endDate);
            List<AggregateResult> orderAnalytics = OrderSelector.getOrderAnalytics(startDate, endDate);
            List<AggregateResult> dailyTrends = OrderSelector.getDailyOrderTrends(startDate, endDate);
            
            // Calculate order metrics
            summary.totalOrders = orders.size();
            summary.totalRevenue = 0;
            summary.highPriorityOrders = 0;
            summary.pendingOrders = 0;
            
            for (Order__c order : orders) {
                if (order.Total_Amount__c != null) {
                    summary.totalRevenue += order.Total_Amount__c;
                }
                
                if (order.Priority__c == 'Critical' || order.Priority__c == 'High') {
                    summary.highPriorityOrders++;
                }
                
                if (order.Order_Status__c == 'Pending' || order.Order_Status__c == 'Confirmed') {
                    summary.pendingOrders++;
                }
            }
            
            summary.averageOrderValue = summary.totalOrders > 0 ? 
                                      summary.totalRevenue / summary.totalOrders : 0;
            summary.formattedTotalRevenue = formatCurrency(summary.totalRevenue);
            summary.formattedAverageOrderValue = formatCurrency(summary.averageOrderValue);
            
            // Process order status distribution
            for (AggregateResult result : orderAnalytics) {
                String status = (String) result.get('status');
                Integer count = (Integer) result.get('orderCount');
                if (status != null && count != null) {
                    summary.ordersByStatus.put(status, count);
                }
            }
            
            // Process daily revenue trends
            for (AggregateResult result : dailyTrends) {
                Date orderDate = (Date) result.get('orderDate');
                Decimal dailyRevenue = (Decimal) result.get('dailyRevenue');
                if (orderDate != null && dailyRevenue != null) {
                    summary.revenueByDay.add(new DashboardDTO.ChartDataDTO(
                        orderDate.format(), dailyRevenue, orderDate
                    ));
                }
            }
            
            // Get device analytics
            Map<String, Integer> deviceCounts = DeviceSelector.getDeviceCountByStatus();
            summary.totalDevices = 0;
            summary.lowStockDevices = 0;
            summary.outOfStockDevices = 0;
            
            for (String status : deviceCounts.keySet()) {
                Integer count = deviceCounts.get(status);
                summary.totalDevices += count;
                
                if (status == 'Low Stock') {
                    summary.lowStockDevices = count;
                } else if (status == 'Out of Stock') {
                    summary.outOfStockDevices = count;
                }
            }
            
            // Get device type distribution
            List<Device__c> devices = DeviceSelector.selectForDashboard(100);
            for (Device__c device : devices) {
                String deviceType = device.Type__c;
                if (deviceType != null) {
                    Integer currentCount = summary.devicesByType.get(deviceType);
                    summary.devicesByType.put(deviceType, currentCount != null ? currentCount + 1 : 1);
                }
            }
            
            return summary;
            
        } catch (Exception e) {
            ErrorLogger.logError('AnalyticsService', 'getDashboardData', e);
            throw new AuraHandledException('Error retrieving dashboard data: ' + e.getMessage());
        }
    }
    
    /**
     * Get inventory analytics for inventory management dashboard
     * @return List of DashboardDTO.DeviceDashboardDTO with inventory insights
     */
    @AuraEnabled(cacheable=true)
    public static List<DashboardDTO.DeviceDashboardDTO> getInventoryAnalytics() {
        try {
            // Security check
            if (!Schema.sObjectType.Device__c.isAccessible()) {
                throw new AuraHandledException('Insufficient permissions to access device data');
            }
            
            List<Device__c> lowStockDevices = DeviceSelector.selectLowStock();
            List<DashboardDTO.DeviceDashboardDTO> inventoryData = new List<DashboardDTO.DeviceDashboardDTO>();
            
            for (Device__c device : lowStockDevices) {
                inventoryData.add(new DashboardDTO.DeviceDashboardDTO(device));
            }
            
            return inventoryData;
            
        } catch (Exception e) {
            ErrorLogger.logError('AnalyticsService', 'getInventoryAnalytics', e);
            throw new AuraHandledException('Error retrieving inventory analytics: ' + e.getMessage());
        }
    }
    
    /**
     * Get customer analytics for relationship management
     * @param startDate Start date for analytics period
     * @param endDate End date for analytics period
     * @return List of customer analytics data
     */
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getCustomerAnalytics(Date startDate, Date endDate) {
        try {
            // Validate input parameters
            if (startDate == null || endDate == null) {
                throw new IllegalArgumentException('Start date and end date are required');
            }
            
            // Security check
            if (!Schema.sObjectType.Order__c.isAccessible()) {
                throw new AuraHandledException('Insufficient permissions to access order data');
            }
            
            return OrderSelector.getCustomerOrderAnalytics(startDate, endDate);
            
        } catch (Exception e) {
            ErrorLogger.logError('AnalyticsService', 'getCustomerAnalytics', e);
            throw new AuraHandledException('Error retrieving customer analytics: ' + e.getMessage());
        }
    }
    
    /**
     * Get order details with line items for order management
     * @param orderId Order record ID
     * @return DashboardDTO.OrderDashboardDTO with complete order details
     */
    @AuraEnabled(cacheable=true)
    public static DashboardDTO.OrderDashboardDTO getOrderDetails(Id orderId) {
        try {
            // Validate input
            if (orderId == null) {
                throw new IllegalArgumentException('Order ID is required');
            }
            
            // Security check
            if (!Schema.sObjectType.Order__c.isAccessible()) {
                throw new AuraHandledException('Insufficient permissions to access order data');
            }
            
            List<Order__c> orders = OrderSelector.selectWithLineItems(new Set<Id>{orderId});
            
            if (orders.isEmpty()) {
                throw new AuraHandledException('Order not found or not accessible');
            }
            
            return new DashboardDTO.OrderDashboardDTO(orders[0]);
            
        } catch (Exception e) {
            ErrorLogger.logError('AnalyticsService', 'getOrderDetails', e);
            throw new AuraHandledException('Error retrieving order details: ' + e.getMessage());
        }
    }
    
    /**
     * Get recent orders for dashboard display
     * @param limitCount Maximum number of orders to return
     * @return List of DashboardDTO.OrderDashboardDTO for recent orders
     */
    @AuraEnabled(cacheable=true)
    public static List<DashboardDTO.OrderDashboardDTO> getRecentOrders(Integer limitCount) {
        try {
            // Validate input
            if (limitCount == null || limitCount <= 0) {
                limitCount = 10; // Default limit
            }
            
            if (limitCount > 100) {
                limitCount = 100; // Maximum limit for performance
            }
            
            // Security check
            if (!Schema.sObjectType.Order__c.isAccessible()) {
                throw new AuraHandledException('Insufficient permissions to access order data');
            }
            
            Date startDate = Date.today().addDays(-30); // Last 30 days
            Date endDate = Date.today();
            
            List<Order__c> orders = OrderSelector.selectForDashboard(startDate, endDate);
            List<DashboardDTO.OrderDashboardDTO> recentOrders = new List<DashboardDTO.OrderDashboardDTO>();
            
            // Limit results and convert to DTOs
            Integer count = 0;
            for (Order__c order : orders) {
                if (count >= limitCount) break;
                recentOrders.add(new DashboardDTO.OrderDashboardDTO(order));
                count++;
            }
            
            return recentOrders;
            
        } catch (Exception e) {
            ErrorLogger.logError('AnalyticsService', 'getRecentOrders', e);
            throw new AuraHandledException('Error retrieving recent orders: ' + e.getMessage());
        }
    }
    
    /**
     * Get performance metrics for monitoring
     * @return Map of performance metrics
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getPerformanceMetrics() {
        try {
            Map<String, Object> metrics = new Map<String, Object>();
            
            // Get current limits
            metrics.put('soqlQueries', Limits.getQueries());
            metrics.put('soqlQueryLimit', Limits.getLimitQueries());
            metrics.put('dmlStatements', Limits.getDMLStatements());
            metrics.put('dmlStatementLimit', Limits.getLimitDMLStatements());
            metrics.put('cpuTime', Limits.getCpuTime());
            metrics.put('cpuTimeLimit', Limits.getLimitCpuTime());
            
            // Calculate utilization percentages
            metrics.put('soqlUtilization', (Decimal.valueOf(Limits.getQueries()) / Limits.getLimitQueries()) * 100);
            metrics.put('dmlUtilization', (Decimal.valueOf(Limits.getDMLStatements()) / Limits.getLimitDMLStatements()) * 100);
            metrics.put('cpuUtilization', (Decimal.valueOf(Limits.getCpuTime()) / Limits.getLimitCpuTime()) * 100);
            
            return metrics;
            
        } catch (Exception e) {
            ErrorLogger.logError('AnalyticsService', 'getPerformanceMetrics', e);
            throw new AuraHandledException('Error retrieving performance metrics: ' + e.getMessage());
        }
    }
    
    // Utility methods
    
    private static String formatCurrency(Decimal amount) {
        if (amount == null) return '$0.00';
        return '$' + amount.setScale(2).format();
    }
}
