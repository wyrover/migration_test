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
	/// BK - Payee class
	/// </summary>
	public partial class BKPayee 
	{


		/// <summary>
		/// Number property
		/// </summary>
		[XmlAttribute("Number", DataType = "int")]
		public Int32 Number { get; set; }



		/// <summary>
		/// Name property
		/// </summary>
		[XmlAttribute("Name", DataType = "string")]
		public String Name { get; set; }



		/// <summary>
		/// Account property
		/// </summary>
		[XmlArray("Accounts"),XmlArrayItem("Account", DataType = "string")]
		public String[] Account { get; set; }


		/// <summary>
		/// Percentage property
		/// </summary>
		[XmlArray("Percentages"),XmlArrayItem("Percentage", DataType = "long")]
		public Int64[] Percentage { get; set; }


		/// <summary>
		/// GSTClass property
		/// </summary>
		[XmlArray("GSTClass"),XmlArrayItem("GSTClas", DataType = "unsignedByte")]
		public byte[] GSTClass { get; set; }


		/// <summary>
		/// GSTHasBeenEdited property
		/// </summary>
		[XmlArray("GSTHasBeenEditeds"),XmlArrayItem("GSTHasBeenEdited", DataType = "boolean")]
		public bool[] GSTHasBeenEdited { get; set; }


		/// <summary>
		/// GLNarration property
		/// </summary>
		[XmlArray("GLNarrations"),XmlArrayItem("GLNarration", DataType = "string")]
		public String[] GLNarration { get; set; }


		/// <summary>
		/// AuditRecordID property
		/// </summary>
		[XmlAttribute("AuditRecordID", DataType = "int")]
		public Int32 AuditRecordID { get; set; }


		/// <summary>
		/// Class Begin Token
		/// </summary>
		public const byte BeginToken = 100;
		/// <summary>
		/// Class End Token
		/// </summary>
		public const byte EndToken = 101;
		/// <summary>
		/// Write to BKStream
		/// </summary>
		public void WriteBKStream(BankLinkTokenStreamWriter s)
		{
			s.WriteToken(100);
			s.WriteInt32Value(102, Number);
			s.WriteShortStringValue(103, Name);
			s.WriteShortStringArray(104, Account, false);
			s.WriteMoneyArray(105, Percentage, false);
			s.WriteByteArray(106, GSTClass, false);
			s.WriteBooleanArray(107, GSTHasBeenEdited, false);
			s.WriteShortStringArray(108, GLNarration, false);
			s.WriteInt32Value(109, AuditRecordID);
			s.WriteToken(101);
		}

		/// <summary>
		/// Default Constructor 
		/// </summary>
		public BKPayee ()
		{}
		/// <summary>
		/// Construct from BKStreamReader
		/// </summary>
		public BKPayee (BankLinkTokenStreamReader s)
		{
			var token = BeginToken;
			while (token != EndToken)
			{
				switch (token)
				{
			case 102 :
				Number = s.ReadInt32Value("Number");
				break;
			case 103 :
				Name = s.ReadShortStringValue("Name");
				break;
			case 104 :
				Account = s.ReadShortStringArray("Account", 104, 50, false);
				break;
			case 105 :
				Percentage = s.ReadMoneyArray("Percentage", 105, 50, false);
				break;
			case 106 :
				GSTClass = s.ReadByteArray("GSTClass", 106, 50, false);
				break;
			case 107 :
				GSTHasBeenEdited = s.ReadBooleanArray("GSTHasBeenEdited", 107, 50, false);
				break;
			case 108 :
				GLNarration = s.ReadShortStringArray("GLNarration", 108, 50, false);
				break;
			case 109 :
				AuditRecordID = s.ReadInt32Value("AuditRecordID");
				break;
			case BeginToken :
			case EndToken :
				break;
			default:
				throw new Exception(string.Format("unexpected Code: {0} reading Payee",token) );
				}
			token = s.ReadToken();
			}
		}


	}


}


