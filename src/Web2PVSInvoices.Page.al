Page 60954 "PVS Web2PVS Invoices"
{
    Caption = 'Sales Invoices';
    CardPageID = "PVS Web2PVS Sales Invoice";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Sales Invoice Header";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                Editable = false;
                field(No; "No.")
                {
                    ApplicationArea = All;
                }
                field(SelltoCustomerNo; "Sell-to Customer No.")
                {
                    ApplicationArea = All;
                }
                field(SelltoCustomerName; "Sell-to Customer Name")
                {
                    ApplicationArea = All;
                }
                field(CurrencyCode; "Currency Code")
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        SetRange("No.");
                        Page.RunModal(Page::"Posted Sales Invoice", Rec)
                    end;
                }
                field(AmountIncludingVAT; "Amount Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'A system generated "Entry No." for each ''''Web2PV Additional''';

                    trigger OnDrillDown()
                    begin
                        SetRange("No.");
                        Page.RunModal(Page::"Posted Sales Invoice", Rec)
                    end;
                }
                field(SelltoPostCode; "Sell-to Post Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(SelltoCountryRegionCode; "Sell-to Country/Region Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(SelltoContact; "Sell-to Contact")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(BilltoCustomerNo; "Bill-to Customer No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(BilltoName; "Bill-to Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(BilltoPostCode; "Bill-to Post Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(BilltoCountryRegionCode; "Bill-to Country/Region Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(BilltoContact; "Bill-to Contact")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(ShiptoCode; "Ship-to Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(ShiptoName; "Ship-to Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(ShiptoPostCode; "Ship-to Post Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(ShiptoCountryRegionCode; "Ship-to Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'A system generated "Entry No." for each ''''Web2PV Additional''';
                    Visible = false;
                }
                field(ShiptoContact; "Ship-to Contact")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(PostingDate; "Posting Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(SalespersonCode; "Salesperson Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(LocationCode; "Location Code")
                {
                    ApplicationArea = All;
                }
                field(DocumentDate; "Document Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(PaymentTermsCode; "Payment Terms Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(DueDate; "Due Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(PaymentDiscount; "Payment Discount %")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(ShipmentMethodCode; "Shipment Method Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(ShipmentDate; "Shipment Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Invoice)
            {
                Caption = 'Invoice';
                Image = Invoice;
                ToolTip = 'Invoice';
                action(Card)
                {
                    ApplicationArea = All;
                    Caption = 'Card';
                    Image = EditLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'Card';

                    trigger OnAction()
                    begin
                        Page.Run(Page::"Posted Sales Invoice", Rec)
                    end;
                }
            }
        }
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
                var
                    SalesInvHeader: Record "Sales Invoice Header";
                begin
                    CurrPage.SetSelectionFilter(SalesInvHeader);
                    SalesInvHeader.PrintRecords(false);
                end;
            }
            action(Email)
            {
                ApplicationArea = All;
                Caption = 'Email';
                Image = Email;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Email';

                trigger OnAction()
                var
                    SalesInvHeader: Record "Sales Invoice Header";
                begin
                    SalesInvHeader := Rec;
                    CurrPage.SetSelectionFilter(SalesInvHeader);
                    SalesInvHeader.EmailRecords(false);
                end;
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    begin
        Error(Text001);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        Error(Text002);
    end;

    trigger OnOpenPage()
    begin
        SetSecurityFilterOnRespCenter();
        FilterGroup(4);
        SetRange("Bill-to Customer No.", CustFrontEndMgt.Get_CustNoFromUserSetup());
        FilterGroup(0);
    end;

    var
        CustFrontEndMgt: Codeunit "PVS Customer Frontend Mgt";
        Text001: label 'Delete not allowed!';
        Text002: label 'Modify not allowed!';
}

