import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PerformanceDashboard extends LightningElement {
    @api performanceMetrics;
    
    @track isLoading = false;
    @track performanceRecommendations = [];
    @track performanceHistory = [];

    // Data table columns for performance history
    historyColumns = [
        {
            label: 'Timestamp',
            fieldName: 'formattedTimestamp',
            type: 'text',
            sortable: true
        },
        {
            label: 'SOQL (%)',
            fieldName: 'soqlUtilization',
            type: 'number',
            sortable: true,
            cellAttributes: { alignment: 'center' }
        },
        {
            label: 'CPU (%)',
            fieldName: 'cpuUtilization',
            type: 'number',
            sortable: true,
            cellAttributes: { alignment: 'center' }
        },
        {
            label: 'DML (%)',
            fieldName: 'dmlUtilization',
            type: 'number',
            sortable: true,
            cellAttributes: { alignment: 'center' }
        },
        {
            label: 'Load Time (ms)',
            fieldName: 'loadTime',
            type: 'number',
            sortable: true,
            cellAttributes: { alignment: 'right' }
        }
    ];

    // Computed properties for metrics
    get soqlQueries() {
        return this.performanceMetrics?.soqlQueries || 0;
    }

    get soqlQueryLimit() {
        return this.performanceMetrics?.soqlQueryLimit || 100;
    }

    get soqlUtilization() {
        return Math.round(this.performanceMetrics?.soqlUtilization || 0);
    }

    get cpuTime() {
        return this.performanceMetrics?.cpuTime || 0;
    }

    get cpuTimeLimit() {
        return this.performanceMetrics?.cpuTimeLimit || 10000;
    }

    get cpuUtilization() {
        return Math.round(this.performanceMetrics?.cpuUtilization || 0);
    }

    get dmlStatements() {
        return this.performanceMetrics?.dmlStatements || 0;
    }

    get dmlStatementLimit() {
        return this.performanceMetrics?.dmlStatementLimit || 150;
    }

    get dmlUtilization() {
        return Math.round(this.performanceMetrics?.dmlUtilization || 0);
    }

    get dashboardLoadTime() {
        // Mock dashboard load time - would come from actual performance tracking
        return Math.floor(Math.random() * 2000) + 500; // 500-2500ms
    }

    // Progress bar styles
    get soqlBarStyle() {
        const utilization = this.soqlUtilization;
        const color = this.getUtilizationColor(utilization);
        return `width: ${utilization}%; background-color: ${color};`;
    }

    get cpuBarStyle() {
        const utilization = this.cpuUtilization;
        const color = this.getUtilizationColor(utilization);
        return `width: ${utilization}%; background-color: ${color};`;
    }

    get dmlBarStyle() {
        const utilization = this.dmlUtilization;
        const color = this.getUtilizationColor(utilization);
        return `width: ${utilization}%; background-color: ${color};`;
    }

    // Data availability checks
    get hasRecommendations() {
        return this.performanceRecommendations && this.performanceRecommendations.length > 0;
    }

    get hasPerformanceHistory() {
        return this.performanceHistory && this.performanceHistory.length > 0;
    }

    // Lifecycle methods
    connectedCallback() {
        this.generatePerformanceRecommendations();
        this.generatePerformanceHistory();
    }

    renderedCallback() {
        if (this.performanceMetrics) {
            this.generatePerformanceRecommendations();
        }
    }

    // Data processing methods
    generatePerformanceRecommendations() {
        const recommendations = [];

        // Check SOQL utilization
        if (this.soqlUtilization > 80) {
            recommendations.push({
                id: 'soql-high',
                title: 'High SOQL Query Usage',
                description: 'Consider optimizing queries with selective SOQL and proper indexing.',
                impact: 'High Impact',
                impactClass: 'slds-theme_error',
                icon: 'utility:database',
                iconClass: 'slds-icon-text-error'
            });
        } else if (this.soqlUtilization > 60) {
            recommendations.push({
                id: 'soql-medium',
                title: 'Moderate SOQL Query Usage',
                description: 'Monitor query patterns and consider caching strategies.',
                impact: 'Medium Impact',
                impactClass: 'slds-theme_warning',
                icon: 'utility:database',
                iconClass: 'slds-icon-text-warning'
            });
        }

        // Check CPU utilization
        if (this.cpuUtilization > 80) {
            recommendations.push({
                id: 'cpu-high',
                title: 'High CPU Usage',
                description: 'Optimize complex calculations and reduce processing overhead.',
                impact: 'High Impact',
                impactClass: 'slds-theme_error',
                icon: 'utility:speed',
                iconClass: 'slds-icon-text-error'
            });
        }

        // Check DML utilization
        if (this.dmlUtilization > 70) {
            recommendations.push({
                id: 'dml-high',
                title: 'High DML Statement Usage',
                description: 'Implement bulk processing patterns and reduce individual DML operations.',
                impact: 'Medium Impact',
                impactClass: 'slds-theme_warning',
                icon: 'utility:edit',
                iconClass: 'slds-icon-text-warning'
            });
        }

        // Check dashboard load time
        if (this.dashboardLoadTime > 3000) {
            recommendations.push({
                id: 'load-time-high',
                title: 'Slow Dashboard Load Time',
                description: 'Implement lazy loading and optimize component rendering.',
                impact: 'Medium Impact',
                impactClass: 'slds-theme_warning',
                icon: 'utility:clock',
                iconClass: 'slds-icon-text-warning'
            });
        }

        // Add positive recommendations if performance is good
        if (recommendations.length === 0) {
            recommendations.push({
                id: 'performance-good',
                title: 'Excellent Performance',
                description: 'All system metrics are within optimal ranges.',
                impact: 'Optimal',
                impactClass: 'slds-theme_success',
                icon: 'utility:success',
                iconClass: 'slds-icon-text-success'
            });
        }

        this.performanceRecommendations = recommendations;
    }

    generatePerformanceHistory() {
        // Mock performance history data - would come from actual logging
        const history = [];
        const now = new Date();

        for (let i = 0; i < 10; i++) {
            const timestamp = new Date(now.getTime() - (i * 2 * 60 * 60 * 1000)); // Every 2 hours
            history.push({
                timestamp: timestamp.toISOString(),
                formattedTimestamp: timestamp.toLocaleString(),
                soqlUtilization: Math.floor(Math.random() * 60) + 10, // 10-70%
                cpuUtilization: Math.floor(Math.random() * 50) + 5,   // 5-55%
                dmlUtilization: Math.floor(Math.random() * 40) + 5,   // 5-45%
                loadTime: Math.floor(Math.random() * 2000) + 500      // 500-2500ms
            });
        }

        this.performanceHistory = history;
    }

    // Event handlers
    handleRefresh() {
        this.isLoading = true;
        
        // Dispatch refresh event to parent
        this.dispatchEvent(new CustomEvent('refresh'));
        
        // Simulate loading delay and regenerate data
        setTimeout(() => {
            this.isLoading = false;
            this.generatePerformanceRecommendations();
            this.generatePerformanceHistory();
            this.showToast('Success', 'Performance metrics refreshed successfully', 'success');
        }, 1000);
    }

    // Utility methods
    getUtilizationColor(utilization) {
        if (utilization >= 80) return '#ea6b66'; // Red
        if (utilization >= 60) return '#ffb75d'; // Orange
        if (utilization >= 40) return '#4bc076'; // Green
        return '#0176d3'; // Blue
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
        this.generatePerformanceRecommendations();
        this.generatePerformanceHistory();
    }

    @api
    getPerformanceSummary() {
        return {
            soqlUtilization: this.soqlUtilization,
            cpuUtilization: this.cpuUtilization,
            dmlUtilization: this.dmlUtilization,
            dashboardLoadTime: this.dashboardLoadTime,
            recommendationsCount: this.performanceRecommendations.length,
            overallHealth: this.getOverallHealth()
        };
    }

    getOverallHealth() {
        const avgUtilization = (this.soqlUtilization + this.cpuUtilization + this.dmlUtilization) / 3;
        
        if (avgUtilization >= 80) return 'Critical';
        if (avgUtilization >= 60) return 'Warning';
        if (avgUtilization >= 40) return 'Good';
        return 'Excellent';
    }
}
