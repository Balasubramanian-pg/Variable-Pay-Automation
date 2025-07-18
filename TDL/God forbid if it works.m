let
    // Step 1: Define XML envelope for Tally export
    xmlEnvelope = "
    <ENVELOPE>
     <HEADER>
       <TALLYREQUEST>Export Data</TALLYREQUEST>
     </HEADER>
     <BODY>
       <EXPORTDATA>
         <REQUESTDESC>
           <REPORTNAME>Voucher Register</REPORTNAME>
           <STATICVARIABLES>
             <SVFROMDATE>20240401</SVFROMDATE>
             <SVTODATE>20240630</SVTODATE>
           </STATICVARIABLES>
         </REQUESTDESC>
       </EXPORTDATA>
     </BODY>
    </ENVELOPE>",
    
    // Step 2: Fetch response from Tally
    RawResponse = Web.Contents("http://localhost:9000", [
        Content = Text.ToBinary(xmlEnvelope),
        Headers = [#"Content-Type" = "text/xml"]
    ]),
    
    // Step 3: Convert to text
    ResponseText = Text.FromBinary(RawResponse),
    
    // Step 4: Split into lines and remove empty lines
    Lines = Text.Split(ResponseText, "#(lf)"),
    CleanLines = List.Select(Lines, each Text.Trim(_) <> ""),
    
    // Step 5: Create table with row numbers to group transactions
    TableWithIndex = Table.FromList(CleanLines, Splitter.SplitByNothing(), {"Column1"}),
    #"Split Column by Delimiter" = Table.SplitColumn(TableWithIndex, "Column1", Splitter.SplitTextByDelimiter(",", QuoteStyle.Csv), {"Column1.1", "Column1.2", "Column1.3", "Column1.4", "Column1.5", "Column1.6"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Split Column by Delimiter",{{"Column1.1", type text}, {"Column1.2", type text}, {"Column1.3", type text}, {"Column1.4", type number}, {"Column1.5", type number}, {"Column1.6", type text}}),
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type",{{"Column1.1", "Date"}, {"Column1.2", "Ledger"}, {"Column1.3", "Transaction Type"}}),
    #"Removed Columns" = Table.RemoveColumns(#"Renamed Columns",{"Column1.6"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Removed Columns",{{"Column1.4", "Credit"}, {"Column1.5", "Debit"}}),
    
    // ADD THIS STEP: Add Parent Ledger Group column
    #"Added Parent Ledger" = Table.AddColumn(#"Renamed Columns1", "Parent Ledger", each 
        if [Ledger] = null then
            "Unknown"
        else if Text.Contains([Ledger], "Debtor") or Text.Contains([Ledger], "Customer") then
            "Sundry Debtors"
        else if Text.Contains([Ledger], "Creditor") or Text.Contains([Ledger], "Supplier") then
            "Sundry Creditors"
        else if Text.Contains([Ledger], "Cash") then
            "Cash-in-Hand"
        else if Text.Contains([Ledger], "Bank") then
            "Bank Accounts"
        else if Text.Contains([Ledger], "Sales") then
            "Sales Accounts"
        else if Text.Contains([Ledger], "Purchase") then
            "Purchase Accounts"
        else if Text.Contains([Ledger], "Expenses") then
            "Indirect Expenses"
        else if Text.Contains([Ledger], "Income") then
            "Indirect Incomes"
        else
            "Other"
    ),
    
    #"Filtered Rows" = Table.SelectRows(#"Added Parent Ledger", each ([Transaction Type] <> null))
in
    #"Filtered Rows"
