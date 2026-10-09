using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * Site */
    /**
     * 
     ***************************************************************************/
    public class Site : MBA.Entity
    {
        public const string DEFAULT_PAGING_ORDER = "clientName asc, name asc"; 

        public int    clientID;
        public string cds7;
        public string clientName;
        public string clientCds;
        public string address1;
        public string address2;
        public string city;
        public string state;
        public string zip5;
        public string zip4;
        public string phoneNumber;
        public string clientProvidedSiteUID;
        public string AddressLine; /* Entire address on a single line */
        public bool   attemptFuzzyMatchByNameAndCode;
        public string attemptFuzzyMatchByNameAndCodeStr;
        public string activeStr;
        public bool cybhiTpaApproved;
        public string cybhiTpaApprovedStr;
        public DateTime? cybhiTpaApprovedOn;
        public string cybhiTpaApprovedOnStr;
        public string cybhiTpaApprovedOnStrYMD;
    }

    /***************************************************************************
     * Sites */
    /**
     * Methods to manage sites (schools)
     ***************************************************************************/

    public class Sites : Entities
    {
        public const string SEL_LABEL_MANAGE       = "Manage Sites";
        public const string SEL_LABEL              = "Sites";
        public const string SEL_LABEL_ADD          = "Record New";
        public const string SEL_LABEL_VIEW         = "View Sites";
        public const string SEL_LABEL_EDIT_DELETE  = "Edit or Delete Sites";
        public const string SEL_LABEL_EDIT         = "Edit";
        public const string SEL_LABEL_SAVE         = "Record New Site";
        public const string URL_SAVE               = "user_all_sites_save.aspx";
        public const string MENU_ID_SAVE           = "addsitelink";

        public const string URL_SVC_BASE                 = @"sites.asmx";
        public const string URL_SVC_VIEW_SEL_BASE        = URL_SVC_BASE + @"/viewSel";
        public const string URL_SVC_DELETE_INLINE_BASE   = URL_SVC_BASE + @"/deleteinline";
        public const string URL_SVC_UNDELETE_INLINE_BASE = URL_SVC_BASE + @"/undeleteinline";

        public const string URL_REST_VIEW_BASE    = @"api/v1/sites";
        public const string URL_MANAGE            = @"user_all_sites_manage.aspx";
        public const string MENU_ID_MANAGE        = @"managesiteslnk";
        public const string URL_WEB_REPORT_BASE   = @"sites.ashx";
        public const string MENU_ID_VIEW          = @"viewsitelink";
        public const string MENU_ID_EDIT_DEL      = @"editdelsiteslink";

       /***************************************************************************
        * URL_REST_VIEW_SEL_INLINE */
       /**
        * 
        **************************************************************************/ 
        public static string URL_REST_VIEW_SEL_INLINE()
        {
          return MBA.HttpApplication.createLink(Sites.URL_SVC_VIEW_SEL_BASE, true);
        }

       /***************************************************************************
        * URL_REST_VIEW */
       /**
        * 
        **************************************************************************/ 
        public static string URL_REST_VIEW()
        {
          return MBA.HttpApplication.createLink(Sites.URL_REST_VIEW_BASE, true);
        }

       /***************************************************************************
         * URL_WEB_REPORT */
       /**
        * 
        **************************************************************************/  
       public static string URL_WEB_REPORT()
       { 
         return MBA.HttpApplication.createLink(Sites.URL_WEB_REPORT_BASE, true);
       }


    /***************************************************************************
     * URL_ADD_NEW */
    /**
     * 
     **************************************************************************/
    public static string URL_ADD_NEW ()
    {
      return MBA.HttpApplication.createLink(  Sites.URL_SAVE
                                            , true
                                            , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                            , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW)                                            
                                            );
    }

      /***************************************************************************
       * URL_EDIT */
      /**
       * 
       **************************************************************************/  
     public static string URL_EDIT()
     {
       return MBA.HttpApplication.createLink ( Sites.URL_SAVE
                                               , true
                                               , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                               , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT)
                                               , new NameValue(Constants.PARM_REC_ID, @"")
                                             );
     }
     
    /***************************************************************************
     * URL_DELETE_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_DELETE_INLINE()
    {
      return MBA.HttpApplication.createLink( Sites.URL_SVC_DELETE_INLINE_BASE
                                            , true
                                           );
    }
    
    /***************************************************************************
     * URL_UNDELETE_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_UNDELETE_INLINE()
    {
      return MBA.HttpApplication.createLink( Sites.URL_SVC_UNDELETE_INLINE_BASE
                                            , true
                                           );
    }
    /***************************************************************************
     * URL_SVC_VIEW_SEL */
    /**
     * 
     **************************************************************************/  
    public static string URL_SVC_VIEW_SEL ()
    {
      return MBA.HttpApplication.createLink( Sites.URL_SVC_VIEW_SEL_BASE
                                            , true
                                           );
    }
        /***************************************************************************
         * viewSel */
        /**
         * Outputs a list of sites for selection display.
         * Selection lists contain the following columns
         *   label: Selection to display to the user
         *   value: Value that is used to compare search term with in client-side searches
         *   id:    Database record id
         * 
         * @param  connSpedmon     Spedmon database connection object
         * @param  log             Logging object
         * @param  clientID        Client id
         * @param  name            All or part of clients name
         * @return                 ReturnSel
         ***************************************************************************/
                
        public static ReturnSel viewSel (  SqlConnection connSpedmon
                                         , DetailsLog    log
                                         , UserInfo      uInfo
                                         , bool          top
                                         , string        topSize
                                         , string        clientID
                                         , string        name
                                        )
        {

          defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {
              ss.addDisplayColumn("AddressLine as context1");                           
              ss.addDisplayColumn("AddressLine as recData1");
              ss.addDisplayColumn("placeID      as recData2");
              
              ss.addSortColumn("name");              
          };
      
      
          return Entities.viewSel(  connSpedmon
                                  , log
                                  , uInfo
                                  , top
                                  , topSize
                                  , delegate {
                                      return Sites.view (  connSpedmon
                                                         , log
                                                         , uInfo
                                                         , Entities.REC_VIEW_SEL
                                                         , top
                                                         , topSize
                                                         , ""
                                                         , "1"
                                                         , clientID
                                                         , name
                                                         , dc);});
    
            
        }

        /***************************************************************************
         * save */
        /**
         ***************************************************************************/
        
        public static ReturnSaveRecord save(
            SqlConnection connSpedmon
          , DetailsLog log
          , UserInfo uInfo
          , string clientID
          , string cds7
          , string name
          , string address1
          , string address2
          , string city
          , string state
          , string zip5
          , string zip4
          , string phoneNumber
          , string client_provided_site_uid
          , string cybhiTpaApproved
          , string cybhiTpaApprovedOn
          , string editDelReason
          , string validateRec
          , string saveType
          , string recid)
        {
            List<SqlParameter> parms = new List<SqlParameter>();

            string sitesSaveSproc = "SITES_Save";

            long vClientID          = Validate.reqClientID(uInfo, clientID);
            string vCds             = Validate.reqString(cds7, "Invalid CDS Code");
            string vSchoolName      = Validate.reqString(name, "Invalid Site Name");
            string vAddress1        = Validate.optString(address1);
            string vAddress2        = Validate.optString(address2);
            string vCity            = Validate.optString(city);
            string vState           = Validate.optString(state);
            var    vZip5            = Validate.optZip5(zip5, "Please enter a valid 5 digit zip code");
            var    vZip4            = Validate.optZip4(zip4, "Please enter a valid 4 digit zip code extension");
            var    vPhoneNumber     = Validate.optPhoneNumber(phoneNumber,@"Invalid phone number");
            string vclient_site_uid = Validate.optString(client_provided_site_uid);
            Object vCybhiTpaApproved = Validate.reqFlag(cybhiTpaApproved, @"Invalid CYBHI TPA Approved flag", true);
            var vCybhiTpaApprovedOn = Validate.optDate(cybhiTpaApprovedOn, @"Invalid CYBHI TPA Approved On date");

            bool vAttemptFuzzyMatchByNameAndCode = false;
           
            parms.Add(Database.SqlParm("@SITE_CLIENT_ID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@SITE_NAME", SqlDbType.VarChar, vSchoolName, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@SITE_CDS", SqlDbType.NChar, vCds, ParameterDirection.Input, 7));
            parms.Add(Database.SqlParm("@ADDRESS_1", SqlDbType.NVarChar, vAddress1, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@ADDRESS_2", SqlDbType.NVarChar, vAddress2, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@CITY", SqlDbType.NVarChar, vCity, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@STATE", SqlDbType.NVarChar, vState, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@ZIP", SqlDbType.NVarChar, vZip5, ParameterDirection.Input, 5));
            parms.Add(Database.SqlParm("@ZIP4", SqlDbType.NVarChar, vZip4, ParameterDirection.Input, 4));
            parms.Add(Database.SqlParm("@PHONE_NUMBER", SqlDbType.VarChar, vPhoneNumber, ParameterDirection.Input, 50));            
            parms.Add(Database.SqlParm("@client_provided_site_uid", SqlDbType.NVarChar, vclient_site_uid, ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@cybhiTpaApproved", SqlDbType.Bit, vCybhiTpaApproved, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@cybhiTpaApprovedOn", SqlDbType.Date, vCybhiTpaApprovedOn, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@attemptFuzzyMatchByNameAndCode", SqlDbType.Bit, vAttemptFuzzyMatchByNameAndCode, ParameterDirection.Input));
            
            ReturnSaveRecordWithRecordData so = Entities.saveAndReturnRecordData(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recid, sitesSaveSproc, Messages.MISSING_SPROC_SAVE, ref parms, delegate() { });
            
            /* Refresh trip calculations (if neccessary) */
            
            TransportationMgmtTripCalculations.refreshAllTripCalcsWithPlaceID (connSpedmon, log, uInfo, so.recData1);
            
            return so;

        }

        public static ReturnSaveRecord delete (
              SqlConnection connSpedmon
            , DetailsLog    log
            , UserInfo      uInfo
            , string        editDelReason
            , string        validateRec
            , string        recID )
        {

           Object vClientID = Validate.optClientID (uInfo, @"");

            /*----------------------------
             * Check for required and 
             * optional parameters
             * and validate data integrity
             * of all supplied parameters
             *----------------------------*/

            //    /*----------------------------
            //     * Collect all of the parameters
            //     * that are specific to this
            //     * delete method.
            //     *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

            string sitesDeleteSproc = "SITES_Site_Delete";
                        
            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, sitesDeleteSproc, ref parms);

        }


        public static ReturnSaveRecord unDelete(
            SqlConnection connSpedmon
          , DetailsLog log
          , UserInfo   uInfo
          , string     editDelReason
          , string     validateRec
          , string     recID)
        {

            /*----------------------------
             * Check for required and 
             * optional parameters
             * and validate data integrity
             * of all supplied parameters
             *----------------------------*/

            Object vClientID = Validate.optClientID(uInfo,@"");
        

            /*----------------------------
             * Collect all of the parameters
             * that are specific to this
             * delete method.
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();
        
            string sitesUnDeleteSproc = "SITES_UnDelete";

            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
                 

            /*----------------------------
             * Call base method 
             *----------------------------*/

            return Entities.unDelete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, sitesUnDeleteSproc, ref parms);
        }
        /***************************************************************************
         * load */
        /**
         * Note: This calls the view method and the view method takes care of
         * enforcing the client id.
         * @param  connSpedmon     Spedmon database connection object
         * @param  log             Logging object
         * @param  clientID        Client ID
         * @return                 ReturnEntity
         ***************************************************************************/

        public static Site load(
                                SqlConnection connSpedmon
                              , DetailsLog log
                              , UserInfo   uInfo
                              , string     recID)
        {
            return (Site)Entities.load(connSpedmon, log, uInfo, recID, typeof(Site),
            delegate { return Sites.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", "", "", null); });
        }

        /***************************************************************************
         * view */
        /**
         * @param  clientID    Client ID record (if any)
         * @return             ReturnDB
         ***************************************************************************/
        
        public static ReturnDB view (
                                SqlConnection connSpedmon
                              , DetailsLog log
                              , UserInfo uInfo
                              , int recViewType
                              , bool pagedOrTop
                              , string idx
                              , string canEdit
                              , string active
                              , string clientID
                              , string name
                              , defineCols dc)
        {

            /*-------------------------------
             * Validate required and 
             * optional parameters
             *------------------------------*/
            
            Object vClientID = Validate.optClientID(uInfo, clientID);
            Object vName = Validate.optString(name);
            
            //Object vAddress = Validate.optString(address1);
            
            /*-------------------------------
             * Setup database command
             *------------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();

            string viewUDF = "SITES_VIEW(@userID,@userGroup,@userRank,@clientID, @name, @canEdit, @active, @recid)";


            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@name", SqlDbType.VarChar, vName, ParameterDirection.Input, 50));

            /*-------------------------------
            * Execute database command
            * and return results in our
            * intermediate structure
            *------------------------------*/

            ReturnDB rd = Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

            return rd;

        }

        // CYBHI_SITE_LIST_AUDIT_RPT(@clientID)
        
        /***************************************************************************
       * viewTbl */
        /**
         * View users record data table
         * 
         * @param  clientID    Client ID record (if any)
         * @return             ReturnDataTable
         ***************************************************************************/


        public static ReturnDataTable viewTbl (
                                                 SqlConnection connSpedmon
                                               , DetailsLog    log
                                               , UserInfo      uInfo
                                               , bool          paged
                                               , string        pageNumber
                                               , string        clientID
                                               , string        name
                                               , string        canEdit
                                               , string        active )
        {
            defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {
                
                ss.addDisplayColumn ("id");
                ss.addDisplayColumnIfParmValueIsNull ("clientName as [Client Name]", "@clientID", true, ref parms);
                ss.addDisplayColumn ("name as [Site Name]", true);
                ss.addDisplayColumn ("activeStr as [Active]");
                ss.addDisplayColumnIfParmValueIsNull ("clientCds as [Client CDS]", "@clientID", ref parms);
                ss.addDisplayColumn ("cds7 as [Site CDS]");
                ss.addDisplayColumn ("AddressLine as [Address]");
                ss.addDisplayColumn ("phoneNumber as [Phone Number]");                
                ss.addDisplayColumn ("cybhiTpaApprovedStr as [CYBHI TPA Approved]");
                ss.addDisplayColumn ("cybhiTpaApprovedOnStr as [CYBHI TPA Approved On]");
                ss.addDisplayColumn ("id as [SpEdCare Record ID]");
                pageroworder = ss.pageRowOrder(); 
            };

            return Entities.viewTbl(connSpedmon
                                     , log
                                     , uInfo
                                     , paged
                                     , pageNumber
                                     , delegate {
                                         return Sites.view(connSpedmon
                                                            , log
                                                            , uInfo
                                                            , Entities.REC_VIEW_TBL
                                                            , paged
                                                            , pageNumber
                                                            , canEdit
                                                            , active
                                                            , clientID
                                                            , name
                                                            , dc); 
                                     }
                                     , "Sites"
                                     , Messages.CONFIDENTIAL);

            

        }

  /***************************************************************************
   * viewObjects */
  /**
   ***************************************************************************/
  public static ReturnObjects viewObjects (   SqlConnection  connSpedmon
                                             , DetailsLog    log
                                             , UserInfo      uInfo
                                             , bool          pageObjectList
                                             , string        pageOrder
                                             , string        idx
                                             , string        active
                                             , string        clientID
                                             , string        term )
    {
        /* Default page order */

        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = Site.DEFAULT_PAGING_ORDER;

        /* Define columns delegate is used to specify columns and page order 
         * We pass in the desired page row order here */

        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
          pageroworder = pageOrder;
        };

        var rd = Entities.viewObjects( connSpedmon
                                      , log
                                      , uInfo
                                      , typeof(Site)
                                      , pageObjectList
                                      , pageOrder
                                      , delegate {
                                         return Sites.view (  connSpedmon
                                                          , log
                                                          , uInfo
                                                          , Entities.REC_VIEW_OBJECTS
                                                          , pageObjectList
                                                          , idx
                                                          , "" /* Can Edit */
                                                          , active
                                                          , clientID
                                                          , term
                                                          , dc);
                                     });
            
        return rd;
      }
      
     /***************************************************************************
      * rptCybhiPracsAudit */
     /**
      * Returns a list of sites that CYBHI services have been rendered at
      * and returns additional information on data that is missing.
      * Missing data is determine by a combination of the 837P and TPA SPI roster specs
      *
      * @return ReturnDataTable
      ***************************************************************************/    
     public static ReturnDataTable rptCybhiSitesAudit (  SqlConnection connSpedmon
                                                          , DetailsLog    log
                                                          , UserInfo      uInfo
                                                          , bool          paged
                                                          , string        pageNumber
                                                          , string        clientID )
    {
      ReturnDataTable so = new ReturnDataTable();

      var vClientID = Validate.reqClientID(uInfo,clientID);
      var clc       = Clients.load(connSpedmon,log,uInfo,clientID);
      var parms     = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

      string udf = @"dbo.CYBHI_SITE_LIST_AUDIT_RPT(@clientID)";

      string viewTitle = clc.name
                       + " CYBHI Sites Audit " 
                       +  DateTime.Today.ToYYYYMMDDString();

      so = viewRpt (connSpedmon,log,uInfo,paged, pageNumber, "Y", udf, parms, null, null,viewTitle,Messages.DATA_VIEW_NO_FOOTER);

      return so;
    }                          
  }    
}

