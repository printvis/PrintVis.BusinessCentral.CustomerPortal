Page 60059 "PVS Customer Role Center"
{
    Caption = 'Customer Frontend';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            part(Control1160230001; "PVS Customer Welcome")
            {
                ApplicationArea = All;
                Caption = 'Role Center';
            }
        }
    }

    actions
    {
        area(embedding)
        {
            action(ProductCatalog)
            {
                ApplicationArea = All;
                Caption = 'Product Catalog';
                RunObject = Page "PVS Customer Product Catalog";
                ToolTip = 'Product Catalog';
            }
            action("Production Orders")
            {
                ApplicationArea = All;
                Caption = 'Production Orders';
                Image = Production;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "PVS Web2PVS Production Orders";
                ToolTip = 'Production Orders';
            }
            action("Production Shipments")
            {
                ApplicationArea = All;
                Caption = 'Production Shipments';
                Image = Shipment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "PVS Web2PVS Prod. Shipments";
                ToolTip = 'Production Shipments';
            }
            action("Other Shipments")
            {
                ApplicationArea = All;
                Caption = 'Other Shipments';
                RunObject = Page "PVS Customer Shipments";
                ToolTip = 'Other Shipments';
            }
            action(Invoices)
            {
                ApplicationArea = All;
                Caption = 'Invoices';
                RunObject = Page "PVS Web2PVS Invoices";
                RunPageMode = View;
                ToolTip = 'Invoices';
            }
        }
    }
}

