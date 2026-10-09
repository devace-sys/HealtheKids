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
   * ClientsSvc */
  /*
   * Web services end point for Clients methods
   *
   * Unless indicated, each of these methdos are for sbs users only
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

  public class ClientsSvc : MBA.WebSvc
  {
    public ClientsSvc() : base() { }

    /***************************************************************************
     * delete */
    /**
     * "delete" a Client record.
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
              return Spedmon.Clients.delete(this.dbConnApp,
                                                 this.log,
                                                 this.uInfo,
                                                 editDelReason,
                                                 validaterec,
                                                 recid);
          },
            Constants.ROLE_SBS_ALL);  // Who can call this method           
      }

    /***************************************************************************
     * save */
    /**
     * Save client records
     ***************************************************************************/                                        

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save
      (string clientName,
       string clientCDS,
       string NPI,
       string tax_ID,
       string firstcheck,
       string approved_837,
       string approved_835,
       string EIN,
       string COE,
       string LEA,
       string MAA,
       string rvnsharectgLEA,
       string rvnsharectgMAA,
       string clrepidLEA,
       string clrepidMAA,
       string owndbycompidLEA,
       string owndbycompidMAA,
       string lecorlgaid,
       string shortname,
       string namercgbyDHCS_EDS,
       string LEARecoveryBudget,
       string street1,
       string street2,
       string city,
       string state,
       string zip5,
       string zip4,
       string lname,
       string fname,
       string title,
       string phone,
       string fax,
       string email,
       string svcrecapprovalsystem,
       string notes,
       string claim_TCM,
       string claim_TCMEffectiveDate,
       string parentConsentAgreement,
       string parentConsentAgreementEffectiveDate,
       string sendUsersEmailNotifications,
       string planWriterAccessGranted,
       string planWriterAccessEndDate,
       string numDaysToHoldClientEnteredClaims,
       string autoGenerate837File,
       string teleCommTeleHealthAccessGranted,
       string teleCommTeleHealthAccessEndDate,
       string teleCommTeleIEPAccessGranted,
       string teleCommTeleIEPAccessEndDate,
       string hyQueueFee,
       string planWriterFee,
       string baselineReimbursement,
       string carePlanLegalLang,
       string clientlogofiledata,
       string cronTabExpectedTotPop,
       string cronTabExpectedSpecEdSvcs,
       string sendRequestsForTotPop,
       string sendRequestsForSpEd,
       string selpaCode,
       string sendElibilityDataMatchRequestsToDHCS,
       string cdecomplianceclient,
       string cybhi,
       string fuzzymatchsitesbynameandcode,
       string cybhiclientcode,
       string initialContractStartDate,
       string healtheKids_percent,
       string cybhi_percent,
       string crcs_percent,
       string cdeReporting_percent,
       string planImplementation_percent,
       string ruHealth_percent,
       string newProduct2_percent,
       string newProduct3_percent,
       string accounting_percent,
       string flatFee_amount,

       //string practiCal_percent,
       //string spEdCare_percent,

       string csba_percent,
       string lba_percent,
       string partner1_percent,
       string partner1E_percent,
       string partner2_percent,
       string clientRetention,

       string mba_bba_percent,

       //string mba_dg_percent,

       string spEdCare_bba_percent,

       //string spEdCare_dg_percent,

       string smaa_1_percent,
       string smaa_2_percent,
       string smaa_3_percent,

       string cybhidonotclaimoverappingleabopsvcs,
       string cybhiaddonmissinginforequeststopatientpersons,
       string cybhiconsortiumbilling,
       string cybhiconsortiumleadClientID,
       string leabopconsortiumbilling,
       string leabopconsortiumLeadClientID,
       string cybhitpaapproved,
       string cybhitpaapprovedon,
       string cybhitpaid,
       string cybhisubmitclaims,
       string cybhiclinicalsupervisorpracid,
       string impliedferpaconsent,

       string cybhiclientname,
       string cybhinpi,
       string cybhitaxid,
       string cybhiaddress1,
       string cybhiaddress2,
       string cybhicity,
       string cybhistate,
       string cybhizip5,
       string cybhizip4,
       string cybhigenerate837,
       string cybhiautogenerate837,
       string cybhinumdaystoholdenteredclaims, 
                                      
       string editDelReason,
       string validaterec,
       string savetype,
       string recid )
    {
      return (ReturnSaveRecord)

      callMethod(typeof(ReturnSaveRecord),
      delegate()
      {
        return Spedmon.Clients.save
         (this.dbConnApp,
          this.log,
          this.uInfo,
          clientName,
          clientCDS,
          NPI,
          tax_ID,
          firstcheck,
          approved_837,
          approved_835,
          EIN,
          COE,
          LEA,
          MAA,
          rvnsharectgLEA,
          rvnsharectgMAA,
          clrepidLEA,
          clrepidMAA,
          owndbycompidLEA,
          owndbycompidMAA,
          lecorlgaid,
          shortname,
          namercgbyDHCS_EDS,
          LEARecoveryBudget,
          street1,
          street2,
          city,
          state,
          zip5,
          zip4,
          lname,
          fname,
          title,
          phone,
          fax,
          email,
          svcrecapprovalsystem,
          notes,
          claim_TCM,
          claim_TCMEffectiveDate,
          parentConsentAgreement,
          parentConsentAgreementEffectiveDate,
          sendUsersEmailNotifications,
          planWriterAccessGranted,
          planWriterAccessEndDate,
          numDaysToHoldClientEnteredClaims,
          autoGenerate837File,
          teleCommTeleHealthAccessGranted,
          teleCommTeleHealthAccessEndDate,
          teleCommTeleIEPAccessGranted,
          teleCommTeleIEPAccessEndDate,
          hyQueueFee,
          planWriterFee,
          baselineReimbursement,
          carePlanLegalLang,
          clientlogofiledata,
          cronTabExpectedTotPop,
          cronTabExpectedSpecEdSvcs,
          sendRequestsForTotPop,
          sendRequestsForSpEd,
          selpaCode,

          sendElibilityDataMatchRequestsToDHCS,
          cdecomplianceclient,
          cybhi,
          fuzzymatchsitesbynameandcode,
          cybhiclientcode,
          initialContractStartDate,
          healtheKids_percent,
          cybhi_percent,
          crcs_percent,
          cdeReporting_percent,
          planImplementation_percent,
          ruHealth_percent,
          newProduct2_percent,
          newProduct3_percent,
          accounting_percent,
          flatFee_amount,

          //practiCal_percent,
          //spEdCare_percent,

          csba_percent,
          lba_percent,
          partner1_percent,
          partner1E_percent,
          partner2_percent,
          clientRetention,

          mba_bba_percent,
          //mba_dg_percent,
          spEdCare_bba_percent,
          //spEdCare_dg_percent,
          smaa_1_percent,
          smaa_2_percent,
          smaa_3_percent,

          cybhidonotclaimoverappingleabopsvcs,
          cybhiaddonmissinginforequeststopatientpersons,
          cybhiconsortiumbilling,
          cybhiconsortiumleadClientID,
          leabopconsortiumbilling,
          leabopconsortiumLeadClientID,
          cybhitpaapproved,
          cybhitpaapprovedon,
          cybhitpaid,
          cybhisubmitclaims,
          cybhiclinicalsupervisorpracid,
          impliedferpaconsent,

          cybhiclientname,
          cybhinpi,
          cybhitaxid,
          cybhiaddress1,
          cybhiaddress2,
          cybhicity,
          cybhistate,
          cybhizip5,
          cybhizip4,
          cybhigenerate837,
          cybhiautogenerate837,
          cybhinumdaystoholdenteredclaims,

          editDelReason,
          validaterec,
          savetype,
          recid);
      },
      Constants.ROLE_SBS_ALL);  // Who can call this method           
    }

    /***************************************************************************
    * viewEntity */
    /**
    * Details about the given clientID
    *
    * @param  clientid     Required, client ID
    ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnEntity viewEntity(string clientid)
    {
      return (ReturnEntity)
      callMethod(typeof(ReturnEntity), 
      delegate()
      {
        ReturnEntity so = Spedmon.Clients.viewEntity(this.dbConnApp,this.log, this.uInfo,clientid);
        so.entity.notes = Util.textToHTMLPre(so.entity.notes);
        return so;
      },
      Constants.ROLE_SBS_ALL); // Who can call this method    
    }     
  
  /***************************************************************************
    * viewSel */
    /**
    * Selection view of clients
    *
    * @param  term         Required, search term string (blank for all)
    ***************************************************************************/

     
      /* TODO:  This widget is used on the Add New Report Subscription page on the SpedCare website.
       * We want an internal user to have the ability to subscribe to a report that is filtered by client ID, or not-filtered by client ID.
       * Thus, we should modify this widget to show an "All Clients" option at the top of the drop-down, to make the process more intuitive.  -JM */
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnSel viewSel(string term)
    {
      return (ReturnSel)
      callMethod(typeof(ReturnSel), 
      delegate()
      {
        return Spedmon.Clients.viewSel(this.dbConnApp, this.log, this.uInfo, true, "", term); 
      },
      Constants.ROLE_SBS_ALL); // Who can call this method    
    }


   /***************************************************************************
    * viewSelWithPcal */
    /**
    * Selection view of clients including dummy record for practi-cal
    *
    * @param  term         Required, search term string (blank for all)
    ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnSel viewSelWithPcal (string term)
    {
      return (ReturnSel)
      callMethod(typeof(ReturnSel), 
      delegate()
      {
        return Spedmon.Clients.viewSelWithPcal (this.dbConnApp, this.log, this.uInfo, true, "", term); 
      },
      Constants.ROLE_SBS_ALL); // Who can call this method    
    }
  }
}
