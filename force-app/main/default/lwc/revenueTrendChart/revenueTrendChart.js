import { LightningElement, api, track } from 'lwc';

export default class RevenueTrendChart extends LightningElement {
    @api chartData = [];
    @api height = '300';
    
    @track processedData = [];
    @track maxValue = 0;
    @track totalRevenue = '$0.00';
    @track averageDaily = '$0.00';
    @track peakDay = '$0.00';

    // Computed properties
    get hasData() {
        return this.chartData && this.chartData.length > 0;
    }

    get chartHeight() {
        return `height: ${this.height}px;`;
    }

    // Lifecycle methods
    connectedCallback() {
        this.processChartData();
    }

    renderedCallback() {
        if (this.chartData && this.chartData.length > 0) {
            this.processChartData();
        }
    }

    // Data processing methods
    processChartData() {
        if (!this.chartData || this.chartData.length === 0) {
            this.processedData = [];
            return;
        }

        // Find max value for scaling
        this.maxValue = Math.max(...this.chartData.map(item => item.value || 0));
        
        // Process data for visualization
        this.processedData = this.chartData.map((item, index) => {
            const value = item.value || 0;
            const percentage = this.maxValue > 0 ? (value / this.maxValue) * 100 : 0;
            
            return {
                label: item.label,
                shortLabel: this.getShortLabel(item.label),
                value: value,
                formattedValue: item.formattedValue || this.formatCurrency(value),
                percentage: percentage,
                barStyle: this.getBarStyle(percentage),
                tooltip: `${item.label}: ${item.formattedValue || this.formatCurrency(value)}`
            };
        });

        // Calculate summary statistics
        this.calculateSummaryStats();
    }

    calculateSummaryStats() {
        if (!this.chartData || this.chartData.length === 0) {
            this.totalRevenue = '$0.00';
            this.averageDaily = '$0.00';
            this.peakDay = '$0.00';
            return;
        }

        const values = this.chartData.map(item => item.value || 0);
        const total = values.reduce((sum, value) => sum + value, 0);
        const average = total / values.length;
        const peak = Math.max(...values);

        this.totalRevenue = this.formatCurrency(total);
        this.averageDaily = this.formatCurrency(average);
        this.peakDay = this.formatCurrency(peak);
    }

    // Utility methods
    getShortLabel(label) {
        if (!label) return '';
        
        // Convert date strings to short format
        const date = new Date(label);
        if (!isNaN(date.getTime())) {
            return date.toLocaleDateString('en-US', { 
                month: 'numeric', 
                day: 'numeric' 
            });
        }
        
        // For non-date labels, truncate if too long
        return label.length > 6 ? label.substring(0, 6) + '...' : label;
    }

    getBarStyle(percentage) {
        const height = Math.max(percentage, 2); // Minimum 2% height for visibility
        const color = this.getBarColor(percentage);
        
        return `height: ${height}%; background-color: ${color}; transition: all 0.3s ease;`;
    }

    getBarColor(percentage) {
        // Color gradient based on value
        if (percentage >= 80) return '#2e844a'; // Green for high values
        if (percentage >= 60) return '#0176d3'; // Blue for medium-high values
        if (percentage >= 40) return '#9a77cf'; // Purple for medium values
        if (percentage >= 20) return '#fe9339'; // Orange for low-medium values
        return '#ea6b66'; // Red for low values
    }

    formatCurrency(amount) {
        if (amount === null || amount === undefined) return '$0.00';
        
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        }).format(amount);
    }

    // Public methods
    @api
    refreshChart() {
        this.processChartData();
    }

    @api
    exportData() {
        return {
            chartData: this.processedData,
            summary: {
                totalRevenue: this.totalRevenue,
                averageDaily: this.averageDaily,
                peakDay: this.peakDay,
                dataPoints: this.chartData.length
            }
        };
    }
}
