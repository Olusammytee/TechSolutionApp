# Salesforce Development Guide

**📊 Difficulty Level: Intermediate to Advanced**
**🎯 Purpose: Deep understanding of Salesforce development concepts**
**📚 Part of: [TechSolutionApp Documentation Suite](README.md#-documentation-suite)**

A comprehensive guide to understanding Salesforce DX project structure, metadata components, and development workflows using the TechSolutionApp as a practical example.

## 📖 Navigation

- **🏠 [Back to Main README](README.md)** - Start here if you're new to the project
- **🚨 [Troubleshooting Guide](TROUBLESHOOTING.md)** - Solve deployment issues
- **✅ [Deployment Verification Guide](DEPLOYMENT_VERIFICATION_GUIDE.md)** - Test your deployment
- **📊 [Complete Setup Experience](COMPLETE_SETUP_EXPERIENCE.md)** - Real-world deployment story

## 📚 Learning Path

**Recommended reading order:**
1. **Beginners**: Start with [README.md](README.md) for basic setup
2. **Intermediate**: Read this guide for technical deep-dive
3. **Advanced**: Review [COMPLETE_SETUP_EXPERIENCE.md](COMPLETE_SETUP_EXPERIENCE.md) for professional insights

## 🎯 What You'll Learn

By the end of this guide, you'll understand:
- ✅ Salesforce DX project structure and organization
- ✅ Metadata components and their relationships
- ✅ Professional CLI commands and workflows
- ✅ Best practices for enterprise development
- ✅ Common pitfalls and how to avoid them

## 📁 Salesforce DX Project Structure

Understanding the project structure is crucial for effective Salesforce development. Here's what each folder contains and why:

```
TechSolutionApp/
├── .forceignore                 # Files to ignore during deployment
├── .gitignore                   # Git ignore patterns
├── sfdx-project.json           # Project configuration file
├── README.md                   # Project documentation
├── config/                     # Org-specific configurations
│   └── project-scratch-def.json
├── force-app/                  # Main source directory
│   └── main/
│       └── default/
│           ├── applications/   # Lightning Apps
│           ├── objects/        # Custom Objects & Fields
│           ├── permissionsets/ # Permission Sets
│           └── tabs/          # Custom Tabs
└── scripts/                   # Utility scripts
    └── apex/                  # Apex scripts for data seeding
```

### Key Files Explained

#### `sfdx-project.json`
The project configuration file that defines:
- Package directories and their paths
- Namespace settings
- Source API version
- Package dependencies

```json
{
  "packageDirectories": [
    {
      "path": "force-app",
      "default": true
    }
  ],
  "name": "TechSolutionApp",
  "namespace": "",
  "sfdcLoginUrl": "https://login.salesforce.com",
  "sourceApiVersion": "60.0"
}
```

#### `.forceignore`
Similar to `.gitignore`, this file specifies which metadata to exclude from deployments:
```
**/tmp/**
*.log
.DS_Store
```

## 🧩 Metadata Components Deep-Dive

### Custom Objects

Custom objects are the foundation of your data model. In TechSolutionApp, we have two main objects:

#### Device__c Object
**Location:** `force-app/main/default/objects/Device__c/Device__c.object-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <actionOverrides>
        <actionName>Accept</actionName>
        <type>Default</type>
    </actionOverrides>
    <!-- Additional configuration -->
    <deploymentStatus>Deployed</deploymentStatus>
    <enableActivities>false</enableActivities>
    <enableBulkApi>true</enableBulkApi>
    <enableFeeds>false</enableFeeds>
    <enableHistory>false</enableHistory>
    <enableLicensing>false</enableLicensing>
    <enableReports>true</enableReports>
    <enableSearch>true</enableSearch>
    <enableSharing>true</enableSharing>
    <enableStreamingApi>true</enableStreamingApi>
    <label>Device</label>
    <nameField>
        <label>Device Name</label>
        <type>Text</type>
    </nameField>
    <pluralLabel>Devices</pluralLabel>
    <searchLayouts/>
    <sharingModel>ReadWrite</sharingModel>
    <visibility>Public</visibility>
</CustomObject>
```

**Key Properties:**
- `deploymentStatus`: Controls whether the object is available in production
- `enableReports`: Allows the object to be used in reports
- `sharingModel`: Defines default sharing behavior
- `nameField`: Configures the primary name field

#### Custom Fields

Each custom field has its own metadata file:

**Example:** `Price__c.field-meta.xml`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Price__c</fullName>
    <externalId>false</externalId>
    <label>Price</label>
    <precision>18</precision>
    <required>false</required>
    <scale>2</scale>
    <trackTrending>false</trackTrending>
    <type>Currency</type>
</CustomField>
```

### Custom Tabs

Custom tabs provide navigation to your custom objects in the Lightning Experience.

**Location:** `force-app/main/default/tabs/Device__c.tab-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomTab xmlns="http://soap.sforce.com/2006/04/metadata">
    <customObject>true</customObject>
    <label>Devices</label>
    <motif>Custom67: PDA</motif>
</CustomTab>
```

**Key Elements:**
- `customObject`: Set to `true` for custom object tabs
- `label`: Display name in the tab
- `motif`: Icon used for the tab

### Custom Applications

Lightning Apps organize tabs and provide branded navigation.

**Location:** `force-app/main/default/applications/Tech_Solutions.app-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomApplication xmlns="http://soap.sforce.com/2006/04/metadata">
    <description>Tech Solutions app for managing devices and orders</description>
    <label>Tech Solutions</label>
    <logo>none</logo>
    <navType>Standard</navType>
    <tabs>standard-Home</tabs>
    <tabs>Device__c</tabs>
    <tabs>Device_Order__c</tabs>
    <uiType>Lightning</uiType>
    <formFactors>Large</formFactors>
</CustomApplication>
```

**Key Elements:**
- `uiType`: Must be "Lightning" for modern apps
- `formFactors`: Required for Lightning apps (Large, Medium, Small)
- `tabs`: List of tabs included in the app
- `navType`: Navigation style (Standard or Console)

### Permission Sets

Permission sets grant access to objects, fields, and other features.

**Location:** `force-app/main/default/permissionsets/TechSolutions_Admin.permissionset-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<PermissionSet xmlns="http://soap.sforce.com/2006/04/metadata">
    <description>Administrative permissions for Tech Solutions app</description>
    <hasActivationRequired>false</hasActivationRequired>
    <label>TechSolutions Admin</label>
    <objectPermissions>
        <allowCreate>true</allowCreate>
        <allowDelete>true</allowDelete>
        <allowEdit>true</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>true</modifyAllRecords>
        <object>Device__c</object>
        <viewAllRecords>true</viewAllRecords>
    </objectPermissions>
    <!-- Additional object permissions -->
    <tabSettings>
        <tab>Device_Order__c</tab>
        <visibility>Visible</visibility>
    </tabSettings>
    <tabSettings>
        <tab>Device__c</tab>
        <visibility>Visible</visibility>
    </tabSettings>
</PermissionSet>
```

## 🔧 Salesforce CLI Commands Reference

### Project Management Commands

```bash
# Create new Salesforce DX project
sf project generate --name MyProject

# Validate project structure
sf project deploy validate --target-org myorg

# Deploy project to org
sf project deploy start --target-org myorg

# Check deployment status
sf project deploy report --target-org myorg
```

### Org Management Commands

```bash
# Authorize an org
sf org login web --alias myorg --set-default

# Display org information
sf org display --target-org myorg

# List all authorized orgs
sf org list

# Open org in browser
sf org open --target-org myorg

# Assign permission set
sf org assign permset --name MyPermSet --target-org myorg
```

### Metadata Commands

```bash
# Retrieve metadata from org
sf project retrieve start --metadata CustomObject:MyObject__c

# Deploy specific metadata
sf project deploy start --metadata CustomObject:MyObject__c

# Generate metadata components
sf schema generate sobject --label "My Object" --plural "My Objects"
sf schema generate tab --sobject MyObject__c
```

### Apex Commands

```bash
# Execute Apex from file
sf apex run --file scripts/apex/my-script.apex --target-org myorg

# Execute Apex interactively
sf apex run --target-org myorg

# Run Apex tests
sf apex test run --target-org myorg

# Get test results
sf apex test report --target-org myorg
```

## 🔄 Development Workflow

### 1. Setup Phase
```bash
# Clone project
git clone <repository-url>
cd <project-directory>

# Authorize target org
sf org login web --alias myorg

# Verify connection
sf org display --target-org myorg
```

### 2. Development Phase
```bash
# Create feature branch
git checkout -b feature/new-functionality

# Make changes to metadata
# Edit files in force-app/main/default/

# Validate changes
sf project deploy validate --target-org myorg

# Deploy to org
sf project deploy start --target-org myorg
```

### 3. Testing Phase
```bash
# Assign permissions
sf org assign permset --name MyPermSet --target-org myorg

# Seed test data
sf apex run --file scripts/apex/data-seed.apex --target-org myorg

# Run tests
sf apex test run --target-org myorg

# Open org for manual testing
sf org open --target-org myorg
```

### 4. Integration Phase
```bash
# Commit changes
git add .
git commit -m "feat: add new functionality"

# Push to remote
git push origin feature/new-functionality

# Create pull request
# (Use GitHub/GitLab interface)
```

## 🎯 Best Practices

### Metadata Organization
- Keep related components together
- Use descriptive names and labels
- Include comprehensive descriptions
- Follow naming conventions consistently

### Security
- Use permission sets instead of profiles
- Apply principle of least privilege
- Test permissions thoroughly
- Document security model

### Development
- Use version control for all changes
- Write meaningful commit messages
- Test in scratch orgs before production
- Maintain comprehensive documentation

### Deployment
- Always validate before deploying
- Use incremental deployments
- Monitor deployment results
- Have rollback plans ready

## 🚨 Common Pitfalls and Solutions

### Metadata Structure Issues
- **Problem**: Incorrect XML structure
- **Solution**: Validate against Salesforce metadata schema
- **Prevention**: Use IDE with Salesforce extensions

### Permission Problems
- **Problem**: Users can't access custom objects
- **Solution**: Check permission sets and sharing settings
- **Prevention**: Test with different user profiles

### Deployment Failures
- **Problem**: Components fail to deploy
- **Solution**: Check dependencies and deployment order
- **Prevention**: Use validation deployments first

---

*This guide provides the foundation for understanding Salesforce development. Each concept builds upon the previous ones, creating a comprehensive understanding of the platform's capabilities.*
