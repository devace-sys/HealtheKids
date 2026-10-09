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
   * PotentialLostReimbursementsResponsesSvc */
  /*
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
  public class PotentialLostReimbursementsResponsesSvc : MBA.WebSvc
  {
    public PotentialLostReimbursementsResponsesSvc() : base() { }
    
    /***************************************************************************
     * save */
    /**
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save (
         string recid
       , string deferred
       , string notes
       , string savetype
    )
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {                     
        return Spedmon.PotentialLostReimbursementsResponses.save (                        
            this.dbConnApp
          , this.log
          , this.uInfo   
          , recid
          , deferred
          , notes
          , ""
          , "0"
          , savetype);                                           
      },
      Constants.ROLE_SBS_ALL_LEA_COORD);  // Who can call this method           
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSaveRecord deferbatch(string clientid, string recidmulti)
    {
        return (ReturnSaveRecord)
        callMethod(typeof(ReturnSaveRecord),
        delegate ()
        {
            return Spedmon.PotentialLostReimbursementsResponses.deferBatch(
                    this.dbConnApp
                , this.log
                , this.uInfo
                , clientid
                , recidmulti);
        },
         Constants.ROLE_SBS_ALL_LEA_COORD);       
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

   
    public ReturnSaveRecord undeferbatch(string clientid, string recidmulti)
    {
        return (ReturnSaveRecord)
        callMethod(typeof(ReturnSaveRecord),
        delegate ()
        {
          return Spedmon.PotentialLostReimbursementsResponses.undeferBatch(
                  this.dbConnApp
                , this.log
                , this.uInfo
                , clientid
                , recidmulti);
        }, Constants.ROLE_SBS_ALL_LEA_COORD);          
    }

    }
}
