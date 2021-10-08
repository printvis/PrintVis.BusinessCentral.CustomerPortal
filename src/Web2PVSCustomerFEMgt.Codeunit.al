Codeunit 60931 "PVS Web2PVS Customer FE Mgt"
{

    trigger OnRun()
    begin
    end;

    var
        FileStorageTableRec: Record "PVS Embedded File Storage";
        SetupRec: Record "PVS General Setup";
        UserSetupRec: Record "PVS User Setup";
        JobRecTemp: Record "PVS Job" temporary;
        Web2PVSFESetupRec: Record "PVS Web2PVS Frontend Setup";
        Web2PVSFEAccountRec: Record "PVS Web2PVS Frontend Account";
        CatIndexItemRec: Record "PVS Web2PVS Cat. Index Items";
        CatIndexItemRecTemp: Record "PVS Web2PVS Cat. Index Items" temporary;
        CatItemOptRec: Record "PVS Web2PVS Catalog Item Opt.";
        CatItemOptRecTemp: Record "PVS Web2PVS Catalog Item Opt." temporary;
        WebHeaderRec: Record "PVS Web2PVS Header";
        WebHeaderRecTemp: Record "PVS Web2PVS Header" temporary;
        WebLineRec: Record "PVS Web2PVS Line";
        WebLineRecTemp: Record "PVS Web2PVS Line" temporary;
        WebPartRecTemp: Record "PVS Web2PVS Part" temporary;
        WebAdditionalRec: Record "PVS Web2PVS Additional";
        WebAdditionalRecTemp: Record "PVS Web2PVS Additional" temporary;
        IntegerTemp: Record "Integer" temporary;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        CustomerFEMgt: Codeunit "PVS Customer Frontend Mgt";
        SingleInstance: Codeunit "PVS SingleInstance";
        MiscFct: Codeunit "PVS Misc. Fct.";
        Web2PVSBackEnd: Codeunit "PVS Web2PVS Backend NAV";
#if OnPrem
        XmlDoc: dotnet XmlDocument;
#endif
        GlobalReqNo: Code[20];
        GlobalReqLineNo: Integer;
        TypeOption: Option " ",configure,addtocart,createquote;
        GlobalAccountSetupLoaded: Boolean;
        RC_Text001: label 'Main Catalog';
        RC_Text002: label 'Shopping Cart';
        RC_Text003: label 'Calculate Price';
        RC_Text004: label 'Add to Cart';
        RC_Text005: label 'Quantity';
        RC_Text006: label 'Please make your selection from these options';
        RC_Text007: label 'Pricing';
        RC_Text008: label 'No price can be calculated due to wrong setup. Please contact your Sales Representative.';
        RC_Text009: label 'Your price';
        RC_Text010: label '%1 x %2 added to cart';
        RC_Text011: label 'Create Quote';
        RC_Text012: label 'Create Quote failed. Please contact IT';
        Text011: label 'Qty';
        Text012: label 'Description';
        Text013: label 'Amount';
        Text014: label 'Total';
        Text015: label 'Order %1 created.';

    procedure RoleCenter_BuildSessionIndex(in_Web2PVSFEAccountRec: Record "PVS Web2PVS Frontend Account")
    var
        SessionIndexRec: Record "PVS Web2PVS Session Index";
        CatalogRecTemp: Record "PVS Web2PVS Catalog" temporary;
        CatalogIndexRec: Record "PVS Web2PVS Catalog Index";
        CatalogIndexRecTemp: Record "PVS Web2PVS Catalog Index" temporary;
    begin
        SessionIndexRec.SetRange(NAVSessionID, SessionId());
        SessionIndexRec.SetRange(Type, SessionIndexRec.Type::CatalogIndex);
        SessionIndexRec.DeleteAll();

        Web2PVSBackEnd.GetCatalog(in_Web2PVSFEAccountRec."Frontend ID",
          in_Web2PVSFEAccountRec."Login ID",
          in_Web2PVSFEAccountRec."Frontend Login ID",
          '', '',
          CatalogRecTemp,
          CatalogIndexRecTemp);

        if CatalogIndexRecTemp.FindSet() then
            repeat
                SessionIndexRec.Init();
                SessionIndexRec.NAVSessionID := SessionId();
                SessionIndexRec."Catalog Code" := CatalogIndexRecTemp."Catalog Code";
                SessionIndexRec."Catalog Entry No." := CatalogIndexRecTemp."Catalog Entry No.";
                SessionIndexRec.Index := CatalogIndexRecTemp.Index;
                SessionIndexRec.Type := SessionIndexRec.Type::CatalogIndex;
                SessionIndexRec.Description := CatalogIndexRecTemp.Description;
                SessionIndexRec."Sorting Order" := CatalogIndexRecTemp."Sorting Order";
                case CatalogIndexRecTemp."Storage Type" of
                    CatalogIndexRecTemp."storage type"::"File Storage Table":
                        if FileStorageTableRec.Get(CatalogIndexRecTemp."File Code", CatalogIndexRecTemp."File Type") then
                            if FileStorageTableRec.Picture.Hasvalue() then begin
                                FileStorageTableRec.CalcFields(Picture);
                                SessionIndexRec.Picture := FileStorageTableRec.Picture;
                            end;
                    CatalogIndexRecTemp."storage type"::Embedded:
                        begin
                            if CatalogIndexRecTemp."Embedded File".Hasvalue() then begin
                                if CatalogIndexRec.Get(CatalogIndexRecTemp."Catalog Code", CatalogIndexRecTemp."Catalog Entry No.", CatalogIndexRecTemp.Index) then begin
                                    CatalogIndexRec.CalcFields("Embedded File");
                                    SessionIndexRec.Picture := CatalogIndexRec."Embedded File";
                                end;
                            end;
                        end;
                end;
                SessionIndexRec.Insert();
            until CatalogIndexRecTemp.Next() = 0;
    end;

    procedure RoleCenter_Open_CatalogIndex(in_SessionIndexRec: Record "PVS Web2PVS Session Index"; var out_CatalogItemRec: Record "PVS Web2PVS Session Index")
    var
        ExtTextRecTemp: Record "Extended Text Line" temporary;
        SalesPriceRecTemp: Record "Sales Price" temporary;
        CatalogItemsRecTemp: Record "PVS Web2PVS Cat. Index Items" temporary;
        CatalogItemsExtRec: Record "PVS Web2PVS Catalog Item Ext.";
        CatalogItemsExtRecTemp: Record "PVS Web2PVS Catalog Item Ext." temporary;
        CatalogItemsOptRecTemp: Record "PVS Web2PVS Catalog Item Opt." temporary;
        i: Integer;
    begin
        FE_GetAccountSetup();

        out_CatalogItemRec.SetRange(NAVSessionID, SessionId());
        out_CatalogItemRec.SetRange(Type, out_CatalogItemRec.Type::ItemIndex);
        out_CatalogItemRec.DeleteAll();

        Web2PVSBackEnd.GetProducts(Web2PVSFEAccountRec."Frontend ID",
          Web2PVSFEAccountRec."Login ID",
          Web2PVSFEAccountRec."Frontend Login ID",
          in_SessionIndexRec."Catalog Code",
          Format(in_SessionIndexRec."Catalog Entry No."),
          in_SessionIndexRec.Index,
          '',
          CatalogItemsRecTemp,
          CatalogItemsExtRecTemp,
          CatalogItemsOptRecTemp,
          SalesPriceRecTemp,
          ExtTextRecTemp);

        if CatalogItemsRecTemp.FindSet() then
            repeat
                i += 1;
                CatalogItemsRecTemp.CalcFields("Item Description", "Item Description 2");
                out_CatalogItemRec.Init();
                out_CatalogItemRec.NAVSessionID := SessionId();
                out_CatalogItemRec."Catalog Code" := CatalogItemsRecTemp."Catalog Code";
                out_CatalogItemRec."Catalog Entry No." := CatalogItemsRecTemp."Catalog Entry No.";
                out_CatalogItemRec.Index := CatalogItemsRecTemp."Catalog Index";
                out_CatalogItemRec."Sorting Order" := i;
                out_CatalogItemRec.Type := out_CatalogItemRec.Type::ItemIndex;
                out_CatalogItemRec."Item No." := CatalogItemsRecTemp."Item No.";
                out_CatalogItemRec."Item Description" := CatalogItemsRecTemp."Item Description";
                out_CatalogItemRec."Item Description 2" := CatalogItemsRecTemp."Item Description 2";

                CatalogItemsExtRecTemp.SetRange("Catalog Code", CatalogItemsRecTemp."Catalog Code");
                CatalogItemsExtRecTemp.SetRange("Catalog Entry No.", CatalogItemsRecTemp."Catalog Entry No.");
                CatalogItemsExtRecTemp.SetRange("Catalog Index", CatalogItemsRecTemp."Catalog Index");
                CatalogItemsExtRecTemp.SetRange("Item No.", CatalogItemsRecTemp."Item No.");
                CatalogItemsExtRecTemp.SetRange("File Subtype", CatalogItemsExtRecTemp."file subtype"::ProductThumbnail);
                if not CatalogItemsExtRecTemp.FindFirst() then
                    CatalogItemsExtRecTemp.SetRange("File Subtype", CatalogItemsExtRecTemp."file subtype"::ProductImage);
                if CatalogItemsExtRecTemp.FindFirst() then
                    case CatalogItemsExtRecTemp."Storage Type" of
                        CatalogItemsExtRecTemp."storage type"::"File Storage Table":
                            if FileStorageTableRec.Get(CatalogItemsExtRecTemp."File Code", CatalogItemsExtRecTemp."File Type") then
                                if FileStorageTableRec.Picture.Hasvalue() then begin
                                    FileStorageTableRec.CalcFields(Picture);
                                    out_CatalogItemRec.Picture := FileStorageTableRec.Picture;
                                end;
                        CatalogItemsExtRecTemp."storage type"::Embedded:
                            if CatalogItemsExtRecTemp."Embedded File".Hasvalue() then begin
                                if CatalogItemsExtRec.Get(CatalogItemsExtRecTemp."Catalog Code", CatalogItemsExtRecTemp."Catalog Entry No.",
                                     CatalogItemsExtRecTemp."Catalog Index", CatalogItemsExtRecTemp."Item No.",
                                     CatalogItemsExtRecTemp."Entry No.")
                                then begin
                                    CatalogItemsExtRec.CalcFields("Embedded File");
                                    out_CatalogItemRec.Picture := CatalogItemsExtRec."Embedded File";
                                end;
                            end;
                    end;
                out_CatalogItemRec.Insert();

            until CatalogItemsRecTemp.Next() = 0;
    end;

    procedure RoleCenter_Get_CatalogIndexDescription(in_CatalogCode: Code[20]; in_CatalogEntry: Integer; in_Index: Code[20]): Text
    var
        Web2PVSCatalogIndexRec: Record "PVS Web2PVS Catalog Index";
    begin
        if Web2PVSCatalogIndexRec.Get(in_CatalogCode, in_CatalogEntry, in_Index) then
            exit(Web2PVSCatalogIndexRec.Description)
        else
            exit('');
    end;

    procedure RoleCenter_Get_BasketNo(): Code[20]
    begin
        if FE_GetLastBasketHeader() then
            exit(WebHeaderRec."No.")
        else
            exit('');
    end;

    procedure RoleCenter_Open_BasketPage()
    var
        IsHandled: Boolean;
    begin
        Onbefore_RoleCenter_Open_BasketPage(IsHandled);
        if IsHandled then
            exit;
        Page.RunModal(Page::"PVS Customer Shopping Cart 1");
    end;

    procedure RoleCenter_OnSubmit(in_SerializedData: Text; var out_Target: Text; in_ImageBrowser: ControlAddIn "PVS ImageBrowser"; ControlAddinReady: Boolean): Text
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
        JobRecTemp.DeleteAll();

        JobRecTemp.Init();
        JobRecTemp.Insert();

        CatItemOptRecTemp.DeleteAll();
        CatIndexItemRecTemp.DeleteAll();
#if OnPrem
        Split_Text_2_Array(in_SerializedData, '&', FormData);

        Elements := FormData.Count() - 1;
        for i := 0 to Elements do begin
            Split_Text_2_Array(FormData.Item(i), '=', FormElement);
            if FormElement.Count() = 2 then begin
                case HttpUtility.UrlDecode(Format(FormElement.Item(0))) of
                    'REQNO':
                        GlobalReqNo := HttpUtility.UrlDecode(Format(FormElement.Item(1)));
                    'REQLINE':
                        if Evaluate(GlobalReqLineNo, HttpUtility.UrlDecode(Format(FormElement.Item(1)))) then
                            ;
                    'TYPE':
                        begin
                            NameTxt := HttpUtility.UrlDecode(Format(FormElement.Item(0)));
                            KeyTxt := '';
                            ValueTxt := HttpUtility.UrlDecode(Format(FormElement.Item(1)));
                            case ValueTxt of
                                'configure':
                                    TypeOption := Typeoption::configure;
                                'addtocart':
                                    TypeOption := Typeoption::addtocart;
                                'createquote':
                                    TypeOption := Typeoption::createquote;
                            end;
                        end;
                    'ITEMKEY':
                        begin
                            NameTxt := HttpUtility.UrlDecode(Format(FormElement.Item(0)));
                            KeyTxt := MiscFct.DecodeFromBase64(HttpUtility.UrlDecode(Format(FormElement.Item(1))));
                            ValueTxt := '';
                            CatIndexItemRec.SetPosition(KeyTxt);
                            if CatIndexItemRec.Find('=') then begin
                                CatIndexItemRecTemp := CatIndexItemRec;
                                CatIndexItemRecTemp.Insert();
                                JobRecTemp."Item No." := CatIndexItemRec."Item No.";
                                JobRecTemp.Modify();
                            end;
                        end;
                    'ITEMQUANTITY':
                        begin
                            NameTxt := HttpUtility.UrlDecode(Format(FormElement.Item(0)));
                            KeyTxt := '';
                            ValueTxt := HttpUtility.UrlDecode(Format(FormElement.Item(1)));
                            if JobRecTemp.Quantity = 0 then
                                if Evaluate(JobRecTemp.Quantity, ValueTxt) then
                                    JobRecTemp.Modify();
                        end;
                    'ITEMAMOUNT':
                        begin
                            NameTxt := HttpUtility.UrlDecode(Format(FormElement.Item(0)));
                            KeyTxt := '';
                            ValueTxt := HttpUtility.UrlDecode(Format(FormElement.Item(1)));
                            if JobRecTemp."Quoted Price" = 0 then
                                if Evaluate(JobRecTemp."Quoted Price", ValueTxt) then
                                    JobRecTemp.Modify();
                        end;
                    'ITEMDESCRIPTION':
                        begin
                            NameTxt := HttpUtility.UrlDecode(Format(FormElement.Item(0)));
                            KeyTxt := '';
                            ValueTxt := HttpUtility.UrlDecode(Format(FormElement.Item(1)));
                            if JobRecTemp."Job Name" = '' then begin
                                JobRecTemp."Job Name" := CopyStr(ValueTxt, 1, MaxStrLen(JobRecTemp."Job Name"));
                                JobRecTemp.Modify();
                            end;
                        end;
                    else begin
                            NameTxt := '';
                            KeyTxt := MiscFct.DecodeFromBase64(HttpUtility.UrlDecode(Format(FormElement.Item(0))));
                            ValueTxt := HttpUtility.UrlDecode(Format(FormElement.Item(1)));
                            CatItemOptRec.SetPosition(KeyTxt);
                            if CatItemOptRec.Find('=') then begin
                                CatItemOptRecTemp := CatItemOptRec;
                                CatItemOptRecTemp."Option Value" := ValueTxt;
                                CatItemOptRecTemp.Insert();
                                IntegerTemp.Number := CatItemOptRec."Part No.";
                                if IntegerTemp.Insert() then;
                            end;
                        end;
                end;
            end;
        end;
#endif
        case TypeOption of
            Typeoption::configure:
                exit(FE_ConfigureProduct(out_Target, in_ImageBrowser));
            Typeoption::addtocart:
                exit(FE_AddToCart(out_Target, in_ImageBrowser, ControlAddinReady));
            Typeoption::createquote:
                exit(FE_CreateQuote(out_Target));
        end;
    end;

    procedure RoleCenter_PlaceOrder(): Text
    begin
        WebHeaderRecTemp.DeleteAll();
        WebLineRecTemp.DeleteAll();
        WebAdditionalRecTemp.DeleteAll();

        FE_GetLastBasketHeader();
        WebHeaderRecTemp := WebHeaderRec;
        WebHeaderRecTemp."Web Shop Status" := WebHeaderRecTemp."web shop status"::Submitted;
        WebHeaderRecTemp.Insert();

        WebLineRec.SetRange("Header No.", WebHeaderRec."No.");
        WebLineRec.SetRange("Cart Status", WebLineRec."cart status"::"Not Added");
        WebLineRec.DeleteAll(true);
        WebLineRec.SetRange("Cart Status", WebLineRec."cart status"::Added);
        if WebLineRec.FindSet() then
            repeat
                WebLineRecTemp := WebLineRec;
                WebLineRecTemp.Insert();
            until WebLineRec.Next() = 0;

        WebAdditionalRec.SetRange("Header No.", WebHeaderRec."No.");
        if WebAdditionalRec.FindSet() then
            repeat
                WebAdditionalRecTemp := WebAdditionalRec;
                WebAdditionalRecTemp.Insert();
            until WebAdditionalRec.Next() = 0;

        Web2PVSBackEnd.PlaceOrder(Web2PVSFEAccountRec."Frontend ID", Web2PVSFEAccountRec."Login ID", Web2PVSFEAccountRec."Frontend Login ID",
          WebHeaderRecTemp, WebLineRecTemp, WebAdditionalRecTemp);

        if WebHeaderRecTemp."Error Text" <> '' then
            Error(WebHeaderRecTemp."Error Text")
        else begin
            if WebHeaderRec.Find('=') then
                WebHeaderRec.Delete(true);
            exit(StrSubstNo(Text015, WebHeaderRecTemp."Sales Order No."));
        end;
    end;

    procedure JSAddin_CreateInitContainer() retHtml: Text
    begin
        retHtml := '<table id="w2pvCntnr" class="tblcontainer" style="height:100%;">';
        retHtml += '<tr id="w2pvCntnr_tr1"><td class="w2pvCntnr_td1"><div id="contentArea" style="height:100%;float:left;"></div></td></tr>';
    end;

    procedure JSAddin_CreateInit2colContainer(inCol1Width: Text; inCol2Width: Text) retHtml: Text
    var
        col2css: Text;
    begin
        if inCol1Width <> '' then begin
            retHtml := '<div id="col1parent" style="width:' + inCol1Width + ';height:100%;"><div id="Column1" style="width:100%;" class="tblcellscroll"></div></div>';
            col2css := 'position:absolute; left:' + inCol1Width + '; top:0px; ';
        end else
            retHtml := '<div id="col1parent" style="height:100%;"><div id="Column1" style="width:100%;vertical-align:top;"></div></div>';

        if inCol2Width <> '' then
            retHtml += '<div id="Column2" style="' + col2css + 'width:' + inCol2Width + '; height:100%; overflow:hidden; vertical-align:top; float:left;"></div>'
        else
            retHtml += '<div id="Column2" style="' + col2css + ' height:100%; overflow:hidden; vertical-align:top; float:left;"></div>';
    end;

    procedure JSAddin_CreateBasket() retHtml: Text
    var
        TotalAmount: Decimal;
    begin
        if IsRemoteSalesman() then
            exit;

        retHtml := '<div id="shopBasket" class="basket">';
        retHtml += '<h1 class="subHeaderBlue">' + RC_Text002 + '</h1>';
        retHtml += '<table id="basketContainer">';
        retHtml += '<tr>';
        retHtml += '<td class="basketHead basketCellQty">' + Text011 + '</td>';
        retHtml += '<td class="basketHead basketCellText">' + Text012 + '</td>';
        retHtml += '<td class="basketHead basketCellPrice">' + Text013 + '</td>';
        retHtml += '</tr>';

        if FE_GetLastBasketHeader() then begin
            WebLineRec.SetRange("Header No.", WebHeaderRec."No.");
            WebLineRec.SetRange("Cart Status", WebLineRec."cart status"::Added);
            if WebLineRec.FindSet() then
                repeat
                    retHtml += '<tr>';
                    retHtml += '<td class="basketRow basketCellQty">' + Format(WebLineRec.Quantity) + '</td>';
                    retHtml += '<td class="basketRow basketCellText">' + WebLineRec.Description + '</td>';
                    retHtml += '<td class="basketRow basketCellPrice">' + Format(WebLineRec."Line Amount", 0, '<Precision,2:2><Standard Format,0>') + '</td>';
                    retHtml += '</tr>';
                    TotalAmount += WebLineRec."Line Amount";
                until WebLineRec.Next() = 0;
            retHtml += '<tr>';
            retHtml += '<td class="basketHead basketCellQty" colspan="2">' + Text014 + '</td>';
            retHtml += '<td class="basketHead basketCellPrice">' + Format(TotalAmount, 0, '<Precision,2:2><Standard Format,0>') + '</td>';
            retHtml += '</tr>';
        end;

        retHtml += '</table>';
        retHtml += '</div>';
    end;

    procedure JSAddin_CreateBreadCrumbBar(in_Level: Integer; in_Position: Text; in_Description: Text) retHtml: Text
    begin
        retHtml := '<div id="breadCrumbs" style="clear: both; height: 1.7em;">';
        retHtml += '<span id="root" class="navbutton">' + RC_Text001 + '</span>';

        if in_Level > 0 then begin
            retHtml += '<img src="bulletbreadcrumb.png" class="crumbicon" />';
            retHtml += '<span id="root" class="navbutton">' + in_Description + '</span>';
        end;
    end;

    procedure JSAddin_CreateItemInfo(in_SessionIndexRec: Record "PVS Web2PVS Session Index"; var out_CatalogItemsExtRecTemp: Record "PVS Web2PVS Catalog Item Ext." temporary) retHtml: Text
    var
        GLSetup: Record "General Ledger Setup";
        ExtTextRecTemp: Record "Extended Text Line" temporary;
        SalesPriceRecTemp: Record "Sales Price" temporary;
        JobItemRec: Record "PVS Job Item";
        JobItemRecTemp: Record "PVS Job Item" temporary;
        CatalogItemsRecTemp: Record "PVS Web2PVS Cat. Index Items" temporary;
        CatalogItemsOptRecTemp: Record "PVS Web2PVS Catalog Item Opt." temporary;
        CurrOption: Text;
        EndTxt: Text;
        ExtText: Text;
        PriceDesc: Text;
        PriceTxt: Text;
        StartTxt: Text;
        TxtSelected: Text;
        CurrencyCode: Code[10];
        DropDownBox: Boolean;
        FirstOption: Boolean;
        OptionsCreated: Boolean;
    begin
        FE_GetAccountSetup();

        Web2PVSBackEnd.GetProducts(Web2PVSFEAccountRec."Frontend ID",
          Web2PVSFEAccountRec."Login ID",
          Web2PVSFEAccountRec."Frontend Login ID",
          in_SessionIndexRec."Catalog Code",
          Format(in_SessionIndexRec."Catalog Entry No."),
          in_SessionIndexRec.Index,
          in_SessionIndexRec."Item No.",
          CatalogItemsRecTemp,
          out_CatalogItemsExtRecTemp,
          CatalogItemsOptRecTemp,
          SalesPriceRecTemp,
          ExtTextRecTemp);

        if not CatalogItemsRecTemp.FindFirst() then
            exit(''); // Not Found

        if not GLSetup.FindFirst() then
            GLSetup.Init();

        retHtml := '<form action="">';
        retHtml += '<input type="hidden" name="ITEMKEY" value="' + MiscFct.EncodeToBase64(CatalogItemsRecTemp.GetPosition(false)) + '" />';
        retHtml += '<input type="hidden" name="REQNO" value="' + FE_FindCreateHeaderNo('') + '" /><input type="hidden" name="ITEMDESCRIPTION" value="' + in_SessionIndexRec."Item Description" + '" /><table id="itemContainer" style="width:100%;">';
        retHtml += '<tr><td class="tblmainwhite" colspan="2"><div class="itemDescription">' + in_SessionIndexRec."Item Description" + '</div></td></tr>';

        // Additional Item Description
        if ExtTextRecTemp.FindSet() then begin
            repeat
                if (ExtText <> '') then
                    if ExtTextRecTemp.Text = '' then
                        ExtText := ExtText + '<br /><br />'
                    else
                        ExtText := ExtText + ' ';
                ExtText := ExtText + ExtTextRecTemp.Text;
            until ExtTextRecTemp.Next() = 0;
            retHtml += '<tr><td class="tblmainwhite" colspan="2"><hr /><div class="itemExtendedText">' + ExtText + '</div></td></tr>';
        end;

        if CatalogItemsRecTemp."Item Production Type" = CatalogItemsRecTemp."item production type"::"Configure To Order" then begin
            // Options
            JobItemRecTemp.DeleteAll();
            if CatalogItemsRecTemp."Template ID" <> 0 then begin
                JobItemRec.SetRange(ID, CatalogItemsRecTemp."Template ID");
                JobItemRec.SetRange(Job, CatalogItemsRecTemp."Template Job");
                JobItemRec.SetRange(Version, CatalogItemsRecTemp."Template Version");
                if JobItemRec.FindSet() then
                    repeat
                        JobItemRecTemp := JobItemRec;
                        JobItemRecTemp.Insert();
                    until JobItemRec.Next() = 0;
            end;
            Clear(JobItemRecTemp);
            JobItemRecTemp.ID := CatalogItemsRecTemp."Template ID";
            JobItemRecTemp.Job := CatalogItemsRecTemp."Template Job";
            JobItemRecTemp.Version := CatalogItemsRecTemp."Template Version";
            JobItemRecTemp."Job Item No." := 0;
            JobItemRecTemp.Insert();
            if JobItemRecTemp.FindSet() then
                repeat
                    JobItemRecTemp.CalcFields("Component Type Description");
                    CatalogItemsOptRecTemp.SetRange("Part No.", JobItemRecTemp."Job Item No.");
                    FirstOption := true;
                    CurrOption := '';
                    if CatalogItemsOptRecTemp.FindSet() then begin
                        if CatalogItemsOptRecTemp."Part No." = 0 then
                            retHtml += '<tr><td class="tblmainwhite" colspan="2"><div class="itemSubHeader">' + RC_Text006 + '</div></td></tr>'
                        else
                            if JobItemRecTemp.Description = '' then
                                retHtml += '<tr><td class="tblmainwhite" colspan="2"><div class="itemSubHeader">' + JobItemRecTemp."Component Type Description" + '</div></td></tr>'
                            else
                                retHtml += '<tr><td class="tblmainwhite" colspan="2"><div class="itemSubHeader">' + JobItemRecTemp.Description + '</div></td></tr>';
                        retHtml += '<tr><td class="tblmainwhite" colspan="2"><hr /><table style="width:100%">';
                        repeat
                            if CatalogItemsOptRecTemp."Option Caption" <> CurrOption then begin
                                if (not FirstOption) then begin
                                    if DropDownBox then
                                        retHtml += '</select>';
                                    retHtml += '</div></td></tr>';
                                end;
                                FirstOption := false;
                                retHtml += '<tr><td class="tblmainwhite"><div class="itemExtendedText">' + CatalogItemsOptRecTemp."Option Caption" + '</div></td><td class="tblmainwhite"><div class="itemExtendedText">';
                                if CatalogItemsOptRecTemp."Option Editable" then begin
                                    retHtml += '<input type="text" name="' + MiscFct.EncodeToBase64(CatalogItemsOptRecTemp.GetPosition(false)) + '" value="' + CatalogItemsOptRecTemp."Option Value" + '" />';
                                    DropDownBox := false;
                                end else begin
                                    retHtml += '<select name="' + MiscFct.EncodeToBase64(CatalogItemsOptRecTemp.GetPosition(false)) + '">';
                                    DropDownBox := true;
                                end;
                            end;
                            if not CatalogItemsOptRecTemp."Option Editable" then begin
                                if CatalogItemsOptRecTemp."Default Value" then
                                    TxtSelected := ' selected'
                                else
                                    TxtSelected := '';
                                retHtml += '<option value="' + CatalogItemsOptRecTemp."Option Value" + '"' + TxtSelected + '>' + CatalogItemsOptRecTemp."Option Value" + '</option>';
                            end;
                            OptionsCreated := true;
                            CurrOption := CatalogItemsOptRecTemp."Option Caption";
                        until CatalogItemsOptRecTemp.Next() = 0;
                        if OptionsCreated then begin
                            if DropDownBox then
                                retHtml += '</select>';
                            retHtml += '</div></td></tr>';
                        end;

                        retHtml += '</table></td></tr>';
                    end;
                until JobItemRecTemp.Next() = 0;
            retHtml += '<tr><td class="tblmainwhite" colspan="2"><hr /></td></tr>';
            retHtml += '<tr id="submitrow"><td class="tblmainwhite" colspan="2"><input type="hidden" name="TYPE" value="configure" />';
            //  retHtml += '<input type="button" class="formbutton" title="' + RC_Text003 + '" value="' + RC_Text003 + '" onclick="SubmitForm()" /></td></tr>';
            retHtml += '<input type="button" class="cursorinherit ms-nav-button" title="' + RC_Text003 + '" value="' + RC_Text003 + '" onclick="SubmitForm()" /></td></tr>';
        end else begin
            // Price
            if SalesPriceRecTemp.FindSet() then begin
                retHtml += '<tr><td class="tblmainwhite" colspan="2"><div class="itemSubHeader">' + RC_Text007 + '</div></td></tr>';
                retHtml += '<tr><td class="tblmainwhite" colspan="2"><hr /><table style="width:100%">';
                repeat
                    PriceTxt := Format(SalesPriceRecTemp."Unit Price", 0, '<Precision,2:2><Standard Format,0>');
                    StartTxt := Format(SalesPriceRecTemp."Minimum Quantity");
                    if SalesPriceRecTemp.Next() <> 0 then begin
                        EndTxt := Format(SalesPriceRecTemp."Minimum Quantity" - 1);
                        SalesPriceRecTemp.Next(-1);
                    end else
                        EndTxt := '';
                    PriceDesc := StartTxt + ' - ' + EndTxt;
                    if SalesPriceRecTemp."Currency Code" = '' then
                        CurrencyCode := GLSetup."LCY Code"
                    else
                        CurrencyCode := SalesPriceRecTemp."Currency Code";
                    retHtml += '<tr><td class="priceRowDesc"><div class="priceText">' + PriceDesc + '</div></td>';
                    retHtml += '<td class="priceRowDesc"><div class="priceText">' + CurrencyCode + '</div></td>';
                    retHtml += '<td class="priceRowValue"><div class="priceText">' + PriceTxt + '</div></td></tr>';

                until SalesPriceRecTemp.Next() = 0;
                retHtml += '</table></tr>';
            end;
            retHtml += '<tr><td class="tblmainwhite" colspan="2"><hr /></td></tr>';
            retHtml += '<tr id="submitrow"><td class="tblmainwhite"><span class="itemExtendedText">' + RC_Text005 + ' <input type="text" name="ITEMQUANTITY" value="1" /></span></td>';
            retHtml += '<td class="tblmainwhite"><input type="hidden" name="TYPE" value="addtocart" />';
            retHtml += '<input type="button" class="cursorinherit ms-nav-button" title="' + RC_Text004 + '" value="' + RC_Text004 + '" onclick="SubmitForm()" /></td></tr>';
        end;
        retHtml += '</table></form></div>';
    end;

    procedure JSAddin_CreateSplashImage(in_Width: Integer; in_Height: Integer) retJSCode: Text
    var
        TempBlobRec: Record "PVS TempBlob" temporary;
        dataUri: Text;
        localHeight: Integer;
        localWidth: Integer;
    begin
        SingleInstance.Get_SetupRec(SetupRec);
        if SetupRec."Frontend Welcome Picture" = '' then
            exit;

        if not FileStorageTableRec.Get(SetupRec."Frontend Welcome Picture", FileStorageTableRec.Type::Image) then
            exit;

        if not FileStorageTableRec.Picture.Hasvalue() then
            exit;

        FileStorageTableRec.CalcFields(Picture);
        TempBlobRec.Blob := FileStorageTableRec.Picture;
        localWidth := in_Width;
        localHeight := in_Height;
        dataUri := CustomerFEMgt.ResizeAndBase64_Picture(TempBlobRec, localWidth, localHeight);
        retJSCode := '<img src=' + dataUri + ' style=''position:relative;max-width:100%;max-height:100%;''>';
        retJSCode := '$("#controlAddIn").append("' + retJSCode + '");';
    end;

    procedure JSAddin_GetSplashImage() retJSCode: Text
    var
        PVSImageManagement: Codeunit "PVS Image Management";
        TempBlob: Codeunit "Temp Blob";
        PictureStream: InStream;
        dataUri: Text;
    begin
        SingleInstance.Get_SetupRec(SetupRec);
        if SetupRec."Frontend Welcome Picture" = '' then
            exit;

        if not FileStorageTableRec.Get(SetupRec."Frontend Welcome Picture", FileStorageTableRec.Type::Image) then
            exit;

        if not FileStorageTableRec.Picture.Hasvalue() then
            exit;

        FileStorageTableRec.CalcFields(Picture);
        TempBlob.FromRecord(FileStorageTableRec, FileStorageTableRec.FieldNo("Picture"));
        dataUri := PVSImageManagement.GetHTMLImgSrc(TempBlob);

        retJSCode := '<img src=' + dataUri + ' style=''position:relative;max-width:100%;max-height:100%;''>';
        retJSCode := '$("#controlAddIn").append("' + retJSCode + '");';
    end;

    procedure FE_AddToCart(var out_Target: Text; in_ImageBrowser: ControlAddIn "PVS ImageBrowser"; ControlAddinReady: Boolean) retHtml: Text
    var
        WebLineFound: Boolean;
    begin
        FE_GetAccountSetup();

        GlobalReqNo := FE_FindCreateHeaderNo(GlobalReqNo);
        if GlobalReqLineNo <> 0 then
            if WebLineRec.Get(GlobalReqNo, GlobalReqLineNo) then
                WebLineFound := true;

        if not WebLineFound then begin
            Clear(WebLineRec);
            FE_InitNewLine(GlobalReqNo);
            WebLineRec.Type := WebLineRec.Type::Item;
            WebLineRec.Validate("No.", JobRecTemp."Item No.");
            WebLineRec.Validate(Quantity, JobRecTemp.Quantity);
        end;

        WebLineRec."Cart Status" := WebLineRec."cart status"::Added;
        WebLineRec.Modify();

        Message(RC_Text010, WebLineRec.Quantity, WebLineRec.Description);

        out_Target := '#submitrow';
        retHtml := '<tr><td class="tblmainwhite"></td></tr>';
        if ControlAddinReady then
            in_ImageBrowser.HidePopup();
    end;

    procedure FE_CreateQuote(var out_Target: Text) retHtml: Text
    var
        CaseRec: Record "PVS Case";
        CaseID: Integer;
        WebLineFound: Boolean;
    begin
        FE_GetAccountSetup();

        GlobalReqNo := FE_FindCreateHeaderNo(GlobalReqNo);
        if GlobalReqLineNo <> 0 then
            if WebLineRec.Get(GlobalReqNo, GlobalReqLineNo) then
                WebLineFound := true;

        if not WebLineFound then begin
            Clear(WebLineRec);
            FE_InitNewLine(GlobalReqNo);
            WebLineRec.Type := WebLineRec.Type::Item;
            WebLineRec.Validate("No.", JobRecTemp."Item No.");
            WebLineRec.Validate(Quantity, JobRecTemp.Quantity);
        end;

        WebLineRec.Modify();

        // Fire Backend
        CaseID := Web2PVSBackEnd.CreateQuote(GlobalReqNo);
        Commit();

        if CaseID = 0 then
            Message(RC_Text012)
        else begin
            CaseRec.Get(CaseID);
            CaseRec.SetRecfilter();
            Page.RunModal(Page::"PVS Web2PVS Create Quote", CaseRec);
        end;

        out_Target := '#submitrow';
        retHtml := '<tr><td class="tblmainwhite"></td></tr>';
    end;

    procedure FE_ConfigureProduct(var out_Target: Text; var in_ImageBrowser: ControlAddIn "PVS ImageBrowser") retHtml: Text
    var
        popupContent: Text;
    begin
        FE_GetAccountSetup();

        WebHeaderRecTemp.DeleteAll();
        WebLineRecTemp.DeleteAll();
        WebPartRecTemp.DeleteAll();
        WebAdditionalRecTemp.DeleteAll();

        if CatIndexItemRecTemp.FindFirst() then
            CatIndexItemRecTemp.CalcFields("Item Description");

        if JobRecTemp.FindFirst() then;
        if CatItemOptRecTemp.FindSet() then;

        // Header
        WebHeaderRecTemp.Init();
        if GlobalReqNo <> '' then
            WebHeaderRecTemp."No." := GlobalReqNo
        else
            WebHeaderRecTemp."No." := '';
        WebHeaderRecTemp."Web Shop Status" := WebHeaderRecTemp."web shop status"::Submitted;
        WebHeaderRecTemp.Insert();

        // Lines
        Clear(WebLineRecTemp);
        WebLineRecTemp.Init();
        WebLineRecTemp."Header No." := WebHeaderRecTemp."No.";
        WebLineRecTemp."Line No." := 0;
        WebLineRecTemp.Type := WebLineRecTemp.Type::Item;

        WebLineRecTemp."No." := CatIndexItemRecTemp."Item No.";
        WebLineRecTemp.Description := FindOptionValue(0, Database::"PVS Web2PVS Line", WebLineRecTemp.FieldNo(Description), CatIndexItemRec."Item Description", true);
        WebLineRecTemp.Quantity := Text2Dec(FindOptionValue(0, Database::"PVS Web2PVS Line", WebLineRecTemp.FieldNo(Quantity), Format(JobRecTemp.Quantity), true));
        WebLineRecTemp."Format Code" := CopyStr(FindOptionValue(0, Database::"PVS Web2PVS Line", WebLineRecTemp.FieldNo("Format Code"), '', true), 1, MaxStrLen(WebLineRecTemp."Format Code"));
        WebLineRecTemp.Insert();

        IntegerTemp.SetRange(Number, 1, 99);
        if IntegerTemp.FindSet() then
            repeat
                WebPartRecTemp.Init();
                WebPartRecTemp."Header No." := WebLineRecTemp."Header No.";
                WebPartRecTemp."Line No." := WebLineRecTemp."Line No.";
                WebPartRecTemp."Job Part No." := IntegerTemp.Number;
                WebPartRecTemp."Job Part Selected" := true;
                WebPartRecTemp.Pages := Text2Dec(FindOptionValue(IntegerTemp.Number, Database::"PVS Web2PVS Part", WebPartRecTemp.FieldNo(Pages), '', true));
                WebPartRecTemp."Paper Item No." := CopyStr(FindOptionValue(IntegerTemp.Number, Database::"PVS Web2PVS Part", WebPartRecTemp.FieldNo("Paper Item No."), '', true), 1, MaxStrLen(WebPartRecTemp."Paper Item No."));
                WebPartRecTemp."Paper Quality" := CopyStr(FindOptionValue(IntegerTemp.Number, Database::"PVS Web2PVS Part", WebPartRecTemp.FieldNo("Paper Quality"), '', true), 1, MaxStrLen(WebPartRecTemp."Paper Quality"));
                WebPartRecTemp."Paper Grammage" := Text2Dec(FindOptionValue(IntegerTemp.Number, Database::"PVS Web2PVS Part", WebPartRecTemp.FieldNo("Paper Grammage"), '', true));
                WebPartRecTemp."Colors Front" := Text2Dec(FindOptionValue(IntegerTemp.Number, Database::"PVS Web2PVS Part", WebPartRecTemp.FieldNo("Colors Front"), '', true));
                WebPartRecTemp."Colors Back" := Text2Dec(FindOptionValue(IntegerTemp.Number, Database::"PVS Web2PVS Part", WebPartRecTemp.FieldNo("Colors Back"), '', true));
                WebPartRecTemp.Insert();
            until IntegerTemp.Next() = 0;

        // Remaining Options
        CatItemOptRecTemp.Reset();
        if CatItemOptRecTemp.FindSet() then begin
            repeat
                FE_ConfigureProduct_SubOption();
            until CatItemOptRecTemp.Next() = 0;
        end;

        // Fire Backend
        Web2PVSBackEnd.ConfigureProduct(Web2PVSFEAccountRec."Frontend ID",
          Web2PVSFEAccountRec."Login ID", Web2PVSFEAccountRec."Frontend Login ID",
          WebHeaderRecTemp, WebLineRecTemp, WebPartRecTemp, WebAdditionalRecTemp);

        if WebLineRecTemp."Price Status" = WebLineRecTemp."price status"::Undefinable then
            Message(RC_Text008)
        else begin
            out_Target := '#submitrow';
            retHtml := '<input type="hidden" name="REQNO" value="' + WebLineRecTemp."Header No." + '">' +
                '<input type="hidden" name="REQLINE" value="' + Format(WebLineRecTemp."Line No.") + '">';
            popupContent := '<div class="pageSubTitle">' + RC_Text009 + '</div>' +
                '<div class="pageTitle">' + Format(WebLineRecTemp.Amount, 0, '<Precision,2:2><Standard Format,0>') + '</div>';
            if IsRemoteSalesman() then begin
                retHtml := '<input type="hidden" name="TYPE" value="createquote">';
                popupContent += '<input type="button" style="margin-top:13px;" class="cursorinherit ms-nav-button" title="' + RC_Text011 + '" value="' + RC_Text011 + '" onclick="SubmitForm()" />';
            end else begin
                retHtml += '<input type="hidden" name="TYPE" value="addtocart">';
                popupContent += '<input type="button" style="margin-top:13px;" class="cursorinherit ms-nav-button" title="' + RC_Text004 + '" value="' + RC_Text004 + '" onclick="SubmitForm()" />';
            end;
            in_ImageBrowser.SetPopupContent(popupContent);
            in_ImageBrowser.ShowPopup();
        end;
    end;

    local procedure FE_ConfigureProduct_SubOption()
    var
        UserFieldRec: Record "PVS Userfield Field";
        RecRef: RecordRef;
        FieldRefID: Integer;
        SkipSetFieldRef: Boolean;
    begin
        case CatItemOptRecTemp."Table ID" of
            Database::"PVS Web2PVS Header":
                begin
                    RecRef.GetTable(WebHeaderRecTemp);
                    SetFieldRefValue(CatItemOptRecTemp."Field No.", CatItemOptRecTemp."Option Value", RecRef);
                    RecRef.SetTable(WebHeaderRecTemp);
                    WebHeaderRecTemp.Modify();
                end;
            Database::"PVS Web2PVS Line":
                begin
                    RecRef.GetTable(WebLineRecTemp);
                    SetFieldRefValue(CatItemOptRecTemp."Field No.", CatItemOptRecTemp."Option Value", RecRef);
                    RecRef.SetTable(WebLineRecTemp);
                    WebLineRecTemp.Modify();
                end;
            Database::"PVS Web2PVS Part":
                begin
                    WebPartRecTemp.SetRange("Line No.", WebLineRecTemp."Line No.");
                    if CatItemOptRecTemp."Part No." <> 0 then
                        WebPartRecTemp.SetRange("Job Part No.", CatItemOptRecTemp."Part No.");
                    if WebPartRecTemp.FindSet(true, false) then
                        repeat
                            RecRef.GetTable(WebPartRecTemp);
                            SetFieldRefValue(CatItemOptRecTemp."Field No.", CatItemOptRecTemp."Option Value", RecRef);
                            RecRef.SetTable(WebPartRecTemp);
                            WebPartRecTemp.Modify();
                        until WebPartRecTemp.Next() = 0;
                end;
            Database::"PVS Web2PVS Additional":
                begin
                    FieldRefID := CatItemOptRecTemp."Field No.";
                    WebAdditionalRecTemp."Entry No." := GetAddRecNextEntryNo(WebLineRecTemp."Header No.", WebLineRecTemp."Line No.");
                    WebAdditionalRecTemp."Job Part" := CatItemOptRecTemp."Part No.";
                    WebAdditionalRecTemp."Header No." := WebLineRecTemp."Header No.";
                    WebAdditionalRecTemp."Line No." := WebLineRecTemp."Line No.";
                    SkipSetFieldRef := false;
                    case CatItemOptRecTemp."Add. Type" of
                        CatItemOptRecTemp."add. type"::HeadLine:
                            WebAdditionalRecTemp.Type := WebAdditionalRecTemp.Type::HeadLine;
                        CatItemOptRecTemp."add. type"::"Calc Unit":
                            begin
                                WebAdditionalRecTemp.Type := WebAdditionalRecTemp.Type::"Calc Unit";
                                WebAdditionalRecTemp.Code := CopyStr(CatItemOptRecTemp."Option Value", 1, MaxStrLen(WebAdditionalRecTemp.Code));
                                SkipSetFieldRef := true;
                            end;
                        CatItemOptRecTemp."add. type"::UserField:
                            begin
                                WebAdditionalRecTemp.Type := WebAdditionalRecTemp.Type::UserField;
                                WebAdditionalRecTemp."Table ID" := CatItemOptRecTemp."Subtable ID";
                                WebAdditionalRecTemp."Table Subtype" := CatItemOptRecTemp."Subtable Type";
                                WebAdditionalRecTemp."Table Code" := CopyStr(CatItemOptRecTemp."Subtable Code", 1, MaxStrLen(WebAdditionalRecTemp.Code));
                                WebAdditionalRecTemp."Field No." := FieldRefID;
                                if UserFieldRec.Get(WebAdditionalRecTemp."Table ID", WebAdditionalRecTemp."Table Subtype", WebAdditionalRecTemp."Table Code", FieldRefID) then
                                    case UserFieldRec."Data Type" of
                                        UserFieldRec."data type"::Number:
                                            FieldRefID := 13;
                                        UserFieldRec."data type"::"Yes/No":
                                            FieldRefID := 15;
                                        UserFieldRec."data type"::Text,
                                      UserFieldRec."data type"::Date,
                                      UserFieldRec."data type"::Time,
                                      UserFieldRec."data type"::"Selection Field":
                                            FieldRefID := 12;
                                    end
                                else
                                    SkipSetFieldRef := true;
                            end;
                        CatItemOptRecTemp."add. type"::Text:
                            WebAdditionalRecTemp.Type := WebAdditionalRecTemp.Type::Text;
                    end;
                    if not SkipSetFieldRef then begin
                        RecRef.GetTable(WebAdditionalRecTemp);
                        SetFieldRefValue(FieldRefID, CatItemOptRecTemp."Option Value", RecRef);
                        RecRef.SetTable(WebAdditionalRecTemp);
                    end;
                    WebAdditionalRecTemp.Selected := true;
                    WebAdditionalRecTemp.Insert();
                end;
        end;
    end;

    local procedure FE_GetLastBasketHeader(): Boolean
    begin
        FE_GetAccountSetup();

        WebHeaderRec.SetRange("Frontend ID", Web2PVSFEAccountRec."Frontend ID");
        WebHeaderRec.SetRange("Login ID", Web2PVSFEAccountRec."Login ID");
        WebHeaderRec.SetRange("Contact Name", Web2PVSFEAccountRec."Frontend Login ID");
        WebHeaderRec.SetRange("Web Shop Status", WebHeaderRec."web shop status"::New);

        exit(WebHeaderRec.FindLast());
    end;

    local procedure FE_FindCreateHeaderNo(in_ReqNo: Code[20]): Code[20]
    var
        WebHeaderFound: Boolean;
    begin
        FE_GetAccountSetup();

        if in_ReqNo <> '' then
            if WebHeaderRec.Get(in_ReqNo) then
                WebHeaderFound := true;

        if not WebHeaderFound then
            if not FE_GetLastBasketHeader() then begin
                WebHeaderRec.Reset();
                Clear(WebHeaderRec);
                WebHeaderRec.Init();
                WebHeaderRec."Frontend ID" := Web2PVSFEAccountRec."Frontend ID";
                WebHeaderRec."Login ID" := Web2PVSFEAccountRec."Login ID";
                WebHeaderRec."Contact Name" := Web2PVSFEAccountRec."Frontend Login ID";
                Web2PVSFESetupRec.TestField("Web Shop Order Nos.");
                NoSeriesMgt.InitSeries(Web2PVSFESetupRec."Web Shop Order Nos.", '', 0D, WebHeaderRec."No.", Web2PVSFESetupRec."Web Shop Order Nos.");
                WebHeaderRec.Validate("Sell-To No.", Web2PVSFEAccountRec."Customer No.");
                WebHeaderRec."Web Shop Status" := WebHeaderRec."web shop status"::New;
                WebHeaderRec.Insert(true);
            end;

        exit(WebHeaderRec."No.");
    end;

    local procedure FE_InitNewLine(in_ReqNo: Code[20])
    var
        NextLineNo: Integer;
    begin
        WebLineRec.SetRange("Header No.", in_ReqNo);
        if WebLineRec.FindLast() then
            NextLineNo := WebLineRec."Line No." + 10000
        else
            NextLineNo := 10000;

        WebLineRec.Reset();
        Clear(WebLineRec);
        WebLineRec.Init();
        WebLineRec."Header No." := in_ReqNo;
        WebLineRec."Line No." := NextLineNo;
        WebLineRec."Sell-To No." := WebHeaderRec."Sell-To No.";
        WebLineRec.Insert();
    end;

    local procedure FE_GetAccountSetup()
    begin
        if not GlobalAccountSetupLoaded then
            CustomerFEMgt.Get_Account(Web2PVSFEAccountRec, Web2PVSFESetupRec);

        GlobalAccountSetupLoaded := true;

        SingleInstance.Get_UserSetupRec(UserSetupRec);
    end;

    local procedure FindOptionValue(in_PartNo: Integer; in_TableID: Integer; in_FieldID: Integer; in_ValueIfEmpty: Text; in_DeleteRec: Boolean) ret_OptionValue: Text
    begin
        CatItemOptRecTemp.SetRange("Table ID", in_TableID);
        CatItemOptRecTemp.SetRange("Field No.", in_FieldID);
        CatItemOptRecTemp.SetRange("Part No.", in_PartNo);
        if CatItemOptRecTemp.FindFirst() then begin
            ret_OptionValue := CatItemOptRecTemp."Option Value";
            if in_DeleteRec then
                CatItemOptRecTemp.Delete();
        end else
            ret_OptionValue := in_ValueIfEmpty;
    end;

    local procedure Bool2Text(inBool: Boolean): Text
    begin
        if inBool then
            exit('true')
        else
            exit('false');
    end;

    local procedure Text2Bool(inText: Text): Boolean
    begin
        if inText = '' then
            exit(false);

        if Lowercase(CopyStr(inText, 1, 1)) in ['n', 'f', '0'] then
            exit(false)
        else
            exit(true);
    end;

    local procedure Text2Int(inText: Text) retInt: Integer
    begin
        if Evaluate(retInt, inText) then;
    end;

    local procedure Text2BigInt(inText: Text) retBigInt: BigInteger
    begin
        if Evaluate(retBigInt, inText) then;
    end;

    local procedure Text2Dec(inText: Text) retDec: Decimal
    begin
        if StrPos(Format(1 / 2), '.') > 0 then begin
            if Evaluate(retDec, ConvertStr(inText, ',', '.')) then;
        end else begin
            if Evaluate(retDec, ConvertStr(inText, '.', ',')) then;
        end;
    end;

    local procedure Text2Date(inText: Text): Date
    var
        DD: Integer;
        MM: Integer;
        Pos: Integer;
        YY: Integer;
    begin
        Pos := StrPos(inText, '-');
        if Pos > 0 then begin
            if Evaluate(YY, CopyStr(inText, 1, Pos - 1)) then;
            inText := CopyStr(inText, Pos + 1);
        end;

        Pos := StrPos(inText, '-');
        if Pos > 0 then begin
            if Evaluate(MM, CopyStr(inText, 1, Pos - 1)) then;
            inText := CopyStr(inText, Pos + 1);
        end;

        Pos := StrPos(inText, '-');
        if Pos > 0 then begin
            if Evaluate(DD, CopyStr(inText, 1, Pos - 1)) then;
            inText := CopyStr(inText, Pos + 1);
        end;

        exit(Dmy2date(DD, MM, YY));
    end;

    local procedure Text2Time(inText: Text): Time
    var
        TestTime: Time;
        HH: Text;
        MM: Text;
        SS: Text;
        Pos: Integer;
    begin
        Pos := StrPos(inText, ':');
        if Pos > 0 then begin
            HH := CopyStr(inText, 1, Pos - 1);
            inText := CopyStr(inText, Pos + 1);
        end;

        Pos := StrPos(inText, ':');
        if Pos > 0 then begin
            MM := CopyStr(inText, 1, Pos - 1);
            inText := CopyStr(inText, Pos + 1);
        end;

        Pos := StrPos(inText, ':');
        if Pos > 0 then begin
            SS := CopyStr(inText, 1, Pos - 1);
            inText := CopyStr(inText, Pos + 1);
        end;

        case StrLen(HH) of
            0:
                HH := '00';
            1:
                HH := '0' + HH;
        end;
        case StrLen(MM) of
            0:
                MM := '00';
            1:
                MM := '0' + MM;
        end;
        case StrLen(SS) of
            0:
                SS := '00';
            1:
                SS := '0' + SS;
        end;

        if Evaluate(TestTime, HH + MM + SS + 'T') then;
        exit(TestTime);
    end;

    local procedure Text2DateTime(inText: Text): DateTime
    var
        TypeHelper: Codeunit "Type Helper";
        Result: Variant;
#if OnPrem
        XmlConvert: dotnet XmlConvert;
        XmlDateTimeSerializationMode: dotnet XmlDateTimeSerializationMode;
#endif
    begin
#if OnPrem
        XmlConvert := XmlConvert.XmlConvert();
        exit(XmlConvert.ToDateTime(inText, XmlDateTimeSerializationMode.Unspecified));
#else
        TypeHelper.Evaluate(Result, inText, '', '');
        exit(Result);
#endif
    end;

    local procedure SetFieldRefValue(inFieldID: Integer; inFieldValue: Text; var inRecRef: RecordRef)
    var
        FldRef: FieldRef;
    begin
        FldRef := inRecRef.Field(inFieldID);
        case GetTypeValue(inRecRef.Number(), inFieldID) of
            'String':
                FldRef.Value := CopyStr(inFieldValue, 1, FldRef.Length());
            'Decimal':
                FldRef.Value := Text2Dec(inFieldValue);
            'Int32':
                FldRef.Value := Text2Int(inFieldValue);
            'Int64':
                FldRef.Value := Text2BigInt(inFieldValue);
            'Date':
                FldRef.Value := Text2Date(inFieldValue);
            'Time':
                FldRef.Value := Text2Time(inFieldValue);
            'DateTime':
                FldRef.Value := Text2DateTime(inFieldValue);
            'Boolean':
                FldRef.Value := Text2Bool(inFieldValue);
        end;
    end;

    local procedure GetTypeValue(inTableID: Integer; inFieldID: Integer): Text
    var
        FieldRec: Record "Field";
    begin
        if not FieldRec.Get(inTableID, inFieldID) then
            exit('unavailable');

        if FieldRec.ObsoleteState <> FieldRec.Obsoletestate::No then
            exit('unavailable');

        case Lowercase(Format(FieldRec.Type)) of
            'oemtext', 'text', 'code':
                exit('String');
            'decimal':
                exit('Decimal');
            'integer':
                exit('Int32');
            'biginteger':
                exit('Int64');
            'date':
                exit('Date');
            'time':
                exit('Time');
            'datetime':
                exit('DateTime');
            'boolean':
                exit('Boolean');
            else
                exit('n/a');
        end;
    end;

    local procedure GetAddRecNextEntryNo(inDocumentNo: Code[20]; inLineNo: Integer) EntryNo: Integer
    begin
        WebAdditionalRecTemp.SetCurrentkey("Header No.", "Line No.", "Entry No.");
        WebAdditionalRecTemp.SetRange("Header No.", inDocumentNo);
        WebAdditionalRecTemp.SetRange("Line No.", inLineNo);

        if WebAdditionalRecTemp.FindLast() then
            EntryNo := WebAdditionalRecTemp."Entry No." + 10000
        else
            EntryNo := 10000;

        WebAdditionalRecTemp.Init();
    end;

    procedure IsRemoteSalesman(): Boolean
    begin
        FE_GetAccountSetup();
        exit(UserSetupRec."User Type" = UserSetupRec."user type"::"Remote Salesman");
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

    [IntegrationEvent(false, false)]
    procedure Onbefore_RoleCenter_Open_BasketPage(var IsHandled: Boolean)
    begin

    end;
}

