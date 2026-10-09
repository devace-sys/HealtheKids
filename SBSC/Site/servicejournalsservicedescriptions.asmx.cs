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
   * ServiceJournalsServiceDescriptionsSvc */
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
  
  public class ServiceJournalsServiceDescriptionsSvc : MBA.WebSvc
  {
    
    /***************************************************************************
     * delete */
    /**
     * Deletes service description 
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
          return Spedmon.ServiceJournalsServiceDescriptions.delete (  ref this.rd
                                                                    , dbConnApp
                                                                    , log
                                                                    , uInfo
                                                                    , editDelReason
                                                                    , validaterec
                                                                    , recid);
        }
        ,Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }

    /***************************************************************************
     * save */
    /**
     * Save service description
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save (
         string clientid
       , string patid
       , string effectivedate
       , string diagnosis
       , string mdorders
       , string servicedescription
       , string expectedoutcomes
       , string iep
       , string siteaide
       , string busaide
       , string pracids
       , string details_pracs_training
       , string orpPracID 
       , string orpauthsvcdate
       , string svcauthstatusconfirmrespcode
       , string editDelReason
       , string validaterec
       , string savetype
       , string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {                     
        return Spedmon.ServiceJournalsServiceDescriptions.save (            
            ref this.rd
          , this.dbConnApp
          , this.log
          , this.uInfo   
          , clientid
          , patid
          , effectivedate
          , diagnosis
          , mdorders
          , servicedescription
          , expectedoutcomes
          , iep
          , siteaide
          , busaide
          , pracids
          , details_pracs_training 
          , orpPracID
          , orpauthsvcdate
          , svcauthstatusconfirmrespcode
          , editDelReason
          , validaterec
          , savetype
          , recid);                                           
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }
        
		
    /***************************************************************************
     * getServiceJournalsServiceDescription */
    /**
     * Get service description record
     * 
     * @param  clientid        Client id
	   * @param  patid           Patient id
	   * @param  referencedate   Date of service 
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnServiceJournalsServiceDescription getServiceJournalsServiceDescription (string clientid, string patid, string referencedate)
    {
      return (ReturnServiceJournalsServiceDescription) 
      callMethod(typeof(ReturnServiceJournalsServiceDescription), 
      delegate()
      {
        return Spedmon.ServiceJournalsServiceDescriptions.getServiceJournalsServiceDescription (this.dbConnApp, this.log, this.uInfo, clientid, patid, referencedate);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }
    
           
  }
}
