/**
 * OrderDashboardMinimal - Ultra-minimal Apex Controller for deployment testing
 * 
 * Educational Purpose: Demonstrates incremental deployment strategy
 * This minimal controller provides basic functionality to test deployment patterns
 * 
 * Part of: TechSolutionApp Phase 4.2 - Deployment Optimization
 * Author: TechSolutionApp Educational Platform
 * Created: August 2024
 */
public with sharing class OrderDashboardMinimal {
    
    /**
     * Get basic order count - minimal implementation
     */
    @AuraEnabled(cacheable=true)
    public static Integer getOrderCount() {
        try {
            return [SELECT COUNT() FROM Device_Order__c];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving order count: ' + e.getMessage());
        }
    }
    
    /**
     * Get basic device count - minimal implementation
     */
    @AuraEnabled(cacheable=true)
    public static Integer getDeviceCount() {
        try {
            return [SELECT COUNT() FROM Device__c];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving device count: ' + e.getMessage());
        }
    }
    
    /**
     * Test method to verify controller functionality
     */
    @AuraEnabled
    public static String testConnection() {
        return 'OrderDashboardMinimal controller is working correctly!';
    }
}
