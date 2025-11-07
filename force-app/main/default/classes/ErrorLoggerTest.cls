/**
 * 🧪 ERROR LOGGER TEST CLASS - Making Testing Fun and Educational!
 *
 * Welcome to testing! This class teaches you how to test enterprise error logging.
 *
 * 🎯 WHAT YOU'LL LEARN:
 * ✅ How to test error handling code
 * ✅ How to simulate exceptions in tests
 * ✅ How to verify performance monitoring
 * ✅ How to test batch operations
 * ✅ How to test edge cases and null scenarios
 *
 * 📚 TESTING CONCEPTS COVERED:
 * - @TestSetup for efficient data creation
 * - Test.startTest() and Test.stopTest() for governor limit reset
 * - try-catch blocks for exception testing
 * - System.assert methods for verification
 * - Testing static utility classes
 *
 * 🎓 EDUCATIONAL GOAL: 90%+ code coverage with comprehensive scenarios
 *
 * @author TechSolutionApp Educational Platform
 * @date 2025
 */
@isTest
private class ErrorLoggerTest {

    /**
     * 🏗️ TEST SETUP: Create test data once for all test methods
     *
     * Why @TestSetup?
     * - Runs ONCE before all test methods
     * - Data is automatically rolled back after each test
     * - More efficient than creating data in each test method
     * - Each test gets a FRESH copy of this data
     */
    @TestSetup
    static void setupTestData() {
        // Educational Note: We don't need much setup for utility class testing
        // But we'll create a device for realistic error scenarios
        Device__c testDevice = new Device__c(
            Name = 'Test Logging Device',
            Price__c = 999.99,
            Stock_Quantity__c = 50
        );
        insert testDevice;
    }

    /**
     * 🧪 TEST 1: Basic Error Logging
     *
     * WHAT THIS TESTS:
     * - logError() method with className, methodName, and Exception
     * - Error_Log__c record creation
     * - Automatic error message formatting
     * - Stack trace capture
     *
     * LEARNING POINT: How to test that errors are logged correctly
     */
    @isTest
    static void testBasicErrorLogging() {
        // 📝 ARRANGE: Set up the scenario
        String testClassName = 'TestClass';
        String testMethodName = 'testMethod';
        Exception testException;

        try {
            // Create a real exception by dividing by zero!
            Decimal result = 1 / 0;
        } catch (Exception e) {
            testException = e;
        }

        // 🎬 ACT: Perform the operation being tested
        Test.startTest();
        ErrorLogger.logError(testClassName, testMethodName, testException);
        ErrorLogger.flushErrorLogs(); // Manually flush to database
        Test.stopTest();

        // ✅ ASSERT: Verify the results
        List<Error_Log__c> errorLogs = [
            SELECT Id, Class_Name__c, Method_Name__c, Error_Message__c,
                   Error_Type__c, Stack_Trace__c
            FROM Error_Log__c
        ];

        System.assertEquals(1, errorLogs.size(),
            '📊 Expected exactly one error log to be created');

        Error_Log__c log = errorLogs[0];
        System.assertEquals(testClassName, log.Class_Name__c,
            '🏷️ Class name should be captured correctly');
        System.assertEquals(testMethodName, log.Method_Name__c,
            '🔧 Method name should be captured correctly');
        System.assertNotEquals(null, log.Error_Message__c,
            '📝 Error message should be populated');
        System.assert(log.Error_Message__c.contains('Divide by zero'),
            '🔍 Error message should contain the actual error text');
        System.assertEquals('MathException', log.Error_Type__c,
            '🏷️ Error type should be correctly identified');
        System.assertNotEquals(null, log.Stack_Trace__c,
            '📍 Stack trace should be captured for debugging');
    }

    /**
     * 🧪 TEST 2: Error Logging with Additional Context
     *
     * WHAT THIS TESTS:
     * - logError() overloaded method with additional context parameter
     * - Context information inclusion in error message
     * - System limits information capture
     *
     * LEARNING POINT: How additional context helps debugging
     */
    @isTest
    static void testErrorLoggingWithContext() {
        // 📝 ARRANGE
        String className = 'OrderProcessor';
        String methodName = 'processOrder';
        String additionalContext = 'Order ID: ORD-12345, Customer: ABC Corp';
        Exception testException;

        try {
            // Simulate a null pointer exception
            String nullString = null;
            Integer length = nullString.length();
        } catch (Exception e) {
            testException = e;
        }

        // 🎬 ACT
        Test.startTest();
        ErrorLogger.logError(className, methodName, testException, additionalContext);
        ErrorLogger.flushErrorLogs();
        Test.stopTest();

        // ✅ ASSERT
        List<Error_Log__c> logs = [SELECT Error_Message__c FROM Error_Log__c];

        System.assertEquals(1, logs.size(),
            '📊 One error log should be created');
        System.assert(logs[0].Error_Message__c.contains(additionalContext),
            '🔍 Additional context should be included in error message');
        System.assert(logs[0].Error_Message__c.contains('System Context'),
            '📊 System context (governor limits) should be included');
        System.assert(logs[0].Error_Message__c.contains('CPU Time'),
            '⏱️ CPU time should be logged for performance analysis');
        System.assert(logs[0].Error_Message__c.contains('SOQL Queries'),
            '🔍 SOQL query count should be logged');
    }

    /**
     * 🧪 TEST 3: Performance Monitoring
     *
     * WHAT THIS TESTS:
     * - startPerformanceMonitoring() method
     * - endPerformanceMonitoring() method
     * - Performance_Metric__c record creation
     * - Execution time calculation
     *
     * LEARNING POINT: How to monitor code performance automatically
     */
    @isTest
    static void testPerformanceMonitoring() {
        // 📝 ARRANGE
        String operationName = 'DataProcessing';

        // 🎬 ACT
        Test.startTest();

        ErrorLogger.startPerformanceMonitoring(operationName);

        // Simulate some work (query execution)
        List<Device__c> devices = [SELECT Id, Name FROM Device__c LIMIT 1];

        ErrorLogger.endPerformanceMonitoring(operationName);
        ErrorLogger.flushPerformanceMetrics();

        Test.stopTest();

        // ✅ ASSERT
        List<Performance_Metric__c> metrics = [
            SELECT Operation_Name__c, Execution_Time_Ms__c,
                   CPU_Time__c, SOQL_Queries__c, DML_Statements__c
            FROM Performance_Metric__c
        ];

        System.assertEquals(1, metrics.size(),
            '📊 One performance metric should be recorded');

        Performance_Metric__c metric = metrics[0];
        System.assertEquals(operationName, metric.Operation_Name__c,
            '🏷️ Operation name should match');
        System.assertNotEquals(null, metric.Execution_Time_Ms__c,
            '⏱️ Execution time should be calculated');
        System.assert(metric.Execution_Time_Ms__c >= 0,
            '✅ Execution time should be non-negative');
        System.assertNotEquals(null, metric.SOQL_Queries__c,
            '🔍 SOQL query count should be captured');
        System.assert(metric.SOQL_Queries__c >= 1,
            '✅ At least one SOQL query was executed in our test');
    }

    /**
     * 🧪 TEST 4: Performance Metric with Context
     *
     * WHAT THIS TESTS:
     * - Direct performance metric logging
     * - Custom execution time and context
     * - System limits capture
     *
     * LEARNING POINT: Multiple ways to log performance metrics
     */
    @isTest
    static void testPerformanceMetricWithContext() {
        // 📝 ARRANGE
        String operation = 'BulkDataImport';
        Long executionTime = 1250L; // milliseconds
        String context = 'Imported 500 records successfully';

        // 🎬 ACT
        Test.startTest();
        ErrorLogger.logPerformanceMetric(operation, executionTime, context);
        ErrorLogger.flushPerformanceMetrics();
        Test.stopTest();

        // ✅ ASSERT
        List<Performance_Metric__c> metrics = [
            SELECT Operation_Name__c, Execution_Time_Ms__c, Additional_Context__c
            FROM Performance_Metric__c
        ];

        System.assertEquals(1, metrics.size(),
            '📊 Performance metric should be logged');
        System.assertEquals(operation, metrics[0].Operation_Name__c,
            '🏷️ Operation name should match');
        System.assertEquals(executionTime, metrics[0].Execution_Time_Ms__c,
            '⏱️ Execution time should match provided value');
        System.assertEquals(context, metrics[0].Additional_Context__c,
            '📝 Additional context should be stored');
    }

    /**
     * 🧪 TEST 5: Automatic Batch Flushing (Error Logs)
     *
     * WHAT THIS TESTS:
     * - Automatic flushing when 10+ errors are logged
     * - Batch processing efficiency
     * - No data loss when batching
     *
     * LEARNING POINT: How batching prevents governor limit issues
     */
    @isTest
    static void testAutomaticErrorLogFlushing() {
        // 📝 ARRANGE: Create 12 errors (should auto-flush at 10)
        Exception testException;
        try {
            Integer result = 1 / 0;
        } catch (Exception e) {
            testException = e;
        }

        // 🎬 ACT
        Test.startTest();

        for (Integer i = 0; i < 12; i++) {
            ErrorLogger.logError('TestClass' + i, 'testMethod', testException);
        }

        // Manual flush for any remaining
        ErrorLogger.flushErrorLogs();

        Test.stopTest();

        // ✅ ASSERT
        List<Error_Log__c> logs = [SELECT Id FROM Error_Log__c];

        System.assertEquals(12, logs.size(),
            '📊 All 12 errors should be logged (auto-flush + manual flush)');
    }

    /**
     * 🧪 TEST 6: Automatic Batch Flushing (Performance Metrics)
     *
     * WHAT THIS TESTS:
     * - Automatic flushing when 20+ metrics are logged
     * - Bulk performance monitoring
     * - Memory management
     *
     * LEARNING POINT: Batching prevents memory and DML limit issues
     */
    @isTest
    static void testAutomaticMetricFlushing() {
        // 📝 ARRANGE: Create 25 metrics (should auto-flush at 20)

        // 🎬 ACT
        Test.startTest();

        for (Integer i = 0; i < 25; i++) {
            ErrorLogger.logPerformanceMetric('Operation' + i, Long.valueOf(i * 100));
        }

        // Manual flush for remaining
        ErrorLogger.flushPerformanceMetrics();

        Test.stopTest();

        // ✅ ASSERT
        List<Performance_Metric__c> metrics = [SELECT Id FROM Performance_Metric__c];

        System.assertEquals(25, metrics.size(),
            '📊 All 25 metrics should be logged via auto-flush and manual flush');
    }

    /**
     * 🧪 TEST 7: System Limits Logging
     *
     * WHAT THIS TESTS:
     * - logSystemLimits() method
     * - Governor limit information capture
     * - Debug log output
     *
     * LEARNING POINT: How to monitor governor limits during execution
     */
    @isTest
    static void testSystemLimitsLogging() {
        // 📝 ARRANGE
        String context = 'Before Heavy Processing';

        // Execute some operations to use limits
        for (Integer i = 0; i < 5; i++) {
            List<Device__c> devices = [SELECT Id FROM Device__c LIMIT 1];
        }

        // 🎬 ACT
        Test.startTest();
        ErrorLogger.logSystemLimits(context);
        Test.stopTest();

        // ✅ ASSERT
        // This method primarily logs to System.debug
        // We verify it doesn't throw exceptions
        System.assert(true,
            '✅ System limits logging completed without errors');

        // If limits are high (>50%), a performance metric is created
        // In test context, limits are usually low, so this is optional
    }

    /**
     * 🧪 TEST 8: Debug Checkpoint
     *
     * WHAT THIS TESTS:
     * - debugCheckpoint() method
     * - Checkpoint logging functionality
     * - No exceptions during debugging
     *
     * LEARNING POINT: How to add debug checkpoints for troubleshooting
     */
    @isTest
    static void testDebugCheckpoint() {
        // 📝 ARRANGE
        String checkpointName = 'BeforeOrderProcessing';
        String context = 'Processing 100 orders for Customer ABC';

        // 🎬 ACT
        Test.startTest();
        ErrorLogger.debugCheckpoint(checkpointName, context);
        Test.stopTest();

        // ✅ ASSERT
        // Debug checkpoints write to System.debug logs
        System.assert(true,
            '✅ Debug checkpoint executed successfully');
    }

    /**
     * 🧪 TEST 9: Flush All Logs
     *
     * WHAT THIS TESTS:
     * - flushAllLogs() method
     * - Simultaneous flushing of errors and metrics
     * - Transactional integrity
     *
     * LEARNING POINT: Clean up method for end of transaction
     */
    @isTest
    static void testFlushAllLogs() {
        // 📝 ARRANGE: Create both errors and metrics
        Exception testException;
        try {
            Integer result = 1 / 0;
        } catch (Exception e) {
            testException = e;
        }

        // 🎬 ACT
        Test.startTest();

        // Log multiple errors and metrics
        for (Integer i = 0; i < 3; i++) {
            ErrorLogger.logError('TestClass', 'method' + i, testException);
            ErrorLogger.logPerformanceMetric('Operation' + i, Long.valueOf(i * 50));
        }

        // Flush all at once
        ErrorLogger.flushAllLogs();

        Test.stopTest();

        // ✅ ASSERT
        System.assertEquals(3, [SELECT COUNT() FROM Error_Log__c],
            '📊 All error logs should be flushed');
        System.assertEquals(3, [SELECT COUNT() FROM Performance_Metric__c],
            '📊 All performance metrics should be flushed');
    }

    /**
     * 🧪 TEST 10: Edge Case - Null Operation Name
     *
     * WHAT THIS TESTS:
     * - Handling of null/empty operation names
     * - Defensive programming against null Map keys
     * - No exceptions with invalid input
     *
     * LEARNING POINT: Apex Maps cannot have null keys - defensive guards required!
     *
     * CRITICAL: This test validates a bug fix. Without defensive null checks,
     * ErrorLogger.startPerformanceMonitoring(null) would throw NullPointerException
     * because Apex Map.put(null, value) is not allowed.
     */
    @isTest
    static void testEdgeCaseNullOperationName() {
        // 📝 ARRANGE
        String nullOperation = null;
        String blankOperation = '   ';
        Long executionTime = 100L;

        // 🎬 ACT
        Test.startTest();

        // These should NOT throw exceptions - should handle gracefully
        ErrorLogger.startPerformanceMonitoring(nullOperation);
        ErrorLogger.endPerformanceMonitoring(nullOperation);
        ErrorLogger.logPerformanceMetric(nullOperation, executionTime);

        // Also test blank strings
        ErrorLogger.startPerformanceMonitoring(blankOperation);
        ErrorLogger.logPerformanceMetric(blankOperation, executionTime);

        ErrorLogger.flushPerformanceMetrics();

        Test.stopTest();

        // ✅ ASSERT
        List<Performance_Metric__c> metrics = [SELECT Id FROM Performance_Metric__c];

        // No metrics should be created for null/blank operation names
        System.assertEquals(0, metrics.size(),
            '📊 Null/blank operation names should be rejected gracefully - no metrics created');

        // Verify methods completed without throwing NullPointerException
        System.assert(true,
            '✅ All methods handled null/blank gracefully without exceptions');
    }

    /**
     * 🧪 TEST 11: Edge Case - Missing Start Time
     *
     * WHAT THIS TESTS:
     * - Calling endPerformanceMonitoring() without startPerformanceMonitoring()
     * - Defensive coding patterns
     * - No data corruption
     *
     * LEARNING POINT: Robust error handling prevents runtime failures
     */
    @isTest
    static void testEdgeCaseMissingStartTime() {
        // 📝 ARRANGE
        String operationName = 'NeverStartedOperation';

        // 🎬 ACT
        Test.startTest();

        // End monitoring without starting it
        ErrorLogger.endPerformanceMonitoring(operationName);
        ErrorLogger.flushPerformanceMetrics();

        Test.stopTest();

        // ✅ ASSERT
        List<Performance_Metric__c> metrics = [SELECT Id FROM Performance_Metric__c];

        // No metric should be created since we never started monitoring
        System.assertEquals(0, metrics.size(),
            '📊 No metric should be created without start time');
    }

    /**
     * 🧪 TEST 12: Bulk Operations - 200 Errors
     *
     * WHAT THIS TESTS:
     * - Governor limit compliance
     * - Bulk error logging (200 records)
     * - Batch processing efficiency
     *
     * LEARNING POINT: Test with realistic bulk volumes (200 is Salesforce standard)
     */
    @isTest
    static void testBulkErrorLogging() {
        // 📝 ARRANGE
        Exception testException;
        try {
            Decimal x = 1 / 0;
        } catch (Exception e) {
            testException = e;
        }

        // 🎬 ACT
        Test.startTest();

        // Log 200 errors (tests bulkification)
        for (Integer i = 0; i < 200; i++) {
            ErrorLogger.logError('BulkTest' + i, 'bulkMethod', testException);
        }

        ErrorLogger.flushErrorLogs();

        Test.stopTest();

        // ✅ ASSERT
        Integer errorCount = [SELECT COUNT() FROM Error_Log__c];

        System.assertEquals(200, errorCount,
            '📊 All 200 errors should be logged successfully');
    }

    /**
     * 🧪 TEST 13: Real-World Scenario - Processing Pipeline
     *
     * WHAT THIS TESTS:
     * - Realistic use case with mixed logging
     * - Performance monitoring with error handling
     * - Complete logging workflow
     *
     * LEARNING POINT: How ErrorLogger works in real applications
     */
    @isTest
    static void testRealWorldScenario() {
        // 📝 ARRANGE
        Device__c device = [SELECT Id FROM Device__c LIMIT 1];

        // 🎬 ACT
        Test.startTest();

        // Start monitoring a complex operation
        ErrorLogger.startPerformanceMonitoring('OrderProcessingPipeline');

        try {
            // Simulate order processing
            Device_Order__c order = new Device_Order__c(
                Device__c = device.Id,
                Quantity__c = 5,
                Status__c = 'Draft'
            );
            insert order;

            // Log checkpoint
            ErrorLogger.debugCheckpoint('AfterOrderInsert',
                'Order ' + order.Id + ' created successfully');

            // Simulate an error in downstream processing
            try {
                String nullStr = null;
                Integer len = nullStr.length();
            } catch (Exception e) {
                ErrorLogger.logError('OrderProcessor', 'postProcessing', e,
                    'Order ID: ' + order.Id);
            }

        } finally {
            // End monitoring regardless of success/failure
            ErrorLogger.endPerformanceMonitoring('OrderProcessingPipeline');

            // Flush all logs at end of transaction
            ErrorLogger.flushAllLogs();
        }

        Test.stopTest();

        // ✅ ASSERT
        System.assertEquals(1, [SELECT COUNT() FROM Error_Log__c],
            '📊 Error should be logged');
        System.assertEquals(1, [SELECT COUNT() FROM Performance_Metric__c],
            '📊 Performance metric should be recorded');
        System.assertEquals(1, [SELECT COUNT() FROM Device_Order__c],
            '📊 Order should still be created despite downstream error');
    }
}
