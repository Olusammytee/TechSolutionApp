/**
 * DashboardDTO - View Model Data Transfer Objects for Lightning Web Component consumption
 * Provides optimized data structures for dashboard components with proper serialization
 * Follows enterprise patterns for performance and maintainability
 */
public class DashboardDTO {
    
    /**
     * Order Dashboard DTO for order management components
     */
    public class OrderDashboardDTO {
        @AuraEnabled public String orderId { get; set; }
        @AuraEnabled public String orderNumber { get; set; }
        @AuraEnabled public String customerId { get; set; }
        @AuraEnabled public String customerName { get; set; }
        @AuraEnabled public String customerType { get; set; }
        @AuraEnabled public String orderStatus { get; set; }
        @AuraEnabled public String priority { get; set; }
        @AuraEnabled public Decimal totalAmount { get; set; }
        @AuraEnabled public String formattedTotalAmount { get; set; }
        @AuraEnabled public Date orderDate { get; set; }
        @AuraEnabled public String formattedOrderDate { get; set; }
        @AuraEnabled public Date expectedDeliveryDate { get; set; }
        @AuraEnabled public Integer lineItemCount { get; set; }
        @AuraEnabled public List<LineItemDTO> lineItems { get; set; }
        @AuraEnabled public String statusClass { get; set; }
        @AuraEnabled public String priorityClass { get; set; }
        
        public OrderDashboardDTO(Order__c order) {
            this.orderId = order.Id;
            this.orderNumber = order.Name;
            this.customerId = order.Customer__c;
            this.customerName = order.Customer__r?.Name;
            this.customerType = order.Customer__r?.Customer_Type__c;
            this.orderStatus = order.Order_Status__c;
            this.priority = order.Priority__c;
            this.totalAmount = order.Total_Amount__c;
            this.formattedTotalAmount = formatCurrency(order.Total_Amount__c);
            this.orderDate = order.Order_Date__c;
            this.formattedOrderDate = formatDate(order.Order_Date__c);
            this.expectedDeliveryDate = order.Expected_Delivery_Date__c;
            this.lineItemCount = Integer.valueOf(order.Line_Item_Count__c);
            this.statusClass = getStatusClass(order.Order_Status__c);
            this.priorityClass = getPriorityClass(order.Priority__c);
            
            // Initialize line items if provided
            this.lineItems = new List<LineItemDTO>();
            if (order.Order_Line_Items__r != null) {
                for (Order_Line_Item__c lineItem : order.Order_Line_Items__r) {
                    this.lineItems.add(new LineItemDTO(lineItem));
                }
            }
        }
    }
    
    /**
     * Line Item DTO for order line item components
     */
    public class LineItemDTO {
        @AuraEnabled public String lineItemId { get; set; }
        @AuraEnabled public String lineItemNumber { get; set; }
        @AuraEnabled public Integer lineNumber { get; set; }
        @AuraEnabled public String deviceId { get; set; }
        @AuraEnabled public String deviceName { get; set; }
        @AuraEnabled public String deviceType { get; set; }
        @AuraEnabled public String productName { get; set; }
        @AuraEnabled public Decimal quantity { get; set; }
        @AuraEnabled public Decimal unitPrice { get; set; }
        @AuraEnabled public String formattedUnitPrice { get; set; }
        @AuraEnabled public Decimal lineDiscountPercentage { get; set; }
        @AuraEnabled public Decimal lineTotal { get; set; }
        @AuraEnabled public String formattedLineTotal { get; set; }
        @AuraEnabled public Decimal lineProfitMargin { get; set; }
        @AuraEnabled public String formattedProfitMargin { get; set; }
        @AuraEnabled public Decimal stockAvailable { get; set; }
        @AuraEnabled public String stockStatus { get; set; }
        
        public LineItemDTO(Order_Line_Item__c lineItem) {
            this.lineItemId = lineItem.Id;
            this.lineItemNumber = lineItem.Name;
            this.lineNumber = Integer.valueOf(lineItem.Line_Number__c);
            this.deviceId = lineItem.Device__c;
            this.deviceName = lineItem.Device__r?.Name;
            this.deviceType = lineItem.Device__r?.Type__c;
            this.productName = lineItem.Product_Name__c;
            this.quantity = lineItem.Quantity__c;
            this.unitPrice = lineItem.Unit_Price__c;
            this.formattedUnitPrice = formatCurrency(lineItem.Unit_Price__c);
            this.lineDiscountPercentage = lineItem.Line_Discount_Percentage__c;
            this.lineTotal = lineItem.Line_Total__c;
            this.formattedLineTotal = formatCurrency(lineItem.Line_Total__c);
            this.lineProfitMargin = lineItem.Line_Profit_Margin__c;
            this.formattedProfitMargin = formatPercentage(lineItem.Line_Profit_Margin__c);
            this.stockAvailable = lineItem.Stock_Available__c;
            this.stockStatus = getStockStatus(lineItem.Stock_Available__c, lineItem.Quantity__c);
        }
    }
    
    /**
     * Device Dashboard DTO for inventory management components
     */
    public class DeviceDashboardDTO {
        @AuraEnabled public String deviceId { get; set; }
        @AuraEnabled public String deviceName { get; set; }
        @AuraEnabled public String deviceType { get; set; }
        @AuraEnabled public Decimal stockQuantity { get; set; }
        @AuraEnabled public String stockStatus { get; set; }
        @AuraEnabled public String stockStatusClass { get; set; }
        @AuraEnabled public Decimal price { get; set; }
        @AuraEnabled public String formattedPrice { get; set; }
        @AuraEnabled public Decimal profitMargin { get; set; }
        @AuraEnabled public String formattedProfitMargin { get; set; }
        @AuraEnabled public String supplierName { get; set; }
        @AuraEnabled public Decimal minimumStockLevel { get; set; }
        @AuraEnabled public Decimal reorderPoint { get; set; }
        @AuraEnabled public Boolean needsReorder { get; set; }
        @AuraEnabled public Integer pendingOrderQuantity { get; set; }
        
        public DeviceDashboardDTO(Device__c device) {
            this.deviceId = device.Id;
            this.deviceName = device.Name;
            this.deviceType = device.Type__c;
            this.stockQuantity = device.Stock_Quantity__c;
            this.stockStatus = device.Stock_Status__c;
            this.stockStatusClass = getStockStatusClass(device.Stock_Status__c);
            this.price = device.Price__c;
            this.formattedPrice = formatCurrency(device.Price__c);
            this.profitMargin = device.Profit_Margin__c;
            this.formattedProfitMargin = formatPercentage(device.Profit_Margin__c);
            this.supplierName = device.Supplier__r?.Name;
            this.minimumStockLevel = device.Minimum_Stock_Level__c;
            this.reorderPoint = device.Reorder_Point__c;
            this.needsReorder = (device.Stock_Quantity__c != null && device.Reorder_Point__c != null) ? 
                               device.Stock_Quantity__c <= device.Reorder_Point__c : false;
            
            // Calculate pending order quantity from related line items
            this.pendingOrderQuantity = 0;
            if (device.Order_Line_Items__r != null) {
                for (Order_Line_Item__c lineItem : device.Order_Line_Items__r) {
                    if (lineItem.Order__r.Order_Status__c == 'Pending' || 
                        lineItem.Order__r.Order_Status__c == 'Confirmed' || 
                        lineItem.Order__r.Order_Status__c == 'Processing') {
                        this.pendingOrderQuantity += Integer.valueOf(lineItem.Quantity__c);
                    }
                }
            }
        }
    }
    
    /**
     * Analytics Summary DTO for dashboard metrics
     */
    public class AnalyticsSummaryDTO {
        @AuraEnabled public Integer totalOrders { get; set; }
        @AuraEnabled public Decimal totalRevenue { get; set; }
        @AuraEnabled public String formattedTotalRevenue { get; set; }
        @AuraEnabled public Decimal averageOrderValue { get; set; }
        @AuraEnabled public String formattedAverageOrderValue { get; set; }
        @AuraEnabled public Integer totalDevices { get; set; }
        @AuraEnabled public Integer lowStockDevices { get; set; }
        @AuraEnabled public Integer outOfStockDevices { get; set; }
        @AuraEnabled public Integer highPriorityOrders { get; set; }
        @AuraEnabled public Integer pendingOrders { get; set; }
        @AuraEnabled public Map<String, Integer> ordersByStatus { get; set; }
        @AuraEnabled public Map<String, Integer> devicesByType { get; set; }
        @AuraEnabled public List<ChartDataDTO> revenueByDay { get; set; }
        
        public AnalyticsSummaryDTO() {
            this.ordersByStatus = new Map<String, Integer>();
            this.devicesByType = new Map<String, Integer>();
            this.revenueByDay = new List<ChartDataDTO>();
        }
    }
    
    /**
     * Chart Data DTO for dashboard visualizations
     */
    public class ChartDataDTO {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public Decimal value { get; set; }
        @AuraEnabled public String formattedValue { get; set; }
        @AuraEnabled public String color { get; set; }
        @AuraEnabled public Date dateValue { get; set; }
        
        public ChartDataDTO(String label, Decimal value) {
            this.label = label;
            this.value = value;
            this.formattedValue = formatCurrency(value);
        }
        
        public ChartDataDTO(String label, Decimal value, Date dateValue) {
            this.label = label;
            this.value = value;
            this.formattedValue = formatCurrency(value);
            this.dateValue = dateValue;
        }
    }
    
    // Utility methods for formatting and styling
    
    private static String formatCurrency(Decimal amount) {
        if (amount == null) return '$0.00';
        return '$' + amount.setScale(2).format();
    }
    
    private static String formatPercentage(Decimal percentage) {
        if (percentage == null) return '0%';
        return percentage.setScale(1).format() + '%';
    }
    
    private static String formatDate(Date dateValue) {
        if (dateValue == null) return '';
        return dateValue.format();
    }
    
    private static String getStatusClass(String status) {
        if (status == null) return 'slds-badge';
        
        switch on status.toLowerCase() {
            when 'pending' { return 'slds-badge slds-theme_warning'; }
            when 'confirmed' { return 'slds-badge slds-theme_info'; }
            when 'processing' { return 'slds-badge slds-theme_info'; }
            when 'shipped' { return 'slds-badge slds-theme_success'; }
            when 'delivered' { return 'slds-badge slds-theme_success'; }
            when 'cancelled' { return 'slds-badge slds-theme_error'; }
            when else { return 'slds-badge'; }
        }
    }
    
    private static String getPriorityClass(String priority) {
        if (priority == null) return 'slds-badge';
        
        switch on priority.toLowerCase() {
            when 'critical' { return 'slds-badge slds-theme_error'; }
            when 'high' { return 'slds-badge slds-theme_warning'; }
            when 'medium' { return 'slds-badge slds-theme_info'; }
            when 'low' { return 'slds-badge'; }
            when else { return 'slds-badge'; }
        }
    }
    
    private static String getStockStatusClass(String stockStatus) {
        if (stockStatus == null) return 'slds-badge';
        
        switch on stockStatus.toLowerCase() {
            when 'out of stock' { return 'slds-badge slds-theme_error'; }
            when 'low stock' { return 'slds-badge slds-theme_warning'; }
            when 'reorder soon' { return 'slds-badge slds-theme_info'; }
            when 'in stock' { return 'slds-badge slds-theme_success'; }
            when else { return 'slds-badge'; }
        }
    }
    
    private static String getStockStatus(Decimal stockAvailable, Decimal quantityOrdered) {
        if (stockAvailable == null || quantityOrdered == null) return 'Unknown';
        
        if (stockAvailable >= quantityOrdered) {
            return 'Available';
        } else if (stockAvailable > 0) {
            return 'Partial';
        } else {
            return 'Backordered';
        }
    }
}
