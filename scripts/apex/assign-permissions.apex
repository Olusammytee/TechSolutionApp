// Assign TechSolutions_Admin Permission Set to Current User
System.debug('=== Assigning Permission Set ===');

try {
    // Get current user
    User currentUser = [SELECT Id, Username, Name FROM User WHERE Id = :UserInfo.getUserId()];
    System.debug('Current User: ' + currentUser.Name + ' (' + currentUser.Username + ')');
    
    // Get permission set
    PermissionSet techSolutionsPS = [SELECT Id, Name, Label FROM PermissionSet WHERE Name = 'TechSolutions_Admin' LIMIT 1];
    System.debug('Permission Set: ' + techSolutionsPS.Label + ' (' + techSolutionsPS.Name + ')');
    
    // Check if assignment already exists
    List<PermissionSetAssignment> existingAssignments = [
        SELECT Id, AssigneeId, PermissionSetId 
        FROM PermissionSetAssignment 
        WHERE AssigneeId = :currentUser.Id AND PermissionSetId = :techSolutionsPS.Id
    ];
    
    if (existingAssignments.isEmpty()) {
        // Create new assignment
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = currentUser.Id;
        psa.PermissionSetId = techSolutionsPS.Id;
        
        insert psa;
        System.debug('✅ Permission Set assigned successfully to ' + currentUser.Name);
    } else {
        System.debug('✅ Permission Set already assigned to ' + currentUser.Name);
    }
    
    // Verify assignment
    List<PermissionSetAssignment> verifyAssignments = [
        SELECT Id, Assignee.Name, PermissionSet.Label 
        FROM PermissionSetAssignment 
        WHERE AssigneeId = :currentUser.Id AND PermissionSetId = :techSolutionsPS.Id
    ];
    
    System.debug('=== PERMISSION VERIFICATION ===');
    for (PermissionSetAssignment psa : verifyAssignments) {
        System.debug('✅ ' + psa.Assignee.Name + ' has ' + psa.PermissionSet.Label);
    }
    
} catch (Exception e) {
    System.debug('ERROR assigning permission set: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== Permission Assignment Complete ===');
