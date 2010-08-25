{++

  m a p i c o d e . p a s

  Abstract:

    Automatic conversion of mapicode.h.

  Comments:

    This source file automatically converted by
    htrans 0.91 beta 1 Copyright (c) 1997 Alexander Staubo

  Revision history:

    18-06-1997 20:53 alex  [Autogenerated]
    18-06-1997 20:53 alex  Retouched for release

--}

unit MapiCode;

interface

uses
  Windows, SysUtils, ActiveX;

{!! htrans: Translated header file begins here }


(*
 *  M A P I C O D E . H
 *
 *  Status Codes returned by MAPI routines
 *
 *  Copyright 1986-1996 Microsoft Corporation. All Rights Reserved.
 *)




{!! htrans: Warning[9] - Ignored: #if defined (WIN32) && !defined (_WIN32) }
{$DEFINE _WIN32}


{ Define S_OK and ITF_* }

{$IFDEF _WIN32}
{!! htrans: Warning[9] - Ignored: #include <winerror.h> }


(*
 *  MAPI Status codes follow the style of OLE 2.0 sCodes as defined in the
 *  OLE 2.0 Programmer's Reference and header file scode.h (Windows 3.x)
 *  or winerror.h (Windows NT and Windows 95).
 *
 *)

{  On Windows 3.x, status codes have 32-bit values as follows:
 *
 *   3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *   1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 *  +-+---------------------+-------+-------------------------------+
 *  |S|       Context       | Facil |               Code            |
 *  +-+---------------------+-------+-------------------------------+
 *
 *  where
 *
 *      S - is the severity code
 *
 *          0 - SEVERITY_SUCCESS
 *          1 - SEVERITY_ERROR
 *
 *      Context - context info
 *
 *      Facility - is the facility code
 *
 *          0x0 - FACILITY_NULL     generally useful errors ([SE]_*)
 *          0x1 - FACILITY_RPC      remote procedure call errors (RPC_E_*)
 *          0x2 - FACILITY_DISPATCH late binding dispatch errors
 *          0x3 - FACILITY_STORAGE  storage errors (STG_E_*)
 *          0x4 - FACILITY_ITF      interface-specific errors
 *
 *      Code - is the facility's status code
 *
 *
 }

(*
 *  On Windows NT 3.5 and Windows 95, scodes are 32-bit values
 *  laid out as follows:
 *  
 *    3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
 *    1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
 *   +-+-+-+-+-+---------------------+-------------------------------+
 *   |S|R|C|N|r|    Facility         |               Code            |
 *   +-+-+-+-+-+---------------------+-------------------------------+
 *  
 *   where
 *  
 *      S - Severity - indicates success/fail
 *  
 *          0 - Success
 *          1 - Fail (COERROR)
 *  
 *      R - reserved portion of the facility code, corresponds to NT's
 *          second severity bit.
 *  
 *      C - reserved portion of the facility code, corresponds to NT's
 *          C field.
 *  
 *      N - reserved portion of the facility code. Used to indicate a
 *          mapped NT status value.
 *  
 *      r - reserved portion of the facility code. Reserved for internal
 *          use. Used to indicate HRESULT values that are not status
 *          values, but are instead message ids for display strings.
 *  
 *      Facility - is the facility code
 *          FACILITY_NULL                    0x0
 *          FACILITY_RPC                     0x1
 *          FACILITY_DISPATCH                0x2
 *          FACILITY_STORAGE                 0x3
 *          FACILITY_ITF                     0x4
 *          FACILITY_WIN32                   0x7
 *          FACILITY_WINDOWS                 0x8
 *  
 *      Code - is the facility's status code
 *  
 *)




(*
 *  We can't use OLE 2.0 macros to build sCodes because the definition has
 *  changed and we wish to conform to the new definition.
 *)
{!! htrans: Warning[1] - Cannot handle macro define }
{!! htrans: Warning[1] - Line is: #define MAKE_MAPI_SCODE(sev,fac,code) \ }


{ The following two macros are used to build OLE 2.0 style sCodes }

{!! htrans: Warning[1] - Cannot handle macro define }
{!! htrans: Warning[1] - Line is: #define MAKE_MAPI_E( err )  (MAKE_MAPI_SCODE( 1, FACILITY_ITF, err )) }

{!! htrans: Warning[1] - Cannot handle macro define }
{!! htrans: Warning[1] - Line is: #define MAKE_MAPI_S( warn ) (MAKE_MAPI_SCODE( 0, FACILITY_ITF, warn )) }


{$IFDEF SUCCESS_SUCCESS}
{$UNDEF SUCCESS_SUCCESS}
{$ENDIF}
const SUCCESS_SUCCESS      = 0;

{ General errors (used by more than one MAPI object) }

const MAPI_E_CALL_FAILED                               = {!! htrans: Warning[2] - Constant value not verifiable }
  E_FAIL;
const MAPI_E_NOT_ENOUGH_MEMORY                         = {!! htrans: Warning[2] - Constant value not verifiable }
  E_OUTOFMEMORY;
const MAPI_E_INVALID_PARAMETER                         = {!! htrans: Warning[2] - Constant value not verifiable }
  E_INVALIDARG;
const MAPI_E_INTERFACE_NOT_SUPPORTED                   = {!! htrans: Warning[2] - Constant value not verifiable }
  E_NOINTERFACE;
const MAPI_E_NO_ACCESS                                 = {!! htrans: Warning[2] - Constant value not verifiable }
  E_ACCESSDENIED;

const MAPI_E_NO_SUPPORT                                = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($102 );
const MAPI_E_BAD_CHARWIDTH                             = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($103 );
const MAPI_E_STRING_TOO_LONG                           = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($105 );
const MAPI_E_UNKNOWN_FLAGS                             = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($106 );
const MAPI_E_INVALID_ENTRYID                           = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($107 );
const MAPI_E_INVALID_OBJECT                            = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($108 );
const MAPI_E_OBJECT_CHANGED                            = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($109 );
const MAPI_E_OBJECT_DELETED                            = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($10A );
const MAPI_E_BUSY                                      = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($10 );
const MAPI_E_NOT_ENOUGH_DISK                           = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($10D );
const MAPI_E_NOT_ENOUGH_RESOURCES                      = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($10E );
const MAPI_E_NOT_FOUND                                 = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($10F );
const MAPI_E_VERSION                                   = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($110 );
const MAPI_E_LOGON_FAILED                              = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($111 );
const MAPI_E_SESSION_LIMIT                             = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($112 );
const MAPI_E_USER_CANCEL                               = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($113 );
const MAPI_E_UNABLE_TO_ABORT                           = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($114 );
const MAPI_E_NETWORK_ERROR                             = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($115 );
const MAPI_E_DISK_ERROR                                = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($116 );
const MAPI_E_TOO_COMPLEX                               = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($117 );
const MAPI_E_BAD_COLUMN                                = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($118 );
const MAPI_E_EXTENDED_ERROR                            = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($119 );
const MAPI_E_COMPUTED                                  = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($11A );
const MAPI_E_CORRUPT_DATA                              = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($11 );
const MAPI_E_UNCONFIGURED                              = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($11C );
const MAPI_E_FAILONEPROVIDER                           = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($11D );
const MAPI_E_UNKNOWN_CPID                              = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($11E );
const MAPI_E_UNKNOWN_LCID                              = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($11F );

{ Flavors of E_ACCESSDENIED, used at logon }

const MAPI_E_PASSWORD_CHANGE_REQUIRED                  = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($120 );
const MAPI_E_PASSWORD_EXPIRED                          = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($121 );
const MAPI_E_INVALID_WORKSTATION_ACCOUNT               = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($122 );
const MAPI_E_INVALID_ACCESS_TIME                       = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($123 );
const MAPI_E_ACCOUNT_DISABLED                          = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($124 );

{ MAPI base function and status object specific errors and warnings }

const MAPI_E_END_OF_SESSION                            = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($200 );
const MAPI_E_UNKNOWN_ENTRYID                           = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($201 );
const MAPI_E_MISSING_REQUIRED_COLUMN                   = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($202 );
const MAPI_W_NO_SERVICE                                = {!! htrans: [MAPI MAKE_MAPI_S macro] }
   (FACILITY_ITF shl 16) or ($203 );

{ Property specific errors and warnings }

const MAPI_E_BAD_VALUE                                 = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($301 );
const MAPI_E_INVALID_TYPE                              = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($302 );
const MAPI_E_TYPE_NO_SUPPORT                           = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($303 );
const MAPI_E_UNEXPECTED_TYPE                           = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($304 );
const MAPI_E_TOO_BIG                                   = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($305 );
const MAPI_E_DECLINE_COPY                              = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($306 );
const MAPI_E_UNEXPECTED_ID                             = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($307 );

const MAPI_W_ERRORS_RETURNED                           = {!! htrans: [MAPI MAKE_MAPI_S macro] }
   (FACILITY_ITF shl 16) or ($380 );

{ Table specific errors and warnings }

const MAPI_E_UNABLE_TO_COMPLETE                        = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($400 );
const MAPI_E_TIMEOUT                                   = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($401 );
const MAPI_E_TABLE_EMPTY                               = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($402 );
const MAPI_E_TABLE_TOO_BIG                             = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($403 );

const MAPI_E_INVALID_BOOKMARK                          = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($405 );

const MAPI_W_POSITION_CHANGED                          = {!! htrans: [MAPI MAKE_MAPI_S macro] }
   (FACILITY_ITF shl 16) or ($481 );
const MAPI_W_APPROX_COUNT                              = {!! htrans: [MAPI MAKE_MAPI_S macro] }
   (FACILITY_ITF shl 16) or ($482 );

{ Transport specific errors and warnings }

const MAPI_E_WAIT                                      = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($500 );
const MAPI_E_CANCEL                                    = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($501 );
const MAPI_E_NOT_ME                                    = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($502 );

const MAPI_W_CANCEL_MESSAGE                            = {!! htrans: [MAPI MAKE_MAPI_S macro] }
   (FACILITY_ITF shl 16) or ($580 );

{ Message Store, Folder, and Message specific errors and warnings }

const MAPI_E_CORRUPT_STORE                             = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($600 );
const MAPI_E_NOT_IN_QUEUE                              = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($601 );
const MAPI_E_NO_SUPPRESS                               = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($602 );
const MAPI_E_COLLISION                                 = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($604 );
const MAPI_E_NOT_INITIALIZED                           = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($605 );
const MAPI_E_NON_STANDARD                              = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($606 );
const MAPI_E_NO_RECIPIENTS                             = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($607 );
const MAPI_E_SUBMITTED                                 = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($608 );
const MAPI_E_HAS_FOLDERS                               = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($609 );
const MAPI_E_HAS_MESSAGES                              = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($60A );
const MAPI_E_FOLDER_CYCLE                              = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($60 );

const MAPI_W_PARTIAL_COMPLETION                        = {!! htrans: [MAPI MAKE_MAPI_S macro] }
   (FACILITY_ITF shl 16) or ($680 );

{ Address Book specific errors and warnings }

const MAPI_E_AMBIGUOUS_RECIP                           = {!! htrans: [MAPI MAKE_MAPI_E macro] }
   (1 shl 31) or (FACILITY_ITF shl 16) or ($700 );

{ The range 0x0800 to 0x08FF is reserved }

{ Obsolete typing shortcut that will go away eventually. }
{$IFNDEF MakeResult}
{!! htrans: Warning[1] - Cannot handle macro define }
{!! htrans: Warning[1] - Line is: #define MakeResult(_s)  ResultFromScode(_s) }

{$ENDIF}

{ We expect these to eventually be defined by OLE, but for now,
 * here they are.  When OLE defines them they can be much more
 * efficient than these, but these are "proper" and don't make
 * use of any hidden tricks.
 }
{$IFNDEF HR_SUCCEEDED}
{!! htrans: Warning[1] - Cannot handle macro define }
{!! htrans: Warning[1] - Line is: #define HR_SUCCEEDED(_hr) SUCCEEDED((SCODE)(_hr)) }

{!! htrans: Warning[1] - Cannot handle macro define }
{!! htrans: Warning[1] - Line is: #define HR_FAILED(_hr) FAILED((SCODE)(_hr)) }

{$ENDIF}

{$ENDIF}  {} 

{!! htrans: Translated header file ends here }

implementation

end.

