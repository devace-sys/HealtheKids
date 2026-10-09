using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;
using Newtonsoft.Json;

namespace Spedmon
{
    
  /**************************************************************************
   * ServiceRecordsExpectedEntryRow */
  /**
   * Note: All fields are initially set to null.  Keep it this way.
   ***************************************************************************/

  public class ServiceRecordsExpectedEntryRow {
    
    /* Entry data */

    public string   pracName                         = null;
    public string   patName                          = null;
	public string   dos                              = null; /* YYYY-MM-DD */
	public string   viatelehealth                    = null; /* 0 or 1 */   
	public string   isiep                            = null; /* 0 or 1.  Note: This is deprecated as we are converting over to svcnameslistdatasourceid */   
    public string   internalplantypeid               = null; /* 1,2,3, or 4 */
    public string   svcnameslistdatasourceid         = null; 
	public string   svcName                          = null;
    public string	altModalityNameID                = null;
    public string	nameid                           = null;
    public string	hasSvcDetFlags                   = null; /* true or false */
    public string	hasOrpSel                        = null; /* true or false */
    public string	orpDocSelectionAuto              = null; /* true or false*/
	public string	svcDetFlag1                      = null;	
    public string	svcDetFlag2                      = null;
    public string	svcDetFlag3                      = null;
    public string	svcDetFlag4                      = null;
    public string	orpDocumentName                  = null;
    public string	svcclientid                      = null;
    public string	svcpracid                        = null;
    public string	svcpatid                         = null;
    public string	svcTypeId                        = null;
    public string	svcSubType1Id                    = null;
    public string	orpDocumentID                    = null;
    public string	clientid                         = null;
    public string	pracid                           = null;
    public string	groupID                          = null;
    public string	patid                            = null;
    public string	startTime                        = null;
    public string	numMins                          = null;
    public string	attendanceStatusSelectionID      = null;
	public string   notes                            = null;		
    public string   svcNotesFormBuilderQuestionsJSON = null;
    public string   svcNotesFormBuilderAnswersJSON   = null;
    public string   patientGoalProgressJSON          = null;
    public string   hasPatientGoalTrackingData       = null; /* true or false */
    public string   createQuestionForm               = null; /* true or false */
    public string   RMTSMoment                       = null; /* true or false */      
    public string   hasSessionRatingTracking         = null; /* true or false */
    public string   hasFillablePdfSelections         = null; /* true or false*/
    public string   fillablePdfSelectionsJSON        = null; 
    public string   fillablePdfAnswersJSON           = null;

    /* Service selections */

    public string   serviceSelectionsJSON            = null;    
    public string   expectedEntryContext             = null;
    public string   scheduledServiceID               = null;

    public string   caseloadGrpId                    = null;   
    
  }
  
  
  /***************************************************************************
   * ServiceRecordsExpectedEntryRows */
  /**
   * 
   ***************************************************************************/

  public class ServiceRecordsExpectedEntryRows: Entities
  {    
    public const string URL_ASMX                                       = @"service_records_expected_entry_rows.asmx";
    public const string URL_ASMX_VIEW_LIST_EXP_TMT_SVCS_ON_DOS         = URL_ASMX + @"/viewListExpectedTmtSvcsOnDos";
    public const string URL_ASMX_VIEW_LIST_EXP_TMT_SVCS_ON_DOS_FOR_PAT = URL_ASMX + @"/viewListExpectedTmtSvcsOnDosForPat";
        
    /***************************************************************************
     * URL_ASMX_VIEW_LIST_EXP_TMT_SVCS_ON_DOS_BASE */
    /**
     * 
     ***************************************************************************/

    public static string URL_ASMX_VIEW_LIST_EXP_TMT_SVCS_ON_DOS_BASE()
    { 
       return MBA.HttpApplication.createLink(ServiceRecordsExpectedEntryRows.URL_ASMX_VIEW_LIST_EXP_TMT_SVCS_ON_DOS, true);
    }

    /***************************************************************************
     * URL_ASMX_VIEW_LIST_EXP_TMT_SVCS_ON_DOS_FOR_PAT_BASE */
    /**
     * 
     ***************************************************************************/
     
    public static string URL_ASMX_VIEW_LIST_EXP_TMT_SVCS_ON_DOS_FOR_PAT_BASE()
    {
       return MBA.HttpApplication.createLink(ServiceRecordsExpectedEntryRows.URL_ASMX_VIEW_LIST_EXP_TMT_SVCS_ON_DOS_FOR_PAT, true);
    }

    /***************************************************************************
     * viewListFromWorkInProgressSavePoint */
    /**
     * 
     ***************************************************************************/
    public static List<ServiceRecordsExpectedEntryRow> viewListFromWorkInProgressSavePoint (
          SqlConnection connSpedmon
        , DetailsLog    log
        , UserInfo      uInfo
        , ref WorkInProgressSavePoint sp) 
    {
      var recs = new List<ServiceRecordsExpectedEntryRow>();   
      string recDataJSON = sp.savedDataObject[Constants.PARM_SVC_REC_FOR_DOS_JSON];
      var recsDataArr = Newtonsoft.Json.Linq.JArray.Parse(recDataJSON);
      var rt = typeof(ServiceRecordsExpectedEntryRow);
      foreach (var recData in recsDataArr) {
        recs.Add((ServiceRecordsExpectedEntryRow) recData.ToObject(rt));
      }  
      return recs;   
   }

    /*****************************************************************************************************
     * convertListOfPractitionerCaseloadMemberExpectedSvcRecEntryDataToListOfServiceRecsExpectedEntryRow */
    /**
     * This does a partial conversion of a list of PractitionerCaseloadMemberExpectedSvcRecEntryData to
     * a list of ServiceRecordsExpectedEntryRow
     *****************************************************************************************************/        
    protected static List<ServiceRecordsExpectedEntryRow> convertListOfPractitionerCaseloadMemberExpectedSvcRecEntryDataToListOfServiceRecsExpectedEntryRow (
          SqlConnection connSpedmon
        , DetailsLog    log
        , UserInfo      uInfo
        , ref List<PractitionerCaseloadMemberExpectedSvcRecEntryData> recsIn)
    {
      var recsOut = new List<ServiceRecordsExpectedEntryRow>();   
      foreach (var recIn in recsIn) {
        
        var recOut = new ServiceRecordsExpectedEntryRow();
        recOut.clientid                 = recIn.clientID.ToString();
        recOut.pracid                   = recIn.pracID.ToString();    
        recOut.pracName                 = recIn.pracName;
        recOut.groupID                  = recIn.groupID.ToString();
        recOut.patid                    = recIn.patID.ToString();
        recOut.patName                  = recIn.patName;
        recOut.svcclientid              = recOut.clientid;
        recOut.svcpracid                = recOut.pracid;
        recOut.svcpatid                 = recOut.patid;
        recOut.dos                      = recIn.dosYMD;
        recOut.isiep                    = Util.boolTo1or0Str(recIn.planIsIEPIFSP);
        recOut.internalplantypeid       = recIn.internalPlanTypeID.ToString();
        recOut.svcnameslistdatasourceid = recIn.svcNamesListDataSourceID.ToString(); /* Services.isIEPIFSPAndBillingProgramIDToSvcNameListDataSourceID(recIn.planIsIEPIFSP, Services.BILLING_PROGRAM_ID_LEA_BOP).ToString(); */
        recOut.viatelehealth            = Util.boolTo1or0Str(recIn.viaTeleHealth);
        recOut.nameid                   = recIn.serviceNameID.ToString();        
        recOut.svcName                  = recIn.serviceName;
        recOut.numMins                  = recIn.numMins.ToString();
        recOut.startTime                = recIn.startTimeHMS;
        recOut.serviceSelectionsJSON    = recIn.serviceSelectionsJSON;
        recOut.svcTypeId                = recIn.svcTypeID.ToString();
        recOut.svcSubType1Id            = recIn.svcSubTypeID.ToString();
        recOut.expectedEntryContext     = recIn.expectedEntryContext;
        if (recIn.scheduledServiceID.HasValue) {
          recOut.scheduledServiceID = recIn.scheduledServiceID.Value.ToString();
        }

        if (recIn.caseloadGrpID != 0)
        {
            recOut.caseloadGrpId = recIn.caseloadGrpID.ToString();
        }
        recsOut.Add(recOut);
      }
      return recsOut;
    }

   /***************************************************************************
    * viewListFromExpectedTmtSvcsOnDos */
   /**
    * Note: This adds additional data to the list of 
    * ServiceRecordsExpectedEntryRow(s)
    ***************************************************************************/
   public static List<ServiceRecordsExpectedEntryRow> viewListFromExpectedTmtSvcsOnDos (
         SqlConnection connSpedmon
       , DetailsLog    log
       , UserInfo      uInfo
       , string        clientID
       , string        pracID
       , string        patID
       , string        dos 
       , string        pracpatgroupid )     
   {            
      
      var recsOut = new List<ServiceRecordsExpectedEntryRow>();

      /* Get list of scheduled services from caseload data */

      var scheduledServices = PractitionerCaseloadMembers.viewListExpectedSvcsOnDos (connSpedmon,log,uInfo,clientID,pracID,patID,dos,pracpatgroupid,false);

      /* Convert list of scheduled services to list of expected entry rows */

      var expectedEntries = convertListOfPractitionerCaseloadMemberExpectedSvcRecEntryDataToListOfServiceRecsExpectedEntryRow(connSpedmon,log,uInfo,ref scheduledServices);
      
      /* Add additional data to list of expected entry rows */
      
      foreach (var recOut in expectedEntries) {
         
         /* Get service data that matches nameid */
         
         var svcSelDataItems  = Spedmon.Services.viewSel2 ( connSpedmon
                                                          , log
                                                          , uInfo
                                                          , recOut.clientid
                                                          , recOut.pracid
                                                          , recOut.patid
                                                          , recOut.dos
                                                          , recOut.svcnameslistdatasourceid
                                                          , null
                                                          , recOut.viatelehealth
                                                          , recOut.nameid );
         
         /* If a match is found */

         if (svcSelDataItems.SelRecs.Length != 0) 
         { 
           var svcSelDataItem = svcSelDataItems.SelRecs[0];
           
           /* If service is an assessment */

           if (svcSelDataItem.flag1 == 1) {
             recOut.orpDocSelectionAuto = "false";
             recOut.hasOrpSel           = "false";
             if (svcSelDataItem.showOptions2 == "SHOW_SPEECH_ASSESS_OPTIONS")  {                  
                recOut.hasSvcDetFlags = "true";                  
             }
             else {
               recOut.hasSvcDetFlags = "false";
             }
           }
           
           /* If service is a treatment */

           else if (svcSelDataItem.flag1 == 2) {

                recOut.hasSvcDetFlags      = "false";
                recOut.svcDetFlag1         = "";
                recOut.svcDetFlag2         = "";
                recOut.svcDetFlag3         = "";
                recOut.svcDetFlag4         = "";
               
                /* And its a treatment that requires an orp doc */

                if (svcSelDataItem.recData14 == "1") { 
                 
                 /* Determine if the orp doc can be auto selected or it must be explicity selected */

                 if ((svcSelDataItem.showOptions2 == "SHOW_TREATMENT_ORP_DOC_SELECTION") && (svcSelDataItem.recData3 == "0")) {
                    recOut.hasOrpSel           = "true";
                    recOut.orpDocSelectionAuto = "false";                  
                  }                
                  else {
                    recOut.hasOrpSel           = "true";
                    recOut.orpDocSelectionAuto = "true";                  
                 }
               } 

               /* And its a treatment that does not require an orp doc */

               else
               {
                 recOut.hasOrpSel           = "false";
                 recOut.orpDocSelectionAuto = "false"; 
               }
           }
           
           /* Any other service */

           else {
                  recOut.hasSvcDetFlags      = "false";
                  recOut.hasOrpSel           = "false";
                  recOut.hasSvcDetFlags      = "false";
                  recOut.orpDocSelectionAuto = "false";                  
           }

           recOut.svcName           = svcSelDataItem.label;
           recOut.altModalityNameID = svcSelDataItem.recData13;
                  
           /* Get any note form data */

           var svcFormData = Spedmon.ClaimServiceNameXrefAndFormDataRecords.loadN ( connSpedmon
                                                                                   , log
                                                                                   , uInfo
                                                                                   , 0
                                                                                   , recOut.clientid
                                                                                   , recOut.internalplantypeid
                                                                                   , recOut.groupID
                                                                                   , recOut.nameid);           
           recOut.svcNotesFormBuilderQuestionsJSON = "{}";
           recOut.svcNotesFormBuilderAnswersJSON   = "{}";
           //recOut.svcTypeId                        = svcFormData.svcTypeId.ToString();
           //recOut.svcSubType1Id                    = svcFormData.svcSubType1Id.ToString();
           
           if (svcFormData.hasFormData == true) {
             recOut.svcNotesFormBuilderQuestionsJSON = svcFormData.formDataJson;
             recOut.svcNotesFormBuilderAnswersJSON   = "{}";
           }
         
           recOut.hasPatientGoalTrackingData = Util.netBoolToJSBool(svcFormData.hasPatientGoalTracking);
           recOut.hasSessionRatingTracking   = Util.netBoolToJSBool(svcFormData.hasSessionRatingTracking);
           recOut.patientGoalProgressJSON    = @"[]";         

           recOut.hasFillablePdfSelections    = Util.netBoolToJSBool(svcFormData.hasFillablePdfSelections);
           recOut.fillablePdfSelectionsJSON   = svcFormData.fillablePdfSelectionsJSON;                                 
           recOut.fillablePdfAnswersJSON      = @"[]";
         }
         recsOut.Add(recOut);         
      }
                     
      return recsOut;
   }

   /***************************************************************************
    * viewListFromExpectedAssmtSvcs */
   /**
    * Note: This returns basically just a list of patients.  The dos is 
    * blanked out.
    * 
    * TODO: Enhance the UDF that is called to return as many fields as needed
    * 
    ***************************************************************************/
   public static List<ServiceRecordsExpectedEntryRow> viewListFromExpectedAssmtSvcs (
         SqlConnection connSpedmon
       , DetailsLog    log
       , UserInfo      uInfo
       , string        clientID
       , string        pracID
       , string        dos
       , bool          limitToPatsInCaseload)     
   {            
      var recsOut = new List<ServiceRecordsExpectedEntryRow>();   
      var recsIn = PractitionerCaseloadMembers.viewListExpectedAssmtSvcs (connSpedmon,log,uInfo,clientID,pracID,dos,limitToPatsInCaseload,false);
      recsOut = convertListOfPractitionerCaseloadMemberExpectedSvcRecEntryDataToListOfServiceRecsExpectedEntryRow (connSpedmon,log,uInfo,ref recsIn);

      /* Note: The following is to blank out the date of service */

      for (var idx=0;idx < recsOut.Count;idx++)
      {
        recsOut[idx].dos = @"";
      }
      return recsOut;
   }
    
 } 
}

