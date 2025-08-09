// Execute comprehensive Phase 4 automation
System.debug('=== Starting Phase 4 Enterprise Automation ===');

// Execute the complete automation workflow
Phase4AutomationOrchestrator.AutomationResult result = Phase4AutomationOrchestrator.executeCompleteAutomation();

// Generate and display comprehensive report
String report = Phase4AutomationOrchestrator.generateAutomationReport(result);

System.debug('=== AUTOMATION EXECUTION COMPLETE ===');
System.debug('Success: ' + result.success);
System.debug('Message: ' + result.message);
System.debug('Execution Time: ' + result.executionTimeMs + 'ms');

if (!result.errors.isEmpty()) {
    System.debug('=== ERRORS ===');
    for (String error : result.errors) {
        System.debug('ERROR: ' + error);
    }
}

if (!result.warnings.isEmpty()) {
    System.debug('=== WARNINGS ===');
    for (String warning : result.warnings) {
        System.debug('WARNING: ' + warning);
    }
}

System.debug('=== DETAILED RESULTS ===');
for (String key : result.results.keySet()) {
    System.debug(key + ': ' + result.results.get(key));
}

System.debug('=== FULL AUTOMATION REPORT ===');
System.debug(report);
