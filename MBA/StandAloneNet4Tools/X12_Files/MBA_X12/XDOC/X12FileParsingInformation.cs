using System;
using System.IO;
using System.Text;

namespace MBA.X12.XDOC
{
  
  public class X12FileParsingInformation: ProcessFileBase
  {
		public X12FileParsingInformation()
		{			
		  this._Init();
		}
		
    public char[]  FirstSegmentChars      { get; private set; }
		public byte[]  HeaderBytes            { get; private set; }
    public long    SegmentCount           { get; private set; }
		public int     SegmentCountISA        { get; private set; }
    public int     SegmentCountGS         { get; private set; }
    public int     SegmentCountST         { get; private set; }
    public int     SegmentCountSE         { get; private set; }
    public int     SegmentCountGE         { get; private set; }
    public int     SegmentCountIEA        { get; private set; }     
    public long    SegmentCountData       { get; private set; }
    public bool    ReadyForUse            { get; private set; }    
    
    public char    ElementDelimiter       { get { return FirstSegmentChars[3];   } }
    public char    SegmentDelimiter       { get { return FirstSegmentChars[105]; } }
    public char    SubElementDelimiter    { get { return FirstSegmentChars[104]; } }

    public Encoding FileEncoding
		{
	    get
			{
				return  (HeaderBytes[1] == 0) && (HeaderBytes[3] == 0) && (HeaderBytes[5] == 0) ? 
          Encoding.Unicode : Encoding.UTF8;
	    }
		}

		protected void _Init()
		{
		  this.HeaderBytes       = new byte[6];
      this.FirstSegmentChars = new char[106];
			this.ReadyForUse       = false;
      this.SegmentCount      = 0;
			this.SegmentCountISA   = 0;
			this.SegmentCountGS    = 0;
			this.SegmentCountST    = 0;
			this.SegmentCountData  = 0;
			this.SegmentCountSE    = 0;
			this.SegmentCountGE    = 0;
			this.SegmentCountIEA   = 0;
    }

		protected void _GetHeaderBytes (string fileIn)
		{
      RaiseProcessingStatusEvent("Getting header bytes");
  
		  /* Get header bytes */

      using (var fs = new FileStream(fileIn, FileMode.Open, FileAccess.Read, FileShare.None))
      {
        fs.Read(this.HeaderBytes, 0, 6);
        fs.Close();
      }
		}

		protected void _GetAndCheckFirstSegmentCharacters (string fileIn)
		{
      RaiseProcessingStatusEvent("Getting and checking first segment characters");

		  /* Get first segment characters */
      
      using (var fs = new FileStream(fileIn, FileMode.Open, FileAccess.Read, FileShare.None))
      using (var sr = new StreamReader(fs,this.FileEncoding))
      {                                  
        sr.ReadBlock(this.FirstSegmentChars, 0, 106);
        sr.Close();
        fs.Close();
      }

			var segCheck = new String(FirstSegmentChars,0, 3);
			if (segCheck != @"ISA")
			{
				throw new Exception(@"First segment does not appear to be a valid X12 segment.");
      }     
		}

		protected void _GetAndCheckSegmentCounts(string fileIn)
		{
			RaiseProcessingStatusEvent("Getting and checking segment counts");

		  using (var fs = new FileStream(fileIn, FileMode.Open, FileAccess.Read, FileShare.None))
			using (var sr = new StreamReader(fs, this.FileEncoding))
			{
		    foreach (var segmentStr in sr.ReadLines(this.SegmentDelimiter))
				{
					var segmentID = segmentStr.Split(this.ElementDelimiter)[0].ToUpper().Trim();
					switch (segmentID)
					{
						case @"ISA": this.SegmentCountISA++; break;
						case @"GS": this.SegmentCountGS++; break;
						case @"ST": this.SegmentCountST++; break;
						case @"SE": this.SegmentCountSE++; break;
						case @"GE": this.SegmentCountGE++; break;
						case @"IEA": this.SegmentCountIEA++; break;
						default: this.SegmentCountData++; break;
					}
					this.SegmentCount++;
				} // Loop
				sr.Close();
				fs.Close();
			} // Using
				
      if (SegmentCountISA != SegmentCountIEA) throw new Exception(@"Mismatched interchange segment pair counts");
		  if (SegmentCountGS != SegmentCountGE)   throw new Exception(@"Mismatched function group segment pair counts");
			if (SegmentCountST != SegmentCountSE)   throw new Exception(@"Mismatched transaction set segment pair counts");
			if (SegmentCountISA != 1)               throw new Exception(@"Invalid interchange segment header count. Expected 1.");
			if (SegmentCountIEA != 1)               throw new Exception(@"Invalid interchange segment trailer count. Expected 1.");
			if (SegmentCountGS == 0)                throw new Exception(@"Invalid function group header segment count. Expected at least 1.");
			if (SegmentCountGE == 0)                throw new Exception(@"Invalid function group trailer segment count. Expected at least 1.");
			if (SegmentCountST == 0)                throw new Exception(@"Invalid transaction set header segment count. Expected at least 1.");
			if (SegmentCountSE == 0)                throw new Exception(@"Invalid transaction set trailer segment count. Expected at least 1.");
	  }

    public bool LoadParsingInformationFromFile (string fileIn)
		{		  
      bool retState = false;
      RaiseProcessingStatusEvent(@"Extracting Parsing Data - Starting");
      try
		  {
        _Init();
        _GetHeaderBytes(fileIn);
			  _GetAndCheckFirstSegmentCharacters(fileIn);
			  _GetAndCheckSegmentCounts(fileIn);
			  this.ReadyForUse = true;
			  retState = true;
		  }
		  catch (Exception e)
		  {
		    retState = false;
		    this.ReadyForUse = false;
		    RaiseProcessingStatusEvent(e.Message);
		  }
		  finally
		  {
		    RaiseProcessingStatusEvent(@"Extracting Parsing Data - Complete");
		  }
		  return retState;
    }                   
  }
}
