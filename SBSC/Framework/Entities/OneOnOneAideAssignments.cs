using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{   
  
  /***************************************************************************
   * ExpectedServicesOneOnOne */
  /**
   * A 1:1 aid assignment
   **************************************************************************/
  
  public class ExpectedServicesOneOnOne:ReturnInfoTable
  {
    public ExpectedServicesOneOnOne ()                 : base(){}
    public ExpectedServicesOneOnOne (string msg)       : base(msg){}
    public ExpectedServicesOneOnOne (Exception e)      : base(e){}
    public ExpectedServicesOneOnOne (Warning e)        : base(e){}
    public ExpectedServicesOneOnOne (Critical e)       : base(e){}
    public ExpectedServicesOneOnOne (SessionExpired e) : base(e){}
        
  }
  
  /***************************************************************************
   * OneOnOneAideAssignment */
  /**
   * A 1:1 aid assignment
   **************************************************************************/
   
  public class OneOnOneAideAssignment:Entity
  {        
    public string   clientName;
    public string   pracName;
    public string   patName;
    public string   siteName;   
    public DateTime dob;
    public long     clientID;
    public long     pracID;
    public long     patID;
    public long     siteID;
    public string   aideLastName;
    public string   aideFirstName;
    public string   aideName;
    public string   oneOnOneAideTypeName;
    public string   oneOnOneAideType;
    public bool     aideSvcsAuthInIEP;
    public bool     svcsAreMedNes;
    public int      busMinsAM;
    public int      siteMins;
    public int      busMinsPM;
    public int      fiscalYearID;
    public string   fiscalYear;
    public long     calendarID;
    public string   calendarName;
    public long     scheduleID;
    public string   scheduleName;
  }
  
  /***************************************************************************
   * OneOnOneAidAssignments*/
  /**
   * Methods to work with 1:1 Aid Assignments
   **************************************************************************/

  public class OneOnOneAideAssignments:Entities
  {          
    
    /***************************************************************************
     * SEL_LABEL */
    /**
     * Selection labels for menus and screens
     ***************************************************************************/       
    
    //public const string SEL_LABEL             = "1:1 Aides";
    public const string SEL_LABEL             = "1:1 & SpecCare";
    public const string SEL_LABEL_ADD         = "Assign Aide to Patient";
    public const string SEL_LABEL_VIEW        = "View Aide : Patient Assignments";
    public const string SEL_LABEL_EDIT_DELETE = "Edit or Deactive Aide : Patient Assignment";
    public const string SEL_LABEL_EDIT        = "Edit Aide : Patient Assignment";   
    public const string SEL_LABEL_DELETE      = "Deactivate Assignment";
    
    /***************************************************************************
     * save */
    /**
     * Save an assignment record
     *
     * @param  userID          User id of who is recording service
     * @param  userGroup       1 = Client, 2 = SBSC (from users db)
     * @param  userRank        Users role ranking
     * @param  clientID        Patient's client id
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
  
    public static ReturnSaveRecord save (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                         string clientID, 
                                         string patID,
                                         string siteID,
                                         string pracID,
                                         string lname,
                                         string fname,
                                         string oneOnOneAidType,
                                         string aidSvcsAuthInIEP,
                                         string svcsAreMedNes,
                                         string busMinsAM,
                                         string siteMins,
                                         string busMinsPM,
                                         string startDate,
                                         string endDate,
                                         string notes,
                                         string fiscalYearID,
                                         string calendarID,
                                         string scheduleID,
                                         string editDelReason,
                                         string validateRec,
                                         string saveType, 
                                         string recID)
    {           
            
      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      List<SqlParameter> parms        = new List<SqlParameter>();
      
      int       vClientID             = Validate.reqClientID (uInfo,  clientID);
      Object    vPracID               = Validate.optPracID   (uInfo,   pracID); 
                 
      int       vPatID                = Validate.reqInteger  (patID,            Messages.INVALID_PAT_ID);
     
      //since the siteID is loading as zero when the value is null we are doing this 
      if (siteID       == "0") siteID       = "";
      if (fiscalYearID == "0") fiscalYearID = "";
      if (calendarID   == "0") calendarID   = "";
      if (scheduleID   == "0") scheduleID   = "";

      Object    vSiteID               = Validate.optInteger  (siteID,           Messages.INVALID_SITE_ID);
      object    vFiscalYearID         = Validate.optInteger  (fiscalYearID,     Messages.INVALID_FISCAL_YEAR_ID);
      object    vCalendarID           = Validate.optInteger  (calendarID,       Messages.INVALID_CALENDAR_ID);
      object    vScheduleID           = Validate.optInteger  (scheduleID,       Messages.INVALID_SCHEDULE_ID);
      string    vLastName             = Validate.optString   (lname,            Messages.INVALID_LNAME);
      string    vFirstName            = Validate.optString   (fname,            Messages.INVALID_FNAME);
      string    vOneOnOneAideType     = Validate.reqString   (oneOnOneAidType,  Messages.INVALID_1_ON_1_TYPE).ToUpper();
      bool      vAidSvcsAuthInIEP     = Validate.reqFlag     (aidSvcsAuthInIEP, Messages.INVALID_FLAG_AUTH_IEP);
      bool      vSvcsAreMedNes        = Validate.reqFlag     (svcsAreMedNes,    Messages.INVALID_FLAG_MED_NES);      
      
      int       vBusMinsAM            = Validate.reqInteger  (busMinsAM,        Messages.INVALID_NUM_MINS, true);
      int       vSiteMins             = Validate.reqInteger  (siteMins,         Messages.INVALID_NUM_MINS, true);
      int       vBusMinsPM            = Validate.reqInteger  (busMinsPM,        Messages.INVALID_NUM_MINS, true);
      
      DateTime  vStartDate            = Validate.reqDate     (startDate,        Messages.INVALID_START_DATE);
      DateTime  vEndDate              = Validate.reqDate     (endDate,          Messages.INVALID_END_DATE);
      string    vNotes                = Validate.optString   (notes,            Messages.INVALID_NOTES);
                      
      /*----------------------------
       * Extra validation for minutes
       *----------------------------*/

      if (vBusMinsAM < 0) throw new Critical(Messages.INVALID_NUM_MINS);
      if (vSiteMins  < 0) throw new Critical(Messages.INVALID_NUM_MINS);
      if (vBusMinsPM < 0) throw new Critical(Messages.INVALID_NUM_MINS);
      
      int totMins = vBusMinsAM + vSiteMins + vBusMinsPM;
                  
      if (totMins == 0) throw new Critical(Messages.INVALID_NUM_MINS);

      /*----------------------------
       * Extra validation for start
       * and end dates
       *----------------------------*/

      if (vStartDate == vEndDate)  throw new Warning  ("Start and end dates are the same date");
      if (vStartDate >  vEndDate)  throw new Critical (Messages.INVALID_START_DATE);
      
      /*----------------------------
       * Populate db params
       *----------------------------*/          

      parms.Add(Database.SqlParm("@clientID",          SqlDbType.Int,      vClientID,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",             SqlDbType.Int,      vPatID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@siteID",            SqlDbType.Int,      vSiteID,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",            SqlDbType.Int,      vPracID,           ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@aideLastName",      SqlDbType.VarChar,  vLastName,         ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@aideFirstName",     SqlDbType.VarChar,  vFirstName,        ParameterDirection.Input, 1000));      
      parms.Add(Database.SqlParm("@oneOnOneAideType",  SqlDbType.VarChar,  vOneOnOneAideType, ParameterDirection.Input, 10));      
      parms.Add(Database.SqlParm("@aideSvcsAuthInIEP", SqlDbType.Bit,      vAidSvcsAuthInIEP, ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@svcsAreMedNec",     SqlDbType.Bit,      vSvcsAreMedNes,    ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@busMinsAM",         SqlDbType.Int,      vBusMinsAM,        ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@siteMins",          SqlDbType.Int,      vSiteMins,         ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@busMinsPM",         SqlDbType.Int,      vBusMinsPM,        ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@startDate",         SqlDbType.DateTime, vStartDate,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",           SqlDbType.DateTime, vEndDate,          ParameterDirection.Input));                 
      parms.Add(Database.SqlParm("@notes",             SqlDbType.VarChar,  vNotes,            ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@fiscalYearID",      SqlDbType.Int,      vFiscalYearID,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@calendarID",        SqlDbType.Int,      vCalendarID,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@scheduleID",        SqlDbType.Int,      vScheduleID,       ParameterDirection.Input));

      
      parms.Add(Database.SqlParm("@MsgNoClient",       SqlDbType.VarChar,  Messages.INVALID_CLIENT_ID,     ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoPat",          SqlDbType.VarChar,  Messages.INVALID_PAT_ID,        ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoSite",         SqlDbType.VarChar,  Messages.INVALID_SITE_ID,       ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoPrac",         SqlDbType.VarChar,  Messages.INVALID_PRAC_ID,       ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgInvAidType",     SqlDbType.VarChar,  Messages.INVALID_1_ON_1_TYPE,   ParameterDirection.Input, 1000));
 
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "ONE_ON_ONE_AIDE_ASSIGNMENT_Save", Messages.DUP_1_ON_1_AIDE_ASSIGN, ref parms, null);
    }     

    /***************************************************************************
     * load */
    /**
     * Outputs data for a single 1:1 aid assignment
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

    public static OneOnOneAideAssignment load (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string recID)
    {
      return (OneOnOneAideAssignment) Entities.load(connSpedmon, log, uInfo, recID, typeof(OneOnOneAideAssignment),
      delegate { return OneOnOneAideAssignments.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", "", "", "", null); });
    } 

    /***************************************************************************
     * delete */
    /**
     * "Deletes" a 1:1 aide assignment
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    public static ReturnSaveRecord delete (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, 
                                           string editDelReason, string validateRec, string recID)
    {           
     
      /*----------------------------
       * Check for required and 
       * optional parameters
       * and validate data integrity
       * of all supplied parameters
       *----------------------------*/

      Object vClientID = Validate.optClientID(uInfo, ""); 
     
      /*----------------------------
       * Collect all of the parameters
       * that are specific to this
       * delete method.
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
      parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
     
     /*----------------------------
      * Call base method 
      *----------------------------*/
     
      return Entities.delete(connSpedmon,log,uInfo,editDelReason,validateRec,recID,"ONE_ONE_ONE_AIDE_ASSIGNMENT_Delete",ref parms);
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

     * @param  includeBS       Required.
     * @param  startDateBS     Optional
     * @param  endDateBS       Optional
     * 
     * @param  includeDS       Required.
     * @param  startDateDS     Optional
     * @param  endDateDS       Optional

     * @param  includeAS       Required.
     * @param  startDateAS     Optional
     * @param  endDateAS       Optional

     * @return                 ReturnInfoTable
     ***************************************************************************/
   
    public static ReturnInfoTable viewExpectedServicesInfoTbl (
      
      SqlConnection connSpedmon, 
      DetailsLog    log, 
      UserInfo      uInfo, 
      
      string        clientID,
      string        patID,
      string        refDate,
      
      string        includeBS,
      string        startDateBS,
      string        endDateBS,
            
      string        includeDS,
      string        startDateDS,
      string        endDateDS,
      
      string        includeAS,
      string        startDateAS,
      string        endDateAS)
         
    {                                            
      
      string viewUDF = "dbo.ONE_ON_ONE_AIDE_ASSIGNMENT_VIEW_SERVICES_EXPECTED (@clientID, @patID, @startDate, @endDate, @includeBS, @startDateBS, @endDateBS, @includeDS, @startDateDS, @endDateDS, @includeAS, @startDateAS, @endDateAS)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
        
      int       vClientID  = Validate.reqClientID (uInfo,     clientID);            
      int       vPatID     = Validate.reqInteger  (patID,     Messages.INVALID_PAT_ID);
      DateTime  vRefDate   = Validate.reqDate     (refDate,   Messages.INVALID_REF_DATE);
            
      bool      vIncludeBS     = Validate.reqFlag  (includeBS,   Messages.INVALID_BOOL);
      DateTime  vStartDateBS   = Validate.reqDate  (startDateBS, Messages.INVALID_START_DATE);
      DateTime  vEndDateBS     = Validate.reqDate  (endDateBS,   Messages.INVALID_END_DATE);

      bool      vIncludeDS     = Validate.reqFlag  (includeDS,   Messages.INVALID_BOOL);
      DateTime  vStartDateDS   = Validate.reqDate  (startDateDS, Messages.INVALID_START_DATE);
      DateTime  vEndDateDS     = Validate.reqDate  (endDateDS,   Messages.INVALID_END_DATE);

      bool      vIncludeAS     = Validate.reqFlag  (includeAS,   Messages.INVALID_BOOL);
      DateTime  vStartDateAS   = Validate.reqDate  (startDateAS, Messages.INVALID_START_DATE);
      DateTime  vEndDateAS     = Validate.reqDate  (endDateAS,   Messages.INVALID_END_DATE);
      
      DateTime  vStartDate = Dates.StartOfMonth (vRefDate);
      DateTime  vEndDate   = Dates.EndOfMonth   (vRefDate);
            
      parms.Add(Database.SqlParm("@clientID",    SqlDbType.Int,      vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",       SqlDbType.Int,      vPatID,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startDate",   SqlDbType.DateTime, vStartDate,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",     SqlDbType.DateTime, vEndDate,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@includeBS",   SqlDbType.Bit,      vIncludeBS,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startDateBS", SqlDbType.DateTime, vStartDateBS, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDateBS",   SqlDbType.DateTime, vEndDateBS,   ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@includeDS",   SqlDbType.Bit,      vIncludeDS,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startDateDS", SqlDbType.DateTime, vStartDateDS, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDateDS",   SqlDbType.DateTime, vEndDateDS,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@includeAS",   SqlDbType.Bit,      vIncludeAS,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startDateAS", SqlDbType.DateTime, vStartDateAS, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDateAS",   SqlDbType.DateTime, vEndDateAS,   ParameterDirection.Input));

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
      
      ReturnInfoTable rd = Entities.viewInfoTbl (connSpedmon, log, uInfo, viewUDF, parms);
      return rd;
         
    }
                                                    
    /***************************************************************************
     * viewTbl */
    /**
     * Returns a data table of records for preview or record selection.
     * 
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewTbl (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                           bool   paged,
                                           string pageNumber,
                                           string clientID,
                                           string patID,
                                           string pracID,
                                           string canEdit,
                                           string active)
    {
      ReturnDataTable so = new ReturnDataTable();
     
      /*----------------------------
       * Define our columns and
       * set the page order for 
       * paging
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        ss.addDisplayColumn("id");
        ss.addDisplayColumn("clientName as [Client]", true);
        ss.addDisplayColumn("patName    as [Patient]", true);
        ss.addDisplayColumn("dob        as [DOB]",     true);        
        ss.addDisplayColumn("startDate  as [1:1 Svcs Start Date]");
        ss.addDisplayColumn("endDate    as [1:1 Svcs End Date]");
        ss.addDisplayColumn("aideName   as [Aides Real Name]");
        ss.addDisplayColumn("pracName   as [SpEdCare Practitioner]");
        ss.addDisplayColumn("siteName   as [Site]");
        ss.addDisplayColumn("dbo.RPT_BIT_TO_YN(AideSvcsAuthInIEP) as [Svcs Auth In IEP]");
        ss.addDisplayColumn("dbo.RPT_BIT_TO_YN(SvcsAreMedNes)     as [Svcs Are Med Nec]");        
        ss.addDisplayColumn("OneOnOneAideType  as [Aide Type]");
        ss.addDisplayColumn("BusMinsAM         as [AM Bus Mins]");
        ss.addDisplayColumn("SiteMins          as [School Mins]");        
        ss.addDisplayColumn("BusMinsPM         as [PM Bus Mins]");        
                
        pageroworder = ss.pageRowOrder();

      };

      /*----------------------------
       * Call base method which
       * handles the rest 
       *----------------------------*/

      so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
        delegate { return OneOnOneAideAssignments.view(connSpedmon, log, uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, canEdit, active, clientID, patID, pracID, dc); });
   
      /*----------------------------
       * Add a title and footer
       *----------------------------*/
                   
      so.tableName   = "Subscriptions";
      so.tableFooter = Messages.CONFIDENTIAL;
     
      /*----------------------------
       * Done
       *----------------------------*/

      return so;
     
    }
   
    /***************************************************************************
     * view */
    /**
     * 
     **************************************************************************/  
    
    public static ReturnDB view (SqlConnection connSpedmon, 
                                 DetailsLog log, 
                                 UserInfo uInfo,
                                 int    recViewType,
                                 bool   pagedOrTop,
                                 string idx,
                                 string canEdit,
                                 string active,
                                 string clientID,
                                 string patID,
                                 string pracID,
                                 defineCols dc) 
    {
    
      string viewUDF = "dbo.ONE_ON_ONE_AIDE_ASSIGNMENT_VIEW (@userID, @userGroup, @userRank ,@clientID, @patID, @pracID, @active, @recID)";    

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
        
      Object vClientID = Validate.optClientID (uInfo, clientID);
      Object vPatID    = Validate.optInteger  (patID,  Messages.INVALID_PAT_ID);
      Object vPracID   = Validate.optInteger  (pracID, Messages.INVALID_PRAC_ID);

      parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",    SqlDbType.Int, vPatID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pRACID",   SqlDbType.Int, vPracID,   ParameterDirection.Input));

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    

    }    
  }
}
