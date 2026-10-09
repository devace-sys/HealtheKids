using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{   
  
  /***************************************************************************
   * WebReportDocument */
  /*
   * Base class for Spedmon reports
   * To use create two files report.ashx and report.ashx.cs
   * 
   * report.ashx should have the following line
   * 
   * <%@ WebHandler Language="C#" Class="MBA.EntityNameRpt" CodeBehind="report.ashx.cs"%>
   * 
   * report.ashx.cs should have the following lines
   * Note where you define permitted roles and the method callback
   * 
   * using System;
   * using System.Collections.Generic;
   * using System.Web;
   * 
   * namespace MBA
   * {
   * public class EntiyNameRpt : MBA.MBAReport
   * {    
   *   public EntityNameRpt()
   *   {
   *     this._permittedRoles = MBA.Constants.ROLE_ALL;
   *     this.cbReportData = delegate(){
   *     _cbAccessControl();
   *     return MBA.EntityName.viewPrev(dbConnMBA,log,rest of parms);
   *   };
   *  }
   * }
   *}
   * 
   * If you need to select a different method to return data use reptNum
   ***************************************************************************/

  public abstract class WebReportDocument : MBA.WebReportDocument
  {
   /*-------------------------------
    * Report Parameters
    *------------------------------*/

    protected string selpacode;
    protected string clientid;
    protected string siteid;
    protected string pracid;
    protected string approvingpracid;
    protected string groupid;
    protected string roleid;
    protected string patid;
    protected string referencedentityid;

    protected string dos;
    protected string dob;
    protected string submitclaims;
    protected string isIEP;
    protected string reference;
    protected string recUserID;
    protected string activeLEA;
    protected string activeMAA;
    protected string dateRange2;
    protected string proccode;
    protected string procmod1;
    protected string procmod2;
    protected string procmod3;
    protected string procmod4;
    protected string viewNotes;
    protected string svcclass;
    protected string groupServiceClassNameID;
    protected string svctypeid;
    protected string rptgroupid;

    /*-------------------------------
     * Clients View parameters
     * needed for filtering
     *------------------------------*/

    protected string approved_837;
    protected string approved_835;
    protected string rvnsharectgLEA;
    protected string rvnsharectgMAA;
    protected string clrepidLEA;
    protected string owndbycompidLEA;
    protected string owndbycompidMAA;
    protected string firstcheck;
    protected string lastcheck;

   /*-------------------------------
    * Calender and Bell schedule parameters
    * needed for filtering
    *------------------------------*/
   
   protected string fiscalyearid;
   protected string calendarid;
   protected string scheduleid;
   
   /*-------------------------------
    * File uploads and file storage
    * parameters needed for filtering
    *------------------------------*/
   
   protected string fileclass;
   protected string filenamespace;
   protected string filesource;
   protected string filedaterange;
   
   /*-------------------------------
    * Service journal
    *------------------------------*/

   protected string journalid;
   protected string journalentryid;
   
   /*-------------------------------
    * Man pages
    *------------------------------*/
   
   protected string pageID;
   protected string userHasBeenEmailedNoticeOfContent;
   protected string userHasSeenContent;
   protected string userWillReadContentLater;
   protected string userHasReadContent;
   
   /*-------------------------------
    * Promised service tracking 
    * related
    *------------------------------*/   

   protected string spEdServiceCode;
   protected string leaBopOnlyOrAllSped;         
   protected string orpDocID;
   protected string svcTrackingClass;
   protected string orpDocStandardSelectionNameID;
   protected string useMinsPerFreqAssigned;
   protected string practitionerPatientCaseloadExpectedServiceID;
   protected string pcalComplianceRatingForPat;
   protected string svcOverDelivery;

  /*-------------------------------
   * RMTS related
   *------------------------------*/
        
   protected string rmtsActivityCode;

  /*-------------------------------
   * Transport related
   *------------------------------*/

  protected string transmgmtid;
  
  /*-------------------------------
   * Patient person
   *------------------------------*/

  protected string personClassID1;
  protected string personClassID2;

   /*-------------------------------
    * Generic
    *------------------------------*/
   
   protected string responseCode;
   protected string requestID;
   protected string closed;
   protected string datasource;
   protected string reviewed;
   protected string includeContent;
   protected string hasAltFormat;
   protected string term;

    public WebReportDocument():base()
    { 
      
     /*-------------------------------
      * Retrieve standard report 
      * parameters
      *------------------------------*/

      selpacode               = MBA.HttpApplication.getParameter(Constants.PARM_SELPA_CODE);                
      clientid                = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
      siteid                  = MBA.HttpApplication.getParameter(Constants.PARM_SITE_ID);
      pracid                  = MBA.HttpApplication.getParameter(Constants.PARM_PRACTITIONER_ID);
      approvingpracid         = MBA.HttpApplication.getParameter("approvingpracid");
      groupid                 = MBA.HttpApplication.getParameter(Constants.PARM_GROUP_ID);
      rptgroupid              = MBA.HttpApplication.getParameter(Constants.PARM_RPT_GROUP_ID);
      roleid                  = MBA.HttpApplication.getParameter("roleid");
      patid                   = MBA.HttpApplication.getParameter(Constants.PARM_PATIENT_ID);
      referencedentityid      = MBA.HttpApplication.getParameter(Constants.PARM_REFERENCED_ENTITY_ID);
      dos                     = MBA.HttpApplication.getParameter(Constants.PARM_DOS);
      dob                     = MBA.HttpApplication.getParameter("dob");
      isIEP                   = MBA.HttpApplication.getParameter("isiep");
      reference               = MBA.HttpApplication.getParameter("reference");
      recUserID               = MBA.HttpApplication.getParameter("recuserid");
      activeLEA               = MBA.HttpApplication.getParameter("activelea");
      activeMAA               = MBA.HttpApplication.getParameter("activemaa");
      dateRange2              = MBA.HttpApplication.getParameter("daterange2");
      proccode                = MBA.HttpApplication.getParameter("proccode");
      procmod1                = MBA.HttpApplication.getParameter("procmod1");
      procmod2                = MBA.HttpApplication.getParameter("procmod2");
      procmod3                = MBA.HttpApplication.getParameter("procmod3");
      procmod4                = MBA.HttpApplication.getParameter("procmod4");
      viewNotes               = MBA.HttpApplication.getParameter("viewNotes");
      submitclaims            = MBA.HttpApplication.getParameter("submitclaims");
      svcclass                = MBA.HttpApplication.getParameter("svcclass");     
      svctypeid               = MBA.HttpApplication.getParameter(Constants.PARM_SVC_TYPE_ID);

      groupServiceClassNameID = MBA.HttpApplication.getParameter("groupServiceClassNameID");

      
      /* Forwards compatibility */
      if (String.IsNullOrEmpty(groupServiceClassNameID)) groupServiceClassNameID = MBA.HttpApplication.getParameter(Constants.PARM_GRP_SVC_CLS_NME_ID);

      /*-------------------------------
       * Retrieve Clients View parameters
       *------------------------------*/

      approved_837    = MBA.HttpApplication.getParameter("approved_837");
      approved_835    = MBA.HttpApplication.getParameter("approved_837");
      clrepidLEA      = MBA.HttpApplication.getParameter("clrepidLEA");
      owndbycompidLEA = MBA.HttpApplication.getParameter("owndbycompidLEA");
      owndbycompidMAA = MBA.HttpApplication.getParameter("owndbycompidMAA");
      firstcheck      = MBA.HttpApplication.getParameter("firstcheck");
      lastcheck       = MBA.HttpApplication.getParameter("lastcheck");
      rvnsharectgLEA  = MBA.HttpApplication.getParameter("rvnsharectgLEA");
      rvnsharectgMAA  = MBA.HttpApplication.getParameter("rvnsharectgMAA");

     /*-------------------------------------------------
      * Retrieve Calendar and Bell schedule parameters
      *-------------------------------------------------*/
      
      fiscalyearid    = MBA.HttpApplication.getParameter("fiscalyearid");
      calendarid      = MBA.HttpApplication.getParameter("calendarid");
      scheduleid      = MBA.HttpApplication.getParameter("scheduleid");
      
     /*-------------------------------------------------
      * Retrieve File Upload and Storage parameters
      *-------------------------------------------------*/
     
     fileclass        = MBA.HttpApplication.getParameter(Constants.PARM_FILE_CLASS);           
     filedaterange    = MBA.HttpApplication.getParameter(Constants.PARM_DATE_RANGE);
     filenamespace    = MBA.HttpApplication.getParameter(Constants.PARM_FILE_NAMESPACE);
     filesource       = MBA.HttpApplication.getParameter(Constants.PARM_FILE_SOURCE);

     /*-------------------------------
      * Service journal
      *------------------------------*/

     journalid      = MBA.HttpApplication.getParameter("journalid");
     journalentryid = MBA.HttpApplication.getParameter("journalentryid");
      
    /*-------------------------------
     * Man pages
     *------------------------------*/
   
    pageID                            = MBA.HttpApplication.getParameter("pageID"); 
    userHasBeenEmailedNoticeOfContent = MBA.HttpApplication.getParameter("userHasBeenEmailedNoticeOfContent");
    userHasSeenContent                = MBA.HttpApplication.getParameter("userHasSeenContent");
    userWillReadContentLater          = MBA.HttpApplication.getParameter("userWillReadContentLater");
    userHasReadContent                = MBA.HttpApplication.getParameter("userHasReadContent");

    /*-------------------------------
     * Promised service tracking
     * related
     *------------------------------*/

    spEdServiceCode               = MBA.HttpApplication.getParameter(Constants.PARM_SPED_SERVICE_CODE);
    leaBopOnlyOrAllSped           = MBA.HttpApplication.getParameter(Constants.PARM_LEA_BOP_ONLY_OR_ALL_SPED);      
    orpDocID                      = MBA.HttpApplication.getParameter(Constants.PARM_ORP_DOC_ID); 
    svcTrackingClass              = MBA.HttpApplication.getParameter(Constants.PARM_SVC_TRACKING_CLASS);
    orpDocStandardSelectionNameID = MBA.HttpApplication.getParameter(Constants.PARM_ORP_DOC_STD_SEL_NAME_ID);
    useMinsPerFreqAssigned        = MBA.HttpApplication.getParameter(Constants.PARM_USE_MINS_PER_FREQ_ASSIGNED);
    
    practitionerPatientCaseloadExpectedServiceID = MBA.HttpApplication.getParameter(Constants.PARM_PRAC_PAT_CASELOAD_EXPECTED_SVC_ID);
    pcalComplianceRatingForPat                   = MBA.HttpApplication.getParameter(Constants.PARM_PCAL_COMPLIANCE_RATING_FOR_PAT);
    svcOverDelivery                              = MBA.HttpApplication.getParameter(Constants.PARM_SVC_OVER_DELIVERY);

    /*-------------------------------
     * RMTS related
     *------------------------------*/

    rmtsActivityCode    = MBA.HttpApplication.getParameter(Constants.PARM_RMTS_ACTIVITY_CODE);
  
    /*-------------------------------
     * Transportation Related
     *------------------------------*/

    transmgmtid         = MBA.HttpApplication.getParameter(Constants.PARM_TRANS_MGMT_ID);

   /*-------------------------------
    * Patient person
    *------------------------------*/

    personClassID1  = MBA.HttpApplication.getParameter(Constants.PARM_PERSON_CLASS_ID_1);
    personClassID2  = MBA.HttpApplication.getParameter(Constants.PARM_PERSON_CLASS_ID_2);

    /*-------------------------------
     * Generic
     *------------------------------*/
   
    responseCode                      = MBA.HttpApplication.getParameter("responsecode");
    requestID                         = MBA.HttpApplication.getParameter("requestid");
    closed                            = MBA.HttpApplication.getParameter("closed");
    datasource                        = MBA.HttpApplication.getParameter(Constants.PARM_DATA_SOURCE);
    reviewed                          = MBA.HttpApplication.getParameter(Constants.PARM_REVIEWED);
    includeContent                    = MBA.HttpApplication.getParameter(Constants.PARM_INCLUDE_CONTENT);
    hasAltFormat                      = MBA.HttpApplication.getParameter(Constants.PARM_HAS_ALT_FORMAT);
    term                              = MBA.HttpApplication.getParameter(Constants.PARM_SEARCH_TERM);

   }
  }
}