// **********************************************************
// This file is Auto generated by DBGen
// Any changes will be lost when the file is regenerated
// **********************************************************
using System;
using BankLink.Practice.Common.Entities;
using System.Xml.Serialization;


namespace BankLink.Practice.BooksIO
{
	/// <summary>
	/// BK - BankAccount class
	/// </summary>
	public partial class BKBankAccount 
	{


		/// <summary>
		/// BankAccountNumber property
		/// </summary>
		[XmlAttribute("BankAccountNumber", DataType = "string")]
		public String BankAccountNumber { get; set; }



		/// <summary>
		/// BankAccountName property
		/// </summary>
		[XmlAttribute("BankAccountName", DataType = "string")]
		public String BankAccountName { get; set; }



		/// <summary>
		/// BankAccountPassword property
		/// </summary>
		[XmlAttribute("BankAccountPassword", DataType = "string")]
		public String BankAccountPassword { get; set; }



		/// <summary>
		/// ContraAccountCode property
		/// </summary>
		[XmlAttribute("ContraAccountCode", DataType = "string")]
		public String ContraAccountCode { get; set; }



		/// <summary>
		/// CurrentBalance property
		/// </summary>
		[XmlAttribute("CurrentBalance", DataType = "long")]
		public Int64 CurrentBalance { get; set; }



		/// <summary>
		/// ApplyMasterMemorisedEntries property
		/// </summary>
		[XmlAttribute("ApplyMasterMemorisedEntries", DataType = "boolean")]
		public bool ApplyMasterMemorisedEntries { get; set; }



		/// <summary>
		/// AccountType property
		/// </summary>
		[XmlAttribute("AccountType", DataType = "unsignedByte")]
		public byte AccountType { get; set; }



		/// <summary>
		/// ColumnOrder property
		/// </summary>
		[XmlArray("ColumnOrders"),XmlArrayItem("ColumnOrder", DataType = "unsignedByte")]
		public byte[] ColumnOrder { get; set; }


		/// <summary>
		/// ColumnWidth property
		/// </summary>
		[XmlArray("ColumnWidths"),XmlArrayItem("ColumnWidth", DataType = "int")]
		public Int32[] ColumnWidth { get; set; }


		/// <summary>
		/// PreferredView property
		/// </summary>
		[XmlAttribute("PreferredView", DataType = "unsignedByte")]
		public byte PreferredView { get; set; }



		/// <summary>
		/// HighestBankLinkID property
		/// </summary>
		[XmlAttribute("HighestBankLinkID", DataType = "int")]
		public Int32 HighestBankLinkID { get; set; }



		/// <summary>
		/// HighestLRN property
		/// </summary>
		[XmlAttribute("HighestLRN", DataType = "int")]
		public Int32 HighestLRN { get; set; }



		/// <summary>
		/// ColumnisHidden property
		/// </summary>
		[XmlArray("ColumnisHiddens"),XmlArrayItem("ColumnisHidden", DataType = "boolean")]
		public bool[] ColumnisHidden { get; set; }


		/// <summary>
		/// AccountExpiryDate property
		/// </summary>
		[XmlAttribute("AccountExpiryDate", DataType = "int")]
		public Int32 AccountExpiryDate { get; set; }



		/// <summary>
		/// HighestMatchedItemID property
		/// </summary>
		[XmlAttribute("HighestMatchedItemID", DataType = "int")]
		public Int32 HighestMatchedItemID { get; set; }



		/// <summary>
		/// NotesAlwaysVisible property
		/// </summary>
		[XmlAttribute("NotesAlwaysVisible", DataType = "boolean")]
		public bool NotesAlwaysVisible { get; set; }



		/// <summary>
		/// NotesHeight property
		/// </summary>
		[XmlAttribute("NotesHeight", DataType = "int")]
		public Int32 NotesHeight { get; set; }



		/// <summary>
		/// LastECodingTransactionUID property
		/// </summary>
		[XmlAttribute("LastECodingTransactionUID", DataType = "int")]
		public Int32 LastECodingTransactionUID { get; set; }



		/// <summary>
		/// ColumnIsNotEditable property
		/// </summary>
		[XmlArray("ColumnIsNotEditables"),XmlArrayItem("ColumnIsNotEditable", DataType = "boolean")]
		public bool[] ColumnIsNotEditable { get; set; }


		/// <summary>
		/// ExtendExpiryDate property
		/// </summary>
		[XmlAttribute("ExtendExpiryDate", DataType = "boolean")]
		public bool ExtendExpiryDate { get; set; }



		/// <summary>
		/// IsAManualAccount property
		/// </summary>
		[XmlAttribute("IsAManualAccount", DataType = "boolean")]
		public bool IsAManualAccount { get; set; }



		/// <summary>
		/// AnalysisCodingLevel property
		/// </summary>
		[XmlAttribute("AnalysisCodingLevel", DataType = "int")]
		public Int32 AnalysisCodingLevel { get; set; }



		/// <summary>
		/// ECodingAccountUID property
		/// </summary>
		[XmlAttribute("ECodingAccountUID", DataType = "int")]
		public Int32 ECodingAccountUID { get; set; }



		/// <summary>
		/// CodingSortOrder property
		/// </summary>
		[XmlAttribute("CodingSortOrder", DataType = "int")]
		public Int32 CodingSortOrder { get; set; }



		/// <summary>
		/// ManualAccountType property
		/// </summary>
		[XmlAttribute("ManualAccountType", DataType = "int")]
		public Int32 ManualAccountType { get; set; }



		/// <summary>
		/// ManualAccountInstitution property
		/// </summary>
		[XmlAttribute("ManualAccountInstitution", DataType = "string")]
		public String ManualAccountInstitution { get; set; }



		/// <summary>
		/// ManualAccountSentToAdmin property
		/// </summary>
		[XmlAttribute("ManualAccountSentToAdmin", DataType = "boolean")]
		public bool ManualAccountSentToAdmin { get; set; }



		/// <summary>
		/// SpareString property
		/// </summary>
		[XmlAttribute("SpareString", DataType = "string")]
		public String SpareString { get; set; }



		/// <summary>
		/// IsAProvisionalAccount property
		/// </summary>
		[XmlAttribute("IsAProvisionalAccount", DataType = "boolean")]
		public bool IsAProvisionalAccount { get; set; }



		/// <summary>
		/// SpareNumber property
		/// </summary>
		[XmlAttribute("SpareNumber", DataType = "int")]
		public Int32 SpareNumber { get; set; }



		/// <summary>
		/// SpareByte property
		/// </summary>
		[XmlAttribute("SpareByte", DataType = "unsignedByte")]
		public byte SpareByte { get; set; }



		/// <summary>
		/// HDEColumnOrder property
		/// </summary>
		[XmlArray("HDEColumnOrders"),XmlArrayItem("HDEColumnOrder", DataType = "unsignedByte")]
		public byte[] HDEColumnOrder { get; set; }


		/// <summary>
		/// HDEColumnWidth property
		/// </summary>
		[XmlArray("HDEColumnWidths"),XmlArrayItem("HDEColumnWidth", DataType = "int")]
		public Int32[] HDEColumnWidth { get; set; }


		/// <summary>
		/// HDEColumnisHidden property
		/// </summary>
		[XmlArray("HDEColumnisHiddens"),XmlArrayItem("HDEColumnisHidden", DataType = "boolean")]
		public bool[] HDEColumnisHidden { get; set; }


		/// <summary>
		/// HDEColumnisNotEditable property
		/// </summary>
		[XmlArray("HDEColumnisNotEditables"),XmlArrayItem("HDEColumnisNotEditable", DataType = "boolean")]
		public bool[] HDEColumnisNotEditable { get; set; }


		/// <summary>
		/// HDESortOrder property
		/// </summary>
		[XmlAttribute("HDESortOrder", DataType = "int")]
		public Int32 HDESortOrder { get; set; }



		/// <summary>
		/// MDEColumnOrder property
		/// </summary>
		[XmlArray("MDEColumnOrders"),XmlArrayItem("MDEColumnOrder", DataType = "unsignedByte")]
		public byte[] MDEColumnOrder { get; set; }


		/// <summary>
		/// MDEColumnWidth property
		/// </summary>
		[XmlArray("MDEColumnWidths"),XmlArrayItem("MDEColumnWidth", DataType = "int")]
		public Int32[] MDEColumnWidth { get; set; }


		/// <summary>
		/// MDEColumnisHidden property
		/// </summary>
		[XmlArray("MDEColumnisHiddens"),XmlArrayItem("MDEColumnisHidden", DataType = "boolean")]
		public bool[] MDEColumnisHidden { get; set; }


		/// <summary>
		/// MDEColumnisNotEditable property
		/// </summary>
		[XmlArray("MDEColumnisNotEditables"),XmlArrayItem("MDEColumnisNotEditable", DataType = "boolean")]
		public bool[] MDEColumnisNotEditable { get; set; }


		/// <summary>
		/// MDESortOrder property
		/// </summary>
		[XmlAttribute("MDESortOrder", DataType = "int")]
		public Int32 MDESortOrder { get; set; }



		/// <summary>
		/// DISColumnOrder property
		/// </summary>
		[XmlArray("DISColumnOrders"),XmlArrayItem("DISColumnOrder", DataType = "unsignedByte")]
		public byte[] DISColumnOrder { get; set; }


		/// <summary>
		/// DISColumnWidth property
		/// </summary>
		[XmlArray("DISColumnWidths"),XmlArrayItem("DISColumnWidth", DataType = "int")]
		public Int32[] DISColumnWidth { get; set; }


		/// <summary>
		/// DISColumnisHidden property
		/// </summary>
		[XmlArray("DISColumnisHiddens"),XmlArrayItem("DISColumnisHidden", DataType = "boolean")]
		public bool[] DISColumnisHidden { get; set; }


		/// <summary>
		/// DISColumnisNotEditable property
		/// </summary>
		[XmlArray("DISColumnisNotEditables"),XmlArrayItem("DISColumnisNotEditable", DataType = "boolean")]
		public bool[] DISColumnisNotEditable { get; set; }


		/// <summary>
		/// DISSortOrder property
		/// </summary>
		[XmlAttribute("DISSortOrder", DataType = "int")]
		public Int32 DISSortOrder { get; set; }



		/// <summary>
		/// DesktopSuperLedgerID property
		/// </summary>
		[XmlAttribute("DesktopSuperLedgerID", DataType = "int")]
		public Int32 DesktopSuperLedgerID { get; set; }



		/// <summary>
		/// CurrencyCode property
		/// </summary>
		[XmlAttribute("CurrencyCode", DataType = "string")]
		public String CurrencyCode { get; set; }



		/// <summary>
		/// DefaultForexSource property
		/// </summary>
		[XmlAttribute("DefaultForexSource", DataType = "string")]
		public String DefaultForexSource { get; set; }



		/// <summary>
		/// DefaultForexDescription property
		/// </summary>
		[XmlAttribute("DefaultForexDescription", DataType = "string")]
		public String DefaultForexDescription { get; set; }



		/// <summary>
		/// SuperFundLedgerCode property
		/// </summary>
		[XmlAttribute("SuperFundLedgerCode", DataType = "string")]
		public String SuperFundLedgerCode { get; set; }



		/// <summary>
		/// AuditRecordID property
		/// </summary>
		[XmlAttribute("AuditRecordID", DataType = "int")]
		public Int32 AuditRecordID { get; set; }



		/// <summary>
		/// CoreAccountID property
		/// </summary>
		[XmlAttribute("CoreAccountID", DataType = "int")]
		public Int32 CoreAccountID { get; set; }



		/// <summary>
		/// SecureOnlineCode property
		/// </summary>
		[XmlAttribute("SecureOnlineCode", DataType = "string")]
		public String SecureOnlineCode { get; set; }



		/// <summary>
		/// ExchangeGainLossCode property
		/// </summary>
		[XmlAttribute("ExchangeGainLossCode", DataType = "string")]
		public String ExchangeGainLossCode { get; set; }



		/// <summary>
		/// SuggestedUnProcessedCount property
		/// </summary>
		[XmlAttribute("SuggestedUnProcessedCount", DataType = "int")]
		public Int32 SuggestedUnProcessedCount { get; set; }


		/// <summary>
		/// Class Begin Token
		/// </summary>
		public const byte BeginToken = 150;
		/// <summary>
		/// Class End Token
		/// </summary>
		public const byte EndToken = 151;
		/// <summary>
		/// Write to BKStream
		/// </summary>
		public void WriteBKStream(BankLinkTokenStreamWriter s)
		{
			s.WriteToken(150);
			s.WriteShortStringValue(152, BankAccountNumber);
			s.WriteShortStringValue(153, BankAccountName);
			s.WriteShortStringValue(154, BankAccountPassword);
			s.WriteShortStringValue(155, ContraAccountCode);
			s.WriteMoneyValue(156, CurrentBalance);
			s.WriteBooleanValue(157, ApplyMasterMemorisedEntries);
			s.WriteByteValue(158, AccountType);
			s.WriteByteArray(159, ColumnOrder, true);
			s.WriteInt32Array(160, ColumnWidth, true);
			s.WriteByteValue(161, PreferredView);
			s.WriteInt32Value(162, HighestBankLinkID);
			s.WriteInt32Value(163, HighestLRN);
			s.WriteBooleanArray(164, ColumnisHidden, true);
			s.WriteJulDateValue(165, AccountExpiryDate);
			s.WriteInt32Value(166, HighestMatchedItemID);
			s.WriteBooleanValue(167, NotesAlwaysVisible);
			s.WriteInt32Value(168, NotesHeight);
			s.WriteInt32Value(169, LastECodingTransactionUID);
			s.WriteBooleanArray(170, ColumnIsNotEditable, true);
			s.WriteBooleanValue(171, ExtendExpiryDate);
			s.WriteBooleanValue(172, IsAManualAccount);
			s.WriteInt32Value(173, AnalysisCodingLevel);
			s.WriteInt32Value(174, ECodingAccountUID);
			s.WriteInt32Value(175, CodingSortOrder);
			s.WriteInt32Value(176, ManualAccountType);
			s.WriteShortStringValue(177, ManualAccountInstitution);
			s.WriteBooleanValue(178, ManualAccountSentToAdmin);
			s.WriteAnsiStringValue(179, SpareString);
			s.WriteBooleanValue(180, IsAProvisionalAccount);
			s.WriteInt32Value(181, SpareNumber);
			s.WriteByteValue(182, SpareByte);
			s.WriteByteArray(183, HDEColumnOrder, true);
			s.WriteInt32Array(184, HDEColumnWidth, true);
			s.WriteBooleanArray(185, HDEColumnisHidden, true);
			s.WriteBooleanArray(186, HDEColumnisNotEditable, true);
			s.WriteInt32Value(187, HDESortOrder);
			s.WriteByteArray(188, MDEColumnOrder, true);
			s.WriteInt32Array(189, MDEColumnWidth, true);
			s.WriteBooleanArray(190, MDEColumnisHidden, true);
			s.WriteBooleanArray(191, MDEColumnisNotEditable, true);
			s.WriteInt32Value(192, MDESortOrder);
			s.WriteByteArray(193, DISColumnOrder, true);
			s.WriteInt32Array(194, DISColumnWidth, true);
			s.WriteBooleanArray(195, DISColumnisHidden, true);
			s.WriteBooleanArray(196, DISColumnisNotEditable, true);
			s.WriteInt32Value(197, DISSortOrder);
			s.WriteInt32Value(198, DesktopSuperLedgerID);
			s.WriteShortStringValue(199, CurrencyCode);
			s.WriteShortStringValue(200, DefaultForexSource);
			s.WriteShortStringValue(201, DefaultForexDescription);
			s.WriteShortStringValue(202, SuperFundLedgerCode);
			s.WriteInt32Value(203, AuditRecordID);
			s.WriteInt32Value(204, CoreAccountID);
			s.WriteShortStringValue(205, SecureOnlineCode);
			s.WriteShortStringValue(206, ExchangeGainLossCode);
			s.WriteInt32Value(207, SuggestedUnProcessedCount);
			s.WriteToken(151);
		}

		/// <summary>
		/// Default Constructor 
		/// </summary>
		public BKBankAccount ()
		{}
		/// <summary>
		/// Construct from BKStreamReader
		/// </summary>
		public BKBankAccount (BankLinkTokenStreamReader s)
		{
			var token = BeginToken;
			while (token != EndToken)
			{
				switch (token)
				{
			case 152 :
				BankAccountNumber = s.ReadShortStringValue("BankAccountNumber");
				break;
			case 153 :
				BankAccountName = s.ReadShortStringValue("BankAccountName");
				break;
			case 154 :
				BankAccountPassword = s.ReadShortStringValue("BankAccountPassword");
				break;
			case 155 :
				ContraAccountCode = s.ReadShortStringValue("ContraAccountCode");
				break;
			case 156 :
				CurrentBalance = s.ReadMoneyValue("CurrentBalance");
				break;
			case 157 :
				ApplyMasterMemorisedEntries = s.ReadBooleanValue("ApplyMasterMemorisedEntries");
				break;
			case 158 :
				AccountType = s.ReadByteValue("AccountType");
				break;
			case 159 :
				ColumnOrder = s.ReadByteArray("ColumnOrder", 159, 32, true);
				break;
			case 160 :
				ColumnWidth = s.ReadInt32Array("ColumnWidth", 160, 32, true);
				break;
			case 161 :
				PreferredView = s.ReadByteValue("PreferredView");
				break;
			case 162 :
				HighestBankLinkID = s.ReadInt32Value("HighestBankLinkID");
				break;
			case 163 :
				HighestLRN = s.ReadInt32Value("HighestLRN");
				break;
			case 164 :
				ColumnisHidden = s.ReadBooleanArray("ColumnisHidden", 164, 32, true);
				break;
			case 165 :
				AccountExpiryDate = s.ReadJulDateValue("AccountExpiryDate");
				break;
			case 166 :
				HighestMatchedItemID = s.ReadInt32Value("HighestMatchedItemID");
				break;
			case 167 :
				NotesAlwaysVisible = s.ReadBooleanValue("NotesAlwaysVisible");
				break;
			case 168 :
				NotesHeight = s.ReadInt32Value("NotesHeight");
				break;
			case 169 :
				LastECodingTransactionUID = s.ReadInt32Value("LastECodingTransactionUID");
				break;
			case 170 :
				ColumnIsNotEditable = s.ReadBooleanArray("ColumnIsNotEditable", 170, 32, true);
				break;
			case 171 :
				ExtendExpiryDate = s.ReadBooleanValue("ExtendExpiryDate");
				break;
			case 172 :
				IsAManualAccount = s.ReadBooleanValue("IsAManualAccount");
				break;
			case 173 :
				AnalysisCodingLevel = s.ReadInt32Value("AnalysisCodingLevel");
				break;
			case 174 :
				ECodingAccountUID = s.ReadInt32Value("ECodingAccountUID");
				break;
			case 175 :
				CodingSortOrder = s.ReadInt32Value("CodingSortOrder");
				break;
			case 176 :
				ManualAccountType = s.ReadInt32Value("ManualAccountType");
				break;
			case 177 :
				ManualAccountInstitution = s.ReadShortStringValue("ManualAccountInstitution");
				break;
			case 178 :
				ManualAccountSentToAdmin = s.ReadBooleanValue("ManualAccountSentToAdmin");
				break;
			case 179 :
				SpareString = s.ReadAnsiStringValue("SpareString");
				break;
			case 180 :
				IsAProvisionalAccount = s.ReadBooleanValue("IsAProvisionalAccount");
				break;
			case 181 :
				SpareNumber = s.ReadInt32Value("SpareNumber");
				break;
			case 182 :
				SpareByte = s.ReadByteValue("SpareByte");
				break;
			case 183 :
				HDEColumnOrder = s.ReadByteArray("HDEColumnOrder", 183, 32, true);
				break;
			case 184 :
				HDEColumnWidth = s.ReadInt32Array("HDEColumnWidth", 184, 32, true);
				break;
			case 185 :
				HDEColumnisHidden = s.ReadBooleanArray("HDEColumnisHidden", 185, 32, true);
				break;
			case 186 :
				HDEColumnisNotEditable = s.ReadBooleanArray("HDEColumnisNotEditable", 186, 32, true);
				break;
			case 187 :
				HDESortOrder = s.ReadInt32Value("HDESortOrder");
				break;
			case 188 :
				MDEColumnOrder = s.ReadByteArray("MDEColumnOrder", 188, 32, true);
				break;
			case 189 :
				MDEColumnWidth = s.ReadInt32Array("MDEColumnWidth", 189, 32, true);
				break;
			case 190 :
				MDEColumnisHidden = s.ReadBooleanArray("MDEColumnisHidden", 190, 32, true);
				break;
			case 191 :
				MDEColumnisNotEditable = s.ReadBooleanArray("MDEColumnisNotEditable", 191, 32, true);
				break;
			case 192 :
				MDESortOrder = s.ReadInt32Value("MDESortOrder");
				break;
			case 193 :
				DISColumnOrder = s.ReadByteArray("DISColumnOrder", 193, 32, true);
				break;
			case 194 :
				DISColumnWidth = s.ReadInt32Array("DISColumnWidth", 194, 32, true);
				break;
			case 195 :
				DISColumnisHidden = s.ReadBooleanArray("DISColumnisHidden", 195, 32, true);
				break;
			case 196 :
				DISColumnisNotEditable = s.ReadBooleanArray("DISColumnisNotEditable", 196, 32, true);
				break;
			case 197 :
				DISSortOrder = s.ReadInt32Value("DISSortOrder");
				break;
			case 198 :
				DesktopSuperLedgerID = s.ReadInt32Value("DesktopSuperLedgerID");
				break;
			case 199 :
				CurrencyCode = s.ReadShortStringValue("CurrencyCode");
				break;
			case 200 :
				DefaultForexSource = s.ReadShortStringValue("DefaultForexSource");
				break;
			case 201 :
				DefaultForexDescription = s.ReadShortStringValue("DefaultForexDescription");
				break;
			case 202 :
				SuperFundLedgerCode = s.ReadShortStringValue("SuperFundLedgerCode");
				break;
			case 203 :
				AuditRecordID = s.ReadInt32Value("AuditRecordID");
				break;
			case 204 :
				CoreAccountID = s.ReadInt32Value("CoreAccountID");
				break;
			case 205 :
				SecureOnlineCode = s.ReadShortStringValue("SecureOnlineCode");
				break;
			case 206 :
				ExchangeGainLossCode = s.ReadShortStringValue("ExchangeGainLossCode");
				break;
			case 207 :
				SuggestedUnProcessedCount = s.ReadInt32Value("SuggestedUnProcessedCount");
				break;
			case BeginToken :
			case EndToken :
				break;
			default:
				throw new Exception(string.Format("unexpected Code: {0} reading BankAccount",token) );
				}
			token = s.ReadToken();
			}
		}


	}


}


