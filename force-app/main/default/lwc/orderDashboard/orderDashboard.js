/**
 * Order Dashboard Lightning Web Component
 * 
 * Educational Purpose: Demonstrates comprehensive LWC development patterns
 * This component showcases the complete order processing workflow:
 * - Real-time data visualization
 * - Interactive user interface
 * - Integration with Apex backend
 * - Responsive design patterns
 * - Error handling and user feedback
 * 
 * Key Learning Concepts:
 * - LWC lifecycle hooks
 * - Apex method integration with @wire
 * - Event handling and data binding
 * - Conditional rendering
 * - Lightning Design System (SLDS)
 * - Real-time data refresh patterns
 * 
 * Part of: TechSolutionApp Phase 4.1 - Interactive Learning Components
 * Author: TechSolutionApp Educational Platform
 * Created: August 2024
 */

import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

// Educational Note: Import Apex methods for LWC integration
import getRecentOrders from '@salesforce/apex/OrderDashboardController.getRecentOrders';
import getStockSummary from '@salesforce/apex/OrderDashboardController.getStockSummary';
import getOrderTrends from '@salesforce/apex/OrderDashboardController.getOrderTrends';
import getAvailableDevices from '@salesforce/apex/OrderDashboardController.getAvailableDevices';
import createOrder from '@salesforce/apex/OrderDashboardController.createOrder';

export default class OrderDashboard extends LightningElement {
    // Educational Note: Reactive properties for data binding
    @track recentOrders = [];
    @track stockSummary = {};
    @track orderTrends = [];
    @track availableDevices = [];
    @track isLoading = false;
    @track error = null;
    
    // Educational Note: Properties for order creation form
    @track selectedDeviceId = '';
    @track orderQuantity = 1;
    @track showOrderForm = false;
    
    // Educational Note: Properties for filtering and pagination
    @track orderLimit = 10;
    @track trendDays = 30;
    @track selectedStatusFilter = 'All';
    
    // Educational Note: Wired properties for reactive data
    wiredOrdersResult;
    wiredStockResult;
    wiredTrendsResult;
    wiredDevicesResult;
    
    /**
     * Wire recent orders with reactive parameters
     * Educational Value: Demonstrates @wire decorator with parameters
     */
    @wire(getRecentOrders, { limitCount: '$orderLimit' })
    wiredOrders(result) {
        this.wiredOrdersResult = result;
        if (result.data) {
            this.recentOrders = result.data;
            this.error = null;
        } else if (result.error) {
            this.error = result.error;
            this.recentOrders = [];
        }
    }
    
    /**
     * Wire stock summary for dashboard widgets
     * Educational Value: Demonstrates cacheable data patterns
     */
    @wire(getStockSummary)
    wiredStock(result) {
        this.wiredStockResult = result;
        if (result.data) {
            this.stockSummary = result.data;
            this.error = null;
        } else if (result.error) {
            this.error = result.error;
            this.stockSummary = {};
        }
    }
    
    /**
     * Wire order trends for chart visualization
     * Educational Value: Demonstrates dynamic parameter binding
     */
    @wire(getOrderTrends, { days: '$trendDays' })
    wiredTrends(result) {
        this.wiredTrendsResult = result;
        if (result.data) {
            this.orderTrends = result.data;
            this.error = null;
        } else if (result.error) {
            this.error = result.error;
            this.orderTrends = [];
        }
    }
    
    /**
     * Wire available devices for order creation
     * Educational Value: Demonstrates filtered data retrieval
     */
    @wire(getAvailableDevices)
    wiredDevices(result) {
        this.wiredDevicesResult = result;
        if (result.data) {
            this.availableDevices = result.data;
            this.error = null;
        } else if (result.error) {
            this.error = result.error;
            this.availableDevices = [];
        }
    }
    
    /**
     * Component lifecycle - connected callback
     * Educational Value: Demonstrates LWC lifecycle hooks
     */
    connectedCallback() {
        // Educational Note: Set up periodic refresh for real-time updates
        this.setupAutoRefresh();
    }
    
    /**
     * Component lifecycle - disconnected callback
     * Educational Value: Demonstrates cleanup patterns
     */
    disconnectedCallback() {
        // Educational Note: Clean up intervals to prevent memory leaks
        if (this.refreshInterval) {
            clearInterval(this.refreshInterval);
        }
    }
    
    /**
     * Set up automatic data refresh
     * Educational Value: Demonstrates real-time data patterns
     */
    setupAutoRefresh() {
        // Educational Note: Refresh data every 30 seconds for real-time updates
        this.refreshInterval = setInterval(() => {
            this.refreshAllData();
        }, 30000);
    }
    
    /**
     * Refresh all dashboard data
     * Educational Value: Demonstrates manual data refresh patterns
     */
    async refreshAllData() {
        try {
            // Educational Note: Use refreshApex for wired data refresh
            await Promise.all([
                refreshApex(this.wiredOrdersResult),
                refreshApex(this.wiredStockResult),
                refreshApex(this.wiredTrendsResult),
                refreshApex(this.wiredDevicesResult)
            ]);
            
            this.showToast('Success', 'Dashboard data refreshed', 'success');
        } catch (error) {
            this.showToast('Error', 'Failed to refresh data: ' + error.body.message, 'error');
        }
    }
    
    /**
     * Handle manual refresh button click
     * Educational Value: Demonstrates user-initiated actions
     */
    handleRefresh() {
        this.isLoading = true;
        this.refreshAllData().finally(() => {
            this.isLoading = false;
        });
    }
    
    /**
     * Handle order limit change
     * Educational Value: Demonstrates reactive parameter updates
     */
    handleOrderLimitChange(event) {
        this.orderLimit = parseInt(event.target.value, 10);
    }
    
    /**
     * Handle trend days change
     * Educational Value: Demonstrates dynamic chart updates
     */
    handleTrendDaysChange(event) {
        this.trendDays = parseInt(event.target.value, 10);
    }
    
    /**
     * Handle status filter change
     * Educational Value: Demonstrates client-side filtering
     */
    handleStatusFilterChange(event) {
        this.selectedStatusFilter = event.target.value;
    }
    
    /**
     * Show order creation form
     * Educational Value: Demonstrates modal/form patterns
     */
    showCreateOrderForm() {
        this.showOrderForm = true;
        this.selectedDeviceId = '';
        this.orderQuantity = 1;
    }
    
    /**
     * Hide order creation form
     * Educational Value: Demonstrates form state management
     */
    hideCreateOrderForm() {
        this.showOrderForm = false;
    }
    
    /**
     * Handle device selection change
     * Educational Value: Demonstrates form field binding
     */
    handleDeviceChange(event) {
        this.selectedDeviceId = event.target.value;
    }
    
    /**
     * Handle quantity change
     * Educational Value: Demonstrates numeric input handling
     */
    handleQuantityChange(event) {
        this.orderQuantity = parseInt(event.target.value, 10);
    }
    
    /**
     * Create new order
     * Educational Value: Demonstrates imperative Apex calls
     */
    async handleCreateOrder() {
        if (!this.selectedDeviceId || this.orderQuantity <= 0) {
            this.showToast('Error', 'Please select a device and enter a valid quantity', 'error');
            return;
        }
        
        this.isLoading = true;
        
        try {
            const confirmationNumber = await createOrder({
                deviceId: this.selectedDeviceId,
                quantity: this.orderQuantity
            });
            
            this.showToast('Success', `Order created successfully! Confirmation: ${confirmationNumber}`, 'success');
            this.hideCreateOrderForm();
            
            // Educational Note: Refresh data to show new order
            await this.refreshAllData();
            
        } catch (error) {
            this.showToast('Error', 'Failed to create order: ' + error.body.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }
    
    /**
     * Show toast notification
     * Educational Value: Demonstrates user feedback patterns
     */
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    
    /**
     * Getter for filtered orders
     * Educational Value: Demonstrates computed properties
     */
    get filteredOrders() {
        if (this.selectedStatusFilter === 'All') {
            return this.recentOrders;
        }
        return this.recentOrders.filter(order => order.status === this.selectedStatusFilter);
    }
    
    /**
     * Getter for stock status CSS classes
     * Educational Value: Demonstrates dynamic styling
     */
    getStockStatusClass(status) {
        switch (status) {
            case 'In Stock':
                return 'slds-text-color_success';
            case 'Low Stock':
                return 'slds-text-color_warning';
            case 'Out of Stock':
                return 'slds-text-color_error';
            default:
                return '';
        }
    }
    
    /**
     * Getter for order status options
     * Educational Value: Demonstrates dynamic option generation
     */
    get statusOptions() {
        return [
            { label: 'All Orders', value: 'All' },
            { label: 'Draft', value: 'Draft' },
            { label: 'Confirmed', value: 'Confirmed' },
            { label: 'Shipped', value: 'Shipped' },
            { label: 'Delivered', value: 'Delivered' }
        ];
    }
    
    /**
     * Getter for device options
     * Educational Value: Demonstrates data transformation
     */
    get deviceOptions() {
        return this.availableDevices.map(device => ({
            label: `${device.name} - $${device.price} (Stock: ${device.stockQuantity})`,
            value: device.id
        }));
    }

    /**
     * Getter for trend chart data
     * Educational Value: Demonstrates chart data preparation
     */
    get chartData() {
        return this.orderTrends.map(trend => ({
            date: trend.orderDate,
            orders: trend.orderCount,
            revenue: trend.totalRevenue
        }));
    }
}
