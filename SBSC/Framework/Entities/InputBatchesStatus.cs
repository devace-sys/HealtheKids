using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  
  public class InputBatchesStatus : Entities
  {
    public const string SEL_LABEL_RPT_BATCHES_ABOUT_TO_AGE_OUT = "List of Batches About To Age Out";
    public const string URL_RPT_BATCHES_ABOUT_TO_AGE_OUT = "rpt_batches_about_to_ageout.aspx";
    public const string SEL_LABEL_RPT_COUNT_OF_BATCHES_IN_PROCESS_BY_STATUS = "Count of Batches Currently in Process by Status";
    public const string URL_RPT_COUNT_OF_BATCHES_IN_PROCESS_BY_STATUS = "rpt_count_of_batches_in_process_by_status.aspx";
    public const string SEL_LABEL_RPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK = "Count Batches Ready to Assign by Type of Work";
    public const string URL_RPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK = "rpt_count_batches_ready_to_assign_by_type_of_work.aspx";
    public const string SEL_LABEL_RPT_BATCHES_NEEDING_PRIORITY_REVIEW = "List of Batches Needing Priority Review";
    public const string URL_RPT_BATCHES_NEEDING_PRIORITY_REVIEW = "rpt_batches_needing_priority_review.aspx";
    public const string SEL_LABEL_RPT_INPUT_STAFF_TRAINING_IN_PROCESS = "Input Staff Training in Process";
    public const string URL_RPT_INPUT_STAFF_TRAINING_IN_PROCESS = "rpt_input_staff_training_in_process.aspx";

    public const string URL_SVC_BASE = @"input_batches_status_codes.asmx";
    public const string URL_VIEW_SEL = URL_SVC_BASE + "/viewSelByCode";

    /***************************************************************************
     * URL_VIEW_SEL_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_VIEW_SEL_BASE()
    { 
       return MBA.HttpApplication.createLink(InputBatchesStatus.URL_VIEW_SEL, true);
    }

        /***************************************************************************
         * viewSel */
        /**
         * 
         ***************************************************************************/

        public static ReturnSel viewSel (   SqlConnection connUsers
                                                 , DetailsLog    log
                                                 , UserInfo      uInfo
                                                 , bool          top
                                                 , string        topSize                                                                                                  
                                                 , string        id
                                                 , string        statusCode
                                                 )
    {
        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> sqlp)
        {
            ss.addDisplayColumn("[name] as [context1]");
            ss.addDisplayColumn("[name] as recData2");
        };
        ReturnSel retval = Entities.viewSel(connUsers, log, uInfo, top, topSize, delegate { return InputBatchesStatus.view(connUsers, log, uInfo, Entities.REC_VIEW_SEL, top, topSize, id, statusCode, dc); });
        return retval;
    } 
    
    /***************************************************************************
     * view */
    /**
     *           
     * @return            ReturnDB
     ***************************************************************************/   

    public static ReturnDB view (   SqlConnection  connUsers
	                                , DetailsLog     log
								    , UserInfo       uInfo
								    , int            recViewType
                                    , bool           pagedOrTop
                                    , string         idx
                                    , string         id
                                    , string         statusCode
                                    , defineCols     dcparam   )
    {


      string viewUDF = "dbo.INPUT_BATCHES_STATUS_VIEW (@id, @statusCode)";
      List<SqlParameter> parms   = new List<SqlParameter>();

      /*----------------------------
       * Validate params specific
       * to this method and add to 
       * params list
       *----------------------------*/
     
      Object  vID          = Validate.optInteger   (id, "Invalid Input Batches Status identifier; try again");
      Object  vStatusCode  = Validate.optString    (statusCode,       "Invalid Status Code provided; try again");

            
      parms.Add(Database.SqlParm("@id",          SqlDbType.Int,  vID,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@statusCode",  SqlDbType.VarChar,  vStatusCode,   ParameterDirection.Input, 1000));

      ReturnDB retval = Entities.view(connUsers, log, uInfo, recViewType, pagedOrTop, idx, "false", null, viewUDF, ref parms, null, dcparam);


      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/
      

      return retval;
            
    }


    public static ReturnDataTable RPT_Batches_About_To_AGE_OUT(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                       bool   paged,
                                       string pageNumber,
                                       string clientID,
                                       string repID,
                                       string workType ) 
    {
        List<SqlParameter> prms = new List<SqlParameter>();

       
        Object vspEDCareClientID = Validate.optClientID(uInfo, clientID);
        Object vConsultantID = Validate.optInteger(repID, Messages.INVALID_REP_ID);
        Object vType_of_Work = Validate.optInteger(workType, Messages.INVALID_NUMBER);

        string reportUDF = "RPT_Batches_About_To_AGE_OUT (@clientID,@repID,@workType)";

        prms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vspEDCareClientID, ParameterDirection.Input));
        prms.Add(Database.SqlParm("@repID", SqlDbType.Int, vConsultantID, ParameterDirection.Input));
        prms.Add(Database.SqlParm("@workType", SqlDbType.Int, vType_of_Work, ParameterDirection.Input));
     


        /*----------------------------
         * Define our columns and
         * set the page order for
         * paging
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {

            //ss.addDisplayColumn("CLIENT_NAME as [Client Name]", true);
      
            //ss.addDisplayColumn("[CDS Code]");
            //ss.addDisplayColumn("Batch_ID as [Batch ID]");
            //ss.addDisplayColumn("[Section]");
            ss.addDisplayColumn("[Current Status Code]",true);
            ss.addDisplayColumn("[Current Status Description]");
            ss.addDisplayColumn("[Date Received]");
            ss.addDisplayColumn("[Oldest DOS]");
            ss.addDisplayColumn("[File Name]");
            ss.addDisplayColumn("[Type of Work]");
            ss.addDisplayColumn("[Practi-Cal Consultant]");
            ss.addDisplayColumn("[Last Assigned to]");
            ss.addDisplayColumn("[Status Date]");
           
            pageroworder = ss.pageRowOrder();
        };

        string tableFooter = Messages.CONFIDENTIAL;

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        //return Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, reportUDF, prms, null, dc
        //  , InputBatchesStatus.SEL_LABEL_RPT_BATCHES_ABOUT_TO_AGE_OUT
        //  , tableFooter
        //  );

        ReturnDataTable rd = Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, reportUDF, prms, null, dc
   , InputBatchesStatus.SEL_LABEL_RPT_BATCHES_ABOUT_TO_AGE_OUT
   , tableFooter
                                         );
        rd.useTemplates = true;
        rd.excelTemplate = new ExcelFileTempateInfo();
        rd.excelTemplate.templateFileName = @"TER05 Batches About to AGE OUT.xls";
        //rd.excelTemplate.postPopulationProcessing = true;
        rd.excelTemplate.forceFormulaRecalculate = true;
        rd.excelTemplate.collapseRowGroups = false;
        rd.excelTemplate.collapseColGroups = false;
        rd.excelTemplate.limitToPhysicalCells = false;

        rd.excelTemplate.setDataCellRegion( 2        /* Starting row*/
                                          , 199      /* Ending row*/
                                          , @"A"     /* Starting column */
                                          , @"I");   /* Ending column */

        return rd;
    }




          /* new method for the Report  "Count of Batches Currently in Process by Status"
       */


    public static ReturnDataTable RPT_Count_OfBatchesInProcessbyStatus(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                       bool paged,
                                       string pageNumber              )
    
    
    
    { 
        
        List<SqlParameter> prms = new List<SqlParameter>();

        /* We don't haveparameters coming in for this report.
             */


        string reportUDF = "RPT_CountOfBatchesInProcessbyStatus()";

                     
        /*----------------------------
         * Define our columns and
         * set the page order for
         * paging
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {

            ss.addDisplayColumn("[Status Code]", true);
            ss.addDisplayColumn("[Status Description]");
            ss.addDisplayColumn("[# of Batches]");
            ss.addDisplayColumn("[Oldest Date Received]");
            ss.addDisplayColumn("[Oldest DOS]");
            pageroworder = ss.pageRowOrder();
           
         };

        string tableFooter = Messages.CONFIDENTIAL;

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

   
        ReturnDataTable rd = Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, reportUDF, prms, null, dc
    , InputBatchesStatus.SEL_LABEL_RPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK
    , tableFooter
                                          );
        rd.useTemplates = true;
        rd.excelTemplate = new ExcelFileTempateInfo();
        rd.excelTemplate.templateFileName = @"TER01 Count of Batches Currently in Process by Status.xls";
        //rd.excelTemplate.postPopulationProcessing = true;
        rd.excelTemplate.forceFormulaRecalculate = true;
        rd.excelTemplate.collapseRowGroups = false;
        rd.excelTemplate.collapseColGroups = false;

        rd.excelTemplate.setDataCellRegion( 3        /* Starting row*/
                                          , 14       /* Ending row*/
                                          , @"A"     /* Starting column */
                                          , @"E");   /* Ending column */

        return rd;
 
    }

    /* new method for the Report  "Count Batches Ready to Assign by Type of Work"
  */


    public static ReturnDataTable RPT_CountBatchesReadyToAssignByTypeOfWork(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                       bool paged,
                                       string pageNumber)
    {

        List<SqlParameter> prms = new List<SqlParameter>();

        /* We don't have parameters coming in for this report.
             */


        string reportUDF = "RPT_CountBatchesReadyToAssignByTypeOfWork()";


        /*----------------------------
         * Define our columns and
         * set the page order for
         * paging
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {

            ss.addDisplayColumn("[Type of Work]", true);
            ss.addDisplayColumn("[# of Batches]");
            ss.addDisplayColumn("[Oldest Date Received]");
            ss.addDisplayColumn("[Oldest DOS]");
            ss.addDisplayColumn("[Batches in Past Year]");
            pageroworder = ss.pageRowOrder();

        };

        string tableFooter = Messages.CONFIDENTIAL;

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/


        ReturnDataTable rd = Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, reportUDF, prms, null, dc
        , InputBatchesStatus.SEL_LABEL_RPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK
        , tableFooter
                                              );
         rd.useTemplates = true;
         rd.excelTemplate = new ExcelFileTempateInfo();
         rd.excelTemplate.templateFileName  = @"TER02 Count Batches Ready to Assign by Type of Work.xls";         
         //rd.excelTemplate.postPopulationProcessing = true;
         rd.excelTemplate.forceFormulaRecalculate = true;
         rd.excelTemplate.collapseRowGroups = false;
         rd.excelTemplate.collapseColGroups = false;
         
         rd.excelTemplate.setDataCellRegion(3        /* Starting row*/
                                           ,19       /* Ending row*/
                                           ,@"A"     /* Starting column */
                                           ,@"E");   /* Ending column */

         return rd;
 

    }



    /* new method for the Report  "Batches Needing Priority Review"
*/

    public static ReturnDataTable RPT_BatchesNeedingPriorityReview(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                       bool paged,
                                       string pageNumber)
                                      // string repID,
                                       //string workType)
  
    {
        List<SqlParameter> prms = new List<SqlParameter>();

        /* We don't have parameters coming in for this report.
           */


        string reportUDF = "RPT_BatchesNeedingPriorityReview ()";

  

        /*----------------------------
         * Define our columns and
         * set the page order for
         * paging
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        
        {

            ss.addDisplayColumn("[Who put this here?]", true);
            ss.addDisplayColumn("[When?]");
            ss.addDisplayColumn("[File Name]");
            ss.addDisplayColumn("[Type of Work]", true);
            ss.addDisplayColumn("[Oldest DOS]");
            ss.addDisplayColumn("[Date Received]");
            ss.addDisplayColumn("[From Status Code]");
            ss.addDisplayColumn("[To Status Code]");
            ss.addDisplayColumn("[To Status Name]");
            //ss.addDisplayColumn("[Section]");
            ss.addDisplayColumn("[Current Status Code]");
            ss.addDisplayColumn("[Current Status Name]");
            ss.addDisplayColumn("[Notes]");
            ss.addDisplayColumn("[Parent Batch ID]");
            ss.addDisplayColumn("[Practi-Cal Consultant]", true);
            pageroworder = ss.pageRowOrder();
        };

        string tableFooter = Messages.CONFIDENTIAL;

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        //return Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, reportUDF, prms, null, dc
        //  , InputBatchesStatus.SEL_LABEL_RPT_BATCHES_NEEDING_PRIORITY_REVIEW
        //  , tableFooter
        //  );
    
             ReturnDataTable rd = Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, reportUDF, prms, null, dc
        , InputBatchesStatus.SEL_LABEL_RPT_BATCHES_NEEDING_PRIORITY_REVIEW
        , tableFooter
                                                   );
         rd.useTemplates = true;
         rd.excelTemplate = new ExcelFileTempateInfo();
         rd.excelTemplate.templateFileName = @"TER04-1 Batches Needing PRIORITY Review.xls";         
         //rd.excelTemplate.postPopulationProcessing = true;
         rd.excelTemplate.forceFormulaRecalculate = true;
         rd.excelTemplate.collapseRowGroups = false;
         rd.excelTemplate.collapseColGroups = false;
         rd.excelTemplate.limitToPhysicalCells = false;
         
         rd.excelTemplate.setDataCellRegion(2        /* Starting row*/
                                           ,199       /* Ending row*/
                                           ,@"A"     /* Starting column */
                                           ,@"N");   /* Ending column */

         return rd;
 

    }      
        /***************************************************************************
         * RPT_Input_Staff_Training_In_Process */
        /**
         *           
         * @returns ReturnDataTable       
         ***************************************************************************/
        public static ReturnDataTable RPT_Input_Staff_Training_In_Process (
             SqlConnection connSpedmon
            , DetailsLog log
            , UserInfo uInfo
            , bool paged
            , string pageNumber
            , string recUserID)

        {
            string reportUDF = "RPT_INPUT_STAFF_TRAINING_IN_PROCESS(@staffID)";

            Object vspEDCarestaffID = Validate.optInteger(recUserID, @"Invalid staff ID");

            List<SqlParameter> prms = new List<SqlParameter>();            
            prms.Add(Database.SqlParm("@staffID", SqlDbType.BigInt, vspEDCarestaffID, ParameterDirection.Input));
                                          
            /*----------------------------
             * Define our columns and
             * set the page order for
             * paging
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)

            {

                ss.addDisplayColumn("[Staff_Name]", true);
          
                ss.addDisplayColumn("Currently_training_on as[Currently training on]");
                ss.addDisplayColumn("[%_Trained]");
                ss.addDisplayColumn("[Skill_level]");
                ss.addDisplayColumn("Last_date_user_started_on_a_batch_of_this_type as[Last date\n user started\n on a batch\nof this type]");
                pageroworder = ss.pageRowOrder();
            };

            string tableFooter = Messages.CONFIDENTIAL;

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

          
            ReturnDataTable rd = Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber, null, reportUDF, prms, null, dc
                                                  , InputBatchesStatus.SEL_LABEL_RPT_INPUT_STAFF_TRAINING_IN_PROCESS
                                                  , tableFooter
                                                  );

            rd.useTemplates  = true;
            rd.excelTemplate = new ExcelFileTempateInfo();

            rd.excelTemplate.templateFileName        = @"TER06-0 Input Staff Training in Process.xls";
            rd.excelTemplate.forceFormulaRecalculate = true;
            rd.excelTemplate.collapseRowGroups       = false;
            rd.excelTemplate.collapseColGroups       = false;
            rd.excelTemplate.limitToPhysicalCells    = false;

            rd.excelTemplate.setDataCellRegion( 2        /* Starting row*/
                                              , 978      /* Ending row*/
                                              , @"A"     /* Starting column */
                                              , @"E");   /* Ending column */

            return rd;

        }
    }



    }




 
