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
   * ServiceJournalsPrescribedOrdersSvc */
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
  
  public class ServiceJournalsPrescribedOrdersSvc : MBA.WebSvc
  {


    /***************************************************************************
     * delete */
    /**
     * "Deletes" order
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
          return Spedmon.ServiceJournalsPrescribedOrders.delete( ref this.rd
                                                                , dbConnApp
                                                                , log
                                                                , uInfo
                                                                , editDelReason
                                                                , validaterec
                                                                , recid);
        },
        Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }
    
    /***************************************************************************
     * save */
    /**
     * Save prescribed orders
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save (
         string clientid
       , string patid
       , string effectivedate
       , string enddate
       , string svcname
       , string orpdocstdnameselid
       , string svcdesc
       , string notecrit1
       , string notecrit2
       , string notecrit3
       , string notecrit4
       , string allowmultipleorders
       , string ordercontextfieldname
       , string formBuilderQuestionsJSON
       , string formBuilderAnswersJSONForOrder
       , string noteobsvcmnt
       , string iep
       , string dailyfreq
       , string pracids
       , string details_pracs_training
       , string groupserviceclassnameid 
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
        return Spedmon.ServiceJournalsPrescribedOrders.save (            
            ref this.rd
          , this.dbConnApp
          , this.log
          , this.uInfo   
          , clientid
          , patid
          , effectivedate
          , enddate
          , svcname
          , orpdocstdnameselid
          , svcdesc
          , notecrit1
          , notecrit2
          , notecrit3
          , notecrit4
          , allowmultipleorders
          , ordercontextfieldname
          , formBuilderQuestionsJSON
          , formBuilderAnswersJSONForOrder
          , noteobsvcmnt
          , iep
          , dailyfreq
          , pracids
          , details_pracs_training
          , groupserviceclassnameid
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
     * saveOrderOrProfile */
    /**
     * Save order or profile
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord saveOrderOrProfile(
         string clientid
       , string patid
       , string orpdoctype
       , string effectivedate
       , string enddate
       , string svcname
       , string orpdocstdnameselid
       , string svcdesc
       , string notecrit1
       , string notecrit2
       , string notecrit3
       , string notecrit4
       , string notecrit5
       , string notecrit6
       , string notecrit7
       , string notecrit8
       , string notecrit9
       , string notecrit10
       , string expectedoutcomes
       , string allowmultipleorders
       , string ordercontextfieldname
       , string formBuilderQuestionsJSON
       , string formBuilderAnswersJSONForOrder
       , string noteobsvcmnt
       , string iep
       , string frequency
       , string projectedminutes
       , string planstartdate
       , string planenddate
       , string siteaide
       , string busaide
       , string dailyfreq
       , string pracids
       , string details_pracs_training
       , string groupserviceclassnameid 
       , string orpPracID
       , string orpauthsvcdate
       , string orpauthexpdate
       , string svcauthstatusconfirmrespcode       
       , string diagnosis       
       , string mdorders
       , string editDelReason
       , string validaterec
       , string savetype
       , string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {                     
        return Spedmon.ServiceJournalsPrescribedOrders.saveOrderOrProfile (            
            ref this.rd
          , this.dbConnApp
          , this.log
          , this.uInfo   
          , clientid
          , patid
          , orpdoctype
          , effectivedate
          , enddate
          , svcname
          , orpdocstdnameselid
          , svcdesc
          , notecrit1
          , notecrit2
          , notecrit3
          , notecrit4
          , notecrit5
          , notecrit6
          , notecrit7
          , notecrit8
          , notecrit9
          , notecrit10
          , expectedoutcomes
          , allowmultipleorders
          , ordercontextfieldname
          , formBuilderQuestionsJSON
          , formBuilderAnswersJSONForOrder
          , noteobsvcmnt
          , iep
          , frequency
          , projectedminutes
          , planstartdate
          , planenddate
          , siteaide
          , busaide
          , dailyfreq
          , pracids
          , details_pracs_training
          , groupserviceclassnameid
          , orpPracID
          , orpauthsvcdate
          , orpauthexpdate
          , svcauthstatusconfirmrespcode
          , diagnosis
          , mdorders
          , editDelReason
          , validaterec
          , savetype
          , recid);                                           
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }
        		
    /***************************************************************************
     * getPrescribedOrders */
    /**
     * Get prescribed orders
     * 
     * @param  clientid        Client id
	   * @param  patid           Patient id
	   * @param  referencedate   Date of service 
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnServiceJournalsPrescribedOrders getPrescribedOrders (string clientid, string patid, string referencedate)
    {
      return (ReturnServiceJournalsPrescribedOrders) 
      callMethod(typeof(ReturnServiceJournalsPrescribedOrders), 
      delegate()
      {
        return Spedmon.ServiceJournalsPrescribedOrders.getServiceJournalsPrescribedOrders (this.dbConnApp, this.log, this.uInfo, clientid, patid, referencedate);
      },
      Constants.ROLE_LEA_PROVIDER); // Who can call this method
    }    
    

  }
}
