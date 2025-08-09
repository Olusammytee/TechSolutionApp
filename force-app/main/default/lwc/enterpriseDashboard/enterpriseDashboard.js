import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

// Import Apex methods from AnalyticsService
import getDashboardData from '@salesforce/apex/AnalyticsService.getDashboardData';
import getInventoryAnalytics from '@salesforce/apex/AnalyticsService.getInventoryAnalytics';
import getCustomerAnalytics from '@salesforce/apex/AnalyticsService.getCustomerAnalytics';
import getRecentOrders from '@salesforce/apex/AnalyticsService.getRecentOrders';
import getPerformanceMetrics from '@salesforce/apex/AnalyticsService.getPerformanceMetrics';

export default class EnterpriseDashboard extends LightningElement {
    // Component state
    @track isLoading = true;
    @track error = null;
    @track activeTab = 'executive';
    @track showSettings = false;
    @track lastUpdated = '';
    @track loadTime = 0;
    @track totalDataPoints = 0;

    // Dashboard data
    @track dashboardData = null;
    @track inventoryData = null;
    @track customerAnalytics = null;
    @track recentOrders = null;
    @track performanceMetrics = null;

    // Settings
    @track refreshInterval = '300000'; // 5 minutes default
    @track enableRealTimeUpdates = true;
    @track showPerformanceMetrics = true;

    // Private properties
    _refreshIntervalId = null;
    _startTime = 0;

    // Refresh interval options
    refreshIntervalOptions = [
        { label: 'Never', value: '0' },
        { label: '1 minute', value: '60000' },
        { label: '5 minutes', value: '300000' },
        { label: '10 minutes', value: '600000' },
        { label: '30 minutes', value: '1800000' }
    ];

    // Wire methods for cacheable data
    @wire(getDashboardData, { 
        startDate: '$startDate', 
        endDate: '$endDate' 
    })
    wiredDashboardData(result) {
        this._dashboardDataResult = result;
        if (result.data) {
            this.dashboardData = result.data;
            this.calculateDataPoints();
            this.error = null;
        } else if (result.error) {
            this.error = this.getErrorMessage(result.error);
            this.dashboardData = null;
        }
        this.updateLoadingState();
    }

    @wire(getInventoryAnalytics)
    wiredInventoryData(result) {
        this._inventoryDataResult = result;
        if (result.data) {
            this.inventoryData = result.data;
            this.error = null;
        } else if (result.error) {
            this.error = this.getErrorMessage(result.error);
            this.inventoryData = null;
        }
        this.updateLoadingState();
    }

    @wire(getRecentOrders, { limitCount: 10 })
    wiredRecentOrders(result) {
        this._recentOrdersResult = result;
        if (result.data) {
            this.recentOrders = result.data;
            this.error = null;
        } else if (result.error) {
            this.error = this.getErrorMessage(result.error);
            this.recentOrders = null;
        }
        this.updateLoadingState();
    }

    @wire(getPerformanceMetrics)
    wiredPerformanceMetrics(result) {
        this._performanceMetricsResult = result;
        if (result.data) {
            this.performanceMetrics = result.data;
            this.error = null;
        } else if (result.error) {
            this.error = this.getErrorMessage(result.error);
            this.performanceMetrics = null;
        }
        this.updateLoadingState();
    }

    // Lifecycle methods
    connectedCallback() {
        this._startTime = performance.now();
        this.setDateRange();
        this.setupAutoRefresh();
        this.updateLastUpdated();
    }

    disconnectedCallback() {
        this.clearAutoRefresh();
    }

    // Computed properties
    get startDate() {
        const date = new Date();
        date.setDate(date.getDate() - 30); // Last 30 days
        return date.toISOString().split('T')[0];
    }

    get endDate() {
        return new Date().toISOString().split('T')[0];
    }

    // Event handlers
    handleTabChange(event) {
        this.activeTab = event.target.value;
        this.trackTabUsage(this.activeTab);
    }

    handleRefresh() {
        this.refreshAllData();
    }

    handleSettings() {
        this.showSettings = true;
    }

    handleCloseSettings() {
        this.showSettings = false;
    }

    handleSaveSettings() {
        this.setupAutoRefresh();
        this.showSettings = false;
        this.showToast('Success', 'Dashboard settings saved successfully', 'success');
    }

    handleRefreshIntervalChange(event) {
        this.refreshInterval = event.detail.value;
    }

    handleRealTimeToggle(event) {
        this.enableRealTimeUpdates = event.target.checked;
    }

    handlePerformanceToggle(event) {
        this.showPerformanceMetrics = event.target.checked;
    }

    handleChildRefresh() {
        this.refreshAllData();
    }

    // Data management methods
    async refreshAllData() {
        this.isLoading = true;
        this._startTime = performance.now();
        
        try {
            // Refresh all wired data
            await Promise.all([
                refreshApex(this._dashboardDataResult),
                refreshApex(this._inventoryDataResult),
                refreshApex(this._recentOrdersResult),
                refreshApex(this._performanceMetricsResult)
            ]);

            // Refresh customer analytics separately (not wired)
            await this.refreshCustomerAnalytics();

            this.updateLastUpdated();
            this.showToast('Success', 'Dashboard data refreshed successfully', 'success');
        } catch (error) {
            this.error = this.getErrorMessage(error);
            this.showToast('Error', 'Failed to refresh dashboard data', 'error');
        } finally {
            this.isLoading = false;
            this.calculateLoadTime();
        }
    }

    async refreshCustomerAnalytics() {
        try {
            const result = await getCustomerAnalytics({ 
                startDate: this.startDate, 
                endDate: this.endDate 
            });
            this.customerAnalytics = result;
        } catch (error) {
            console.error('Error refreshing customer analytics:', error);
        }
    }

    // Utility methods
    updateLoadingState() {
        // Check if all data has been loaded
        const dataLoaded = this.dashboardData !== null && 
                          this.inventoryData !== null && 
                          this.recentOrders !== null && 
                          this.performanceMetrics !== null;
        
        if (dataLoaded && this.isLoading) {
            this.isLoading = false;
            this.calculateLoadTime();
            this.updateLastUpdated();
        }
    }

    calculateLoadTime() {
        this.loadTime = Math.round(performance.now() - this._startTime);
    }

    calculateDataPoints() {
        let points = 0;
        if (this.dashboardData) {
            points += this.dashboardData.totalOrders || 0;
            points += this.dashboardData.totalDevices || 0;
            points += (this.dashboardData.revenueByDay || []).length;
        }
        if (this.inventoryData) {
            points += this.inventoryData.length;
        }
        if (this.recentOrders) {
            points += this.recentOrders.length;
        }
        this.totalDataPoints = points;
    }

    updateLastUpdated() {
        this.lastUpdated = new Date().toLocaleString();
    }

    setDateRange() {
        // Set default date range for dashboard
        this.startDate = this.startDate;
        this.endDate = this.endDate;
    }

    setupAutoRefresh() {
        this.clearAutoRefresh();
        
        if (this.refreshInterval && this.refreshInterval !== '0') {
            this._refreshIntervalId = setInterval(() => {
                if (this.enableRealTimeUpdates) {
                    this.refreshAllData();
                }
            }, parseInt(this.refreshInterval, 10));
        }
    }

    clearAutoRefresh() {
        if (this._refreshIntervalId) {
            clearInterval(this._refreshIntervalId);
            this._refreshIntervalId = null;
        }
    }

    getErrorMessage(error) {
        if (error && error.body && error.body.message) {
            return error.body.message;
        } else if (error && error.message) {
            return error.message;
        } else if (typeof error === 'string') {
            return error;
        }
        return 'An unexpected error occurred';
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    trackTabUsage(tabName) {
        // Analytics tracking for tab usage
        console.log(`Dashboard tab accessed: ${tabName}`);
    }
}
