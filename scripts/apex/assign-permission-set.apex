/**
 * Apex Script to Assign TechSolutions_Admin Permission Set
 * 
 * This script directly assigns the permission set to the current user
 * to resolve app launcher visibility issues.
 */

// Get the current user
User currentUser = [SELECT Id, Username FROM User WHERE Id = :UserInfo.getUserId()];
System.debug('Current User: ' + currentUser.Username);

// Get the TechSolutions_Admin permission set
PermissionSet techSolutionsPermSet = [SELECT Id, Name, Label FROM PermissionSet WHERE Name = 'TechSolutions_Admin' LIMIT 1];
System.debug('Permission Set Found: ' + techSolutionsPermSet.Label);

// Check if assignment already exists
List<PermissionSetAssignment> existingAssignments = [
    SELECT Id, PermissionSetId, AssigneeId 
    FROM PermissionSetAssignment 
    WHERE PermissionSetId = :techSolutionsPermSet.Id 
    AND AssigneeId = :currentUser.Id
];

if (existingAssignments.isEmpty()) {
    // Create new permission set assignment
    PermissionSetAssignment assignment = new PermissionSetAssignment();
    assignment.PermissionSetId = techSolutionsPermSet.Id;
    assignment.AssigneeId = currentUser.Id;
    
    try {
        insert assignment;
        System.debug('SUCCESS: Permission set assigned to user ' + currentUser.Username);
        System.debug('Assignment ID: ' + assignment.Id);
    } catch (Exception e) {
        System.debug('ERROR: Failed to assign permission set - ' + e.getMessage());
    }
} else {
    System.debug('INFO: Permission set already assigned to user ' + currentUser.Username);
    System.debug('Existing Assignment ID: ' + existingAssignments[0].Id);
}

// Verify the assignment
List<PermissionSetAssignment> verifyAssignments = [
    SELECT Id, PermissionSet.Name, PermissionSet.Label, Assignee.Username
    FROM PermissionSetAssignment 
    WHERE PermissionSetId = :techSolutionsPermSet.Id 
    AND AssigneeId = :currentUser.Id
];

if (!verifyAssignments.isEmpty()) {
    System.debug('VERIFICATION SUCCESS: Permission set is assigned');
    System.debug('User: ' + verifyAssignments[0].Assignee.Username);
    System.debug('Permission Set: ' + verifyAssignments[0].PermissionSet.Label);
} else {
    System.debug('VERIFICATION FAILED: Permission set assignment not found');
}
