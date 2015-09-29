unit PromoDisplayForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PromoWindowObj, PromoContentFme, StdCtrls, Buttons, ExtCtrls,
  dxGDIPlusClasses, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdHTTP, OSFont, ImgList, Contnrs, PageNavigation;

type
  {This is the main promo screen where all content types will be displayed.
  Each content type is a frame will be added on the fly based on the content type selected
  or the time of firing}
  TPromoDisplayFrm = class(TForm)
    pnlControls: TPanel;
    ShapeBotBorder: TShape;
    btnClose: TBitBtn;
    cbHidePromo: TCheckBox;
    PageImages: TImageList;
    pnlFrames: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    PurpleImageIndex : Integer;
    {Each fram added to the form will be saved in this list so that it can be freed later}
    FrameList : TObjectList;
    {Page navigation component which has left arrow, right arrow and circle images
    equal to the no of pages. This is visible only if the no of pages > 1.}
    PageNavigation : TPageNavigation;
    {}
    procedure ImageClick(Sender: TObject);
    procedure OnArrowMove(Sender:TObject;Shift: TShiftState;X,Y: Integer);
    procedure OnArrowLeave(Sender : TObject);

    procedure lblRightArrowMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lblLeftArrowMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lblRightArrowMouseLeave(Sender: TObject);
    procedure lblLeftArrowMouseLeave(Sender: TObject);

    procedure lblRightArrowClick(Sender: TObject);
    procedure lblLeftArrowClick(Sender: TObject);
    procedure PageImageClick(Sender: TObject);
    { Private declarations }
    function CalculatePagesRequired: Integer;
    procedure DisplayPage(aPageIndex : Integer);
    procedure CopyImage(aMoveImg1,aMoveImg2 : TImage);
    procedure OnURLMouseEnter(Sender : TObject);
    procedure OnURLMouseLeave(Sender : TObject);
    procedure OnURLClick(Sender : TObject);
    procedure FreeAllExistingFrames;
  public
    { Public declarations }
  end;


var
  PromoDisplayFrm: TPromoDisplayFrm;

implementation

uses ipshttps, ShellApi, Globals, math;

{$R *.dfm}


procedure TPromoDisplayFrm.btnCloseClick(Sender: TObject);
begin
  //UserINI_Show_Promo_Window := (not cbHidePromo.Checked);
  ShowedPromoWindow := True;
  Close;
end;

function TPromoDisplayFrm.CalculatePagesRequired: Integer;
var
  i, FrameHeight : Integer;
  Content : TContentfulObj;
  TotalHeight : Integer;
  PageIndex : Integer;
  NewFrame: TPromoContentFrame;
  Bitmap : TBitmap;
  NoOfPagesRequired : Integer;
  t : TObjectList;
begin
  TotalHeight := 0;
  Result := 1;
  t := TObjectList.Create;
  for i := 0 to DisplayPromoContents.Count - 1  do
  begin
    Content := TContentfulObj(DisplayPromoContents.Item[i]);
    FrameHeight := 0;
    if Assigned(Content) then
    begin
      NewFrame := TPromoContentFrame.Create(Self);
      try
        NewFrame.Parent := pnlFrames;
        NewFrame.ParentFont := True;
        NewFrame.ParentColor := True;
        NewFrame.TabOrder := i;

        NewFrame.lblTitle.Font.Color := HyperLinkColor;
        NewFrame.lblTitle.Font.Size := 14;
        NewFrame.lblTitle.Font.Style := [fsBold];
        NewFrame.lblTitle.Caption := Trim(Content.Title);

        NewFrame.reDescription.Clear;
        NewFrame.lblDescResize.Caption := Trim(Content.Description);

        NewFrame.reDescription.Lines.Add(Trim(Content.Description));
        NewFrame.reDescription.Height := NewFrame.lblDescResize.Height ;
        NewFrame.lblDescResize.Visible := False;

        NewFrame.lblURL.Font.Color := HyperLinkColor;
        NewFrame.lblURL.Caption := Content.URL;

        NewFrame.imgContainer.Visible := Content.IsImageAvilable;
        NewFrame.lblURL.Visible := (Trim(Content.URL) <> '');

        FrameHeight := FrameHeight + NewFrame.lblTitle.Height;
        FrameHeight := FrameHeight + NewFrame.reDescription.Height;
        if NewFrame.lblURL.Visible then        
          FrameHeight := FrameHeight + NewFrame.lblURL.Height;
        if NewFrame.imgContainer.Visible then
          FrameHeight := FrameHeight + NewFrame.imgContainer.Height;

        TotalHeight := TotalHeight + NewFrame.ClientHeight;
        Content.FrameHeightRequired := NewFrame.ClientHeight;
      finally
        FreeAndNil(NewFrame);
      end;
    end;
  end;
  if DisplayPromoContents.PromoMainWindowHeight <> 0 then
    Result := Ceil(TotalHeight/DisplayPromoContents.PromoMainWindowHeight);
  DisplayPromoContents.NoOfPagesRequired := Result;
  PageIndex := 1;
  TotalHeight := 0;
  DisplayPromoContents.SortContentfulData;
  for i := 0 to DisplayPromoContents.Count - 1 do
  begin
    Content := TContentfulObj(DisplayPromoContents.Item[i]);
    if Assigned(Content) then
    begin
      TotalHeight := TotalHeight + Content.FrameHeightRequired;

      if (TotalHeight < DisplayPromoContents.PromoMainWindowHeight) then
        Content.PageIndexWhereToDisplay := PageIndex
      else
      begin
        Inc(PageIndex);
        if PageIndex > CONTENT_MAX_PAGES_TODISPLAY then
          PageIndex := 0;

        Content.PageIndexWhereToDisplay := PageIndex;
        TotalHeight := 0;
      end;
    end;
  end;
end;

procedure TPromoDisplayFrm.CopyImage(aMoveImg1, aMoveImg2: TImage);
var
  tempPic : TPicture;
begin
  tempPic := TPicture.Create;
  try
    tempPic.Assign(aMoveImg2.Picture);
    aMoveImg2.Picture.Assign(aMoveImg1.Picture);
    aMoveImg1.Picture.Assign(tempPic);
  finally
    FreeAndNil(tempPic);
  end;
end;

procedure TPromoDisplayFrm.DisplayPage(aPageIndex: Integer);
var
  i : Integer;
  Content : TContentfulObj;
  NewFrame: TPromoContentFrame;
  Bitmap : TBitmap;
begin
  FreeAllExistingFrames;
  if not Assigned(DisplayPromoContents) then
    Exit;
    
  NewFrame := Nil;
  DisplayPromoContents.SortContentfulData;
  for i := 0 to DisplayPromoContents.Count - 1  do
  begin
    Content := TContentfulObj(DisplayPromoContents.Item[i]);
    if Assigned(Content) then
    begin
      if Content.PageIndexWhereToDisplay = aPageIndex then
      begin
        NewFrame := TPromoContentFrame.Create(Self);
        FrameList.Add(NewFrame);

        NewFrame.ParentFont := True;
        NewFrame.ParentColor := True;

        NewFrame.Parent := pnlFrames;//Self;
        NewFrame.Name := NewFrame.Name + IntToStr(aPageIndex) +  IntToStr(i);

        NewFrame.lblTitle.Font.Color := HyperLinkColor;
        NewFrame.lblTitle.Font.Size := 14;
        NewFrame.lblTitle.Font.Style := [fsBold];
        NewFrame.lblTitle.Caption := Trim(Content.Title);

        NewFrame.reDescription.Clear;
        NewFrame.lblDescResize.Caption := Trim(Content.Description);

        NewFrame.reDescription.Lines.Add(Trim(Content.Description));
        NewFrame.reDescription.Height := NewFrame.lblDescResize.Height ;
        NewFrame.lblDescResize.Visible := False;

        NewFrame.imgContainer.Visible := Content.IsImageAvilable;
        NewFrame.lblURL.Visible := (Trim(Content.URL) <> '');

        NewFrame.lblURL.Font.Color := HyperLinkColor;
        NewFrame.lblURL.Caption := Content.URL;
        NewFrame.lblURL.OnMouseEnter := OnURLMouseEnter;
        NewFrame.lblURL.OnMouseLeave := OnURLMouseLeave;
        NewFrame.lblURL.OnClick := OnURLClick;

        NewFrame.TabOrder := i;
        if Content.IsImageAvilable then
          NewFrame.imgContainer.Picture.Assign(Content.MainImageBitmap);
      end;
    end;
  end;

  if DisplayPromoContents.NoOfPagesRequired > 1 then
  begin
    //pnlMoveControls.Visible := True;
    PageNavigation.Visible := True;
    PageNavigation.Align := alBottom;
  end;
  pnlFrames.Align := alClient;

  for i := 0 to FrameList.Count - 1 do
  begin
    NewFrame := TPromoContentFrame(FrameList.Items[i]);
    NewFrame.Align :=  alBottom;
    NewFrame.Align :=  alTop;
  end;

  PageNavigation.ResetTop;
end;

procedure TPromoDisplayFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DisplayPromoContents.DisplayTypes := [ctUpgrade, ctMarketing, ctTechnical];
  DisplayPromoContents.ListValidContents;
end;

procedure TPromoDisplayFrm.FormCreate(Sender: TObject);
begin
  FrameList := TObjectList.Create;
  PageNavigation := TPageNavigation.Create(self);

  PageNavigation.Visible := False;
  PageNavigation.Parent := Self;//pnlMoveControls;
  PageNavigation.Height := 44;
  PageNavigation.Width := 600;
  PageNavigation.ImageList := PageImages;
  PageNavigation.OnLeftArrowClick := lblRightArrowClick;
  PageNavigation.OnRightArrowClick := lblLeftArrowClick;
  PageNavigation.OnImageClick := PageImageClick;

  PageNavigation.PageControlMargin := 4;
  PageNavigation.PageControlWidth := 20;
end;

procedure TPromoDisplayFrm.FormDestroy(Sender: TObject);
begin
  FrameList.Clear;
  FreeAndNil(FrameList);
  FreeAndNil(PageNavigation);
end;

procedure TPromoDisplayFrm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 27 then
    Close;
end;

procedure TPromoDisplayFrm.FormShow(Sender: TObject);
begin
  if Assigned(DisplayPromoContents) then
  begin
    DisplayPromoContents.SortContentfulData;
    DisplayPromoContents.PromoMainWindowHeight := 840-pnlControls.Height - PageNavigation.Height ;//pnlMoveControls.Height;
    DisplayPromoContents.NoOfPagesRequired := CalculatePagesRequired;
    DisplayPromoContents.SortContentfulData;
    PageNavigation.NoOfPages := DisplayPromoContents.NoOfPagesRequired;
  end;
  PurpleImageIndex := 1;

  DisplayPage(1);
end;

procedure TPromoDisplayFrm.FreeAllExistingFrames;
begin
  FrameList.Clear;
end;

procedure TPromoDisplayFrm.ImageClick(Sender: TObject);
begin
  inherited;
end;

procedure TPromoDisplayFrm.lblLeftArrowClick(Sender: TObject);
begin
  inherited;
  DisplayPage(PageNavigation.CurrentPage);
end;

procedure TPromoDisplayFrm.lblLeftArrowMouseLeave(Sender: TObject);
begin
  inherited
end;

procedure TPromoDisplayFrm.lblLeftArrowMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
end;

procedure TPromoDisplayFrm.lblRightArrowClick(Sender: TObject);
begin
  inherited;
  DisplayPage(PageNavigation.CurrentPage);
end;

procedure TPromoDisplayFrm.lblRightArrowMouseLeave(Sender: TObject);
begin
  inherited;
end;

procedure TPromoDisplayFrm.lblRightArrowMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
end;

procedure TPromoDisplayFrm.OnArrowLeave(Sender: TObject);
begin
  inherited;
end;

procedure TPromoDisplayFrm.OnArrowMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
end;

procedure TPromoDisplayFrm.OnURLClick(Sender: TObject);
var
  sURL : string;
begin
  sURL := TLabel(Sender).Caption;
  ShellExecute(0, 'OPEN', PChar(sURL), '', '', SW_SHOWNORMAL);
end;

procedure TPromoDisplayFrm.OnURLMouseEnter(Sender: TObject);
begin
  SetHyperlinkFont(TLabel(Sender).Font);
  Screen.Cursor := crHandPoint;
end;

procedure TPromoDisplayFrm.OnURLMouseLeave(Sender: TObject);
begin
  TLabel(Sender).Font.Style := [];
  Screen.Cursor := crDefault;
end;

procedure TPromoDisplayFrm.PageImageClick(Sender: TObject);
begin
  inherited;
  DisplayPage(PageNavigation.CurrentPage);
end;

end.
