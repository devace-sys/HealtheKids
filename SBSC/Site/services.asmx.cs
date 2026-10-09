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
   * services.asmx */
  /*
   * Web services end point for services methods
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

  public class ServicesSvc : MBA.WebSvc
  {    
    /***************************************************************************
     * viewEntity */
    /**
     * Details about the given clientID, patID
     *
     * @param  clientID       Required, client ID
     * @param  patID          Required, patient ID
     ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnEntity viewEntity(string clientid, string patid, string pracid, string nameid, string isiep, string dossvcs, string recid)
    {
      return (ReturnEntity)
      callMethod(typeof(ReturnEntity), 
      delegate()
      {
        ReturnEntity so = Spedmon.Services.viewEntity(this.dbConnApp,this.log,this.uInfo,clientid,patid,pracid,nameid,isiep,dossvcs,recid);
        so.entity.notes = Util.textToHTMLPre(so.entity.notes);
        return so; 
      },
      Constants.ROLE_SBS_ALL); // Who can call this method
    }      

    /***************************************************************************
     * viewSel */
    /**
     * Selection view of services that can be rendered by a provider
     * 
     * @param  clientid     Required, client id
     * @param  pracid       Required, practitoner id
     * @param  patid        Required, patient id
     * @param  dos          Required, date of service
     * @param  isIEP        Required, is IEP or IFSP
     * @param  term         Search term string (blank for all)
     ***************************************************************************/
 
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
 
    public ReturnSel viewSel(string clientid, string pracid, string patid, string dos, string isiep, string term)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel), 
      delegate()
      {
        return Spedmon.Services.viewSel(this.dbConnApp,this.log, this.uInfo, clientid,pracid,patid,dos,isiep,term);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method            
    }

    /***************************************************************************
     * viewSel2 */
    /**
     * Selection view of services that can be rendered by a provider
     * 
     * @param  clientid     Required, client id
     * @param  pracid       Required, practitoner id
     * @param  patid        Required, patient id
     * @param  dos          Required, date of service
     * @param  isIEP        Required, is IEP or IFSP
     * @param  term         Search term string (blank for all)
     ***************************************************************************/
 
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
 
    public ReturnSel viewSel2 (string clientid, string pracid, string patid, string dos, string svcnameslistdatasourceid, string term, string viatelehealth)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel), 
      delegate()
      {        
        return Spedmon.Services.viewSel2(this.dbConnApp,this.log, this.uInfo, clientid,pracid,patid,dos,svcnameslistdatasourceid,term,viatelehealth);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method            
    }

    /***************************************************************************
     * viewSelTmtTcmTrans */
    /**
     * Selection view of services that can be rendered by a provider
     * 
     * @param  clientid     Required, client id
     * @param  pracid       Required, practitoner id
     * @param  patid        Required, patient id
     * @param  dos          Required, date of service
     * @param  isIEP        Required, is IEP or IFSP
     * @param  term         Search term string (blank for all)
     ***************************************************************************/
 
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
 
    public ReturnSel viewSelTmtTcmTrans (string clientid, string pracid, string svcnameslistdatasourceid, string dos, string term)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel), 
      delegate()
      {
        return Spedmon.Services.viewSelTmtTcmTrans (this.dbConnApp,this.log, this.uInfo, clientid, pracid, svcnameslistdatasourceid, dos, term);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method            
    }            

    /***************************************************************************
     * viewSelForPlanTypeGroupID */
    /**
     * General selection view of services by plantype, group, and name
     * Not to be used for service record entry
     ***************************************************************************/
 
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
 
    public ReturnSel viewSelForPlanTypeGroupID (string plantype, string groupid, string term)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel), 
      delegate()
      {
        return Spedmon.Services.viewSelForPlanTypeGroupID(this.dbConnApp,this.log, this.uInfo,plantype,groupid,term);
      },
      Constants.ROLE_SBS_ALL); // Who can call this method            
    }
  }
}
