Page 60965 "PVS Customer Shipments"
{
    Caption = 'Shipments';
    CardPageID = "PVS Customer Shipment";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Sales Shipment Header";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(No; "No.")
                {
                    ApplicationArea = All;
                }
                field(ShiptoCode; "Ship-to Code")
                {
                    ApplicationArea = All;
                }
                field(ShiptoName; "Ship-to Name")
                {
                    ApplicationArea = All;
                }
                field(ShiptoPostCode; "Ship-to Post Code")
                {
                    ApplicationArea = All;
                }
                field(ShiptoCity; "Ship-to City")
                {
                    ApplicationArea = All;
                }
                field(ShiptoCountryRegionCode; "Ship-to Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field(ShiptoContact; "Ship-to Contact")
                {
                    ApplicationArea = All;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                    Visible = false;
                }
                field(PostingDate; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field(CurrencyCode; "Currency Code")
                {
                    ApplicationArea = All;
                }
                field(DocumentDate; "Document Date")
                {
                    ApplicationArea = All;
                }
                field(RequestedDeliveryDate; "Requested Delivery Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                    Visible = false;
                }
                field(ShipmentMethodCode; "Shipment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                    Visible = false;
                }
                field(ShippingAgentCode; "Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                    Visible = false;
                }
                field(ShipmentDate; "Shipment Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
        }
    }

    trigger OnOpenPage()
    begin
        FilterGroup(2);
        SetRange("Sell-to Customer No.", CustomerFEMgt.Get_CustNoFromUserSetup());
        FilterGroup(0);
        SetCurrentkey("Shipment Date");
        Ascending(false);
        if FindFirst() then;
    end;

    var
        CustomerFEMgt: Codeunit "PVS Customer Frontend Mgt";
}

