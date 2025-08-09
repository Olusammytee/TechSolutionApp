import { LightningElement, api, track } from 'lwc';

export default class OrderStatusChart extends LightningElement {
    @api chartData = [];
    @api height = '300';

    @track chartSegments = [];
    @track totalOrders = 0;
    @track activeOrders = 0;
    @track completedOrders = 0;

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
            this.resetData();
            return;
        }

        // Calculate totals
        this.totalOrders = this.chartData.reduce((sum, item) => sum + (item.value || 0), 0);

        // Process data with percentages and colors
        const processedData = this.chartData.map(item => {
            const value = item.value || 0;
            const percentage = this.totalOrders > 0 ? Math.round((value / this.totalOrders) * 100) : 0;
            const color = item.color || this.getDefaultColor(item.label);

            return {
                label: item.label,
                value: value,
                percentage: percentage,
                color: color,
                colorStyle: `background-color: ${color};`,
                tooltip: `${item.label}: ${value} orders (${percentage}%)`
            };
        });

        // Generate donut chart segments
        this.generateDonutSegments(processedData);

        // Calculate summary statistics
        this.calculateSummaryStats(processedData);

        // Update chart data with processed information
        this.chartData = processedData;
    }

    generateDonutSegments(data) {
        if (!data || data.length === 0) {
            this.chartSegments = [];
            return;
        }

        const centerX = 50;
        const centerY = 50;
        const outerRadius = 35;
        const innerRadius = 20;
        
        let currentAngle = -90; // Start at top
        this.chartSegments = [];

        data.forEach(item => {
            if (item.value > 0) {
                const angleSize = (item.value / this.totalOrders) * 360;
                const startAngle = currentAngle;
                const endAngle = currentAngle + angleSize;
                
                const pathData = this.createArcPath(
                    centerX, centerY, 
                    innerRadius, outerRadius, 
                    startAngle, endAngle
                );
                
                this.chartSegments.push({
                    label: item.label,
                    value: item.value,
                    color: item.color,
                    pathData: pathData,
                    tooltip: item.tooltip
                });
                
                currentAngle += angleSize;
            }
        });
    }

    createArcPath(centerX, centerY, innerRadius, outerRadius, startAngle, endAngle) {
        const startAngleRad = (startAngle * Math.PI) / 180;
        const endAngleRad = (endAngle * Math.PI) / 180;

        const largeArcFlag = endAngle - startAngle <= 180 ? "0" : "1";

        const x1 = centerX + outerRadius * Math.cos(startAngleRad);
        const y1 = centerY + outerRadius * Math.sin(startAngleRad);
        const x2 = centerX + outerRadius * Math.cos(endAngleRad);
        const y2 = centerY + outerRadius * Math.sin(endAngleRad);

        const x3 = centerX + innerRadius * Math.cos(endAngleRad);
        const y3 = centerY + innerRadius * Math.sin(endAngleRad);
        const x4 = centerX + innerRadius * Math.cos(startAngleRad);
        const y4 = centerY + innerRadius * Math.sin(startAngleRad);

        return [
            "M", x1, y1,
            "A", outerRadius, outerRadius, 0, largeArcFlag, 1, x2, y2,
            "L", x3, y3,
            "A", innerRadius, innerRadius, 0, largeArcFlag, 0, x4, y4,
            "Z"
        ].join(" ");
    }

    calculateSummaryStats(data) {
        const activeStatuses = ['Pending', 'Confirmed', 'Processing', 'Shipped'];
        const completedStatuses = ['Delivered'];

        this.activeOrders = data
            .filter(item => activeStatuses.includes(item.label))
            .reduce((sum, item) => sum + item.value, 0);

        this.completedOrders = data
            .filter(item => completedStatuses.includes(item.label))
            .reduce((sum, item) => sum + item.value, 0);
    }

    resetData() {
        this.chartSegments = [];
        this.totalOrders = 0;
        this.activeOrders = 0;
        this.completedOrders = 0;
    }

    // Utility methods
    getDefaultColor(status) {
        const colorMap = {
            'Pending': '#FFB75D',      // Orange
            'Confirmed': '#4BC076',    // Green
            'Processing': '#5DDAFF',   // Light Blue
            'Shipped': '#9A77CF',      // Purple
            'Delivered': '#57B85A',    // Dark Green
            'Cancelled': '#EA6B66',    // Red
            'Returned': '#F4B942'      // Yellow
        };
        return colorMap[status] || '#747474'; // Default gray
    }

    // Event handlers
    handleSegmentClick(event) {
        const label = event.target.dataset.label;
        const value = event.target.dataset.value;

        if (label && value) {
            // Dispatch custom event for parent component
            this.dispatchEvent(new CustomEvent('segmentclick', {
                detail: {
                    label: label,
                    value: parseInt(value, 10)
                }
            }));
        }
    }

    // Public methods
    @api
    refreshChart() {
        this.processChartData();
    }

    @api
    exportData() {
        return {
            chartData: this.chartData,
            summary: {
                totalOrders: this.totalOrders,
                activeOrders: this.activeOrders,
                completedOrders: this.completedOrders,
                segments: this.chartSegments.length
            }
        };
    }

    @api
    highlightSegment(label) {
        // Method to highlight a specific segment
        const segments = this.template.querySelectorAll('.donut-segment');
        segments.forEach(segment => {
            if (segment.dataset.label === label) {
                segment.style.opacity = '1';
                segment.style.strokeWidth = '2';
            } else {
                segment.style.opacity = '0.7';
                segment.style.strokeWidth = '1';
            }
        });
    }

    @api
    clearHighlight() {
        // Method to clear all highlights
        const segments = this.template.querySelectorAll('.donut-segment');
        segments.forEach(segment => {
            segment.style.opacity = '1';
            segment.style.strokeWidth = '1';
        });
    }
}
