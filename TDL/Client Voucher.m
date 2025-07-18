/*
==============================================
Monthly Billing Voucher Extractor for Tally
==============================================

Purpose: Extract monthly billing data from Tally at voucher level
Output Columns: Date, Client, Amount
Author: Assistant
Version: 1.0

Usage Instructions:
1. Set fromDate and toDate variables (lines 13-14)
2. Set targetCompany if needed (line 15) - leave empty for current company
3. Ensure Tally ODBC server is running on localhost:9000
4. Run the query

Error Handling:
- Connection timeout handling
- XML parsing error handling
- Data type conversion error handling
- Empty response handling

Notes:
- This TDL focuses on Sales vouchers which typically contain billing information
- PartyLedgerName represents the Client
- Amount is extracted from ledger entries
- Non-cancelled and non-optional vouchers only
==============================================
*/

let
    // === CONFIGURATION PARAMETERS ===
    fromDate = #date(2024,4,1),        // Set your start date
    toDate = #date(2025,3,31),         // Set your end date
    targetCompany = "",                 // Leave empty for current company or specify company name
    tallyPort = 9000,                  // Default Tally ODBC port
    
    // === DATE FORMATTING ===
    _fromDate = Date.ToText(fromDate, "d-MMM-yyyy"),
    _toDate = Date.ToText(toDate, "d-MMM-yyyy"),
    
    // === TDL XML PAYLOAD ===
    // This TDL extracts voucher-level billing data with focus on Sales transactions
    payload_xml_base = "<?xml version=""1.0"" encoding=""utf-8""?>
    <ENVELOPE>
        <HEADER>
            <VERSION>1</VERSION>
            <TALLYREQUEST>Export</TALLYREQUEST>
            <TYPE>Data</TYPE>
            <ID>MonthlyBillingReport</ID>
        </HEADER>
        <BODY>
            <DESC>
                <STATICVARIABLES>
                    <SVEXPORTFORMAT>XML (Data Interchange)</SVEXPORTFORMAT>
                    <SVFROMDATE>$fromDate</SVFROMDATE>
                    <SVTODATE>$toDate</SVTODATE>
                    <SVCURRENTCOMPANY>$targetCompany</SVCURRENTCOMPANY>
                </STATICVARIABLES>
                <TDL>
                    <TDLMESSAGE>
                        <!-- Main Report Definition -->
                        <REPORT NAME=""MonthlyBillingReport"">
                            <FORMS>BillingForm</FORMS>
                        </REPORT>
                        
                        <!-- Form Structure -->
                        <FORM NAME=""BillingForm"">
                            <PARTS>VoucherPart</PARTS>
                            <XMLTAG>BILLINGDATA</XMLTAG>
                        </FORM>
                        
                        <!-- Voucher Part -->
                        <PART NAME=""VoucherPart"">
                            <LINES>VoucherLine</LINES>
                            <REPEAT>VoucherLine : BillingVouchers</REPEAT>
                            <SCROLLED>Vertical</SCROLLED>
                        </PART>
                        
                        <!-- Voucher Line Definition -->
                        <LINE NAME=""VoucherLine"">
                            <FIELDS>FldDate, FldClient, FldAmount, FldVoucherType, FldVoucherNumber, FldNarration</FIELDS>
                            <XMLTAG>BILLING_ENTRY</XMLTAG>
                        </LINE>
                        
                        <!-- Field Definitions -->
                        <FIELD NAME=""FldDate"">
                            <SET>$Date</SET>
                            <XMLTAG>DATE</XMLTAG>
                        </FIELD>
                        
                        <FIELD NAME=""FldClient"">
                            <SET>if $$IsEmpty:$PartyLedgerName then ""No Client"" else $PartyLedgerName</SET>
                            <XMLTAG>CLIENT</XMLTAG>
                        </FIELD>
                        
                        <FIELD NAME=""FldAmount"">
                            <SET>$$Number:$Amount</SET>
                            <XMLTAG>AMOUNT</XMLTAG>
                        </FIELD>
                        
                        <FIELD NAME=""FldVoucherType"">
                            <SET>$VoucherTypeName</SET>
                            <XMLTAG>VOUCHERTYPE</XMLTAG>
                        </FIELD>
                        
                        <FIELD NAME=""FldVoucherNumber"">
                            <SET>if $$IsEmpty:$VoucherNumber then ""Auto"" else $VoucherNumber</SET>
                            <XMLTAG>VOUCHERNUMBER</XMLTAG>
                        </FIELD>
                        
                        <FIELD NAME=""FldNarration"">
                            <SET>if $$IsEmpty:$Narration then """" else $Narration</SET>
                            <XMLTAG>NARRATION</XMLTAG>
                        </FIELD>
                        
                        <!-- Collection Definition - Focus on Sales/Billing Vouchers -->
                        <COLLECTION NAME=""BillingVouchers"">
                            <TYPE>Voucher</TYPE>
                            <FETCH>PartyLedgerName, Amount, Date, VoucherTypeName, VoucherNumber, Narration</FETCH>
                            <FILTER>NotCancelled, NotOptional, IsBilling</FILTER>
                        </COLLECTION>
                        
                        <!-- Filter Definitions -->
                        <SYSTEM TYPE=""Formulae"" NAME=""NotCancelled"">NOT $IsCancelled</SYSTEM>
                        <SYSTEM TYPE=""Formulae"" NAME=""NotOptional"">NOT $IsOptional</SYSTEM>
                        <SYSTEM TYPE=""Formulae"" NAME=""IsBilling"">
                            $$IsSales:$VoucherTypeName OR 
                            $$Upper:$VoucherTypeName = ""SALES"" OR 
                            $$Upper:$VoucherTypeName = ""INVOICE"" OR
                            $$Upper:$VoucherTypeName = ""BILLING""
                        </SYSTEM>
                        
                    </TDLMESSAGE>
                </TDL>
            </DESC>
        </BODY>
    </ENVELOPE>",
    
    // === XML PAYLOAD PREPARATION ===
    payload_step1 = Text.Replace(payload_xml_base, "$fromDate", _fromDate),
    payload_step2 = Text.Replace(payload_step1, "$toDate", _toDate),
    payload_final = if targetCompany = "" 
                   then Text.Replace(payload_step2, "<SVCURRENTCOMPANY>$targetCompany</SVCURRENTCOMPANY>", "") 
                   else Text.Replace(payload_step2, "$targetCompany", targetCompany),
    
    // === TALLY CONNECTION WITH ERROR HANDLING ===
    GetTallyData = () =>
        try
            let
                response = Web.Contents(
                    "http://localhost:" & Text.From(tallyPort), 
                    [ 
                        Content = Text.ToBinary(payload_final, TextEncoding.Utf16), 
                        Headers = [#"Content-Type" = "text/xml;charset=utf-16"],
                        Timeout = #duration(0, 0, 1, 0)  // 1 minute timeout
                    ]
                ),
                responseText = Text.FromBinary(response, TextEncoding.Utf16)
            in
                responseText
        otherwise
            error "Connection to Tally failed. Please ensure Tally is running with ODBC server enabled on port " & Text.From(tallyPort),
    
    // === DATA EXTRACTION AND TRANSFORMATION ===
    rawResponse = GetTallyData(),
    
    // Parse XML response
    xmlData = try Xml.Tables(rawResponse) otherwise error "Failed to parse XML response from Tally",
    
    // Extract main table
    mainTable = try xmlData{0}[Table] otherwise error "No data found in Tally response",
    
    // Transform to required format
    transformedData = try
        let
            // Clean and type the data
            cleanedData = Table.TransformColumnTypes(
                mainTable,
                {
                    {"DATE", type date}, 
                    {"CLIENT", type text}, 
                    {"AMOUNT", type number},
                    {"VOUCHERTYPE", type text},
                    {"VOUCHERNUMBER", type text},
                    {"NARRATION", type text}
                }
            ),
            
            // Remove empty client names and handle null values
            filteredData = Table.SelectRows(cleanedData, each [CLIENT] <> null and [CLIENT] <> "No Client"),
            
            // Select only required columns
            finalColumns = Table.SelectColumns(filteredData, {"DATE", "CLIENT", "AMOUNT"}),
            
            // Rename columns for consistency
            renamedColumns = Table.RenameColumns(finalColumns, {{"DATE", "Date"}, {"CLIENT", "Client"}, {"AMOUNT", "Amount"}})
        in
            renamedColumns
    otherwise
        error "Failed to transform data. Please check the TDL structure and Tally data format",
    
    // === FINAL VALIDATION ===
    validatedResult = if Table.RowCount(transformedData) = 0 
                     then error "No billing data found for the specified date range. Please check your date range and voucher types in Tally."
                     else transformedData

in
    validatedResult
