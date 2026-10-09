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
     * ClaimExceptionsSvc */
    /*
     * Web services end point for ClaimsProcessingException methods
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
  public class ClaimExceptionsSvc : MBA.WebSvc
  {
   
      public ClaimExceptionsSvc() : base() { }
    
   /***************************************************************************
    * delete */
   /**
    * "delete" a Claim Processing Exception record.
    * 
    * @param  validaterec   Required, True=Yes, False=No
    * @param  editDelReason Reason for delete
    * @param  recid         Record id to delete
    ***************************************************************************/

      [WebMethod]
      [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

      public ReturnSaveRecord delete(
                                    string editDelReason,
                                    string validaterec,
                                    string recid)
      {
          return (ReturnSaveRecord)
          callMethod(typeof(ReturnSaveRecord),
          delegate()
          {
              return Spedmon.ClaimsProcessingExceptions.delete(this.dbConnApp,
                                                 this.log,
                                                 this.uInfo,
                                                 editDelReason,
                                                 validaterec,
                                                 recid);
          },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
      }


    /***************************************************************************
     * save */
    /**
     * Save ClaimsProcessingExceptions records
     ***************************************************************************/

      [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save
      (string clientid,
       string pracid,
       string startDate,
       string endDate,
       string notes,
       string exceptionid,
       string editDelReason,
       string validaterec,
       string savetype,
       string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {
          return Spedmon.ClaimsProcessingExceptions.save
         (this.dbConnApp,
          this.log,
          this.uInfo,
          clientid,
          pracid, 
          startDate,
          endDate,
          notes,
          exceptionid,
          editDelReason,
          validaterec,
          savetype,
          recid);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }


    /***************************************************************************
     * viewSel */
    /**
     * Selection view of Claims Processing Exceptions
     * 
     * @param  clientid     Required, client id
     * @param  term         Required, search term string (blank for all)
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSel (string clientid, string term)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      {
        return Spedmon.ClaimsProcessingExceptions.viewSel(this.dbConnApp, this.log, this.uInfo, true, "", term);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

    /***************************************************************************
     * viewEntity */
    /**
     * Details about the given claimexceptionID
     *
     * @param  claimexceptionid     Required,  claimexceptionID
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnEntity viewEntity(string claimexceptionid)
    {
        return (ReturnEntity)
        callMethod(typeof(ReturnEntity),
        delegate()
        {
            ReturnEntity so = Spedmon.ClaimsProcessingExceptions.viewEntity(this.dbConnApp, this.log, this.uInfo, claimexceptionid);
            so.entity.notes = Util.textToHTMLPre(so.entity.notes);
            return so;
        },
        Constants.ROLE_SBS_ALL); // Who can call this method    
    }

    /***************************************************************************
     * viewSelExceptionList */
    /**
     * Selection view of ClaimsProcessingExceptionList
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSelExceptionList()
    {
        return (ReturnSel)
        callMethod(typeof(ReturnSel),
        delegate()
        {
            return Spedmon.ClaimsProcessingExceptionList.viewSel(this.dbConnApp, this.log, this.uInfo, false, "");
        },
        Constants.ROLE_SBS_ALL); // Who can call this method
    }

  }
}


