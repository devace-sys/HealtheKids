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
   * ClientPBSDocumentationSvc */
  /*
   * Web services end point.
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
  
  public class ClientPBSDocumentationSvc : MBA.WebSvc
  {

    /***************************************************************************
     * delete */
    /**
     * "Deletes" record
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/  

    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord delete (string editDelReason,
                                    string validaterec,
                                    string recid)
    {
      return (ReturnSaveRecord)
      callMethod(typeof(ReturnSaveRecord),    
        delegate() {    
          return Spedmon.ClientPBSDocumentation.delete(   dbConnApp
                                                        , log
                                                        , uInfo
                                                        , editDelReason
                                                        , validaterec
                                                        , recid);
        },
        Constants.ROLE_SBS_ALL);  // Who can call this method           
    }
    
    /***************************************************************************
     * save */
    /**
     * Save new or edit existing record
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save (
         string clientid
       , string groupServiceClassNameID
       , string orpPracID
       , string startDate
       , string endDate
       , string notes
       , string editDelReason
       , string validaterec
       , string savetype
       , string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {                     
        return Spedmon.ClientPBSDocumentation.save (                        
            this.dbConnApp
          , this.log
          , this.uInfo   
          , clientid
          , groupServiceClassNameID
          , orpPracID
          , startDate
          , endDate
          , notes
          , editDelReason
          , validaterec
          , savetype
          , recid);                                           
      },
      Constants.ROLE_SBS_ALL);  // Who can call this method           
    }        		           
  }
}
