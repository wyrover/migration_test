�
 TDLGCASHFLOWREP 0�  TPF0TdlgCashFlowRepdlgCashFlowRepLeft�Top� BorderStylebsDialogCaptionCash Flow Report OptionsClientHeightLClientWidth�Color	clBtnFaceDefaultMonitor
dmMainForm
ParentFont	Padding.LeftPadding.TopPadding.RightOldCreateOrderPositionpoScreenCenterScaledOnCreate
FormCreate	OnDestroyFormDestroyOnShowFormShow
DesignSize�L PixelsPerInch`
TextHeight TButtonbtnOKLeftPTop#WidthKHeightAnchorsakRightakBottom Caption&PrintTabOrderOnClick
btnOKClick  TButton
btnPreviewLeftTop#WidthKHeightAnchorsakLeftakBottom CaptionPrevie&wDefault	TabOrderOnClickbtnPreviewClick  TButton	btnCancelLeft�Top#WidthKHeightAnchorsakRightakBottom Cancel	CaptionCancelTabOrder	OnClickbtnCancelClick  TButtonbtnFileLeftXTop#WidthKHeightAnchorsakLeftakBottom CaptionFil&eTabOrderOnClickbtnFileClick  TPanelpnlDivisionLeftTop� Width�Height)AlignalTopTabOrder TLabellblDivisionLeft	TopWidth$HeightCaptionDivisionFocusControlcmbDivision  	TComboBoxcmbDivisionLeft� Top	Width� HeightStylecsDropDownList
ItemHeight TabOrder    TPanelpnlCheckboxesLeftTop� Width�HeightCAlignalTopTabOrder 	TCheckBoxchkChartCodesLeft	TopWidth� HeightCaptionInclude &Chart CodesTabOrder   	TCheckBoxchkGSTLeft� TopWidth� HeightCaption&GST InclusiveTabOrder  	TCheckBoxcbPercentageLeft	Top$Width� HeightCaptionShow &% Of IncomeTabOrder   TPanel	PnlBudgetLeftTop� Width�Height)AlignalTopTabOrder TLabelLabel2Left	TopWidth"HeightCaptionBudget  	TComboBox	cmbBudgetLeft� TopWidth� HeightStylecsDropDownList
ItemHeight TabOrder    TBitBtnBtnSaveLeft� Top#WidthKHeightAnchorsakRightakBottom CaptionSa&veTabOrderOnClickBtnSaveClick  TPanelpnlDateSelectionLeftTopWidth�HeightAlignalTopTabOrder  TPanelpnlPeriodSelectionLeftTopWidth�Height$AlignalTop
BevelOuterbvNoneTabOrder Visible TLabelLabel4LeftTopWidthBHeightCaptionReport PeriodFocusControlcmbStartMonth  	TComboBoxcmbPeriodLengthLeft� Top	Width� HeightStylecsDropDownList
ItemHeight TabOrder    TPanelPanel5LeftTop%Width�HeightaAlignalTop
BevelOuterbvNoneTabOrder TLabelLabel1LeftTop+WidthDHeightCaptionReport EndingFocusControl	cmbPeriod  TLabellblLastLeft� TopFWidth� Height	AlignmenttaRightJustifyCaption*The last period of  CODED data is Dec 1998  TLabelLabel3LeftTop
WidthhHeightCaptionReporting Year StartsFocusControlcmbStartMonth  TLabellblFinancialYearStartDateLeft� Top
WidthZHeightAutoSizeCaptionlblFinancialYearStartDate  	TComboBox	cmbPeriodLeft� Top&Width� HeightStylecsOwnerDrawFixedDropDownCount
ItemHeightTabOrder
OnDrawItemcmbPeriodDrawItemItems.Strings123456789101112   	TComboBoxcmbStartMonthLeft� TopWidth]HeightStylecsDropDownList
ItemHeight TabOrder OnChangecmbStartMonthChange  TRzSpinEditspnStartYearLeft� TopWidthIHeightMax      `�
@Min      ��	@Value      @�	@TabOrderOnChangespnStartYearChange    TButtonbtnEmailLeft� Top#WidthKHeightAnchorsakLeftakBottom CaptionE&mailTabOrderOnClickbtnEmailClick  TOvcControllerOvcController1EntryCommands.TableListDefault	 WordStar Grid  EpochlLeft��  Top�    