Page 60961 "PVS Customer Product Catalog"
{
    Caption = 'Product Catalog';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    ShowFilter = false;

    layout
    {
        area(content)
        {
            usercontrol(ImageGallery; "PVS ImageGallery")
            {
                ApplicationArea = All;

                trigger ControlAddInReady()
                begin
                    AddInReady();
                end;

                trigger GalleryItemClicked(Identifier: Text)
                begin
                    OpenItemIndex(Identifier);
                end;

                trigger ItemClicked(Identifier: Text; Data: Text)
                begin
                    case Identifier of
                        'root':
                            OpenCatalogIndex(false);
                        'shopBasket':
                            OpenBasketPage();
                        else
                            OpenItemIndex(Identifier);
                    end;
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(OpenCart)
            {
                ApplicationArea = All;
                Caption = 'Shopping Cart';
                Image = PickLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Shopping Cart';

                trigger OnAction()
                begin
                    OpenBasketPage();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        SessionIndexFilter(SessionIndexRec.Type::CatalogIndex);
    end;

    var
        SessionIndexRec: Record "PVS Web2PVS Session Index";
        CustomerFEAPI: Codeunit "PVS Customer Frontend Mgt";
        MiscFct: Codeunit "PVS Misc. Fct.";
        Web2PVSCustFEMgt: Codeunit "PVS Web2PVS Customer FE Mgt";
        ItemHeight: Integer;
        ItemWidth: Integer;
        SessionType: Option CatalogIndex,ItemIndex;
        Text001: label 'Catalog not found';
        Text002: label 'No Picture Available';

    local procedure AddInReady()
    begin
        OpenCatalogIndex(true);
    end;

    local procedure OpenCatalogIndex(in_InitialLoad: Boolean)
    begin
        ItemHeight := 190;
        ItemWidth := 190;
        CurrPage.ImageGallery.InitializeGallery(ItemHeight, ItemWidth);

        if in_InitialLoad then begin
            CurrPage.ImageGallery.AddElement(Web2PVSCustFEMgt.JSAddin_CreateInitContainer(), '#controlAddIn', false);
            //007 CurrPage.ImageGallery.AddElement(Web2PVSCustFEMgt.JSAddin_CreateBasket,'#controlAddIn',FALSE);
        end;
        CurrPage.ImageGallery.AddElement(Web2PVSCustFEMgt.JSAddin_CreateBreadCrumbBar(0, '', ''), '#contentArea', (not in_InitialLoad));

        LoadImages(Sessiontype::CatalogIndex);
    end;

    local procedure OpenItemIndex(in_Position: Text)
    var
        CatalogItemsPage: Page "PVS Customer Item Details";
        DummyAddin: ControlAddIn "PVS ImageBrowser";
        DecodedPosition: Text;
        DummyTarget: Text;
        FormDataSerialized: Text;
    begin
        if in_Position = '' then
            exit;

        DecodedPosition := MiscFct.DecodeFromBase64(in_Position);
        SessionIndexRec.Reset();
        SessionIndexRec.SetPosition(DecodedPosition);
        if SessionIndexRec.Find('=') then begin
            if SessionIndexRec.Type = SessionIndexRec.Type::ItemIndex then begin
                Clear(CatalogItemsPage);
                CatalogItemsPage.SetRecord(SessionIndexRec);
                CatalogItemsPage.Editable(true);
                CatalogItemsPage.RunModal();
                if CatalogItemsPage.GetSerializedData(FormDataSerialized) then
                    Web2PVSCustFEMgt.RoleCenter_OnSubmit(FormDataSerialized, DummyTarget, DummyAddin, false);

                UpdatePage();
            end else begin
                ItemHeight := 150;
                ItemWidth := 150;

                CurrPage.ImageGallery.InitializeGallery(ItemHeight, ItemWidth);
                CurrPage.ImageGallery.AddElement(Web2PVSCustFEMgt.JSAddin_CreateBreadCrumbBar(1, in_Position, SessionIndexRec.Description), '#contentArea', true);
                Web2PVSCustFEMgt.RoleCenter_Open_CatalogIndex(SessionIndexRec, SessionIndexRec);

                LoadImages(Sessiontype::ItemIndex);
            end;
        end else
            Error(Text001);
    end;

    procedure OpenBasketPage()
    begin
        Web2PVSCustFEMgt.RoleCenter_Open_BasketPage();
        UpdatePage();
    end;

    procedure UpdatePage()
    begin
        CurrPage.ImageGallery.RemoveElement('#shopBasket');
        //007 CurrPage.ImageGallery.AddElement(Web2PVSCustFEMgt.JSAddin_CreateBasket,'#controlAddIn',FALSE);
    end;

    local procedure LoadImages(in_Type: Integer)
    var
        TempBlobRec: Record "PVS TempBlob" temporary;
        Base64String: Text;
        LocalHeight: Integer;
        LocalWidth: Integer;
    begin
        SessionIndexFilter(in_Type);

        if SessionIndexRec.FindSet() then
            repeat
                Clear(Base64String);
                if SessionIndexRec.Picture.Hasvalue() then begin
                    SessionIndexRec.CalcFields(Picture);
                    Clear(TempBlobRec.Blob);
                    TempBlobRec.Blob := SessionIndexRec.Picture;
                    LocalWidth := ItemWidth;
                    LocalHeight := ItemHeight;
                    Base64String := CustomerFEAPI.ResizeAndBase64_Picture(TempBlobRec, LocalWidth, LocalHeight);
                end;
                if in_Type = 0 then
                    CurrPage.ImageGallery.AddGalleryItem(MiscFct.EncodeToBase64(SessionIndexRec.GetPosition(false)), '#contentArea',
                      SessionIndexRec.Description, '', 'captionfullframe', Base64String, Text002)
                else
                    CurrPage.ImageGallery.AddGalleryItem(MiscFct.EncodeToBase64(SessionIndexRec.GetPosition(false)), '#contentArea',
                      SessionIndexRec."Item Description", SessionIndexRec."Item Description 2", 'captionfullframe', Base64String, Text002);
            until SessionIndexRec.Next() = 0;

        CurrPage.ImageGallery.PageLoadedComplete();
    end;

    procedure SessionIndexFilter(in_Type: Integer)
    begin
        SessionIndexRec.SetRange(NAVSessionID, SessionId());
        SessionIndexRec.SetRange(Type, in_Type);
    end;
}

