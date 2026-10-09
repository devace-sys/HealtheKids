using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;


namespace MBA
{
  public class Serialize
  {
  
    /***************************************************************************
     * multiDate */
    /**
     * Serializes a multidate.
     * 
     * @param    datesIn       One or more dates in a datetime array
     * @return   string
     ***************************************************************************/
   
    public static string multiDate (DateTime[] datesIn, string delim)
    {
      string datesOut = "";

      if (datesIn == null)     return datesOut;
      if (datesIn.Length == 0) return datesOut;
      
      if (Util.IsNullOrEmpty(delim)) delim = ",";
      
      foreach (DateTime dateVal in datesIn)
        datesOut = datesOut + dateVal.ToShortDateString() + delim;
      
      int len = datesOut.Length - 1;
      datesOut.Remove(len,1);
      
      return datesOut;
    }
  }
}
