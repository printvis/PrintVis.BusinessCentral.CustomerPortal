Page 60982 "PVS Web2PVS Prod. Shipments"
{
    Caption = 'Shipment';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = "PVS Job Shipment";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(OrderNo; "Order No.")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    Lookup = false;
                }
                field(JobName; "Job Name")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    Lookup = false;
                }
                field(ShipmentDate; "Shipment Date")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    Lookup = false;
                    ToolTip = 'The field automatically fills in the present date as soon as the shipped quantity field is filled in, but you may also state another date in the field';
                }
                field(QtyToShip; "Qty. To Ship")
                {
                    ApplicationArea = All;
                    ToolTip = 'Insert the actual quantity packed and shipped (or ready for shipment), to have a record of the exact quantity actually shipped to the customer.';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Displays Delivery Name from the selected Address code  or it may be manually written (address type Manual)';
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Displays Delivery Address from the selected Address code  or it may be manually written (address type Manual)';
                }
                field(PostCode; "Post Code")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    Lookup = false;
                    ToolTip = 'Post Code relates to the Code field in table Post Code. The Post Code can be selected from the Post Code table.Displays Delivery Zip-/Post Code from the selected Address code  or it may be manually written, provided the code you write is created within the Post Code Table.';
                }
                field(City; City)
                {
                    ApplicationArea = All;
                    AssistEdit = false;
                    DrillDown = false;
                    Lookup = false;
                    ToolTip = 'Displays Delivery City from the selected Address code  or it may be filled in through selecting a Zip-/Post Code';
                }
                field(Contact; Contact)
                {
                    ApplicationArea = All;
                    AssistEdit = false;
                    DrillDown = false;
                    Lookup = false;
                    ToolTip = 'Displays Delivery Contact Person from the selected Address code  or it may be manually written.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Job Card")
            {
                ApplicationArea = All;
                Caption = 'Job';
                Image = Job;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "PVS Web2PVS Prod. Job Card";
                RunPageLink = ID = field(ID),
                              Job = field(Job),
                              "Order Calculation" = const(true),
                              Active = const(true);
                ToolTip = 'Job';
            }
        }
    }

    trigger OnInit()
    var
        FrontendSetupRec: Record "PVS Web2PVS Frontend Setup";
        AccountRec: Record "PVS Web2PVS Frontend Account";
        CustomerFEMgt: Codeunit "PVS Customer Frontend Mgt";
    begin
        // get the account and set filters
        CustomerFEMgt.Get_Account(AccountRec, FrontendSetupRec);
        AccountRec.TestField("Customer No.");

        FilterGroup(4); // hidden locked filters!
        SetRange("Customer No.", AccountRec."Customer No.");
        SetRange(Shipped, true);
        FilterGroup(0);
    end;
}

