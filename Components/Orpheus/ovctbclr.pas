{*********************************************************}
{*                  OVCTBCLR.PAS 4.05                    *}
{*     COPYRIGHT (C) 1995-2002 TurboPower Software Co    *}
{*                 All rights reserved.                  *}
{*********************************************************}

{$I OVC.INC}

{$B-} {Complete Boolean Evaluation}
{$I+} {Input/Output-Checking}
{$P+} {Open Parameters}
{$T-} {Typed @ Operator}
{.W-} {Windows Stack Frame}                                          {!!.02}
{$X+} {Extended Syntax}

unit ovctbclr;
  {-Orpheus table colors}

interface

uses
  Graphics, Classes;

type
  TOvcTableColors = class(TPersistent)
    protected {private}
      {.Z+}
      FLocked              : TColor;
      FLockedText          : TColor;
      FActiveFocused       : TColor;
      FActiveFocusedText   : TColor;
      FActiveUnfocused     : TColor;
      FActiveUnfocusedText : TColor;
      FEditing             : TColor;
      FEditingText         : TColor;
      FSelected            : TColor;
      FSelectedText        : TColor;

      FOnCfgChanged        : TNotifyEvent;
      {.Z-}

    protected
      {.Z+}
      procedure SetLocked(C : TColor);
      procedure SetLockedText(C : TColor);
      procedure SetActiveFocused(C : TColor);
      procedure SetActiveFocusedText(C : TColor);
      procedure SetActiveUnfocused(C : TColor);
      procedure SetActiveUnfocusedText(C : TColor);
      procedure SetEditing(C : TColor);
      procedure SetEditingText(C : TColor);
      procedure SetSelected(C : TColor);
      procedure SetSelectedText(C : TColor);

      procedure DoCfgChanged;
      {.Z-}

    public {protected}
      {.Z+}
      property OnCfgChanged : TNotifyEvent
         read FOnCfgChanged write FOnCfgChanged;
      {.Z-}

    public
      constructor Create;
      procedure Assign(Source : TPersistent); override;

    published
      {properties}
      property ActiveFocused : TColor
         read FActiveFocused write SetActiveFocused
           default clHighlight;                                       {!!.05}

      property ActiveFocusedText : TColor
         read FActiveFocusedText write SetActiveFocusedText
           default clHighlightText;                                   {!!.05}

      property ActiveUnfocused : TColor
         read FActiveUnfocused write SetActiveUnfocused
           default clHighlight;                                       {!!.05}

      property ActiveUnfocusedText : TColor
         read FActiveUnfocusedText write SetActiveUnfocusedText
           default clHighlightText;                                   {!!.05}

      property Locked : TColor
         read FLocked write SetLocked
           default clBtnFace;                                         {!!.05}

      property LockedText : TColor
         read FLockedText write SetLockedText
           default clWindowText;                                      {!!.05}

      property Editing : TColor
         read FEditing write SetEditing
           default clBtnFace;                                         {!!.05}

      property EditingText : TColor
         read FEditingText write SetEditingText
           default clWindowText;                                      {!!.05}

      property Selected : TColor
         read FSelected write SetSelected
           default clHighlight;                                       {!!.05}

      property SelectedText : TColor
         read FSelectedText write SetSelectedText
           default clHighlightText;                                   {!!.05}
    end;

implementation


{===TOvcTableColors==================================================}
constructor TOvcTableColors.Create;
  begin
    FLocked := clBtnFace;
    FLockedText := clWindowText;
    FActiveFocused := clHighlight;
    FActiveFocusedText := clHighlightText;
    FActiveUnfocused := clHighlight;
    FActiveUnfocusedText := clHighlightText;
    FEditing := clBtnFace;
    FEditingText := clWindowText;
    FSelected := clHighlight;
    FSelectedText := clHighlightText;
  end;
{--------}
procedure TOvcTableColors.Assign(Source : TPersistent);
  begin
    if (Source is TOvcTableColors) then
      begin
        FLocked := TOvcTableColors(Source).Locked;
        FLockedText := TOvcTableColors(Source).LockedText;
        FActiveFocused := TOvcTableColors(Source).ActiveFocused;
        FActiveFocusedText := TOvcTableColors(Source).ActiveFocusedText;
        FActiveUnfocused := TOvcTableColors(Source).ActiveUnfocused;
        FActiveUnfocusedText := TOvcTableColors(Source).ActiveUnfocusedText;
        FEditing := TOvcTableColors(Source).Editing;
        FEditingText := TOvcTableColors(Source).EditingText;
        FSelected := TOvcTableColors(Source).Selected;
        FSelectedText := TOvcTableColors(Source).SelectedText;
        DoCfgChanged;
      end;
  end;
{--------}
procedure TOvcTableColors.DoCfgChanged;
  begin
    if Assigned(FOnCfgChanged) then
      FOnCfgChanged(Self);
  end;
{--------}
procedure TOvcTableColors.SetActiveFocused(C : TColor);
  begin
    if (C <> FActiveFocused) then
      begin
        FActiveFocused := C;
        DoCfgChanged;
      end;
  end;
{--------}
procedure TOvcTableColors.SetActiveFocusedText(C : TColor);
  begin
    if (C <> FActiveFocusedText) then
      begin
        FActiveFocusedText := C;
        DoCfgChanged;
      end;
  end;
{--------}
procedure TOvcTableColors.SetActiveUnfocused(C : TColor);
  begin
    if (C <> FActiveUnfocused) then
      begin
        FActiveUnfocused := C;
        DoCfgChanged;
      end;
  end;
{--------}
procedure TOvcTableColors.SetActiveUnfocusedText(C : TColor);
  begin
    if (C <> FActiveUnfocusedText) then
      begin
        FActiveUnfocusedText := C;
        DoCfgChanged;
      end;
  end;
{--------}
procedure TOvcTableColors.SetEditing(C : TColor);
  begin
    if (C <> FEditing) then
      begin
        FEditing := C;
        DoCfgChanged;
      end;
  end;
{--------}
procedure TOvcTableColors.SetEditingText(C : TColor);
  begin
    if (C <> FEditingText) then
      begin
        FEditingText := C;
        DoCfgChanged;
      end;
  end;
{--------}
procedure TOvcTableColors.SetLocked(C : TColor);
  begin
    if (C <> FLocked) then
      begin
        FLocked := C;
        DoCfgChanged;
      end;
  end;
{--------}
procedure TOvcTableColors.SetLockedText(C : TColor);
  begin
    if (C <> FLockedText) then
      begin
        FLockedText := C;
        DoCfgChanged;
      end;
  end;
{--------}
procedure TOvcTableColors.SetSelected(C : TColor);
  begin
    if (C <> FSelected) then
      begin
        FSelected := C;
        DoCfgChanged;
      end;
  end;
{--------}
procedure TOvcTableColors.SetSelectedText(C : TColor);
  begin
    if (C <> FSelectedText) then
      begin
        FSelectedText := C;
        DoCfgChanged;
      end;
  end;
{====================================================================}

end.
