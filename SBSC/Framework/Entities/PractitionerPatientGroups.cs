using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    /***************************************************************************
     * PractitionerPatientGroup */
    /**
     * 
     ***************************************************************************/

    public class PractitionerPatientGroup : Entity
    {
        public long     clientID;
        public string   clientName;
        public long     pracID;
        public string   pracName;
        public string   groupName;
        public string   weekDaysJSON;

        /*Schedule Services Data*/
        public int      svcNamesListDataSourceID;
        public string   svcNamesListDataSourceName;
        public bool     viaTeleHealth;
        public string   viaTeleHealthYN;
        public long     nameID;
        public long     altModalityNameID;
        public string   svcName;
        public bool     recurring;
        public string   recurringYN;
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

        public string wedStartTimeStr;
        public string wedStartTimeHMS;

        public string thuStartTimeStr;
        public string thuStartTimeHMS;

        public string friStartTimeStr;
        public string friStartTimeHMS;
    }
  
  /***************************************************************************
   * PractitionerPatientGroups */
  /**
   * 
   ***************************************************************************/

  public class PractitionerPatientGroups: Entities
  {
    public const string SEL_LABEL_ADD_NEW                = @"Create New Group";
    public const string SEL_LABEL_EDIT                   = @"Edit Group";
    public const string URL_ASMX                         = "practitioner_patient_groups.asmx";
    public const string URL_SCH_SVC_GROUP                = "user_all_practitioner_patient_group_save.aspx";

    public const string URL_ASMX_SAVE                    = URL_ASMX + "/save";
    public const string URL_ASMX_DELETE                  = URL_ASMX + "/delete";
    public const string URL_ASMX_VIEW_ENTITY             = URL_ASMX + "/viewEntity";
    public const string URL_ASMX_VIEW_SEL_BY_CLIENT_PRAC = URL_ASMX + "/viewSelByClientPrac";

    public static string GEN_URL_VIEW_SEL_BY_CLIENT_PRAC ()
    { 
       return MBA.HttpApplication.createLink(URL_ASMX_VIEW_SEL_BY_CLIENT_PRAC, true);
    }

    public static string GEN_URL_ASMX_SAVE()
    { 
       return MBA.HttpApplication.createLink(URL_ASMX_SAVE, true);
    }

    public static string GEN_URL_ASMX_VIEW_ENTITY()
    { 
       return MBA.HttpApplication.createLink(URL_ASMX_VIEW_ENTITY, true);
    }

    public static string GEN_URL_ASMX_DELETE()
    { 
       return MBA.HttpApplication.createLink(URL_ASMX_DELETE, true);
    }    

    public static string GEN_URL_SCH_SVC_GROUP_DATA()
    { 
       return MBA.HttpApplication.createLink(URL_SCH_SVC_GROUP
                                            , true
                                            , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE));
    }

    /***************************************************************************
     * delete */
    /**
     * Deletes an entire group and all members.
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
	    , string        patientGroupID
      )
    {

      /*----------------------------
       * Check for required and 
       * optional parameters
       * and validate data integrity
       * of all supplied parameters
       *----------------------------*/

      long   vClientID       = Validate.reqClientID (uInfo, clientID);
      long   vPracID         = Validate.reqPracID   (uInfo, pracID);
      long   vPracPatGroupID = Validate.reqInteger  (patientGroupID, @"Invalid group id");
      
      /*----------------------------
       * Collect all of the parameters
       * that are specific to this
       * delete method.
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm("@clientID",       SqlDbType.BigInt,  vClientID,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",         SqlDbType.BigInt,  vPracID,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracPatGroupID", SqlDbType.BigInt,  vPracPatGroupID, ParameterDirection.Input)); 

      /*----------------------------
       * Call base method 
       *----------------------------*/

      return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, patientGroupID, "PRACTITIONER_PATIENT_GROUP_DELETE", ref parms);
    }

   
   /***************************************************************************
    * save */
    /**
    * Save a new group (group only not members)
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
      , string        groupName
      , string        svcNamesListDataSourceID
      , string        viaTeleHealth
      , string        nameID
      , string        recurring
      , string        startDate
      , string        endDate
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
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
      long   vClientID                     = Validate.reqClientID  (uInfo, clientID);
      long   vPracID                       = Validate.reqPracID    (uInfo, pracID);
      string vGroupName                    = Validate.reqString    (groupName,                @"Invalid group name");
      int    vSvcNamesListDataSourceID     = Validate.reqInteger   (svcNamesListDataSourceID, Messages.INVALID_PLAN_TYPE);
      bool   vViaTeleHealth                = Validate.reqFlag      (viaTeleHealth,            @"Invalid value for via telehealth");
      long   vNameID                       = Validate.reqInteger   (nameID,                   Messages.INVALID_NAME_ID);
      bool   vRecurring                    = Validate.reqFlag      (recurring,                @"Invalid value for recurring");

      DateTime vStartDate                  = Validate.reqDate      (startDate,                Messages.INVALID_START_DATE);
      Object   vEndDate                    = Validate.optDate      (endDate,                  Messages.INVALID_END_DATE);      
      Object   vNumMins                    = Validate.optInteger   (numMins,                  Messages.INVALID_NUM_MINS, true);
      Object   vMon                        = Validate.optFlag      (mon,                      @"Invalid value for Mon");
      Object   vMonStartTime               = Validate.optTime      (monStartTime,             @"Invalid start time for Mon");
      Object   vTue                        = Validate.optFlag      (tue,                      @"Invalid value for Tue");
      Object   vTueStartTime               = Validate.optTime      (tueStartTime,             @"Invalid start time for Tue");
      Object   vWed                        = Validate.optFlag      (wed,                      @"Invalid value for Wed");
      Object   vWedStartTime               = Validate.optTime      (wedStartTime,             @"Invalid start time for Wed");
      Object   vThu                        = Validate.optFlag      (thu,                      @"Invalid value for Thu");
      Object   vThuStartTime               = Validate.optTime      (thuStartTime,             @"Invalid start time for Thu");
      Object   vFri                        = Validate.optFlag      (fri,                      @"Invalid value for Fri");
      Object   vFriStartTime               = Validate.optTime      (friStartTime,             @"Invalid start time for Fri");
      Object   vNotes                      = Validate.optString    (notes,                    Messages.INVALID_NOTES);

      parms.Add(Database.SqlParm("@clientID",                  SqlDbType.BigInt,   vClientID,                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",                    SqlDbType.BigInt,   vPracID,                    ParameterDirection.Input));
	  parms.Add(Database.SqlParm("@groupName",                 SqlDbType.VarChar,  vGroupName,                 ParameterDirection.Input, 500));    
      parms.Add(Database.SqlParm("@svcNamesListDataSourceID",  SqlDbType.Int,      vSvcNamesListDataSourceID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@viaTeleHealth",             SqlDbType.Bit,      vViaTeleHealth,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@nameID",                    SqlDbType.BigInt,   vNameID,                    ParameterDirection.Input)); 
      parms.Add(Database.SqlParm("@recurring",                 SqlDbType.Bit,      vRecurring,                 ParameterDirection.Input)); 
      parms.Add(Database.SqlParm("@startDate",                 SqlDbType.Date,     vStartDate,                 ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",                   SqlDbType.Date,     vEndDate,                   ParameterDirection.Input));      
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

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "PRACTITIONER_PATIENT_GROUP_SAVE", Messages.DUP_PATIENT_GROUP , ref parms, null);

    }    
                                                    
   /***************************************************************************
    * view */
   /**
    * Returns a list of caseloads for given criteria
    * 
    ***************************************************************************/   

    public static ReturnDB view (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, 
                                 int    recViewType,
                                 bool   pagedOrTop,
                                 string idx,
                                 string canEdit,
                                 string active,
                                 string clientID, 
                                 string pracID,
                                 string term,
                                 defineCols dc)
    { 
      
      string viewUDF = "PRACTITIONER_PATIENT_GROUPS_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @term, @recID)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/  
      
      List<SqlParameter> parms = new List<SqlParameter>();
      

      long   vClientID = Validate.reqClientID (uInfo, clientID);
      long   vPracID   = Validate.reqPracID   (uInfo, pracID);
      string vTerm     = Validate.optString   (term,  @"Invalid search term");
      
      parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt,  vClientID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",   SqlDbType.BigInt,  vPracID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",     SqlDbType.VarChar, vTerm,      ParameterDirection.Input));
      
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
    * View group record selections
    * 
    * @param  groupType       Practitioner group type
    *                         0 = All
    *                         1 = Allied Discipline
    *                         2 = Reporting group
    *                         3 = Allied discipline super group
    * @return                 ReturnSel
    ***************************************************************************/   
    
    public static ReturnSel viewSel (SqlConnection connSpedmon, 
                                     DetailsLog log, 
                                     UserInfo uInfo, 
                                     bool top, 
                                     string topSize, 
                                     string clientID, 
                                     string pracID,                                     
                                     string term) 
    {
      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){        
        ss.addSortColumn("name");
      };
      
      
      return Entities.viewSel(connSpedmon, log, uInfo,top, topSize,
        delegate{return PractitionerPatientGroups.view (connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, top, topSize, "", "Y", clientID, pracID, term, dc);});
    }


   /***************************************************************************
    * load */
   /**
    * Outputs data for a single caseload member
    ***************************************************************************/ 
    
    public static PractitionerPatientGroup load (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, 
                                     string clientID, string pracID, string recID)
    { 
      return (PractitionerPatientGroup) Entities.load (connSpedmon, log, uInfo , recID, typeof(PractitionerPatientGroup),
      delegate{return PractitionerPatientGroups.view (connSpedmon,log,uInfo,Entities.REC_VIEW_LOAD, false, recID, "", "", clientID, pracID, "", null);});      
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
        PractitionerPatientGroup c = PractitionerPatientGroups.load(connSpedmon, log, uInfo, clientID, pracID, recID);
        so.entity = (Entity)c;
        return so;
    } 
     
   
 } 
}

