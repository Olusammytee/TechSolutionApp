import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class ExecutiveSummaryDashboard extends NavigationMixin(LightningElement) {
    @api dashboardData;
    @api performanceMetrics;

    @track revenueChartData = [];
    @track orderStatusChartData = [];
    @track highPriorityOrders = [];
    @track inventoryAlerts = [];

    // Computed properties for KPI metrics
    get totalOrders() {
        return this.dashboardData?.totalOrders || 0;
    }

    get formattedTotalRevenue() {
        return this.dashboardData?.formattedTotalRevenue || '$0.00';
    }

    get formattedAverageOrderValue() {
        return this.dashboardData?.formattedAverageOrderValue || '$0.00';
    }

    get lowStockDevices() {
        return this.dashboardData?.lowStockDevices || 0;
    }

    get outOfStockDevices() {
        return this.dashboardData?.outOfStockDevices || 0;
    }

    get totalDevices() {
        return this.dashboardData?.totalDevices || 0;
    }

    // Inventory health calculation
    get inventoryHealthScore() {
        if (!this.totalDevices) return 100;
        const healthyDevices = this.totalDevices - this.lowStockDevices - this.outOfStockDevices;
        return Math.round((healthyDevices / this.totalDevices) * 100);
    }

    get inventoryHealthClass() {
        const score = this.inventoryHealthScore;
        if (score >= 80) return 'slds-text-color_success';
        if (score >= 60) return 'slds-text-color_warning';
        return 'slds-text-color_error';
    }

    // Trend calculations (mock data for demo - would be calculated from historical data)
    get revenueTrendIcon() {
        return 'utility:trending';
    }

    get revenueTrendClass() {
        return 'slds-text-color_success';
    }

    get revenueTrendText() {
        return '+12.5% vs last month';
    }

    get ordersTrendIcon() {
        return 'utility:trending';
    }

    get ordersTrendClass() {
        return 'slds-text-color_success';
    }

    get ordersTrendText() {
        return '+8.3% vs last month';
    }

    get aovTrendIcon() {
        return 'utility:trending';
    }

    get aovTrendClass() {
        return 'slds-text-color_success';
    }

    get aovTrendText() {
        return '+3.7% vs last month';
    }

    // Chart data availability
    get hasRevenueData() {
        return this.revenueChartData && this.revenueChartData.length > 0;
    }

    get hasOrderStatusData() {
        return this.orderStatusChartData && this.orderStatusChartData.length > 0;
    }

    get hasHighPriorityOrders() {
        return this.highPriorityOrders && this.highPriorityOrders.length > 0;
    }

    get hasInventoryAlerts() {
        return this.inventoryAlerts && this.inventoryAlerts.length > 0;
    }

    // Lifecycle methods
    connectedCallback() {
        this.processChartData();
        this.processHighPriorityOrders();
        this.processInventoryAlerts();
    }

    renderedCallback() {
        // Update charts when data changes
        if (this.dashboardData) {
            this.processChartData();
        }
    }

    // Data processing methods
    processChartData() {
        if (!this.dashboardData) return;

        // Process revenue trend data
        if (this.dashboardData.revenueByDay) {
            this.revenueChartData = this.dashboardData.revenueByDay.map(item => ({
                label: this.formatDate(item.dateValue),
                value: item.value,
                formattedValue: item.formattedValue
            }));
        }

        // Process order status data
        if (this.dashboardData.ordersByStatus) {
            this.orderStatusChartData = Object.keys(this.dashboardData.ordersByStatus).map(status => ({
                label: status,
                value: this.dashboardData.ordersByStatus[status],
                color: this.getStatusColor(status)
            }));
        }
    }

    processHighPriorityOrders() {
        // Mock high priority orders - would come from parent component
        this.highPriorityOrders = [
            {
                orderId: '1',
                orderNumber: 'ORD-00001',
                customerName: 'Acme Corporation',
                formattedTotalAmount: '$15,750.00',
                priority: 'Critical',
                priorityClass: 'slds-theme_error'
            },
            {
                orderId: '2',
                orderNumber: 'ORD-00002',
                customerName: 'Global Tech Solutions',
                formattedTotalAmount: '$8,999.99',
                priority: 'High',
                priorityClass: 'slds-theme_warning'
            }
        ];
    }

    processInventoryAlerts() {
        // Mock inventory alerts - would come from parent component
        this.inventoryAlerts = [
            {
                deviceId: '1',
                deviceName: 'MacBook Pro 16-inch M3 Max',
                stockQuantity: 2,
                stockStatus: 'Low Stock',
                stockStatusClass: 'slds-theme_warning'
            },
            {
                deviceId: '2',
                deviceName: 'Dell XPS 13 Plus',
                stockQuantity: 0,
                stockStatus: 'Out of Stock',
                stockStatusClass: 'slds-theme_error'
            }
        ];
    }

    // Event handlers
    handleViewAllOrders() {
        // Navigate to orders list view
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Order__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }
        });
    }

    handleViewInventory() {
        // Navigate to devices list view
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Device__c',
                actionName: 'list'
            },
            state: {
                filterName: 'All'
            }
        });
    }

    // Utility methods
    formatDate(dateString) {
        if (!dateString) return '';
        const date = new Date(dateString);
        return date.toLocaleDateString('en-US', { 
            month: 'short', 
            day: 'numeric' 
        });
    }

    getStatusColor(status) {
        const colorMap = {
            'Pending': '#FFB75D',
            'Confirmed': '#4BC076',
            'Processing': '#5DDAFF',
            'Shipped': '#9A77CF',
            'Delivered': '#57B85A',
            'Cancelled': '#EA6B66',
            'Returned': '#F4B942'
        };
        return colorMap[status] || '#747474';
    }

    // Public methods for parent component
    @api
    refreshData() {
        this.processChartData();
        this.processHighPriorityOrders();
        this.processInventoryAlerts();
        
        // Dispatch refresh event to parent
        this.dispatchEvent(new CustomEvent('refresh'));
    }
}
