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
    #"Filtered Rows" = Table.SelectRows(#"Renamed Columns1", each ([Transaction Type] = "Sale"))
in
    #"Filtered Rows"
