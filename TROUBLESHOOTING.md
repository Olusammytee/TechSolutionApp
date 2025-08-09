# TechSolutionApp Troubleshooting Guide

**📊 Difficulty Level: Beginner to Intermediate**
**🎯 Purpose: Solve deployment and setup issues quickly**
**📚 Part of: [TechSolutionApp Documentation Suite](README.md#-documentation-suite)**

This guide documents common issues encountered during deployment and their solutions, based on real experiences with the TechSolutionApp project.

## 📖 Navigation

- **🏠 [Back to Main README](README.md)** - Complete setup guide
- **🔧 [Salesforce Development Guide](SALESFORCE_DEVELOPMENT_GUIDE.md)** - Deep technical concepts
- **✅ [Deployment Verification Guide](DEPLOYMENT_VERIFICATION_GUIDE.md)** - Post-deployment testing
- **📊 [Complete Setup Experience](COMPLETE_SETUP_EXPERIENCE.md)** - Real-world deployment story

## 🚨 Quick Issue Finder

**Having deployment issues?** Jump to the relevant section:
- [CustomTab Metadata Errors](#customtab-metadata-structure-error) - XML structure problems
- [Lightning App Issues](#lightning-app-formfactors-error) - FormFactors requirements
- [Apex Script Problems](#apex-script-execution-issues) - CLI execution failures
- [Permission Issues](#issue-insufficient-privileges-error) - Access problems
- [Data Seeding Problems](#issue-no-sample-data-visible) - Missing records

## 🚨 Deployment Issues

### CustomTab Metadata Structure Error

**Error Message:**
```
Error parsing file: Element {http://soap.sforce.com/2006/04/metadata}object invalid at this location in type CustomTab (5:11)
```

**Root Cause:**
The CustomTab metadata files were using an incorrect XML structure with `<object>` elements instead of the proper `<customObject>` element.

**Incorrect Structure:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomTab xmlns="http://soap.sforce.com/2006/04/metadata">
  <label>Devices</label>
  <motif>Custom67: PDA</motif>
  <object>Device__c</object>  <!-- INCORRECT -->
</CustomTab>
```

**Correct Structure:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomTab xmlns="http://soap.sforce.com/2006/04/metadata">
    <customObject>true</customObject>  <!-- CORRECT -->
    <label>Devices</label>
    <motif>Custom67: PDA</motif>
</CustomTab>
```

**Solution Steps:**
1. Open the problematic tab metadata files:
   - `force-app/main/default/tabs/Device__c.tab-meta.xml`
   - `force-app/main/default/tabs/Device_Order__c.tab-meta.xml`

2. Replace `<object>ObjectName</object>` with `<customObject>true</customObject>`

3. Ensure proper element ordering (customObject should come first)

4. Redeploy: `sf project deploy start --target-org GTP5org`

### Lightning App FormFactors Error

**Error Message:**
```
FormFactors is required for Lightning apps.
```

**Root Cause:**
Lightning applications require the `formFactors` element to specify supported form factors.

**Solution:**
Add the `formFactors` element to your CustomApplication metadata:

```xml
<CustomApplication xmlns="http://soap.sforce.com/2006/04/metadata">
    <!-- Other elements -->
    <uiType>Lightning</uiType>
    <formFactors>Large</formFactors>  <!-- ADD THIS -->
</CustomApplication>
```

**Supported FormFactors:**
- `Large` - Desktop and tablet landscape
- `Medium` - Tablet portrait
- `Small` - Mobile devices

## 🔧 Apex Script Execution Issues

### Apex Script Fails to Execute via CLI

**Error Symptoms:**
- `sf apex run --file scripts/apex/data-seed.apex --target-org GTP5org` returns exit code 1
- No specific error message displayed
- Script works when executed manually in Developer Console

**Potential Root Causes:**

#### 1. File Path Issues
**Check:** Verify the file path is correct relative to project root
```bash
# Verify file exists
ls -la scripts/apex/data-seed.apex

# Try absolute path
sf apex run --file "$(pwd)/scripts/apex/data-seed.apex" --target-org GTP5org
```

#### 2. Org Authorization Issues
**Check:** Verify org connection
```bash
# Display org information
sf org display --target-org GTP5org

# List all orgs
sf org list

# Re-authorize if needed
sf org login web --alias GTP5org
```

#### 3. Permission Issues
**Check:** Ensure user has proper permissions
```bash
# Verify permission set assignment
sf org assign permset --name TechSolutions_Admin --target-org GTP5org

# Check user permissions in org
sf org open --target-org GTP5org
# Navigate to Setup > Users > [Your User] > Permission Set Assignments
```

#### 4. Deployment Status Issues
**Check:** Verify metadata deployment completed successfully
```bash
# Check deployment status
sf project deploy report --target-org GTP5org

# Redeploy if necessary
sf project deploy start --target-org GTP5org
```

### Alternative Execution Methods

**📊 Difficulty Level: Beginner**
**⏱️ Estimated Time: 5-10 minutes per method**

If CLI execution continues to fail, use these proven alternatives:

#### ✅ Method 1: Developer Console (Recommended)
**Best for: All users, most reliable method**

1. **Open your org**: `sf org open --target-org GTP5org`
2. **Navigate to Developer Console**:
   - Click the **Setup gear icon** (⚙️) in the top right
   - Select **Developer Console** from the dropdown
3. **Execute Anonymous**:
   - In Developer Console: **Debug** menu → **Execute Anonymous**
   - Copy the complete code from `scripts/apex/data-seed.apex`
   - Paste into the Execute Anonymous window
   - ✅ Check "Open Log" checkbox for debugging
   - Click **Execute**
4. **Verify Success**: Look for "Compiled successfully" and check debug logs

#### ✅ Method 2: VS Code Execute Anonymous
**Best for: Developers using VS Code with Salesforce extensions**

1. **Prerequisites**: Ensure Salesforce Extension Pack is installed
2. **Open file**: Navigate to `scripts/apex/data-seed.apex` in VS Code
3. **Select code**: Press `Ctrl+A` (Windows/Linux) or `Cmd+A` (macOS)
4. **Execute**:
   - Press `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (macOS)
   - Type: "SFDX: Execute Anonymous Apex"
   - Select the command and press Enter
5. **Check results**: View output in VS Code's integrated terminal

#### ⚠️ Method 3: Interactive CLI Execution
**Best for: Advanced users comfortable with command line**

**Windows (PowerShell/Command Prompt):**
```bash
# Start interactive session
sf apex run --target-org GTP5org

# Paste the Apex code when prompted
# Press Ctrl+Z then Enter to execute
```

**macOS/Linux (Terminal):**
```bash
# Start interactive session
sf apex run --target-org GTP5org

# Paste the Apex code when prompted
# Press Ctrl+D to execute
```

#### 🔧 Method 4: Manual Record Creation
**Best for: Learning object relationships, troubleshooting data model**

If all Apex methods fail, create records manually to understand the data structure:

1. **Create Device Records**:
   - Navigate to **Devices** tab → **New**
   - Create 2-3 sample devices with different types
   - Note the Device IDs for order creation

2. **Create Device Order Records**:
   - Navigate to **Device Orders** tab → **New**
   - Select a Device from the lookup field
   - Add quantity and status
   - Save and verify the relationship works

### Data Seeding Script Content

If you need to execute the script manually, here's the complete code:

```apex
// Create sample devices
List<Device__c> devices = new List<Device__c>{
    new Device__c(Name='MacBook Pro', Type__c='Laptop', Stock_Quantity__c=25, Price__c=2499.00, Active__c=true),
    new Device__c(Name='iPhone 15', Type__c='Smartphone', Stock_Quantity__c=50, Price__c=999.00, Active__c=true),
    new Device__c(Name='iPad Air', Type__c='Tablet', Stock_Quantity__c=30, Price__c=599.00, Active__c=true),
    new Device__c(Name='Dell XPS 13', Type__c='Laptop', Stock_Quantity__c=15, Price__c=1299.00, Active__c=true),
    new Device__c(Name='Samsung Galaxy S24', Type__c='Smartphone', Stock_Quantity__c=40, Price__c=899.00, Active__c=true)
};

insert devices;
System.debug('Sample devices created: ' + devices.size());

// Create sample orders
List<Device_Order__c> orders = new List<Device_Order__c>{
    new Device_Order__c(Device__c=devices[0].Id, Quantity__c=2, Status__c='Confirmed'),
    new Device_Order__c(Device__c=devices[1].Id, Quantity__c=5, Status__c='Confirmed'),
    new Device_Order__c(Device__c=devices[2].Id, Quantity__c=3, Status__c='Draft')
};

insert orders;
System.debug('Sample orders created: ' + orders.size());
System.debug('Tech Solutions sample data setup complete!');
```

## 🔍 Verification Steps

### Verify Successful Deployment

1. **Check Deployment Status:**
   ```bash
   sf project deploy report --target-org GTP5org
   ```

2. **Verify Objects Exist:**
   - Open org: `sf org open --target-org GTP5org`
   - Navigate to **Setup > Object Manager**
   - Look for `Device` and `Device Order` objects

3. **Check Tab Visibility:**
   - In Lightning Experience, click the **App Launcher** (9 dots)
   - Search for "Tech Solutions" app
   - Verify Device and Device Order tabs are visible

### Verify Data Creation

1. **Check Device Records:**
   - Navigate to **Device** tab
   - Verify 5 sample devices are created
   - Check field values (Name, Type, Stock Quantity, Price, Active)

2. **Check Device Order Records:**
   - Navigate to **Device Order** tab
   - Verify 3 sample orders are created
   - Check relationships to Device records

3. **Verify Relationships:**
   - Open a Device Order record
   - Confirm the Device lookup field shows the correct related Device
   - Check that quantities and statuses are correct

## 📞 Getting Additional Help

### Salesforce Resources
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/)
- [Metadata API Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/)

### Community Support
- [Salesforce Developer Community](https://developer.salesforce.com/forums)
- [Salesforce Stack Exchange](https://salesforce.stackexchange.com/)
- [Trailblazer Community](https://trailhead.salesforce.com/trailblazer-community)

### Debug Information to Collect

When seeking help, provide:
1. **Salesforce CLI Version:** `sf --version`
2. **Operating System:** Windows/macOS/Linux version
3. **Error Messages:** Complete error output
4. **Deployment Status:** Output of `sf project deploy report`
5. **Org Information:** Output of `sf org display --target-org GTP5org`
6. **File Contents:** Relevant metadata file contents

---

*This troubleshooting guide is based on real issues encountered during the TechSolutionApp development process. It will be updated as new issues are discovered and resolved.*
