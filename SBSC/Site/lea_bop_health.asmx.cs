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
   * LeaBopHealthSvc */
  /*
   * Web services end points 
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
  
  public class LeaBopHealthSvc : MBA.WebSvc
  {
    public LeaBopHealthSvc() : base() { }
    
    /***************************************************************************
     * getreimbursementamtbydosforthisyear */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnTotalNumAmt getreimbursementamtbydosforthisyear (string clientid, string repid)
    {
        return (ReturnTotalNumAmt)
        callMethod(typeof(ReturnTotalNumAmt),
        delegate ()
        {
           return Spedmon.PotentialLostReimbursementActionItems.getTotalNumAmt(dbConnApp, log, uInfo, clientid, repid, PotLstRbrActItmSel.ReimbursementHistoryByDOSThisYear);
        }, Constants.ROLE_LEA_BOP_HEALTH_MANAGE); // Who can call this method
    }   
    
    /***************************************************************************
     * getreimbursementamtbydowforthisyear */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnTotalNumAmt getreimbursementamtbydowforthisyear (string clientid, string repid)
    {
        return (ReturnTotalNumAmt)
        callMethod(typeof(ReturnTotalNumAmt),
        delegate ()
        {
           return Spedmon.PotentialLostReimbursementActionItems.getTotalNumAmt(dbConnApp, log, uInfo, clientid, repid, PotLstRbrActItmSel.ReimbursementHistoryByCheckDateThisYear);
        }, Constants.ROLE_LEA_BOP_HEALTH_MANAGE); // Who can call this method
    }   


    /***************************************************************************
     * getpotlostreimbursementserviceauth */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnTotalNumAmt getpotlostreimbursementserviceauth (string clientid)
    {
        return (ReturnTotalNumAmt)
        callMethod(typeof(ReturnTotalNumAmt),
        delegate ()
        {
           return Spedmon.PotentialLostReimbursementActionItems.getTotalNumAmt(dbConnApp, log, uInfo, clientid, null, PotLstRbrActItmSel.ServiceAuthorization);
        }, Constants.ROLE_LEA_BOP_HEALTH_MANAGE); // Who can call this method
    }   

    /***************************************************************************
     * getpotlostreimbursementrmtspart */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnTotalNumAmt getpotlostreimbursementrmtspart (string clientid)
    {
        return (ReturnTotalNumAmt)
        callMethod(typeof(ReturnTotalNumAmt),
        delegate ()
        {
           return Spedmon.PotentialLostReimbursementActionItems.getTotalNumAmt(dbConnApp, log, uInfo, clientid, null, PotLstRbrActItmSel.RmtsParticipation);
        }, Constants.ROLE_LEA_BOP_HEALTH_MANAGE); // Who can call this method
    }   

    /***************************************************************************
     * getpotlostreimbursementpracsup */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnTotalNumAmt getpotlostreimbursementpracsup (string clientid)
    {
        return (ReturnTotalNumAmt)
        callMethod(typeof(ReturnTotalNumAmt),
        delegate ()
        {
           return Spedmon.PotentialLostReimbursementActionItems.getTotalNumAmt(dbConnApp, log, uInfo, clientid, null, PotLstRbrActItmSel.PractitionerSupervision);
        }, Constants.ROLE_LEA_BOP_HEALTH_MANAGE); // Who can call this method
    }

    /***************************************************************************
     * getpotlostreimbursementmissingtmts */
    /**
     **************************************************************************/
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnTotalNumAmt getpotlostreimbursementmissingtmts(string clientid)
    {
        return (ReturnTotalNumAmt)
        callMethod(typeof(ReturnTotalNumAmt),
        delegate ()
        {
           return Spedmon.PotentialLostReimbursementActionItems.getTotalNumAmt(dbConnApp, log, uInfo, clientid, null, PotLstRbrActItmSel.MissingSpEdTreatments);
        }, Constants.ROLE_LEA_BOP_HEALTH_MANAGE); // Who can call this method
    }

    /***************************************************************************
     * getpotlostreimbursementmissingasmts */
    /**
     **************************************************************************/
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnTotalNumAmt getpotlostreimbursementmissingasmts(string clientid)
    {
        return (ReturnTotalNumAmt)
        callMethod(typeof(ReturnTotalNumAmt),
        delegate ()
        {
           return Spedmon.PotentialLostReimbursementActionItems.getTotalNumAmt(dbConnApp, log, uInfo, clientid, null, PotLstRbrActItmSel.MissingAssessments);
        }, Constants.ROLE_LEA_BOP_HEALTH_MANAGE); // Who can call this method
    }

    /***************************************************************************
     * getpotlostreimbursementparentconsent */
    /**
     **************************************************************************/
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnTotalNumAmt getpotlostreimbursementparentconsent (string clientid)
    {
        return (ReturnTotalNumAmt)
        callMethod(typeof(ReturnTotalNumAmt),
        delegate ()
        {
           return Spedmon.PotentialLostReimbursementActionItems.getTotalNumAmt(dbConnApp, log, uInfo, clientid, null, PotLstRbrActItmSel.ParentConsent);
        }, Constants.ROLE_LEA_BOP_HEALTH_MANAGE); // Who can call this method
    }

    /***************************************************************************
     * getpotlostreimbursementamts */
    /**
     **************************************************************************/
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnTotalNumAmts getpotlostreimbursementamts (string clientid, string repid)
    {
      return (ReturnTotalNumAmts)
        callMethod(typeof(ReturnTotalNumAmts),
        delegate ()
        {
           return Spedmon.PotentialLostReimbursementActionItems.getTotalNumAmts(dbConnApp, log, uInfo, clientid, repid);
        }, Constants.ROLE_LEA_BOP_HEALTH_MANAGE); // Who can call this method
    }

    /***************************************************************************
     * getclaimspaid2p */
    /**
     **************************************************************************/
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnClaimsPaid2P getclaimspaid2p (string clientid, string repid)
    {
      return (ReturnClaimsPaid2P)
        callMethod(typeof(ReturnClaimsPaid2P),
        delegate ()
        {
           return Spedmon.PotentialLostReimbursementActionItems.getClaimsPaid2PAll(dbConnApp, log, uInfo, clientid, repid, "");
        }, Constants.ROLE_LEA_BOP_HEALTH_MANAGE); // Who can call this method
    }

    
  }
}
