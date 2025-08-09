import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class InventoryDashboard extends NavigationMixin(LightningElement) {
    @api inventoryData;
    @api dashboardData;
    
    @track isLoading = false;
    @track inventoryHealthData = [];
    @track categoryStockData = [];
    @track criticalAlerts = [];
    @track reorderRecommendations = [];

    // Computed properties for metrics
    get totalDevices() {
        return this.dashboardData?.totalDevices || 0;
    }

    get inStockDevices() {
        const total = this.totalDevices;
        const low = this.lowStockDevices;
        const out = this.outOfStockDevices;
        return Math.max(0, total - low - out);
    }

    get lowStockDevices() {
        return this.dashboardData?.lowStockDevices || 0;
    }

    get outOfStockDevices() {
        return this.dashboardData?.outOfStockDevices || 0;
    }

    // Data availability checks
    get hasInventoryHealthData() {
        return this.inventoryHealthData && this.inventoryHealthData.length > 0;
    }

    get hasCategoryData() {
        return this.categoryStockData && this.categoryStockData.length > 0;
    }

    get hasCriticalAlerts() {
        return this.criticalAlerts && this.criticalAlerts.length > 0;
    }

    get hasReorderRecommendations() {
        return this.reorderRecommendations && this.reorderRecommendations.length > 0;
    }

    // Lifecycle methods
    connectedCallback() {
        this.processInventoryData();
    }

    renderedCallback() {
        if (this.inventoryData || this.dashboardData) {
            this.processInventoryData();
        }
    }

    // Data processing methods
    processInventoryData() {
        this.processInventoryHealthData();
        this.processCategoryStockData();
        this.processCriticalAlerts();
        this.processReorderRecommendations();
    }

    processInventoryHealthData() {
        const healthData = [
            {
                label: 'In Stock',
                value: this.inStockDevices,
                color: '#4BC076',
                percentage: this.calculatePercentage(this.inStockDevices, this.totalDevices)
            },
            {
                label: 'Low Stock',
                value: this.lowStockDevices,
                color: '#FFB75D',
                percentage: this.calculatePercentage(this.lowStockDevices, this.totalDevices)
            },
            {
                label: 'Out of Stock',
                value: this.outOfStockDevices,
                color: '#EA6B66',
                percentage: this.calculatePercentage(this.outOfStockDevices, this.totalDevices)
            }
        ];

        this.inventoryHealthData = healthData.filter(item => item.value > 0);
    }

    processCategoryStockData() {
        // Mock category data - would come from actual device types
        const categories = [
            { label: 'Computers', inStock: 45, lowStock: 8, outOfStock: 2 },
            { label: 'Software', inStock: 32, lowStock: 5, outOfStock: 1 },
            { label: 'Networking', inStock: 28, lowStock: 3, outOfStock: 0 },
            { label: 'Mobile Devices', inStock: 22, lowStock: 4, outOfStock: 1 },
            { label: 'Storage', inStock: 18, lowStock: 2, outOfStock: 0 }
        ];

        this.categoryStockData = categories.map(category => ({
            category: category.label,
            inStock: category.inStock,
            lowStock: category.lowStock,
            outOfStock: category.outOfStock,
            total: category.inStock + category.lowStock + category.outOfStock,
            healthPercentage: this.calculatePercentage(
                category.inStock, 
                category.inStock + category.lowStock + category.outOfStock
            )
        }));
    }

    processCriticalAlerts() {
        // Mock critical alerts - would come from inventory data
        this.criticalAlerts = [
            {
                deviceId: '1',
                deviceName: 'MacBook Pro 16-inch M3 Max',
                alertMessage: 'Only 2 units remaining - Below minimum stock level',
                alertIcon: 'utility:warning',
                alertIconClass: 'slds-icon-text-warning',
                severity: 'High'
            },
            {
                deviceId: '2',
                deviceName: 'Dell XPS 13 Plus',
                alertMessage: 'Out of stock - Immediate reorder required',
                alertIcon: 'utility:error',
                alertIconClass: 'slds-icon-text-error',
                severity: 'Critical'
            },
            {
                deviceId: '3',
                deviceName: 'Microsoft Surface Pro 9',
                alertMessage: '3 units remaining - Approaching reorder point',
                alertIcon: 'utility:info',
                alertIconClass: 'slds-icon-text-default',
                severity: 'Medium'
            }
        ];
    }

    processReorderRecommendations() {
        // Mock reorder recommendations - would be calculated from demand patterns
        this.reorderRecommendations = [
            {
                deviceId: '1',
                deviceName: 'MacBook Pro 16-inch M3 Max',
                currentStock: 2,
                recommendedQuantity: 15,
                priority: 'High',
                priorityClass: 'slds-theme_warning',
                estimatedCost: '$37,500'
            },
            {
                deviceId: '2',
                deviceName: 'Dell XPS 13 Plus',
                currentStock: 0,
                recommendedQuantity: 20,
                priority: 'Critical',
                priorityClass: 'slds-theme_error',
                estimatedCost: '$24,000'
            },
            {
                deviceId: '4',
                deviceName: 'iPad Pro 12.9-inch',
                currentStock: 5,
                recommendedQuantity: 12,
                priority: 'Medium',
                priorityClass: 'slds-theme_info',
                estimatedCost: '$13,200'
            }
        ];
    }

    // Event handlers
    handleRefresh() {
        this.isLoading = true;
        
        // Dispatch refresh event to parent
        this.dispatchEvent(new CustomEvent('refresh'));
        
        // Simulate loading delay
        setTimeout(() => {
            this.isLoading = false;
            this.processInventoryData();
            this.showToast('Success', 'Inventory data refreshed successfully', 'success');
        }, 1000);
    }

    handleGenerateReport() {
        // Generate inventory report
        const reportData = {
            summary: {
                totalDevices: this.totalDevices,
                inStock: this.inStockDevices,
                lowStock: this.lowStockDevices,
                outOfStock: this.outOfStockDevices,
                healthPercentage: this.calculatePercentage(this.inStockDevices, this.totalDevices)
            },
            healthDistribution: this.inventoryHealthData,
            categoryBreakdown: this.categoryStockData,
            criticalAlerts: this.criticalAlerts,
            reorderRecommendations: this.reorderRecommendations,
            generatedAt: new Date().toISOString()
        };

        // Create and download JSON report
        const dataStr = JSON.stringify(reportData, null, 2);
        const dataBlob = new Blob([dataStr], { type: 'application/json' });
        const url = URL.createObjectURL(dataBlob);
        const link = document.createElement('a');
        link.href = url;
        link.download = `inventory-report-${new Date().toISOString().split('T')[0]}.json`;
        link.click();
        URL.revokeObjectURL(url);

        this.showToast('Success', 'Inventory report generated successfully', 'success');
    }

    handleViewAllAlerts() {
        // Navigate to custom alerts page or show modal
        this.showToast('Info', 'Navigating to detailed alerts view', 'info');
    }

    handleReorder(event) {
        const deviceId = event.target.dataset.deviceId;
        const device = this.criticalAlerts.find(alert => alert.deviceId === deviceId);
        
        if (device) {
            // Navigate to create purchase order or show reorder modal
            this.showToast('Info', `Initiating reorder for ${device.deviceName}`, 'info');
        }
    }

    handleCreatePurchaseOrder() {
        // Create purchase order from recommendations
        const totalItems = this.reorderRecommendations.length;
        const totalEstimatedCost = this.reorderRecommendations.reduce((sum, rec) => {
            const cost = parseFloat(rec.estimatedCost.replace(/[$,]/g, ''));
            return sum + cost;
        }, 0);

        this.showToast('Success', 
            `Purchase order created for ${totalItems} items (Est. $${totalEstimatedCost.toLocaleString()})`, 
            'success');
    }

    // Utility methods
    calculatePercentage(value, total) {
        return total > 0 ? Math.round((value / total) * 100) : 0;
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
        this.processInventoryData();
    }

    @api
    getInventoryHealth() {
        return {
            totalDevices: this.totalDevices,
            inStock: this.inStockDevices,
            lowStock: this.lowStockDevices,
            outOfStock: this.outOfStockDevices,
            healthPercentage: this.calculatePercentage(this.inStockDevices, this.totalDevices),
            criticalAlertsCount: this.criticalAlerts.length,
            reorderRecommendationsCount: this.reorderRecommendations.length
        };
    }
}
