Page 60968 "PVS Customer Welcome"
{
    Caption = 'Customer Welcome';
    Editable = false;
    LinksAllowed = false;
    PageType = CardPart;
    ShowFilter = false;

    layout
    {
        area(content)
        {
            usercontrol(HtmlView; "PVS HtmlViewController")
            {
                ApplicationArea = All;

                trigger ControlAddInReady()
                var
                    JSCode: Text;
                begin
                    JSCode := '$("#controlAddIn").css("border","none");';
                    JSCode += '$("#controlAddIn").css("overflow","hidden");';
                    JSCode += '$("#controlAddIn").css("padding","0px");';
                    JSCode += '$("#controlAddIn").empty();';
                    CurrPage.HtmlView.ExecuteJS(JSCode);

                    JSCode := '$(".control-addin-container", window.top.document).css("height","100%");';
                    JSCode += '$("iframe", window.top.document).css("height","100%");';
                    JSCode += '$("iframe", window.top.document).css("max-height","");';
                    CurrPage.HtmlView.ExecuteJS(JSCode);

                    CurrPage.HtmlView.GetSize('');
                end;

                trigger OnGetSize(width: Integer; height: Integer)
                begin
                    InitPage(width, height);
                end;
            }
        }
    }

    actions
    {
    }

    var
        Web2PVSCustFEMgt: Codeunit "PVS Web2PVS Customer FE Mgt";

    procedure InitPage(inWidth: Integer; inHeight: Integer)
    begin
        CurrPage.HtmlView.ExecuteJS(Web2PVSCustFEMgt.JSAddin_GetSplashImage());
    end;
}

