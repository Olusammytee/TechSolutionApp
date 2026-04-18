import { LightningElement, track } from 'lwc';

export default class FrontendApp extends LightningElement {
    @track activeView = 'overview';

    viewOptions = [
        { label: 'Overview', value: 'overview' },
        { label: 'Operations', value: 'operations' },
        { label: 'Enterprise', value: 'enterprise' }
    ];

    handleViewChange(event) {
        this.activeView = event.detail.value;
    }

    get isOverview() {
        return this.activeView === 'overview';
    }

    get isOperations() {
        return this.activeView === 'operations';
    }

    get isEnterprise() {
        return this.activeView === 'enterprise';
    }
}
