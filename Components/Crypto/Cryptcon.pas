unit Cryptcon;
{*****************************************************************************
 UNIT: Cryptcon
 Description:  This unit contains an Object Pascal Object which can be used as
               a base class for constructing Encryption Objects for BLOCK
               Ciphers.  This contains all the necessary fields/methods for
               doing encryption.  In most cases all that a user of this base class
               will need to do is override the EncipherBLOCK/DecipherBLOCK and
               SetKeys(generate SubKeys) methods.  It handles things such as
               File encryption, Byte Array encryption, different modes of
               operation(CBC, ECB, CFB).
 -----------------------------------------------------------------------------
 Code Author:  Greg Carter, gregc@cryptocard.com
 Organization: CRYPTOCard Corporation, info@cryptocard.com
               R&D Division, Carleton Place, ON, CANADA, K7C 3T2
               1-613-253-3152 Voice, 1-613-253-4685 Fax.
 Date of V.1:  Jan. 30 1996.

 Compatibility & Testing with BP7.0: Marcel Roorda, garfield@xs4all.nl
 -----------------------------------------------------------------------------}
{Usage:  See one of the included algorithm implementations, TRC5, TBLOWFISH,
         TIDEA to see how to inherite and use this base class.
{-----------------------------------------------------------------------------}
{LEGAL:        This code is placed into the public domain, hence requires
               no license or runtime fees.  However this code is copyright by
               CRYPTOCard.  CRYPTOCard grants anyone who may wish to use, modify
               or redistribute this code privileges to do so, provided the user
               agrees to the following three(3) rules:

               1)Any Applications, (ie exes which make use of this
               Object...), for-profit or non-profit,
               must acknowledge the author of this Object(ie.
               MD5 Implementation provided by Greg Carter, CRYPTOCard
               Corporation) somewhere in the accompanying Application
               documentation(ie AboutBox, HelpFile, readme...).  NO runtime
               or licensing fees are required!

               2)Any Developer Component(ie Delphi Component, Visual Basic VBX,
               DLL) derived from this software must acknowledge that it is
               derived from "Crypto Object Pascal Implementation Originated by
               Greg Carter, CRYPTOCard Corporation 1996". Also all efforts should
               be made to point out any changes from the original.
               !!!!!Further, any Developer Components based on this code
               *MAY NOT* be sold for profit.  This Object was placed into the
               public domain, and therefore any derived components should
               also.!!!!!

               3)CRYPTOCard Corporation makes no representations concerning this
               software or the suitability of this software for any particular
               purpose. It is provided "as is" without express or implied
               warranty of any kind. CRYPTOCard accepts no liability from any
               loss or damage as a result of using this software.

-----------------------------------------------------------------------------
Why Use this instead of a freely available C DLL?

The goal was to provide a number of Encryption/Hash implementations in Object
Pascal, so that the Pascal Developer has considerably more freedom.  These
Implementations are geared toward the PC(Intel) Microsoft Windows developer,
who will be using Borland's New 32bit developement environment(Delphi32).  The
code generated by this new compiler is considerablely faster then 16bit versions.
And should provide the Developer with faster implementations then those using
C DLLs.
-----------------------------------------------------------------------------
NOTES:
------------------------------------------------------------------------------
Revised:  00/00/00 BY: ******* Reason: ******
          Nov 97       Matthew Hopkins       Removed condition compile options
                                             for bp7 and delphi16
          Jan 2000     Andrew Bell           UWORD_32bits = LongWord;  
                                             Changed from LongInt
------------------------------------------------------------------------------
}

{Declare the compiler defines}
{$I CRYPTDEF.INC}
{------Changeable compiler switches-----------------------------------}
{$A+   Word align variables }
{$F+   Force Far calls }
{$K+   Use smart callbacks
{$N+}
{$E+}
{$P+   Open parameters enabled }
{$S+   Stack checking }
{$T-   @ operator is NOT typed }
{$U-   Non Pentium safe FDIV }
{$Z-   No automatic word-sized enumerations}
{---------------------------------------------------------------------}
interface
uses Windows,Classes,Controls,sysutils;

type
 {An enumerated typt which tells the object what type the input to the cipher is}
 TSourceType = (SourceFile, SourceByteArray,SourceString);
 {Different modes of cipher operation}
 TCipherMode = (ECBMode, CBCMode, CFBMode);

 UWORD_32bits = LongWord;  {Changed from LongInt - ADB 01/2000}
 UWORD_16bits = WORD;
 UBYTE_08bits = BYTE;

 BArray  = array[0..7] of BYTE;
 PByte   = ^Byte;
 PArray  = ^BArray;
 LArray  = array[0..1] of UWORD_32bits;
 PLong   = ^UWORD_32bits;
 PLArray = ^LArray;

 {Motorola}
 {$IFDEF ORDER_ABCD}
   singleBytes = Record
          byte0: BYTE; {MSB}
          byte1: BYTE;
          byte2: BYTE;
          byte3: BYTE; {LSB}
   end;{SingleBytes}
 {$DEFINE MAC}
 {$ENDIF}

{Intelx86}
{$IFDEF ORDER_DCBA}
   singleBytes = Record
          byte3: BYTE; {LSB}
          byte2: BYTE;
          byte1: BYTE;
          byte0: BYTE; {MSB}
   end;{SingleBytes}
{$DEFINE INTEL}
{$ENDIF}

{VAX, anyone using Pascal on the Vax???}
{$IFDEF ORDER_BADC}
   singleBytes = Record
          byte1: BYTE;
          byte0: BYTE;
          byte3: BYTE;
          byte2: BYTE;
   end;{SingleBytes}
 {$ENDIF}

 aword = record
  case Integer Of
   0: (LWord: UWORD_32bits);
   1: (fByte: Array[0..3] of UBYTE_08bits);
   2: (w: singleBytes);
 end;{aword, 32bits!}

 Paword = ^aword;
{------------------------------------------------------------------------------}
{TCrypto Object:  TCrypto Object descends from the base class(of you respestive
                  compiler(TComponent for Delphi, TObject for BP7).  It is a
                  basic 'container' to hold all the input/output information to
                  an encryption routine.

                  When using a cipher in CBC or CFB mode the cipher needs an
                  initialization vector(IV).  The user can either supply an
                  IV vector, by assigning a string value(which MUST be the
                  same length as block of the cipher) to the FIVector field, or
                  have an IVector generated for them.  If the user chooses to have
                  the IVector generated(Do not assign it anything), then upon
                  completion of the current encryption, the FIVector field
                  will hold the IV vector used.  You need to keep a copy of the
                  IV vector used to encrypt, in order to decrypt anything.  It is
                  not necessary to keep this value secret.

                  A destructor fills the Objects copy of the User Key with
                  zeros on exit for security reasons.

                  'Protected' Fields under Delphi are accessible to desendents of
                  the inherited object, but not to users of the desendent
                  objects.
-------------------------------------------------------------------------------}

TCrypto = class(TComponent)
 Protected
{ Protected declarations }
  FIVector: String;  {Initial IVector MUST be as long as FBLOCKSIZE}
  FIVTemp:  PArray;  {IVector during cipher}
  FKey: String;      {Local Copy of User Key}
  FInputType:  TSourceType;{SourceString, SourceByteArray, SourceFile}
  FCipherMode: TCipherMode;{ECBMode, CBCMode, CFBMode}
  FInputFilePath:  String; {Path to input file}
  FOutputFilePath: String; {Path to output file}
  FInputArray:  PArray;    {Pointer to input array}
  FOutputArray: PArray;    {Output Array}
  FInputString: String;    {Pascal String to Encipher}
  FInputLength: WORD;      {16bit Unsigned Length of ByteArray}
  FBuffer:      array[0..4096] of BYTE; {Local Copy of Data}
  FSmallBuffer: array[0..63]   of BYTE;
  FDoneFile:  Boolean;     {Signal reading of file or array is done}
  FBLOCKSIZE: BYTE;        {MUST be initialized in Constructor}
  Procedure ShiftLeft(pIV, pNewData: PByte; Pos: WORD);
  function  MIN(Aparam, Bparam: integer): integer;
  Procedure GenIVector;    {generates a psedo random IVector}
  Procedure InitIV;
  Procedure StartCipher(Continue: Boolean);
  Procedure EncipherBLOCK; virtual;abstract;
  Procedure DecipherBLOCK; virtual;abstract;
 {do any SubKey generation or initialization here}
  Procedure SetKeys;virtual;abstract;
  Procedure Encipher_File;
  Procedure Decipher_File;
  Procedure Encipher_Bytes;virtual;
  Procedure Decipher_Bytes;virtual;
{Different modes for Block Ciphers}
  Procedure EncipherECB;
  Procedure DecipherECB;
  Procedure EncipherCFB;
  Procedure DecipherCFB;
  Procedure EncipherCBC;
  Procedure DecipherCBC;

 public
{ Public declarations }
  Procedure DecipherData(Continue: Boolean);  {Users call these to perform}
  Procedure EncipherData(Continue: Boolean);  {Encryption/Decryption}
  {Continue is used for CBC and CFB Modes, where the encryption procedure
   needs to know whether to generate a new Initialization Vector, or use the
   one generated in the last round of the previous encryption}
  {constructor Create(Owner: TComponent);override;}
  destructor  Destroy;override;
  Property pInputArray:  PArray read FInputArray  write FInputArray;
  Property pOutputArray: PArray read FOutputArray write FOutputArray;{!!See FOutputArray}
 published
{Published properties show up in the object inspector}
  Property Key: String write FKey Stored False;
  Property InputType:  TSourceType read FInputType      write FInputType;
  Property InputFilePath:   String read FInputFilePath  write FInputFilePath;
  Property OutputFilePath:  String read FOutputFilePath write FOutputFilePath;
  Property InputString:     String read FInputString    write FInputString;
  Property InputLength:       WORD read FInputLength    write FInputLength;
  Property CipherMode: TCipherMode read FCipherMode     write FCipherMode;
  Property IVector:         String read FIVector        write FIVector Stored False;
end;{TCrypto}

implementation


destructor TCrypto.Destroy;
  var i: integer;
  begin
   If FIVTemp <> nil then begin
      FreeMem(FIVTemp, FBLOCKSIZE);
   end;
   for i := 1 to Length(FKey) do begin
    FKey[i] := #0;
   end;
  inherited Destroy;
  end;{destructor}

{=======================Misc. Methods=========================================}
function TCrypto.MIN(Aparam, Bparam: integer): integer;
begin
 if Aparam > Bparam then
  MIN := Bparam
 else
  MIN := Aparam;
end;

Procedure TCrypto.ShiftLeft(pIV, pNewData: PByte; Pos: WORD);
{Used in CFB Mode}
var
 TempPtr: PByte;
 i: BYTE;
begin
{$WARN OFF}
 TempPtr := pIV; Inc(TempPtr, Pos);
 For i:= 1 To (FBLOCKSIZE - Pos) do
  pIV^ := TempPtr^; Inc(pIV); Inc(TempPtr);
 repeat
  pIV^ := pNewData^; Inc(pIV); Inc(pNewData);
  Dec(Pos);
 Until Pos = 0;
{$WARN ON}
end;{TCrypto.ShiftLeft}

Procedure TCrypto.GenIVector;
var
 i: WORD;
begin
 Randomize;
 FIVector := '';
 For i:= 1 to FBLOCKSIZE do begin
   FIVector := FIVector + Chr(BYTE(Random(93) + 33));
   {add 33 so all in ascii printable range}
 end;
end;

Procedure TCrypto.InitIV;
begin
 {If the user wishes to supply an IV vector then let them, otherwise we
 generate one, and put it in FIVector, so that they can see it, also put
 IV in FIVTemp, which is used during the cipher routines}
 If FIVector = '' then
    GenIVector;
 if FIVTemp = nil then
    GetMem(FIVTemp, FBLOCKSIZE);
 Move(FIVector[1], FIVTemp^, FBLOCKSIZE);
end;

Procedure TCrypto.StartCipher(Continue: Boolean);
begin
if Not Continue then begin
 SetKeys;
 Case FCipherMode of
  ECBMode:
   begin
   end;
  CBCMode:
   begin
    InitIV;
   end;
  CFBMode:
   begin
    InitIV;
   end;
 end;{Case}
end;{if}
end;{TCrypto.StartCipher}

{==================Main Entry Public Methods==================================}
Procedure TCrypto.EncipherData(Continue: Boolean);
{Public/Protected Procedure used to encipher data}
var
pStr: PChar;
 begin
   StartCipher(Continue);
   case FInputType of
    SourceFile:
    begin
     Encipher_File;
    end;
    SourceByteArray:
    begin
     {Check Length!!!!}
     Move(FInputArray^, FBuffer, FInputLength);
     Encipher_Bytes;
    end;
    SourceString:
   begin
    {Convert Pascal String to Byte Array}
    pStr := StrAlloc(Length(FInputString) + 1);
    try {protect dyanmic memory allocation}
    StrPCopy(pStr, FInputString);
    FInputLength := Length(FInputString);
    FInputArray := Pointer(pStr);
    {Check Length!!!!}
    Move(FInputArray^, FBuffer, FInputLength);
    Encipher_Bytes;
    finally
     StrDispose(pStr);
    end;
   end;{SourceString}
   end;{case}
end;{TCrypto.EncipherData}

Procedure TCrypto.DecipherData(Continue: Boolean);
{Public/Proctected Procedure used to Decipher data}
 begin
   StartCipher(Continue);
   case FInputType of
    SourceFile:
    begin
     Decipher_File;
    end;
    SourceByteArray:
    begin
    {Check Length!!!!}
     Move(FInputArray^, FBuffer, FInputLength);
     Decipher_Bytes;
    end;
    SourceString:
    begin
    {FIXME: Error, can't decipher input as Pascal string}
    end;{SourceString}
   end;{case}
end;{TCrypto.DecipherData}

{=========================Data handling Methods===============================}
Procedure TCrypto.Encipher_Bytes;
begin
    Case FCipherMode of
     ECBMode:
      EncipherECB;
     CBCMode:
      EncipherCBC;
     CFBMode:
      EncipherCFB;
    end;{Case}
end;

Procedure TCrypto.Encipher_File;
var
  InputFile, OutputFile: File;
  NumWrite, NumRead: integer;
  DoneFile: Boolean;
begin
 DoneFile := False;

 AssignFile(InputFile, FInputFilePath);
 Reset(InputFile, 1);
 NumWrite := FileCreate(FOutputFilePath);
 FileClose(NumWrite);
 AssignFile(OutputFile, FOutputFilePath);
 Reset(OutputFile, 1);
 repeat
    BlockRead(InputFile,FBuffer,4096, NumRead{FInputLength});
    FInputLength := NumRead;
    if FInputLength<>4096 then DoneFile := True;
    {Call Encipher_Bytes to handle the actual encryption}
    FInputArray := @FBuffer;
    FOutputArray := @FBuffer;
    Encipher_Bytes;
    {Case FCipherMode of
     ECBMode:
      EncipherECB;
     CBCMode:
      EncipherCBC;
     CFBMode:
      EncipherCFB;
    end;{Case}
    {Put in OutputFile}
    BlockWrite(OutputFile,FBuffer, FInputLength,NumWrite);
    {Should signal a disk full error when numwrite<>FInputLength}
  until DoneFile or (NumWrite <> FInputLength);

  CloseFile(InputFile);
  CloseFile(OutputFile);
{  FInputLength := TotalRead;}
end;{TCrypto.Encipher_File}

Procedure TCrypto.Decipher_Bytes;
begin
    Case FCipherMode of {keep in this order for compiler optimization}
     ECBMode:
      DecipherECB;
     CBCMode:
      DecipherCBC;
     CFBMode:
      DecipherCFB;
    end;{Case}
end;{TCrypto.Decipher_Bytes}

Procedure TCrypto.Decipher_File;
var
  InputFile, OutputFile: File;
  NumWrite, NumRead:integer ;
  DoneFile: Boolean;
begin
 DoneFile := False;

 AssignFile(InputFile, FInputFilePath);
 Reset(InputFile, 1);
 NumWrite := FileCreate(FOutputFilePath);
 FileClose(NumWrite);
 AssignFile(OutputFile, FOutputFilePath);
 Reset(OutputFile, 1);

 repeat
    BlockRead(InputFile,FBuffer,4096, NumRead{FInputLength});
    FInputLength := NumRead;
    if FInputLength<>4096 then DoneFile := True;
    FInputArray := @FBuffer;
    FOutputArray := @FBuffer;
    Decipher_Bytes;
    {Put in OutputFile}
    BlockWrite(OutputFile,FBuffer, FInputLength,NumWrite);
    {Should signal a disk full error when numwrite<>FInputLength}
 until DoneFile or (NumWrite <> FInputLength);

  CloseFile(InputFile);
  CloseFile(OutputFile);
{  FInputLength := TotalRead;}
end;{TCrypto.Decipher_File}

{===========================Cipher Mode Methods===============================}
Procedure TCrypto.EncipherCFB;
var
 i: WORD;
 WhatsLeft, Index: Longint;
 pOut: PByte;
 curSize : BYTE;
begin
  WhatsLeft := FInputLength;
  curSize   := MIN(FBLOCKSIZE, WhatsLeft);
  pOut      := PByte(FOutputArray);    {get pointer to users outputarray}
  Index := 0;
  while (curSize > 0) do begin
    Move(FIVTemp^, FSmallBuffer, FBLOCKSIZE);
    EncipherBLOCK;
    For i:= 0 to (curSize - 1) do begin
     PArray(pOut)^[i] := FBuffer[Index + i] Xor FSmallBuffer[i];
    end;
    If curSize = FBLOCKSIZE then
       Move(pOut^, FIVTemp^, FBLOCKSIZE)
    else
       ShiftLeft(Pointer(FIVTemp), Pointer(pOut), curSize);
    Dec(WhatsLeft, curSize);
    Inc(pOut,  curSize);
    Inc(Index, curSize);
    curSize:= MIN(FBLOCKSIZE, WhatsLeft);
 end;{while}
end;{TCrypto.EncipherCFB}

Procedure TCrypto.DecipherCFB;
var
 i: WORD;
 WhatsLeft, Index: Longint;
 pOut: PByte;
 curSize : BYTE;
begin
  WhatsLeft := FInputLength;
  curSize   := MIN(FBLOCKSIZE, WhatsLeft);
  pOut   := PByte(FOutputArray);   {save pointer to users outputarray}
  Index := 0;
  while (curSize > 0) do begin
    Move(FIVTemp^, FSmallBuffer, FBLOCKSIZE);
    EncipherBLOCK;
    {Put Cipher Text in Feeback Register, IVTemp}
    If curSize = FBLOCKSIZE then
       Move(FBuffer[Index], FIVTemp^, FBLOCKSIZE)
    else
       ShiftLeft(Pointer(FIVTemp), @FBuffer[Index], curSize);
    For i:= 0 to (curSize - 1) do begin
     PArray(pOut)^[i] := FBuffer[Index + i] Xor FSmallBuffer[i];
    end;
    Dec(WhatsLeft, curSize);
    Inc(Index, curSize);
    Inc(pOut,  curSize);
    curSize   := MIN(FBLOCKSIZE, WhatsLeft);
 end;{while}
end;{TCrypto.DecipherCFB}

Procedure TCrypto.EncipherECB;
var Index: WORD;
begin
 {Pad the input to a multiple of 64bits(8BYTES) with Nulls}
  while (FInputLength mod FBLOCKSIZE)<>0 do begin
    FBuffer[FInputLength] := 0;
    Inc(FInputLength);
  end;
  Index := 0;
  repeat {Do one BLOCK at a time}
    Move(FBuffer[Index], FSmallBuffer, FBLOCKSIZE);
    EncipherBLOCK;
    Move(FSmallBuffer, FOutputArray^[Index], FBLOCKSIZE);
    Inc(Index,FBLOCKSIZE);
  until Index = FInputLength;
end;{TCrypto.EncipherECB}

Procedure TCrypto.DecipherECB;
var Index: WORD;
begin
 {Pad the input to a multiple of FBLOCKSIZE with Nulls}
  while (FInputLength mod FBLOCKSIZE)<>0 do begin
    FBuffer[FInputLength] := 0;
    Inc(FInputLength);
  end;
  Index := 0;
  repeat {Do one BLOCK at a time}
    Move(FBuffer[Index], FSmallBuffer, FBLOCKSIZE);
    DecipherBLOCK;
    Move(FSmallBuffer, FOutputArray^[Index], FBLOCKSIZE);
    Inc(Index,FBLOCKSIZE);
  until Index = FInputLength;
end;{TCrypto.DecipherECB}

Procedure TCrypto.EncipherCBC;
{Purpose:  Performs Cipher Block Chaining(CBC) mode encrytion.
           C_i := E(P_i Xor C_i-1 )
}
var
  pOut: PArray;
  Index: LongInt;
  i: WORD;
begin
 pOut := PArray(FOutputArray);
 Index := 0;
{Pad the input to a multiple of FBLOCKSIZE with Nulls}
  while (FInputLength mod FBLOCKSIZE)<>0 do begin
    FBuffer[FInputLength] := 0;
    Inc(FInputLength);
  end;
  repeat {Do one BLOCK at a time}
    Move(FBuffer[Index], FSmallBuffer, FBLOCKSIZE);
    For i:= 0 to (FBLOCKSIZE - 1) do begin
     FSmallBuffer[i] := FSmallBuffer[i] Xor PArray(FIVTemp)^[i];
    end;
    EncipherBLOCK;
    Move(FSmallBuffer, FIVTemp^, FBLOCKSIZE);    {Put Cipher text in FB register}
    Move(FSmallBuffer, pOut^[Index], FBLOCKSIZE);{Put Cipher in Output Buffer}
    Inc(Index,FBLOCKSIZE);
  until Index = FInputLength;
end;{TCrypto.EncipherCBC}

Procedure TCrypto.DecipherCBC;
{Purpose:  Performs Cipher Block Chaining(CBC) mode Decrytion.
           P_i := C_i-1 Xor D(Ci)
}
var
  pOut: PArray;
  Index : LongInt;
  i: WORD;
begin
 pOut := PArray(FOutputArray);
 Index := 0;
{Pad the input to a multiple of FBLOCKSIZE with Nulls}
  while (FInputLength mod FBLOCKSIZE)<>0 do begin
    FBuffer[FInputLength] := 0;
    Inc(FInputLength);
  end;
  repeat {Do one BLOCK at a time}
    Move(FBuffer[Index], FSmallBuffer, FBLOCKSIZE);
    DecipherBLOCK; {Decipher C_i}
    For i:= 0 to (FBLOCKSIZE - 1) do begin {xor with C_i-1}
     FSmallBuffer[i] := FSmallBuffer[i] Xor PArray(FIVTemp)^[i];
    end;
    Move(FBuffer[Index], FIVTemp^, FBLOCKSIZE); {Save next IV}
    Move(FSmallBuffer, PArray(pOut)^[Index], FBLOCKSIZE); {Save Plain Text}
    Inc(Index,FBLOCKSIZE);
  until Index = FInputLength;
end;{TCrypto.EncipherCBC}

end.
