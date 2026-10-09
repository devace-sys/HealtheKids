using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.Services.Protocols;
using System.Web.Script.Serialization;
using System.ComponentModel;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * CompanyFiscalYearsSvc */
  /*
   * Unless indicated, each of these methods require that the caller is
   * logged in.
   *
   * Each end point method provides a wrapper for a corresponding framework
   * method that is not accessible from the outside.
   *
   * These wrappers handle access control and parameter replacement.
   *
   * The method is restricted to calls for given user groups
   *
   * Parameter replacement is used to enforce additional access control within
   * the user group but this is limited.
   *
   * The final line of defense for access control are the database udfs or
   * sprocs that return or save data
   ***************************************************************************/

  [WebService(Namespace = "http://spedcare.com/")]
  [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
  [ScriptService]
  
  public class CompanyFiscalYearsSvc : MBA.WebSvc
  {
    public CompanyFiscalYearsSvc() : base() { }
   
    /***************************************************************************
     * viewSel */
    /**
     * 
     * @param  term         Required, search term string (blank for all)
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSel ( 
          string term 
        //, string yearsback  // TODO: Figure out how to send yearsBack and yearsForward to this method from DataEntryRowSelectFiscalYear control. Currently they are hard-coded.
        //, string yearsforward
        //, string year
    )
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      {
        string yearsBack    = "2";
        string yearsForward = "1";
        if (uInfo.pcalStaff) yearsBack = "7"; /* 7 years is a standard practice for audit purposes */

        return Spedmon.CompanyFiscalYears.viewSel(this.dbConnApp, this.log, this.uInfo, true, "", term, yearsBack, yearsForward, DateTime.Now.ToString("yyyy-MM-dd"));
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

    /***************************************************************************
     * viewSel2 */
    /**
     * 
     * @param  term         Required, search term string (blank for all)
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSel2 ( string term )
    {

      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      {
                
        return Spedmon.CompanyFiscalYears.viewSel(
              this.dbConnApp
            , this.log
            , this.uInfo
            , true
            , ""
            , term
            , "10"
            , "2"
            , DateTime.Now.ToString("yyyy-MM-dd"));
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method

    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnValue getQuarterID(string fyearID, string quarterNumber)
    {

      return (ReturnValue)
      callMethod(typeof(ReturnValue), 
      delegate()
      {
        //string v;
        ReturnValue val = new ReturnValue();

        var fiscalQuarter =

        CompanyFiscalQuarters.load(
        this.dbConnApp,
        this.log,
        this.uInfo,
        "1",
        null,
        fyearID,
        quarterNumber,
        null
        );

        val.value = fiscalQuarter.id.ToString();
        
        return val;
      },
      Constants.ROLE_ALL); // Who can call this method    

    }
  
  }  
}

