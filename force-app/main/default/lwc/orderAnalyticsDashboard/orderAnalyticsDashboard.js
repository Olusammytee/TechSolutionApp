import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OrderAnalyticsDashboard extends NavigationMixin(LightningElement) {
    @api dashboardData;
    @api recentOrders;
    
    @track isLoading = false;
    @track selectedTrendPeriod = '30days';
    @track sortedBy = 'orderDate';
    @track sortedDirection = 'desc';
    
    // Chart data
    @track orderPipelineData = [];
    @track orderTrendsData = [];
    @track priorityAnalysisData = [];
    @track recentOrdersData = [];

    // Trend period options
    trendPeriodOptions = [
        { label: 'Last 7 Days', value: '7days' },
        { label: 'Last 30 Days', value: '30days' },
        { label: 'Last 90 Days', value: '90days' },
        { label: 'Last 12 Months', value: '12months' }
    ];

    // Data table columns
    orderColumns = [
        {
            label: 'Order Number',
            fieldName: 'orderNumber',
            type: 'text',
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Customer',
            fieldName: 'customerName',
            type: 'text',
            sortable: true
        },
        {
            label: 'Status',
            fieldName: 'orderStatus',
            type: 'text',
            sortable: true,
            cellAttributes: { 
                class: { fieldName: 'statusClass' },
                alignment: 'center'
            }
        },
        {
            label: 'Priority',
            fieldName: 'priority',
            type: 'text',
            sortable: true,
            cellAttributes: { 
                class: { fieldName: 'priorityClass' },
                alignment: 'center'
            }
        },
        {
            label: 'Total Amount',
            fieldName: 'formattedTotalAmount',
            type: 'text',
            sortable: true,
            cellAttributes: { alignment: 'right' }
        },
        {
            label: 'Order Date',
            fieldName: 'formattedOrderDate',
            type: 'text',
            sortable: true
        },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'View', name: 'view' },
                    { label: 'Edit', name: 'edit' }
                ]
            }
        }
    ];

    // Computed properties for metrics
    get totalOrders() {
        return this.dashboardData?.totalOrders || 0;
    }

    get activeOrders() {
        return this.dashboardData?.highPriorityOrders || 0;
    }

    get pendingOrders() {
        return this.dashboardData?.pendingOrders || 0;
    }

    get averageProcessingTime() {
        // Mock calculation - would be calculated from actual data
        return '3.2 days';
    }

    // Trend indicators (mock data - would be calculated from historical data)
    get ordersTrendClass() {
        return 'slds-text-color_success';
    }

    get ordersTrendText() {
        return '+12% vs last period';
    }

    get activeTrendClass() {
        return 'slds-text-color_warning';
    }

    get activeTrendText() {
        return '+5% vs last period';
    }

    get pendingTrendClass() {
        return 'slds-text-color_error';
    }

    get pendingTrendText() {
        return '+18% vs last period';
    }

    get timeTrendClass() {
        return 'slds-text-color_success';
    }

    get timeTrendText() {
        return '-8% vs last period';
    }

    // Data availability checks
    get hasOrderPipelineData() {
        return this.orderPipelineData && this.orderPipelineData.length > 0;
    }

    get hasOrderTrendsData() {
        return this.orderTrendsData && this.orderTrendsData.length > 0;
    }

    get hasPriorityData() {
        return this.priorityAnalysisData && this.priorityAnalysisData.length > 0;
    }

    get hasRecentOrders() {
        return this.recentOrdersData && this.recentOrdersData.length > 0;
    }

    // Lifecycle methods
    connectedCallback() {
        this.processAnalyticsData();
    }

    renderedCallback() {
        if (this.dashboardData || this.recentOrders) {
            this.processAnalyticsData();
        }
    }

    // Data processing methods
    processAnalyticsData() {
        this.processOrderPipelineData();
        this.processOrderTrendsData();
        this.processPriorityAnalysisData();
        this.processRecentOrdersData();
    }

    processOrderPipelineData() {
        if (!this.dashboardData?.ordersByStatus) {
            this.orderPipelineData = [];
            return;
        }

        this.orderPipelineData = Object.keys(this.dashboardData.ordersByStatus).map(status => ({
            label: status,
            value: this.dashboardData.ordersByStatus[status],
            color: this.getStatusColor(status),
            percentage: this.calculatePercentage(
                this.dashboardData.ordersByStatus[status], 
                this.totalOrders
            )
        }));
    }

    processOrderTrendsData() {
        if (!this.dashboardData?.revenueByDay) {
            this.orderTrendsData = [];
            return;
        }

        this.orderTrendsData = this.dashboardData.revenueByDay.map(item => ({
            date: item.dateValue,
            label: this.formatDate(item.dateValue),
            orderCount: Math.floor(Math.random() * 20) + 5, // Mock data
            revenue: item.value,
            formattedRevenue: item.formattedValue
        }));
    }

    processPriorityAnalysisData() {
        // Mock priority data - would come from actual analytics
        const priorities = [
            { label: 'Critical', count: 3, color: '#ea6b66' },
            { label: 'High', count: 8, color: '#ffb75d' },
            { label: 'Medium', count: 15, color: '#4bc076' },
            { label: 'Low', count: 4, color: '#9a77cf' }
        ];

        const totalPriorityOrders = priorities.reduce((sum, p) => sum + p.count, 0);

        this.priorityAnalysisData = priorities.map(priority => ({
            label: priority.label,
            count: priority.count,
            percentage: this.calculatePercentage(priority.count, totalPriorityOrders),
            badgeClass: this.getPriorityBadgeClass(priority.label),
            barStyle: `width: ${this.calculatePercentage(priority.count, totalPriorityOrders)}%; background-color: ${priority.color};`
        }));
    }

    processRecentOrdersData() {
        if (!this.recentOrders) {
            this.recentOrdersData = [];
            return;
        }

        this.recentOrdersData = this.recentOrders.map(order => ({
            orderId: order.orderId,
            orderNumber: order.orderNumber,
            customerName: order.customerName,
            orderStatus: order.orderStatus,
            priority: order.priority,
            formattedTotalAmount: order.formattedTotalAmount,
            formattedOrderDate: order.formattedOrderDate,
            statusClass: order.statusClass,
            priorityClass: order.priorityClass
        }));
    }

    // Event handlers
    handleRefresh() {
        this.isLoading = true;
        
        // Dispatch refresh event to parent
        this.dispatchEvent(new CustomEvent('refresh'));
        
        // Simulate loading delay
        setTimeout(() => {
            this.isLoading = false;
            this.processAnalyticsData();
            this.showToast('Success', 'Order analytics refreshed successfully', 'success');
        }, 1000);
    }

    handleExportData() {
        // Export functionality
        const exportData = {
            metrics: {
                totalOrders: this.totalOrders,
                activeOrders: this.activeOrders,
                pendingOrders: this.pendingOrders,
                averageProcessingTime: this.averageProcessingTime
            },
            pipeline: this.orderPipelineData,
            trends: this.orderTrendsData,
            priorities: this.priorityAnalysisData,
            recentOrders: this.recentOrdersData
        };

        // Create and download JSON file
        const dataStr = JSON.stringify(exportData, null, 2);
        const dataBlob = new Blob([dataStr], { type: 'application/json' });
        const url = URL.createObjectURL(dataBlob);
        const link = document.createElement('a');
        link.href = url;
        link.download = `order-analytics-${new Date().toISOString().split('T')[0]}.json`;
        link.click();
        URL.revokeObjectURL(url);

        this.showToast('Success', 'Order analytics data exported successfully', 'success');
    }

    handleTrendPeriodChange(event) {
        this.selectedTrendPeriod = event.detail.value;
        this.processOrderTrendsData();
    }

    handleStatusClick(event) {
        const status = event.detail.status;
        // Navigate to filtered order list view
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Order__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent',
                // Add status filter if supported
            }
        });
    }

    handleViewAllOrders() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Order__c',
                actionName: 'list'
            },
            state: {
                filterName: 'All'
            }
        });
    }

    handleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        this.sortData(this.sortedBy, this.sortedDirection);
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        switch (actionName) {
            case 'view':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.orderId,
                        actionName: 'view'
                    }
                });
                break;
            case 'edit':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.orderId,
                        actionName: 'edit'
                    }
                });
                break;
        }
    }

    // Utility methods
    calculatePercentage(value, total) {
        return total > 0 ? Math.round((value / total) * 100) : 0;
    }

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
            'Cancelled': '#EA6B66'
        };
        return colorMap[status] || '#747474';
    }

    getPriorityBadgeClass(priority) {
        const classMap = {
            'Critical': 'slds-theme_error',
            'High': 'slds-theme_warning',
            'Medium': 'slds-theme_info',
            'Low': 'slds-theme_success'
        };
        return classMap[priority] || 'slds-theme_default';
    }

    sortData(fieldName, direction) {
        const parseData = JSON.parse(JSON.stringify(this.recentOrdersData));
        const keyValue = (a) => {
            return a[fieldName];
        };
        const isReverse = direction === 'asc' ? 1: -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.recentOrdersData = parseData;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    // Public methods
    @api
    refreshData() {
        this.processAnalyticsData();
    }
}
