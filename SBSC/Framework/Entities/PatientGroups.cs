using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  
  /***************************************************************************
   * PatientGroup */
  /**
   * Patient group
   ***************************************************************************/

  public class PatientGroup:Entity
  {    
    public string      clientName;
    public string      pracName;
    public string      description;
    public long        clientID;
    public long        pracID;
    public string      startDateStr;
    public TimeSpan    startTime;
    public string      startTimeStr;
    public int         numMins;
    public bool        grpMtg2;
    public bool        grpMtg3;
    public bool        grpMtg4;
    public bool        grpMtg5;
    public bool        grpMtg6;
    public string      grpMtgsStr;
    public string      patIDsStr;
    public string      patNames;
    public DateTime    effectiveDate;
    public string      effectiveDateStr;
  }

  /***************************************************************************
   * PatientGroups */
  /**
   * Patient groups
   ***************************************************************************/

  public class PatientGroups:MBA.Entities
  {
    /***************************************************************************
     * SEL_LABEL */
    /**
     * Selection labels for menus and screens
     ***************************************************************************/       
    
    public const string SEL_LABEL             = "Group Speech & Psych";
    public const string SEL_LABEL_ADD         = "Create New Group";
    public const string SEL_LABEL_VIEW        = "View Groups";
    public const string SEL_LABEL_EDIT_DELETE = "Edit or Delete Group";
    public const string SEL_LABEL_EDIT        = "Edit";   
    public const string SEL_LABEL_DELETE      = "Delete";
    public const string SEL_LABEL_SVC_REC_NEW = "Record Services for a Group";
     
    /***************************************************************************
     * save */
    /**
     * Save a group record
     *
     * @param  userID          User id of who is recording service
     * @param  userGroup       1 = Client, 2 = SBSC (from users db)
     * @param  userRank        Users role ranking
     * @param  clientID        Client id
     * @param  pracID          Practitioner id
     * @param  patIDs          Patient ids
    
     * @param  distributionNotes     Any notes about the distribution (fax only, send with invoice, etc)
     * 
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
     * @param  recID           Record id of existing patient record to edit or
     *                         delete.
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    public static ReturnSaveRecord save (SqlConnection connSpedmon, 
                                         DetailsLog    log, 
                                         UserInfo      uInfo,
                                         string        clientID, 
                                         string        pracID,                           
                                         string        name,
                                         string        description,
                                         
                                         string        startDate,
                                         string        startTime,
                                         string        numMins,                                        
                                         
                                         string        grpMtg2,
                                         string        grpMtg3,
                                         string        grpMtg4,
                                         string        grpMtg5,
                                         string        grpMtg6, 

                                         string        patIDs,
                                         
                                         string        tmtEffDate,                         
                                         string        editDelReason,
                                         string        validateRec,
                                         string        saveType, 
                                         string        recID)
    {           
            
      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
      int       vClientID      = Validate.reqClientID (uInfo,  clientID);
      int       vPracID        = Validate.reqPracID   (uInfo,  pracID);
      
      string    vName          = Validate.reqString   (name,         Messages.INVALID_GROUP_NAME);
      string    vDescription   = Validate.optString   (description,  Messages.INVALID_GROUP_DESCRIPTION);      
      
      DateTime  vStartDate     = Validate.reqDate     (startDate,    Messages.INVALID_START_DATE);
      TimeSpan  vStartTime     = Validate.reqTime     (startTime,    Messages.INVALID_START_TIME);
      int       vNumMins       = Validate.reqInteger  (numMins,      Messages.INVALID_NUM_MINS);              
           
      bool      vGrpMtg2       = Validate.reqFlag     (grpMtg2,      Messages.INVALID_FLAG_DAY_OF_WEEK, true);   
      bool      vGrpMtg3       = Validate.reqFlag     (grpMtg3,      Messages.INVALID_FLAG_DAY_OF_WEEK, true);   
      bool      vGrpMtg4       = Validate.reqFlag     (grpMtg4,      Messages.INVALID_FLAG_DAY_OF_WEEK, true);   
      bool      vGrpMtg5       = Validate.reqFlag     (grpMtg5,      Messages.INVALID_FLAG_DAY_OF_WEEK, true);   
      bool      vGrpMtg6       = Validate.reqFlag     (grpMtg6,      Messages.INVALID_FLAG_DAY_OF_WEEK, true);   
            
      string    vPatIDs        = Parse.createMultiInt (Validate.reqRecIDMulti (patIDs, Messages.INVALID_PAT_ID));
    
      // Determine what to do with effective date based on save type and validate
      
      int       vSaveType    = Validate.reqInteger (saveType,    Messages.INVALID_SAVE_TYPE);
      bool      vValidateRec = Validate.reqFlag    (validateRec, Messages.INVALID_VALIDATE_FLAG);      
      DateTime  vTmtEffDate  = Dates.DateOnly(DateTime.Now);

      // If this is a new record then the effective date is the same as the start date
      
      if (vSaveType == Constants.SAVE_TYPE_NEW) 
      {
        vTmtEffDate = vStartDate;
      }  
      
      
      // If this is anything else, then the effective date must be provided
      
      else                                      
      {
        if (vValidateRec) 
        {
          Object td = Validate.optDate(tmtEffDate, Messages.INVALID_EFFECTIVE_DATE);
          if (td == null) throw new Warning("Please make sure to provide an effective date for your changes.");        
        }
        else
        {
          vTmtEffDate = Validate.reqDate (tmtEffDate, Messages.INVALID_EFFECTIVE_DATE);
        }
      }
      
      parms.Add(Database.SqlParm("@clientID",    SqlDbType.Int,      vClientID,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",      SqlDbType.Int,      vPracID,       ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@name",        SqlDbType.VarChar,  vName,         ParameterDirection.Input, 500));
      parms.Add(Database.SqlParm("@description", SqlDbType.VarChar,  vDescription,  ParameterDirection.Input, 1000));      

      parms.Add(Database.SqlParm("@startDate",   SqlDbType.DateTime, vStartDate,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startTime",   SqlDbType.Time,     vStartTime,    ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@numMins",     SqlDbType.Int,      vNumMins,      ParameterDirection.Input));   

      parms.Add(Database.SqlParm("@grpMtg2",     SqlDbType.Bit,      vGrpMtg2,      ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@grpMtg3",     SqlDbType.Bit,      vGrpMtg3,      ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@grpMtg4",     SqlDbType.Bit,      vGrpMtg4,      ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@grpMtg5",     SqlDbType.Bit,      vGrpMtg5,      ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@grpMtg6",     SqlDbType.Bit,      vGrpMtg6,      ParameterDirection.Input));   
    
      parms.Add(Database.SqlParm("@patIDsStr",   SqlDbType.VarChar,  vPatIDs,       ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@tmtEffDate",  SqlDbType.DateTime, vTmtEffDate,   ParameterDirection.Input));
    

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.save(connSpedmon, 
                           log, 
                           uInfo, 
                           saveType, 
                           validateRec, 
                           editDelReason, 
                           recID, 
                           "PRACTITONER_PATIENT_GROUPS_Save", 
                           Messages.DUP_PATIENT_GROUP, 
                           ref parms,null);
    }  
    

    /***************************************************************************
     * load */
    /**
     * Outputs data for a single caseload record
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing the client id.
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @param  patID           PatID
     * @return                 ReturnEntity
     ***************************************************************************/

    public static PatientGroup load (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string recID)
    {
      return (PatientGroup)Entities.load(connSpedmon, log, uInfo, recID, typeof(PatientGroup),
      delegate { return PatientGroups.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", "", "", "", "", null); });    
    } 
  
    
    /***************************************************************************
     * delete */
    /**
     * "Deletes" a group record
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/

    public static ReturnSaveRecord delete(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                           string editDelReason, string validateRec, string endDate, 
                                           string recID)
    {

      /*----------------------------
       * Check for required and 
       * optional parameters
       * and validate data integrity
       * of all supplied parameters
       *----------------------------*/

      // Fetch optional client and prac id parms "behind the scenes"
      // This will ensure that clients who edit this will only be able
      // to edit their own recs
      
      Object      vClientID = Validate.optClientID (uInfo,   "");
      Object      vPracID   = Validate.optPracID   (uInfo,   "");
      DateTime vEndDate     = Validate.reqDate     (endDate, Messages.INVALID_END_DATE);
      
      /*----------------------------
       * Collect all of the parameters
       * that are specific to this
       * delete method.
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm("@clientID",  SqlDbType.Int,      vClientID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",    SqlDbType.Int,      vPracID,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",   SqlDbType.DateTime, vEndDate,  ParameterDirection.Input));

      /*----------------------------
       * Call base method 
       *----------------------------*/

      return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "PRACTITONER_PATIENT_GROUPS_Delete", ref parms);
    }
       
    /***************************************************************************
     * viewExpectedServicesInfoTbl */
    /**
     * Returns a ReturnInfoTable of expected services.
     * 
     * @param  clientID        Required.  Record ID of client.
     * @param  pracID          Required.  Record ID of practitioner.
     * @param  patID           Required.  Record ID of patient.
     * @param  refDate         Required.  Any date in the month services were
     *                         provided.
     * @return                 ReturnInfoTable
     ***************************************************************************/
   
    public static ReturnInfoTable viewExpectedServicesInfoTbl (
      
      SqlConnection connSpedmon, 
      DetailsLog    log, 
      UserInfo      uInfo, 
      string        clientID,
      string        pracID,
      string        groupID,
      string        dos,
      string        isIEP)
    {                                            
      
      string viewUDF = "dbo.PRACTITONER_PATIENT_GROUPS_VIEW_SERVICES_EXPECTED(@clientID, @pracID, @groupID, @dos, @isIEP)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
        
      int       vClientID  = Validate.reqClientID (uInfo, clientID);
      int       vPracID    = Validate.reqPracID   (uInfo, pracID);
      
      int       vGroupID   = Validate.reqInteger  (groupID, Messages.INVALID_GROUP_ID);
      DateTime  vDos       = Validate.reqDate     (dos,     Messages.INVALID_DATES);
      bool      vIsIEP     = Validate.reqFlag     (isIEP,   Messages.IFSP_IEP_FLAG_BAD);
      
      parms.Add(Database.SqlParm("@clientID",  SqlDbType.Int,      vClientID,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",    SqlDbType.Int,      vPracID,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@groupID",   SqlDbType.Int,      vGroupID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@dos",       SqlDbType.DateTime, vDos,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@isIEP",     SqlDbType.Bit,      vIsIEP,      ParameterDirection.Input));
      
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.viewInfoTbl (connSpedmon, log, uInfo, viewUDF, parms);
         
    }

   /***************************************************************************
    * viewTbl */
   /**
    * Returns a data table of records for preview or record selection.
    * 
    * @return                 ReturnDataTable
    ***************************************************************************/

   public static ReturnDataTable viewTbl(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                          bool   paged,
                                          string pageNumber,
                                          string clientID,
                                          string pracID,
                                          string canEdit,
                                          string active)
   {
     ReturnDataTable so = new ReturnDataTable();
     
     /*----------------------------
      * Define our columns and
      * set the page order for 
      * paging
      * 
      * TODO: Rewrite 
      *----------------------------*/

     defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
     {
       ss.addDisplayColumn("id");
       ss.addDisplayColumn("name as [Name]", true);
       ss.addDisplayColumn("description as [Description]"); 
       ss.addDisplayColumn("startDateStr as [Start Date]");
       ss.addDisplayColumn("startTimeStr as [Start Time]");
       ss.addDisplayColumn("grpMtgsStr   as [Meets On]");
       ss.addDisplayColumn("patNames     as [Patients]");
       ss.addDisplayColumn("effectiveDateStr as [Effective Date]");
       
       pageroworder = ss.pageRowOrder();

     };

     /*----------------------------
      * Call base method which
      * handles the rest 
      *----------------------------*/

     so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
       delegate { return PatientGroups.view(connSpedmon, log, uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, canEdit, active, clientID, pracID, "", "", dc); });
   
     /*----------------------------
      * Add a title and footer
      *----------------------------*/
                   
     so.tableName   = "Treatment Groups - View";
     so.tableFooter = Messages.CONFIDENTIAL;
     
     /*----------------------------
      * Done
      *----------------------------*/

     return so;
     
    }
    
    /***************************************************************************
     * view */
    /**
     * View group records
     * 
     * @param  clientID        Client ID
     * @param  pracID          Practitioner ID
     * @param  patID           Patient ID
     * @param  startDate       Start date
     * @param  endDate         End date
     * @return                 Group records
     ***************************************************************************/   

    public static ReturnDB view (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                 int     recViewType,
                                 bool    pagedOrTop,
                                 string  idx,
                                 string  canEdit,
                                 string  active,
                                 string  clientID,
                                 string  pracID,
                                 string  dos,
                                 string  name,
                                 defineCols dc) 
    {
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms      = new List<SqlParameter>();
      
      string             viewUDF    = "PRACTITONER_PATIENT_GROUPS_View (@userID, @userGroup, @userRank, @clientID, @pracID, @dos, null, @active, @recID)";
      
      Object  vClientID;
      Object  vPracID;

      /*----------------------------
       * If the view type is a load
       * then clientID and pracID
       * validation is optional
       *----------------------------*/  

      if (recViewType != REC_VIEW_LOAD)
      {                
        vClientID = Validate.reqClientID (uInfo, clientID);
        vPracID   = Validate.reqPracID   (uInfo, pracID);
      }
      else
      {
        vClientID = Validate.optClientID (uInfo, clientID);
        vPracID   = Validate.optPracID   (uInfo, pracID);
      }
      

      Object vDos = Validate.optDate (dos, Messages.SERVICE_DATE_BAD);
      
       
      parms.Add(Database.SqlParm("@clientID",   SqlDbType.Int,      vClientID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",     SqlDbType.Int,      vPracID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@dos",        SqlDbType.DateTime, vDos,       ParameterDirection.Input));

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
                                     string dos,
                                     string term) 
    {
      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){        
         //ss.addDisplayColumn("description as context1");
         ss.addDisplayColumn("[startTimeStr] + ' ' + [grpMtgsStr] + ' ' + [description] as context1");
         ss.addSortColumn("name");
      };
      
      
      return Entities.viewSel(connSpedmon, log, uInfo,top, topSize,
        delegate{return PatientGroups.view (connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, top, topSize, "", "", clientID, pracID, dos, term, dc);});
    }

  
  }
} 

