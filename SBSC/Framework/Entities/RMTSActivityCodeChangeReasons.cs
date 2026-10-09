using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using MBA;
 
namespace Spedmon
{

  /***************************************************************************
   * RMTSActivityCodeChangeReason */
  /**
   * 
   **************************************************************************/
  public class RMTSActivityCodeChangeReason : Entity
  {
      public const string DEFAULT_PAGING_ORDER = @"rmtsCodeValue asc";
      public string rmtsCodeValue;
   }
  
  /***************************************************************************
   * RMTSActivityCodeChangeReasons */
  /**
   * 
   **************************************************************************/

  public class RMTSActivityCodeChangeReasons : Entities
  {
    public const string SEL_LABEL                   = @"Rmts Activity Code Change Reasons";
    public const string URL_SERVICE_BASE            = @"rmts_activity_code_change_reasons.asmx";
    public const string URL_REST_SAVE_INLINE_BASE   = URL_SERVICE_BASE + @"/saveinline";
    public const string URL_REST_DELETE_INLINE_BASE = URL_SERVICE_BASE + @"/deleteinline";
    public const string URL_VIEW_SEL                = URL_SERVICE_BASE + @"/viewSel";
    public const string URL_REST_VIEW_BASE          = @"api/v1/rmtsactivitycodechangereasons";
    public const string URL_WEB_REPORT_BASE         = @"rmts_activity_code_change_reasons.ashx";
    public const string MENU_ID_MANAGE              = @"rmtsactivitycodechangereasonsmanagelnk";
    public const string SEL_LABEL_MANAGE            = @"Manage RMTS Activity Code Change Reasons";
    public const string URL_PAGE_MANAGE_USER_ALL    = @"user_all_manage_rmts_activity_code_change_reasons.aspx";

    /***************************************************************************
     * URL_REST_SAVE_INLINE */
    /**
     * 
     **************************************************************************/

    public static string URL_REST_SAVE_INLINE()
    {
      return MBA.HttpApplication.createLink(RMTSActivityCodeChangeReasons.URL_REST_SAVE_INLINE_BASE, true);
    }

    /***************************************************************************
     * URL_REST_DELETE_INLINE */
    /**
     * 
     **************************************************************************/ 

    public static string URL_REST_DELETE_INLINE()
    {
        return MBA.HttpApplication.createLink(RMTSActivityCodeChangeReasons.URL_REST_DELETE_INLINE_BASE, true);
    }

    /***************************************************************************
     * URL_REST_VIEW */
    /**
     * 
     **************************************************************************/  
    public static string URL_REST_VIEW()
    { 
       return MBA.HttpApplication.createLink(RMTSActivityCodeChangeReasons.URL_REST_VIEW_BASE, true);
    }
 
    /***************************************************************************
     * URL_REPORT */
    /**
     * 
     **************************************************************************/  
    public static string URL_WEB_REPORT()
    { 
       return MBA.HttpApplication.createLink(RMTSActivityCodeChangeReasons.URL_WEB_REPORT_BASE, true);
    }
 
    /***************************************************************************
     * view */
    /**
     * Returns ReturnDB.  Base method use for other views.
     **************************************************************************/

    public static ReturnDB view (  SqlConnection connSpedmon
                                 , DetailsLog    log
                                 , UserInfo      uInfo
                                 , int           recViewType
                                 , bool          pagedOrTop
                                 , string        idx
                                 , string        canEdit
                                 , string        active
                                 , string        rmtsCodeValue
                                 , string        term 
                                 , defineCols    dc)
    {
                  
      var viewUDF = "RMTS_ACTIVITY_CODE_CHANGE_REASONS_VIEW(@userID, @userGroup, @userRank, @rmtsCodeValue, @term, @recID, @canEdit, @active)";
      var parms   = new List<SqlParameter>();

            /*----------------------------
             * Validate parameters specific
             * to this entity.view that 
             * will be used in all cases
             *----------------------------*/
      
      string vRmtsCodeValue = Validate.optString(rmtsCodeValue, "RMTS Code is required");
      Object vTerm          = Validate.optString(term);

            /*----------------------------
             * Populate database parameters
             *----------------------------*/

      parms.Add(Database.SqlParm("@rmtsCodeValue",  SqlDbType.VarChar  , vRmtsCodeValue,   ParameterDirection.Input, 10));
      parms.Add(Database.SqlParm("@term",      SqlDbType.VarChar , vTerm,       ParameterDirection.Input, 50));
      
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
        
      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);
    }

    /***************************************************************************
     * viewList */
    /**
     * Returns list * 
     ***************************************************************************/

    public static List<RMTSActivityCodeChangeReason> viewList (  SqlConnection connSpedmon
                                                               , DetailsLog    log
                                                               , UserInfo      uInfo
                                                               , string        rmtsCodeValue )
    {
            var recs = new List<RMTSActivityCodeChangeReason>();

            bool hasRecords = false;

            Object[] records = loadAllRecords(connSpedmon
                                            , log
                                            , uInfo
                                            , typeof(RMTSActivityCodeChangeReason)
                                            , delegate {
                                                return RMTSActivityCodeChangeReasons.view(
                                                          connSpedmon
                                                        , log
                                                        , uInfo
                                                        , Entities.REC_VIEW_ALL
                                                        , false
                                                        , ""
                                                        , ""
                                                        , "1"
                                                        , rmtsCodeValue
                                                        , ""
                                                        , null
                                                     );
                                            }
                                           , out hasRecords);

            if (hasRecords == true)
            {
                foreach (Object rec in records)
                {
                    RMTSActivityCodeChangeReason recItem = (RMTSActivityCodeChangeReason)rec;
                    recs.Add(recItem);
                }
            }

            return recs;

   }

        /***************************************************************************
          * generateDataListHTMLForActivityCode */
        /**
         * Returns string containing datalist markupl * 
         ***************************************************************************/

        public static string generateDataListHTMLForActivityCode (  SqlConnection connSpedmon
                                                                    , DetailsLog log
                                                                    , UserInfo uInfo
                                                                    , string dataListID
                                                                    , string rmtsCodeValue)
        {
            var activityCodes = RMTSActivityCodeChangeReasons.viewList(connSpedmon, log, uInfo, rmtsCodeValue);
            var sb = new StringBuilder();
            sb.AppendFormat(@"<datalist id=""{0}"">", dataListID);
            foreach(var activityCode in activityCodes)
            {
                sb.AppendFormat(@"<option data-for-rmts-code=""{0}"" value=""{1}"">{1}</option>", activityCode.rmtsCodeValue, activityCode.name);
            }
            sb.Append(@"</datalist>");
            return sb.ToString();
        }


        /***************************************************************************
          * viewSel */
        /**
         * Returns ReturnSel * 
         ***************************************************************************/
        public static ReturnSel viewSel(    SqlConnection connSpedmon
                                       , DetailsLog log
                                       , UserInfo uInfo
                                       , bool top
                                       , string topSize
                                       , string rmtsCodeValue
                                       , string term)
     {

       /*###########################################################################
         # Define context columns
         ###########################################################################*/

        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {


        };

        /*###########################################################################
          # Call the base method which handles the rest and return
          ###########################################################################*/

         return Entities.viewSel( connSpedmon
                                 , log
                                 , uInfo
                                 , top
                                 , topSize
                                 , delegate {
                                        
                                   return RMTSActivityCodeChangeReasons.view(connSpedmon
                                           , log
                                           , uInfo
                                           , Entities.REC_VIEW_SEL
                                           , top
                                           , topSize
                                           , ""
                                           , "1"
                                           , rmtsCodeValue
                                           , term
                                           , dc);
                                    });
        }

        /***************************************************************************
          * viewTbl */
        /**
         * Returns a data table of records for preview or record selection.
         *
         * @return                 ReturnDataTable
         ***************************************************************************/

        public static ReturnDataTable viewTbl(  SqlConnection connSpedmon
                                               , DetailsLog log
                                               , UserInfo uInfo
                                               , bool paged
                                               , string pageNumber
                                               , string canEdit
                                               , string active
                                               , string rmtsCodeValue)
      {
        ReturnDataTable so = new ReturnDataTable();

        /*----------------------------
         * Define our columns and
         * set the page order for
         * paging
         *----------------------------*/

         defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
         {
             ss.addDisplayColumn("rmtsCodeValue     as [Activity\nCode]", true);
             ss.addDisplayColumn("name              as [Reason]", true);
             pageroworder = ss.pageRowOrder();
         };

         /*----------------------------
          * Call base method which
          * handles the rest
          *----------------------------*/

          so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
              delegate {
                  return RMTSActivityCodeChangeReasons.view(connSpedmon
                                           , log
                                           , uInfo
                                           , Entities.REC_VIEW_TBL
                                           , paged
                                           , pageNumber
                                           , canEdit
                                           , active
                                           , rmtsCodeValue
                                           , ""                                           
                                           , dc);
              });

            /*----------------------------
             * Add a title and footer
             *----------------------------*/

            so.tableName   = SEL_LABEL;
            so.tableFooter = Messages.CONFIDENTIAL;

            /*----------------------------
             * Done
             *----------------------------*/

            return so;
    }
 
    /***************************************************************************
     * viewObjects 
     *
     * Returns a list of objects
     * 
     ***************************************************************************/

    public static ReturnObjects viewObjects ( SqlConnection connSpedmon
                                             , DetailsLog log
                                             , UserInfo uInfo
                                             , bool pageObjectList
                                             , string pageOrder
                                             , string idx
                                             , string active
                                             , string rmtsCodeValue)
 
    {
 
        /* Default page order */
 
        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = RMTSActivityCodeChangeReason.DEFAULT_PAGING_ORDER;
 
        /* Define columns delegate is used to specify columns and page order 
         * We pass in the desired page row order here */
 
        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            pageroworder = pageOrder;
        };
 
        return Entities.viewObjects (   connSpedmon
                                      , log
                                      , uInfo
                                      , typeof(RMTSActivityCodeChangeReason)
                                      , pageObjectList
                                      , pageOrder
                                      , delegate {
                                          return RMTSActivityCodeChangeReasons.view (   connSpedmon
                                                                      , log
                                                                      , uInfo
                                                                      , Entities.REC_VIEW_OBJECTS
                                                                      , pageObjectList
                                                                      , idx
                                                                      , "" /* Can edit */
                                                                      , active
                                                                      , rmtsCodeValue
                                                                      , null
                                                                      , dc);
                                      });
 
 
    }
 
    /***************************************************************************
     * delete */
    /**
     * "Deletes" record
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    public static ReturnSaveRecord delete (  SqlConnection   connSpedmon
                                           , DetailsLog      log
                                           , UserInfo        uInfo
                                           , string          editDelReason
                                           , string          validateRec                                           
                                           , string          recID )
    {           
                
      var deleteSproc = @"dbo.RMTS_ACTIVITY_CODE_CHANGE_REASON_DELETE";
    
      /*###########################################################################
        # Validate parameters specific to this entity delete and create their 
        # database parameters.
        ###########################################################################*/  
      
      var parms = new List<SqlParameter>();
     
      /*###########################################################################
        # Call base method which handles the rest and returns the results
        ###########################################################################*/  

      return Entities.delete(connSpedmon,log,uInfo,editDelReason,validateRec,recID,deleteSproc,ref parms);

    }

    /***************************************************************************
     * save 
     *
     * Returns ReturnSaveRecord
     * 
     ***************************************************************************/

    public static ReturnSaveRecord save (  SqlConnection connSpedmon
                                         , DetailsLog    log
                                         , UserInfo      uInfo
                                         , string        rmtsCodeValue
                                         , string        name         
                                         , string        description
                                         , string        editDelReason
                                         , string        validateRec
                                         , string        saveType
                                         , string        recID )
    {

        var saveSproc = @"RMTS_ACTIVITY_CODE_CHANGE_REASON_SAVE";
        
        string vRmtsCodeValue  = Validate.reqString (rmtsCodeValue,  @"RMTS Code is required");
        string vName           = Validate.reqString (name,           @"Reason is required");
        string vDescription   = Validate.optString  (description,    @"Description is required");

        var parms = new List<SqlParameter>();
 
        parms.Add(Database.SqlParm("@rmtsCodeValue",  SqlDbType.VarChar,  vRmtsCodeValue,  ParameterDirection.Input, 10));
        parms.Add(Database.SqlParm("@name",           SqlDbType.VarChar,  vName,           ParameterDirection.Input, 512));
        parms.Add(Database.SqlParm("@description",     SqlDbType.VarChar, vDescription,    ParameterDirection.Input, -1));

        return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, @"This RMTS code and reason already exists", ref parms, null);
    }
  }
}