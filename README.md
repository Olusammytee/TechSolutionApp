# Tech Solutions App

Complete Salesforce inventory management system with devices and orders.

## Quick Deploy to Developer Org

```bash
# 1. Login to your org
sf org login web -a GTP5org

# 2. Deploy the app
sf project deploy start -o GTP5org

# 3. Assign permissions
sf org assign permset -n TechSolutions_Admin -o GTP5org

# 4. Seed sample data
sf apex run --file scripts/apex/data-seed.apex -o GTP5org

# 5. Open the app
sf org open -o GTP5org
```

Then navigate to App Launcher → Tech Solutions
