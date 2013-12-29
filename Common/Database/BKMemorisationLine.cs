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
	/// BK - MemorisationLine class
	/// </summary>
	public partial class BKMemorisationLine 
	{


		/// <summary>
		/// Account property
		/// </summary>
		[XmlAttribute("Account", DataType = "string")]
		public String Account { get; set; }



		/// <summary>
		/// Percentage property
		/// </summary>
		[XmlAttribute("Percentage", DataType = "long")]
		public Int64 Percentage { get; set; }



		/// <summary>
		/// GSTClass property
		/// </summary>
		[XmlAttribute("GSTClass", DataType = "unsignedByte")]
		public byte GSTClass { get; set; }



		/// <summary>
		/// GSTHasBeenEdited property
		/// </summary>
		[XmlAttribute("GSTHasBeenEdited", DataType = "boolean")]
		public bool GSTHasBeenEdited { get; set; }



		/// <summary>
		/// GLNarration property
		/// </summary>
		[XmlAttribute("GLNarration", DataType = "string")]
		public String GLNarration { get; set; }



		/// <summary>
		/// LineType property
		/// </summary>
		[XmlAttribute("LineType", DataType = "unsignedByte")]
		public byte LineType { get; set; }



		/// <summary>
		/// GSTAmount property
		/// </summary>
		[XmlAttribute("GSTAmount", DataType = "long")]
		public Int64 GSTAmount { get; set; }



		/// <summary>
		/// Payee property
		/// </summary>
		[XmlAttribute("Payee", DataType = "int")]
		public Int32 Payee { get; set; }



		/// <summary>
		/// SFPCFranked property
		/// </summary>
		[XmlAttribute("SFPCFranked", DataType = "long")]
		public Int64 SFPCFranked { get; set; }



		/// <summary>
		/// SFMemberID property
		/// </summary>
		[XmlAttribute("SFMemberID", DataType = "string")]
		public String SFMemberID { get; set; }



		/// <summary>
		/// SFFundID property
		/// </summary>
		[XmlAttribute("SFFundID", DataType = "int")]
		public Int32 SFFundID { get; set; }



		/// <summary>
		/// SFFundCode property
		/// </summary>
		[XmlAttribute("SFFundCode", DataType = "string")]
		public String SFFundCode { get; set; }



		/// <summary>
		/// SFTransID property
		/// </summary>
		[XmlAttribute("SFTransID", DataType = "int")]
		public Int32 SFTransID { get; set; }



		/// <summary>
		/// SFTransCode property
		/// </summary>
		[XmlAttribute("SFTransCode", DataType = "string")]
		public String SFTransCode { get; set; }



		/// <summary>
		/// SFMemberAccountID property
		/// </summary>
		[XmlAttribute("SFMemberAccountID", DataType = "int")]
		public Int32 SFMemberAccountID { get; set; }



		/// <summary>
		/// SFMemberAccountCode property
		/// </summary>
		[XmlAttribute("SFMemberAccountCode", DataType = "string")]
		public String SFMemberAccountCode { get; set; }



		/// <summary>
		/// SFEdited property
		/// </summary>
		[XmlAttribute("SFEdited", DataType = "boolean")]
		public bool SFEdited { get; set; }



		/// <summary>
		/// SFMemberComponent property
		/// </summary>
		[XmlAttribute("SFMemberComponent", DataType = "unsignedByte")]
		public byte SFMemberComponent { get; set; }



		/// <summary>
		/// SFPCUnFranked property
		/// </summary>
		[XmlAttribute("SFPCUnFranked", DataType = "long")]
		public Int64 SFPCUnFranked { get; set; }



		/// <summary>
		/// JobCode property
		/// </summary>
		[XmlAttribute("JobCode", DataType = "string")]
		public String JobCode { get; set; }



		/// <summary>
		/// Quantity property
		/// </summary>
		[XmlAttribute("Quantity", DataType = "long")]
		public Int64 Quantity { get; set; }



		/// <summary>
		/// SFGDTDate property
		/// </summary>
		[XmlAttribute("SFGDTDate", DataType = "int")]
		public Int32 SFGDTDate { get; set; }



		/// <summary>
		/// SFTaxFreeDist property
		/// </summary>
		[XmlAttribute("SFTaxFreeDist", DataType = "long")]
		public Int64 SFTaxFreeDist { get; set; }



		/// <summary>
		/// SFTaxExemptDist property
		/// </summary>
		[XmlAttribute("SFTaxExemptDist", DataType = "long")]
		public Int64 SFTaxExemptDist { get; set; }



		/// <summary>
		/// SFTaxDeferredDist property
		/// </summary>
		[XmlAttribute("SFTaxDeferredDist", DataType = "long")]
		public Int64 SFTaxDeferredDist { get; set; }



		/// <summary>
		/// SFTFNCredits property
		/// </summary>
		[XmlAttribute("SFTFNCredits", DataType = "long")]
		public Int64 SFTFNCredits { get; set; }



		/// <summary>
		/// SFForeignIncome property
		/// </summary>
		[XmlAttribute("SFForeignIncome", DataType = "long")]
		public Int64 SFForeignIncome { get; set; }



		/// <summary>
		/// SFForeignTaxCredits property
		/// </summary>
		[XmlAttribute("SFForeignTaxCredits", DataType = "long")]
		public Int64 SFForeignTaxCredits { get; set; }



		/// <summary>
		/// SFCapitalGainsIndexed property
		/// </summary>
		[XmlAttribute("SFCapitalGainsIndexed", DataType = "long")]
		public Int64 SFCapitalGainsIndexed { get; set; }



		/// <summary>
		/// SFCapitalGainsDisc property
		/// </summary>
		[XmlAttribute("SFCapitalGainsDisc", DataType = "long")]
		public Int64 SFCapitalGainsDisc { get; set; }



		/// <summary>
		/// SFCapitalGainsOther property
		/// </summary>
		[XmlAttribute("SFCapitalGainsOther", DataType = "long")]
		public Int64 SFCapitalGainsOther { get; set; }



		/// <summary>
		/// SFOtherExpenses property
		/// </summary>
		[XmlAttribute("SFOtherExpenses", DataType = "long")]
		public Int64 SFOtherExpenses { get; set; }



		/// <summary>
		/// SFInterest property
		/// </summary>
		[XmlAttribute("SFInterest", DataType = "long")]
		public Int64 SFInterest { get; set; }



		/// <summary>
		/// SFCapitalGainsForeignDisc property
		/// </summary>
		[XmlAttribute("SFCapitalGainsForeignDisc", DataType = "long")]
		public Int64 SFCapitalGainsForeignDisc { get; set; }



		/// <summary>
		/// SFRent property
		/// </summary>
		[XmlAttribute("SFRent", DataType = "long")]
		public Int64 SFRent { get; set; }



		/// <summary>
		/// SFSpecialIncome property
		/// </summary>
		[XmlAttribute("SFSpecialIncome", DataType = "long")]
		public Int64 SFSpecialIncome { get; set; }



		/// <summary>
		/// SFOtherTaxCredit property
		/// </summary>
		[XmlAttribute("SFOtherTaxCredit", DataType = "long")]
		public Int64 SFOtherTaxCredit { get; set; }



		/// <summary>
		/// SFNonResidentTax property
		/// </summary>
		[XmlAttribute("SFNonResidentTax", DataType = "long")]
		public Int64 SFNonResidentTax { get; set; }



		/// <summary>
		/// SFForeignCapitalGainsCredit property
		/// </summary>
		[XmlAttribute("SFForeignCapitalGainsCredit", DataType = "long")]
		public Int64 SFForeignCapitalGainsCredit { get; set; }



		/// <summary>
		/// SFCapitalGainsFractionHalf property
		/// </summary>
		[XmlAttribute("SFCapitalGainsFractionHalf", DataType = "boolean")]
		public bool SFCapitalGainsFractionHalf { get; set; }



		/// <summary>
		/// AuditRecordID property
		/// </summary>
		[XmlAttribute("AuditRecordID", DataType = "int")]
		public Int32 AuditRecordID { get; set; }


		/// <summary>
		/// Class Begin Token
		/// </summary>
		public const byte BeginToken = 145;
		/// <summary>
		/// Class End Token
		/// </summary>
		public const byte EndToken = 146;
		/// <summary>
		/// Write to BKStream
		/// </summary>
		public void WriteBKStream(BankLinkTokenStreamWriter s)
		{
			s.WriteToken(145);
			s.WriteShortStringValue(147, Account);
			s.WriteMoneyValue(148, Percentage);
			s.WriteByteValue(149, GSTClass);
			s.WriteBooleanValue(150, GSTHasBeenEdited);
			s.WriteAnsiStringValue(151, GLNarration);
			s.WriteByteValue(152, LineType);
			s.WriteMoneyValue(153, GSTAmount);
			s.WriteInt32Value(154, Payee);
			s.WriteMoneyValue(155, SFPCFranked);
			s.WriteShortStringValue(156, SFMemberID);
			s.WriteInt32Value(157, SFFundID);
			s.WriteShortStringValue(158, SFFundCode);
			s.WriteInt32Value(159, SFTransID);
			s.WriteAnsiStringValue(160, SFTransCode);
			s.WriteInt32Value(161, SFMemberAccountID);
			s.WriteShortStringValue(162, SFMemberAccountCode);
			s.WriteBooleanValue(163, SFEdited);
			s.WriteByteValue(164, SFMemberComponent);
			s.WriteMoneyValue(165, SFPCUnFranked);
			s.WriteShortStringValue(166, JobCode);
			s.WriteMoneyValue(167, Quantity);
			s.WriteJulDateValue(168, SFGDTDate);
			s.WriteMoneyValue(169, SFTaxFreeDist);
			s.WriteMoneyValue(170, SFTaxExemptDist);
			s.WriteMoneyValue(171, SFTaxDeferredDist);
			s.WriteMoneyValue(172, SFTFNCredits);
			s.WriteMoneyValue(173, SFForeignIncome);
			s.WriteMoneyValue(174, SFForeignTaxCredits);
			s.WriteMoneyValue(175, SFCapitalGainsIndexed);
			s.WriteMoneyValue(176, SFCapitalGainsDisc);
			s.WriteMoneyValue(177, SFCapitalGainsOther);
			s.WriteMoneyValue(178, SFOtherExpenses);
			s.WriteMoneyValue(179, SFInterest);
			s.WriteMoneyValue(180, SFCapitalGainsForeignDisc);
			s.WriteMoneyValue(181, SFRent);
			s.WriteMoneyValue(182, SFSpecialIncome);
			s.WriteMoneyValue(183, SFOtherTaxCredit);
			s.WriteMoneyValue(184, SFNonResidentTax);
			s.WriteMoneyValue(185, SFForeignCapitalGainsCredit);
			s.WriteBooleanValue(186, SFCapitalGainsFractionHalf);
			s.WriteInt32Value(187, AuditRecordID);
			s.WriteToken(146);
		}

		/// <summary>
		/// Default Constructor 
		/// </summary>
		public BKMemorisationLine ()
		{}
		/// <summary>
		/// Construct from BKStreamReader
		/// </summary>
		public BKMemorisationLine (BankLinkTokenStreamReader s)
		{
			var token = BeginToken;
			while (token != EndToken)
			{
				switch (token)
				{
			case 147 :
				Account = s.ReadShortStringValue("Account");
				break;
			case 148 :
				Percentage = s.ReadMoneyValue("Percentage");
				break;
			case 149 :
				GSTClass = s.ReadByteValue("GSTClass");
				break;
			case 150 :
				GSTHasBeenEdited = s.ReadBooleanValue("GSTHasBeenEdited");
				break;
			case 151 :
				GLNarration = s.ReadAnsiStringValue("GLNarration");
				break;
			case 152 :
				LineType = s.ReadByteValue("LineType");
				break;
			case 153 :
				GSTAmount = s.ReadMoneyValue("GSTAmount");
				break;
			case 154 :
				Payee = s.ReadInt32Value("Payee");
				break;
			case 155 :
				SFPCFranked = s.ReadMoneyValue("SFPCFranked");
				break;
			case 156 :
				SFMemberID = s.ReadShortStringValue("SFMemberID");
				break;
			case 157 :
				SFFundID = s.ReadInt32Value("SFFundID");
				break;
			case 158 :
				SFFundCode = s.ReadShortStringValue("SFFundCode");
				break;
			case 159 :
				SFTransID = s.ReadInt32Value("SFTransID");
				break;
			case 160 :
				SFTransCode = s.ReadAnsiStringValue("SFTransCode");
				break;
			case 161 :
				SFMemberAccountID = s.ReadInt32Value("SFMemberAccountID");
				break;
			case 162 :
				SFMemberAccountCode = s.ReadShortStringValue("SFMemberAccountCode");
				break;
			case 163 :
				SFEdited = s.ReadBooleanValue("SFEdited");
				break;
			case 164 :
				SFMemberComponent = s.ReadByteValue("SFMemberComponent");
				break;
			case 165 :
				SFPCUnFranked = s.ReadMoneyValue("SFPCUnFranked");
				break;
			case 166 :
				JobCode = s.ReadShortStringValue("JobCode");
				break;
			case 167 :
				Quantity = s.ReadMoneyValue("Quantity");
				break;
			case 168 :
				SFGDTDate = s.ReadJulDateValue("SFGDTDate");
				break;
			case 169 :
				SFTaxFreeDist = s.ReadMoneyValue("SFTaxFreeDist");
				break;
			case 170 :
				SFTaxExemptDist = s.ReadMoneyValue("SFTaxExemptDist");
				break;
			case 171 :
				SFTaxDeferredDist = s.ReadMoneyValue("SFTaxDeferredDist");
				break;
			case 172 :
				SFTFNCredits = s.ReadMoneyValue("SFTFNCredits");
				break;
			case 173 :
				SFForeignIncome = s.ReadMoneyValue("SFForeignIncome");
				break;
			case 174 :
				SFForeignTaxCredits = s.ReadMoneyValue("SFForeignTaxCredits");
				break;
			case 175 :
				SFCapitalGainsIndexed = s.ReadMoneyValue("SFCapitalGainsIndexed");
				break;
			case 176 :
				SFCapitalGainsDisc = s.ReadMoneyValue("SFCapitalGainsDisc");
				break;
			case 177 :
				SFCapitalGainsOther = s.ReadMoneyValue("SFCapitalGainsOther");
				break;
			case 178 :
				SFOtherExpenses = s.ReadMoneyValue("SFOtherExpenses");
				break;
			case 179 :
				SFInterest = s.ReadMoneyValue("SFInterest");
				break;
			case 180 :
				SFCapitalGainsForeignDisc = s.ReadMoneyValue("SFCapitalGainsForeignDisc");
				break;
			case 181 :
				SFRent = s.ReadMoneyValue("SFRent");
				break;
			case 182 :
				SFSpecialIncome = s.ReadMoneyValue("SFSpecialIncome");
				break;
			case 183 :
				SFOtherTaxCredit = s.ReadMoneyValue("SFOtherTaxCredit");
				break;
			case 184 :
				SFNonResidentTax = s.ReadMoneyValue("SFNonResidentTax");
				break;
			case 185 :
				SFForeignCapitalGainsCredit = s.ReadMoneyValue("SFForeignCapitalGainsCredit");
				break;
			case 186 :
				SFCapitalGainsFractionHalf = s.ReadBooleanValue("SFCapitalGainsFractionHalf");
				break;
			case 187 :
				AuditRecordID = s.ReadInt32Value("AuditRecordID");
				break;
			case BeginToken :
			case EndToken :
				break;
			default:
				throw new Exception(string.Format("unexpected Code: {0} reading MemorisationLine",token) );
				}
			token = s.ReadToken();
			}
		}


	}


}


