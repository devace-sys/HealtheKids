using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;
using Newtonsoft.Json;

namespace Spedmon
{
    
  /**************************************************************************
   * PractitionerPatientScheduledService */
  /**
   * 
   ***************************************************************************/

  public class PractitionerPatientScheduledService:Entity
  {
      public const string DEFAULT_PAGING_ORDER = "clientName, pracName, patName, startDate desc, svcName";
	  
      public long     practitionerPatientCaseloadExpectedServiceID;
      public long     caseloadGrpID;
	  public long     clientID;
      public string   clientName;
	  public long     pracID;
	  public string   pracName;
      public long     patID;
      public string   patName;  
	  public long     groupID; 
      public string   groupName;
	  public int      svcNamesListDataSourceID;	 
	  public string   svcNamesListDataSourceName;                      
	  public bool     viaTeleHealth;
      public string   viaTeleHealthYN;
	  public long     nameID; 
      public long     altModalityNameID;
      public string   svcName;
	  public bool     recurring;
      public string   recurringYN;

	  public TimeSpan startTime;
	  public int      numMins;

      public bool     mon;
	  public TimeSpan monStartTime;	
      public bool     tue;
	  public TimeSpan tueStartTime;
      public bool     wed;
	  public TimeSpan wedStartTime;
      public bool     thu;
	  public TimeSpan thuStartTime;	  
      public bool     fri;
	  public TimeSpan friStartTime;      
      public DateTime refDate;
      public bool     occursOnRefDate;
      public string   whenSummary;
		
      public string startDateStr;
	  public string startDateYMD;

	  public string endDateStr; 
	  public string endDateYMD; 

      public string startTimeStr; 
      public string startTimeHMS; 
	
	  public string monStartTimeStr; 
	  public string monStartTimeHMS; 

  	  public string tueStartTimeStr; 
	  public string tueStartTimeHMS; 

	  public string  wedStartTimeStr; 
	  public string  wedStartTimeHMS;

      public string  thuStartTimeStr;
	  public string  thuStartTimeHMS;

      public string  friStartTimeStr;   
	  public string  friStartTimeHMS;

      public string  refDateStr;
      public string  occursOnRefDateStr;
      
      public bool    scheduleHasExpired;
      public string  scheduleHasExpiredStr;

      public int     dateRangeBeforeInOrAfterRefDateVal;
      public string  dateRangeBeforeInOrAfterRefDateName;

	}

  
  /***************************************************************************
   * PractitionerPatientScheduledServices */
  /**
   * 
   ***************************************************************************/

  public class PractitionerPatientScheduledServices: Entities
  {

    public const string SEL_LABEL               = "Scheduled Service";
    public const string SEL_LABEL_EXPORT        = "Scheduled Services";
    public const string SEL_LABEL_ADD_NEW       = SEL_LABEL + " - New";
    public const string SEL_LABEL_EDIT          = SEL_LABEL + " - Edit";
    public const string SEL_LABEL_MANAGE        = @"Manage My Scheduled Services";

    public const string MENU_ID                 = @"pracpatscheduledsvcsmanagelink";
    public const string URL_USER_ALL_MANAGE     = @"user_all_practitioner_patient_scheduled_services_manage.aspx";
    public const string URL_USER_ALL_SAVE       = @"user_all_practitioner_patient_scheduled_service_save.aspx";
    
    public const string URL_SVC                 = @"practitioner_patient_scheduled_services.asmx";
    public const string URL_WEB_REPORT          = @"practitioner_patient_scheduled_services.ashx";
	                                              
    public const string URL_SVC_DELETE_INLINE   = URL_SVC + "/deleteinline"; 
    public const string URL_SVC_SAVE            = URL_SVC + "/save";
    public const string URL_SVC_SAVE_MULTIPLE   = URL_SVC + "/savemultiple";
    public const string URL_REST_VIEW           = @"api/v1/practitionerpatientscheduledservices";
    
    
	/***************************************************************************
     * URL_REST VIEW_BASE */
    /**
     * 
     ***************************************************************************/

    public static string URL_REST_VIEW_BASE()
    { 
       return MBA.HttpApplication.createLink(URL_REST_VIEW, true);
    }

    /***************************************************************************
     * URL_MANAGE_BASE */
    /**
     * 
     **************************************************************************/
    public static string URL_MANAGE_BASE()
    { 
       return MBA.HttpApplication.createLink ( URL_USER_ALL_MANAGE
                                              , true
                                              , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE));     
    }

    /***************************************************************************
     * URL_ADD_NEW_BASE */
    /**
     * 
     **************************************************************************/
    public static string URL_ADD_NEW_BASE()
    {
      return MBA.HttpApplication.createLink(  URL_USER_ALL_SAVE
                                            , true
                                            , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                            , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW)
                                           );
    }

    /***************************************************************************
     * URL_EDIT_BASE */
    /**
     * 
     **************************************************************************/
    public static string URL_EDIT_BASE()
    {
      return MBA.HttpApplication.createLink ( URL_USER_ALL_SAVE
                                             , true
                                             , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                             , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT)
                                             /*, new NameValue(Constants.PARM_REC_ID, @"")*/
                                            );
    }

    /***************************************************************************
     * URL_SVC_DELETE_INLINE_BASE */
    /**
     * 
     **************************************************************************/
    public static string URL_SVC_DELETE_INLINE_BASE()
    {
      return MBA.HttpApplication.createLink (URL_SVC_DELETE_INLINE, true);
    }

    /***************************************************************************
     * URL_SVC_SAVE_BASE */
    /**
     * 
     **************************************************************************/
    public static string URL_SVC_SAVE_BASE()
    {
      return MBA.HttpApplication.createLink (URL_SVC_SAVE, true);
    }

    /***************************************************************************
     * URL_SVC_SAVE_BASE_MULTIPLE */
    /**
     * 
     **************************************************************************/
    public static string URL_SVC_SAVE_BASE_MULTIPLE()
    {
      return MBA.HttpApplication.createLink (URL_SVC_SAVE_MULTIPLE, true);
    }
    
    /***************************************************************************
     * URL_WEB_REPORT_BASE */
    /**
     * 
     **************************************************************************/
    public static string URL_WEB_REPORT_BASE()
    {
      return MBA.HttpApplication.createLink (URL_WEB_REPORT, true);
    }
        
    /***************************************************************************
     * delete */
    /**
     * 
     ***************************************************************************/

    public static ReturnSaveRecord delete (
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        clientID
      , string        pracID      
      , string        editDelReason
      , string        validateRec       
	  , string        recID )
    {

      /*----------------------------
       * Check for required and 
       * optional parameters
       * and validate data integrity
       * of all supplied parameters
       *----------------------------*/

      long   vClientID = Validate.reqClientID (uInfo, clientID);
      long   vPracID   = Validate.reqPracID   (uInfo, pracID);
      
      /*----------------------------
       * Collect all of the parameters
       * that are specific to this
       * delete method.
       *----------------------------*/

      var parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt,   vClientID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",    SqlDbType.BigInt,   vPracID,   ParameterDirection.Input));
      
      /*----------------------------
       * Call base method 
       *----------------------------*/

      return Entities.delete (connSpedmon, log, uInfo, editDelReason, validateRec, recID, "Practitioner_Patient_Scheduled_Services_Delete", ref parms);
    }
   

   /***************************************************************************
    * save */
   /**
    *
    ***************************************************************************/

    public static ReturnSaveRecord save (
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        clientID
      , string        pracID
      , string        patID
      , string        caseloadGrpID
      , string        svcNamesListDataSourceID
	  , string        viaTeleHealth
	  , string        nameID
	  , string        recurring
      , string        practitionerPatientCaseloadExpectedServiceID
	  , string        startDate
	  , string        endDate
	  , string        startTime
	  , string        numMins
      , string        mon
	  , string        monStartTime	 
      , string        tue
	  , string        tueStartTime
      , string        wed
	  , string        wedStartTime
      , string        thu
	  , string        thuStartTime
      , string        fri
	  , string        friStartTime
	  , string        notes
      , string        editDelReason
      , string        validateRec
      , string        saveType 
      , string        recID )
      
    {           
                  
      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      var parms = new List<SqlParameter>();
      
      long     vClientID                 = Validate.reqClientID  (uInfo, clientID);
      long     vPracID                   = Validate.reqPracID    (uInfo, pracID);
      long     vPatID                    = Validate.reqPatID     (uInfo, patID);
      Object   vCaseloadGrpID            = Validate.optInteger   (caseloadGrpID,            @"Invalid caseload group id");
      int      vSvcNamesListDataSourceID = Validate.reqInteger   (svcNamesListDataSourceID, Messages.INVALID_PLAN_TYPE);
      bool     vViaTeleHealth            = Validate.reqFlag      (viaTeleHealth,            @"Invalid value for via telehealth");
      long     vNameID                   = Validate.reqInteger   (nameID,                   Messages.INVALID_NAME_ID);
      bool     vRecurring                = Validate.reqFlag      (recurring,                @"Invalid value for recurring");
      
      Object   vPractitionerPatientCaseloadExpectedServiceID = Validate.optInteger(practitionerPatientCaseloadExpectedServiceID,@"Invalid expected service ID",true);

      DateTime vStartDate                = Validate.reqDate      (startDate,                Messages.INVALID_START_DATE);
      Object   vEndDate                  = Validate.optDate      (endDate,                  Messages.INVALID_END_DATE);
      Object   vStartTime                = Validate.optTime      (startTime,                Messages.INVALID_START_TIME);
      Object   vNumMins                  = Validate.optInteger   (numMins,                  Messages.INVALID_NUM_MINS, true);

      Object vMon                        = Validate.optFlag   (mon,           @"Invalid value for Mon");
      Object vMonStartTime               = Validate.optTime   (monStartTime,  @"Invalid start time for Mon");
      Object vTue                        = Validate.optFlag   (tue,           @"Invalid value for Tue");
      Object vTueStartTime               = Validate.optTime   (tueStartTime,  @"Invalid start time for Tue");
      Object vWed                        = Validate.optFlag   (wed,           @"Invalid value for Wed");
      Object vWedStartTime               = Validate.optTime   (wedStartTime,  @"Invalid start time for Wed");
      Object vThu                        = Validate.optFlag   (thu,           @"Invalid value for Thu");
      Object vThuStartTime               = Validate.optTime   (thuStartTime,  @"Invalid start time for Thu");
      Object vFri                        = Validate.optFlag   (fri,           @"Invalid value for Fri");
      Object vFriStartTime               = Validate.optTime   (friStartTime,  @"Invalid start time for Fri");
      Object vNotes                      = Validate.optString (notes, Messages.INVALID_NOTES);

      parms.Add(Database.SqlParm("@clientID",                  SqlDbType.BigInt,   vClientID,                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",                    SqlDbType.BigInt,   vPracID,                    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",                     SqlDbType.BigInt,   vPatID,                     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@caseloadGrpID",             SqlDbType.BigInt,   vCaseloadGrpID,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@svcNamesListDataSourceID",  SqlDbType.Int,      vSvcNamesListDataSourceID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@viaTeleHealth",             SqlDbType.Bit,      vViaTeleHealth,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@nameID",                    SqlDbType.BigInt,   vNameID,                    ParameterDirection.Input)); 
      parms.Add(Database.SqlParm("@recurring",                 SqlDbType.Bit,      vRecurring,                 ParameterDirection.Input));    
      
      parms.Add(Database.SqlParm("@practitionerPatientCaseloadExpectedServiceID", SqlDbType.BigInt, vPractitionerPatientCaseloadExpectedServiceID, ParameterDirection.Input)); 

      parms.Add(Database.SqlParm("@startDate",                 SqlDbType.Date,     vStartDate,                 ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",                   SqlDbType.Date,     vEndDate,                   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startTime",                 SqlDbType.Time,     vStartTime,                 ParameterDirection.Input));
      parms.Add(Database.SqlParm("@numMins",                   SqlDbType.Int,      vNumMins,                   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@mon",                       SqlDbType.Bit,      vMon,                       ParameterDirection.Input));   
      parms.Add(Database.SqlParm("@monStartTime",              SqlDbType.Time,     vMonStartTime,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@tue",                       SqlDbType.Bit,      vTue,                       ParameterDirection.Input));   
      parms.Add(Database.SqlParm("@tueStartTime",              SqlDbType.Time,     vTueStartTime,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@wed",                       SqlDbType.Bit,      vWed,                       ParameterDirection.Input));   
      parms.Add(Database.SqlParm("@wedStartTime",              SqlDbType.Time,     vWedStartTime,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@thu",                       SqlDbType.Bit,      vThu,                       ParameterDirection.Input));   
      parms.Add(Database.SqlParm("@thuStartTime",              SqlDbType.Time,     vThuStartTime,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fri",                       SqlDbType.Bit,      vFri,                       ParameterDirection.Input));   
      parms.Add(Database.SqlParm("@friStartTime",              SqlDbType.Time,     vFriStartTime,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@notes",                     SqlDbType.VarChar,  vNotes,                     ParameterDirection.Input, -1));

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.save (connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "Practitioner_Patient_Scheduled_Services_Save", @"This service is already scheduled" , ref parms, null);

   }    

    /***************************************************************************
    * save */
    /**
    *
    ***************************************************************************/

    public static ReturnSaveRecord savemultiple (
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        clientID
      , string        pracID
      , string        caseloadGrpID
      , string        patSelectedJSON
      , string        svcNamesListDataSourceID
	  , string        viaTeleHealth
	  , string        nameID
	  , string        recurring
	  , string        startDate
	  , string        endDate
	  , string        startTime
	  , string        numMins
      , string        mon
	  , string        monStartTime	 
      , string        tue
	  , string        tueStartTime
      , string        wed
	  , string        wedStartTime
      , string        thu
	  , string        thuStartTime
      , string        fri
	  , string        friStartTime
	  , string        notes
      , string        editDelReason
      , string        validateRec
      , string        saveType 
      , string        recID )
      
    {           
                  
      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      var parms = new List<SqlParameter>();
      
      long     vClientID                 = Validate.reqClientID  (uInfo, clientID);
      long     vPracID                   = Validate.reqPracID    (uInfo, pracID);
      Object   vCaseloadGrpID            = Validate.optInteger   (caseloadGrpID,            @"Invalid caseload group id");
      string   vPatSelectedJSON          = Validate.reqString    (patSelectedJSON,          @"Invalid patient data");
      int      vSvcNamesListDataSourceID = Validate.reqInteger   (svcNamesListDataSourceID, Messages.INVALID_PLAN_TYPE);
      bool     vViaTeleHealth            = Validate.reqFlag      (viaTeleHealth,            @"Invalid value for via telehealth");
      long     vNameID                   = Validate.reqInteger   (nameID,                   Messages.INVALID_NAME_ID);
      bool     vRecurring                = Validate.reqFlag      (recurring,                @"Invalid value for recurring");

      DateTime vStartDate                = Validate.reqDate      (startDate,                Messages.INVALID_START_DATE);
      Object   vEndDate                  = Validate.optDate      (endDate,                  Messages.INVALID_END_DATE);
      Object   vStartTime                = Validate.optTime      (startTime,                Messages.INVALID_START_TIME);
      Object   vNumMins                  = Validate.optInteger   (numMins,                  Messages.INVALID_NUM_MINS, true);

      Object vMon                        = Validate.optFlag   (mon,           @"Invalid value for Mon");
      Object vMonStartTime               = Validate.optTime   (monStartTime,  @"Invalid start time for Mon");
      Object vTue                        = Validate.optFlag   (tue,           @"Invalid value for Tue");
      Object vTueStartTime               = Validate.optTime   (tueStartTime,  @"Invalid start time for Tue");
      Object vWed                        = Validate.optFlag   (wed,           @"Invalid value for Wed");
      Object vWedStartTime               = Validate.optTime   (wedStartTime,  @"Invalid start time for Wed");
      Object vThu                        = Validate.optFlag   (thu,           @"Invalid value for Thu");
      Object vThuStartTime               = Validate.optTime   (thuStartTime,  @"Invalid start time for Thu");
      Object vFri                        = Validate.optFlag   (fri,           @"Invalid value for Fri");
      Object vFriStartTime               = Validate.optTime   (friStartTime,  @"Invalid start time for Fri");
      Object vNotes                      = Validate.optString (notes, Messages.INVALID_NOTES);

      parms.Add(Database.SqlParm("@clientID",                  SqlDbType.BigInt,   vClientID,                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",                    SqlDbType.BigInt,   vPracID,                    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@caseloadGrpID",             SqlDbType.BigInt,   vCaseloadGrpID,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patSelectedJSON",           SqlDbType.VarChar,  vPatSelectedJSON,           ParameterDirection.Input, -1)); 
      parms.Add(Database.SqlParm("@svcNamesListDataSourceID",  SqlDbType.Int,      vSvcNamesListDataSourceID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@viaTeleHealth",             SqlDbType.Bit,      vViaTeleHealth,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@nameID",                    SqlDbType.BigInt,   vNameID,                    ParameterDirection.Input)); 
      parms.Add(Database.SqlParm("@recurring",                 SqlDbType.Bit,      vRecurring,                 ParameterDirection.Input));  

      parms.Add(Database.SqlParm("@startDate",                 SqlDbType.Date,     vStartDate,                 ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",                   SqlDbType.Date,     vEndDate,                   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startTime",                 SqlDbType.Time,     vStartTime,                 ParameterDirection.Input));
      parms.Add(Database.SqlParm("@numMins",                   SqlDbType.Int,      vNumMins,                   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@mon",                       SqlDbType.Bit,      vMon,                       ParameterDirection.Input));   
      parms.Add(Database.SqlParm("@monStartTime",              SqlDbType.Time,     vMonStartTime,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@tue",                       SqlDbType.Bit,      vTue,                       ParameterDirection.Input));   
      parms.Add(Database.SqlParm("@tueStartTime",              SqlDbType.Time,     vTueStartTime,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@wed",                       SqlDbType.Bit,      vWed,                       ParameterDirection.Input));   
      parms.Add(Database.SqlParm("@wedStartTime",              SqlDbType.Time,     vWedStartTime,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@thu",                       SqlDbType.Bit,      vThu,                       ParameterDirection.Input));   
      parms.Add(Database.SqlParm("@thuStartTime",              SqlDbType.Time,     vThuStartTime,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fri",                       SqlDbType.Bit,      vFri,                       ParameterDirection.Input));   
      parms.Add(Database.SqlParm("@friStartTime",              SqlDbType.Time,     vFriStartTime,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@notes",                     SqlDbType.VarChar,  vNotes,                     ParameterDirection.Input, -1));

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.save (connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "PRACTITIONER_PATIENT_SCHEDULED_SERVICES_SAVE_MULTIPLE", @"This service is already scheduled" , ref parms, null);

   } 
                                                    
   /***************************************************************************
    * view */
   /**
    * 
    ***************************************************************************/   

    public static ReturnDB view (  SqlConnection connSpedmon
	                             , DetailsLog    log
								 , UserInfo      uInfo
                                 , int           recViewType
                                 , bool          pagedOrTop
                                 , string        idx
                                 , string        canEdit
                                 , string        active
                                 , string        clientID
                                 , string        pracID
                                 , string        patID
                                 , string        practitionerPatientCaseloadExpectedServiceID
                                 , defineCols    dc)
    { 
      
      string viewUDF = "Practitioner_Patient_Scheduled_Services_View (@userID, @userGroup, @userRank, @clientID, @pracID, @patID, @practitionerPatientCaseloadExpectedServiceID, @active, @recID)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      var parms = new List<SqlParameter>();
      
      long   vClientID    = Validate.reqClientID  (uInfo, clientID);
      long   vPracID      = Validate.reqPracID    (uInfo, pracID);      
      Object vPatID       = Validate.optPatID     (uInfo, patID);      
      Object vPpcesID     = Validate.optInteger   (practitionerPatientCaseloadExpectedServiceID, @"Invalid expected service ID");
            
      parms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt,  vClientID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",    SqlDbType.BigInt,  vPracID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",     SqlDbType.BigInt,  vPatID,     ParameterDirection.Input));

      parms.Add(Database.SqlParm("@practitionerPatientCaseloadExpectedServiceID", SqlDbType.BigInt, vPpcesID, ParameterDirection.Input));
            
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
      
      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

   }  

   /***************************************************************************
    * load */
   /**
    *
    ***************************************************************************/ 
    
    public static PractitionerPatientScheduledService load (  SqlConnection connSpedmon
                                                            , DetailsLog    log
                                                            , UserInfo      uInfo
                                                            , string        clientID
                                                            , string        pracID
                                                            , string        recID)
    { 
      return (PractitionerPatientScheduledService) Entities.load (connSpedmon, log, uInfo , recID, typeof(PractitionerPatientScheduledService),
      delegate{return PractitionerPatientScheduledServices.view (connSpedmon,log,uInfo,Entities.REC_VIEW_LOAD, false, recID, "", "", clientID, pracID, "", "",null);});
    } 

    /***************************************************************************
     * viewTbl */
    /**
     *
     ***************************************************************************/
    public static ReturnDataTable viewTbl (  SqlConnection connSpedmon
                                           , DetailsLog    log
                                           , UserInfo      uInfo
                                           , bool          paged
                                           , string        pageNumber
                                           , string        canEdit
                                           , string        active
                                           , string        clientID
                                           , string        pracID
                                           , string        patID
                                           , string        practitionerPatientCaseloadExpectedServiceID)
    {
      ReturnDataTable so = new ReturnDataTable();

      /*----------------------------
       * Define our columns and
       * set the page order for
       * paging
       *----------------------------*/

      defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        ss.addDisplayColumn("patName                             as [Student\nLast, First]", true);
        ss.addDisplayColumn("startDateStr                        as [Start\nDate]",true);
        ss.addDisplayColumn("endDateStr                          as [End\nDate]",true);
        ss.addDisplayColumn("dateRangeBeforeInOrAfterRefDateName as [Dates Are]");
        ss.addDisplayColumn("scheduleHasExpiredStr               as [Schedule\nExpired]");
        ss.addDisplayColumn("svcNamesListDataSourceName as [Plan\nType]");
        ss.addDisplayColumn("svcName                    as [Service]");
        ss.addDisplayColumn("numMins                    as [Number\nof\nMinutes]");
        ss.addDisplayColumn("viaTelehealthYN            as [Via\nTele\nHealth?]");
        ss.addDisplayColumn("recurringYN                as [Recurring?]");
        ss.addDisplayColumn("whenSummary                as [Service Is\nProvided On]");
        ss.addDisplayColumn("notes                      as [Notes]");  
        pageroworder = ss.pageRowOrder();
      };

      /*----------------------------
       * Call base method which
       * handles the rest
       *----------------------------*/

      so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber, delegate {
                  return PractitionerPatientScheduledServices.view ( 
                                             connSpedmon
                                           , log
                                           , uInfo
                                           , Entities.REC_VIEW_TBL
                                           , paged
                                           , pageNumber
                                           , canEdit
                                           , active
                                           , clientID
                                           , pracID
                                           , patID                                           
                                           , practitionerPatientCaseloadExpectedServiceID
                                           , dc);
                  });
            
            /*----------------------------
             * Add a title and footer
             *----------------------------*/

            so.tableName   = SEL_LABEL_EXPORT;
            so.tableFooter = Messages.CONFIDENTIAL;

            /*----------------------------
             * Done
             *----------------------------*/

            return so;
        }

    /***************************************************************************
     * viewObjects */
    /**
     *
     ***************************************************************************/
    public static ReturnObjects viewObjects (   SqlConnection connSpedmon
                                              , DetailsLog    log
                                              , UserInfo      uInfo
                                              , bool          pageObjectList
                                              , string        pageOrder
                                              , string        idx
                                              , string        active
                                              , string        clientID 
                                              , string        pracID
                                              , string        patID
                                              , string        practitionerPatientCaseloadExpectedServiceID)

    {

      /* Default page order */

      if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PractitionerPatientScheduledService.DEFAULT_PAGING_ORDER;

      /* Define columns delegate is used to specify columns and page order 
       * We pass in the desired page row order here */

      defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        pageroworder = pageOrder;
      };

      return Entities.viewObjects (   connSpedmon
                                    , log
                                    , uInfo
                                    , typeof(PractitionerPatientScheduledService)
                                    , pageObjectList
                                    , pageOrder
                                    , delegate {
                                        return PractitionerPatientScheduledServices.view(
                                                                                   connSpedmon
                                                                                 , log
                                                                                 , uInfo
                                                                                 , Entities.REC_VIEW_OBJECTS
                                                                                 , pageObjectList
                                                                                 , idx
                                                                                 , ""
                                                                                 , active
                                                                                 , clientID 
                                                                                 , pracID
                                                                                 , patID                                                                                 
                                                                                 , practitionerPatientCaseloadExpectedServiceID
                                                                                 , dc);
                                    });


    }
            
   
  } 
}
