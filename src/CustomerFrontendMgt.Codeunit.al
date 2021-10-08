Codeunit 60055 "PVS Customer Frontend Mgt"
{

    trigger OnRun()
    begin
    end;

    var
        UserSetupRec: Record "PVS User Setup";
        SingleInstance: Codeunit "PVS SingleInstance";
        Web2PVSCustFEMgt: Codeunit "PVS Web2PVS Customer FE Mgt";
        Text001: label 'No Frontend Setup found for User %1';
        Text002: label 'No PrintVis User Setup found for User %1';

    procedure RoleCenter_OnLogin()
    begin
        if not Get_UserSetup() then
            Error(Text002, UserId());

        OnLogin_Web2PVS();
    end;

    procedure OnLogin_Web2PVS()
    var
        Web2PVSFESetupRec: Record "PVS Web2PVS Frontend Setup";
        Web2PVSFEAccountRec: Record "PVS Web2PVS Frontend Account";
        UserPersonalizationRec: Record "User Personalization";
    begin
        if not Get_Account(Web2PVSFEAccountRec, Web2PVSFESetupRec) then
            exit;

        Web2PVSFEAccountRec.CalcFields("User Security ID");

        if Web2PVSFESetupRec."Web Client FE Profile ID" <> '' then
            if UserPersonalizationRec.Get(Web2PVSFEAccountRec."User Security ID") then begin
                if UserPersonalizationRec."Profile ID" <> Web2PVSFESetupRec."Web Client FE Profile ID" then begin
                    UserPersonalizationRec."Profile ID" := Web2PVSFESetupRec."Web Client FE Profile ID";
                    UserPersonalizationRec.Modify();
                end;
            end else begin
                UserPersonalizationRec.Init();
                UserPersonalizationRec."User SID" := Web2PVSFEAccountRec."User Security ID";
                UserPersonalizationRec."Profile ID" := Web2PVSFESetupRec."Web Client FE Profile ID";

                UserPersonalizationRec.Company := COMPANYNAME();
                if not UserPersonalizationRec.Insert() then
                    UserPersonalizationRec.Modify();
            end;

        Web2PVSCustFEMgt.RoleCenter_BuildSessionIndex(Web2PVSFEAccountRec);
    end;

    procedure Get_Account(var out_Web2PVSFEAccountRec: Record "PVS Web2PVS Frontend Account"; var out_Web2PVSFESetupRec: Record "PVS Web2PVS Frontend Setup"): Boolean
    var
        Web2PVSFEAccountCheckRec: Record "PVS Web2PVS Frontend Account";
    begin
        if not Get_UserSetup() then
            exit;

        Web2PVSFEAccountCheckRec.SetRange("Login ID", UserSetupRec."User ID");
        if not Web2PVSFEAccountCheckRec.FindSet() then
            exit(false);

        if Web2PVSFEAccountCheckRec.Count() > 1 then begin
            repeat
                if out_Web2PVSFESetupRec.Get(Web2PVSFEAccountCheckRec."Frontend ID") and out_Web2PVSFESetupRec."Web Client FE" then begin
                    out_Web2PVSFEAccountRec := Web2PVSFEAccountCheckRec;
                    if Web2PVSFEAccountCheckRec.FindLast() then;
                end;
            until Web2PVSFEAccountCheckRec.Next() = 0;
            if out_Web2PVSFEAccountRec."Login ID" = '' then
                Error(Text001, out_Web2PVSFEAccountRec."Login ID");
        end else begin
            if (not out_Web2PVSFESetupRec.Get(Web2PVSFEAccountCheckRec."Frontend ID")) or (not out_Web2PVSFESetupRec."Web Client FE") then
                Error(Text001, Web2PVSFEAccountCheckRec."Login ID");
            out_Web2PVSFEAccountRec := Web2PVSFEAccountCheckRec;
        end;
        exit(true);
    end;

    procedure Get_UserSetup(): Boolean
    begin
        if not SingleInstance.Get_UserSetupRec(UserSetupRec) then
            exit(false);

        if not (UserSetupRec."User Type" in [UserSetupRec."user type"::Customer, UserSetupRec."user type"::"Remote Salesman"]) then
            UserSetupRec.TestField("User Type", UserSetupRec."user type"::Customer);
        exit(true);
    end;

    procedure Get_CustNoFromUserSetup(): Code[20]
    begin
        if not Get_UserSetup() then
            exit('')
        else
            exit(UserSetupRec."Link No.");
    end;

    procedure ResizeAndBase64_Picture(var in_TempBlobRec: Record "PVS TempBlob"; var in_Width: Integer; var in_Height: Integer) dataUri: Text
    var
        PVSImageManagement: Codeunit "PVS Image Management";
        TempBlob: Codeunit "Temp Blob";
    begin
        TempBlob.FromRecord(in_TempBlobRec, in_TempBlobRec.FieldNo("Blob"));
        dataUri := PVSImageManagement.ScaleDownBlobGetHTMLImgSrc(TempBlob, In_Width, In_Height);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::LogInManagement, 'OnAfterCompanyOpen', '', false, false)]
    procedure OnAfterCompanyOpen();
    var
        CustomerFEAPI: Codeunit "PVS Customer Frontend Mgt";
    begin
        case UserSetupRec."User Type" of
            UserSetupRec."user type"::Customer,
            UserSetupRec."user type"::"Remote Salesman":
                begin
                    CustomerFEAPI.RoleCenter_OnLogin();
                    exit;
                end;
        end;
    end;


}

