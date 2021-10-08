Page 60964 "PVS Customer Shopping Cart 2"
{
    Caption = 'Customer and Shipment Information';
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ShowFilter = false;
    SourceTable = "PVS Web2PVS Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(TotalOrderAmount; TotalOrderAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Total Order Amount';
                    Editable = false;
                    Style = StrongAccent;
                    StyleExpr = true;
                }
            }
            group(Customer)
            {
                Caption = 'Customer Info';
                field(YourReference; "Your Reference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Own Reference no. from customer';
                }
                field(SellToName; "Sell-To Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Sell-to Customer Name relates to the "Name" field in table "Customer".';
                }
                field(SellToName2; "Sell-To Name 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Sell-to Customer Name 2 relates to the "Name 2" field in table "Customer".';
                }
                field(SellToAddress; "Sell-To Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Sell-to Address relates to the "Address" field in table "Customer".';
                }
                field(SellToPostCode; "Sell-To Post Code")
                {
                    ApplicationArea = All;
                }
                field(SellToCounty; "Sell-To County")
                {
                    ApplicationArea = All;
                    ToolTip = 'Sell-to Country relates to the "Country" field in table "Countries".';
                }
                field(SellToCity; "Sell-To City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Sell-to City relates to the "City" field in table "Customer".';
                }
                field(SellToCountryRegionCode; "Sell-To Country/Region Code")
                {
                    ApplicationArea = All;
                }
            }
            group(Shipment)
            {
                Caption = 'Shipment Info';
                field(ShipToCode; "Ship-To Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Ship-to Code relates to the "Code" field in table "Ship-to Address", which is connected to the customer.';
                }
                field(ShipToName; "Ship-To Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Ship-to Name relates to the "Name" field in table "Ship-to Address", which is connected to the customer.';
                }
                field(ShiptoName2; "Ship-to Name 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Ship-to Name 2 relates to the "Name 2" field in table "Ship-to Address", which is connected to the customer.';
                }
                field(ShipToAddress; "Ship-To Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Ship-to Address relates to the "Address" field in table "Ship-to Address", which is connected to the customer.';
                }
                field(ShipToPostCode; "Ship-To Post Code")
                {
                    ApplicationArea = All;
                }
                field(ShipToCounty; "Ship-To County")
                {
                    ApplicationArea = All;
                    ToolTip = 'Ship-to Country relates to the "Country" field in table "Countries".';
                }
                field(ShipToCity; "Ship-To City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Ship-to City relates to the "City" field in table "Ship-to Address", which is connected to the customer.';
                }
                field(ShipToCountryRegionCode; "Ship-To Country/Region Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(PlaceOrder)
            {
                ApplicationArea = All;
                Caption = 'Place Order';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Place Order';

                trigger OnAction()
                begin
                    PlacePVSOrder();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        WebLineRec.SetRange("Header No.", "No.");
        WebLineRec.SetRange("Cart Status", WebLineRec."cart status"::Added);
        if WebLineRec.FindSet() then
            repeat
                TotalOrderAmount += WebLineRec."Line Amount";
            until WebLineRec.Next() = 0;
    end;

    trigger OnInit()
    begin
        SetRange("No.", CustomerWeb2PVSFEMgt.RoleCenter_Get_BasketNo());
    end;

    var
        WebLineRec: Record "PVS Web2PVS Line";
        CustomerWeb2PVSFEMgt: Codeunit "PVS Web2PVS Customer FE Mgt";
        GlobalMessage: Text;
        TotalOrderAmount: Decimal;
        Text001: label 'Please confirm that you want to place this order.';

    local procedure PlacePVSOrder()
    begin
        if Confirm(Text001, false) then begin
            GlobalMessage := CustomerWeb2PVSFEMgt.RoleCenter_PlaceOrder();
            CurrPage.Close();
        end;
    end;

    procedure GetMessage(): Text
    begin
        exit(GlobalMessage);
    end;
}

