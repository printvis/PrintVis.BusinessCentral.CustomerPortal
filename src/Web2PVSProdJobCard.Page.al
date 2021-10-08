Page 60981 "PVS Web2PVS Prod. Job Card"
{
    Caption = 'Production Order';
    DataCaptionExpression = Get_PageCaption();
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "PVS Job";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(JobName; "Job Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Is used to identify the Case and Job, and should contain a Headline which will enable you to refind the job for later copying etc.';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'This is a calculated Flow Field. The field can show the sum of the underlying entries, or simply display a text from another table that relates to this field.';
                }
                field(Quantity; Get_Quantity())
                {
                    ApplicationArea = All;
                    Caption = 'Quantity';
                    DecimalPlaces = 0 : 0;
                    Editable = false;
                    ToolTip = 'This is a calculated Flow Field. The field can show the sum of the underlying entries, or simply display a text from another table that relates to this field.';
                }
                field(FormatCode; "Format Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'In this field you may indicate the format of the finished item as you would look at itFormats can be entered either as a Format code (having defined standard formats such as A4, A5, Legal, Letter etc.) or simply entered displaying the format with a multiplicator-sign between the 2 formats (* or x).The unit used for the formats follows your setup for General Units such as mm, cm or Inches. You may however freely combine such formats using cm, mm or , behind the given format. Hence if you are running your setup in Cm (Centimeters), but wish to enter a format as mm*Inches, you can do so by writing 210mm * 11 ¥ in the field.';
                }
                field(Finishing; Finishing)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'If specific Finishing Units are set up in your system, you can add the Finishing which does NOT belong to any specific sheet or web through this field, adding the Calculation Units belonging to such Finishing Code to the estimation.Finishing Units belonging to a specific Sheet or Web are to be added to the specific JobItem instead.';
                }
                field(ColorsFront; "Colors Front")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'In this field you enter the number of colors for the prima side of the job.';
                }
                field(ColorsBack; "Colors Back")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'In this field you enter the number of colors for the secondary side of the job. If there is no print on the secondary side, the field is left empty.';
                }
                field(QuotedPrice; "Quoted Price")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'In this field, price of the job is displayed according to the selected price method - the price may be overwritten directly in the field as Fixed Quote Price for Job';
                }
            }
            group(ReOrder)
            {
                Caption = 'Re-Order';
                field(Quantitytoreorder; ReOrder_Quantity)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'Quantity to re-order';
                    DecimalPlaces = 0 : 0;
                }
            }
            // group(UploadedFiles)
            // {
            //     Caption = 'Uploaded Files';
            //     field(UplFile; PVSCase."Web2PVS Uploaded Files")
            //     {
            //         ApplicationArea = All;
            //         Caption = 'Uploaded Files';
            //         Editable = false;
            //         ToolTip = 'In this field, price of the job is displayed according to the selected price method - the price may be overwritten directly in the field as Fixed Quote Price for Job';

            //         trigger OnAssistEdit()
            //         var
            //             TempBlob: Record "PVS TempBlob" temporary;
            //             PVSBlobStorage: Codeunit "PVS Blob Storage";
            //             FileName: Text;
            //         begin
            //             FileName := PVSBlobStorage.BlobImport(TempBlob, '');
            //             if FileName = '' then
            //                 exit;

            //             if MoveToRunListFolder(TempBlob, FileName) then begin
            //                 Message(TXT01, GetFilename(FileName));
            //                 PVSCase.Get(ID);
            //                 PVSCase."Web2PVS Uploaded Files" += 1;
            //                 PVSCase.Modify();
            //             end;
            //         end;
            //     }
            // }
        }
    }

    actions
    {
        area(processing)
        {
            action("ActionRe-order")
            {
                ApplicationArea = All;
                Caption = 'Re-Order';
                Image = Copy;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Re-Order';

                trigger OnAction()
                begin
                    Create_New_Order();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        PVSCase.Get(ID);
    end;

    var
        PVSCase: Record "PVS Case";
        ReOrder_Quantity: Decimal;
        ERR01: label 'Upload Not Possible';
        TXT01: label 'File is Uploaded (%1)';
        TXT02: label 'Do You Want to Re-Order This Order?';
        TXT03: label 'Order Re-Ordered';

    local procedure Get_PageCaption() Result: Text
    var
        CaseRec: Record "PVS Case";
    begin
        CaseRec.Get(ID);
        Result := StrSubstNo('%1 [%2-%3]', CaseRec."Order No.", Job, Version);
    end;

    local procedure Get_Quantity() Result: Decimal
    begin
        Result := Quantity;
    end;

    local procedure Create_New_Order()
    var
        PVSJobTo: Record "PVS Job";
        Web2PVSFESetup: Record "PVS Web2PVS Frontend Setup";
        Web2PVSFEAccount: Record "PVS Web2PVS Frontend Account";
        CustomerFrontendMgt: Codeunit "PVS Customer Frontend Mgt";
        CopyManagement: Codeunit "PVS Copy Management";
        NewID: Integer;
    begin
        // get the account and set filters
        if not Confirm(TXT02) then
            Error('');
        CustomerFrontendMgt.Get_Account(Web2PVSFEAccount, Web2PVSFESetup);

        CopyManagement.Set_NewStatusCode(Web2PVSFESetup."Status Code");

        NewID := CopyManagement.Main_Copy_Complete_Case(PVSCase);

        PVSJobTo.Reset();
        PVSJobTo.SetFilter(ID, '%1', NewID);
        PVSJobTo.SetFilter(Active, '%1', true);
        PVSJobTo.SetFilter(Status, '%1|%2', PVSJobTo.Status::Order, PVSJobTo.Status::"Production Order");
        if PVSJobTo.FindLast() then;
        PVSJobTo.Validate(Quantity, ReOrder_Quantity);
        PVSJobTo.Modify(true);
        Message(TXT03);
    end;

    // local procedure MoveToRunListFolder(var in_TempBlob: Record "PVS TempBlob"; var in_FilePath: Text): Boolean
    // var
    //     PVSFolderSetup: Record "PVS Folder Setup";
    //     PVSRunlistFolder: Record "PVS Folder";
    // begin
    //     PVSFolderSetup.Reset();
    //     PVSFolderSetup.SetFilter(Usage, '%1', PVSFolderSetup.Usage::Runlist);
    //     if not PVSFolderSetup.FindFirst() then
    //         Error(ERR01);

    //     PVSRunlistFolder.Init();

    //     PVSRunlistFolder.ID := ID;
    //     PVSRunlistFolder.Folder_Create_Folders();

    //     PVSRunlistFolder.Reset();
    //     PVSRunlistFolder.SetFilter("Group Code", '%1', PVSFolderSetup.Group);
    //     PVSRunlistFolder.SetFilter("Folder ID", '%1', PVSFolderSetup."Folder ID");
    //     PVSRunlistFolder.SetFilter(ID, '%1', ID);
    //     if not PVSRunlistFolder.FindFirst() then
    //         Error(ERR01);

    //     if not PVSRunlistFolder.Folder_Upload_File(in_FilePath, in_TempBlob) then
    //         Error(ERR01);

    //     exit(true);
    // end;

    local procedure GetFilename(Filename: Text): Text
    var
        Name: Text;
        Path: Text;
        Pos: Integer;
        Found: Boolean;
    begin
        Path := '';
        Name := '';
        Filename := DelChr(Filename, '<>');
        if (Filename = '') then
            exit;

        Pos := StrLen(Filename);
        repeat
            Found := (CopyStr(Filename, Pos, 1) = '\');
            if not Found then
                Pos := Pos - 1;
        until (Pos = 0) or Found;

        if Found then begin
            Path := CopyStr(Filename, 1, Pos);
            Name := CopyStr(Filename, Pos + 1);
        end else begin
            Path := '';
            Name := Filename;
        end;

        exit(Name);
    end;
}

