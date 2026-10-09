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
   * PlanWriterPlansDiagnosis */
  /**
   *
   ***************************************************************************/

  public class PlanWriterDiagnosis : Entity
  {      
    public long    clientID;    
    public string  description;    
  }
  
  public class PlanWriterPlanDiagnosis : Entity
  {      
    public long    clientID;    
    public string  description;    
  }
  
  /***************************************************************************
   * PlanWriterConditionsDiagnosis */
  /**
   *
   ***************************************************************************/
  
  public class PlanWriterDiagnoses : Entities
  {
    public const string SEL_LABEL                     = @"Diagnoses";
    public const string SEL_LABEL_MANAGE              = @"Create and Manage Diagnoses";
    public const string SEL_LABEL_ADD                 = @"Add New";
    public const string SEL_LABEL_EDIT                = @"Edit";
    public const string SEL_LABEL_DELETE              = @"Delete";
    public const string URL_USER_ALL_MANAGE_DIAGNOSES = @"user_all_plan_writer_diagnoses_manage.aspx";

    public const string URL_ASMX     = @"plan_writer_diagnoses.asmx";
    public const string URL_VIEW_SEL = URL_ASMX + @"/viewSel";
    public const string URL_DELETE   = URL_ASMX + @"/delete";
    public const string URL_SAVE     = URL_ASMX + @"/saveDiagnosis";

    public static string URL_VIEW_SEL_BASE() { 
        return MBA.HttpApplication.createLink(URL_VIEW_SEL, true);
    }
    public static string URL_DELETE_BASE() { 
        return MBA.HttpApplication.createLink(URL_DELETE, true);
    }
    public static string URL_SAVE_BASE() { 
        return MBA.HttpApplication.createLink(URL_SAVE, true);
    }


    /***************************************************************************
    * saveDiagnosis */
   /**
    * Save new or update existing record
    *
    * @param  userID          User id of who is recording service
    * @param  userGroup       1 = Client, 2 = SBSC (from users db)
    * @param  userRank        Users role ranking
    * @param  clientID        Client id
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
  
    public static ReturnSaveRecord saveDiagnosis(  SqlConnection connSpedmon
                                         , DetailsLog    log
                                         , UserInfo      uInfo
                                         , string        clientID
										 , string        diagnosisName
                                         , string        diagnosisDescription
                                         , string        templateType
                                         , string        groupServiceClassNameID
                                         , string        editDelReason
                                         , string        validateRec
                                         , string        saveType
                                         , string        recID)
    {           
                       
      string saveSproc = @"DIAGNOSIS_TEMPLATES_SAVE";
      string dupRecMsg = @"Diagnosis already exists";

      /*###########################################################################
        # Validate parameters specific to this entity save and create their 
        # database parameters
        ###########################################################################*/

      Object   vClientID                 = Validate.optInteger  (clientID, Messages.INVALID_CLIENT_ID);
      Object   vTemplateType             = Validate.optInteger  (templateType, Messages.INVALID_NUMBER);
      Object   vGroupServiceClassNameID  = Validate.optInteger  (groupServiceClassNameID, Messages.INVALID_GROUP_FAMILY);
      string   vDiagnosisName            = Validate.reqString   (diagnosisName,        @"Invalid diagnosis name");
      string   vDiagnosisDescription     = Validate.reqString   (diagnosisDescription, @"Invalid diagnosis description");
                 
      List<SqlParameter> parms = new List<SqlParameter>();
  
      parms.Add(Database.SqlParm("@clientID",                 SqlDbType.BigInt,  vClientID,                 ParameterDirection.Input));
      parms.Add(Database.SqlParm("@templateType",             SqlDbType.BigInt,  vTemplateType,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@groupServiceClassNameID",  SqlDbType.BigInt,  vGroupServiceClassNameID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@diagnosisName",            SqlDbType.VarChar, vDiagnosisName,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@diagnosisDescription",     SqlDbType.VarChar, vDiagnosisDescription,     ParameterDirection.Input));
      
      /*###########################################################################
        # Call base method which handles the rest and returns the results
        ###########################################################################*/  

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms,null);
    }
    
    /***************************************************************************
     * view */
    /**
     *
     **************************************************************************/  
    
     public static ReturnDB view (   SqlConnection connSpedmon
                                  , DetailsLog    log
                                  , UserInfo      uInfo
                                  , int           recViewType
                                  , bool          pagedOrTop
                                  , string        idx
                                  , string        canEdit
                                  , string        active
                                  , string        clientID
                                  , string        groupServiceClassNameID
                                  , string        templateType
                                  , string        term
                                  , defineCols    dc )
    {
      
      string viewUDF = @"dbo.DIAGNOSIS_TEMPLATES_VIEW (@userID, @userGroup, @userRank, @clientID, @groupServiceClassNameID, @templateType, @term, @active, @recID)";
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
       
      Object vClientID                = Validate.optClientID                      (uInfo, clientID);
      Object vTerm                    = Validate.optString                        (term,        Messages.INVALID_SEARCH_TERM);
      Object vGroupServiceClassNameID = Validate.optInteger                       (groupServiceClassNameID,        Messages.INVALID_GROUP_FAMILY);
      Object vTemplateType            = Validate.reqInteger                       (templateType,                   Messages.INVALID_SEARCH_TERM);
      
      parms.Add(Database.SqlParm("@clientID",                  SqlDbType.BigInt,   vClientID,                 ParameterDirection.Input));
      parms.Add(Database.SqlParm("@groupServiceClassNameID",   SqlDbType.BigInt,   vGroupServiceClassNameID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@templateType",              SqlDbType.BigInt,   vTemplateType,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",                      SqlDbType.VarChar,  vTerm,                     ParameterDirection.Input, 256));
      
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
       
      return Entities.view (  connSpedmon
                            , log
                            , uInfo
                            , recViewType
                            , pagedOrTop
                            , idx
                            , canEdit
                            , active
                            , viewUDF
                            , ref parms
                            , null
                            , dc );    
    }
        
    public static ReturnDB viewPlan (   SqlConnection connSpedmon
                                  , DetailsLog    log
                                  , UserInfo      uInfo
                                  , int           recViewType
                                  , bool          pagedOrTop
                                  , string        idx
                                  , string        canEdit
                                  , string        clientID
                                  , string        planID
                                  , string        term
                                  , defineCols    dc )
    {
      
      string viewUDF = @"dbo.PLAN_WRITER_PLANS_DIAGNOSES_VIEW (@userID, @userGroup, @userRank, @clientID, @planID, @term, @recID)";
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
       
      Object vClientID            = Validate.optClientID                      (uInfo, clientID);
      Object vPlanID              = Validate.optInteger                       (planID,    Messages.INVALID_RECORD_ID);
      Object vTerm                = Validate.optString                        (term,        Messages.INVALID_SEARCH_TERM);
      
      parms.Add(Database.SqlParm("@clientID",             SqlDbType.BigInt,   vClientID,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@planID",               SqlDbType.BigInt,   vPlanID,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",                 SqlDbType.VarChar,  vTerm,                 ParameterDirection.Input, 256));
      
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
       
      return Entities.view (  connSpedmon
                            , log
                            , uInfo
                            , recViewType
                            , pagedOrTop
                            , idx
                            , canEdit
                            , "Y"
                            , viewUDF
                            , ref parms
                            , null
                            , dc );    
    }
    
    /***************************************************************************
     * viewSel */
    /**
     * Returns a data table of records for preview or record selection.
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnSel viewSel (   SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , bool          top
                                      , string        topSize
                                      , string        clientID                                      
                                      , string        recID  
                                      , string        groupServiceClassNameID
                                      , string        templateType
                                      , string        term
                                    )
    {

        /*----------------------------
         * Define our context column
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {         
          ss.addDisplayColumn("description as recData1");
        };

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        return Entities.viewSel(  connSpedmon
                                , log
                                , uInfo
                                , top
                                , topSize
                                , delegate { 
                                  return PlanWriterDiagnoses.view (  connSpedmon
                                                                                  , log
                                                                                  , uInfo
                                                                                  , Entities.REC_VIEW_SEL
                                                                                  , top
                                                                                  , topSize
                                                                                  , ""
                                                                                  , "Y"
                                                                                  , clientID
                                                                                  , groupServiceClassNameID
                                                                                  , templateType
                                                                                  , term
                                                                                  , dc ); 
                                  });
                                                                    
    }

    /***************************************************************************
     * viewTbl */
    /**
     * Returns a data table of records for preview or record selection.
     * 
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewTbl (  SqlConnection connSpedmon
                                           , DetailsLog    log
                                           , UserInfo      uInfo
                                           , bool          paged
                                           , string        pageNumber
                                           , string        clientID
                                           , string        templateType
                                           , string        canEdit
                                           , string        active )
   {
     ReturnDataTable so = new ReturnDataTable();
     
     /*###########################################################################
       # Define our display columns and set the page order.  Page order needs to
       # be in the same sort order as the udf called in the view.
       ###########################################################################*/  

     defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
     {       
       ss.addDisplayColumn("id");   
       ss.addDisplayColumn("NAME        as [Name]",  true);
       //ss.addDisplayColumn("DESCRIPTION as [Description]");
       pageroworder = ss.pageRowOrder();
     };

     /*###########################################################################
       # Call the base method which handles the rest and returns a ReturnDataTable
       ###########################################################################*/  

     so = Entities.viewTbl(  connSpedmon
                           , log
                           , uInfo
                           , paged
                           , pageNumber
                           , delegate { return
                             PlanWriterDiagnoses.view (  connSpedmon
                                                            , log
                                                            , uInfo
                                                            , Entities.REC_VIEW_TBL
                                                            , paged
                                                            , pageNumber
                                                            , canEdit
                                                            , active
                                                            , clientID
                                                            , null
                                                            , templateType
                                                            , ""
                                                            , dc); 
                            });
   
     /*###########################################################################
       # Add a title and footer to ReturnDataTable then return
       ###########################################################################*/  
               
     so.tableName   = SEL_LABEL;
     so.tableFooter = Messages.CONFIDENTIAL;
         
     return so;
     
    }

    /***************************************************************************
     * load */
    /**
     * Outputs data for a single record
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

    public static PlanWriterPlanDiagnosis loadPlanDiag(   SqlConnection connSpedmon
                                                           , DetailsLog    log
                                                           , UserInfo      uInfo
                                                           , string        clientID
                                                           , string        planID )
    {
      return (PlanWriterPlanDiagnosis) Entities.loadNRecord (   connSpedmon
                                                                , log
                                                                , uInfo
                                                                , 0
                                                                , typeof (PlanWriterPlanDiagnosis)
                                                                , delegate {          
                                                                  return PlanWriterDiagnoses.viewPlan (  connSpedmon
                                                                                                                  , log
                                                                                                                  , uInfo
                                                                                                                  , Entities.REC_VIEW_LOAD_N
                                                                                                                  , false
                                                                                                                  , ""
                                                                                                                  , ""
                                                                                                                  , clientID
                                                                                                                  , planID
                                                                                                                  , ""
                                                                                                                  , null );
                                                            });
    }

    /***************************************************************************
     * loadDiagnosis */
    /**
     * Loads single record
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing client specific data
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @return                 ReturnEntity
     ***************************************************************************/

    public static PlanWriterDiagnosis loadDiagnosis (  SqlConnection connSpedmon
                                                 , DetailsLog    log
                                                 , UserInfo      uInfo
                                                 , string        clientID
                                                 , string        templateType
                                                 , string        recID )
    {      
      return (PlanWriterDiagnosis) Entities.load(connSpedmon, log, uInfo, recID, typeof(PlanWriterDiagnosis),
      delegate { return PlanWriterDiagnoses.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", clientID, null, templateType, "", null); });
    }

    /***************************************************************************
    * delete */
   /*
    ***************************************************************************/
 
   public static ReturnSaveRecord delete(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                             string editDelReason, string validateRec, string recID)
    {
      /*----------------------------
       * Collect all of the parameters
       * that are specific to this
       * delete method.
       *----------------------------*/
 
          List<SqlParameter> parms = new List<SqlParameter>();
 
          /*----------------------------
           * Call base method
           *----------------------------*/
 
          return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "DIAGNOSIS_TEMPLATES_DELETE", ref parms);
    }


  }
}
