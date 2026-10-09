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
   * ServiceJournalJournal */
  /**
   * Service journal
   **************************************************************************/

  public class ServiceJournalJournal
  {
    public const string DEFAULT_PAGING_ORDER = @"dos desc, id desc";

    public long     id;
    public string   name;
    public long     clientID;
    public string   clientName;
    public long     patID;    
    public string   patName;
    public string   dos;
    public DateTime dosVal;
    public bool     patientAbsent;
    public bool     completed;
    public bool     isReopened;
    public bool     canEdit;
    public string   patAbsentOrPresentStr;
    public string   closedOrOpenStr;
    public string   canEditStr;
    public string   attendance;
    public string   openingPracName;
  }
      
  /***************************************************************************
   * ServiceJournalsJournals */
  /**
   * Methods to work with service journals
   **************************************************************************/

  public class ServiceJournalsJournals:Entities
  {          
    public const string URL_SVC             = "servicejournalsjournals.asmx";
    public const string URL_ASMX            = "servicejournalsjournals.asmx";
    public const string URL_ASMX_SAVE       = URL_ASMX + "/save";
    public const string URL_ASMX_DELETE     = URL_ASMX + "/delete";
    public const string URL_ASMX_CLOSE      = URL_ASMX + "/close";
    public const string URL_SVC_SAVE_INLINE = URL_SVC + @"/saveinline";
    public const string URL_REST_VIEW_OPEN  = @"api/v1/openservicejournals";
        
    /***************************************************************************
     * URL_SVC_SAVE_INLINE_BASE() */
    /**
     * 
     **************************************************************************/  
    public static string URL_SVC_SAVE_INLINE_BASE()
    { 
       return MBA.HttpApplication.createLink(ServiceJournalsJournals.URL_SVC_SAVE_INLINE, true);
    }

    /***************************************************************************
     * URL_REST_VIEW_OPEN_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_REST_VIEW_OPEN_BASE()
    { 
       return MBA.HttpApplication.createLink(ServiceJournalsJournals.URL_REST_VIEW_OPEN, true);
    }

    /***************************************************************************
     * URL_REST_DELETE_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_REST_DELETE_BASE()
    { 
       return MBA.HttpApplication.createLink(ServiceJournalsJournals.URL_ASMX_DELETE, true);
    }

    /***************************************************************************
     * URL_REST_CLOSE_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_REST_CLOSE_BASE()
    { 
       return MBA.HttpApplication.createLink(ServiceJournalsJournals.URL_ASMX_CLOSE, true);
    }

                   
    /***************************************************************************
     * delete */
    /**
     * Delete journal entry
     ***************************************************************************/       
    
    public static ReturnSaveRecord delete (   SqlConnection connSpedmon
                                            , DetailsLog    log
                                            , UserInfo      uInfo
                                            , string        editDelReason
                                            , string        validateRec
                                            , string        recID)
    {           
     
      /*----------------------------
       * Check for required and 
       * optional parameters
       * and validate data integrity
       * of all supplied parameters
       *----------------------------*/

      Object vClientID  = Validate.optClientID (uInfo, ""); 
      Object vPracID    = Validate.optPracID   (uInfo, ""); 
      
      /*----------------------------
       * Collect all of the parameters
       * that are specific to this
       * delete method.
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@clientID",  SqlDbType.Int, vClientID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",    SqlDbType.Int, vPracID,    ParameterDirection.Input));
      
      /*----------------------------
       * Call base method 
       *----------------------------*/
     
      return Entities.delete(connSpedmon,log,uInfo,editDelReason,validateRec,recID,"SVCJOURNAL_JOURNAL_DELETE",ref parms);
    
    }
    
    
    /***************************************************************************
     * save */
    /**
     * Save a service journal
     *
     * @param  userID          User id of who is recording service
     * @param  userGroup       1 = Client, 2 = SBSC (from users db)
     * @param  userRank        Users role ranking
     * @param  clientID        Client id
     * @param  pracID          Practitioner id
     * @param  patID           Patient id
     * @param  DOS             Date of service
     * @param  SvcType         Type of service
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
  
    public static ReturnSaveRecord save (  SqlConnection connSpedmon
                                         , DetailsLog    log
                                         , UserInfo      uInfo
                                         , string        clientID
                                         , string        pracID
                                         , string        patID
                                         , string        dos
                                         , string        patAbsent
                                         , string        editDelReason
                                         , string        validateRec
                                         , string        saveType
                                         , string        recID)
    {           
            
      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      List<SqlParameter> parms  = new List<SqlParameter>();
      
      int       vClientID     = Validate.reqClientID        (uInfo,      clientID);
      int       vPracID       = Validate.reqPracID          (uInfo,      pracID);
      int       vPatID        = Validate.reqInteger         (patID,      Messages.INVALID_PAT_ID);
      string    vReference    = uInfo.userIP;
      DateTime  vDOS          = Validate.reqDate            (dos,        Messages.INVALID_DOS, Constants.VAL_OPT_DATE_NO_FUTURE);
      bool      vPatAbsent    = Validate.reqFlag            (patAbsent,  Messages.INVALID_FLAG_PAT_ABSNT);
            
      parms.Add(Database.SqlParm("@clientID",        SqlDbType.Int,      vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",          SqlDbType.Int,      vPracID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",           SqlDbType.Int,      vPatID,       ParameterDirection.Input));  
      parms.Add(Database.SqlParm("@reference",       SqlDbType.VarChar,  vReference,   ParameterDirection.Input, 500));
      parms.Add(Database.SqlParm("@dos",             SqlDbType.DateTime, vDOS,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patAbsent",       SqlDbType.Bit,      vPatAbsent,   ParameterDirection.Input)); 
      
      parms.Add(Database.SqlParm("@MsgInvCombo",     SqlDbType.VarChar,  Messages.INVALID_PPN_COMBO,      ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgMinReq",       SqlDbType.VarChar,  Messages.MIN_REQ,                ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgMinDef",       SqlDbType.VarChar,  Messages.MIN_DEF,                ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgMilReq",       SqlDbType.VarChar,  Messages.MIL_REQ,                ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgPatElg",       SqlDbType.VarChar,  Messages.PAT_ELG,                ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgPatDOBGteDOS", SqlDbType.VarChar,  Messages.PAT_DOB_GTE_DOS,        ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgPatAbsent",    SqlDbType.VarChar,  Messages.PAT_ABSENT_NO_CLAIM,    ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgFutureDOS",    SqlDbType.VarChar,  Messages.VAL_SVC_REC_DOS_FUTURE, ParameterDirection.Input, 1000));

      
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "SVCJOURNAL_JOURNAL_SAVE", @"Service journal for this patient and date already exists", ref parms,null);
    }     

    /***************************************************************************
     * close */
    /**
     * Close a service journal
     *
     * @param  userID          User id of who is recording service
     * @param  userGroup       1 = Client, 2 = SBSC (from users db)
     * @param  userRank        Users role ranking
     * @param  clientID        Client id
     * @param  pracID          Practitioner id
     * @param  patID           Patient id
     * @param  DOS             Date of service
     * @param  SvcType         Type of service
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
  
    public static ReturnSaveRecord close (   SqlConnection connSpedmon
                                           , DetailsLog    log
                                           , UserInfo      uInfo
                                           , string        clientID
                                           , string        pracID
                                           , string        patID
                                           , string        editDelReason
                                           , string        validateRec
                                           , string        saveType
                                           , string        recID)
    {           
            
      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      List<SqlParameter> parms  = new List<SqlParameter>();
      
      int       vClientID            = Validate.reqClientID (uInfo, clientID);
      int       vPracID              = Validate.reqPracID   (uInfo, pracID);      
      int       vPatID               = Validate.reqInteger  (patID, Messages.INVALID_PAT_ID);
      string    vReference           = uInfo.userIP;
            
      parms.Add(Database.SqlParm("@clientID",             SqlDbType.Int,      vClientID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",               SqlDbType.Int,      vPracID,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",                SqlDbType.Int,      vPatID,               ParameterDirection.Input));
      
      parms.Add(Database.SqlParm("@reference",            SqlDbType.VarChar,  vReference,           ParameterDirection.Input, 500));
      
      parms.Add(Database.SqlParm("@MsgInvCombo",          SqlDbType.VarChar,  Messages.INVALID_PPN_COMBO,      ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgMinReq",            SqlDbType.VarChar,  Messages.MIN_REQ,                ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgMinDef",            SqlDbType.VarChar,  Messages.MIN_DEF,                ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgMilReq",            SqlDbType.VarChar,  Messages.MIL_REQ,                ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgPatElg",            SqlDbType.VarChar,  Messages.PAT_ELG,                ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgPatDOBGteDOS",      SqlDbType.VarChar,  Messages.PAT_DOB_GTE_DOS,        ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgPatAbsent",         SqlDbType.VarChar,  Messages.PAT_ABSENT_NO_CLAIM,    ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgFutureDOS",         SqlDbType.VarChar,  Messages.VAL_SVC_REC_DOS_FUTURE, ParameterDirection.Input, 1000));

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "SVCJOURNAL_JOURNAL_CLOSE", @"Service journal for this patient and date already exists", ref parms,null);
    }     

    /***************************************************************************
     * reopen */
    /**
     * Reopen a service journal
     *
     * @param  userID          User id of who is recording service
     * @param  userGroup       1 = Client, 2 = SBSC (from users db)
     * @param  userRank        Users role ranking
     * @param  clientID        Client id
     * @param  pracID          Practitioner id
     * @param  patID           Patient id
     * @param  DOS             Date of service
     * @param  SvcType         Type of service
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
  
    public static ReturnSaveRecord reopen (   SqlConnection connSpedmon
                                            , DetailsLog    log
                                            , UserInfo      uInfo
                                            , string        clientID
                                            , string        pracID
                                            , string        patID
                                            , string        editDelReason
                                            , string        validateRec
                                            , string        saveType
                                            , string        recID)
    {           
            
      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      List<SqlParameter> parms  = new List<SqlParameter>();
      
      int       vClientID        = Validate.reqClientID (uInfo, clientID);
      int       vPracID          = Validate.reqPracID   (uInfo, pracID);      
      int       vPatID           = Validate.reqInteger  (patID, Messages.INVALID_PAT_ID);
      string    vReference       = uInfo.userIP;
            
      parms.Add(Database.SqlParm("@clientID",             SqlDbType.BigInt,   vClientID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",               SqlDbType.BigInt,   vPracID,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",                SqlDbType.BigInt,   vPatID,               ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@reference",            SqlDbType.VarChar,  vReference,           ParameterDirection.Input, 500));      
      parms.Add(Database.SqlParm("@MsgInvCombo",          SqlDbType.VarChar,  Messages.INVALID_PPN_COMBO,      ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgMinReq",            SqlDbType.VarChar,  Messages.MIN_REQ,                ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgMinDef",            SqlDbType.VarChar,  Messages.MIN_DEF,                ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgMilReq",            SqlDbType.VarChar,  Messages.MIL_REQ,                ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgPatElg",            SqlDbType.VarChar,  Messages.PAT_ELG,                ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgPatDOBGteDOS",      SqlDbType.VarChar,  Messages.PAT_DOB_GTE_DOS,        ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgPatAbsent",         SqlDbType.VarChar,  Messages.PAT_ABSENT_NO_CLAIM,    ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgFutureDOS",         SqlDbType.VarChar,  Messages.VAL_SVC_REC_DOS_FUTURE, ParameterDirection.Input, 1000));

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "SVCJOURNAL_JOURNAL_REOPEN", @"Service journal has already been reopened", ref parms,null);
    }     

    /***************************************************************************
     * view */
    /**
     * 
     **************************************************************************/  
    
    public static ReturnDB view (SqlConnection connSpedmon, 
                                 DetailsLog    log, 
                                 UserInfo      uInfo,
                                 int           recViewType,
                                 bool          pagedOrTop,
                                 string        idx,
                                 string        canEdit,
                                 string        active,
                                 string        term,
                                 string        clientID,
                                 string        pracID,
                                 string        patID,
                                 string        dos,
                                 string        completed,
                                 defineCols    dc) 
    {
    
      string viewUDF = "dbo.SvcJournal_Journals_View (null, null, null, @clientID , @patID, @dos, @completed, @recID)";    

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
       
      Object    vClientID       = Validate.optClientID (uInfo,     clientID);
      Object    vPatID          = Validate.optInteger  (patID,     Messages.INVALID_PAT_ID);
      Object    vDOS            = Validate.optDate     (dos,       Messages.INVALID_DATES);
      Object    vCompleted      = Validate.optFlag     (completed, Messages.INVALID_FLAG_ACTIVE);

      List<SqlParameter> parms = new List<SqlParameter>();
                   
      parms.Add(Database.SqlParm("@clientID",  SqlDbType.Int,      vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",     SqlDbType.Int,      vPatID,       ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@dos",       SqlDbType.DateTime, vDOS,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@completed", SqlDbType.Bit,      vCompleted,   ParameterDirection.Input));
              
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    

    }       

    /***************************************************************************
     * load */
    /**
     * Outputs data for a single journal journal
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing the client id and the pracid
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @param  patID           PatID
     * @return                 ReturnEntity
     ***************************************************************************/

    public static ServiceJournalJournal load (   SqlConnection connSpedmon
                                               , DetailsLog    log
                                               , UserInfo      uInfo
                                               , string        clientID
                                               , string        recID)
    {
      
      return (ServiceJournalJournal) Entities.load(connSpedmon, log, uInfo, recID, typeof(ServiceJournalJournal),
      delegate { return ServiceJournalsJournals.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", "",clientID,"","","","",null); });
    } 
    
    /***************************************************************************
     * viewSel */
    /**
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing the client id and the pracid
     **************************************************************************/  
    
    public static ReturnSel viewSel (   SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , bool          top
                                      , string        topSize
                                      , string        term
                                      , string        clientID
                                      , string        pracID
                                      , string        patID
                                      , string        dos
                                      , string        completed)
    {
             
      /*----------------------------
       * Define our context column
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){
        ss.addDisplayColumn("rowOrder as [rowOrder]", true);
        pageroworder = ss.pageRowOrder();
      };
     
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.viewSel(connSpedmon, log, uInfo ,top, topSize, 
      delegate{return ServiceJournalsJournals.view (connSpedmon,log,uInfo,Entities.REC_VIEW_SEL, top, topSize, null, null, term, clientID, pracID, patID, dos, completed, dc);});

    }
           
    /***************************************************************************
     * viewTbl */
    /**
     * Returns a data table of records for preview or record selection.
     *
     * Note: This calls the view method and the view method takes care of
     * enforcing the client id and the pracid
     *
     * @return                 ReturnDataTable
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
                                           , string        dos 
                                           , string        completed)
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
        ss.addDisplayColumn("dos                   as [Service Date]");        
        ss.addDisplayColumn("patName               as [Patient]");
        ss.addDisplayColumn("patAbsentOrPresentStr as [Absent or Present]");
        ss.addDisplayColumn("canEditStr            as [Journal Can Still Be Modifed]");
        ss.addDisplayColumn("rowOrder              as [rowOrder]", true);
        pageroworder = ss.pageRowOrder();
      };

      /*----------------------------
       * Call base method which
       * handles the rest 
       *----------------------------*/
 
      so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
        delegate { return ServiceJournalsJournals.view (connSpedmon,log,uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, "", "", null, clientID, pracID, patID, dos, completed, dc); });
   
      /*----------------------------
       * Add a title and footer
       *----------------------------*/
                   
      so.tableName   = "Service Journals";
      so.tableFooter = Messages.CONFIDENTIAL;
     
      /*----------------------------
       * Done
       *----------------------------*/

      return so;
     
    } 
        
    /***************************************************************************
     * viewMissingStartOrEnd */
    /**
     *
     * Note: This needs to be the same column layout as the journal.view
     **************************************************************************/  
    
    public static ReturnDB viewMissingStartOrEnd (

        SqlConnection connSpedmon
      , DetailsLog    log 
      , UserInfo      uInfo
      , int           recViewType
      , bool          pagedOrTop
      , string        idx
      , string        canEdit
      , string        active
      , string        clientID
      , string        pracID                           
      , defineCols    dc) 
    {
    
      string viewUDF = "dbo.SvcJournal_Journals_With_Missing_Start_Or_End (@userID, @userGroup, @userRank, @clientID, @pracID)";

      Object  vClientID  = Validate.optClientID (uInfo, clientID);
      Object  vPracID    = Validate.optPracID   (uInfo, pracID);

      List<SqlParameter> parms = new List<SqlParameter>();
                   
      parms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt,   vClientID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",    SqlDbType.BigInt,   vPracID,    ParameterDirection.Input));
              
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

    }    
    
    /***************************************************************************
     * viewMissingStartOrEndTable/
    /**
     * Returns a data table of records for preview or record selection.
     * 
     * Note: This calls the coresponding view method and the view method 
     * takes care of enforcing the client id and the pracid
     *
     * Note: This needs to be the same column layout as the journal.view
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewMissingStartOrEndTbl (  SqlConnection connSpedmon
                                                            , DetailsLog    log
                                                            , UserInfo      uInfo
                                                            , bool          paged
                                                            , string        pageNumber
                                                            , string        canEdit
                                                            , string        active
                                                            , string        clientID
                                                            , string        pracID )
    {
      ReturnDataTable so = new ReturnDataTable();
     
      
      /*----------------------------
       * Define our columns and
       * set the page order for 
       * paging
       *
       * Note: This needs to be the 
       * same column layout as the 
       * journal.view
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        ss.addDisplayColumn("id");       
        ss.addDisplayColumn("dos                   as [Service Date]");        
        ss.addDisplayColumn("patName               as [Patient]");
        ss.addDisplayColumn("patAbsentOrPresentStr as [Absent or Present]");
        ss.addDisplayColumn("canEditStr            as [Journal Can Still Be Modifed]");
        ss.addDisplayColumn("rowOrder              as [rowOrder]", true);
        pageroworder = ss.pageRowOrder();
      };

      /*----------------------------
       * Call base method which
       * handles the rest 
       *----------------------------*/

      so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
        delegate { return ServiceJournalsJournals.viewMissingStartOrEnd (connSpedmon,log,uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, "", "", clientID, pracID, dc); });
   
      /*----------------------------
       * Add a title and footer
       *----------------------------*/
                   
      so.tableName   = "Missing Start or End";
      so.tableFooter = "Missing Start or End";
     
      /*----------------------------
       * Done
       *----------------------------*/

      return so;
     
    } 


    /***************************************************************************
     * viewMisingStartOrEndList */
    /**
     * Generates list
     *
     ***************************************************************************/  
   
    public static List<ServiceJournalJournal> viewMissingStartOrEndList  (  SqlConnection connSpedmon
                                                                          , DetailsLog    log
                                                                          , UserInfo      uInfo
                                                                          , string        clientID
                                                                          , string        pracID  )
    {
   
      List<ServiceJournalJournal> Journals = new List<ServiceJournalJournal>();                 
      ReturnDB rd = ServiceJournalsJournals.viewMissingStartOrEnd (connSpedmon,log,uInfo, Entities.REC_VIEW_RAW, false, null, null,null, clientID, pracID, null);                                                               
      List<Object> slo = Database.convertRecordsToList(ref rd.records, typeof(ServiceJournalJournal));     
      foreach (Object o in slo)
        Journals.Add((ServiceJournalJournal) o);             
      return Journals;
    }


/***********************************************************************************************************************
 * **************************************** Service Journal Refactor ***************************************************
 * *********************************************************************************************************************/


    /***************************************************************************
     * viewUserOpenJournals */
    /**
     * 
     **************************************************************************/  
    
    public static ReturnDB viewUserOpenJournals (SqlConnection connSpedmon, 
                                 DetailsLog    log, 
                                 UserInfo      uInfo,
                                 int           recViewType,
                                 bool          pagedOrTop,
                                 string        idx,
                                 string        canEdit,
                                 string        active,
                                 string        clientID,
                                 string        pracID,
                                 string        patID,
                                 string        dos,
                                 string        getAllClientJournalsIfPracAllowed,
                                 defineCols    dc) 
    {
    
      string viewUDF = "dbo.SVCJOURNAL_JOURNAL_USER_OPEN_JOURNALS_VIEW (null, null, null, @clientID , @pracID, @patID, @dos, @getAllClientJournalsIfPracAllowed, @recID)";    

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
       
      Object    vClientID                             = Validate.optClientID (uInfo,                                 clientID);
      Object    vPracID                               = Validate.optInteger  (pracID,                                Messages.INVALID_PRAC_ID);
      Object    vPatID                                = Validate.optInteger  (patID,                                 Messages.INVALID_PAT_ID);
      Object    vDOS                                  = Validate.optDate     (dos,                                   Messages.INVALID_DATES);
      Object    vGetAllClientJournalsIfPracAllowed = Validate.reqFlag     (getAllClientJournalsIfPracAllowed,  Messages.INVALID_BOOL);

      List<SqlParameter> parms = new List<SqlParameter>();
                   
      parms.Add(Database.SqlParm("@clientID",                             SqlDbType.Int,      vClientID,                             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",                               SqlDbType.Int,      vPracID,                               ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@patID",                                SqlDbType.Int,      vPatID,                                ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@dos",                                  SqlDbType.DateTime, vDOS,                                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@getAllClientJournalsIfPracAllowed", SqlDbType.Bit,      vGetAllClientJournalsIfPracAllowed,    ParameterDirection.Input));
              
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    

    }
        
    /*************************************************************************
     * viewUserOpenJournalsList */
    /**
     * Return a list of Service Journals records
     * 
     ***************************************************************************/

    public static List<ServiceJournalJournal> viewUserOpenJournalsList( SqlConnection connSpedmon
                                                         , DetailsLog    log
                                                         , UserInfo      uInfo
                                                         , string clientID
                                                         , string pracID
                                                         , string patID
                                                         , string dos
                                                         , string getAllClientJournalsIfPracAllowed
                                                         , string active)
      
     {
        var recs = new List<ServiceJournalJournal>();
        ReturnDB rd = ServiceJournalsJournals.viewUserOpenJournals(connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, null, null, active, clientID, pracID, patID, dos, getAllClientJournalsIfPracAllowed, null);       
        List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(ServiceJournalJournal));
        foreach (var o in slo) {
            recs.Add((ServiceJournalJournal) o);
        }
        return recs;
    }


    /***************************************************************************
     * viewObjectsOpenJournals 
     *
     * Returns a list of objects
     * 
     ***************************************************************************/

    public static ReturnObjects viewObjectsOpenJournals (   SqlConnection connSpedmon
                                              , DetailsLog log
                                              , UserInfo uInfo
                                              , bool pageObjectList
                                              , string pageOrder
                                              , string idx
                                              , string active
                                              , string clientID
                                              , string pracID
                                              , string patID
                                              , string dos
                                              , string getAllClientJournalsIfPracAllowed)
    {

      /* Default page order */

      if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = ServiceJournalJournal.DEFAULT_PAGING_ORDER;

      /* Define columns delegate is used to specify columns and page order 
       * We pass in the desired page row order here */

      defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        pageroworder = pageOrder;
      };

      return Entities.viewObjects (   connSpedmon
                                    , log
                                    , uInfo
                                    , typeof(ServiceJournalJournal)
                                    , pageObjectList
                                    , pageOrder
                                    , delegate {
                                        return ServiceJournalsJournals.viewUserOpenJournals(   connSpedmon
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
                                                                     , dos
                                                                     , getAllClientJournalsIfPracAllowed
                                                                     , dc);
                                         });
    }

         
  }
}
