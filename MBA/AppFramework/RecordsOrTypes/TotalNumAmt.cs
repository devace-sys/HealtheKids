using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MBA
{
  /***************************************************************************
   * TotalNumAmt */
  /**
   ***************************************************************************/   
  
  public class TotalNumAmt
  {
    public long    totalNumVal;
	public decimal totalAmtVal;
	public string  totalNumStr;
	public string  totalAmtStr;
	public long    goalNumVal;
	public Decimal goalAmtVal;
    public string  goalNumStr;
	public string  goalAmtStr;
    public long    compareNumVal;
    public Decimal compareAmtVal;
    public string  compareNumStr;
    public string  compareAmtStr;
	public long    totalNumGoalNumDiffVal;
    public Decimal totalAmtGoalAmtDiffVal;
    public string  totalNumGoalNumDiffStr;
    public string  totalAmtGoalAmtDiffStr;
    public string  label;
    public string  actionURL;
    public string  actionTabID;
    public bool    isReportDownload;
    public string  additionalData1 = "";
    public string  additionalData2 = "";
    public string  additionalData3 = "";
    public string  additionalData4 = "";
    public string  rptNum;
    public string  rptFmt;
    public string  valuesJSON;
    public int     chartType;    
}

}
