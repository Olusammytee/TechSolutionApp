/**
 * ErrorLogger - Enterprise error handling and logging framework
 * Provides centralized error logging, performance monitoring, and debugging capabilities
 * Follows enterprise patterns for reliability and observability
 */
public class ErrorLogger {
    
    // Static variables for performance tracking
    private static Map<String, Long> operationStartTimes = new Map<String, Long>();
    private static List<Error_Log__c> pendingErrorLogs = new List<Error_Log__c>();
    private static List<Performance_Metric__c> pendingMetrics = new List<Performance_Metric__c>();
    
    /**
     * Log an error with full context information
     * @param className Name of the class where error occurred
     * @param methodName Name of the method where error occurred
     * @param e Exception that was thrown
     */
    public static void logError(String className, String methodName, Exception e) {
        logError(className, methodName, e, null);
    }
    
    /**
     * Log an error with additional context information
     * @param className Name of the class where error occurred
     * @param methodName Name of the method where error occurred
     * @param e Exception that was thrown
     * @param additionalContext Additional context information
     */
    public static void logError(String className, String methodName, Exception e, String additionalContext) {
        try {
            Error_Log__c errorLog = new Error_Log__c(
                Class_Name__c = className,
                Method_Name__c = methodName,
                Error_Message__c = buildErrorMessage(e, additionalContext),
                Stack_Trace__c = e.getStackTraceString(),
                Error_Type__c = e.getTypeName(),
                Timestamp__c = Datetime.now()
            );
            
            // Add to pending logs for batch processing
            pendingErrorLogs.add(errorLog);
            
            // If we have too many pending logs, flush them
            if (pendingErrorLogs.size() >= 10) {
                flushErrorLogs();
            }
            
            // Also log to system debug for immediate visibility
            System.debug(LoggingLevel.ERROR, 
                'ERROR in ' + className + '.' + methodName + ': ' + e.getMessage());
            
        } catch (Exception logException) {
            // Fallback to system debug if logging fails
            System.debug(LoggingLevel.ERROR, 
                'Failed to log error in ' + className + '.' + methodName + ': ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 
                'Logging exception: ' + logException.getMessage());
        }
    }
    
    /**
     * Start performance monitoring for an operation
     * @param operationName Name of the operation being monitored
     */
    public static void startPerformanceMonitoring(String operationName) {
        operationStartTimes.put(operationName, System.currentTimeMillis());
    }
    
    /**
     * End performance monitoring and log the metric
     * @param operationName Name of the operation being monitored
     */
    public static void endPerformanceMonitoring(String operationName) {
        Long startTime = operationStartTimes.get(operationName);
        if (startTime != null) {
            Long executionTime = System.currentTimeMillis() - startTime;
            logPerformanceMetric(operationName, executionTime);
            operationStartTimes.remove(operationName);
        }
    }
    
    /**
     * Log a performance metric
     * @param operation Name of the operation
     * @param executionTime Execution time in milliseconds
     */
    public static void logPerformanceMetric(String operation, Long executionTime) {
        logPerformanceMetric(operation, executionTime, null);
    }
    
    /**
     * Log a performance metric with additional context
     * @param operation Name of the operation
     * @param executionTime Execution time in milliseconds
     * @param additionalContext Additional context information
     */
    public static void logPerformanceMetric(String operation, Long executionTime, String additionalContext) {
        try {
            Performance_Metric__c metric = new Performance_Metric__c(
                Operation_Name__c = operation,
                Execution_Time_Ms__c = executionTime,
                Additional_Context__c = additionalContext,
                Timestamp__c = Datetime.now(),
                CPU_Time__c = Limits.getCpuTime(),
                SOQL_Queries__c = Limits.getQueries(),
                DML_Statements__c = Limits.getDMLStatements()
            );
            
            pendingMetrics.add(metric);
            
            // If we have too many pending metrics, flush them
            if (pendingMetrics.size() >= 20) {
                flushPerformanceMetrics();
            }
            
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 
                'Failed to log performance metric for ' + operation + ': ' + e.getMessage());
        }
    }
    
    /**
     * Log system limits for monitoring resource usage
     * @param context Context where limits are being checked
     */
    public static void logSystemLimits(String context) {
        try {
            String limitsInfo = 'System Limits for ' + context + ':\n' +
                'SOQL Queries: ' + Limits.getQueries() + '/' + Limits.getLimitQueries() + '\n' +
                'DML Statements: ' + Limits.getDMLStatements() + '/' + Limits.getLimitDMLStatements() + '\n' +
                'CPU Time: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime() + '\n' +
                'Heap Size: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize();
            
            System.debug(LoggingLevel.INFO, limitsInfo);
            
            // Log as performance metric if limits are high
            Decimal soqlUtilization = (Decimal.valueOf(Limits.getQueries()) / Limits.getLimitQueries()) * 100;
            Decimal cpuUtilization = (Decimal.valueOf(Limits.getCpuTime()) / Limits.getLimitCpuTime()) * 100;
            
            if (soqlUtilization > 50 || cpuUtilization > 50) {
                logPerformanceMetric('SystemLimitsCheck', 0, limitsInfo);
            }
            
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 
                'Failed to log system limits: ' + e.getMessage());
        }
    }
    
    /**
     * Flush pending error logs to database
     */
    public static void flushErrorLogs() {
        if (!pendingErrorLogs.isEmpty()) {
            try {
                Database.SaveResult[] results = Database.insert(pendingErrorLogs, false);
                
                // Check for any failures in logging
                for (Integer i = 0; i < results.size(); i++) {
                    if (!results[i].isSuccess()) {
                        System.debug(LoggingLevel.WARN, 
                            'Failed to insert error log: ' + results[i].getErrors()[0].getMessage());
                    }
                }
                
                pendingErrorLogs.clear();
                
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 
                    'Failed to flush error logs: ' + e.getMessage());
                pendingErrorLogs.clear(); // Clear to prevent memory issues
            }
        }
    }
    
    /**
     * Flush pending performance metrics to database
     */
    public static void flushPerformanceMetrics() {
        if (!pendingMetrics.isEmpty()) {
            try {
                Database.insert(pendingMetrics, false); // Allow partial success
                pendingMetrics.clear();
                
            } catch (Exception e) {
                System.debug(LoggingLevel.WARN, 
                    'Failed to flush performance metrics: ' + e.getMessage());
                pendingMetrics.clear(); // Clear to prevent memory issues
            }
        }
    }
    
    /**
     * Flush all pending logs (called at end of transaction)
     */
    public static void flushAllLogs() {
        flushErrorLogs();
        flushPerformanceMetrics();
    }
    
    /**
     * Create a debug checkpoint for troubleshooting
     * @param checkpointName Name of the checkpoint
     * @param context Additional context information
     */
    public static void debugCheckpoint(String checkpointName, String context) {
        System.debug(LoggingLevel.DEBUG, 
            'CHECKPOINT [' + checkpointName + ']: ' + context + 
            ' | CPU: ' + Limits.getCpuTime() + 
            ' | SOQL: ' + Limits.getQueries() + 
            ' | DML: ' + Limits.getDMLStatements());
    }
    
    // Private helper methods
    
    private static String buildErrorMessage(Exception e, String additionalContext) {
        String message = e.getMessage();
        
        if (String.isNotBlank(additionalContext)) {
            message += '\n\nAdditional Context: ' + additionalContext;
        }
        
        // Add system context
        message += '\n\nSystem Context:';
        message += '\nCPU Time: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime();
        message += '\nSOQL Queries: ' + Limits.getQueries() + '/' + Limits.getLimitQueries();
        message += '\nDML Statements: ' + Limits.getDMLStatements() + '/' + Limits.getLimitDMLStatements();
        message += '\nHeap Size: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize();
        
        return message;
    }
}
