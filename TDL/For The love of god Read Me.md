# Monthly Billing TDL Implementation Guide

## Overview
This TDL solution extracts monthly billing data from Tally at the voucher level, specifically targeting **Sales vouchers** which typically contain billing information for clients.

## Prerequisites

### Tally Setup
1. **Enable ODBC in Tally**
   - Go to Gateway of Tally → F11 (Features) → Company Features
   - Set "Enable ODBC" to Yes
   - Set "ODBC Server Port" to 9000 (default)

2. **Start ODBC Server**
   - In Tally, go to Gateway → F1 (Select Company)
   - Press F6 (ODBC) to start the ODBC server
   - You should see "ODBC Server Started" message

3. **Verify Connection**
   - The server should show "Listening on port 9000"
   - Keep Tally running with the company loaded

### Power Query Setup
1. Open Power BI Desktop or Excel
2. Go to Data → Get Data → Blank Query
3. Open Advanced Editor
4. Paste the TDL code

## Implementation Steps

### Step 1: Choose Your Version
- **Full Version**: More comprehensive error handling and features
- **Simplified Version**: Easier to debug and troubleshoot

### Step 2: Configuration
```powerquery
fromDate = #date(2024,4,1),     // Financial Year Start
toDate = #date(2025,3,31),      // Financial Year End
targetCompany = "",             // Leave empty for current company
```

### Step 3: Test Connection
1. Run the query
2. Check for error messages
3. Verify data output

## Understanding the TDL Structure

### What the TDL Does
1. **Connects to Tally** via ODBC on port 9000
2. **Filters for Sales Vouchers** (billing transactions)
3. **Extracts Key Fields**:
   - Date: Transaction date
   - Client: Party ledger name (customer)
   - Amount: Transaction amount
4. **Excludes**: Cancelled and optional vouchers

### TDL Components Explained

#### Collections
```xml
<COLLECTION NAME="BillingVouchers">
    <TYPE>Voucher</TYPE>
    <FETCH>PartyLedgerName, Amount, Date, VoucherTypeName</FETCH>
    <FILTER>NotCancelled, NotOptional, SalesOnly</FILTER>
</COLLECTION>
```

#### Filters
- `NotCancelled`: Excludes cancelled vouchers
- `NotOptional`: Excludes optional vouchers
- `SalesOnly`: Only includes Sales vouchers (`$$IsSales:$VoucherTypeName`)

#### Fields
- `FldDate`: Voucher date
- `FldClient`: Customer name from PartyLedgerName
- `FldAmount`: Voucher amount

## Troubleshooting Guide

### Common Issues and Solutions

#### 1. Connection Errors
**Error**: "Cannot connect to Tally"
**Solutions**:
- Ensure Tally is running
- Check ODBC server is started (F6 in Tally)
- Verify port 9000 is not blocked by firewall
- Try restarting Tally ODBC server

#### 2. No Data Returned
**Error**: "No billing data found"
**Possible Causes**:
- Date range has no sales vouchers
- Company has no sales transactions
- Voucher types don't match filter criteria

**Solutions**:
- Check date range covers periods with sales
- Verify you have Sales vouchers in Tally
- Modify the `SalesOnly` filter to include other voucher types

#### 3. XML Parsing Errors
**Error**: "Invalid XML response"
**Solutions**:
- Check if Tally returned an error message
- Verify TDL syntax is correct
- Ensure proper XML encoding

#### 4. Data Type Errors
**Error**: "Failed to convert data types"
**Solutions**:
- Check for null values in Amount field
- Verify date formats
- Look for special characters in client names

### Advanced Troubleshooting

#### Debug Mode
To debug, break down the query:
1. Test connection first
2. Check raw XML response
3. Verify XML parsing
4. Test data transformation step by step

#### Custom Voucher Types
If you need other voucher types besides Sales:
```xml
<SYSTEM TYPE="Formulae" NAME="CustomVoucherTypes">
    $$IsSales:$VoucherTypeName OR 
    $$Upper:$VoucherTypeName = "INVOICE" OR
    $$Upper:$VoucherTypeName = "BILLING"
</SYSTEM>
```

## Customization Options

### 1. Include Additional Fields
Add to the LINE definition:
```xml
<FIELD NAME="FldVoucherNumber">
    <SET>$VoucherNumber</SET>
    <XMLTAG>VOUCHERNUMBER</XMLTAG>
</FIELD>
```

### 2. Filter by Client Type
Add to collection filters:
```xml
<SYSTEM TYPE="Formulae" NAME="CustomerOnly">
    $$IsLedgerOfGroup:$PartyLedgerName:"Sundry Debtors"
</SYSTEM>
```

### 3. Amount Filtering
Add minimum amount filter:
```xml
<SYSTEM TYPE="Formulae" NAME="MinAmount">
    $$Number:$Amount >= 1000
</SYSTEM>
```

## Best Practices

### 1. Error Handling
- Always include try-otherwise blocks
- Provide meaningful error messages
- Test with different scenarios

### 2. Performance
- Use appropriate date ranges
- Limit voucher types to necessary ones
- Consider using indexed fields

### 3. Data Quality
- Handle null values appropriately
- Validate data types
- Clean up special characters

### 4. Maintenance
- Document customizations
- Test after Tally updates
- Keep backup of working versions

## Expected Output Format

| Date | Client | Amount |
|------|--------|--------|
| 2024-04-01 | ABC Company | 10000.00 |
| 2024-04-02 | XYZ Ltd | 5000.00 |
| 2024-04-03 | PQR Industries | 7500.00 |

## Support and Further Help

### Common Tally TDL Resources
1. Tally Developer documentation
2. TDL Reference manual
3. Tally community forums

### Query Optimization
- Use specific date ranges
- Filter at collection level
- Minimize field fetches

### Version Control
- Keep working versions documented
- Test changes in non-production environment
- Maintain changelog for modifications

This TDL solution provides a robust foundation for extracting monthly billing data from Tally. The error handling ensures graceful failure modes, while the modular structure allows for easy customization based on specific business requirements.
