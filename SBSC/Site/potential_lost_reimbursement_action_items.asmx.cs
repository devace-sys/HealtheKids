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
using System.IO;

namespace Spedmon
{
  /***************************************************************************
   * PotentialLostReimbursementActionItemsSvc */
  /*
   * Web services end point for Client Contact methods
   *
   * Unless indicated, each of these methods require that the caller is 
   * logged in.
   * 
   * Each end point method provides a wrapper for a coresponding framework
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
  public class PotentialLostReimbursementActionItemsSvc : MBA.WebSvc
  {
    public PotentialLostReimbursementActionItemsSvc() : base() { }
    
   
    /***************************************************************************
     * getmissingassmts */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnTotalNumAmt getmissingassmts ()
    {
        return (ReturnTotalNumAmt)
        callMethod(typeof(ReturnTotalNumAmt),
        delegate ()
        {
           return Spedmon.PotentialLostReimbursementActionItems.getTotalNumAmt(dbConnApp, log, uInfo, PotLstRbrActItmSel.MissingAssessments);
        }, Constants.ROLE_ACTION_ITEM_PLR_ALL); // Who can call this method
    }

    /***************************************************************************
     * getmissingspedtreatments */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnTotalNumAmt getmissingspedtreatments ()
    {
        return (ReturnTotalNumAmt)
        callMethod(typeof(ReturnTotalNumAmt),
        delegate ()
        {
           return Spedmon.PotentialLostReimbursementActionItems.getTotalNumAmt(dbConnApp, log, uInfo, PotLstRbrActItmSel.MissingSpEdTreatments);
        }, Constants.ROLE_ACTION_ITEM_PLR_ALL); // Who can call this method
    }
    /***************************************************************************
     * getparentconsent */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnTotalNumAmt getparentconsent ()
    {
        return (ReturnTotalNumAmt)
        callMethod(typeof(ReturnTotalNumAmt),
        delegate ()
        {
           return Spedmon.PotentialLostReimbursementActionItems.getTotalNumAmt(dbConnApp, log, uInfo, PotLstRbrActItmSel.ParentConsent);
        }, Constants.ROLE_ACTION_ITEM_PLR_ALL); // Who can call this method
    }

    /***************************************************************************
     * getserviceauthorization */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnTotalNumAmt getserviceauthorization ()
    {
        return (ReturnTotalNumAmt)
        callMethod(typeof(ReturnTotalNumAmt),
        delegate ()
        {
           return Spedmon.PotentialLostReimbursementActionItems.getTotalNumAmt(dbConnApp, log, uInfo, PotLstRbrActItmSel.ServiceAuthorization);
        }, Constants.ROLE_ACTION_ITEM_PLR_ALL); // Who can call this method
    }

    /***************************************************************************
     * getreimbursementhistorybydosthisyear */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnTotalNumAmt getreimbursementhistorybydosthisyear()
    {
        return (ReturnTotalNumAmt)
        callMethod(typeof(ReturnTotalNumAmt),
        delegate ()
        {
           return Spedmon.PotentialLostReimbursementActionItems.getTotalNumAmt(dbConnApp, log, uInfo, PotLstRbrActItmSel.ReimbursementHistoryByDOSThisYear);
        }, Constants.ROLE_ACTION_ITEM_PLR_ALL); // Who can call this method
    }
    
    /***************************************************************************
     * getreimbursementhistorybydoslastyear */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnTotalNumAmt getreimbursementhistorybydoslastyear()
    {
        return (ReturnTotalNumAmt)
        callMethod(typeof(ReturnTotalNumAmt),
        delegate ()
        {
           return Spedmon.PotentialLostReimbursementActionItems.getTotalNumAmt(dbConnApp, log, uInfo, PotLstRbrActItmSel.ReimbursementHistoryByDOSLastYear);
        }, Constants.ROLE_ACTION_ITEM_PLR_ALL); // Who can call this method
    }

    /***************************************************************************
     * getreimbursementhistorybycheckdatethisyear */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnTotalNumAmt getreimbursementhistorybycheckdatethisyear()
    {
        return (ReturnTotalNumAmt)
        callMethod(typeof(ReturnTotalNumAmt),
        delegate ()
        {
           return Spedmon.PotentialLostReimbursementActionItems.getTotalNumAmt(dbConnApp, log, uInfo, PotLstRbrActItmSel.ReimbursementHistoryByCheckDateThisYear);
        }, Constants.ROLE_ACTION_ITEM_PLR_ALL); // Who can call this method
    }

    /***************************************************************************
     * getreimbursementhistorybycheckdatelastyear */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnTotalNumAmt getreimbursementhistorybycheckdatelastyear()
    {
        return (ReturnTotalNumAmt)
        callMethod(typeof(ReturnTotalNumAmt),
        delegate ()
        {
           return Spedmon.PotentialLostReimbursementActionItems.getTotalNumAmt(dbConnApp, log, uInfo, PotLstRbrActItmSel.ReimbursementHistoryByCheckDateLastYear);
        }, Constants.ROLE_ACTION_ITEM_PLR_ALL); // Who can call this method
    }

    /***************************************************************************
     * getreimbursementhistoryanngoalamt */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnTotalNumAmt getreimbursementhistoryanngoalamt()
    {
        return (ReturnTotalNumAmt)
        callMethod(typeof(ReturnTotalNumAmt),
        delegate ()
        {
           return Spedmon.PotentialLostReimbursementActionItems.getTotalNumAmt(dbConnApp, log, uInfo, PotLstRbrActItmSel.ReimbursementHistoryAnnGoalAmt);
        }, Constants.ROLE_ACTION_ITEM_PLR_ALL); // Who can call this method
    }

  }
}
