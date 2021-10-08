Page 60962 "PVS Customer Item Details"
{
    Caption = 'Item Details';
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = "PVS Web2PVS Session Index";

    layout
    {
        area(content)
        {
            usercontrol(ImageBrowser; "PVS ImageBrowser")
            {
                ApplicationArea = All;

                trigger ControlAddInReady()
                begin
                    InitPage();
                end;

                trigger OnStripImageClicked(identifier: Text; targetHeight: Integer; targetWidth: Integer)
                begin
                    SelectMainImage(identifier, targetHeight, targetWidth);
                end;

                trigger OnSubmitForm(formDataSerialized: Text)
                begin
                    SubmitForm(formDataSerialized);
                end;
            }
        }
    }

    actions
    {
    }

    var
        FileStorageTableRec: Record "PVS Embedded File Storage";
        CatalogItemsExtRec: Record "PVS Web2PVS Catalog Item Ext.";
        CatalogItemsExtRecTemp: Record "PVS Web2PVS Catalog Item Ext." temporary;
        TempBlobRec: Record "PVS TempBlob" temporary;
        PVSGlobal: Codeunit "PVS Global";
        CustomerFEMgt: Codeunit "PVS Customer Frontend Mgt";
        MiscFct: Codeunit "PVS Misc. Fct.";
        Web2PVSCustFEMgt: Codeunit "PVS Web2PVS Customer FE Mgt";
        GlobalFormDataSerialized: Text;
        JavaScriptCmd: Text;
        ActionForParent: Boolean;

    local procedure InitPage()
    begin
        JavaScriptCmd := '$(".spa-task-dialog form", window.top.document).css("max-height","98%");' +
            '$(".spa-task-dialog form", window.top.document).css("height","98%");' +
            '$(".spa-task-dialog form", window.top.document).addClass("task-dialog-maximized");' +
            '$(".spa-task-dialog form", window.top.document).css("width","98%");' +
            '$(".control-addin-container", window.top.document).css("height","100%");' +
            '$(".collapse-ribbon", window.top.document).addClass("ms-nav-hidden");' +
            '$(".dialog-maximize", window.top.document).remove();' +
            '$(".ms-cui-tabContainer", window.top.document).remove();' +
            '$(".ms-cui-tts", window.top.document).remove();' +
            '$("iframe", window.top.document).css("height","100%");' +
            '$("iframe", window.top.document).css("min-height","");' +
            '$("iframe", window.top.document).css("max-height","");';
        CurrPage.ImageBrowser.ExecuteScript(JavaScriptCmd);

        CurrPage.ImageBrowser.SetWindowsClient(PVSGlobal.Is_RTC());
        CurrPage.ImageBrowser.AddElement(Web2PVSCustFEMgt.JSAddin_CreateInit2colContainer('50%', '50%'), '', false);
        CurrPage.ImageBrowser.AddPopupDialog('col1parent');

        CurrPage.ImageBrowser.AddElement(Web2PVSCustFEMgt.JSAddin_CreateItemInfo(Rec, CatalogItemsExtRecTemp), 'Column1', false);

        // Image Browser
        CurrPage.ImageBrowser.SetBrowserTarget('Column2');
        LoadImages();
    end;

    local procedure LoadImages()
    var
        ImageUri: Text;
        NewHeight: Integer;
        NewWidth: Integer;
        FirstImage: Boolean;
    begin
        FirstImage := true;
        CatalogItemsExtRecTemp.SetRange("Storage Type", CatalogItemsExtRecTemp."storage type"::"File Storage Table", CatalogItemsExtRecTemp."storage type"::Embedded);
        CatalogItemsExtRecTemp.SetRange("File Subtype", CatalogItemsExtRecTemp."file subtype"::ProductImage);
        if CatalogItemsExtRecTemp.FindSet() then
            repeat
                case CatalogItemsExtRecTemp."Storage Type" of
                    CatalogItemsExtRecTemp."storage type"::"File Storage Table":
                        if FileStorageTableRec.Get(CatalogItemsExtRecTemp."File Code", CatalogItemsExtRecTemp."File Type") then
                            if FileStorageTableRec.Picture.Hasvalue() then begin
                                FileStorageTableRec.CalcFields(Picture);
                                TempBlobRec.Blob := FileStorageTableRec.Picture;
                            end;
                    CatalogItemsExtRecTemp."storage type"::Embedded:
                        if CatalogItemsExtRecTemp."Embedded File".Hasvalue() then begin
                            if CatalogItemsExtRec.Get(CatalogItemsExtRecTemp."Catalog Code", CatalogItemsExtRecTemp."Catalog Entry No.",
                                 CatalogItemsExtRecTemp."Catalog Index", CatalogItemsExtRecTemp."Item No.",
                                 CatalogItemsExtRecTemp."Entry No.")
                            then begin
                                CatalogItemsExtRec.CalcFields("Embedded File");
                                TempBlobRec.Blob := CatalogItemsExtRec."Embedded File";
                            end;
                        end;
                end;
                NewWidth := 112;
                NewHeight := 76;
                ImageUri := CustomerFEMgt.ResizeAndBase64_Picture(TempBlobRec, NewWidth, NewHeight);
                if ImageUri <> '' then begin
                    CurrPage.ImageBrowser.AddStripImage(MiscFct.EncodeToBase64(CatalogItemsExtRecTemp.GetPosition(false)), '', '', ImageUri, NewWidth, FirstImage);
                    FirstImage := false;
                end;
            until CatalogItemsExtRecTemp.Next() = 0;
    end;

    local procedure SelectMainImage(in_Identifier: Text; in_Height: Integer; in_Width: Integer)
    var
        DecodedPosition: Text;
        ImageUri: Text;
    begin
        DecodedPosition := MiscFct.DecodeFromBase64(in_Identifier);
        CatalogItemsExtRec.Reset();
        CatalogItemsExtRec.SetPosition(DecodedPosition);
        if CatalogItemsExtRec.Find('=') then begin
            case CatalogItemsExtRec."Storage Type" of
                CatalogItemsExtRec."storage type"::"File Storage Table":
                    if FileStorageTableRec.Get(CatalogItemsExtRec."File Code", CatalogItemsExtRec."File Type") then
                        if FileStorageTableRec.Picture.Hasvalue() then begin
                            FileStorageTableRec.CalcFields(Picture);
                            TempBlobRec.Blob := FileStorageTableRec.Picture;
                        end;
                CatalogItemsExtRec."storage type"::Embedded:
                    begin
                        CatalogItemsExtRec.CalcFields("Embedded File");
                        TempBlobRec.Blob := CatalogItemsExtRec."Embedded File";
                    end;
            end;
            ImageUri := CustomerFEMgt.ResizeAndBase64_Picture(TempBlobRec, in_Width, in_Height);
            CurrPage.ImageBrowser.ShowFullImage('', '', ImageUri, in_Width, in_Height);

        end;
    end;

    local procedure SubmitForm(FormDataSerialized: Text)
    var
        NewHtml: Text;
        NewTarget: Text;
    begin
        if IsActionForParent(FormDataSerialized) then begin
            ActionForParent := true;
            GlobalFormDataSerialized := FormDataSerialized;
            CurrPage.Close();
        end;

        if not ActionForParent then begin
            Clear(Web2PVSCustFEMgt);
            NewHtml := Web2PVSCustFEMgt.RoleCenter_OnSubmit(FormDataSerialized, NewTarget, CurrPage.ImageBrowser, true);
            if NewTarget <> '' then begin
                CurrPage.ImageBrowser.AddElement(NewHtml, NewTarget, true);
            end;
        end;
    end;

    local procedure IsActionForParent(inFormDataSerialized: Text): Boolean
    var
#if OnPrem
        FormData: dotnet List_Of_T;
        FormElement: dotnet List_Of_T;
        HttpUtility: dotnet HttpUtility;
#endif
        KeyTxt: Text;
        NameTxt: Text;
        ValueTxt: Text;
        Elements: Integer;
        i: Integer;
    begin
#if OnPrem
        Split_Text_2_Array(inFormDataSerialized, '&', FormData);

        Elements := FormData.Count() - 1;
        for i := 0 to Elements do begin
            Split_Text_2_Array(FormData.Item(i), '=', FormElement);
            if FormElement.Count() = 2 then begin
                if HttpUtility.UrlDecode(Format(FormElement.Item(0))) = 'TYPE' then begin
                    NameTxt := HttpUtility.UrlDecode(Format(FormElement.Item(0)));
                    KeyTxt := '';
                    ValueTxt := HttpUtility.UrlDecode(Format(FormElement.Item(1)));
                    if ValueTxt in ['createquote', 'addtocart'] then
                        exit(true);
                end;
            end;
        end;
#endif
    end;

    procedure GetSerializedData(var outFormDataSerialized: Text): Boolean
    begin
        outFormDataSerialized := GlobalFormDataSerialized;
        exit(ActionForParent);
    end;

    local procedure SaveHtml(inHtml: Variant)
    begin
    end;
#if OnPrem
    procedure Split_Text_2_Array(inText: Text; inDelimiter: Text; var outArray: dotnet List_Of_T)
    var
        netActivator: dotnet Activator;
        netArr: dotnet Array;
        netString: dotnet String;
        netType: dotnet Type;
        DelimiterPos: Integer;
    begin
        netArr := netArr.CreateInstance(GetDotNetType(netType), 1);
        netArr.SetValue(GetDotNetType(netString), 0);

        netType := GetDotNetType(outArray);
        netType := netType.MakeGenericType(netArr);

        outArray := netActivator.CreateInstance(netType);

        DelimiterPos := StrPos(inText, inDelimiter);
        while DelimiterPos > 0 do begin
            outArray.Add(CopyStr(inText, 1, DelimiterPos - 1));
            inText := CopyStr(inText, DelimiterPos + StrLen(inDelimiter));
            DelimiterPos := StrPos(inText, inDelimiter);
        end;
        if inText <> '' then
            outArray.Add(inText);
    end;
#endif
}

