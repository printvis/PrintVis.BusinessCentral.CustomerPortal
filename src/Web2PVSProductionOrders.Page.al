Page 60980 "PVS Web2PVS Production Orders"
{
    Caption = 'Production Orders';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = "PVS Case";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(OrderNo; "Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = '- is drawn automatically from the Numberseries set up for your company, when status progresses to any Order or Production Order Statuscode.';
                }
                field(OrderDate; "Order Date")
                {
                    ApplicationArea = All;
                    ToolTip = '- Displays the date the Case reached Order or Production Order status.';
                }
                field(SellToName; "Sell-To Name")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    Lookup = false;
                    ToolTip = 'Customer Name.';
                }
                field(Archived; Archived)
                {
                    ApplicationArea = All;
                    ToolTip = '- When the Case reaches a status, where the setup on the Statuscode indicates a case is Archived, this field is set to ''yes/true''.';
                }
                field(Status; "External Status Description")
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    DrillDown = false;
                    Lookup = false;
                    ToolTip = 'Status is an automatic lookup in another table. The field is not editable. ';
                }
                field(JobName; "Job Name")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    Lookup = false;
                    ToolTip = 'The internal and external name of the job. The job name is for example written in the title line of the active windows.Generally, it is a good idea to assign an easily recognizable but meaningful job name to the case. The job name is automatically repeated for each job in the below table.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Job)
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
                              Status = filter(Order | "Production Order"),
                              Active = const(true);
                ToolTip = 'Job';
            }
            action(Shipments)
            {
                ApplicationArea = All;
                Caption = 'Shipment';
                Image = Shipment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "PVS Web2PVS Prod. Shipments";
                RunPageLink = ID = field(ID),
                              Shipped = const(true);
                ToolTip = 'Shipment';
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
        //SETRANGE(Type,Type::Order,Type::"Production Order"); RH
        SetRange("Sell-To No.", AccountRec."Customer No.");
        SetRange(Canceled, false);
        SetRange("Customer Job Tracking", true);
        FilterGroup(0);
    end;
}

