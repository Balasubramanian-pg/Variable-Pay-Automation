let
    // Step 1: Define XML envelope
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

    // Step 2: Fetch raw CSV as plain text
    RawResponse = Text.FromBinary(Web.Contents("http://localhost:9000", [
        Content = Text.ToBinary(xmlEnvelope),
        Headers = [#"Content-Type" = "text/xml"]
    ])),

    // Step 3: Split raw text into individual lines
    Lines = Text.Split(RawResponse, "#(lf)"),

    // Step 4: Remove empty lines
    NonEmptyLines = List.Select(Lines, each Text.Trim(_) <> ""),

    // Step 5: Split each line into fields (CSV format, so handle quotes)
    ParsedLines = List.Transform(NonEmptyLines, each Csv.Document(_, [Delimiter = ",", QuoteStyle = QuoteStyle.Csv])),

    // Step 6: Flatten into a table (each row is one voucher entry)
    Flattened = Table.FromList(ParsedLines, Splitter.SplitByNothing(), null, null, ExtraValues.Ignore),
    Expanded = Table.ExpandTableColumn(Flattened, "Column1", {"Column1", "Column2", "Column3", "Column4", "Column5", "Column6"}),

    // Step 7: Rename columns to meaningful names
    Renamed = Table.RenameColumns(Expanded, {
        {"Column1", "Date"},
        {"Column2", "Ledger Name"},
        {"Column5", "Amount"}
    }, MissingField.Ignore),

    // Step 8: Filter only Sundry Debtors (adjust keyword as needed)
    Filtered = Table.SelectRows(Renamed, each Text.Contains([Ledger Name], "Debtor") or Text.Contains([Ledger Name], "Customer")),

    // Step 9: Select final output columns
    Final = Table.SelectColumns(Filtered, {"Date", "Ledger Name", "Amount"})
in
    Final
