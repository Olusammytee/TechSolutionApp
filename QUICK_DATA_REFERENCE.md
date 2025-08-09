# 🚀 **QUICK DATA CREATION REFERENCE CARD**

## **⚡ FAST TRACK DATA CREATION**

### **🎯 CREATION ORDER (CRITICAL)**
1. **Suppliers First** (5-7 records) - Required for Device lookups
2. **Devices Second** (10-15 records) - Required for Order lookups  
3. **Customers Third** (8-10 records) - Required for Order lookups
4. **Orders Last** (15-20 records) - References all above objects

---

## **📦 SUPPLIER QUICK DATA**

| **Company Name** | **Contact** | **Email** | **Country** | **Rating** | **Active** |
|------------------|-------------|-----------|-------------|------------|------------|
| TechCorp Solutions | Sarah Johnson | sarah.johnson@techcorp.com | United States | 5 | ✅ |
| Global Hardware Inc | Michael Chen | m.chen@globalhardware.com | Canada | 4 | ✅ |
| European Tech Partners | Emma Schmidt | emma.schmidt@eurotech.de | Germany | 5 | ✅ |
| Asia Pacific Systems | Hiroshi Tanaka | h.tanaka@apsystems.jp | Japan | 4 | ✅ |
| Budget Components Ltd | David Wilson | d.wilson@budgetcomp.co.uk | United Kingdom | 3 | ✅ |
| Premium Solutions Group | Maria Rodriguez | maria.rodriguez@premiumsol.com | United States | 5 | ✅ |
| Local Tech Supplies | James Thompson | james@localtechsupplies.com | United States | 2 | ❌ |

---

## **💻 DEVICE QUICK DATA**

### **Hardware (5 Records)**
| **Name** | **Type** | **Price** | **Cost** | **Stock** | **Min Stock** | **Supplier** |
|----------|----------|-----------|----------|-----------|---------------|--------------|
| Dell OptiPlex 7090 | Computer | $1,299 | $899 | 25 | 10 | TechCorp Solutions |
| HP ProLiant DL380 | Server | $4,599 | $3,299 | 8 | 5 | Global Hardware Inc |
| Cisco Catalyst 2960 | Networking | $899 | $649 | 3 | 5 | European Tech Partners |
| Synology DS920+ | Storage | $549 | $399 | 15 | 8 | Asia Pacific Systems |
| iPad Pro 12.9" | Mobile Device | $1,099 | $799 | 12 | 6 | Premium Solutions Group |

### **Software (5 Records)**
| **Name** | **Type** | **Price** | **Cost** | **Stock** | **Min Stock** | **Supplier** |
|----------|----------|-----------|----------|-----------|---------------|--------------|
| Microsoft Office 365 | Software | $149 | $99 | 100 | 25 | TechCorp Solutions |
| Adobe Creative Cloud | License | $599 | $449 | 20 | 10 | Premium Solutions Group |
| Salesforce Enterprise | Cloud Service | $165 | $125 | 50 | 20 | Global Hardware Inc |
| AutoCAD Professional | Digital Asset | $1,775 | $1,299 | 10 | 5 | European Tech Partners |
| Antivirus Enterprise | Software | $45 | $29 | 200 | 50 | Budget Components Ltd |

### **Accessories (5 Records)**
| **Name** | **Type** | **Price** | **Cost** | **Stock** | **Min Stock** | **Supplier** |
|----------|----------|-----------|----------|-----------|---------------|--------------|
| USB-C Hub | Accessory | $79 | $45 | 35 | 15 | Asia Pacific Systems |
| HDMI Cable 6ft | Cable | $24.99 | $12 | 75 | 30 | Budget Components Ltd |
| Wireless Mouse | Peripheral | $39.99 | $22 | 45 | 20 | Local Tech Supplies |
| RAM Module 16GB | Component | $129 | $89 | 22 | 10 | TechCorp Solutions |
| Printer Toner | Consumable | $89.99 | $55 | 18 | 12 | Premium Solutions Group |

---

## **👥 CUSTOMER QUICK DATA**

### **Business Customers (6 Records)**
| **Name** | **Type** | **Email** | **Status** | **Credit Limit** |
|----------|----------|-----------|------------|------------------|
| Acme Corporation | Enterprise | procurement@acmecorp.com | Active | $50,000 |
| StartUp Innovations LLC | Small Business | orders@startupinnovations.com | VIP | $15,000 |
| City Government IT Dept | Government | it.procurement@citygovt.org | Active | $75,000 |
| Education Foundation | Non-Profit | tech@educationfoundation.org | Active | $25,000 |
| Global Manufacturing Inc | Enterprise | it.orders@globalmanufacturing.com | VIP | $100,000 |
| Local Consulting Group | Small Business | admin@localconsulting.com | Prospect | $10,000 |

### **Individual Customers (4 Records)**
| **Name** | **Type** | **Email** | **Status** | **Credit Limit** |
|----------|----------|-----------|------------|------------------|
| John Smith | Individual | john.smith@email.com | Active | $5,000 |
| Emily Davis | Student | emily.davis@university.edu | Active | $2,500 |
| Robert Johnson | Senior | robert.johnson@email.com | VIP | $7,500 |
| Sarah Wilson | Individual | sarah.wilson@email.com | Inactive | $3,000 |

---

## **📋 ORDER QUICK DATA PATTERNS**

### **Sample Order Scenarios**
| **Device** | **Customer** | **Qty** | **Priority** | **Status** | **Discount** | **Days Ago** |
|------------|--------------|---------|--------------|------------|--------------|--------------|
| Dell OptiPlex 7090 | Acme Corporation | 5 | Medium | Delivered | 10% | 85 |
| HP ProLiant DL380 | Global Manufacturing Inc | 2 | Critical | Shipped | 5% | 7 |
| Microsoft Office 365 | City Government IT Dept | 25 | High | Delivered | 15% | 45 |
| iPad Pro 12.9" | John Smith | 1 | Low | Delivered | 0% | 30 |
| Adobe Creative Cloud | Emily Davis | 1 | Low | Confirmed | 20% | 15 |

---

## **⚡ SPEED CREATION TIPS**

### **🔥 Fastest Data Entry Method**
1. **Use Copy/Paste**: Copy data from reference tables above
2. **Tab Navigation**: Use Tab key to move between fields quickly
3. **Lookup Search**: Type first few letters for quick lookup selection
4. **Date Shortcuts**: Use relative dates (Today-30, Today-45, etc.)
5. **Bulk Similar Records**: Create similar records in batches

### **📅 Date Calculation Helper**
- **Today**: Current date
- **Today - 7**: One week ago
- **Today - 15**: Two weeks ago  
- **Today - 30**: One month ago
- **Today - 45**: Six weeks ago
- **Today - 60**: Two months ago
- **Today - 85**: Three months ago

### **💰 Price Range Guidelines**
- **Hardware**: $549 - $4,599 (high-value items)
- **Software**: $45 - $1,775 (license-based pricing)
- **Accessories**: $24.99 - $129 (consumable/peripheral pricing)

### **📊 Stock Level Strategy**
- **High Stock**: 50+ (software licenses, consumables)
- **Medium Stock**: 15-45 (accessories, common hardware)
- **Low Stock**: 3-12 (servers, specialized equipment)

---

## **🔧 VALIDATION RULE REMINDERS**

### **⚠️ Avoid These Common Errors**
- **Negative Quantities**: Always use positive numbers (1, 2, 5, 25)
- **Missing Device**: Always select a device for orders
- **Overselling**: Don't order more than available stock
- **Required Fields**: Fill all required fields (marked with red asterisk)

### **✅ Validation Rule Testing Data**
- **Test Negative Quantity**: Try -1 or 0 (should fail)
- **Test Missing Device**: Leave device blank (should fail)
- **Test Overselling**: Order 100 of low-stock item (should fail)
- **Test Valid Data**: Use positive quantities with selected devices (should succeed)

---

## **📊 FORMULA FIELD VERIFICATION**

### **Profit Margin Calculation**
- **Formula**: `((Price - Cost Price) / Price) * 100`
- **Example**: Price $1,299, Cost $899 = 30.79%
- **Check**: All devices should show realistic profit margins (10-40%)

### **Final Amount Calculation**
- **Formula**: `Total Price * (1 - Discount% / 100)`
- **Example**: Total $6,495, Discount 10% = $5,845.50
- **Check**: Orders with discounts should show reduced final amounts

---

## **🎯 COMPLETION TARGETS**

### **Record Count Goals**
- ✅ **Suppliers**: 5-7 records (geographic diversity)
- ✅ **Devices**: 10-15 records (category diversity)
- ✅ **Customers**: 8-10 records (business/individual mix)
- ✅ **Orders**: 15-20 records (90-day distribution)

### **Data Quality Goals**
- ✅ **Relationships**: All lookups properly connected
- ✅ **Formulas**: All calculations working correctly
- ✅ **Validation**: All rules preventing invalid data
- ✅ **Triggers**: Order automation functioning
- ✅ **Stock Status**: Reflecting current inventory levels

---

## **🚀 NEXT STEPS AFTER DATA CREATION**

1. **Run Verification Checklist**: Use DATA_VERIFICATION_CHECKLIST.md
2. **Test Dashboard Component**: Access OrderDashboardMinimal
3. **Explore List Views**: Use enhanced list views for data analysis
4. **Create Additional Orders**: Test trigger functionality
5. **Document Issues**: Note any problems for troubleshooting

---

## **📞 QUICK TROUBLESHOOTING**

### **Common Issues & Quick Fixes**
- **Lookup Not Found**: Create parent record first (Supplier/Customer)
- **Validation Error**: Check quantity > 0, device selected, stock available
- **Formula Not Calculating**: Ensure all referenced fields have values
- **Trigger Not Firing**: Verify OrderTrigger is deployed and active
- **Dashboard Not Loading**: Check OrderDashboardMinimal component deployment

---

**🎉 You're ready to create comprehensive test data! Follow the creation order, use the reference tables, and verify with the checklist for best results.**
