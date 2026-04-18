import { LightningElement } from 'lwc';

const VIEWS = {
    OVERVIEW: 'overview',
    OPERATIONS: 'operations',
    ENTERPRISE: 'enterprise'
};

export default class FrontendApp extends LightningElement {
    activeView = VIEWS.OVERVIEW;

    viewOptions = [
        { label: 'Overview', value: VIEWS.OVERVIEW },
        { label: 'Operations', value: VIEWS.OPERATIONS },
        { label: 'Enterprise', value: VIEWS.ENTERPRISE }
    ];

    handleViewChange(event) {
        this.activeView = event.detail.value;
    }

    get isOverview() {
        return this.activeView === VIEWS.OVERVIEW;
    }

    get isOperations() {
        return this.activeView === VIEWS.OPERATIONS;
    }

    get isEnterprise() {
        return this.activeView === VIEWS.ENTERPRISE;
    }

    get activeViewTitle() {
        if (this.isOperations) {
            return 'Operations Control Center';
        }
        if (this.isEnterprise) {
            return 'Enterprise Analytics Hub';
        }
        return 'Unified Frontend Overview';
    }

    get activeViewDescription() {
        if (this.isOperations) {
            return 'Manage order workflows, stock status, and day-to-day fulfillment activities.';
        }
        if (this.isEnterprise) {
            return 'Track cross-functional business performance with strategic analytics dashboards.';
        }
        return 'Monitor business health and jump into the right workspace with one-click navigation.';
    }

    get heroIcon() {
        if (this.isOperations) {
            return 'utility:task';
        }
        if (this.isEnterprise) {
            return 'utility:chart';
        }
        return 'utility:apps';
    }
}
