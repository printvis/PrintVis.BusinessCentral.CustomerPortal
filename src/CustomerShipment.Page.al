Page 60966 "PVS Customer Shipment"
{
    Caption = 'Shipment';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Document;
    SourceTable = "Sales Shipment Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(No; "No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(SelltoCustomerName; "Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(SelltoAddress; "Sell-to Address")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(SelltoAddress2; "Sell-to Address 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(SelltoPostCode; "Sell-to Post Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(SelltoCity; "Sell-to City")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(SelltoContact; "Sell-to Contact")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(PostingDate; "Posting Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(DocumentDate; "Document Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(RequestedDeliveryDate; "Requested Delivery Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(PromisedDeliveryDate; "Promised Delivery Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(QuoteNo; "Quote No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(OrderNo; "Order No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(ExternalDocumentNo; "External Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
            }
            part(SalesShipmLines; "PVS Customer Shpt. Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Document No." = field("No.");
            }
            group(Invoicing)
            {
                Caption = 'Invoicing';
                field(BilltoName; "Bill-to Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(BilltoAddress; "Bill-to Address")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(BilltoAddress2; "Bill-to Address 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(BilltoPostCode; "Bill-to Post Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        DoNothing();
                    end;
                }
                field(BilltoCity; "Bill-to City")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        DoNothing();
                    end;
                }
                field(BilltoContact; "Bill-to Contact")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
            }
            group(Shipping)
            {
                Caption = 'Shipping';
                field(ShiptoCode; "Ship-to Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(ShiptoName; "Ship-to Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(ShiptoAddress; "Ship-to Address")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(ShiptoAddress2; "Ship-to Address 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(ShiptoPostCode; "Ship-to Post Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(ShiptoCity; "Ship-to City")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(PackageTrackingNo; "Package Tracking No.")
                {
                    ApplicationArea = All;
                }
                field(ShipmentDate; "Shipment Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Print)
            {
                ApplicationArea = All;
                Caption = 'Print';
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Print';

                trigger OnAction()
                begin
                    CurrPage.SetSelectionFilter(SalesShptHeader);
                    SalesShptHeader.PrintRecords(false);
                end;
            }
        }
    }

    trigger OnModifyRecord(): Boolean
    begin
        Codeunit.Run(Codeunit::"Shipment Header - Edit", Rec);
        exit(false);
    end;

    trigger OnOpenPage()
    begin
        FilterGroup(2);
        SetRange("Sell-to Customer No.", CustomerFEMgt.Get_CustNoFromUserSetup());
        FilterGroup(0);
    end;

    var
        SalesShptHeader: Record "Sales Shipment Header";
        CustomerFEMgt: Codeunit "PVS Customer Frontend Mgt";

    local procedure DoNothing()
    begin
    end;
}

