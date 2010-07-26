{===============================================================================
  RzTray Unit

  Raize Components - Component Source Unit

  Copyright � 1995-2007 by Raize Software, Inc.  All Rights Reserved.


  Components
  ------------------------------------------------------------------------------
  TRzTrayIcon
    Nonvisual component that allows application to have an icon in the system 
    tray.


  Modification History
  ------------------------------------------------------------------------------
  3.1    (04 Aug 2005)
    * Fixed problem in TRzTrayIcon where changing the Icons property to
      reference a different image list would not cause the tray icon to be
      updated to the image of the corresponding index.
    * When setting the TRzTrayIcon.IconIndex property to -1, the application
      icon is now displayed in the system tray instead of just showing a blank
      area.
  ------------------------------------------------------------------------------
  3.0.13 (15 May 2005)
    * Fixed problem where OnRestoreApp event would get fired twice when the
      app was manually restored.
    * Fixed problem where tray icon would disappear when running on Win98 and
      other versions that did not support Shell32 v5 or higher.
    * Removed the FORM_HANDLES_TRAY_MSGS conditional symbol.  If an apps needs
      to handle the wm_QueryEndSession or wm_EndSession messages, they can
      handle the new OnQueryEndSession or OnEndSession events.
    * Added new OnQueryEndSession and OnEndSession events.  If an app is
      minimized to the system tray, then the app's main form does not receive
      the wm_QueryEndSession nor the wm_EndSession message.  These new events
      allow a tray icon app to handle these messages.
  ------------------------------------------------------------------------------
  3.0.12 (15 Dec 2004)
    * Added SupportsBalloonHints method to TRzTrayIcon. This function can be
      used to determine if BalloonHints are supported by the current operating
      system.
  ------------------------------------------------------------------------------
  3.0.11 (12 Dec 2004)
    * Removed exceptions that were raised as a result of the Shell_NotifyIcon
      function from returning an error code.  If Shell_NotifyIcon returns
      False, the Enabled property gets set to False.
    * Fixed problem where ShowBalloonHint would truncate the balloon hint text
      too short.
    * If an app is minimized to the system tray, then the app's main form does
      not receive the wm_QueryEndSession message.  This is caused by the call
      to AllocateHWnd. If a user needs to process the wm_QueryEndSession
      message, then the RzTray.pas file will need to be recompiled and the
      FORM_HANDLES_TRAY_MSGS symbol defined.  In addition, the owner form
      needs to override the WndProc method and after calling inherited, pass
      the Msg to the TRzTrayIcon.MsgWndProc method.
    * Removed 64 character check on length of hint string when setting the
      Hint property. If the Hint is longer than the length allowed by the
      operating system, then only the first N characters are used.
  ------------------------------------------------------------------------------
  3.0.8  (29 Aug 2003)
    * Fixed problem where setting Enabled to True, when the control was already
      Enabled caused an exception.
    * Animation of icons now only occurs at runtime.
    * Fixed problem where application would hang if RestoreOn was set to
      ticLeftClick and the icon was left-clicked while a popup menu was
      currently being displayed.
  ------------------------------------------------------------------------------
  3.0    (20 Dec 2002)
    * Fixed problem where setting Enabled to False still resulted in the tray
      icon data structure to be created when the component was created, and then
      turned off during loading.  Now, the tray icon data structure is not
      created until the first time the Enabled property is set to True.
    * Added the HideOnMinimize option that controls whether the button in the
      Task Bar remains visible when the main form is minimized.
    * If Windows Explorer is restarted, enabled TRzTrayIcon tray icons will be
      recreated.
    * Added new methods ShowBalloonHint and HideBalloonHint, which allows a user
      to display the BalloonHints that are available with version 5 or higher of
      the Shell32.dll.  The TRzTrayIcon also adds the following events:
      OnBalloonHintHide, OnBalloonHintClosed, and OnBalloonHintClicked;
===============================================================================}

{$I RzComps.inc}

// Typed Address checking must be turned off for this unit because two different
// record structures are passed to the Shell_NotifyIcon function:
// FIconData and FIconDataPreV5.  This is to support the new features added in
// version 5 of Shell32.dll
{$TYPEDADDRESS OFF}


unit RzTray;

interface

uses
  {$IFDEF USE_CS}
  CodeSiteLogging,
  {$ENDIF}
  Messages,
  Windows,
  Controls,
  Forms,
  Menus,
  StdCtrls,
  ExtCtrls,
  Classes,
  ShellAPI,
  Graphics,
  SysUtils,
  ImgList,
  RzCommon;

const
  wm_TrayIconMessage = wm_User + $2022;


type
  TRzBalloonHintIcon = ( bhiNone, bhiInfo, bhiWarning, bhiError);
  TRzBalloonHintTimeout = 10..30;                          // MSDN states that min = 10 seconds, max = 30 seconds

  TRzTimeoutOrVersion = record
    case Integer of              // 0: Before Win2000; 1: Win2000 and up
      0: ( uTimeout: UINT );
      1: ( uVersion: UINT );     // Only used when sending a NIM_SETVERSION message
  end;

  PRzNotifyIconDataA = ^TRzNotifyIconDataA;
  PRzNotifyIconDataW = ^TRzNotifyIconDataW;
  PNotifyIconData = PRzNotifyIconDataA;
  _RZNOTIFYICONDATAA = record
    cbSize: DWORD;
    Wnd: HWND;
    uID: UINT;
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
    szTip: array[ 0..127 ] of AnsiChar;
    dwState: DWORD;
    dwStateMask: DWORD;
    szInfo: array[ 0..255 ] of AnsiChar;
    TimeoutOrVersion: TRzTimeoutOrVersion;
    szInfoTitle: array[ 0..63 ] of AnsiChar;
    dwInfoFlags: DWORD;
  end;
  _RZNOTIFYICONDATAW = record
    cbSize: DWORD;
    Wnd: HWND;
    uID: UINT;
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
    szTip: array[ 0..63 ] of WideChar;
    dwState: DWORD;
    dwStateMask: DWORD;
    szInfo: array[ 0..255 ] of WideChar;
    TimeoutOrVersion: TRzTimeoutOrVersion;
    szInfoTitle: array[ 0..63 ] of WideChar;
    dwInfoFlags: DWORD;
  end;
  _RZNOTIFYICONDATA = _RZNOTIFYICONDATAA;
  TRzNotifyIconDataA = _RZNOTIFYICONDATAA;
  TRzNotifyIconDataW = _RZNOTIFYICONDATAW;
  TRzNotifyIconData = TRzNotifyIconDataA;
  RZNOTIFYICONDATAA = _RZNOTIFYICONDATAA;
  RZNOTIFYICONDATAW = _RZNOTIFYICONDATAW;
  RZNOTIFYICONDATA = RZNOTIFYICONDATAA;

  ERzTrayIconError = class( Exception );

  TRzTrayIconClicks = ( ticNone,
                        ticLeftClick, ticLeftDblClick, ticLeftClickUp,
                        ticRightClick, ticRightDblClick, ticRightClickUp );

  TRzQueryEndSessionEvent = procedure( Sender: TObject;
                                       var AllowSessionToEnd: Boolean ) of object;

  TRzTrayIcon = class( TComponent )
  private
    FAboutInfo: TRzAboutInfo;
    FIconData: TRzNotifyIconData;
    FIconDataPreV5: TNotifyIconData;
    FIcon: TIcon;
    FIconList: TCustomImageList;
    FImageChangeLink: TChangeLink;
    FPopupMenu: TPopupMenu;
    FTimer: TTimer;
    FHint: string;
    FIconIndex: Integer;
    FEnabled: Boolean;
    FMsgWindow: HWnd;
    FHideOnMinimize: Boolean;
    FTaskBarRecreated: Boolean;
    FMenuVisible: Boolean;
    FManualRestore: Boolean;

    FRestoreOn: TRzTrayIconClicks;
    FPopupMenuOn: TRzTrayIconClicks;

    FOnMinimizeApp: TNotifyEvent;
    FOnRestoreApp: TNotifyEvent;

    FOnLButtonDown: TNotifyEvent;
    FOnLButtonUp: TNotifyEvent;
    FOnLButtonDblClick: TNotifyEvent;
    FOnRButtonDown: TNotifyEvent;
    FOnRButtonUp: TNotifyEvent;
    FOnRButtonDblClick: TNotifyEvent;

    FShell32Ver5: Boolean;
    FOnBalloonHintHide: TNotifyEvent;
    FOnBalloonHintClose: TNotifyEvent; // Generated when the user clicks the Close button or the timeout value is reached
    FOnBalloonHintClick: TNotifyEvent;

    FOnQueryEndSession: TRzQueryEndSessionEvent;
    FOnEndSession: TNotifyEvent;

    { Internal Event Handlers }
    procedure MinimizeAppHandler( Sender: TObject );
    procedure RestoreAppHandler( Sender: TObject );
    procedure TimerExpiredHandler( Sender: TObject );
    procedure ImageListChange( Sender: TObject );
  protected
    procedure Loaded; override;
    procedure Notification( Component: TComponent;
                            Operation: TOperation ); override;
    procedure Update;
    procedure EnabledChanged;
    procedure DeleteIcon;

    { Event Dispatch Methods }
    procedure QueryEndSession( var AllowSessionToEnd: Boolean ); dynamic;
    procedure EndSession; dynamic;
    procedure LButtonDown; dynamic;
    procedure LButtonUp; dynamic;
    procedure LButtonDblClick; dynamic;
    procedure RButtonDown; dynamic;
    procedure RButtonUp; dynamic;
    procedure RButtonDblClick; dynamic;
    procedure DoMinimizeApp; dynamic;
    procedure DoRestoreApp; dynamic;

    { Property Access Methods }
    function GetAnimate: Boolean; virtual;
    procedure SetAnimate( Value: Boolean ); virtual;
    procedure SetEnabled( Value: Boolean ); virtual;
    procedure SetHint( const Value: string ); virtual;
    function GetInterval: Integer; virtual;
    procedure SetInterval( Value: Integer ); virtual;
    procedure SetIconIndex( Value: Integer ); virtual;
    procedure SetIconList( Value: TCustomImageList ); virtual;

    { Property Declarations }
    property IconData: TRzNotifyIconData
      read FIconData;

    property IconDataPreV5: TNotifyIconData
      read FIconDataPreV5;
  public
    constructor Create( AOwner: TComponent ); override;
    destructor Destroy; override;

    procedure MsgWndProc( var Msg: TMessage );

    procedure MinimizeApp;
    procedure RestoreApp;

    procedure ShowMenu;
    procedure SetDefaultIcon;

    function SupportBalloonHints: Boolean;
    procedure ShowBalloonHint( const Title: string; const Msg: string; IconType: TRzBalloonHintIcon = bhiInfo;
                               TimeoutSecs: TRzBalloonHintTimeOut = 10 );
    procedure HideBalloonHint;
  published
    property About: TRzAboutInfo
      read FAboutInfo
      write FAboutInfo
      stored False;

    property Animate: Boolean
      read GetAnimate
      write SetAnimate
      default False;

    property Enabled: Boolean
      read FEnabled
      write SetEnabled
      default True;

    property HideOnMinimize: Boolean
      read FHideOnMinimize
      write FHideOnMinimize
      default True;

    property Hint: string
      read FHint
      write SetHint;

    property PopupMenu: TPopupMenu
      read FPopupMenu
      write FPopupMenu;

    property Icons: TCustomImageList
      read FIconList
      write SetIconList;

    property IconIndex: Integer
      read FIconIndex
      write SetIconIndex
      default 0;

    property Interval: Integer
      read GetInterval
      write SetInterval
      default 1000;

    property RestoreOn: TRzTrayIconClicks
      read FRestoreOn
      write FRestoreOn
      default ticLeftDblClick;

    property PopupMenuOn: TRzTrayIconClicks
      read FPopupMenuOn
      write FPopupMenuOn
      default ticRightClickUp;

    property OnBalloonHintHide: TNotifyEvent
      read FOnBalloonHintHide
      write FOnBalloonHintHide;

    property OnBalloonHintClose: TNotifyEvent
      read FOnBalloonHintClose
      write FOnBalloonHintClose;

    property OnBalloonHintClick: TNotifyEvent
      read FOnBalloonHintClick
      write FOnBalloonHintClick;

    property OnMinimizeApp: TNotifyEvent
      read FOnMinimizeApp
      write FOnMinimizeApp;

    property OnRestoreApp: TNotifyEvent
      read FOnRestoreApp
      write FOnRestoreApp;

    property OnLButtonDown: TNotifyEvent
      read FOnLButtonDown
      write FOnLButtonDown;

    property OnLButtonUp: TNotifyEvent
      read FOnLButtonUp
      write FOnLButtonUp;

    property OnLButtonDblClick: TNotifyEvent
      read FOnLButtonDblClick
      write FOnLButtonDblClick;

    property OnRButtonDown: TNotifyEvent
      read FOnRButtonDown
      write FOnRButtonDown;

    property OnRButtonUp: TNotifyEvent
      read FOnRButtonUp
      write FOnRButtonUp;

    property OnRButtonDblClick: TNotifyEvent
      read FOnRButtonDblClick
      write FOnRButtonDblClick;

    property OnEndSession: TNotifyEvent
      read FOnEndSession
      write FOnEndSession;

    property OnQueryEndSession: TRzQueryEndSessionEvent
      read FOnQueryEndSession
      write FOnQueryEndSession;
  end;

implementation


const
  // Key select events (Space and Enter)
  NIN_SELECT           = WM_USER + 0;
  NINF_KEY             = 1;
  NIN_KEYSELECT        = NINF_KEY or NIN_SELECT;
  // Events returned by balloon hint
  NIN_BALLOONSHOW      = WM_USER + 2;
  NIN_BALLOONHIDE      = WM_USER + 3;
  NIN_BALLOONTIMEOUT   = WM_USER + 4;
  NIN_BALLOONUSERCLICK = WM_USER + 5;
  // Constants used for balloon hint feature
  NIIF_NONE            = $00000000;
  NIIF_INFO            = $00000001;
  NIIF_WARNING         = $00000002;
  NIIF_ERROR           = $00000003;
  NIIF_ICON_MASK       = $0000000F;    // Reserved for WinXP
  NIIF_NOSOUND         = $00000010;    // Reserved for WinXP
  // Additional uFlags constants for TNotifyIconDataEx
  NIF_STATE            = $00000008;
  NIF_INFO             = $00000010;
  NIF_GUID             = $00000020;
  // Additional dwMessage constants for Shell_NotifyIcon
  NIM_SETFOCUS         = $00000003;
  NIM_SETVERSION       = $00000004;
  NOTIFYICON_VERSION   = 3;            // Used with the NIM_SETVERSION message
  // Tooltip constants
  TOOLTIPS_CLASS       = 'tooltips_class32';
  TTS_NOPREFIX         = 2;


var
  wm_TaskbarCreated: DWord;

type
  _DllVersionInfo = record
    cbSize: DWORD;
    dwMajorVersion: DWORD;
    dwMinorVersion: DWORD;
    dwBuildNumber: DWORD;
    dwPlatformID: DWORD;
  end;
  DLLVERSIONINFO = _DllVersionInfo;
  TDLLVersionInfo = DLLVERSIONINFO;

var
  DLLGetVersion: function( var VI: TDLLVersionInfo ): HResult; stdcall;


function Shell32Version: Integer;
var
  VI: TDLLVersionInfo;
  ShModule: THandle;
begin
  Result := 0;
  ShModule := GetModuleHandle( ShellAPI.Shell32 );
  if ShModule <> 0 then
  begin
    @DLLGetVersion := GetProcAddress( ShModule, 'DllGetVersion' );
    if Assigned( DLLGetVersion ) then
    begin
      VI.cbSize := SizeOf( VI );
      DLLGetVersion( VI );
      Result := VI.dwMajorVersion;
    end;
  end;
end;


{&RT}
{=========================}
{== TRzTrayIcon Methods ==}
{=========================}

constructor TRzTrayIcon.Create( AOwner: TComponent );
begin
  inherited;

  FIcon := TIcon.Create;
  FTimer := TTimer.Create( nil );

  FIconIndex := 0;
  FIcon.Assign( Application.Icon );

  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := ImageListChange;

  FRestoreOn := ticLeftDblClick;
  FPopupMenuOn := ticRightClickUp;

  FHideOnMinimize := True;

  {$IFDEF VCL60_OR_HIGHER}
  // Classes prefix needed to eliminate Warning message under Delphi 6 and higher
  FMsgWindow := Classes.AllocateHWnd( MsgWndProc );
  {$ELSE}
  FMsgWindow := AllocateHWnd( MsgWndProc );
  {$ENDIF}

  FTimer.Enabled := False;
  FTimer.OnTimer := TimerExpiredHandler;
  FTimer.Interval := 1000;
  {&RCI}

  FShell32Ver5 := Shell32Version >= 5;

  if not ( csDesigning in ComponentState ) then
  begin
    if FShell32Ver5 then
    begin
      FillChar( FIConData, 0, SizeOf( TRzNotifyIconData ) );

      FIconData.cbSize := SizeOf( TRzNotifyIconData );
      FIconData.Wnd := FMsgWindow;
      FIconData.uID := Integer( Self );
      FIconData.uFlags := nif_Message or nif_Icon;
      FIconData.uCallBackMessage := wm_TrayIconMessage;
      FIconData.hIcon := FIcon.Handle;
    end
    else
    begin
      FillChar( FIConDataPreV5, 0, SizeOf( TNotifyIconData ) );

      FIconDataPreV5.cbSize := SizeOf( TNotifyIconData );
      FIconDataPreV5.Wnd := FMsgWindow;
      FIconDataPreV5.uID := Integer( Self );
      FIconDataPreV5.uFlags := nif_Message or nif_Icon;
      FIconDataPreV5.uCallBackMessage := wm_TrayIconMessage;
      FIconDataPreV5.hIcon := FIcon.Handle;
    end;

    // Replace the application's OnMinimize and OnRestore handlers with
    // special ones for the tray icon. The TRzTrayIcon component has its own
    // OnMinimizeApp and OnRestoreApp events that the user can set.
    Application.OnMinimize := MinimizeAppHandler;
    Application.OnRestore := RestoreAppHandler;
    Update;
  end;

  FEnabled := True;
end;


destructor TRzTrayIcon.Destroy;
begin
  if not ( csDesigning in ComponentState ) then
    DeleteIcon;

  {$IFDEF VCL60_OR_HIGHER}
  // Classes prefix needed to eliminate Warning message under Delphi 6 and higher
  Classes.DeallocateHWnd( FMsgWindow );
  {$ELSE}
  DeallocateHWnd( FMsgWindow );
  {$ENDIF}

  FIcon.Free;
  FTimer.Free;

  FImageChangeLink.Free;

  inherited;
end;


procedure TRzTrayIcon.Loaded;
begin
  inherited;

  if not Assigned( FIconList ) then
    FIcon.Assign( Application.Icon )
  else
    FIconList.GetIcon( FIconIndex, FIcon );

  if not ( csDesigning in ComponentState ) and FEnabled then
    EnabledChanged;

  Update;
end;


procedure TRzTrayIcon.Notification( Component: TComponent; Operation: TOperation );
begin
  inherited;
  if Operation = opRemove then
  begin
    if Component = FPopupMenu then
      FPopupMenu := nil
    else if Component = FIconList then
      SetIconList( nil );
  end;
end;


procedure TRzTrayIcon.Update;
begin
  if not ( csDesigning in ComponentState ) then
  begin
    if FShell32Ver5 then
    begin
      FIconData.hIcon := FIcon.Handle;
      Shell_NotifyIcon( nim_Modify, @FIconData );
    end
    else
    begin
      FIconDataPreV5.hIcon := FIcon.Handle;
      Shell_NotifyIcon( nim_Modify, @FIconDataPreV5 );
    end;
  end;
end;


procedure TRzTrayIcon.ShowMenu;
var
  P: TPoint;
begin
  {&RV}
  if Assigned( FPopupMenu ) then
  begin
    GetCursorPos( P );

    // Must call SetForegroundWindow for proper menu behavior
    if Owner is TForm then
      SetForegroundWindow( TForm( Owner ).Handle );
    FMenuVisible := True;
    try
      FPopupMenu.Popup( P.X, P.Y );
      PostMessage( 0, 0, 0, 0 );
    finally
      FMenuVisible := False;
    end;
  end;
end;


function TRzTrayIcon.SupportBalloonHints: Boolean;
begin
  Result := FShell32Ver5;
end;


procedure TRzTrayIcon.ShowBalloonHint( const Title: string; const Msg: string; IconType: TRzBalloonHintIcon = bhiInfo;
                                       TimeoutSecs: TRzBalloonHintTimeOut = 10 );
const
  BalloonIconTypes: array[ TRzBalloonHintIcon ] of Byte = ( NIIF_NONE, NIIF_INFO, NIIF_WARNING, NIIF_ERROR );
begin
  if FShell32Ver5 then
  begin
    // Remove old balloon hint
    HideBalloonHint;

    // Display new balloon hint
    FIconData.uFlags := nif_Info;
    StrPLCopy( FIconData.szInfo, Msg, SizeOf( FIconData.szInfo ) - 1 );
    StrPLCopy( FIconData.szInfoTitle, Title, 63 );
    FIconData.TimeoutOrVersion.uTimeout := TimeoutSecs * 1000;
    FIconData.dwInfoFlags := BalloonIconTypes[ IconType ];

    Update;

    // Remove nif_Info before next call to ModifyIcon (or the balloon hint will redisplay itself)
    FIconData.uFlags := nif_Icon or nif_Message or nif_Tip;
  end;
end;


procedure TRzTrayIcon.HideBalloonHint;
begin
  if FShell32Ver5 then
  begin
    FIconData.uFlags := FIconData.uFlags or NIF_INFO;
    StrPCopy( FIconData.szInfo, '' );
    Update;
  end;
end;


procedure TRzTrayIcon.MsgWndProc( var Msg: TMessage );
var
  AllowSessionToEnd: Boolean;
begin
  case Msg.Msg of
    wm_QueryEndSession:
    begin
      AllowSessionToEnd := True;
      QueryEndSession( AllowSessionToEnd );
      if AllowSessionToEnd then
        Msg.Result := 1
      else
        Msg.Result := 0;
    end;

    wm_EndSession:
    begin
      EndSession;
      if Msg.WParam = 1 then
        DeleteIcon;                             // Be sure to clean up tray icon
    end;

    wm_TrayIconMessage:
    begin
      case Msg.LParam of
        wm_LButtonDown:
          LButtonDown;

        wm_LButtonUp:
          LButtonUp;

        wm_LButtonDblClk:
          LButtonDblClick;

        wm_RButtonDown:
          RButtonDown;

        wm_RButtonUp:
          RButtonUp;

        wm_RButtonDblClk:
          RButtonDblClick;

        nin_BalloonShow:
        begin
          // Do nothing
        end;

        nin_BalloonHide:
        begin
          if Assigned( FOnBalloonHintHide ) then
            FOnBalloonHintHide( Self );
        end;

        nin_BalloonTimeout:
        begin
          if Assigned( FOnBalloonHintClose ) then
            FOnBalloonHintClose( Self );
        end;

        nin_BalloonUserClick:
        begin
          if Assigned( FOnBalloonHintClick ) then
            FOnBalloonHintClick( Self );
        end;

      end;
    end;
  end;

  if Msg.Msg = wm_TaskbarCreated then
  begin
    try
      // Restore only icons that were already enabled. Do not restore disabled ones.
      if Enabled then
      begin
        FTaskBarRecreated := True;
        try
          SetEnabled( True );
        finally
          FTaskBarRecreated := False;
        end;
      end;
    except
    end;
  end;

end; {= TRzTrayIcon.MsgWndProc =}


procedure TRzTrayIcon.QueryEndSession( var AllowSessionToEnd: Boolean );
begin
  if Assigned( FOnQueryEndSession ) then
    FOnQueryEndSession( Self, AllowSessionToEnd );
end;


procedure TRzTrayIcon.EndSession;
begin
  if Assigned( FOnEndSession ) then
    FOnEndSession( Self );
end;


procedure TRzTrayIcon.TimerExpiredHandler( Sender: TObject );
begin
  if ( FIconList <> nil ) and not ( csDesigning in ComponentState ) then
  begin
    if IconIndex < FIconList.Count - 1 then
      Inc( FIconIndex )
    else
      FIconIndex := 0;

    SetIconIndex( FIconIndex );
  end;
end;


procedure TRzTrayIcon.MinimizeAppHandler( Sender: TObject );
begin
  MinimizeApp;
end;


procedure TRzTrayIcon.RestoreAppHandler( Sender: TObject );
begin
  if not FManualRestore then
    RestoreApp;
end;


procedure TRzTrayIcon.DeleteIcon;
begin
  if FShell32Ver5 then
    Shell_NotifyIcon( nim_Delete, @FIconData )
  else
    Shell_NotifyIcon( nim_Delete, @FIconDataPreV5 );
end;


procedure TRzTrayIcon.DoMinimizeApp;
begin
  if Assigned( FOnMinimizeApp ) then
    FOnMinimizeApp( Self );
end;


procedure TRzTrayIcon.MinimizeApp;
begin
  Application.Minimize;
  if FEnabled and FHideOnMinimize then
    ShowWindow( Application.Handle, sw_Hide );
  DoMinimizeApp;
end;


procedure TRzTrayIcon.DoRestoreApp;
begin
  if Assigned( FOnRestoreApp ) then
    FOnRestoreApp( Self );
end;


procedure TRzTrayIcon.RestoreApp;
begin
  if FMenuVisible then
    Exit;
  FManualRestore := True;
  try
    Application.Restore;
    if FEnabled then
    begin
      ShowWindow( Application.Handle, sw_Restore );
      SetForegroundWindow( Application.Handle );
    end;
    DoRestoreApp;
  finally
    FManualRestore := False;
  end;
end;


function TRzTrayIcon.GetAnimate: Boolean;
begin
  Result := FTimer.Enabled;
end;


procedure TRzTrayIcon.SetAnimate( Value: Boolean );
begin
  FTimer.Enabled := Value;
end;


procedure TRzTrayIcon.SetHint( const Value: string );
begin
  if FHint <> Value then
  begin
    FHint := Value;
    if FShell32Ver5 then
    begin
      StrPLCopy( FIconData.szTip, Value, SizeOf( FIconData.szTip ) - 1 );

      if Value <> '' then
        FIconData.uFlags := FIconData.uFlags or nif_Tip
      else
        FIconData.uFlags := FIconData.uFlags and not nif_Tip;
    end
    else
    begin
      StrPLCopy( FIconDataPreV5.szTip, Value, SizeOf( FIconDataPreV5.szTip ) - 1 );

      if Value <> '' then
        FIconDataPreV5.uFlags := FIconDataPreV5.uFlags or nif_Tip
      else
        FIconDataPreV5.uFlags := FIconDataPreV5.uFlags and not nif_Tip;
    end;

    Update;
  end;
end;


procedure TRzTrayIcon.SetIconList( Value: TCustomImageList );
begin
  if FIconList <> nil then
    FIconList.UnRegisterChanges( FImageChangeLink );

  FIconList := Value;

  if FIconList <> nil then
  begin
    FIconList.RegisterChanges( FImageChangeLink );
    FIconList.FreeNotification( Self );
  end;
  if not ( csLoading in ComponentState ) then
    SetIconIndex( FIconIndex );
end;


procedure TRzTrayIcon.ImageListChange( Sender: TObject );
begin
  if Sender = FIconList then
    SetIconIndex( FIconIndex );
end;


function TRzTrayIcon.GetInterval: Integer;
begin
  Result := FTimer.Interval;
end;


procedure TRzTrayIcon.SetInterval( Value: Integer );
begin
  FTimer.Interval := Value;
end;


procedure TRzTrayIcon.SetEnabled( Value: Boolean );
begin
  if ( FEnabled <> Value ) or FTaskBarRecreated then
  begin
    FEnabled := Value;

    if not ( csDesigning in ComponentState ) and not ( csLoading in ComponentState ) then
      EnabledChanged;
  end;
end;


procedure TRzTrayIcon.EnabledChanged;
begin
  if FEnabled then
  begin
    if FShell32Ver5 then
    begin
      if not Shell_NotifyIcon( nim_Add, @FIconData ) then
        FEnabled := False;
    end
    else
    begin
      if not Shell_NotifyIcon( nim_Add, @FIconDataPreV5 ) then
        FEnabled := False;
    end;
    Application.OnMinimize := MinimizeAppHandler;
    Application.OnRestore := RestoreAppHandler;
  end
  else
  begin
    DeleteIcon;
  end;
end;


procedure TRzTrayIcon.SetIconIndex( Value: Integer );
begin
  FIconIndex := Value;

  if Assigned( FIconList ) and ( FIconIndex >= 0 ) and
     ( FIconIndex < FIconList.Count ) then
  begin
    FIconList.GetIcon( FIconIndex, FIcon );
  end
  else
    FIcon.Assign( Application.Icon );

  Update;
end;


procedure TRzTrayIcon.SetDefaultIcon;
begin
  FIcon.Assign( Application.Icon );
  Update;
end;


procedure TRzTrayIcon.LButtonDown;
begin
  if FRestoreOn = ticLeftClick then
    RestoreApp;
  if FPopupMenuOn = ticLeftClick then
    ShowMenu;

  if Assigned( FOnLButtonDown ) then
    FOnLButtonDown( Self );
end;


procedure TRzTrayIcon.LButtonUp;
begin
  if FRestoreOn = ticLeftClickUp then
    RestoreApp;
  if FPopupMenuOn = ticLeftClickUp then
    ShowMenu;

  if Assigned( FOnLButtonUp ) then
    FOnLButtonUp( Self );
end;


procedure TRzTrayIcon.LButtonDblClick;
begin
  if FRestoreOn = ticLeftDblClick then
    RestoreApp;
  if FPopupMenuOn = ticLeftDblClick then
    ShowMenu;

  if Assigned( FOnLButtonDblClick ) then
    FOnLButtonDblClick( Self );
end;


procedure TRzTrayIcon.RButtonDown;
begin
  if FRestoreOn = ticRightClick then
    RestoreApp;
  if FPopupMenuOn = ticRightClick then
    ShowMenu;

  if Assigned( FOnRButtonDown ) then
    FOnRButtonDown( Self );
end;


procedure TRzTrayIcon.RButtonUp;
begin
  if FRestoreOn = ticRightClickUp then
    RestoreApp;
  if FPopupMenuOn = ticRightClickUp then
    ShowMenu;

  if Assigned( FOnRButtonUp ) then
    FOnRButtonUp( Self );
end;


procedure TRzTrayIcon.RButtonDblClick;
begin
  if FRestoreOn = ticRightDblClick then
    RestoreApp;
  if FPopupMenuOn = ticRightDblClick then
    ShowMenu;

  if Assigned( FOnRButtonDblClick ) then
    FOnRButtonDblClick( Self );
end;


initialization
  wm_TaskbarCreated := RegisterWindowMessage( 'TaskbarCreated' );
  {&RUI}

end.
