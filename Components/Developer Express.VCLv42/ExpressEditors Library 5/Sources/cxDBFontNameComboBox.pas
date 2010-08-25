
{********************************************************************}
{                                                                    }
{       Developer Express Visual Component Library                   }
{       ExpressEditors                                               }
{                                                                    }
{       Copyright (c) 1998-2009 Developer Express Inc.               }
{       ALL RIGHTS RESERVED                                          }
{                                                                    }
{   The entire contents of this file is protected by U.S. and        }
{   International Copyright Laws. Unauthorized reproduction,         }
{   reverse-engineering, and distribution of all or any portion of   }
{   the code contained in this file is strictly prohibited and may   }
{   result in severe civil and criminal penalties and will be        }
{   prosecuted to the maximum extent possible under the law.         }
{                                                                    }
{   RESTRICTIONS                                                     }
{                                                                    }
{   THIS SOURCE CODE AND ALL RESULTING INTERMEDIATE FILES            }
{   (DCU, OBJ, DLL, ETC.) ARE CONFIDENTIAL AND PROPRIETARY TRADE     }
{   SECRETS OF DEVELOPER EXPRESS INC. THE REGISTERED DEVELOPER IS    }
{   LICENSED TO DISTRIBUTE THE EXPRESSEDITORS AND ALL                }
{   ACCOMPANYING VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY. }
{                                                                    }
{   THE SOURCE CODE CONTAINED WITHIN THIS FILE AND ALL RELATED       }
{   FILES OR ANY PORTION OF ITS CONTENTS SHALL AT NO TIME BE         }
{   COPIED, TRANSFERRED, SOLD, DISTRIBUTED, OR OTHERWISE MADE        }
{   AVAILABLE TO OTHER INDIVIDUALS WITHOUT EXPRESS WRITTEN CONSENT   }
{   AND PERMISSION FROM DEVELOPER EXPRESS INC.                       }
{                                                                    }
{   CONSULT THE END USER LICENSE AGREEMENT FOR INFORMATION ON        }
{   ADDITIONAL RESTRICTIONS.                                         }
{                                                                    }
{********************************************************************}

unit cxDBFontNameComboBox;

interface

{$I cxVer.inc}

uses
{$IFDEF DELPHI6}
  Variants,
{$ENDIF}
  Windows, Classes, Controls, Dialogs, Forms, Graphics, Messages, StdCtrls,
  SysUtils, cxControls, cxDBEdit, cxEdit, cxFontNameComboBox;

type
  { TcxDBFontNameComboBox }

  TcxDBFontNameComboBox = class(TcxCustomFontNameComboBox)
  private
    function GetActiveProperties: TcxFontNameComboBoxProperties;
    function GetDataBinding: TcxDBTextEditDataBinding;
    function GetProperties: TcxFontNameComboBoxProperties;
    procedure SetDataBinding(Value: TcxDBTextEditDataBinding);
    procedure SetProperties(Value: TcxFontNameComboBoxProperties);
    procedure CMGetDataLink(var Message: TMessage); message CM_GETDATALINK;
  protected
    class function GetDataBindingClass: TcxEditDataBindingClass; override;
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxFontNameComboBoxProperties
      read GetActiveProperties;
  published
    property Anchors;
    property AutoSize;
    property BeepOnEnter;
    property Constraints;
    property DataBinding: TcxDBTextEditDataBinding read GetDataBinding
      write SetDataBinding;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ImeMode;
    property ImeName;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Properties: TcxFontNameComboBoxProperties read GetProperties
      write SetProperties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditing;
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

{ TcxDBFontNameComboBox }

class function TcxDBFontNameComboBox.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxFontNameComboBoxProperties;
end;

class function TcxDBFontNameComboBox.GetDataBindingClass: TcxEditDataBindingClass;
begin
  Result := TcxDBTextEditDataBinding;
end;

function TcxDBFontNameComboBox.GetActiveProperties: TcxFontNameComboBoxProperties;
begin
  Result := TcxFontNameComboBoxProperties(InternalGetActiveProperties);
end;

function TcxDBFontNameComboBox.GetDataBinding: TcxDBTextEditDataBinding;
begin
  Result := TcxDBTextEditDataBinding(FDataBinding);
end;

function TcxDBFontNameComboBox.GetProperties: TcxFontNameComboBoxProperties;
begin
  Result := TcxFontNameComboBoxProperties(FProperties);
end;

procedure TcxDBFontNameComboBox.SetDataBinding(Value: TcxDBTextEditDataBinding);
begin
  FDataBinding.Assign(Value);
end;

procedure TcxDBFontNameComboBox.SetProperties(
  Value: TcxFontNameComboBoxProperties);
begin
  FProperties.Assign(Value);
end;

procedure TcxDBFontNameComboBox.CMGetDataLink(var Message: TMessage);
begin
  Message.Result := Integer(GetcxDBEditDataLink(Self));
end;

end.
