using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;
using Newtonsoft.Json;

namespace Spedmon
{
    
  /**************************************************************************
   * PractitionerCaseloadMember */
  /**
   * 
   ***************************************************************************/

  public class PractitionerCaseloadMember:Entity
  {
      public const string DEFAULT_PAGING_ORDER = "name";
	  public long     clientID;
      public string   clientName;
	  public long     pracID;
	  public string   pracName;
      public long     patID;
      public string   patName;    
      public int      minsInd;
	  public int      minsGrp;
      public int      minsAnn;    
      public string   minsIndStr;
	  public string   minsGrpStr;
      public string   minsAnnStr;
      public string   weekdaysjson;
      public string   dobStr;
      public string   siteName;
      public string   startDateStr;
      public string   startDateTmtSvcsStr;
      public string   planTypeStr;
      public string   planTypeName;


      public DateTime   planStartDate;
      public string     planStartDateStr;
      public string     planStartDateStrYMD;
      public DateTime   planEndDate;
      public string     planEndDateStr;
      public string     planEndDateStrYMD;
      public int        numMinsExpected;
      public int        numMinsApplicable;
      public int        numMinsDiff;
      public string     pctExpectedApplicableStr;

      public long       promisedSvcID;
      public long       promisedSvcCode;
      public string     promisedSvcName;

      public int        frequencyCode;
      public string     frequencyName;

      public long       orpDocID;
      public string     orpDocName;

  }

  /**************************************************************************
   * PractitionerCaseloadMemberExpectedSvcRecEntryData */
  /**
   * Data for preloading fields
   ***************************************************************************/

  public class PractitionerCaseloadMemberExpectedSvcRecEntryData {
    public long     id;
    public long     clientID;
    public string   clientName;
    public long     pracID;
    public string   pracName;
    public long     patID ;
    public string   patName;
    public long     groupID;
    public string   groupName;
    public DateTime dos;
    public string   dosStr;
    public string   dosYMD;
    public int      numMins; 
    public TimeSpan startTime;
    public string   startTimeStr;
    public string   startTimeHMS;
    public int      svcTypeID;
    public int      svcSubTypeID;
    public int      planTypeSelectionID;
    public bool     planIsIEPIFSP;
    public int      svcNamesListDataSourceID;
    public string   svcNamesListDataSourceName;
    public int      internalPlanTypeID;
    public long?    serviceNameID;
    public string   serviceName;
    public string   svcName;
    public int      svcSubType1ID;
    public bool     viaTeleHealth;
	public long?    altModalityNameID;
    public string   serviceSelectionsJSON;
    public string   expectedEntryContext;
    public long?    scheduledServiceID;
    public long     caseloadGrpID;
   }
  
  /***************************************************************************
  * PractitionerCaseloadMemberSvcRec */
  /**
  * 
  ***************************************************************************/

  public class PractitionerCaseloadMemberSvcRec : PractitionerCaseloadMember
  {
      public DateTime startDateTmtSvcs;
      public int      planSelection;
      public int      serviceClass;
      public string   startTime;
      public bool     teleHealthSession = false;
      public int      sessionDeliveryStatus;
      public string serviceClasses;

      /***************************************************************************
      * copyPropsFromAnotherPCM */
      /**
      * Given another object of the same type (PractitionerCaseloadMemberSvcRec),
      * copy the field values of that object into this object
      ***************************************************************************/
      public void copyPropsFromAnotherPCM (PractitionerCaseloadMemberSvcRec pcm)
      {
          this.name             = pcm.name             ;
          this.clientID         = pcm.clientID         ;        
          this.clientName       = pcm.clientName       ;      
          this.pracID           = pcm.pracID           ;
          this.pracName         = pcm.pracName         ;
          this.patID            = pcm.patID            ;
          this.patName          = pcm.patName          ;
          this.minsInd          = pcm.minsInd          ;
          this.minsGrp          = pcm.minsGrp          ;
          this.minsAnn          = pcm.minsAnn          ;
          this.weekdaysjson     = pcm.weekdaysjson     ;
          this.startDateTmtSvcs = pcm.startDateTmtSvcs ;
          this.notes            = pcm.notes            ;
          
          // check patID
          if (this.patID == 0) this.patID = pcm.id;
      }
  }
  
 
  /***************************************************************************
   * PractitionerCaseloadMembers */
  /**
   * 
   ***************************************************************************/

  public class PractitionerCaseloadMembers: Entities
  {

    public const string SEL_LABEL_PRAC                              = @"Manage My Caseload/Groups & Record for Scheduled Services";

    public const string SEL_LABEL_NON_PRAC                          = @"Caseload & Groups";

    public const string MENU_ID                                     = @"caseloadandgroupmgmtlink";
    public const string URL_USER_ALL                                = @"user_all_caseload_and_patient_group_mgmt.aspx";

    public const string URL_ASMX                                    = @"practitioner_caseload_members.asmx";
    public const string URL_ASMX_SAVE                               = URL_ASMX + "/save";
    public const string URL_ASMX_VIEW_SEL                           = URL_ASMX + "/viewSel";
    public const string URL_ASMX_DELETE                             = URL_ASMX + "/delete";
    public const string URL_ASMX_VIEW_ENTITY                        = URL_ASMX + "/viewEntity";
    public const string URL_ASMX_VIEW_EXP_TRTMNTS                   = URL_ASMX + "/viewExpectedTreatmentServicesCompliance";
    public const string URL_ASMX_VIEW_LIST_SVC_DOS                  = URL_ASMX + "/viewListExpectedTmtSvcsOnDos";


    /***************************************************************************
     * REST VIEW */
        /**
         * 
         ***************************************************************************/
    public const string URL_REST_VIEW = @"api/v1/practitionercaseloadmembers";

    public static string URL_REST_VIEW_BASE()
    { 
       return MBA.HttpApplication.createLink(PractitionerCaseloadMembers.URL_REST_VIEW, true);
    }

    public static string GEN_URL_ASMX_SAVE()
    { 
       return MBA.HttpApplication.createLink(PractitionerCaseloadMembers.URL_ASMX_SAVE, true);
    }
    
    public static string GEN_URL_ASMX_VIEW_SEL()
    { 
       return MBA.HttpApplication.createLink(PractitionerCaseloadMembers.URL_ASMX_VIEW_SEL, true);
    }
        
    public static string GEN_URL_ASMX_DELETE()
    { 
       return MBA.HttpApplication.createLink(PractitionerCaseloadMembers.URL_ASMX_DELETE, true);
    }
            
    public static string GEN_URL_ASMX_VIEW_ENTITY()
    { 
       return MBA.HttpApplication.createLink(PractitionerCaseloadMembers.URL_ASMX_VIEW_ENTITY, true);
    }

    public static string GEN_URL_ASMX_VIEW_LIST_SVC_DOS()
    { 
       return MBA.HttpApplication.createLink(PractitionerCaseloadMembers.URL_ASMX_VIEW_LIST_SVC_DOS, true);
    }
    
    /***************************************************************************
     * daysOfWeekForCaseloadServiceObj */
    /**
     * object used to parse days of week for a caseload service
     * 
     ***************************************************************************/
    private class daysOfWeekForCaseloadServiceObj
    {
       public bool monInd;
       public bool tueInd;
       public bool wedInd;
       public bool thurInd;
       public bool friInd;
       public bool monGrp;
       public bool tueGrp;
       public bool wedGrp;
       public bool thurGrp;
       public bool friGrp;
       public bool hasInd;
       public bool hasGrp;
       
       // given a day of week, decides if this object is has individual and/or group on that day
       public void setIndGrpForDayOfWeek(DayOfWeek dow) {
           this.hasInd = this.hasGrp = false;

           switch (dow) {
               case DayOfWeek.Monday:
                   if (this.monInd) this.hasInd = true; 
                   if (this.monGrp) this.hasGrp = true;
                   break;
               case DayOfWeek.Tuesday:
                   if (this.tueInd) this.hasInd = true; 
                   if (this.tueGrp) this.hasGrp = true;
                   break;
               case DayOfWeek.Wednesday:
                   if (this.wedInd) this.hasInd = true; 
                   if (this.wedGrp) this.hasGrp = true;
                   break;
               case DayOfWeek.Thursday:
                   if (this.thurInd) this.hasInd = true; 
                   if (this.thurGrp) this.hasGrp = true;
                   break;
               case DayOfWeek.Friday:
                   if (this.friInd) this.hasInd = true; 
                   if (this.friGrp) this.hasGrp = true;
                   break;
           }
       }
    }
    
    /***************************************************************************
     * delete */
    /**
     * "Deletes" a caseload record
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/

    public static ReturnSaveRecord delete (
    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        editDelReason
      , string        validateRec       
      , string        clientID
      , string        pracID
      , string        caseloadGroupID
      , string        patID)
    {

      /*----------------------------
       * Check for required and 
       * optional parameters
       * and validate data integrity
       * of all supplied parameters
       *----------------------------*/

      long   vClientID = Validate.reqClientID (uInfo, clientID);
      long   vPracID   = Validate.reqPracID   (uInfo, pracID);
      long   vPatID    = Validate.reqInteger  (patID, Messages.INVALID_PAT_ID);
      
      /*----------------------------
       * Collect all of the parameters
       * that are specific to this
       * delete method.
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt,   vClientID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",    SqlDbType.BigInt,   vPracID,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",     SqlDbType.BigInt,   vPatID,    ParameterDirection.Input));
      
      /*----------------------------
       * Call base method 
       *----------------------------*/

      return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, patID, "PRACTITIONER_CASELOAD_MEMBER_Delete", ref parms);
    }
   

   /***************************************************************************
    * save */
    /**
    * Save a caseload record
    *
    * @param  userID          User id of who is recording service
    * @param  userGroup       1 = Client, 2 = SBSC (from users db)
    * @param  userRank        Users role ranking
    * @param  clientID        Patient's client id
    * @param  pracID          Practitioner id
    * @param  patID           Patient id

    * @param  editDelReason   Reason for record edit or delete
    * @param  validateRec     1 = Performs data integrity validation tasks
    *                             Perform advisory validation tasks that can
    *                             only be conducted by referencing data from the
    *                             database and then exits WITHOUT saving the record
    *                         0 = Peform data integrity validation tasks and
    *                             if these tasks succeed peforms the desired
    *                             operation (saveType) on the record and exits
    * @param  saveType        Type of operation to perform
    *                         1 = New, 2 = Edit, 3 = Delete
    * @param  recID           Record id of existing record to edit or delete.
    * @return                 ReturnSaveNewRecord
    ***************************************************************************/   
  
    public static ReturnSaveRecord save (
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        clientID
      , string        pracID
      , string        caseloadGroupID
      , string        patID
      , string        minsInd
      , string        minsGrp
      , string        minsAnn
      , string        startDateTmtSvcs
      , string        planType
      , string        weekDaysJSON
      , string        promisedSvcStartDate
      , string        promisedSvcEndDate
      , string        promisedSvcCode
      , string        orpDocID
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
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
      long   vClientID         = Validate.reqClientID  (uInfo, clientID);
      long   vPracID           = Validate.reqPracID    (uInfo, pracID);      
      long   vPatID            = Validate.reqInteger   (patID,         Messages.INVALID_PAT_ID);  
      Object vMinsInd          = Validate.optInteger   (minsInd,       Messages.INVALID_NUM_MINS, true);
	  Object vMinsGrp          = Validate.optInteger   (minsGrp,       Messages.INVALID_NUM_MINS, true);
      Object vMinsAnn          = Validate.optInteger   (minsAnn,       Messages.INVALID_NUM_MINS, true);
      Object vStartDate        = Validate.optDate      (startDateTmtSvcs,     Messages.INVALID_DATES);
      int    vPlanType         = Validate.reqInteger   (planType,     Messages.INVALID_PLAN_TYPE);
      string vWeekDaysJSON     = Validate.reqString    (weekDaysJSON , Messages.INVALID_DAY_TYPE_ID  );
      Object vPromisedSvcStartDate = Validate.optDate   (promisedSvcStartDate, "Invalid service start date");
      Object vPromisedSvcEndDate   = Validate.optDate   (promisedSvcEndDate, "Invalid service end date");
      Object vPromisedSvcCode      = Validate.optInteger(promisedSvcCode, "Invalid service code");
      Object vOrpDocID             = Validate.optInteger(orpDocID, "Invalid order selection");

      parms.Add(Database.SqlParm("@clientID",         SqlDbType.BigInt,   vClientID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",           SqlDbType.BigInt,   vPracID,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",            SqlDbType.BigInt,   vPatID,         ParameterDirection.Input)); 
	  parms.Add(Database.SqlParm("@minsInd",          SqlDbType.Int,      vMinsInd,       ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@minsGrp",          SqlDbType.Int,      vMinsGrp,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@minsAnn",          SqlDbType.Int,      vMinsAnn,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startDateTmtSvcs", SqlDbType.DateTime, vStartDate,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@planType",         SqlDbType.Int,      vPlanType,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@weekDaysJSON",     SqlDbType.VarChar,  vWeekDaysJSON,  ParameterDirection.Input, -1));
      parms.Add(Database.SqlParm("@promisedSvcStartDate", SqlDbType.Date, vPromisedSvcStartDate, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@promisedSvcEndDate", SqlDbType.Date,   vPromisedSvcEndDate  , ParameterDirection.Input));
      parms.Add(Database.SqlParm("@promisedSvcCode",   SqlDbType.Int,     vPromisedSvcCode, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@orpDocID",          SqlDbType.BigInt,  vOrpDocID       , ParameterDirection.Input));
                 
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "PRACTITIONER_CASELOAD_MEMBER_SAVE", Messages.DUP_CASELOAD_REC , ref parms, null);

    }    
                                                    
   /***************************************************************************
    * view */
   /**
    * Returns a list of caseloads for given criteria
    * 
    * TODO: Find and refactor all dependencies
    ***************************************************************************/   

    public static ReturnDB view (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, 
                                 int    recViewType,
                                 bool   pagedOrTop,
                                 string idx,
                                 string canEdit,
                                 string active,
                                 string clientID, 
                                 string pracID,
                                 string caseloadGroupID,
                                 string term,
                                 string iep,
                                 string nameID,
                                 string refDate,
                                 defineCols dc)
    { 
      
      string viewUDF = "PRACTITIONER_CASELOAD_MEMBERS_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @term, @iep, @nameID, @refDate, @recID)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
      long   vClientID    = Validate.reqClientID  (uInfo, clientID);
      long   vPracID      = Validate.reqPracID    (uInfo, pracID);      
      string vTerm        = Validate.optString    (term, @"Invalid search term");
      
      Object vIEP     = Validate.optFlag    (iep,      Messages.INVALID_BOOL);
      Object vNameID  = Validate.optInteger (nameID,   Messages.INVALID_SERVICE);
      Object vRefDate = Validate.optDate    (refDate,  Messages.INVALID_DOS);
           
      parms.Add(Database.SqlParm("@clientID",  SqlDbType.Int,     vClientID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",    SqlDbType.Int,     vPracID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",      SqlDbType.VarChar, vTerm,      ParameterDirection.Input, 500));
      parms.Add(Database.SqlParm("@iep",       SqlDbType.Bit,     vIEP,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@nameID",    SqlDbType.BigInt,  vNameID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@refDate",   SqlDbType.Date,    vRefDate,   ParameterDirection.Input));
      

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
      
      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      

   }  

   /***************************************************************************
    * viewSel */
   /**
    * View group member record selections
    * 
    * @param  groupType       Practitioner group type
    *                         0 = All
    *                         1 = Allied Discipline
    *                         2 = Reporting group
    *                         3 = Allied discipline super group
    * @return                 ReturnSel
    ***************************************************************************/   
    
   public static ReturnSel viewSel (SqlConnection connSpedmon, 
                                    DetailsLog    log, 
                                    UserInfo      uInfo, 
                                    bool          top, 
                                    string        topSize, 
                                    string        clientID, 
                                    string        pracID,
                                    string        caseloadGroupID,                                     
                                    string        term,
                                    string        iep,
                                    string        nameID,
                                    string        refDate ) 
    {

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){          
        ss.addSortColumn("name");
        ss.addDisplayColumn("dobStr + ' | ' + siteName + ' | Ind: ' + minsIndStr + ' | Grp: ' + minsGrpStr as [context1]");
        ss.addDisplayColumn("minsIndStr     as [recData1]");
        ss.addDisplayColumn("minsGrpStr     as [recData2]");
        ss.addDisplayColumn("ytdNumMinsStr  as [recData3]");
        ss.addDisplayColumn("mtdNumMinsStr  as [recData4]");
        
        ss.addDisplayColumn("ytdDosMinStr   as [recData5]");
        ss.addDisplayColumn("ytdDosMaxStr   as [recData6]");
        ss.addDisplayColumn("ytdNumSvcsStr  as [recData7]");

        ss.addDisplayColumn("mtdDosMinStr   as [recData8]");
        ss.addDisplayColumn("mtdDosMaxStr   as [recData9]");
        ss.addDisplayColumn("mtdNumSvcsStr  as [recData10]");
        
        ss.addDisplayColumn("minsAnnStr            as [recData11]");
        ss.addDisplayColumn("weekdaysjson          as [recData12]");
        ss.addDisplayColumn("startDateTmtSvcsStr   as [recData13]");
        ss.addDisplayColumn("planTypeStr           as [recData14]");
      };
            
      return Entities.viewSel(connSpedmon, log, uInfo,top, topSize,
        delegate{return PractitionerCaseloadMembers.view (connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, top, topSize, "", "Y", clientID, pracID, caseloadGroupID, term, iep, nameID, refDate, dc);});
    }   

    /***************************************************************************
     * viewList */
    /**
     * View list of caseload members
     * 
     ***************************************************************************/   
    
     public static List<PractitionerCaseloadMemberSvcRec> viewList (  SqlConnection connSpedmon
                                                              , DetailsLog    log
                                                              , UserInfo      uInfo
                                                              , string        clientID
                                                              , string        pracID )
     {
         var recs = new List<PractitionerCaseloadMemberSvcRec>();
         ReturnDB rd = PractitionerCaseloadMembers.view (connSpedmon,log,uInfo,Entities.REC_VIEW_RAW, false, null,null, null, clientID,pracID,"","","","", "", null);
         List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(PractitionerCaseloadMemberSvcRec));
         foreach (var o in slo) {
           recs.Add((PractitionerCaseloadMemberSvcRec) o);
         }
         return recs;
     }
     
     /*************************************************************************
      * viewListExpectedTmtSvcsOnDos */
     /**
      * View list of caseload members that have scheduled services for the given
      * date of service (DOS)
      ***************************************************************************/   
     public static List<PractitionerCaseloadMemberExpectedSvcRecEntryData> viewListExpectedSvcsOnDos ( 
         SqlConnection connSpedmon
       , DetailsLog    log
       , UserInfo      uInfo
       , string        clientID
       , string        pracID
       , string        patID
       , string        dos 
       , string        pracpatgroupid
       , bool includeSvcSelections = true)
      
     {
       
       var sql = "select * from dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_ON_DOS_VIEW (@userID,@userGroup,@userRank,@clientID,@pracID,@patID,@dos,@pracPatGroupID)";
       
       /*----------------------------
        * Default to today if 
        * dos is not passed
        *----------------------------*/
       
       if (String.IsNullOrWhiteSpace(dos)) dos = DateTime.Now.ToShortDateString();   
        
       /*----------------------------
        * Validate required parameters
        *----------------------------*/
       
       var vClientID       = Validate.reqClientID ( uInfo, clientID);
       var vPracID         = Validate.reqPracID   ( uInfo, pracID);       
       var vPatID          = Validate.optPatID    ( uInfo, patID);
       var vDos            = Validate.reqDate     ( dos, Messages.INVALID_DOS, Constants.VAL_OPT_DATE_NO_FUTURE);
       var vPracPatGroupID = Validate.optInteger  ( pracpatgroupid, Messages.INVALID_NUMBER);

       /*----------------------------
        * Populate db parameters
        *----------------------------*/
   
       var parms = new List<SqlParameter>();

       Entities.validateAndAddCommonUserInfoParameters (uInfo,ref parms);

       parms.Add(Database.SqlParm("@clientID",        SqlDbType.BigInt,   vClientID,       ParameterDirection.Input));
       parms.Add(Database.SqlParm("@pracID",          SqlDbType.BigInt,   vPracID,         ParameterDirection.Input));
       parms.Add(Database.SqlParm("@patID",           SqlDbType.BigInt,   vPatID,          ParameterDirection.Input));
       parms.Add(Database.SqlParm("@dos",             SqlDbType.DateTime, vDos,            ParameterDirection.Input));
       parms.Add(Database.SqlParm("@pracPatGroupID",  SqlDbType.BigInt,   vPracPatGroupID, ParameterDirection.Input));
       
       /*----------------------------
        * Call UDF and return raw data
        *----------------------------*/

       var rd = Database.execQuery (connSpedmon, log, sql, false, parms);

       /*----------------------------
        * Populate our list
        *----------------------------*/

       var recs = new List<PractitionerCaseloadMemberExpectedSvcRecEntryData>();       
       
       var slo = Database.convertRecordsToList (ref rd.records, typeof(PractitionerCaseloadMemberExpectedSvcRecEntryData));

       foreach (var o in slo) {
 
         var rec  = (PractitionerCaseloadMemberExpectedSvcRecEntryData) o;

         /* Add service selections data */
         
         if (includeSvcSelections) { 
           var serviceSelections     = Spedmon.Services.viewSel(connSpedmon, log, uInfo, clientID, pracID, rec.patID.ToString(), dos, Util.boolTo1or0Str(rec.planIsIEPIFSP), "");
           rec.serviceSelectionsJSON = MBA.JSON.toJSONString(serviceSelections.SelRecs, JsonLibrary.MSFT_WEB_SCRIPT_SERIALIZATION);       
         }
                recs.Add(rec);
       }
      
       /*----------------------------
        * Return the list
        *----------------------------*/
       
       return recs;
  
    }
  
   /*************************************************************************
    * viewListExpectedAssmtSvcs */
   /**
    * View list of caseload members who have not had an assessment in the
    * past 13 months
    * 
    ***************************************************************************/

    public static List<PractitionerCaseloadMemberExpectedSvcRecEntryData> viewListExpectedAssmtSvcs ( 
         SqlConnection connSpedmon
       , DetailsLog    log
       , UserInfo      uInfo
       , string        clientID
       , string        pracID
       , string        dos
       , bool          limitToPatsInCaseload
       , bool          includeSvcSelections = true)
      
     {
       
       var sql = "select * from dbo.PRACTITIONER_CASELOAD_EXPECTED_PATIENT_ASSESSMENT_SERVICES_COMPLIANCE_VIEW (@userID,@userGroup,@userRank,@clientID,@pracID,@patsInCaseload) order by patName";   
        
       /*----------------------------
        * Default to today if 
        * dos is not passed
        *----------------------------*/
       
       if (String.IsNullOrWhiteSpace(dos)) dos = DateTime.Now.ToShortDateString();
        
       /*----------------------------
        * Validate required parameters
        *----------------------------*/
       
       var vClientID = Validate.reqClientID ( uInfo, clientID);
       var vPracID   = Validate.reqPracID   ( uInfo, pracID);       
       
       Object vPatsInCaseload = null;
       if (limitToPatsInCaseload) vPatsInCaseload = true;

       /*----------------------------
        * Populate db parameters
        *----------------------------*/
   
       var parms = new List<SqlParameter>();
       
       Entities.validateAndAddCommonUserInfoParameters (uInfo,ref parms);

       parms.Add(Database.SqlParm("@clientID",          SqlDbType.BigInt,   vClientID,        ParameterDirection.Input));
       parms.Add(Database.SqlParm("@pracID",            SqlDbType.BigInt,   vPracID,          ParameterDirection.Input));
       parms.Add(Database.SqlParm("@patsInCaseload",    SqlDbType.Bit,      vPatsInCaseload,  ParameterDirection.Input));

       /*----------------------------
        * Call UDF and return raw data
        *----------------------------*/

       var rd = Database.execQuery (connSpedmon, log, sql, false, parms);

       /*----------------------------
        * Populate our list
        *----------------------------*/

       var recs = new List<PractitionerCaseloadMemberExpectedSvcRecEntryData>();       
       
       var slo = Database.convertRecordsToList (ref rd.records, typeof(PractitionerCaseloadMemberExpectedSvcRecEntryData));

       foreach (var o in slo) {
 
         var rec  = (PractitionerCaseloadMemberExpectedSvcRecEntryData) o;
                
         /* Add service selections data */
         
         if (includeSvcSelections) { 
           var serviceSelections     = Spedmon.Services.viewSel(connSpedmon, log, uInfo, clientID, pracID, rec.patID.ToString(), dos, Util.boolTo1or0Str(rec.planIsIEPIFSP), "");
           rec.serviceSelectionsJSON = MBA.JSON.toJSONString(serviceSelections.SelRecs, JsonLibrary.MSFT_WEB_SCRIPT_SERIALIZATION);       
         }
         recs.Add(rec);
       }
      
       /*----------------------------
        * Return the list
        *----------------------------*/
       
       return recs;
  
    }
    
   
    /*************************************************************************
     * viewExpectedTreatmentServicesCompliance */
    /**
     * 
     ***************************************************************************/   
    
     public static ReturnHTMLContent viewExpectedTreatmentServicesCompliance ( 
         SqlConnection connSpedmon
       , DetailsLog    log
       , UserInfo      uInfo
       , string        clientID
       , string        pracID )
      
     {
       ReturnHTMLContent so = new ReturnHTMLContent();

       var sql = "select patName as [Patient], dobStr as [DOB], startDate as [Authorization Date], annualMins as [Annual Minutes], totMinsSatisfied as [Minutes Satisfied], totMinsStillOwed as [Minutes Still Owed], totMinsPatAbsent as [Patient Marked Absent (Satisfied)], totMinsPracAbsent as [Practitioner Marked Absent (Not Satisfied)] from dbo.PRACTITIONER_CASELOAD_EXPECTED_PATIENT_TREATMENT_SERVICES_COMPLIANCE_VIEW (@userID,@userGroup,@userRank,@clientID,@pracID) order by id";
       
       /*----------------------------
        * Validate required parameters
        *----------------------------*/
       
       var vClientID = Validate.reqClientID ( uInfo, clientID);
       var vPracID   = Validate.reqPracID   ( uInfo, pracID);       
       
       /*----------------------------
        * Populate db parameters
        *----------------------------*/
   
       var parms = new List<SqlParameter>();

       Entities.validateAndAddCommonUserInfoParameters (uInfo,ref parms);

       parms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt,   vClientID,  ParameterDirection.Input));
       parms.Add(Database.SqlParm("@pracID",    SqlDbType.BigInt,   vPracID,    ParameterDirection.Input));
       
       /*----------------------------
        * Call UDF and return raw data
        *----------------------------*/

       var rd = Database.execQuery (connSpedmon, log, sql, false, parms);

       /*----------------------------
        * Convert raw data to return
        * info table
        *----------------------------*/

       var rit = Database.convertReturnDBToReturnInfoTable(ref rd);
      
       /*----------------------------
        * Generate HTML table
        *----------------------------*/

       so.content = ReturnInfoTable.ToHTMLTableString (ref rit,@"service-record-compliance",@"No patients found",false,false);
       
       return so;

    }


   /***************************************************************************
    * load */
   /**
    * Outputs data for a single caseload member
    ***************************************************************************/ 
    
    public static PractitionerCaseloadMember load (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, 
                                     string clientID, string pracID, string recID)
    { 
      return (PractitionerCaseloadMember) Entities.load (connSpedmon, log, uInfo , recID, typeof(PractitionerCaseloadMember),
      delegate{return PractitionerCaseloadMembers.view (connSpedmon,log,uInfo,Entities.REC_VIEW_LOAD, false, recID, "", "", clientID, pracID, "", "", "", "", "", null);});      
    } 

   /***************************************************************************
    * viewEntity */
   /**
    * Outputs data for a single caseload member
    ***************************************************************************/ 
    public static ReturnEntity viewEntity (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, 
                                     string clientID, string pracID, string recID)
    {
        ReturnEntity so = new ReturnEntity();
        PractitionerCaseloadMember c = PractitionerCaseloadMembers.load(connSpedmon, log, uInfo, clientID, pracID, recID);
        so.entity = (Entity)c;
        return so;
    } 
      
    /***************************************************************************
     * viewObjects */
    /**
     ***************************************************************************/
    public static ReturnObjects viewObjects (   SqlConnection connSpedmon
                                              , DetailsLog log
                                              , UserInfo uInfo
                                              , bool   pageObjectList
                                              , string pageOrder
                                              , string idx
                                              , string active
                                              , string clientID 
                                              , string pracID
                                              , string caseloadGroupID                                     
                                              , string term
                                              , string iep
                                              , string nameID
                                              , string refDate)

    {

      /* Default page order */

      if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PractitionerCaseloadMember.DEFAULT_PAGING_ORDER;

      /* Define columns delegate is used to specify columns and page order 
       * We pass in the desired page row order here */

      defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        pageroworder = pageOrder;
      };

      return Entities.viewObjects (   connSpedmon
                                    , log
                                    , uInfo
                                    , typeof(PractitionerCaseloadMember)
                                    , pageObjectList
                                    , pageOrder
                                    , delegate {
                                        return PractitionerCaseloadMembers.view(
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
                                                                                 , caseloadGroupID                                     
                                                                                 , term
                                                                                 , iep
                                                                                 , nameID
                                                                                 , refDate
                                                                                 , dc);
                                    });


    }
   
 } 
}

