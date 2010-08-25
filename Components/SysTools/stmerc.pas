{*********************************************************}
{* SysTools: StMerc.pas 3.03                             *}
{* Copyright (c) TurboPower Software Co 1996, 2001       *}
{* All rights reserved.                                  *}
{*********************************************************}
{* SysTools: Astronomical Routines (for Mercury)         *}
{*********************************************************}

{$I StDefine.inc}

{$IFDEF WIN16}
  {$C MOVEABLE,DEMANDLOAD,DISCARDABLE}
{$ENDIF}

unit StMerc;

interface

uses
  StAstroP;

function ComputeMercury(JD : Double) : TStEclipticalCord;


implementation

{$IFDEF TRIALRUN}
uses
  {$IFDEF MSWINDOWS}
  Registry,
  {$ENDIF}
  {$IFDEF WIN16}
  Ver,
  {$ENDIF}
  Classes,
  Forms,
  IniFiles,
  ShellAPI,
  SysUtils,
  StTrial;
{$I TRIAL00.INC} {FIX}
{$I TRIAL01.INC} {CAB}
{$I TRIAL02.INC} {CC}
{$I TRIAL03.INC} {VC}
{$I TRIAL04.INC} {TCC}
{$I TRIAL05.INC} {TVC}
{$I TRIAL06.INC} {TCCVC}
{$ENDIF}


function GetLongitude(Tau, Tau2, Tau3, Tau4, Tau5 : Double) : Double;
var
  L0, L1,
  L2, L3,
  L4, L5   : Double;
begin
  {$IFDEF TRIALRUN} TCCVC; {$ENDIF}
  L0 := 4.40250710140 * cos(0.00000000000 +      0.00000000000 * Tau)
      + 0.40989414976 * cos(1.48302034190 +  26087.90314200000 * Tau)
      + 0.05046294199 * cos(4.47785489540 +  52175.80628300000 * Tau)
      + 0.00855346843 * cos(1.16520322350 +  78263.70942500000 * Tau)
      + 0.00165590362 * cos(4.11969163180 + 104351.61257000000 * Tau)
      + 0.00034561897 * cos(0.77930765817 + 130439.51571000000 * Tau)
      + 0.00007583476 * cos(3.71348400510 + 156527.41885000000 * Tau)
      + 0.00003559740 * cos(1.51202669420 +   1109.37855210000 * Tau)
      + 0.00001803463 * cos(4.10333178410 +   5661.33204920000 * Tau)
      + 0.00001726012 * cos(0.35832239908 + 182615.32199000000 * Tau)
      + 0.00001589923 * cos(2.99510417810 +  25028.52121100000 * Tau)
      + 0.00001364682 * cos(4.59918318740 +  27197.28169400000 * Tau)
      + 0.00001017332 * cos(0.88031439040 +  31749.23519100000 * Tau)
      + 0.00000714182 * cos(1.54144865260 +  24978.52458900000 * Tau)
      + 0.00000643759 * cos(5.30266110790 +  21535.94964400000 * Tau)
      + 0.00000451137 * cos(6.04989275290 +  51116.42435300000 * Tau)
      + 0.00000404200 * cos(3.28228847030 + 208703.22513000000 * Tau)
      + 0.00000352441 * cos(5.24156297100 +  20426.57109200000 * Tau)
      + 0.00000345212 * cos(2.79211901540 +  15874.61759500000 * Tau)
      + 0.00000343313 * cos(5.76531885340 +    955.59974161000 * Tau)
      + 0.00000339214 * cos(5.86327765000 +  25558.21217600000 * Tau)
      + 0.00000325335 * cos(1.33674334780 +  53285.18483500000 * Tau)
      + 0.00000272947 * cos(2.49451163980 +    529.69096509000 * Tau)
      + 0.00000264336 * cos(3.91705094010 +  57837.13833200000 * Tau)
      + 0.00000259587 * cos(0.98732428184 +   4551.95349710000 * Tau)
      + 0.00000238793 * cos(0.11343953378 +   1059.38193020000 * Tau)
      + 0.00000234830 * cos(0.26672118900 +  11322.66409800000 * Tau)
      + 0.00000216645 * cos(0.65987207348 +  13521.75144200000 * Tau)
      + 0.00000208995 * cos(2.09178234010 +  47623.85278600000 * Tau)
      + 0.00000183359 * cos(2.62878670780 +  27043.50288300000 * Tau)
      + 0.00000181629 * cos(2.43413502470 +  25661.30495100000 * Tau)
      + 0.00000175965 * cos(4.53636829860 +  51066.42773100000 * Tau)
      + 0.00000172643 * cos(2.45200164170 +  24498.83024600000 * Tau)
      + 0.00000142316 * cos(3.36003948840 +  37410.56724000000 * Tau)
      + 0.00000137942 * cos(0.29098447849 +  10213.28554600000 * Tau)
      + 0.00000125219 * cos(3.72079804430 +  39609.65458300000 * Tau)
      + 0.00000118233 * cos(2.78149786370 +  77204.32749400000 * Tau)
      + 0.00000106422 * cos(4.20572116250 +  19804.82729200000 * Tau);

  L1 := 26088.1470620 * cos(0.00000000000 +      0.00000000000 * Tau)
      + 0.01126007832 * cos(6.21703971000 +  26087.90314200000 * Tau)
      + 0.00303471395 * cos(3.05565472360 +  52175.80628300000 * Tau)
      + 0.00080538452 * cos(6.10454743370 +  78263.70942500000 * Tau)
      + 0.00021245035 * cos(2.83531934450 + 104351.61257000000 * Tau)
      + 0.00005592094 * cos(5.82675673330 + 130439.51571000000 * Tau)
      + 0.00001472233 * cos(2.51845458400 + 156527.41885000000 * Tau)
      + 0.00000388318 * cos(5.48039225890 + 182615.32199000000 * Tau)
      + 0.00000352244 * cos(3.05238094400 +   1109.37855210000 * Tau)
      + 0.00000102743 * cos(2.14879173780 + 208703.22513000000 * Tau)
      + 0.00000093540 * cos(6.11791163930 +  27197.28169400000 * Tau)
      + 0.00000090579 * cos(0.00045481669 +  24978.52458900000 * Tau)
      + 0.00000051941 * cos(5.62107554050 +   5661.33204920000 * Tau)
      + 0.00000044370 * cos(4.57348500460 +  25028.52121100000 * Tau)
      + 0.00000028070 * cos(3.04195430990 +  51066.42773100000 * Tau)
      + 0.00000027295 * cos(5.09210138840 + 234791.12827000000 * Tau);

  L2 := 0.00053049845 * cos(0.00000000000 +      0.00000000000 * Tau)
      + 0.00016903658 * cos(4.69072300650 +  26087.90314200000 * Tau)
      + 0.00007396711 * cos(1.34735624670 +  52175.80628300000 * Tau)
      + 0.00003018297 * cos(4.45643539700 +  78263.70942500000 * Tau)
      + 0.00001107419 * cos(1.26226537550 + 104351.61257000000 * Tau)
      + 0.00000378173 * cos(4.31998055900 + 130439.51571000000 * Tau)
      + 0.00000122998 * cos(1.06868541050 + 156527.41885000000 * Tau)
      + 0.00000038663 * cos(4.08011610180 + 182615.32199000000 * Tau)
      + 0.00000014898 * cos(4.63343085810 +   1109.37855210000 * Tau)
      + 0.00000011861 * cos(0.79187646439 + 208703.22513000000 * Tau);

  L3 := 0.00000188077 * cos(0.03466830117 +   52175.80628300000 * Tau)
      + 0.00000142152 * cos(3.12505452600 +   26087.90314200000 * Tau)
      + 0.00000096877 * cos(3.00378171920 +   78263.70942500000 * Tau)
      + 0.00000043669 * cos(6.01867965830 +  104351.61257000000 * Tau)
      + 0.00000035395 * cos(0.00000000000 +       0.00000000000 * Tau)
      + 0.00000018045 * cos(2.77538373990 +  130439.51571000000 * Tau)
      + 0.00000006971 * cos(5.81808665740 +  156527.41885000000 * Tau)
      + 0.00000002556 * cos(2.57014364450 +  182615.32199000000 * Tau);

  L4 := 0.00000114078 * cos(3.14159265360 +       0.00000000000 * Tau)
      + 0.00000003247 * cos(2.02848007620 +   26087.90314200000 * Tau)
      + 0.00000001914 * cos(1.41731803760 +   78263.70942500000 * Tau)
      + 0.00000001727 * cos(4.50137643800 +   52175.80628300000 * Tau)
      + 0.00000001237 * cos(4.49970181060 +  104351.61257000000 * Tau)
      + 0.00000000645 * cos(1.26591776990 +  130439.51571000000 * Tau);

  L5 := 0.00000000877 * cos(3.14159265360 +  0.00000000000 * Tau);
  Result := (L0 + L1*Tau + L2*Tau2 + L3*Tau3 + L4*Tau4 + L5*Tau5);
end;

{-------------------------------------------------------------------------}

function GetLatitude(Tau, Tau2, Tau3, Tau4, Tau5 : Double) : Double;
var
  B0, B1,
  B2, B3,
  B4, B5   : Double;
begin

  B0 := 0.11737528962 * cos(1.98357498770 +  26087.90314200000 * Tau)
      + 0.02388076996 * cos(5.03738959690 +  52175.80628300000 * Tau)
      + 0.01222839532 * cos(3.14159265360 +      0.00000000000 * Tau)
      + 0.00543251810 * cos(1.79644363960 +  78263.70942500000 * Tau)
      + 0.00129778770 * cos(4.83232503960 + 104351.61257000000 * Tau)
      + 0.00031866927 * cos(1.58088495670 + 130439.51571000000 * Tau)
      + 0.00007963301 * cos(4.60972126350 + 156527.41885000000 * Tau)
      + 0.00002014189 * cos(1.35324164690 + 182615.32199000000 * Tau)
      + 0.00000513953 * cos(4.37835409310 + 208703.22513000000 * Tau)
      + 0.00000208584 * cos(2.02020294150 +  24978.52458900000 * Tau)
      + 0.00000207674 * cos(4.91772564070 +  27197.28169400000 * Tau)
      + 0.00000132013 * cos(1.11908492280 + 234791.12827000000 * Tau)
      + 0.00000121395 * cos(1.81271752060 +  53285.18483500000 * Tau)
      + 0.00000100454 * cos(5.65684734210 +  20426.57109200000 * Tau);

  B1 := 0.00429151362 * cos(3.50169780390 +  26087.90314200000 * Tau)
      + 0.00146233668 * cos(3.14159265360 +      0.00000000000 * Tau)
      + 0.00022675295 * cos(0.01515366880 +  52175.80628300000 * Tau)
      + 0.00010894981 * cos(0.48540174006 +  78263.70942500000 * Tau)
      + 0.00006353462 * cos(3.42943919980 + 104351.61257000000 * Tau)
      + 0.00002495743 * cos(0.16051210665 + 130439.51571000000 * Tau)
      + 0.00000859585 * cos(3.18452433650 + 156527.41885000000 * Tau)
      + 0.00000277503 * cos(6.21020774180 + 182615.32199000000 * Tau)
      + 0.00000086233 * cos(2.95244391820 + 208703.22513000000 * Tau)
      + 0.00000027696 * cos(0.29068938889 +  27197.28169400000 * Tau)
      + 0.00000026133 * cos(5.97708962690 + 234791.12827000000 * Tau);

  B2 := 0.00011830934 * cos(4.79065585780 +  26087.90314200000 * Tau)
      + 0.00001913516 * cos(0.00000000000 +      0.00000000000 * Tau)
      + 0.00001044801 * cos(1.21216540540 +  52175.80628300000 * Tau)
      + 0.00000266213 * cos(4.43418336530 +  78263.70942500000 * Tau)
      + 0.00000170280 * cos(1.62255638710 + 104351.61257000000 * Tau)
      + 0.00000096300 * cos(4.80023692020 + 130439.51571000000 * Tau)
      + 0.00000044692 * cos(1.60758267770 + 156527.41885000000 * Tau)
      + 0.00000018316 * cos(4.66904655380 + 182615.32199000000 * Tau)
      + 0.00000006927 * cos(1.43404888930 + 208703.22513000000 * Tau);

  B3 := 0.00000235423 * cos(0.35387524604 +  26087.90314200000 * Tau)
      + 0.00000160537 * cos(0.00000000000 +      0.00000000000 * Tau)
      + 0.00000018904 * cos(4.36275460260 +  52175.80628300000 * Tau)
      + 0.00000006376 * cos(2.50715381440 +  78263.70942500000 * Tau)
      + 0.00000004580 * cos(6.14257817570 + 104351.61257000000 * Tau)
      + 0.00000003061 * cos(3.12497552680 + 130439.51571000000 * Tau)
      + 0.00000001732 * cos(6.26642412060 + 156527.41885000000 * Tau);

  B4 := 0.00000004276 * cos(1.74579932120 +  26087.90314200000 * Tau)
      + 0.00000001023 * cos(3.14159265360 +      0.00000000000 * Tau);

  B5 := 0.00000000000 * cos(0.00000000000 +      0.00000000000 * Tau);
  Result := (B0 + B1*Tau + B2*Tau2 + B3*Tau3 + B4*Tau4 + B5*Tau5);
end;

{-------------------------------------------------------------------------}

function GetRadiusVector(Tau, Tau2, Tau3, Tau4, Tau5 : Double) : Double;
var
  R0, R1,
  R2, R3,
  R4, R5  : Double;
begin
  R0 := 0.39528271652 * cos(0.00000000000 +      0.00000000000 * Tau)
      + 0.07834131817 * cos(6.19233722600 +  26087.90314200000 * Tau)
      + 0.00795525557 * cos(2.95989690100 +  52175.80628300000 * Tau)
      + 0.00121281763 * cos(6.01064153810 +  78263.70942500000 * Tau)
      + 0.00021921969 * cos(2.77820093970 + 104351.61257000000 * Tau)
      + 0.00004354065 * cos(5.82894543260 + 130439.51571000000 * Tau)
      + 0.00000918228 * cos(2.59650562600 + 156527.41885000000 * Tau)
      + 0.00000289955 * cos(1.42441936950 +  25028.52121100000 * Tau)
      + 0.00000260033 * cos(3.02817753480 +  27197.28169400000 * Tau)
      + 0.00000201855 * cos(5.64725040350 + 182615.32199000000 * Tau)
      + 0.00000201499 * cos(5.59227724200 +  31749.23519100000 * Tau)
      + 0.00000141980 * cos(6.25264202640 +  24978.52458900000 * Tau)
      + 0.00000100144 * cos(3.73435608690 +  21535.94964400000 * Tau);

  R1 := 0.00217347739 * cos(4.65617158660 +  26087.90314200000 * Tau)
      + 0.00044141826 * cos(1.42385543980 +  52175.80628300000 * Tau)
      + 0.00010094479 * cos(4.47466326320 +  78263.70942500000 * Tau)
      + 0.00002432804 * cos(1.24226083430 + 104351.61257000000 * Tau)
      + 0.00001624367 * cos(0.00000000000 +      0.00000000000 * Tau)
      + 0.00000603996 * cos(4.29303116560 + 130439.51571000000 * Tau)
      + 0.00000152851 * cos(1.06060779810 + 156527.41885000000 * Tau)
      + 0.00000039202 * cos(4.11136751420 + 182615.32199000000 * Tau);

  R2 := 0.00003117867 * cos(3.08231840300 +  26087.90314200000 * Tau)
      + 0.00001245396 * cos(6.15183317420 +  52175.80628300000 * Tau)
      + 0.00000424822 * cos(2.92583352960 +  78263.70942500000 * Tau)
      + 0.00000136130 * cos(5.97983925840 + 104351.61257000000 * Tau)
      + 0.00000042175 * cos(2.74936980630 + 130439.51571000000 * Tau)
      + 0.00000021759 * cos(3.14159265360 +      0.00000000000 * Tau)
      + 0.00000012793 * cos(5.80143162210 + 156527.41885000000 * Tau);

  R3 := 0.00000032676 * cos(1.67971635360 +  26087.90314200000 * Tau)
      + 0.00000024166 * cos(4.63403169000 +  52175.80628300000 * Tau)
      + 0.00000012133 * cos(1.38983781540 +  78263.70942500000 * Tau)
      + 0.00000005140 * cos(4.43915386930 + 104351.61257000000 * Tau)
      + 0.00000001981 * cos(1.20733880270 + 130439.51571000000 * Tau);

  R4 := 0.00000000000;

  R5 := 0.00000000000;
  Result := (R0 + R1*Tau + R2*Tau2 + R3*Tau3 + R4*Tau4 + R5*Tau5);
end;

{---------------------------------------------------------------------------}

function ComputeMercury(JD : Double) : TStEclipticalCord;
var
  Tau,
  Tau2,
  Tau3,
  Tau4,
  Tau5      : Double;
begin
  Tau  := (JD - 2451545.0) / 365250.0;
  Tau2 := sqr(Tau);
  Tau3 := Tau * Tau2;
  Tau4 := sqr(Tau2);
  Tau5 := Tau2 * Tau3;

  Result.L0 := GetLongitude(Tau, Tau2, Tau3, Tau4, Tau5);
  Result.B0 := GetLatitude(Tau, Tau2, Tau3, Tau4, Tau5);
  Result.R0 := GetRadiusVector(Tau, Tau2, Tau3, Tau4, Tau5);
end;


end.