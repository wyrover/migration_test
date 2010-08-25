 Unit EditUserDlg;
//------------------------------------------------------------------------------
{
   Title:       Edit User Dialog

   Description: Allows editing and set up for system users

   Author:      Matthew Hopkins

   Remarks:

}
//------------------------------------------------------------------------------

Interface

Uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
      SYDEFS, StdCtrls, ExtCtrls, ComCtrls, CheckLst,
      OsFont;

Type
   TdlgEditUser = Class (TForm)
    btnOK        : TButton;
    btnCancel    : TButton;
    pcMain: TPageControl;
    tsDetails: TTabSheet;
    stUserName: TLabel;
    eUserCode: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    eFullName: TEdit;
    Label3: TLabel;
    eMail: TEdit;
    ePass: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    eConfirmPass: TEdit;
    chkMaster: TCheckBox;
    pnlSpecial: TPanel;
    tsFiles: TTabSheet;
    Label6: TLabel;
    rbAllFiles: TRadioButton;
    rbSelectedFiles: TRadioButton;
    Label7: TLabel;
    pnlSelected: TPanel;
    lvFiles: TListView;
    btnAdd: TButton;
    btnRemove: TButton;
    btnRemoveAll: TButton;
    Label8: TLabel;
    cmbUserType: TComboBox;
    lblUserType: TLabel;
    Label9: TLabel;
    eDirectDial: TEdit;
    chkLoggedIn: TCheckBox;
    Label20: TLabel;
    CBPrintDialogOption: TCheckBox;
    CBSuppressHeaderFooter: TCheckBox;
    chkShowPracticeLogo: TCheckBox;

    Procedure btnCancelClick(Sender: TObject);
    Procedure btnOKClick(Sender: TObject);
    Procedure chkLoggedInClick(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    Procedure FormShow(Sender: TObject);
    procedure btnRemoveAllClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure rbAllFilesClick(Sender: TObject);
    procedure rbSelectedFilesClick(Sender: TObject);
    procedure cmbUserTypeSelect(Sender: TObject);
   Private
      { Private declarations }
      okPressed  : boolean;
      formLoaded : boolean;
      EditChk    : boolean;
      Function OKtoPost : boolean;
      Procedure UpdateAdminFileAccessList( UserLRN : integer);
   Public
      { Public declarations }
      Function Execute(User: pUser_Rec) : boolean;
   End;

Function EditUser(User_Code: String) : boolean;

Function AddUser : boolean;

//******************************************************************************
implementation

uses
  Admin32,
  bkconst,
  BKHelp,
  bkXPThemes,
  ClientLookUpExFrm,
  ErrorMoreFrm,
  Globals,
  ImagesFrm,
  LogUtil,
  SyUSIO,
  WarningMoreFrm,
  YesNoDlg;

{$R *.DFM}

//------------------------------------------------------------------------------
procedure TdlgEditUser.FormCreate(Sender: TObject);
var
  i : Integer;
begin
  bkXPThemes.ThemeForm( Self);

  formLoaded := false;
  SetUpHelp;
  pcMain.ActivePage := tsDetails;

  SetpasswordFont(ePass);
  SetpasswordFont(eConfirmPass);

  with cmbUserType do
  begin
    Clear;
    for i := ustmin to ustMax do
      Items.Add(ustNames[i]);
  end;
End;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditUser.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   eUserCode.Hint      :=
                       'Enter a User Code for logging in to '+SHORTAPPNAME+'|' +
                       'Enter a User Code for logging in to '+SHORTAPPNAME;
   eFullName.Hint      :=
                       'Enter the user''s full name|' +
                       'Enter the user''s full name';
   eMail.Hint          :=
                       'Enter the user''s E-mail address|' +
                       'Enter the user''s E-mail address';
   ePass.Hint          :=
                       'Enter a login password|' +
                       'Enter a password that this User must use when logging in. (Required if user has Administrator rights)';
   eConfirmPass.Hint   :=
                       'Confirm the password entered above|' +
                       'Re-enter the password above to confirm it is correct';
   chkMaster.Hint      :=
                       'Check to allow user to memorise transactions at master level|' +
                       'Check to allow user to memorise transactions at master level';
   //chkSystem.Hint      :=
   //                    'Check to give the user Administrator rights|' +
   //                    'Check to give the user Administrator rights';

   cmbUserType.Hint    :=
                       'Select users access rights|' +
                       'Select users access rights';

   chkLoggedIn.hint    :=
                       'Check to alter the user''s login status|' +
                       'Uncheck to reset the user''s status if the user has crashed out of the program';

   CBPrintDialogOption.Hint :=
                        'Always show printer options before printing|' +
                        'Always show printer options before printing';

   CBSuppressHeaderFooter.Hint := 'Check to Hide Headers and Footers on Reports for this User';

   chkShowPracticeLogo.Hint := 'Display the practice logo when this user is logged in';

end;
//------------------------------------------------------------------------------
Procedure TdlgEditUser.FormShow(Sender: TObject);
begin { TdlgEditUser.FormShow }
   formLoaded := true;
End; { TdlgEditUser.FormShow }
//------------------------------------------------------------------------------
Procedure TdlgEditUser.btnCancelClick(Sender: TObject);
begin { TdlgEditUser.btnCancelClick }
   okPressed := false;
   Close;
End; { TdlgEditUser.btnCancelClick }
//------------------------------------------------------------------------------
Procedure TdlgEditUser.btnOKClick(Sender: TObject);
begin { TdlgEditUser.btnOKClick }
   If OKtoPost Then begin
      okPressed := true;
      Close;
   End { OKtoPost };
End; { TdlgEditUser.btnOKClick }
//------------------------------------------------------------------------------
Function TdlgEditUser.OKtoPost : boolean;
Var
   URec : pUser_Rec;
begin { TdlgEditUser.OKtoPost }
   Result := false;

   If eUserCode.visible Then begin
      If (Trim(eUserCode.text) = '') Then begin
         HelpfulWarningMsg('You must enter a user code.', 0);
         pcMain.ActivePage := tsDetails;
         eUserCode.SetFocus;
         exit;
      End { (Trim(eUserCode.text) = '') };

      {check for duplicate login name}
      URec := AdminSystem.fdSystem_User_List.FindCode(eUserCode.text);
      If Assigned(URec) or (eUserCode.text = SUPERUSER) Then
      begin
         HelpfulWarningMsg( Format( 'The user code "%s" already exists.  Please use a different code.', [ eUserCode.Text ] ), 0 );
         pcMain.ActivePage := tsDetails;
         eUserCode.SetFocus;
         exit;
      End { Assigned(URec) or (eUserCode.text = SUPERUSER) };
   End { eUserCode.visible };

   case cmbUserType.ItemIndex of
     ustRestricted :
       begin
         if (rbSelectedFiles.Checked) and (lvFiles.Items.Count = 0) then
         begin
           HelpfulWarningMsg('Users with Restricted Access MUST be allowed to access at least one file.', 0);
           pcMain.ActivePage := tsFiles;
           btnAdd.SetFocus;
           Exit;
         end;
       end;
     ustNormal :
       begin
         if (rbSelectedFiles.Checked) and (lvFiles.Items.Count = 0) then
         begin
           HelpfulWarningMsg('Users with Normal Access MUST be allowed to access at least one file.', 0);
           pcMain.ActivePage := tsFiles;
           btnAdd.SetFocus;
           Exit;
         end;
       end;
     ustSystem :
       begin
         if (ePass.Text = '') then
         begin
            HelpfulWarningMsg('Users with System Menu Access MUST have a password.', 0);
            pcMain.ActivePage := tsDetails;
            ePass.SetFocus;
            exit;
         end;
       end;
   end;

   if not (ePass.text = eConfirmPass.text) Then begin
      HelpfulWarningMsg('The passwords you have entered do not match. Please re-enter them.', 0);
      pcMain.ActivePage := tsDetails;
      ePass.SetFocus;
      exit;
   end { not (ePass.text = eConfirmPass.text) };
   Result := true;
End; { TdlgEditUser.OKtoPost }
//------------------------------------------------------------------------------
Procedure TdlgEditUser.chkLoggedInClick(Sender: TObject);
begin { TdlgEditUser.chkLoggedInClick }
   If formLoaded Then begin
      If EditChk Then begin
         exit
      End; {already editing}
      If AskYesNo('Reset User Status', 'This will reset the User''s login status and reset the Client File '
         + 'open status for any files the user had open.  You should only do this '
         + 'if the user has been unexpectedly disconnected from ' + SHORTAPPNAME+'.'
         + #13 + #13 + 'Please confirm you want to do this.', DLG_NO, 0) <>
         DLG_YES Then begin
         EditChk := true;
         chkLoggedIn.Checked := not chkLoggedIn.Checked;
         EditChk := false;
      End
         { AskYesNo('Reset User Status', 'This will reset the Users login status and reset the Client File '  };
   End { formLoaded };
End; { TdlgEditUser.chkLoggedInClick }

//------------------------------------------------------------------------------
Procedure TdlgEditUser.UpdateAdminFileAccessList( UserLRN : integer);
var
   CLRN : integer;
   i    : integer;
begin
   //Clear out the existing information, this will allow access to all files
   AdminSystem.fdSystem_File_Access_List.Delete_User( UserLRN );

   //set access if selected files checked
   if rbSelectedFiles.Checked then begin
     if lvFiles.Items.Count = 0 then begin
        //create a dummy client LRN so that file access will be denied
        AdminSystem.fdSystem_File_Access_List.Insert_Access_Rec( UserLRN, 0 )
     end
     else begin
        for i := 0 to Pred( lvFiles.Items.Count ) do begin
           CLRN := Integer( lvFiles.Items[ i].SubItems.Objects[ 0]);
           AdminSystem.fdSystem_File_Access_List.Insert_Access_Rec( UserLRN, CLRN );
        end;
     end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function TdlgEditUser.Execute( User: pUser_Rec ) : boolean;
Var
  i : Integer;
  NewLVItem : TListItem;
begin { TdlgEditUser.Execute }
  lvFiles.Items.Clear;

  if Assigned(User) then
  begin
    //user type
    if (User.usSystem_Access) then
      cmbUserType.ItemIndex := ustSystem
    else if (User.usIs_Remote_User) then
      cmbUserType.ItemIndex := ustRestricted
    else
      cmbUserType.ItemIndex := ustNormal;
    cmbUserTypeSelect(cmbUserType);

    //see if user is restricted
    if AdminSystem.fdSystem_File_Access_List.Restricted_User( User^.usLRN) then begin
       rbSelectedFiles.Checked := true;

       //load selected files into list view
       lvFiles.Items.BeginUpdate;
       try
          With AdminSystem.fdSystem_Client_File_List do begin
             For i := 0 to Pred( ItemCount ) do With AdminSystem.fdSystem_Client_File_List.Client_File_At( i )^ do
             begin
                If AdminSystem.fdSystem_File_Access_List.Allow_Access( User^.usLRN, cfLRN ) then begin
                  NewLVItem := lvFiles.Items.Add;
                  NewLVItem.caption := cfFile_Code;
                  NewLVItem.SubItems.AddObject( cfFile_Name, Pointer( cfLRN ));
                  NewLVItem.ImageIndex := 0;
                end;
             end;
          end;
       finally
          lvFiles.Items.EndUpdate;
       end;
    end
    else
       rbAllFiles.Checked := true;

    eUserCode.Visible  := false;
    stUserName.Caption := User.usCode;
    eFullName.Text     := User.usName;
    eMail.Text         := User.usEMail_Address;
    eDirectDial.Text   := User.usDirect_Dial;
    ePass.Text         := User.usPassword;
    eConfirmPass.Text  := User.usPassword;
    chkLoggedIn.Checked := User.usLogged_In;
    cbPrintDialogOption.Checked := User.usShow_Printer_Choice;
    cbSuppressHeaderFooter.Checked := (User.usSuppress_HF = shfChecked);
    chkShowPracticeLogo.Checked := User.usShow_Practice_Logo;

    if User.usWorkstation_Logged_In_At <> '' then
      chkLoggedIn.Caption := 'User is &Logged In  (on ' + User.usWorkstation_Logged_In_At +')';
    chkMaster.Checked     := User.usMASTER_Access;
  end { Assigned(User) }
  else
  begin
    {new user}
    stUserName.visible := false;
    eUserCode.text := '';
    eFullName.text := '';
    eMail.text := '';
    ePass.text := '';
    eDirectDial.Text := '';
    eConfirmPass.text := '';
    cmbUserType.ItemIndex := ustNormal;
    cmbUserTypeSelect(cmbUserType);
    chkLoggedIn.Checked := false;
    chkLoggedIn.Enabled := false;
    chkMaster.Checked := false;
    cbPrintDialogOption.Checked := false;
    cbSuppressHeaderFooter.Checked := false;
    rbAllFiles.Checked := true;
  end { not (Assigned(User)) };

  pnlSelected.Visible := rbSelectedFiles.Checked;
  rbAllFiles.Enabled := (cmbUserType.ItemIndex <> ustRestricted);

  EditChk := false;
  ShowModal;
  Result := okPressed;
End; { TdlgEditUser.Execute }

//------------------------------------------------------------------------------

Function EditUser(User_Code: String) : boolean;
const
   ThisMethodName = 'EditUser';
Var
  MyDlg       : TdlgEditUser;
  eUser       : pUser_Rec;
  StoredLRN   : Integer;
  StoredName  : string;
  YN          : string;
  pu          : pUser_Rec;
  WasLoggedIn : boolean;
  i           : integer;
begin { EditUser }
  Result := false;

  eUser := AdminSystem.fdSystem_User_List.FindCode(User_Code);

  If not (Assigned(AdminSystem) and Assigned(eUser)) Then begin
     exit
  End;

  MyDlg := TdlgEditUser.Create(Application);
  Try
    BKHelpSetUp(MyDlg, BKH_Adding_and_maintaining_users);
    if Assigned(CurrUser) Then begin
      if (CurrUser.LRN = eUser.usLRN) or (not eUser.usLogged_In) then
      begin
        MyDlg.chkLoggedIn.Enabled    := false;
        MyDlg.cmbUserType.ItemIndex := ustNormal;
      end; { CurrUser.LRN = eUser.usLRN }
    end;
    WasLoggedIn := eUser^.usLogged_In;

    If MyDlg.Execute(eUser) Then begin
      //get the user_rec again as the admin system may have changed in the mean time.
      eUser := AdminSystem.fdSystem_User_List.FindCode(User_Code);
      With MyDlg Do begin
        StoredLRN := eUser.usLRN; {user pointer about to be destroyed}
        StoredName := eUser.usCode;

        If LoadAdminSystem(true, ThisMethodName ) Then begin
          pu := AdminSystem.fdSystem_User_List.FindLRN(StoredLRN);
          If not Assigned(pu) Then begin
             UnlockAdmin;
             HelpfulErrorMsg('The User ' + StoredName + ' can no longer be found in the Admin System.', 0);
             exit;
          End;

          pu.usName           := eFullName.text;
          pu.usPassword       := ePass.text;
          pu.usEMail_Address  := Trim( eMail.text);
          pu.usDirect_Dial    := eDirectDial.Text;
          pu.usShow_Printer_Choice := cbPrintDialogOption.Checked;
          if CBSuppressHeaderFooter.Checked then
            pu.usSuppress_HF := shfChecked
          else pu.usSuppress_HF := shfUnChecked;

          pu.usShow_Practice_Logo := chkShowPracticeLogo.Checked;

          case cmbUserType.ItemIndex of
            ustRestricted :
              begin
                pu.usSystem_Access  := False;
                pu.usIs_Remote_User := True;
              end;
            ustSystem :
              begin
                pu.usSystem_Access  := True;
                pu.usIs_Remote_User := False;
              end;
            ustNormal :
              begin
                pu.usSystem_Access  := False;
                pu.usIs_Remote_User := False;
              end;
          else
            pu.usSystem_Access  := False;
            pu.usIs_Remote_User := False;
          end;
          pu.usMASTER_Access  := chkMaster.Checked;

          If pu.usLogged_In <> chkLoggedIn.Checked Then begin
             If chkLoggedIn.Checked Then begin
                YN := 'YES'
             End
             Else begin
                YN := 'NO'
             End;
             LogUtil.LogMsg(lmInfo, 'EDITUSERDLG', 'User '+StoredName+' Logged In reset to '
                + YN);
             pu.usLogged_In := chkLoggedIn.Checked;

             //have changed to not logged in ( logged out). ie reset user status, so now reset any open files
             If (not (chkLoggedIn.Checked) and WasLoggedIn) Then begin
                //clear the workstation identifier
                pu.usWorkstation_Logged_In_At := '';
                With AdminSystem.fdSystem_Client_File_List Do begin
                   For i := 0 to Pred(ItemCount) Do begin
                      With Client_File_At(i)^ Do begin
                         If (cfFile_Status = fsOpen) and (cfCurrent_User = pu^.usLRN) Then begin
                            //reset the file status for files that this user may have open
                            cfFile_Status := fsNormal;
                            cfCurrent_User := 0;
                         End
                      End
                   End
                End
             End;
          End;

          UpdateAdminFileAccessList( pu^.usLRN);

          SaveAdminSystem;
          Result := true;

          If Assigned(CurrUser) Then begin
             If CurrUser.LRN = pu.usLRN Then begin
                CurrUser.CanMemoriseToMaster := pu.usMASTER_Access;
                CurrUser.FullName := pu.usName;
                CurrUser.ShowPrinterDialog := pu.usShow_Printer_Choice;
             End { CurrUser.LRN = pu.usLRN }
          End;
        End { LoadAdminSystem(true) }
        Else begin
           HelpfulErrorMsg('Could not update User Details at this time. Admin System unavailable.', 0)
        End;
      End { with MyDlg }
    End;
  Finally
     MyDlg.Free;
  End { try };
End; { EditUser }
//------------------------------------------------------------------------------
Function AddUser : boolean;
const
   ThisMethodName = 'AddUser';
Var
   MyDlg : TdlgEditUser;
   pu    : pUser_Rec;
begin { AddUser }
   Result := false;
   If not Assigned(AdminSystem) Then begin
      exit
   End;

   MyDlg := TdlgEditUser.Create(Application);
   Try
      BKHelpSetUp(MyDlg, BKH_Adding_and_maintaining_users);
      If MyDlg.Execute(Nil) Then begin
         With MyDlg Do begin
            If LoadAdminSystem(true, ThisMethodName ) Then begin
               pu := New_User_Rec;

               if not Assigned(pu) Then begin
                  UnlockAdmin;
                  HelpfulErrorMsg('New User cannot be created', 0);
                  exit;
               end { not Assigned(pu) };

               Inc(AdminSystem.fdFields.fdUser_LRN_Counter);
               pu.usCode           := eUserCode.text;
               pu.usName           := eFullName.text;
               pu.usPassword       := ePass.text;
               pu.usEMail_Address  := Trim( eMail.text);
               pu.usDirect_Dial    := eDirectDial.Text;
               pu.usShow_Printer_Choice := cbPrintDialogOption.Checked;
               if CBSuppressHeaderFooter.Checked then
                 pu.usSuppress_HF := shfChecked
               else pu.usSuppress_HF := shfUnChecked;

               pu.usShow_Practice_Logo := chkShowPracticeLogo.Checked;

               case cmbUserType.ItemIndex of
                 ustRestricted :
                   begin
                     pu.usSystem_Access  := False;
                     pu.usIs_Remote_User := True;
                   end;
                 ustSystem :
                   begin
                     pu.usSystem_Access  := True;
                     pu.usIs_Remote_User := False;
                   end;
                 ustNormal :
                   begin
                     pu.usSystem_Access  := False;
                     pu.usIs_Remote_User := False;
                   end;
               else
                 pu.usSystem_Access  := False;
                 pu.usIs_Remote_User := False;
               end;
               pu.usMASTER_Access  := chkMaster.Checked;
               pu.usLogged_In      := false;
               pu.usLRN            := AdminSystem.fdFields.fdUser_LRN_Counter;

               AdminSystem.fdSystem_User_List.Insert( pu );

               UpdateAdminFileAccessList( pu^.usLRN);

               SaveAdminSystem;
               Result := true;
            End { LoadAdminSystem(true) }
            Else begin
               HelpfulErrorMsg('Could not update User Details at this time. Admin System unavailable.', 0)
            End;
         End { with MyDlg }
      End;
   Finally
      MyDlg.Free;
   End { try };
End; { AddUser }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditUser.btnRemoveAllClick(Sender: TObject);
begin
  lvFiles.Items.Clear;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditUser.btnAddClick(Sender: TObject);
Var
  Codes  : TStringList;
  pCF    : pClient_File_Rec;
  Found  : Boolean;
  i, j   : Integer;
  NewLVItem : TListItem;
begin
  Codes := TStringList.Create;
  try
    Codes.Delimiter := ClientCodeDelimiter;
    Codes.StrictDelimiter := True;
    //ask the user for a list of codes, will reload admin system
    Codes.DelimitedText := LookupClientCodes( 'Select Files', '', [ coHideStatusColumn, coHideViewButtons, coAllowMultiSelected, coShowAssignedToColumn], 'Add');

    for i := 0 to Codes.Count - 1 do
    begin
      pCF := AdminSystem.fdSystem_Client_File_List.FindCode( Codes[i] );
      if Assigned( pCF ) then
      begin
        Found := False;
        //check that is not already in the list
        for j := 0 to Pred( lvFiles.Items.Count ) do
          If Integer( lvFiles.Items[ j].SubItems.Objects[ 0]) = pCF.cfLRN then
            Found := True;

        if not Found then begin
           NewLVItem := lvFiles.Items.Add;
           NewLVItem.caption := pCF^.cfFile_Code;
           NewLVItem.SubItems.AddObject( pCF^.cfFile_Name, Pointer( pCF^.cfLRN ));
           NewLVItem.ImageIndex := 0;
        end;
      end;
    end;
  finally
    Codes.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditUser.btnRemoveClick(Sender: TObject);
Var i : Integer;
begin
  If lvFiles.SelCount > 0 then
  begin
    For i := Pred( lvFiles.Items.Count ) downto 0 do
    begin
      If lvFiles.Items[ i].Selected then
         lvFiles.Items[ i].Delete;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditUser.rbAllFilesClick(Sender: TObject);
begin
   pnlSelected.Visible := rbSelectedFiles.Checked;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditUser.rbSelectedFilesClick(Sender: TObject);
begin
   pnlSelected.Visible := rbSelectedFiles.Checked;

end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// cmbUserTypeSelect
//
// Triggered when the User Type combobox is changed. The caption next to the
// combobox is updated and the various controls on the form are set.
//
procedure TdlgEditUser.cmbUserTypeSelect(Sender: TObject);
begin
  case TComboBox(Sender).ItemIndex of
    ustRestricted :
      begin
        lblUserType.Caption := 'Limited functionality : Access to selected files only';
        chkMaster.Checked := False;
        chkMaster.Enabled := False;
        rbAllFiles.Checked := False;
        rbAllFiles.Enabled := False;
        rbSelectedFiles.Checked := True;
        rbSelectedFiles.Enabled := True;
        chkShowPracticeLogo.Enabled := True;
      end;
    ustNormal :
      begin
        lblUserType.Caption := 'Standard functionality : Access to all or selected files';
        chkMaster.Enabled := True;
        rbAllFiles.Checked := True;
        rbAllFiles.Enabled := True;
        rbSelectedFiles.Checked := False;
        rbSelectedFiles.Enabled := True;
        chkShowPracticeLogo.Enabled := False;
        chkShowPracticeLogo.Checked := False;
      end;
    ustSystem :
      begin
        lblUserType.Caption := 'Administrator rights : Access to all files';
        chkMaster.Enabled := True;
        rbAllFiles.Checked := True;
        rbAllFiles.Enabled := True;
        rbSelectedFiles.Checked := False;
        rbSelectedFiles.Enabled := False;
        chkShowPracticeLogo.Enabled := False;
        chkShowPracticeLogo.Checked := False;
      end;
  else
    lblUserType.Caption := '';
  end;
end;

End.
