using System;
using System.Collections.Generic;
using System.Text;

/***************************************************************************
* DetailsLog.cs */
/**
 * Contains the logging object we pass through methods
 ***************************************************************************/   

namespace MBA
{
  
  /*****************************************************************************
   * DetailsLog */
  /**
   * 
   *****************************************************************************/

  public class DetailsLog 
  { 
    public DetailsLog(){this._details = new List<string>();}

    protected List<String> _details;

    public int       detailsCount {get{return this._details.Count;}}
    public bool      hasDetails   {get{if (this._details.Count > 0) return true; else return false;}}
    public string[]  details      {get{return _details.ToArray();}}

    // Add single detail string
    
    public void addDetail (string detail)
    {
      _details.Add(detail);
      return;
    }
    
    // Add a details with a severity level

    public void addDetail (string detail, int state)
    {
      addDetail(detail,state,0);
    }

    public void addDetail (string detail, int state, int referenceNumber)
    {  
      string refNumberStr = "";

      if (referenceNumber > 0)
      {
        refNumberStr = "(" + referenceNumber.ToString() + ") ";
      }      
      detail = "[" + state.ToString() + "]" + refNumberStr + detail;
      this.addDetail(detail);
      return;
    }


    // Parses a pipe or comma delimited string and adds as detail

    public void addDetails (string detailsin)
    {
      if (String.IsNullOrEmpty(detailsin)) return;
      detailsin = detailsin.Trim();
      string[] _detailsin = detailsin.Split(new char[]{'|',','},StringSplitOptions.RemoveEmptyEntries);
      foreach(string _detailin in _detailsin)
      {
        this.addDetail(_detailin);
      }
      return;
    }
  }
}











