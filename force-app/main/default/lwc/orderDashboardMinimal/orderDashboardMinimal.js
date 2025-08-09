/**
 * OrderDashboardMinimal - Minimal Lightning Web Component for deployment testing
 * 
 * Educational Purpose: Demonstrates incremental LWC deployment strategy
 * This minimal component provides basic dashboard functionality to test deployment patterns
 * 
 * Part of: TechSolutionApp Phase 4.2 - Deployment Optimization
 * Author: TechSolutionApp Educational Platform
 * Created: August 2024
 */
import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOrderCount from '@salesforce/apex/OrderDashboardMinimal.getOrderCount';
import getDeviceCount from '@salesforce/apex/OrderDashboardMinimal.getDeviceCount';
import testConnection from '@salesforce/apex/OrderDashboardMinimal.testConnection';

export default class OrderDashboardMinimal extends LightningElement {
    
    // Reactive properties for data binding
    orderCount = 0;
    deviceCount = 0;
    connectionStatus = '';
    isLoading = false;
    error;

    // Wire methods for reactive data
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
}
