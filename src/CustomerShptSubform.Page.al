Page 60967 "PVS Customer Shpt. Subform"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    Editable = false;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "Sales Shipment Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        DoNothing();
                    end;
                }
                field(No; "No.")
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        DoNothing();
                    end;
                }
                field(VariantCode; "Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        DoNothing();
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        DoNothing();
                    end;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    BlankZero = true;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        DoNothing();
                    end;
                }
                field(UnitofMeasure; "Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        DoNothing();
                    end;
                }
                field(RequestedDeliveryDate; "Requested Delivery Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        DoNothing();
                    end;
                }
                field(PromisedDeliveryDate; "Promised Delivery Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        DoNothing();
                    end;
                }
                field(ShipmentDate; "Shipment Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Location Code relates to the "Code" field in table "Location".The Location Code can be selected from the Location table.';
                    Visible = true;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        DoNothing();
                    end;
                }
            }
        }
    }

    actions
    {
    }

    local procedure DoNothing()
    begin
    end;
}

