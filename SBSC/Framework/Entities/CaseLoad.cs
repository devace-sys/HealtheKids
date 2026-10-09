using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    
  public class CaseLoad:Entity
  {    
    public string   clientName;
    public string   pracName;
    public string   patName;
    
    public long     clientID;
    public long     pracID;
    public long     patID;
    
    public DateTime AsmtDueAnn;
    public DateTime AsmtDueTriAnn;
    
    public int TmtFrqInd2;
    public int TmtDurInd2;
    public int TmtFrqInd3;
    public int TmtDurInd3;
    public int TmtFrqInd4;
    public int TmtDurInd4;
    public int TmtFrqInd5;
    public int TmtDurInd5;
    public int TmtFrqInd6;
    public int TmtDurInd6;

    public int TmtFrqGrp2;
    public int TmtDurGrp2;
    public int TmtFrqGrp3;
    public int TmtDurGrp3;
    public int TmtFrqGrp4;
    public int TmtDurGrp4;
    public int TmtFrqGrp5;
    public int TmtDurGrp5;
    public int TmtFrqGrp6;
    public int TmtDurGrp6;
    
    public string   TmtSchedule;
    public DateTime TmtEffectiveDate;
    
  }
  
  /***************************************************************************
   * CaseLoads */
  /**
   * 
   ***************************************************************************/

  public class CaseLoads: Entities
	{
    /***************************************************************************
     * SEL_LABEL */
    /**
     * Selection labels for menus and screens
     ***************************************************************************/       
    
    public const string SEL_LABEL             = "Caseload List";
    public const string SEL_LABEL_ADD         = "Add Patient(s) to List";
    public const string SEL_LABEL_VIEW        = "View List";
    public const string SEL_LABEL_EDIT_DELETE = "Edit or Remove Patient";
    public const string SEL_LABEL_EDIT        = "Edit Patient on List";   
    public const string SEL_LABEL_DELETE      = "Remove Patient from List";

   
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
      
      Object   vClientID = Validate.optClientID (uInfo, "");
      Object   vPracID   = Validate.optPracID   (uInfo,   "");
      DateTime vEndDate  = Validate.reqDate     (endDate, Messages.INVALID_END_DATE);
      
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

      return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "CASELOAD_Delete", ref parms);
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

    public static CaseLoad load(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string recID)
    {
      return (CaseLoad)Entities.load(connSpedmon, log, uInfo, recID, typeof(CaseLoad),
      delegate { return CaseLoads.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", "", "", null); });
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
    * @param  startDate       Start date of relationship

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
  
    public static ReturnSaveRecord save (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                         string clientID, 
                                         string pracID, 
                                         string patID,
                                         string startDate,
                                         
                                         string asmtDueAnn,
                                         string asmtDueTriAnn,
                                         string tmtEffDate,
                                         
                                         string tmtFrqInd2,
                                         string tmtDurInd2,
                                         string tmtFrqGrp2,
                                         string tmtDurGrp2,

                                         string tmtFrqInd3,
                                         string tmtDurInd3,
                                         string tmtFrqGrp3,
                                         string tmtDurGrp3,

                                         string tmtFrqInd4,
                                         string tmtDurInd4,
                                         string tmtFrqGrp4,
                                         string tmtDurGrp4,

                                         string tmtFrqInd5,
                                         string tmtDurInd5,
                                         string tmtFrqGrp5,
                                         string tmtDurGrp5,

                                         string tmtFrqInd6,
                                         string tmtDurInd6,
                                         string tmtFrqGrp6,
                                         string tmtDurGrp6,

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
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
      int  vClientID        = Validate.reqClientID  (uInfo, clientID);
      int  vPracID          = Validate.reqPracID    (uInfo, pracID);      
      int  vPatID           = Validate.reqInteger   (patID,         Messages.INVALID_PAT_ID);  
      
      DateTime vStartDate     = Validate.reqDate      (startDate,     Messages.INVALID_START_DATE);      
      Object   vAsmtDueAnn    = Validate.optDate      (asmtDueAnn,    Messages.INVALID_ASMT_ANN_DATE );
      Object   vAsmtDueTriAnn = Validate.optDate      (asmtDueTriAnn, Messages.INVALID_ASMT_TRI_ANN_DATE );
      Object   vTmtEffDate    = Validate.optDate      (tmtEffDate,    Messages.INVALID_START_DATE);
      
      Object vTmtFrqInd2 = Validate.optInteger(tmtFrqInd2, Messages.INVALID_NUM_APTS, true);
      Object vTmtDurInd2 = Validate.optInteger(tmtDurInd2, Messages.INVALID_NUM_MINS, true);
      Object vTmtFrqGrp2 = Validate.optInteger(tmtFrqGrp2, Messages.INVALID_NUM_APTS, true);
      Object vTmtDurGrp2 = Validate.optInteger(tmtDurGrp2, Messages.INVALID_NUM_MINS, true);
      
      Object vTmtFrqInd3 = Validate.optInteger(tmtFrqInd3, Messages.INVALID_NUM_APTS, true);
      Object vTmtDurInd3 = Validate.optInteger(tmtDurInd3, Messages.INVALID_NUM_MINS, true);
      Object vTmtFrqGrp3 = Validate.optInteger(tmtFrqGrp3, Messages.INVALID_NUM_APTS, true);
      Object vTmtDurGrp3 = Validate.optInteger(tmtDurGrp3, Messages.INVALID_NUM_MINS, true);

      Object vTmtFrqInd4 = Validate.optInteger(tmtFrqInd4, Messages.INVALID_NUM_APTS, true);
      Object vTmtDurInd4 = Validate.optInteger(tmtDurInd4, Messages.INVALID_NUM_MINS, true);
      Object vTmtFrqGrp4 = Validate.optInteger(tmtFrqGrp4, Messages.INVALID_NUM_APTS, true);
      Object vTmtDurGrp4 = Validate.optInteger(tmtDurGrp4, Messages.INVALID_NUM_MINS, true);

      Object vTmtFrqInd5 = Validate.optInteger(tmtFrqInd5, Messages.INVALID_NUM_APTS, true);
      Object vTmtDurInd5 = Validate.optInteger(tmtDurInd5, Messages.INVALID_NUM_MINS, true);
      Object vTmtFrqGrp5 = Validate.optInteger(tmtFrqGrp5, Messages.INVALID_NUM_APTS, true);
      Object vTmtDurGrp5 = Validate.optInteger(tmtDurGrp5, Messages.INVALID_NUM_MINS, true);

      Object vTmtFrqInd6 = Validate.optInteger(tmtFrqInd6, Messages.INVALID_NUM_APTS, true);
      Object vTmtDurInd6 = Validate.optInteger(tmtDurInd6, Messages.INVALID_NUM_MINS, true);
      Object vTmtFrqGrp6 = Validate.optInteger(tmtFrqGrp6, Messages.INVALID_NUM_APTS, true);
      Object vTmtDurGrp6 = Validate.optInteger(tmtDurGrp6, Messages.INVALID_NUM_MINS, true);


      parms.Add(Database.SqlParm("@clientID",      SqlDbType.Int,      vClientID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",        SqlDbType.Int,      vPracID,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",         SqlDbType.Int,      vPatID,         ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@startDate",     SqlDbType.DateTime, vStartDate,     ParameterDirection.Input));

      parms.Add(Database.SqlParm("@asmtDueAnn",    SqlDbType.DateTime, vAsmtDueAnn,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@asmtDueTriAnn", SqlDbType.DateTime, vAsmtDueTriAnn, ParameterDirection.Input));

      parms.Add(Database.SqlParm("@tmtEffDate",    SqlDbType.DateTime, vTmtEffDate,    ParameterDirection.Input));

      parms.Add(Database.SqlParm("@tmtFrqInd2",    SqlDbType.Int,      vTmtFrqInd2, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtDurInd2",    SqlDbType.Int,      vTmtDurInd2, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtFrqGrp2",    SqlDbType.Int,      vTmtFrqGrp2, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtDurGrp2",    SqlDbType.Int,      vTmtDurGrp2, ParameterDirection.Input));    

      parms.Add(Database.SqlParm("@tmtFrqInd3",    SqlDbType.Int,      vTmtFrqInd3, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtDurInd3",    SqlDbType.Int,      vTmtDurInd3, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtFrqGrp3",    SqlDbType.Int,      vTmtFrqGrp3, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtDurGrp3",    SqlDbType.Int,      vTmtDurGrp3, ParameterDirection.Input));    

      parms.Add(Database.SqlParm("@tmtFrqInd4",    SqlDbType.Int,      vTmtFrqInd4, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtDurInd4",    SqlDbType.Int,      vTmtDurInd4, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtFrqGrp4",    SqlDbType.Int,      vTmtFrqGrp4, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtDurGrp4",    SqlDbType.Int,      vTmtDurGrp4, ParameterDirection.Input));    

      parms.Add(Database.SqlParm("@tmtFrqInd5",    SqlDbType.Int,      vTmtFrqInd5, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtDurInd5",    SqlDbType.Int,      vTmtDurInd5, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtFrqGrp5",    SqlDbType.Int,      vTmtFrqGrp5, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtDurGrp5",    SqlDbType.Int,      vTmtDurGrp5, ParameterDirection.Input));    

      parms.Add(Database.SqlParm("@tmtFrqInd6",    SqlDbType.Int,      vTmtFrqInd6, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtDurInd6",    SqlDbType.Int,      vTmtDurInd6, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtFrqGrp6",    SqlDbType.Int,      vTmtFrqGrp6, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtDurGrp6",    SqlDbType.Int,      vTmtDurGrp6, ParameterDirection.Input));    

           
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "CASELOAD_Save", Messages.DUP_CASELOAD_REC , ref parms, null);

    }    
    
   /***************************************************************************
    * createTmtScheduleString */
   /**
    * Calls udf that generates treatment schedule string
    * 
    ***************************************************************************/   
   
   public static ReturnValue generateTmtSchedStr (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                                  string tmtFrqInd2,
                                                  string tmtDurInd2,
                                                  string tmtFrqGrp2,
                                                  string tmtDurGrp2,

                                                  string tmtFrqInd3,
                                                  string tmtDurInd3,
                                                  string tmtFrqGrp3,
                                                  string tmtDurGrp3,

                                                  string tmtFrqInd4,
                                                  string tmtDurInd4,
                                                  string tmtFrqGrp4,
                                                  string tmtDurGrp4,

                                                  string tmtFrqInd5,
                                                  string tmtDurInd5,
                                                  string tmtFrqGrp5,
                                                  string tmtDurGrp5,

                                                  string tmtFrqInd6,
                                                  string tmtDurInd6,
                                                  string tmtFrqGrp6,
                                                  string tmtDurGrp6)
   {
      
      ReturnValue so = new ReturnValue();
      
      Object vTmtFrqInd2 = Validate.optInteger(tmtFrqInd2, Messages.INVALID_NUM_APTS, true);
      Object vTmtDurInd2 = Validate.optInteger(tmtDurInd2, Messages.INVALID_NUM_MINS, true);
      Object vTmtFrqGrp2 = Validate.optInteger(tmtFrqGrp2, Messages.INVALID_NUM_APTS, true);
      Object vTmtDurGrp2 = Validate.optInteger(tmtDurGrp2, Messages.INVALID_NUM_MINS, true);
      
      Object vTmtFrqInd3 = Validate.optInteger(tmtFrqInd3, Messages.INVALID_NUM_APTS, true);
      Object vTmtDurInd3 = Validate.optInteger(tmtDurInd3, Messages.INVALID_NUM_MINS, true);
      Object vTmtFrqGrp3 = Validate.optInteger(tmtFrqGrp3, Messages.INVALID_NUM_APTS, true);
      Object vTmtDurGrp3 = Validate.optInteger(tmtDurGrp3, Messages.INVALID_NUM_MINS, true);

      Object vTmtFrqInd4 = Validate.optInteger(tmtFrqInd4, Messages.INVALID_NUM_APTS, true);
      Object vTmtDurInd4 = Validate.optInteger(tmtDurInd4, Messages.INVALID_NUM_MINS, true);
      Object vTmtFrqGrp4 = Validate.optInteger(tmtFrqGrp4, Messages.INVALID_NUM_APTS, true);
      Object vTmtDurGrp4 = Validate.optInteger(tmtDurGrp4, Messages.INVALID_NUM_MINS, true);

      Object vTmtFrqInd5 = Validate.optInteger(tmtFrqInd5, Messages.INVALID_NUM_APTS, true);
      Object vTmtDurInd5 = Validate.optInteger(tmtDurInd5, Messages.INVALID_NUM_MINS, true);
      Object vTmtFrqGrp5 = Validate.optInteger(tmtFrqGrp5, Messages.INVALID_NUM_APTS, true);
      Object vTmtDurGrp5 = Validate.optInteger(tmtDurGrp5, Messages.INVALID_NUM_MINS, true);

      Object vTmtFrqInd6 = Validate.optInteger(tmtFrqInd6, Messages.INVALID_NUM_APTS, true);
      Object vTmtDurInd6 = Validate.optInteger(tmtDurInd6, Messages.INVALID_NUM_MINS, true);
      Object vTmtFrqGrp6 = Validate.optInteger(tmtFrqGrp6, Messages.INVALID_NUM_APTS, true);
      Object vTmtDurGrp6 = Validate.optInteger(tmtDurGrp6, Messages.INVALID_NUM_MINS, true);

      string vTmtSch = "";
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm("@tmtFrqInd2",    SqlDbType.Int,      vTmtFrqInd2, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtDurInd2",    SqlDbType.Int,      vTmtDurInd2, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtFrqGrp2",    SqlDbType.Int,      vTmtFrqGrp2, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtDurGrp2",    SqlDbType.Int,      vTmtDurGrp2, ParameterDirection.Input));    

      parms.Add(Database.SqlParm("@tmtFrqInd3",    SqlDbType.Int,      vTmtFrqInd3, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtDurInd3",    SqlDbType.Int,      vTmtDurInd3, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtFrqGrp3",    SqlDbType.Int,      vTmtFrqGrp3, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtDurGrp3",    SqlDbType.Int,      vTmtDurGrp3, ParameterDirection.Input));    

      parms.Add(Database.SqlParm("@tmtFrqInd4",    SqlDbType.Int,      vTmtFrqInd4, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtDurInd4",    SqlDbType.Int,      vTmtDurInd4, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtFrqGrp4",    SqlDbType.Int,      vTmtFrqGrp4, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtDurGrp4",    SqlDbType.Int,      vTmtDurGrp4, ParameterDirection.Input));    

      parms.Add(Database.SqlParm("@tmtFrqInd5",    SqlDbType.Int,      vTmtFrqInd5, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtDurInd5",    SqlDbType.Int,      vTmtDurInd5, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtFrqGrp5",    SqlDbType.Int,      vTmtFrqGrp5, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtDurGrp5",    SqlDbType.Int,      vTmtDurGrp5, ParameterDirection.Input));    

      parms.Add(Database.SqlParm("@tmtFrqInd6",    SqlDbType.Int,      vTmtFrqInd6, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtDurInd6",    SqlDbType.Int,      vTmtDurInd6, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtFrqGrp6",    SqlDbType.Int,      vTmtFrqGrp6, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtDurGrp6",    SqlDbType.Int,      vTmtDurGrp6, ParameterDirection.Input));    
      parms.Add(Database.SqlParm("@tmtSch",        SqlDbType.VarChar,  vTmtSch,     ParameterDirection.Output, 1000));    

      string sql = "select @tmtSch = dbo.RPT_TMT_SCHEDULE(@tmtFrqInd2, @tmtDurInd2, @tmtFrqGrp2, @tmtDurGrp2, @tmtFrqInd3, @tmtDurInd3, @tmtFrqGrp3, @tmtDurGrp3, @tmtFrqInd4, @tmtDurInd4, @tmtFrqGrp4, @tmtDurGrp4, @tmtFrqInd5, @tmtDurInd5, @tmtFrqGrp5, @tmtDurGrp5, @tmtFrqInd6, @tmtDurInd6, @tmtFrqGrp6, @tmtDurGrp6)";

     /*----------------------------
      * Setup our output class
      *----------------------------*/

      ReturnDB rd = Database.execQuery(connSpedmon, log, sql, false, parms);
      
      return so;
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
                                 defineCols dc)
    { 
      
      string viewUDF = "CASELOAD_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @active, @recID)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/  
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
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
      
      parms.Add(Database.SqlParm("@clientID",  SqlDbType.Int,  vClientID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",    SqlDbType.Int,  vPracID,    ParameterDirection.Input));

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
      
      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      

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
                                          string patID,
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

       ss.addDisplayColumn("patName as [Patient Name (Last, First)]",                true);       
       ss.addDisplayColumn("dbo.RPT_DATE_FMT(startDate) as [Start Date]",            true);
       ss.addDisplayColumn("dbo.RPT_DATE_FMT(AsmtDueAnn) as [Ann Asmt Due]",         true);
       ss.addDisplayColumn("dbo.RPT_DATE_FMT(AsmtDueTriAnn) as [Tri Asmt Due]",      true);
       ss.addDisplayColumn("TmtSchedule as [Treatment Schedule]",                    true);
       ss.addDisplayColumn("dbo.RPT_DATE_FMT(TmtEffectiveDate) as [As Of]", true);

       //ss.addPageOrderColumn("[Patient Name (Last, First)]");

       pageroworder = ss.pageRowOrder();

     };

     /*----------------------------
      * Call base method which
      * handles the rest 
      *----------------------------*/

     so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
       delegate { return CaseLoads.view(connSpedmon, log, uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, canEdit, active, clientID, pracID, dc); });
   
     /*----------------------------
      * Add a title and footer
      *----------------------------*/
                   
     so.tableName   = "Caseload";
     so.tableFooter = Messages.CONFIDENTIAL;
     
     /*----------------------------
      * Done
      *----------------------------*/

     return so;
     
   }
 } 
}

