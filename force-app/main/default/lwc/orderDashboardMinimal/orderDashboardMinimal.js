/**
 * OrderDashboardMinimal - Enhanced Analytics Dashboard Lightning Web Component
 *
 * Educational Purpose: Demonstrates advanced dashboard features with incremental enhancement
 * This enhanced component provides comprehensive analytics, charts, and real-time data
 *
 * Part of: TechSolutionApp Phase 4.3 - Advanced Dashboard Features
 * Author: TechSolutionApp Educational Platform
 * Created: August 2024
 * Enhanced: August 2024 - Phase 4.3 Implementation
 *
 * Features:
 * - Chart visualizations (bar charts, pie charts, trend lines)
 * - Real-time data refresh with configurable intervals
 * - Advanced filtering and search capabilities
 * - Comprehensive analytics widgets
 * - Enterprise-level error handling and performance optimization
 */
import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

// Basic methods
import getOrderCount from '@salesforce/apex/OrderDashboardMinimal.getOrderCount';
import getDeviceCount from '@salesforce/apex/OrderDashboardMinimal.getDeviceCount';
import testConnection from '@salesforce/apex/OrderDashboardMinimal.testConnection';

// Advanced analytics methods
import getOrderTrendData from '@salesforce/apex/OrderDashboardMinimal.getOrderTrendData';
import getDevicePopularityData from '@salesforce/apex/OrderDashboardMinimal.getDevicePopularityData';
import getDashboardMetrics from '@salesforce/apex/OrderDashboardMinimal.getDashboardMetrics';
import getFilteredOrders from '@salesforce/apex/OrderDashboardMinimal.getFilteredOrders';
import getDeviceFilterOptions from '@salesforce/apex/OrderDashboardMinimal.getDeviceFilterOptions';

export default class OrderDashboardMinimal extends LightningElement {

    // ========================================
    // REACTIVE PROPERTIES FOR DATA BINDING
    // ========================================

    // Basic metrics
    orderCount = 0;
    deviceCount = 0;
    connectionStatus = '';
    isLoading = false;
    error;

    // Advanced analytics data
    @track orderTrendData = [];
    @track devicePopularityData = [];
    @track dashboardMetrics = {};
    @track filteredOrders = [];
    @track deviceFilterOptions = [];

    // Real-time refresh configuration
    @track refreshInterval = 30000; // 30 seconds default
    @track autoRefreshEnabled = false;
    refreshIntervalId;

    // Advanced filtering properties
    @track searchTerm = '';
    @track selectedDeviceFilter = 'All';
    @track dateFromFilter = '';
    @track dateToFilter = '';
    @track orderLimit = 50;

    // UI state management
    @track showCharts = true;
    @track showFilters = false;
    @track activeTab = 'overview';
    @track chartType = 'bar'; // bar, pie, line

    // ========================================
    // WIRE METHODS FOR REACTIVE DATA
    // ========================================

    // Basic metrics wire methods
    @wire(getOrderCount)
    wiredOrderCount({ error, data }) {
        if (data !== undefined) {
            this.orderCount = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.orderCount = 0;
        }
    }

    @wire(getDeviceCount)
    wiredDeviceCount({ error, data }) {
        if (data !== undefined) {
            this.deviceCount = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.deviceCount = 0;
        }
    }

    // Advanced analytics wire methods
    @wire(getOrderTrendData)
    wiredOrderTrendData({ error, data }) {
        if (data) {
            this.orderTrendData = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.orderTrendData = [];
        }
    }

    @wire(getDevicePopularityData)
    wiredDevicePopularityData({ error, data }) {
        if (data) {
            this.devicePopularityData = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.devicePopularityData = [];
        }
    }

    @wire(getDashboardMetrics)
    wiredDashboardMetrics({ error, data }) {
        if (data) {
            this.dashboardMetrics = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.dashboardMetrics = {};
        }
    }

    @wire(getDeviceFilterOptions)
    wiredDeviceFilterOptions({ error, data }) {
        if (data) {
            this.deviceFilterOptions = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.deviceFilterOptions = [];
        }
    }

    // ========================================
    // LIFECYCLE HOOKS
    // ========================================

    connectedCallback() {
        // Initialize component
        this.loadFilteredOrders();

        // Set up auto-refresh if enabled
        if (this.autoRefreshEnabled) {
            this.startAutoRefresh();
        }
    }

    disconnectedCallback() {
        // Clean up auto-refresh interval
        this.stopAutoRefresh();
    }

    // ========================================
    // BASIC FUNCTIONALITY
    // ========================================

    // Test connection method
    handleTestConnection() {
        this.isLoading = true;
        testConnection()
            .then(result => {
                this.connectionStatus = result;
                this.showToast('Success', 'Connection test successful!', 'success');
            })
            .catch(error => {
                this.error = error;
                this.showToast('Error', 'Connection test failed', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    // ========================================
    // ADVANCED FILTERING FUNCTIONALITY
    // ========================================

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
        this.debounceSearch();
    }

    handleDeviceFilterChange(event) {
        this.selectedDeviceFilter = event.target.value;
        this.loadFilteredOrders();
    }

    handleDateFromChange(event) {
        this.dateFromFilter = event.target.value;
        this.loadFilteredOrders();
    }

    handleDateToChange(event) {
        this.dateToFilter = event.target.value;
        this.loadFilteredOrders();
    }

    handleLimitChange(event) {
        this.orderLimit = parseInt(event.target.value, 10);
        this.loadFilteredOrders();
    }

    // Debounced search to avoid excessive API calls
    debounceSearch() {
        clearTimeout(this.searchTimeout);
        this.searchTimeout = setTimeout(() => {
            this.loadFilteredOrders();
        }, 500);
    }

    // Load filtered orders based on current filter criteria
    loadFilteredOrders() {
        this.isLoading = true;

        getFilteredOrders({
            searchTerm: this.searchTerm,
            deviceFilter: this.selectedDeviceFilter,
            dateFrom: this.dateFromFilter,
            dateTo: this.dateToFilter,
            limitSize: this.orderLimit
        })
        .then(result => {
            this.filteredOrders = result;
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.filteredOrders = [];
            this.showToast('Error', 'Failed to load filtered orders', 'error');
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    // Clear all filters
    handleClearFilters() {
        this.searchTerm = '';
        this.selectedDeviceFilter = 'All';
        this.dateFromFilter = '';
        this.dateToFilter = '';
        this.orderLimit = 50;
        this.loadFilteredOrders();
    }

    // ========================================
    // REAL-TIME REFRESH FUNCTIONALITY
    // ========================================

    handleAutoRefreshToggle(event) {
        this.autoRefreshEnabled = event.target.checked;

        if (this.autoRefreshEnabled) {
            this.startAutoRefresh();
            this.showToast('Success', 'Auto-refresh enabled', 'success');
        } else {
            this.stopAutoRefresh();
            this.showToast('Info', 'Auto-refresh disabled', 'info');
        }
    }

    handleRefreshIntervalChange(event) {
        this.refreshInterval = parseInt(event.target.value, 10) * 1000; // Convert to milliseconds

        if (this.autoRefreshEnabled) {
            this.stopAutoRefresh();
            this.startAutoRefresh();
        }
    }

    startAutoRefresh() {
        this.refreshIntervalId = setInterval(() => {
            this.refreshAllData();
        }, this.refreshInterval);
    }

    stopAutoRefresh() {
        if (this.refreshIntervalId) {
            clearInterval(this.refreshIntervalId);
            this.refreshIntervalId = null;
        }
    }

    handleManualRefresh() {
        this.refreshAllData();
        this.showToast('Success', 'Dashboard refreshed', 'success');
    }

    refreshAllData() {
        // Refresh all wired data
        return Promise.all([
            refreshApex(this.wiredOrderCount),
            refreshApex(this.wiredDeviceCount),
            refreshApex(this.wiredOrderTrendData),
            refreshApex(this.wiredDevicePopularityData),
            refreshApex(this.wiredDashboardMetrics),
            refreshApex(this.wiredDeviceFilterOptions)
        ]).then(() => {
            this.loadFilteredOrders();
        }).catch(error => {
            this.error = error;
            this.showToast('Error', 'Failed to refresh data', 'error');
        });
    }

    // ========================================
    // UI STATE MANAGEMENT
    // ========================================

    handleTabChange(event) {
        this.activeTab = event.target.value;
    }

    handleToggleCharts() {
        this.showCharts = !this.showCharts;
    }

    handleToggleFilters() {
        this.showFilters = !this.showFilters;
    }

    handleChartTypeChange(event) {
        this.chartType = event.target.value;
    }

    // ========================================
    // UTILITY METHODS
    // ========================================

    // Utility method for toast messages
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    // Getter for displaying error messages
    get errorMessage() {
        return this.error ? this.error.body?.message || this.error.message : '';
    }

    // Getters for UI state
    get isOverviewTab() {
        return this.activeTab === 'overview';
    }

    get isChartsTab() {
        return this.activeTab === 'charts';
    }

    get isOrdersTab() {
        return this.activeTab === 'orders';
    }

    get refreshIntervalOptions() {
        return [
            { label: '10 seconds', value: '10' },
            { label: '30 seconds', value: '30' },
            { label: '1 minute', value: '60' },
            { label: '5 minutes', value: '300' }
        ];
    }

    get chartTypeOptions() {
        return [
            { label: 'Bar Chart', value: 'bar' },
            { label: 'Pie Chart', value: 'pie' },
            { label: 'Line Chart', value: 'line' }
        ];
    }

    get hasOrderTrendData() {
        return this.orderTrendData && this.orderTrendData.length > 0;
    }

    get hasDevicePopularityData() {
        return this.devicePopularityData && this.devicePopularityData.length > 0;
    }

    get hasFilteredOrders() {
        return this.filteredOrders && this.filteredOrders.length > 0;
    }
}
