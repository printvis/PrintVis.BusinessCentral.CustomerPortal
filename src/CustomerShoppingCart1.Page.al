Page 60963 "PVS Customer Shopping Cart 1"
{
    Caption = 'Shopping Cart';
    DataCaptionExpression = '';
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "PVS Web2PVS Line";

    layout
    {
        area(content)
        {
            repeater(Control1160230001)
            {
                field(No; "No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'blankG/L AccountItemCharge (Item)';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(UnitPrice; "Unit Price")
                {
                    ApplicationArea = All;
                    DecimalPlaces = 2 : 2;
                    Editable = false;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
                field(LineAmount; "Line Amount")
                {
                    ApplicationArea = All;
                    DecimalPlaces = 2 : 2;
                    Editable = false;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("ActionEmptyCart()")
            {
                ApplicationArea = All;
                Caption = 'Empty Cart';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Delete all items from the cart';
                Visible = OptionsVisible;

                trigger OnAction()
                begin
                    EmptyCart();
                end;
            }
            action("ActionNextStep()")
            {
                ApplicationArea = All;
                Caption = 'Continue to next step';
                Image = NextRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Continue to next step';
                Visible = OptionsVisible;

                trigger OnAction()
                begin
                    NextStep();
                end;
            }
        }
    }

    trigger OnInit()
    begin
        OptionsVisible := false;
    end;

    trigger OnOpenPage()
    begin
        FindRecs();
    end;

    var
        WebHeaderRec: Record "PVS Web2PVS Header";
        CustomerWeb2PVSFEMgt: Codeunit "PVS Web2PVS Customer FE Mgt";
        [InDataSet]
        OptionsVisible: Boolean;
        Text001: label 'Are you sure you want to empty the complete shopping cart?';

    procedure EmptyCart()
    begin
        if WebHeaderRec.Get("Header No.") then
            if Confirm(Text001, false) then begin
                WebHeaderRec.Delete(true);
                CurrPage.Close();
            end;
    end;

    procedure NextStep()
    var
        PageStep2: Page "PVS Customer Shopping Cart 2";
        MessageTxt: Text;
    begin
        //PAGE.RUNMODAL(PAGE::"PVS Customer Shopping Cart 2");
        PageStep2.RunModal();
        MessageTxt := PageStep2.GetMessage();
        if MessageTxt <> '' then
            Message(MessageTxt);

        FindRecs();

        CurrPage.Update(false);
    end;

    local procedure FindRecs()
    begin
        SetRange("Header No.", CustomerWeb2PVSFEMgt.RoleCenter_Get_BasketNo());
        SetRange("Cart Status", "cart status"::Added);
        if FindFirst() then
            OptionsVisible := true;
    end;
}

