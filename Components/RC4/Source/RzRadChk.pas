{===============================================================================
  RzRadChk Unit

  Raize Components - Component Source Unit

  Copyright � 1995-2007 by Raize Software, Inc.  All Rights Reserved.


  Components
  ------------------------------------------------------------------------------
  TRzRadioButton
    Custom radio button control--supports multi-line captions, 3D text styles,
    custom glyphs

  TRzCheckBox
    Custom check box control--supports multi-line captions, 3D text styles,
    custom glyphs


  Modification History
  ------------------------------------------------------------------------------
  4.2    (29 May 2007)
    * Fixed problem where TRzCheckBox would display slowly under certain
      conditions under Windows Vista.
  ------------------------------------------------------------------------------
  4.1    (15 Dec 2006)
    * Fixed problem where pressing an accelerator character for a TRzCheckBox
      would cause the state to change even if the check box was ReadOnly.
    * TRzCheckBox and TRzRadioButton now handle the BM_GETCHECK window message
      to return the current state of the control. This message is used by
      accessibility applications such as Windows Eyes.
    * Fixed flicker issue with TRzCheckBox and TRzRadioButton.
  ------------------------------------------------------------------------------
  4.0.3  (05 Apr 2006)
    * Added ReadOnly, ReadOnlyColor, and ReadOnlyColorOnFocus proeprties to
      TRzCheckBox and TRzRadioButton.  When either control is ReadOnly, the
      state of the control cannot be changed by the user (i.e. via mouse or
      keyboard). The state can stil be changed programatically.  Also, when a
      TRzRadioButton is made ReadOnly, all of the other sibling radio buttons
      (i.e within the same container) are also made ReadOnly.
    * Fixed problem where the check mark displayed in a disabled TRzCheckBox
      would appear in the normal color instead of the disabled color.
  ------------------------------------------------------------------------------
  4.0.2  (13 Jan 2006)
    * Fixed problem where TRzRadioButton and TRzCheckBox would not pick up the
      correct settings when connected to a TRzFrameController in Delphi 5.
  ------------------------------------------------------------------------------
  4.0.1  (07 Jan 2006)
    * Added FillColor and FocusColor properties to TRzRadioButton and
      TRzCheckbox. These properties affect the interior of the radio button
      and the check box glyph. When the control is focused, the interior is
      filled with the FocusColor otherwise the FillColor is used. These
      properties can also be controlled through a connected TRzFrameController.
    * Added HotTrackStyle property to TRzCheckBox and TRzRadioButton, which
      determines the appearance of hot track highlighting when the HotTrack
      property is set to True. The default of htsInterior is identical to
      previous versions where the interior is highlighted.  When set to htsFrame
      the frame of the box (or circle) is highlighted to be thicker--the same
      appearance as setting FrameHotStyle to fsFlatBold in TRzEdit and others.
      The TRzFrameController can also be used to manage the this new property
      and apperance.
  ------------------------------------------------------------------------------
  4.0    (23 Dec 2005)
    * The display methods for TRzRadioButton and TRzCheckBox has been completely
      redesigned in this version. The old approach utilized a bitmap resource
      and the control would replace colors in the resource to match the
      desired colors of the control. This was an adequate approach, but it did
      not allow for a smooth display (especially in radio buttons). Also, hot
      tracking was very rough looking as only two colors were used.  In this
      new version, the glyph images for the TRzRadioButton and TRzCheckBox are
      drawn using the new DrawRadioButton and DrawCheckBox procedures that were
      added to the RzCommon unit.  The new style display provides a very
      effective and polished appearance for both controls.  This is especially
      true with the circular radio button and the use of gradients for hot
      tracking.
    * Fixed problem where bottom portion of TRzCheckBox or TRzRadioButton
      caption would get cut off when using Large Fonts and using default size
      of the control.
    * Fixed display issues in TRzRadioButton and TRzCheckBox when running under
      RTL systems.
    * Surfaced Align property in TRzRadioButton and TRzCheckBox.
    * Added new FrameControllerNotifications property to TRzRadioButton and
      TRzCheckBox.
      The FrameControllerNotifications set property defines which
      TRzFrameController properties will be handled by the control.
      By default all TRzFrameController properties will be handled.
  ------------------------------------------------------------------------------
  3.0.13 (15 May 2005)
    * Fixed issue where change the Checked property of an Action that is 
      connected to a TRzCheckBox caused the check box to have painting issues.
  ------------------------------------------------------------------------------
  3.0.4  (04 Mar 2003)
    * Fixed display problems when running under Right-To-Left locales.
    * Fixed display problems when running under 256 and 16-bit color depths.
    * Fixed problem of disappearing check marks and radio button circles when
      Highlight color is clTeal as is used in the Dessert color scheme.
  ------------------------------------------------------------------------------
  3.0.3  (21 Jan 2003)
    * Added GetHotTrackRect override.
  ------------------------------------------------------------------------------
  3.0    (20 Dec 2002)
    * Added HotTrack property.
    * Fixed problem with OnExit event not firing.
===============================================================================}

{$I RzComps.inc}

unit RzRadChk;

interface

uses
  {$IFDEF USE_CS}
  CodeSiteLogging,
  {$ENDIF}
  SysUtils,
  Windows,
  Messages,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  RzCommon,
  RzButton,
  ActnList,
  Menus;

type
  {============================================}
  {== TRzCustomGlyphButton Class Declaration ==}
  {============================================}

  TRzCustomGlyphButton = class;

  TRzCheckedActionLink = class( TWinControlActionLink )
  protected
    FClient: TRzCustomGlyphButton;
    procedure AssignClient( AClient: TObject ); override;
    function IsCheckedLinked: Boolean; override;
    procedure SetChecked( Value: Boolean ); override;
  end;

  TRzCheckedActionLinkClass = class of TRzCheckedActionLink;

  {$IFDEF VCL60_OR_HIGHER}
  TRzCustomGlyphButton = class( TRzCustomButton, IRzCustomFramingNotification )
  {$ELSE}
  TRzCustomGlyphButton = class( TRzCustomButton, IUnknown, IRzCustomFramingNotification )
  {$ENDIF}
  private
    FAlignment: TLeftRight;
    FFrameColor: TColor;
    FNumStates: Integer;
    FCustomGlyphs: TBitmap;
    FUseCustomGlyphs: Boolean;
    FTransparentColor: TColor;
    FWinMaskColor: TColor;
    FFillColor: TColor;
    FFocusColor: TColor;
    FDisabledColor: TColor;
    FReadOnly: Boolean;
    FReadOnlyColorOnFocus: Boolean;
    FReadOnlyColor: TColor;
    FGlyphWidth: Integer;
    FGlyphHeight: Integer;
    FTabOnEnter: Boolean;
    FHotTrackStyle: TRzButtonHotTrackStyle;

    FFrameController: TRzFrameController;
    FFrameControllerNotifications: TRzFrameControllerNotifications;

    procedure ReadOldFrameFlatProp( Reader: TReader );

    function IsCheckedStored: Boolean;

    { Internal Event Handlers }
    procedure CustomGlyphsChanged( Sender: TObject );

    { Message Handling Methods }
    procedure CMEnabledChanged( var Msg: TMessage ); message cm_EnabledChanged;
    procedure CMParentColorChanged( var Msg: TMessage ); message cm_ParentColorChanged;
    procedure WMEraseBkgnd( var Msg: TWMEraseBkgnd ); message wm_EraseBkgnd;
    procedure WMSize( var Msg: TWMSize ); message wm_Size;
  protected
    FClicksDisabled: Boolean;
    FBackgroundBmp: TBitmap;
    FUpdateBg: Boolean;
    FUsingMouse: Boolean;

    procedure DefineProperties( Filer: TFiler ); override;
    procedure Notification( AComponent: TComponent; Operation: TOperation ); override;

    procedure ActionChange( Sender: TObject; CheckDefaults: Boolean ); override;
    function GetActionLinkClass: TControlActionLinkClass; override;

    procedure CustomFramingChanged; virtual;

    procedure SelectGlyph( Glyph: TBitmap ); virtual; abstract;
    procedure UpdateDisplay; override;
    procedure RepaintDisplay; override;
    function GetHotTrackRect: TRect; override;

    procedure BlendButtonFrame( Glyph: TBitmap ); virtual;
    procedure DrawGlyph( ACanvas: TCanvas ); virtual;
    procedure UpdateBackground;
    procedure PaintBackground( DC: HDC ); override;
    procedure Paint; override;

    procedure ExtractGlyph( Index: Integer; Bitmap, Source: TBitmap; W, H: Integer ); virtual;

    { Event Dispatch Methods }
    procedure KeyPress( var Key: Char ); override;
    procedure MouseDown( Button: TMouseButton; Shift: TShiftState; X, Y: Integer ); override;
    procedure MouseUp( Button: TMouseButton; Shift: TShiftState; X, Y: Integer ); override;


    { Property Access Methods }
    procedure SetAlignment( Value: TLeftRight ); virtual;
    function GetChecked: Boolean; virtual;
    procedure SetChecked( Value: Boolean ); virtual;
    procedure SetCustomGlyphs( Value: TBitmap ); virtual;
    procedure SetFillColor( Value: TColor ); virtual;
    procedure SetFocusColor( Value: TColor ); virtual;
    procedure SetFrameColor( Value: TColor ); virtual;
    procedure SetFrameController( Value: TRzFrameController ); virtual;
    procedure SetUseCustomGlyphs( Value: Boolean ); virtual;
    procedure SetDisabledColor( Value: TColor ); virtual;
    procedure SetReadOnly( Value: Boolean ); virtual;
    procedure SetReadOnlyColor( Value: TColor ); virtual;
    procedure SetTransparent( Value: Boolean ); override;
    procedure SetTransparentColor( Value: TColor ); virtual;
    procedure SetWinMaskColor( Value: TColor ); virtual;

    { Property Declarations }
    property Alignment: TLeftRight
      read FAlignment
      write SetAlignment
      default taRightJustify;

    property Checked: Boolean
      read GetChecked
      write SetChecked
      stored IsCheckedStored
      default False;

    property CustomGlyphs: TBitmap
      read FCustomGlyphs
      write SetCustomGlyphs;

    property DisabledColor: TColor
      read FDisabledColor
      write SetDisabledColor
      default clBtnFace;

    property FillColor: TColor
      read FFillColor
      write SetFillColor
      default clWindow;

    property FocusColor: TColor
      read FFocusColor
      write SetFocusColor
      default clWindow;

    property FrameColor: TColor
      read FFrameColor
      write SetFrameColor
      default clBtnShadow;

    property FrameControllerNotifications: TRzFrameControllerNotifications
      read FFrameControllerNotifications
      write FFrameControllerNotifications
      default fccAll;

    property FrameController: TRzFrameController
      read FFrameController
      write SetFrameController;

    property HotTrackStyle: TRzButtonHotTrackStyle
      read FHotTrackStyle
      write FHotTrackStyle
      default htsInterior;

    property ReadOnly: Boolean
      read FReadOnly
      write SetReadOnly
      default False;

    property ReadOnlyColorOnFocus: Boolean
      read FReadOnlyColorOnFocus
      write FReadOnlyColorOnFocus
      default False;

    property ReadOnlyColor: TColor
      read FReadOnlyColor
      write SetReadOnlyColor
      default clInfoBk;

    property TabOnEnter: Boolean
      read FTabOnEnter
      write FTabOnEnter
      default False;

    property TransparentColor: TColor
      read FTransparentColor
      write SetTransparentColor
      default clOlive;

    property UseCustomGlyphs: Boolean
      read FUseCustomGlyphs
      write SetUseCustomGlyphs
      default False;

    property WinMaskColor: TColor
      read FWinMaskColor
      write SetWinMaskColor
      default clLime;
  public
    constructor Create( AOwner: TComponent ); override;
    destructor Destroy; override;

    function GetControlsAlignment: TAlignment; override;
  end;


  {======================================}
  {== TRzRadioButton Class Declaration ==}
  {======================================}

  TRzRadioButton = class( TRzCustomGlyphButton )
  private
    FAboutInfo: TRzAboutInfo;
    FChecked: Boolean;

    { Message Handling Methods }
    procedure CMDialogChar( var Msg: TCMDialogChar ); message cm_DialogChar;
    procedure CMDialogKey( var Msg: TCMDialogKey ); message cm_DialogKey;
    procedure WMSetFocus( var Msg: TWMSetFocus ); message wm_SetFocus;
    procedure WMLButtonDblClk( var Msg: TWMLButtonDblClk ); message wm_LButtonDblClk;
    procedure BMGetCheck( var Msg: TMessage ); message bm_GetCheck;
  protected
    procedure ChangeState; override;
    procedure SelectGlyph( Glyph: TBitmap ); override;
    procedure BlendButtonFrame( Glyph: TBitmap ); override;

    { Property Access Methods }
    function GetChecked: Boolean; override;
    procedure SetChecked( Value: Boolean ); override;
    procedure SetReadOnly( Value: Boolean ); override;
  public
    constructor Create( AOwner: TComponent ); override;
    destructor Destroy; override;
  published
    property About: TRzAboutInfo
      read FAboutInfo
      write FAboutInfo
      stored False;

    { Inherited Properties & Events }
    property Action;
    property Align;
    property Alignment;
    property AlignmentVertical default avTop;
    property Anchors;
    property BiDiMode;
    property Caption;
    property Checked;
    property Color;
    property Constraints;
    property CustomGlyphs;
    property DisabledColor;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FillColor;
    property FocusColor;
    property FrameColor;
    property Font;
    property FrameControllerNotifications;
    property FrameController;
    property Height;
    property HelpContext;
    property HighlightColor;
    property Hint;
    property HotTrack;
    property HotTrackColor;
    property HotTrackColorType;
    property HotTrackStyle;
    property LightTextStyle;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ReadOnlyColor;
    property ReadOnlyColorOnFocus;
    property TextHighlightColor;
    property TextShadowColor;
    property TextShadowDepth;
    property ShowHint;
    property TabOnEnter;
    property TabOrder;
    property TabStop;
    property TextStyle;
    property Transparent;
    property TransparentColor;
    property UseCustomGlyphs;
    property Visible;
    property Width;
    property WinMaskColor;

    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;


  {=========================================}
  {== TRzCustomCheckBox Class Declaration ==}
  {=========================================}

  TRzCustomCheckBox = class( TRzCustomGlyphButton )
  private
    FAllowGrayed: Boolean;
    FState: TCheckBoxState;
    FKeyToggle: Boolean;

    { Message Handling Methods }
    procedure CMDialogChar( var Msg: TCMDialogChar ); message cm_DialogChar;
    procedure BMGetCheck( var Msg: TMessage ); message bm_GetCheck;
  protected
    procedure ChangeState; override;
    procedure SelectGlyph( Glyph: TBitmap ); override;

    { Event Dispatch Methods }
    procedure KeyDown( var Key: Word; Shift: TShiftState ); override;
    procedure KeyUp( var Key: Word; Shift: TShiftState ); override;
    procedure DoExit; override;

    { Property Access Methods }
    function GetChecked: Boolean; override;
    procedure SetChecked( Value: Boolean ); override;
    procedure SetState( Value: TCheckBoxState ); virtual;

    { Property Declarations }
    property AllowGrayed: Boolean
      read FAllowGrayed
      write FAllowGrayed
      default False;

    property State: TCheckBoxState
      read FState
      write SetState;

  public
    constructor Create( AOwner: TComponent ); override;
    destructor Destroy; override;

    procedure InitState( Value: TCheckBoxState );
  end;


  {== TRzCheckBox Class Declaration ==}

  TRzCheckBox = class( TRzCustomCheckBox )
  private
    FAboutInfo: TRzAboutInfo;
  published
    property About: TRzAboutInfo
      read FAboutInfo
      write FAboutInfo
      stored False;

    { Inherited Properties & Events }
    property Action;
    property Align;
    property Alignment;
    property AlignmentVertical default avTop;
    property AllowGrayed;
    property Anchors;
    property BiDiMode;
    property Caption;
    property Checked;
    property Color;
    property Constraints;
    property CustomGlyphs;
    property DisabledColor;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FillColor;
    property FocusColor;
    property FrameColor;
    property Font;
    property FrameControllerNotifications;
    property FrameController;
    property Height;
    property HelpContext;
    property HighlightColor;
    property Hint;
    property HotTrack;
    property HotTrackColor;
    property HotTrackColorType;
    property HotTrackStyle;
    property LightTextStyle;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ReadOnlyColor;
    property ReadOnlyColorOnFocus;
    property TextHighlightColor;
    property TextShadowColor;
    property TextShadowDepth;
    property ShowHint;
    property State;
    property TabOnEnter;
    property TabOrder;
    property TabStop default True;
    property TextStyle;
    property Transparent;
    property TransparentColor;
    property UseCustomGlyphs;
    property Visible;
    property Width;
    property WinMaskColor;

    property OnClick;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

implementation

uses
  {$IFDEF VCL70_OR_HIGHER}
  Themes,
  {$ELSE}
  RzThemeSrv,
  {$ENDIF}
  RzCommonBitmaps,
  RzGrafx;

const
  DefaultGlyphWidth  = 13;
  DefaultGlyphHeight = 13;


{==================================}
{== TRzCheckedActionLink Methods ==}
{==================================}

procedure TRzCheckedActionLink.AssignClient( AClient: TObject );
begin
  inherited;
  FClient := AClient as TRzCustomGlyphButton;
end;

function TRzCheckedActionLink.IsCheckedLinked: Boolean;
begin
  Result := inherited IsCheckedLinked and
    ( FClient.Checked = ( Action as TCustomAction ).Checked );
end;

procedure TRzCheckedActionLink.SetChecked( Value: Boolean );
begin
  if IsCheckedLinked then
  begin
    FClient.FClicksDisabled := True;
    try
      FClient.Checked := Value;
    finally
      FClient.FClicksDisabled := False;
    end;
  end;
end;


{&RT}
{==================================}
{== TRzCustomGlyphButton Methods ==}
{==================================}

constructor TRzCustomGlyphButton.Create( AOwner: TComponent );
begin
  inherited;
  FNumStates := 2;

  FGlyphWidth := DefaultGlyphWidth;
  FGlyphHeight := DefaultGlyphHeight;

  FCustomGlyphs := TBitmap.Create;
  FCustomGlyphs.OnChange := CustomGlyphsChanged;
  FUseCustomGlyphs := False;

  FTabOnEnter := False;

  FFrameController := nil;
  FFrameControllerNotifications := fccAll;

  FFrameColor := clBtnShadow;
  FDisabledColor := clBtnFace;
  FTransparentColor := clOlive;
  FWinMaskColor := clLime;
  FFocusColor := clWindow;
  FFillColor := clWindow;
  FReadOnly := False;
  FReadOnlyColor := clInfoBk;
  FReadOnlyColorOnFocus := False;

  FBackgroundBmp := TBitmap.Create;
  FUpdateBg := True;
  FUsingMouse := False;

  FAlignment := taRightJustify;
  ControlStyle := ControlStyle + [ csSetCaption, csReplicatable ];
end;


destructor TRzCustomGlyphButton.Destroy;
begin
  if FFrameController <> nil then
    FFrameController.RemoveControl( Self );

  FCustomGlyphs.Free;
  FBackgroundBmp.Free;
  inherited;
end;


procedure TRzCustomGlyphButton.DefineProperties( Filer: TFiler );
begin
  inherited;
  // Handle the fact that the Flat property was renamed to HotTrack
  Filer.DefineProperty( 'Flat', ReadOldFrameFlatProp, nil, False );
end;


procedure TRzCustomGlyphButton.ReadOldFrameFlatProp( Reader: TReader );
begin
  HotTrack := Reader.ReadBoolean;
end;


procedure TRzCustomGlyphButton.Notification( AComponent: TComponent; Operation: TOperation );
begin
  inherited;
  if ( Operation = opRemove ) and ( AComponent = FFrameController ) then
    FFrameController := nil;
end;


procedure TRzCustomGlyphButton.CustomFramingChanged;
begin
  if FFrameController.FrameVisible then
  begin
    FHotTrack := True;

    if fcpColor in FFrameControllerNotifications then
      FFillColor := FFrameController.Color;
    if fcpFrameColor in FFrameControllerNotifications then
      FFrameColor := FFrameController.FrameColor;
    if fcpFocusColor in FFrameControllerNotifications then
      FFocusColor := FFrameController.FocusColor;
    if fcpDisabledColor in FFrameControllerNotifications then
      FDisabledColor := FFrameController.DisabledColor;
    if fcpReadOnlyColor in FFrameControllerNotifications then
      FReadOnlyColor := FFrameController.ReadOnlyColor;
    if fcpReadOnlyColorOnFocus in FFrameControllerNotifications then
      FReadOnlyColorOnFocus := FFrameController.ReadOnlyColorOnFocus;
    if fcpFrameHotTrack in FFrameControllerNotifications then
    begin
      if FFrameController.FrameHotTrack then
        FHotTrackStyle := htsFrame
      else
        FHotTrackStyle := htsInterior;
    end;
    if fcpFrameHotColor in FFrameControllerNotifications then
    begin
      if FHotTrackStyle = htsFrame then
        HotTrackColor := FFrameController.FrameHotColor;
    end;
    Invalidate;
  end;
end;


function TRzCustomGlyphButton.GetControlsAlignment: TAlignment;
begin
  if not UseRightToLeftAlignment then
    Result := taRightJustify
  else if FAlignment = taRightJustify then
    Result := taLeftJustify
  else
    Result := taRightJustify;
end;


procedure TRzCustomGlyphButton.ActionChange(Sender: TObject; CheckDefaults: Boolean);
begin
  inherited;

  if Sender is TCustomAction then
  begin
    with TCustomAction( Sender ) do
    begin
      if not CheckDefaults or ( Self.Checked = False ) then
        Self.Checked := Checked;
    end;
  end;
end;


function TRzCustomGlyphButton.GetActionLinkClass: TControlActionLinkClass;
begin
  Result := TRzCheckedActionLink;
end;


function TRzCustomGlyphButton.IsCheckedStored: Boolean;
begin
  Result := ( ActionLink = nil ) or not TRzCheckedActionLink( ActionLink ).IsCheckedLinked;
end;


function TRzCustomGlyphButton.GetChecked: Boolean;
begin
  Result := False;
end;

procedure TRzCustomGlyphButton.SetChecked( Value: Boolean );
begin
end;

procedure TRzCustomGlyphButton.CustomGlyphsChanged( Sender: TObject );
begin
  UseCustomGlyphs := not FCustomGlyphs.Empty;
  FUpdateBg := True;
  Invalidate;
end;


procedure TRzCustomGlyphButton.ExtractGlyph( Index: Integer; Bitmap, Source: TBitmap; W, H: Integer );
var
  DestRct: TRect;
begin
  DestRct := Rect( 0, 0, W, H );

  Bitmap.Width := W;
  Bitmap.Height := H;
  Bitmap.Canvas.CopyRect( DestRct, Source.Canvas, Rect( Index * W, 0, (Index + 1 ) * W, H ) );
end;


procedure TRzCustomGlyphButton.SetAlignment( Value: TLeftRight );
begin
  if FAlignment <> Value then
  begin
    FAlignment := Value;
    Invalidate;
  end;
end;


procedure TRzCustomGlyphButton.SetCustomGlyphs( Value: TBitmap );
begin
  FCustomGlyphs.Assign( Value );
end;


procedure TRzCustomGlyphButton.SetFillColor( Value: TColor );
begin
  if FFillColor <> Value then
  begin
    FFillColor := Value;
    Invalidate;
  end;
end;


procedure TRzCustomGlyphButton.SetFocusColor( Value: TColor );
begin
  if FFocusColor <> Value then
  begin
    FFocusColor := Value;
    Invalidate;
  end;
end;


procedure TRzCustomGlyphButton.SetFrameColor( Value: TColor );
begin
  if FFrameColor <> Value then
  begin
    FFrameColor := Value;
    Invalidate;
  end;
end;


procedure TRzCustomGlyphButton.SetFrameController( Value: TRzFrameController );
begin
  if FFrameController <> nil then
    FFrameController.RemoveControl( Self );
  FFrameController := Value;
  if Value <> nil then
  begin
    Value.AddControl( Self );
    Value.FreeNotification( Self );
  end;
end;


procedure TRzCustomGlyphButton.SetUseCustomGlyphs( Value: Boolean );
begin
  if FUseCustomGlyphs <> Value then
  begin
    FUseCustomGlyphs := Value;
    if FUseCustomGlyphs then
    begin
      FGlyphWidth := FCustomGlyphs.Width div FNumStates;
      FGlyphHeight := FCustomGlyphs.Height;
    end
    else
    begin
      FGlyphWidth := DefaultGlyphWidth;
      FGlyphHeight := DefaultGlyphHeight;
    end;
    Invalidate;
  end;
end;


procedure TRzCustomGlyphButton.SetDisabledColor( Value: TColor );
begin
  if FDisabledColor <> Value then
  begin
    FDisabledColor := Value;
    Invalidate;
  end;
end;


procedure TRzCustomGlyphButton.SetReadOnly( Value: Boolean );
begin
  if FReadOnly <> Value then
  begin
    FReadOnly := Value;
    Invalidate;
  end;
end;


procedure TRzCustomGlyphButton.SetReadOnlyColor( Value: TColor );
begin
  if FReadOnlyColor <> Value then
  begin
    FReadOnlyColor := Value;
    Invalidate;
  end;
end;


procedure TRzCustomGlyphButton.SetTransparent( Value: Boolean );
begin
  FUpdateBg := True;
  inherited;
end;


procedure TRzCustomGlyphButton.SetTransparentColor( Value: TColor );
begin
  if FTransparentColor <> Value then
  begin
    FTransparentColor := Value;
    Invalidate;
  end;
end;


procedure TRzCustomGlyphButton.SetWinMaskColor( Value: TColor );
begin
  if FWinMaskColor <> Value then
  begin
    FWinMaskColor := Value;
    Invalidate;
  end;
end;


procedure TRzCustomGlyphButton.RepaintDisplay;
begin
  Paint;
end;


procedure TRzCustomGlyphButton.UpdateDisplay;
begin
  Paint;
end;


function TRzCustomGlyphButton.GetHotTrackRect: TRect;
var
  X, Y: Integer;
begin
  if ( FAlignment = taRightJustify ) xor UseRightToLeftAlignment then
    X := 0
  else
    X := Width - FGlyphWidth;

  Y := 0;
  case AlignmentVertical of
    avTop:
      Y := 2;

    avCenter:
      Y := ( Height - FGlyphHeight ) div 2;

    avBottom:
      Y := Height - FGlyphHeight - 2;
  end;

  Result := Rect( X, Y, X + FGlyphWidth, Y + FGlyphHeight );
end;


procedure TRzCustomGlyphButton.BlendButtonFrame( Glyph: TBitmap );
begin
  // Do nothing in base class -- override as needed in descendants
end;


procedure TRzCustomGlyphButton.DrawGlyph( ACanvas: TCanvas );
var
  R, SrcRect: TRect;
  FGlyph, Phase1Bmp, Phase2Bmp: TBitmap;
  X, Y: Integer;
begin
  if ACanvas = nil then
    ACanvas := Canvas;
  FGlyph := TBitmap.Create;
  FGlyph.Width := FGlyphWidth;
  FGlyph.Height := FGlyphHeight;
  try
    SelectGlyph( FGlyph );

    Phase1Bmp := TBitmap.Create;
    Phase2Bmp := TBitmap.Create;
    try
      if ( FAlignment = taRightJustify ) xor UseRightToLeftAlignment then
        X := 0
      else
        X := Width - FGlyphWidth;

      Y := 0;
      case AlignmentVertical of
        avTop:
          Y := 2;

        avCenter:
          Y := ( Height - FGlyphHeight ) div 2;

        avBottom:
          Y := Height - FGlyphHeight - 2;
      end;

      { Don't Forget to Set the Width and Height of Destination Bitmap }
      Phase1Bmp.Width := FGlyphWidth;
      Phase1Bmp.Height := FGlyphHeight;

      R := Rect( 0, 0, FGlyphWidth, FGlyphHeight );

      if FTransparent then
      begin
        SrcRect := Bounds( X, Y, FGlyphWidth, FGlyphHeight );
        Phase1Bmp.Canvas.CopyMode := cmSrcCopy;
        Phase1Bmp.Canvas.CopyRect( R, ACanvas, SrcRect );
        if ThemeServices.ThemesEnabled then
          DrawFullTransparentBitmap( Phase1Bmp.Canvas, FGlyph, R, R, clBtnFace )
        else
          DrawFullTransparentBitmap( Phase1Bmp.Canvas, FGlyph, R, R, FTransparentColor );
      end
      else
      begin
        Phase1Bmp.Canvas.Brush.Color := Color;
        Phase1Bmp.Canvas.BrushCopy( R, FGlyph, R, FTransparentColor );
      end;

      if FUseCustomGlyphs or Transparent then
      begin
        if FUseCustomGlyphs then
        begin
          // Replace WinMaskColor with clWindow color value
          Phase2Bmp.Width := FGlyphWidth;
          Phase2Bmp.Height := FGlyphHeight;
          Phase2Bmp.Canvas.Brush.Color := clWindow;
          Phase2Bmp.Canvas.BrushCopy( R, Phase1Bmp, R, FWinMaskColor );
        end
        else
        begin
          Phase2Bmp.Assign( Phase1Bmp );
        end;

        if Transparent then
          BlendButtonFrame( Phase2Bmp );
      end
      else  // Normal, non-transparent image
      begin
        Phase2Bmp.Assign( Phase1Bmp );
      end;

      ACanvas.Draw( X, Y, Phase2Bmp );
    finally
      Phase2Bmp.Free;
      Phase1Bmp.Free;
    end;
  finally
    FGlyph.Free;
  end;
end; {= TRzCustomGlyphButton.DrawGlyph =}


procedure TRzCustomGlyphButton.UpdateBackground;
begin
  // Save background image of entire control
  FBackgroundBmp.Width := Width;
  FBackgroundBmp.Height := Height;

  if FTransparent then
  begin
    // Parent image has already been copied to Canvas via TRzCustomButton.WMEraseBkgnd
    // So, simply copy current Canvas image into the FBackgroundBmp.Canvas
    FBackgroundBmp.Canvas.CopyRect( ClientRect, Canvas, ClientRect );
  end
  else
  begin
    FBackgroundBmp.Canvas.Brush.Color := Color;
    FBackgroundBmp.Canvas.FillRect( ClientRect );
  end;
  FUpdateBg := False;
end;


procedure TRzCustomGlyphButton.Paint;
var
  R: TRect;
  W: Integer;
  MemImage: TBitmap;
  Flags: DWord;
begin
  if csDestroying in ComponentState then
    Exit;

  MemImage := TBitmap.Create;
  try
    { Make memory Bitmap same size as client rect }
    MemImage.Height := Height;
    MemImage.Width := Width;

    MemImage.Canvas.Font := Font;
    MemImage.Canvas.Brush.Color := Color;

    if FUpdateBg then
      UpdateBackground;
    MemImage.Canvas.CopyRect( ClientRect, FBackgroundBmp.Canvas, ClientRect );

    DrawGlyph( MemImage.Canvas );

    R := ClientRect;
    InflateRect( R, -1, -1 );
    if (FAlignment = taRightJustify) xor UseRightToLeftAlignment then
      Inc( R.Left, FGlyphWidth + 4 )
    else
      Dec( R.Right, FGlyphWidth + 4 );

    if UseRightToLeftAlignment then
      Flags := dt_Right
    else
      Flags := 0;

    { Draw Caption }
    Draw3DText( MemImage.Canvas, R, dt_WordBreak or dt_ExpandTabs or Flags );

    InflateRect( R, 1, 1 );
    if Focused and ( Caption <> '' ) then
    begin
      W := Min( R.Right - R.Left, MemImage.Canvas.TextWidth( Trim( Caption ) ) + 3 );
      if not UseRightToLeftAlignment then
        R.Right := R.Left + W
      else
        R.Left := R.Right - W;
      DrawFocusBorder( MemImage.Canvas, R );
    end;

    Canvas.CopyMode := cmSrcCopy;
    Canvas.Draw( 0, 0, MemImage );
  finally
    MemImage.Free;
  end;
end; {= TRzCustomGlyphButton.Paint =}


procedure TRzCustomGlyphButton.KeyPress( var Key: Char );
begin
  if FTabOnEnter and ( Ord( Key ) = vk_Return ) then
  begin
    Key := #0;
    PostMessage( Handle, wm_KeyDown, vk_Tab, 0 );
  end
  else
    inherited;
end;


procedure TRzCustomGlyphButton.MouseDown( Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
begin
  FUsingMouse := True;
  inherited;
end;


procedure TRzCustomGlyphButton.MouseUp( Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
begin
  inherited;
  FUsingMouse := False;
end;


procedure TRzCustomGlyphButton.WMEraseBkgnd( var Msg: TWMEraseBkgnd );
begin
  inherited;
  FUpdateBg := True;
end;


procedure TRzCustomGlyphButton.PaintBackground( DC: HDC );
begin
  if FTransparent then
    DrawParentImage( Self, DC, True );
end;


procedure TRzCustomGlyphButton.WMSize( var Msg: TWMSize );
begin
  inherited;
  FUpdateBg := True;
end;


procedure TRzCustomGlyphButton.CMEnabledChanged( var Msg: TMessage );
begin
  inherited;
  FUpdateBg := True;
  Invalidate;
end;


procedure TRzCustomGlyphButton.CMParentColorChanged( var Msg: TMessage );
begin
  inherited;
  FUpdateBg := True;
  Invalidate;
end;



{============================}
{== TRzRadioButton Methods ==}
{============================}

constructor TRzRadioButton.Create( AOwner: TComponent );
begin
  inherited;
  AlignmentVertical := avTop;
  FChecked := False;
  FNumStates := 6;
  TabStop := False;
  {&RCI}
end;


destructor TRzRadioButton.Destroy;
begin
  inherited;
end;


function TRzRadioButton.GetChecked: Boolean;
begin
  Result := FChecked;
end;

procedure TRzRadioButton.SetChecked( Value: Boolean );

  procedure TurnSiblingsOff;
  var
    I: Integer;
    Sibling: TControl;
  begin
    if Parent <> nil then
      with Parent do
      begin
        for I := 0 to ControlCount - 1 do
        begin
          Sibling := Controls[ I ];
          if ( Sibling <> Self ) and ( Sibling is TRzRadioButton ) then
            TRzRadioButton( Sibling ).SetChecked( False );
        end;
      end;
  end;

begin
  {&RV}
  if FChecked <> Value then
  begin
    FChecked := Value;
    TabStop := Value;
    UpdateDisplay;
    if Value then
    begin
      TurnSiblingsOff;
      if not FClicksDisabled then
        Click;
    end;
  end;
end;


procedure TRzRadioButton.SetReadOnly( Value: Boolean );

  procedure UpdateSiblings( ReadOnly: Boolean );
  var
    I: Integer;
    Sibling: TControl;
  begin
    if Parent <> nil then
      with Parent do
      begin
        for I := 0 to ControlCount - 1 do
        begin
          Sibling := Controls[ I ];
          if ( Sibling <> Self ) and ( Sibling is TRzRadioButton ) then
            TRzRadioButton( Sibling ).ReadOnly := ReadOnly;
        end;
      end;
  end;

begin
  if FReadOnly <> Value then
  begin
    FReadOnly := Value;
    UpdateDisplay;
    UpdateSiblings( FReadOnly );
  end;
end;


procedure TRzRadioButton.ChangeState;
begin
  if not FChecked and not FReadOnly then
    SetChecked( True );
end;


procedure TRzRadioButton.BlendButtonFrame( Glyph: TBitmap );
begin
  Glyph.Canvas.Pixels[  4,  0 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[  4,  0 ], 128 );
  Glyph.Canvas.Pixels[  8,  0 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[  8,  0 ], 128 );
  Glyph.Canvas.Pixels[  2,  1 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[  2,  1 ], 128 );
  Glyph.Canvas.Pixels[ 10,  1 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[ 10,  1 ], 128 );
  Glyph.Canvas.Pixels[  1,  2 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[  1,  2 ], 128 );
  Glyph.Canvas.Pixels[ 11,  2 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[ 11,  2 ], 128 );
  Glyph.Canvas.Pixels[  0,  4 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[  0,  4 ], 128 );
  Glyph.Canvas.Pixels[ 12,  4 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[ 12,  4 ], 128 );
  Glyph.Canvas.Pixels[  0,  8 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[  0,  8 ], 128 );
  Glyph.Canvas.Pixels[ 12,  8 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[ 12,  8 ], 128 );
  Glyph.Canvas.Pixels[  1, 10 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[  1, 10 ], 128 );
  Glyph.Canvas.Pixels[ 11, 10 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[ 11, 10 ], 128 );
  Glyph.Canvas.Pixels[  2, 11 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[  2, 11 ], 128 );
  Glyph.Canvas.Pixels[ 10, 11 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[ 10, 11 ], 128 );
  Glyph.Canvas.Pixels[  4, 12 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[  4, 12 ], 128 );
  Glyph.Canvas.Pixels[  8, 12 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[  8, 12 ], 128 );

  Glyph.Canvas.Pixels[  3,  0 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[  3,  0 ], 40 );
  Glyph.Canvas.Pixels[  9,  0 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[  9,  0 ], 40 );
  Glyph.Canvas.Pixels[  0,  3 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[  0,  3 ], 40 );
  Glyph.Canvas.Pixels[ 12,  3 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[ 12,  3 ], 40 );
  Glyph.Canvas.Pixels[  0,  9 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[  0,  9 ], 40 );
  Glyph.Canvas.Pixels[ 12,  9 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[ 12,  9 ], 40 );
  Glyph.Canvas.Pixels[  3, 12 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[  3, 12 ], 40 );
  Glyph.Canvas.Pixels[  9, 12 ] := BlendColors( FrameColor, Glyph.Canvas.Pixels[  9, 12 ], 40 );
end;


procedure TRzRadioButton.SelectGlyph( Glyph: TBitmap );
var
  R: TRect;
  Flags: Integer;
  DestBmp, SourceBmp: TBitmap;
  HotTrackLightColor, HotTrackDarkColor: TColor;
  ElementDetails: TThemedElementDetails;
  DisplayState: TRzButtonDisplayState;
begin
  R := Rect( 0, 0, FGlyphWidth, FGlyphHeight );

  if not FUseCustomGlyphs then
  begin
    // Test for XP themes first...
    if ThemeServices.ThemesEnabled then
    begin
      if FChecked then
      begin
        if Enabled then
        begin
          if FShowDownVersion then
            ElementDetails := ThemeServices.GetElementDetails( tbRadioButtonCheckedPressed )
          else if FMouseOverButton then
            ElementDetails := ThemeServices.GetElementDetails( tbRadioButtonCheckedHot )
          else
            ElementDetails := ThemeServices.GetElementDetails( tbRadioButtonCheckedNormal );
        end
        else
        begin
          ElementDetails := ThemeServices.GetElementDetails( tbRadioButtonCheckedDisabled );
        end;
      end
      else // Unchecked
      begin
        if Enabled then
        begin
          if FShowDownVersion then
            ElementDetails := ThemeServices.GetElementDetails( tbRadioButtonUncheckedPressed )
          else if FMouseOverButton then
            ElementDetails := ThemeServices.GetElementDetails( tbRadioButtonUncheckedHot )
          else
            ElementDetails := ThemeServices.GetElementDetails( tbRadioButtonUncheckedNormal );
        end
        else
        begin
          ElementDetails := ThemeServices.GetElementDetails( tbRadioButtonUncheckedDisabled );
        end;
      end;

      Glyph.Canvas.Brush.Color := Self.Color;
      Glyph.Canvas.FillRect( R );
      ThemeServices.DrawElement( Glyph.Canvas.Handle, ElementDetails, R );
    end
    else if HotTrack then // and No XP Themes
    begin
      if HotTrackColorType = htctComplement then
      begin
        HotTrackLightColor := ComplementaryColor( HotTrackColor, 180 );
        HotTrackDarkColor := DarkerColor( HotTrackLightColor, 30 );
      end
      else
      begin
        HotTrackDarkColor := HotTrackColor;
        HotTrackLightColor := BlendColors( clWhite, HotTrackDarkColor, 190 );
      end;

      if Enabled then
      begin
        if FShowDownVersion then
          DisplayState := bdsDown
        else if FMouseOverButton then
          DisplayState := bdsHot
        else
          DisplayState := bdsNormal;
      end
      else
        DisplayState := bdsDisabled;

      DrawRadioButton( Glyph.Canvas, R, FChecked, DisplayState, Focused, FHotTrackStyle,
                       FFrameColor, HighlightColor, FFillColor, FFocusColor, FDisabledColor,
                       HotTrackLightColor, HotTrackDarkColor,
                       Color, Transparent, clOlive, FReadOnly, FReadOnlyColorOnFocus,
                       FReadOnlyColor );
    end
    else // Default OS appearance
    begin
      if FChecked then
        Flags := dfcs_ButtonRadio or dfcs_Checked
      else
        Flags := dfcs_ButtonRadio;

      if FShowDownVersion then
        Flags := Flags or dfcs_Pushed;
      if not Enabled then
        Flags := Flags or dfcs_Inactive;

      Flags := Flags or dfcs_Transparent;

      Glyph.Canvas.Brush.Color := FTransparentColor;
      Glyph.Canvas.FillRect( R );
      DrawFrameControl( Glyph.Canvas.Handle, R, dfc_Button, Flags );
    end;
  end
  else // Using Custom Glyphs
  begin
    SourceBmp := FCustomGlyphs;

    DestBmp := TBitmap.Create;
    try
      if Enabled then
      begin
        if FChecked then
          if FShowDownVersion then
            ExtractGlyph( 3, DestBmp, SourceBmp, FGlyphWidth, FGlyphHeight )
          else
            ExtractGlyph( 1, DestBmp, SourceBmp, FGlyphWidth, FGlyphHeight )
        else
          if FShowDownVersion then
            ExtractGlyph( 2, DestBmp, SourceBmp, FGlyphWidth, FGlyphHeight )
          else
            ExtractGlyph( 0, DestBmp, SourceBmp, FGlyphWidth, FGlyphHeight );
      end
      else
      begin
        if FChecked then
          ExtractGlyph( 5, DestBmp, SourceBmp, FGlyphWidth, FGlyphHeight )
        else
          ExtractGlyph( 4, DestBmp, SourceBmp, FGlyphWidth, FGlyphHeight );
      end;

      Glyph.Assign( DestBmp );

    finally
      DestBmp.Free;
    end;
  end;
end; {= TRzRadioButton.SelectGlyph =}


procedure TRzRadioButton.CMDialogChar( var Msg: TCMDialogChar );
begin
  with Msg do
  begin
    if IsAccel( CharCode, Caption ) and CanFocus then
    begin
      SetFocus;
      Result := 1;
    end
    else
      inherited;
  end;
end;


procedure TRzRadioButton.CMDialogKey( var Msg: TCMDialogKey );
begin
  with Msg do
  begin
    if ( CharCode = vk_Down ) and ( KeyDataToShiftState( KeyData ) = [] ) and CanFocus then
    begin
      if not FClicksDisabled then
        Click;
      Result := 1;
    end
    else
      inherited;
  end;
end;


procedure TRzRadioButton.WMSetFocus( var Msg: TWMSetFocus );
begin
  inherited;
  if not FUsingMouse and not FReadOnly then
    SetChecked( True );
end;


procedure TRzRadioButton.WMLButtonDblClk( var Msg: TWMLButtonDblClk );
begin
  inherited;
  DblClick;
end;


procedure TRzRadioButton.BMGetCheck( var Msg: TMessage );
begin
  inherited;
  if FChecked then
    Msg.Result := BST_CHECKED
  else
    Msg.Result := BST_UNCHECKED;
end;



{===============================}
{== TRzCustomCheckBox Methods ==}
{===============================}

constructor TRzCustomCheckBox.Create( AOwner: TComponent );
begin
  inherited;
  AlignmentVertical := avTop;
  FNumStates := 9;
  FState := cbUnchecked;
  FAllowGrayed := False;
  {&RCI}
end;


destructor TRzCustomCheckBox.Destroy;
begin
  inherited;
end;


procedure TRzCustomCheckBox.ChangeState;
begin
  {&RV}
  if FUsingMouse and FReadOnly then
    Exit;
  case State of
    cbUnchecked:
      if FAllowGrayed then
        State := cbGrayed
      else
        State := cbChecked;

    cbChecked:
      State := cbUnchecked;

    cbGrayed:
      State := cbChecked;
  end;
end;


function TRzCustomCheckBox.GetChecked: Boolean;
begin
  Result := FState = cbChecked;
end;


procedure TRzCustomCheckBox.SetChecked( Value: Boolean );
begin
  if Value then
    State := cbChecked
  else
    State := cbUnchecked;
end;


procedure TRzCustomCheckBox.SetState( Value: TCheckBoxState );
begin
  if FState <> Value then
  begin
    FState := Value;
    UpdateDisplay;
    if not FClicksDisabled then
      Click;
  end;
end;


procedure TRzCustomCheckBox.InitState( Value: TCheckBoxState );
begin
  if FState <> Value then
  begin
    FState := Value;
    UpdateDisplay;
    { This method does not generate the OnClick event }
  end;
end;


procedure TRzCustomCheckBox.KeyDown( var Key: Word; Shift: TShiftState );
begin
  inherited;
  if FReadOnly then
    Exit;
  if Key = vk_Escape then
  begin
    FKeyToggle := False;
    FShowDownVersion := False;
    UpdateDisplay;
  end
  else if Key = vk_Space then
  begin
    FKeyToggle := True;
    FShowDownVersion := True;
    UpdateDisplay;
  end;
end;


procedure TRzCustomCheckBox.KeyUp( var Key: Word; Shift: TShiftState );
begin
  inherited;
  if FReadOnly then
    Exit;
  if Key = vk_Space then
  begin
    FShowDownVersion := False;
    if FKeyToggle then
      ChangeState;
    UpdateDisplay;
  end;
end;


procedure TRzCustomCheckBox.DoExit;
begin
  inherited;
  FShowDownVersion := False;
  UpdateDisplay;
end;


procedure TRzCustomCheckBox.SelectGlyph( Glyph: TBitmap );
var
  R: TRect;
  Flags: Integer;
  DestBmp, SourceBmp: TBitmap;
  HotTrackLightColor, HotTrackDarkColor: TColor;
  ElementDetails: TThemedElementDetails;
  DisplayState: TRzButtonDisplayState;
begin
  R := Rect( 0, 0, FGlyphWidth, FGlyphHeight );

  if not FUseCustomGlyphs then
  begin
    // Test for XP Themes first...
    if ThemeServices.ThemesEnabled then
    begin
      case FState of
        cbUnchecked:
        begin
          if Enabled then
          begin
            if FShowDownVersion then
              ElementDetails := ThemeServices.GetElementDetails( tbCheckBoxUncheckedPressed )
            else if FMouseOverButton then
              ElementDetails := ThemeServices.GetElementDetails( tbCheckBoxUncheckedHot )
            else
              ElementDetails := ThemeServices.GetElementDetails( tbCheckBoxUncheckedNormal );
          end
          else
          begin
            ElementDetails := ThemeServices.GetElementDetails( tbCheckBoxUncheckedDisabled );
          end;
        end;

        cbChecked:
        begin
          if Enabled then
          begin
            if FShowDownVersion then
              ElementDetails := ThemeServices.GetElementDetails( tbCheckBoxCheckedPressed )
            else if FMouseOverButton then
              ElementDetails := ThemeServices.GetElementDetails( tbCheckBoxCheckedHot )
            else
              ElementDetails := ThemeServices.GetElementDetails( tbCheckBoxCheckedNormal );
          end
          else
          begin
            ElementDetails := ThemeServices.GetElementDetails( tbCheckBoxCheckedDisabled );
          end;
        end;

        cbGrayed:
        begin
          if Enabled then
          begin
            if FShowDownVersion then
              ElementDetails := ThemeServices.GetElementDetails( tbCheckBoxMixedPressed )
            else if FMouseOverButton then
              ElementDetails := ThemeServices.GetElementDetails( tbCheckBoxMixedHot )
            else
              ElementDetails := ThemeServices.GetElementDetails( tbCheckBoxMixedNormal );
          end
          else
          begin
            ElementDetails := ThemeServices.GetElementDetails( tbCheckBoxMixedDisabled );
          end;
        end;
      end;

      Glyph.Canvas.Brush.Color := Self.Color;
      Glyph.Canvas.FillRect( R );
      ThemeServices.DrawElement( Glyph.Canvas.Handle, ElementDetails, R );
    end
    else if HotTrack then
    begin
      if HotTrackColorType = htctComplement then
      begin
        HotTrackLightColor := ComplementaryColor( HotTrackColor, 180 );
        HotTrackDarkColor := DarkerColor( HotTrackLightColor, 30 );
      end
      else
      begin
        HotTrackDarkColor := HotTrackColor;
        HotTrackLightColor := BlendColors( clWhite, HotTrackDarkColor, 190 );
      end;

      if Enabled then
      begin
        if FShowDownVersion then
          DisplayState := bdsDown
        else if FMouseOverButton then
          DisplayState := bdsHot
        else
          DisplayState := bdsNormal;
      end
      else
        DisplayState := bdsDisabled;

      DrawCheckBox( Glyph.Canvas, R, FState, DisplayState, Focused, FHotTrackStyle,
                    FFrameColor, HighlightColor, FFillColor, FFocusColor, FDisabledColor,
                    HotTrackLightColor, HotTrackDarkColor, FReadOnly,
                    FReadOnlyColorOnFocus, FReadOnlyColor );
    end
    else // Default OS appearance
    begin
      Flags := 0;
      case FState of
        cbUnchecked: Flags := dfcs_ButtonCheck;
        cbChecked: Flags := dfcs_ButtonCheck or dfcs_Checked;
        cbGrayed: Flags := dfcs_Button3State or dfcs_Checked;
      end;
      if FShowDownVersion then
        Flags := Flags or dfcs_Pushed;
      if not Enabled then
        Flags := Flags or dfcs_Inactive;

      DrawFrameControl( Glyph.Canvas.Handle, R, dfc_Button, Flags );
    end;
  end
  else // Use Custom Glyphs
  begin
    SourceBmp := FCustomGlyphs;

    DestBmp := TBitmap.Create;
    try
      if Enabled then
      begin
        case FState of
          cbUnchecked:
            if FShowDownVersion then
              ExtractGlyph( 3, DestBmp, SourceBmp, FGlyphWidth, FGlyphHeight )
            else
              ExtractGlyph( 0, DestBmp, SourceBmp, FGlyphWidth, FGlyphHeight );

          cbChecked:
            if FShowDownVersion then
              ExtractGlyph( 4, DestBmp, SourceBmp, FGlyphWidth, FGlyphHeight )
            else
              ExtractGlyph( 1, DestBmp, SourceBmp, FGlyphWidth, FGlyphHeight );

          cbGrayed:
            if FShowDownVersion then
              ExtractGlyph( 5, DestBmp, SourceBmp, FGlyphWidth, FGlyphHeight )
            else
              ExtractGlyph( 2, DestBmp, SourceBmp, FGlyphWidth, FGlyphHeight );
        end;
      end
      else
      begin
        case FState of
          cbUnchecked:
            ExtractGlyph( 6, DestBmp, SourceBmp, FGlyphWidth, FGlyphHeight );

          cbChecked:
            ExtractGlyph( 7, DestBmp, SourceBmp, FGlyphWidth, FGlyphHeight );

          cbGrayed:
            ExtractGlyph( 8, DestBmp, SourceBmp, FGlyphWidth, FGlyphHeight );
        end;
      end;

      Glyph.Assign( DestBmp );

    finally
      DestBmp.Free;
    end;
  end;
end; {= TRzCustomCheckBox.SelectGlyph =}



procedure TRzCustomCheckBox.CMDialogChar( var Msg: TCMDialogChar );
begin
  with Msg do
  begin
    if IsAccel( CharCode, Caption ) and CanFocus then
    begin
      Windows.SetFocus( Handle );
      if Focused and not FReadOnly then
      begin
        ChangeState;
        UpdateDisplay;
      end;
      Result := 1;
    end
    else
      inherited;
  end;
end;


procedure TRzCustomCheckBox.BMGetCheck( var Msg: TMessage );
begin
  case State of
    cbUnchecked: Msg.Result := BST_UNCHECKED;
    cbChecked:   Msg.Result := BST_CHECKED;
    cbGrayed:    Msg.Result := BST_INDETERMINATE;
  end;
end;


{&RUIF}
end.
