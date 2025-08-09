import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CustomerDashboard extends NavigationMixin(LightningElement) {
    @api customerAnalytics;
    @api dashboardData;
    
    @track isLoading = false;
    @track customerTierData = [];
    @track lifetimeValueRanges = [];
    @track topCustomers = [];
    @track customerInsights = [];

    // Computed properties for metrics
    get totalCustomers() {
        // Mock data - would come from actual analytics
        return 47;
    }

    get activeCustomers() {
        // Mock data - would come from actual analytics
        return 42;
    }

    get vipCustomers() {
        // Mock data - would come from actual analytics
        return 8;
    }

    get averageOrderValue() {
        return this.dashboardData?.formattedAverageOrderValue || '$2,450';
    }

    get totalLifetimeValue() {
        return '$485,750';
    }

    get averageLifetimeValue() {
        return '$10,335';
    }

    // Data availability checks
    get hasCustomerTierData() {
        return this.customerTierData && this.customerTierData.length > 0;
    }

    get hasLifetimeValueData() {
        return this.lifetimeValueRanges && this.lifetimeValueRanges.length > 0;
    }

    get hasTopCustomers() {
        return this.topCustomers && this.topCustomers.length > 0;
    }

    get hasCustomerInsights() {
        return this.customerInsights && this.customerInsights.length > 0;
    }

    // Lifecycle methods
    connectedCallback() {
        this.processCustomerData();
    }

    renderedCallback() {
        if (this.customerAnalytics || this.dashboardData) {
            this.processCustomerData();
        }
    }

    // Data processing methods
    processCustomerData() {
        this.processCustomerTierData();
        this.processLifetimeValueData();
        this.processTopCustomers();
        this.processCustomerInsights();
    }

    processCustomerTierData() {
        // Mock customer tier data - would come from actual analytics
        const tiers = [
            { label: 'Platinum', count: 3, color: '#9a77cf' },
            { label: 'Gold', count: 5, color: '#ffb75d' },
            { label: 'Silver', count: 12, color: '#5ddaff' },
            { label: 'Bronze', count: 27, color: '#4bc076' }
        ];

        const totalCustomers = tiers.reduce((sum, tier) => sum + tier.count, 0);

        this.customerTierData = tiers.map(tier => ({
            label: tier.label,
            count: tier.count,
            percentage: this.calculatePercentage(tier.count, totalCustomers),
            badgeClass: this.getTierBadgeClass(tier.label),
            barStyle: `width: ${this.calculatePercentage(tier.count, totalCustomers)}%; background-color: ${tier.color};`
        }));
    }

    processLifetimeValueData() {
        // Mock lifetime value ranges - would come from actual analytics
        const ranges = [
            { label: '$100K+', count: 3, color: '#9a77cf' },
            { label: '$50K - $100K', count: 5, color: '#0176d3' },
            { label: '$25K - $50K', count: 8, color: '#4bc076' },
            { label: '$10K - $25K', count: 15, color: '#ffb75d' },
            { label: 'Under $10K', count: 16, color: '#ea6b66' }
        ];

        const maxCount = Math.max(...ranges.map(r => r.count));

        this.lifetimeValueRanges = ranges.map(range => ({
            label: range.label,
            count: range.count,
            barStyle: `width: ${this.calculatePercentage(range.count, maxCount)}%; background-color: ${range.color};`
        }));
    }

    processTopCustomers() {
        // Mock top customers data - would come from actual analytics
        this.topCustomers = [
            {
                customerId: '1',
                customerName: 'Acme Corporation',
                totalValue: '$125,750',
                orderCount: 15,
                lastOrderDate: '2024-01-15',
                tier: 'Platinum',
                tierClass: 'slds-theme_success'
            },
            {
                customerId: '2',
                customerName: 'Global Tech Solutions',
                totalValue: '$89,500',
                orderCount: 12,
                lastOrderDate: '2024-01-12',
                tier: 'Gold',
                tierClass: 'slds-theme_warning'
            },
            {
                customerId: '3',
                customerName: 'Innovation Labs Inc',
                totalValue: '$67,250',
                orderCount: 8,
                lastOrderDate: '2024-01-10',
                tier: 'Gold',
                tierClass: 'slds-theme_warning'
            },
            {
                customerId: '4',
                customerName: 'Digital Dynamics',
                totalValue: '$45,800',
                orderCount: 6,
                lastOrderDate: '2024-01-08',
                tier: 'Silver',
                tierClass: 'slds-theme_info'
            },
            {
                customerId: '5',
                customerName: 'Future Systems LLC',
                totalValue: '$38,900',
                orderCount: 5,
                lastOrderDate: '2024-01-05',
                tier: 'Silver',
                tierClass: 'slds-theme_info'
            }
        ];
    }

    processCustomerInsights() {
        // Mock customer insights - would come from actual analytics
        this.customerInsights = [
            {
                id: '1',
                title: 'High-Value Customer Growth',
                description: '15% increase in customers with orders over $50K in the last quarter.',
                icon: 'utility:trending',
                iconClass: 'slds-icon-text-success'
            },
            {
                id: '2',
                title: 'Customer Retention Rate',
                description: '92% of customers have placed repeat orders within 6 months.',
                icon: 'utility:success',
                iconClass: 'slds-icon-text-success'
            },
            {
                id: '3',
                title: 'Average Order Frequency',
                description: 'VIP customers place orders 3.2x more frequently than standard customers.',
                icon: 'utility:clock',
                iconClass: 'slds-icon-text-default'
            },
            {
                id: '4',
                title: 'Upsell Opportunity',
                description: '23 customers are approaching tier upgrade thresholds.',
                icon: 'utility:opportunity',
                iconClass: 'slds-icon-text-warning'
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
            this.processCustomerData();
            this.showToast('Success', 'Customer analytics refreshed successfully', 'success');
        }, 1000);
    }

    handleViewAllCustomers() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Customer__c',
                actionName: 'list'
            },
            state: {
                filterName: 'All'
            }
        });
    }

    // Utility methods
    calculatePercentage(value, total) {
        return total > 0 ? Math.round((value / total) * 100) : 0;
    }

    getTierBadgeClass(tier) {
        const classMap = {
            'Platinum': 'slds-theme_success',
            'Gold': 'slds-theme_warning',
            'Silver': 'slds-theme_info',
            'Bronze': 'slds-theme_default'
        };
        return classMap[tier] || 'slds-theme_default';
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
        this.processCustomerData();
    }

    @api
    getCustomerSummary() {
        return {
            totalCustomers: this.totalCustomers,
            activeCustomers: this.activeCustomers,
            vipCustomers: this.vipCustomers,
            averageOrderValue: this.averageOrderValue,
            totalLifetimeValue: this.totalLifetimeValue,
            averageLifetimeValue: this.averageLifetimeValue,
            tierDistribution: this.customerTierData,
            topCustomersCount: this.topCustomers.length,
            insightsCount: this.customerInsights.length
        };
    }
}
