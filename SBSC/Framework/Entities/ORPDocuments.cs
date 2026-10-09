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
   * ORPDocument */
  /**
   * 
   **************************************************************************/

  public class ORPDocument: Entity
  {
  }
          
  /***************************************************************************
   * ORPDocuments */
  /**
   * 
   **************************************************************************/

  public class ORPDocuments:Entities
  {          

    public const string SEL_LABEL                            = @"ORP Documents";    
    public const string SEL_LABEL_VIEW                       = @"View";
    public const string SEL_LABEL_RPT                        = SEL_LABEL + " - " + SEL_LABEL_VIEW;    


    public const string SEL_LABEL_CURRENT_EXP                = "Orders and Prescriptions - Current and Expiring Soon"; 

    public const string URL_SBS_VIEW                         = @"sbs_all_orp_documents_view.aspx";
    
    public const string URL_EXPORT_DATA_BASE                 = @"orp_documents.ashx";
    
    public const string URL_REST_VIEW_BASE                      = @"api/v1/orpdocumentsordersandprofiles";
    public const string URL_SERVICE_BASE                        = @"orp_documents.asmx";
    public const string URL_USER_ALL_MANAGE                     = @"user_all_orders_prescriptions_manage.aspx";
    public const string URL_USER_ALL_SAVE_BASE                  = @"user_all_order_prescription_save.aspx";
    public const string URL_USER_ALL_DELETE_BASE                = URL_SERVICE_BASE + @"/delete";
    public const string URL_VIEW_SEL_ONLY_ORDERS_PROFILES_BASE  = URL_SERVICE_BASE + @"/viewSelOnlyOrdersAndProfiles";
    public const string URL_VIEW_SEL_PAT_ORDERS_FOR_DOS_BASE    = URL_SERVICE_BASE + "/viewSelPatOrdersForDos";

    public const string DEFAULT_PAGING_ORDER_ORDERS_PROFILES    = @"patName asc";

    public const string URL_SERVICE_VIEW_SEL_ORDS_PROF_FOR_CLT_GRP_PAT_SVC = 
              URL_SERVICE_BASE 
            + @"/viewselordersandprofilesforclientgroupSvcclasspatsvc";

    /***************************************************************************
     * URL_VIEW_SEL_PAT_ORDERS_FOR_DOS */
    /**
     * 
     **************************************************************************/  

    public static string URL_VIEW_SEL_PAT_ORDERS_FOR_DOS()
    {
       return MBA.HttpApplication.createLink(ORPDocuments.URL_VIEW_SEL_PAT_ORDERS_FOR_DOS_BASE, true);     
    }

    /***************************************************************************
     * URL_REST_VIEW_ORP_DOCS_ORDERS_AND_PROFILES */
    /**
     * 
     **************************************************************************/  
    public static string URL_REST_VIEW_ORP_DOCS_ORDERS_AND_PROFILES()
    { 
       return MBA.HttpApplication.createLink(ORPDocuments.URL_REST_VIEW_BASE, true);
    }

    /***************************************************************************
     * URL_WEB_REPORT_ORP_DOCS_ORDERS_AND_PROFILES */
    /**
     * 
     **************************************************************************/  
    public static string URL_WEB_REPORT_ORP_DOCS_ORDERS_AND_PROFILES() {
      return MBA.HttpApplication.createLink(ORPDocuments.URL_EXPORT_DATA_BASE, true);      
    }

    /***************************************************************************
     * URL_ADD_NEW_ORDER_PRESCRIPTION */
    /**
     * 
     **************************************************************************/  
    public static string URL_ADD_NEW_ORDER_PRESCRIPTION()
    {
      return MBA.HttpApplication.createLink( ORPDocuments.URL_USER_ALL_SAVE_BASE
                                            , true
                                            , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                            , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW)                                            
                                            );
    }

    /***************************************************************************
     * URL_EDIT_ORDER_PRESCRIPTION_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_EDIT_ORDER_PRESCRIPTION_BASE()
    {
      return MBA.HttpApplication.createLink (ORPDocuments.URL_USER_ALL_SAVE_BASE
                                             , true
                                             , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                             , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT)
                                             , new NameValue(Constants.PARM_REC_ID, @"")
                                            );
    }
    
    /***************************************************************************
     * URL_EDIT_ORDER_PRESCRIPTION_BASE_REDIRECT */
    /**
     * 
     **************************************************************************/  
    public static string URL_EDIT_ORDER_PRESCRIPTION_BASE_REDIRECT()
    {
      return MBA.HttpApplication.createLink (ORPDocuments.URL_USER_ALL_SAVE_BASE
                                             , true
                                             , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT)
                                             , new NameValue(Constants.PARM_REC_ID, @"")
                                            );
    }
    /***************************************************************************
     * URL_DELETE_ORDER_PRESCRIPTION_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_DELETE_ORDER_PRESCRIPTION_BASE()
    {
      return MBA.HttpApplication.createLink(  ORPDocuments.URL_USER_ALL_DELETE_BASE
                                             , true
                                           );
    }

    /***************************************************************************
     * URL_REQUEST_SVC_AUTH_ORDER_PRESCRIPTION_BASE */
    /**
     * 
     **************************************************************************/  

    public static string URL_REQUEST_SVC_AUTH_ORDER_PRESCRIPTION_BASE ()
    {
      return MBA.HttpApplication.createLink ( ServiceAuthorizationRequests.URL_SAVE
                                            , true
                                            , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                            , new NameValue(ServiceAuthorizationRequests.PARM_NAME_AUTH_REQUEST_TYPE, (int)ServiceAuthorizationRequestTypes.ORDER_OR_PRESCRIPTION)
                                            , new NameValue(ServiceAuthorizationRequests.PARM_NAME_REFD_ENTITY_ID, ""));
    }
    
    /***************************************************************************
     * URL_REQUEST_SVC_AUTH_PATIENT_PROFILE_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_REQUEST_SVC_AUTH_PATIENT_PROFILE_BASE ()
    {
      return MBA.HttpApplication.createLink ( ServiceAuthorizationRequests.URL_SAVE
                                            , true
                                            , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                            , new NameValue(ServiceAuthorizationRequests.PARM_NAME_AUTH_REQUEST_TYPE, (int)ServiceAuthorizationRequestTypes.PATIENT_PROFILE)
                                            , new NameValue(ServiceAuthorizationRequests.PARM_NAME_REFD_ENTITY_ID, ""));
    }

    /***************************************************************************
     * URL_SERVICE_VIEW_SEL_ORDS_PROF_FOR_CLT_GRP_PAT_SVC_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_SERVICE_VIEW_SEL_ORDS_PROF_FOR_CLT_GRP_PAT_SVC_BASE()
    {
      return MBA.HttpApplication.createLink ( ORPDocuments.URL_SERVICE_VIEW_SEL_ORDS_PROF_FOR_CLT_GRP_PAT_SVC
                                            , true);
    }
     
    /***************************************************************************
     * URL_SERVICE_VIEW_SEL_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_SERVICE_VIEW_SEL_BASE()
    {
      return MBA.HttpApplication.createLink ( URL_VIEW_SEL_ONLY_ORDERS_PROFILES_BASE
                                            , true);
    }

    /***************************************************************************
     * defineCols _dcOrdersAndPrescr */
    /**
     *  Used for two viewTbl methods that return identical columns sets
     **************************************************************************/ 

    private static defineCols _dcOrdersAndPrescr(UserInfo uInfo, bool applyUinfoRules = true)
    {
        return delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
             ss.addDisplayColumn("id");
             ss.addDisplayColumn("patName           as [Patient]", true);
             ss.addDisplayColumn("orpDocStdName     as [Service]", true);

             if (applyUinfoRules == true)
             { 
               if (uInfo.userGroup == Constants.USER_GROUP_SBSC)
               {
                 ss.addDisplayColumn("effectiveDateStr  as [Plan Start\nDate]", true);
                 ss.addDisplayColumn("endDateStr        as [Plan End\nDate]", true);
                 ss.addDisplayColumn("dbo.RPT_BIT_TO_YN(active) as [Active]");
               }
             }
             ss.addDisplayColumn("lastApprovalEffectiveDateStr  as [Effective Date]");
             ss.addDisplayColumn("lastApprovalExpirationMessage as [ORP Approval\nStatus]");

             ss.addDisplayColumn("orpPracName              as [ORP\nProfessional]");
             ss.addDisplayColumn("orpNPI                   as [ORP\nNPI]");
             ss.addDisplayColumn("orpIsValidMcalOrp        as [ORP\nValid]");
            //ss.addDisplayColumn("svcDesc                as [Short Description]");
             ss.addDisplayColumn("noteCrit1                as [Note Criteria 1]");
             ss.addDisplayColumn("noteCrit2                as [Note Criteria 2]");
             ss.addDisplayColumn("noteCrit3                as [Note Criteria 3]");
             ss.addDisplayColumn("noteCrit4                as [Note Criteria 4]");
             ss.addDisplayColumn("createdByUserName        as [Created By]");
             ss.addDisplayColumn("createdStr               as [Created\nOn]");
             ss.addDisplayColumn("lastModifiedByUserName   as [Last Modified By]");
             ss.addDisplayColumn("lastModifiedStr          as [Last\nModified\nOn]");
             ss.addDisplayColumn("refID                    as [Referenced\nEntity\nID]");
             ss.addDisplayColumn("orpDocType               as [ORP Type]");
             ss.addDisplayColumn("ORP_DOCUMENT_ID          as [orpDocID]");
             ss.addDisplayColumn("siteName                 as [Site]");
             ss.addDisplayColumn("studentID                as [Student ID]");

             pageroworder = ss.pageRowOrder();

        };
    }
       
   /***************************************************************************
    * validateAndAddCommonSvcAuthorizationParams */
   /**
    * Note: Used by :
    *  
    * - ServiceJournalPrescribedOrders
    * - ServiceJournalServiceDescriptions
    * 
    **************************************************************************/

   public static void validateAndAddCommonSvcAuthorizationStatusParams (   ref RequestResponse rd
                                                                         , string orpPracID
                                                                         , string orpAuthSvcDate
                                                                         , string orpAuthExpDate
                                                                         , string svcAuthStatusConfirmRespCode
                                                                         , ref List<SqlParameter> parms)
   {

      Object   vOrpPracID = Validate.optInteger (orpPracID, Messages.INVALID_ORP_PRAC_ID, true);
      Object   vOrpAuthSvcDate;
      Object   vOrpAuthExpDate = null;
      Object   vSvcAuthStatusConfirmRespCode;
      
      /* If an ORP is selected then ..*/

      if (Util.isNullOrPseduoNullValue (orpPracID) == false)
      {
              
        /* We require that the user enter the date the service was authorized 
         * and the authorization status (Pending, Authorized, etc.).  This is also where a user can indicate 
         * that they are the ORP authorizing the order and trigger a self authorization request/response through
         * the service authorizaton system on the back end. */

        vSvcAuthStatusConfirmRespCode = Validate.reqInteger (svcAuthStatusConfirmRespCode, Messages.AUTHORIZATION_STATUS_REQUIRED);

        /* If the authorization status is Yes I am approving this as the ORP  */

        if ( (int) vSvcAuthStatusConfirmRespCode == (int) ServiceAuthorizationStatusConfirmationResponse.YES_I_AM_THE_ORP)
        {
          /* And its a valid possible response for this user role */

          if (SelectServiceAuthorizationStatusConfirmationResponse.isYesIAmTheORPAValidPossibleOption(ref rd))
          {
            /* Convert the orpID submitted to something we can compare the logged in practitioner id with */ 
            
            if (long.TryParse(orpPracID,out long orpPracIDSubmitted))
            { 
              /* If there are not the same then let the user know they cannot do this */              
              if (orpPracIDSubmitted != rd.wu.pr.id)
              {
                throw new Critical("You are not the selected ORP");              
              }

            }
            else
            {
              throw new Critical(Messages.INVALID_ORP_PRAC_ID);
            }
          }

          /* If its not a valid response then let the user know (Note: this will only happen if the user messes with the request) */

          else
          {
             throw new Critical("Only practitioners are allowed to select this option");
          }
        }

        /* If response is */

       if ( (int) vSvcAuthStatusConfirmRespCode == (int) ServiceAuthorizationStatusConfirmationResponse.UNKNOWN)
       {
          vOrpAuthSvcDate = Validate.optDate (orpAuthSvcDate, Messages.INVALID_AUTHORIZE_DATE);         
       }
        
       else
       { 
        
          /* If the answer is no/pending */
          
          if ((int) vSvcAuthStatusConfirmRespCode == (int) ServiceAuthorizationStatusConfirmationResponse.NO_PENDING_AUTH)
          {
            
            /* And no date is given, default to todays date */
            
            if (String.IsNullOrWhiteSpace(orpAuthSvcDate)) orpAuthSvcDate = DateTime.Today.Date.ToShortDateString();

            vOrpAuthSvcDate = Validate.optDate (orpAuthSvcDate, Messages.INVALID_AUTHORIZE_DATE);            
            
          }

          /* Otherwise a date is required */

          else
          { 
            vOrpAuthSvcDate = Validate.reqDate (orpAuthSvcDate, Messages.INVALID_AUTHORIZE_DATE);
            vOrpAuthExpDate = Validate.optDate (orpAuthExpDate, Messages.INVALID_AUTHORIZE_DATE);
          }
        }
      }            
      else
      {
        vOrpAuthSvcDate               = Validate.optDate    (orpAuthSvcDate,               Messages.INVALID_AUTHORIZE_DATE);
        vSvcAuthStatusConfirmRespCode = Validate.optInteger (svcAuthStatusConfirmRespCode, Messages.AUTHORIZATION_STATUS_REQUIRED);
      }
      
      /* Add database parameters for stored procedure save call */

      parms.Add(Database.SqlParm("@orpPracID",                    SqlDbType.BigInt,   vOrpPracID,                     ParameterDirection.Input));                  
      parms.Add(Database.SqlParm("@orpAuthSvcDate",               SqlDbType.Date,     vOrpAuthSvcDate,                ParameterDirection.Input));
      parms.Add(Database.SqlParm("@orpAuthExpDate",               SqlDbType.Date,     vOrpAuthExpDate,                ParameterDirection.Input));
      parms.Add(Database.SqlParm("@svcAuthStatusConfirmRespCode", SqlDbType.BigInt,   vSvcAuthStatusConfirmRespCode,  ParameterDirection.Input));

   }

    /***************************************************************************
     * generateLastAuthorizedInfoHtmlString */
    /**
     * 
     **************************************************************************/  
   
   public static string generateLastAuthorizedInfoHtmlString (bool hasLastAuth, string orpName, string orpTitle, string orpNPI, string effDateStr)
   {
     if (hasLastAuth) {
       return String.Format(@"The last ORP who authorized this service was <span>{0}</span> (<span>{1}</span>) NPI #: <span>{2}</span>.<br>Authorization is effective as of <time>{3}</time>."
                                            , orpName
                                            , orpTitle
                                            , orpNPI
                                            , effDateStr
                                            );       
     }
    return @"";
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
				                  , string        rdrPracID
				                  , string        rdrGroupSvcClassNameID
				                  , string        patID
                                  , string        dos
                                  , string        term
                                  , string        includeOnlyOrpDocTypeIDs
                                  , string        displayRank
                                  , defineCols    dc 
                                  , bool requirePatID = false)
    {
    
      string viewUDF = "dbo.ORP_DOCUMENTS_VIEW (@userID, @userGroup, @userRank, @clientID, @rdrPracID, @rdrGroupSvcClassNameID, @patID, @dos, @term, null, null, @includeOnlyOrpDocTypeIDs, @displayRank, @active, @recID)";
      
      /*###########################################################################
        # Validate parameters specific to this entity view and create their 
        # database parameters
        ###########################################################################*/  
       
      Object  vClientID                 = Validate.optClientID (uInfo,  clientID);
      Object  vRdrPracID                = Validate.optPracID   (uInfo,  rdrPracID);
      Object  vRdrGroupSvcClassNameID   = Validate.optInteger  (rdrGroupSvcClassNameID, Messages.INVALID_GROUP_ID);
      Object  vPatID;
      if (requirePatID == true)
      {
        vPatID = Validate.reqPatID(uInfo,patID);
      }
      else
      {
        vPatID = Validate.optInteger  (patID, Messages.INVALID_PAT_ID);
      }

	  Object  vDOS                      = Validate.optDate     (dos,                    Messages.INVALID_DOS);
      Object  vTerm                     = Validate.optString   (term,                   Messages.INVALID_SEARCH_TERM);      
      Object  vIncludeOnlyOrpDocTypeIDs = Validate.optRecIDMultiStr(includeOnlyOrpDocTypeIDs, @"Invalid orp doc type ids");
      Object  vDisplayRank              = Validate.optInteger  (displayRank, @"Invalid display ranking");
	    
	  List<SqlParameter> parms = new List<SqlParameter>();
                         
      parms.Add(Database.SqlParm("@clientID",                 SqlDbType.BigInt,   vClientID,                    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@rdrPracID",                SqlDbType.BigInt,   vRdrPracID,                   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@rdrGroupSvcClassNameID",   SqlDbType.BigInt,   vRdrGroupSvcClassNameID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",                    SqlDbType.BigInt,   vPatID,                       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@dos",                      SqlDbType.Date,     vDOS,                         ParameterDirection.Input));
	  parms.Add(Database.SqlParm("@term",                     SqlDbType.VarChar,  vTerm,                        ParameterDirection.Input, 255));	    
	  parms.Add(Database.SqlParm("@includeOnlyOrpDocTypeIDs", SqlDbType.VarChar,  vIncludeOnlyOrpDocTypeIDs,    ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@displayRank",              SqlDbType.BigInt,   vDisplayRank,                 ParameterDirection.Input));  
	    	  
      /*###########################################################################
        # Call base method which handles the rest and return the results
        ###########################################################################*/  
      
      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

    }


    /***************************************************************************
     * viewOrdersAndProfiles */
    /**
     * 
     * @return                 ReturnDB 
     **************************************************************************/    
    public static ReturnDB viewOrdersAndProfiles(SqlConnection connSpedmon
                                       , DetailsLog log
                                       , UserInfo uInfo
                                       , int recViewType
                                       , bool pagedOrTop
                                       , string idx
                                       , string canEdit
                                       , string active
                                       , string clientID
                                       , string patID
                                       , string groupSvcClassNameID
                                       , string referenceDate
                                       , string startDate
                                       , string endDate
                                       , string maxRow
                                       , string orpApprovalState
                                       , defineCols dc)
    {
    
      string viewUDF = "dbo.SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @groupSvcClassNameID, @patID, @referenceDate, @startRefDate, @endRefDate, @maxRow, @orpApprovalState, @recID, @active)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
       
      Object  vClientID            = Validate.optClientID (uInfo, clientID);            
      Object  vPracID              = Validate.optPracID   (uInfo, @""); /* Force prac ID for practitioners */
   
      Object  vGroupSvcClassNameID = Validate.optInteger  (groupSvcClassNameID, Messages.INVALID_GROUP_FAMILY);
      Object  vPatID               = Validate.optInteger  (patID,               Messages.INVALID_PAT_ID);
      Object  vReferenceDate       = Validate.optDate     (referenceDate,       Messages.INVALID_DATES);
      Object  vStartRefDate        = Validate.optDate     (startDate,           Messages.INVALID_START_DATE);
      Object  vEndRefDate          = Validate.optDate     (endDate,             Messages.INVALID_END_DATE);
      Object  vMaxRow              = Validate.optInteger  (maxRow,              @"Invalid max row");
      Object  vOrpApprovalState    = Validate.optInteger  (orpApprovalState,    @"Invalid approval state", true);

      List<SqlParameter> parms = new List<SqlParameter>();
                   
      parms.Add(Database.SqlParm("@clientID",            SqlDbType.BigInt,   vClientID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",              SqlDbType.BigInt,   vPracID,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",               SqlDbType.BigInt,   vPatID,               ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@groupSvcClassNameID", SqlDbType.BigInt,   vGroupSvcClassNameID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@referenceDate",       SqlDbType.DateTime, vReferenceDate,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startRefDate",        SqlDbType.Date,     vStartRefDate,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endRefDate",          SqlDbType.Date,     vEndRefDate,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@maxRow",              SqlDbType.Int,      vMaxRow,              ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@orpApprovalState",    SqlDbType.BigInt,   vOrpApprovalState,    ParameterDirection.Input));
      
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

    }

    
    
    /***************************************************************************
     * viewOrdersAndProfilesForClientGroupSvcClassPatStdSelName */
    /**
     * Used for dup check
     **************************************************************************/  
    public static ReturnDB viewOrdersAndProfilesForClientGroupSvcClassPatSvc (
          SqlConnection connSpedmon
        , DetailsLog    log
        , UserInfo      uInfo
        , int           recViewType
        , bool          pagedOrTop
        , string        idx
        , string        canEdit
        , string        active
        , string        clientID
        , string        groupSvcClassNameID
        , string        patID
        , string        orpDocStdSelNameID
        , defineCols dc)
    {
    
      string viewUDF = "dbo.SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW_EXISTING_FOR_CLIENT_GROUP_SVC_CLASS_PAT_STD_SEL_NAME(@userID,@userGroup,@userRank,@clientID,@groupSvcClassNameID,@patID,@orpDocStdSelNameID,@active)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      long   vClientID                = Validate.reqClientID (uInfo, clientID);
      long   vGroupSvcClassNameID     = Validate.reqStdGroupSvcClassNameID (uInfo, groupSvcClassNameID);
      long   vPatID                   = Validate.reqInteger(patID, Messages.INVALID_PAT_ID);
      long   vOrpDocStdSelNameID      = Validate.reqInteger (orpDocStdSelNameID, Messages.INVALID_PAT_ID);

      var parms = new List<SqlParameter>();
                   
      parms.Add(Database.SqlParm("@clientID",               SqlDbType.BigInt,   vClientID,               ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",                  SqlDbType.BigInt,   vPatID,                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@groupSvcClassNameID",    SqlDbType.BigInt,   vGroupSvcClassNameID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@orpDocStdSelNameID",     SqlDbType.BigInt,   vOrpDocStdSelNameID,     ParameterDirection.Input));
              
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

    }
    
        
    /***************************************************************************
     * viewSelOrdersAndProfilesForClientGroupSvcClassPatSvc */
    /**
     * Used for dup check
     * 
     * @return                 ReturnDataTable   // NOTE!! Returns ReturnSel, not ReturnDataTable.
                                                 //        all existing comment blocks for this .cs code should be inspected
                                                 //        and possibly rewritten... eventually.
     ***************************************************************************/
    public static ReturnSel viewSelOrdersAndProfilesForClientGroupSvcClassPatSvc (
         SqlConnection connSpedmon
       , DetailsLog    log
       , UserInfo      uInfo
       , bool          top
       , string        topSize
       , string        clientID
       , string        groupSvcClassNameID
       , string        patID
       , string        orpDocStdSelNameID ) 
    {
      /*###########################################################################
        # Define context columns
        ###########################################################################*/  

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){
        
        ss.addDisplayColumn("context1");        
       
      };
     
      /*###########################################################################
        # Call the base method which handles the rest and return
        ###########################################################################*/  

      return Entities.viewSel(  connSpedmon
                              , log
                              , uInfo
                              , top
                              , topSize
                              , delegate{ return                              
                                ORPDocuments.viewOrdersAndProfilesForClientGroupSvcClassPatSvc (  
                                      connSpedmon
                                    , log
                                    , uInfo
                                    , Entities.REC_VIEW_SEL
                                    , top
                                    , topSize                                   
                                    , ""                                                  
                                    , "1"                                                  
                                    , clientID
                                    , groupSvcClassNameID
                                    , patID
                                    , orpDocStdSelNameID
                                    , dc );
                              });
    }
    
    /***************************************************************************
     * viewSel */
    /**
     *
     * Used on multi pat multi svc service records entry screen for selection if
     * applicable
     * 
     * @return                 ReturnDataTable
     ***************************************************************************/
    public static ReturnSel viewSel (   SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , bool          top
                                      , string        topSize
                                      , string        clientID
                                      , string        rdrPracID				                				  
                                      , string        patID  
                                      , string        includeOnlyOrpDocTypeIDs
                                      , string        term
                                      , bool          requirePatID) 
    {
      /*###########################################################################
        # Define context columns
        ###########################################################################*/  

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){
        
        ss.addDisplayColumn("context1");        
        ss.addDisplayColumn("svcNoteTemplateTitle                           as [recData1]");
        ss.addDisplayColumn("svcNoteTemplateText                            as [recData2]");
        ss.addDisplayColumn("convert(varchar, lastApprovalExpiresInDays)    as [recData3]");
        ss.addDisplayColumn("convert(varchar, lastApprovalExpirationState)  as [recData4]");
        ss.addDisplayColumn("svcNoteCriteriaFormQuestionsJSON               as [recData5]");
        ss.addDisplayColumn("convert(varchar, iep)                          as [recData6]");
        ss.addDisplayColumn("[frequencyName]                                as [recData7]");
        ss.addDisplayColumn("convert(varchar, [projectedMinutes]   )        as [recData8]");
        ss.addDisplayColumn("planStartDateStrYMD                            as [recData9]");
        ss.addDisplayColumn("planEndDateStrYMD                              as [recData10]");

        
      };
     
      /*###########################################################################
        # Call the base method which handles the rest and return
        ###########################################################################*/  

      return Entities.viewSel(  connSpedmon
                              , log
                              , uInfo
                              , top
                              , topSize
                              , delegate{ return                              
                                ORPDocuments.view (  connSpedmon
                                                   , log
                                                   , uInfo
                                                   , Entities.REC_VIEW_SEL
                                                   , top
                                                   , topSize
                                                   , ""                                                  
                                                   , "1"                                                  
                                                   , clientID
                                                   , rdrPracID
                                                   , null
                                                   , patID
                                                   , ""
                                                   , term
                                                   , includeOnlyOrpDocTypeIDs
                                                   , @"1"    /* Limits patient profiles to most current*/
                                                   , dc
                                                   , requirePatID
                                                   );
                              });
    }
    
    /***************************************************************************
     * viewSelForJournalEntry */
    /**
     * Returns either orders or patient profile
     * 2 = Orders , 3 = Patient profile
     * @return                 ReturnDataTable
     * TODO: This may not be used anymore.  Check and remove if so.
     ***************************************************************************/
  
    public static ReturnSel viewSelForJournalEntry (   SqlConnection connSpedmon
                                                     , DetailsLog    log
                                                     , UserInfo      uInfo
                                                     , bool          top
                                                     , string        topSize
                                                     , string        clientID
                                                     , string        rdrPracID				                				  
                                                     , string        patID
                                                     , string        term
                                                     , string        orpDocTypeID ) 
    {

      if (Util.IsNullOrEmpty(orpDocTypeID)) orpDocTypeID = "2,3";
      
      /*###########################################################################
        # Define context columns
        ###########################################################################*/  

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {        
        ss.addDisplayColumn("context1");        
        ss.addDisplayColumn("svcNoteTemplateTitle as [recData1]");
        ss.addDisplayColumn("svcNoteTemplateText  as [recData2]");        
      };
     
      /*###########################################################################
        # Call the base method which handles the rest and return
        ###########################################################################*/  

      return Entities.viewSel(  connSpedmon
                              , log
                              , uInfo
                              , top
                              , topSize
                              , delegate{ return                              
                                ORPDocuments.view (  connSpedmon
                                                   , log
                                                   , uInfo
                                                   , Entities.REC_VIEW_SEL
                                                   , top
                                                   , topSize
                                                   , ""                                                  
                                                   , "1"                                                  
                                                   , clientID
                                                   , rdrPracID
                                                   , null
                                                   , patID
                                                   , ""
                                                   , term
                                                   , orpDocTypeID
                                                   , @"1"    /* Limits patient profiles to most current*/
                                                   , dc );
                              });
    }
    

    /***************************************************************************
     * rptCurrentAndExpiringOrders */
    /**
     * Returns current and expiring orders
     * 
     * @return ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable rptCurrentAndExpiringOrders (  SqlConnection connSpedmon
                                                                , DetailsLog    log
                                                                , UserInfo      uInfo
                                                                , bool          paged
                                                                , string        pageNumber
                                                                , string        clientID
                                                                , bool          applyUInfoRules = true)
   {

     ReturnDataTable so = new ReturnDataTable();
            
     int vClientID = Validate.reqClientID (uInfo, clientID);            

     var parms = new List<SqlParameter>();       
            
     parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
     
     so = Entities.viewRpt (  connSpedmon
                             , log
                             , uInfo
                             , paged
                             , pageNumber
                             , "Y"
                             , @"RPT_CURRENT_AND_EXPIRING_ORDERS (@userID, @userGroup, @userRank, @clientID)"
                             , parms
                             , null
                             , ORPDocuments._dcOrdersAndPrescr (uInfo, applyUInfoRules)
                             , ORPDocuments.SEL_LABEL_CURRENT_EXP
                             , Messages.CONFIDENTIAL );
          
     return so;
     
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
                                           , string        patID
                                           , string        dos
                                           , string        canEdit
                                           , string        active )
   {
     ReturnDataTable so        = new ReturnDataTable();
     string          tableName = ORPDocuments.SEL_LABEL;
     
     /*###########################################################################
       # Define our display columns and set the page order.  Page order needs to
       # be in the same sort order as the udf called in the view.
       ###########################################################################*/  

     defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
     {       
       ss.addDisplayColumn("id");       
       ss.addDisplayColumn("clientName               as [Client]",             true);
       ss.addDisplayColumn("patName                  as [Patient\nName]",      true);
       ss.addDisplayColumn("patDOBStr                as [Patient\nDOB]",       true);
       ss.addDisplayColumn("patCSIS                  as [Patient\nCSIS]");
       ss.addDisplayColumn("patBIC                   as [Patient\nBIC]");
       ss.addDisplayColumn("startDateStr             as [Effective\nDate]",    true);
       ss.addDisplayColumn("orpPracName              as [ORP\nName]");
       ss.addDisplayColumn("orpPracNPINumber         as [ORP\nNPI #]");
       ss.addDisplayColumn("orpPracIsValidMcalOrpStr as [ORP\nIs\nMCAL\nValidated]");
       ss.addDisplayColumn("orpPracIsReadyFor837Str  as [ORP\nIs\nReady\nFor Claims]");
       ss.addDisplayColumn("orpDocTypeName           as [Document\nSource]");
       ss.addDisplayColumn("name                     as [Document\nTitle]");
       ss.addDisplayColumn("description              as [Document\nDescription]");
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
                             ORPDocuments.view (  connSpedmon
                                                , log
                                                , uInfo
                                                , Entities.REC_VIEW_TBL
                                                , paged
                                                , pageNumber
                                                , canEdit
                                                , active
                                                , clientID
                                                , null
                                                , null
                                                , patID
                                                , dos
                                                , null
                                                , null
                                                , null
                                                , dc); 
                             });
   
     /*###########################################################################
       # Add a title and footer to ReturnDataTable then return
       ###########################################################################*/  
               
     so.tableName   = tableName;
     so.tableFooter = Messages.CONFIDENTIAL;
         
     return so;
     
    } 


    /***************************************************************************
     * load */
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

    public static ORPDocument load (   SqlConnection connSpedmon
                                     , DetailsLog    log
                                     , UserInfo      uInfo
                                     , string        clientID
                                     , string        recID )
    {      
      /*###########################################################################
        # Call the base method which handles everything and return
        ###########################################################################*/  

      return (ORPDocument) Entities.load(connSpedmon, log, uInfo, recID, typeof(ClientPBSDocumentRecord),
      delegate { return ORPDocuments.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", clientID, null,null,null, null, null, null, null, null); });
    }
        
    /***************************************************************************
     * viewTblOrdersAndProfiles */
    /**
     * Returns a data table of records for preview or record selection.
     * 
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewTblOrdersAndProfiles(SqlConnection connSpedmon
                                            , DetailsLog log
                                            , UserInfo uInfo
                                            , bool paged
                                            , string pageNumber
                                            , string clientID
                                            , string patID
                                            , string groupSvcClassNameID
                                            , string dateRange
                                            , string orpApprovalState
                                            , string canEdit
                                            , string active)
    {

        ReturnDataTable so = new ReturnDataTable();

        /*-------------------------------
         * Parse date range into start
         * and end dates
         *----------------------------*/

        string startDate = "";
        string endDate = "";
        Util.parseDateRange(dateRange, out startDate, out endDate);

        /*----------------------------
         * SBSC staff can see both 
         * active and inactive for
         * views. 
         *----------------------------*/

        if (uInfo.userGroup == Constants.USER_GROUP_SBSC)
        {
            active = @"";
        }
        else
        {
            active = @"Y";
        }


        /*----------------------------
            * Call base method which
            * handles the rest 
            *----------------------------*/

        so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
            delegate { return ORPDocuments.viewOrdersAndProfiles(
                          connSpedmon, log, uInfo,
                          Entities.REC_VIEW_TBL, paged, pageNumber, canEdit,
                          active, clientID, patID, groupSvcClassNameID, null,
                          startDate, endDate, null, orpApprovalState,
                          ORPDocuments._dcOrdersAndPrescr( uInfo )
             ); });

        /*----------------------------
            * Add a title and footer
            *----------------------------*/

        so.tableName = "Orders and Profiles - View";
        so.tableFooter = Messages.CONFIDENTIAL;

        /*----------------------------
         * Done
         *----------------------------*/

        return so;

    }


    /***************************************************************************
     * viewObjectsOrdersAndProfiles 
     *
     * Returns 
     * 
     ***************************************************************************/

    public static ReturnObjects viewObjectsOrdersAndProfiles (  SqlConnection connSpedmon
                                                               , DetailsLog   log
                                                               , UserInfo     uInfo
                                                               , bool         pageObjectList
                                                               , string       pageOrder
                                                               , string       idx
                                                               , string       active
                                                               , string       clientID
                                                               , string       groupSvcClassNameID
                                                               , string       patID
                                                               , string       orpApprovalState )

    {
      /* Default page order */

      if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = ORPDocuments.DEFAULT_PAGING_ORDER_ORDERS_PROFILES;

      /* Define columns delegate is used to specify columns and page order 
       * We pass in the desired page row order here */

      defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        pageroworder = pageOrder;
      };

      var rd = Entities.viewObjects( connSpedmon
                                   , log
                                   , uInfo
                                   , typeof(ServiceJournalsPrescribedOrder)
                                   , pageObjectList
                                   , pageOrder
                                   , delegate {
                                       return ORPDocuments.viewOrdersAndProfiles( connSpedmon
                                                                                 , log
                                                                                 , uInfo
                                                                                 , Entities.REC_VIEW_OBJECTS
                                                                                 , pageObjectList
                                                                                 , idx
                                                                                 , "" /* Can Edit */
                                                                                 , active
                                                                                 , clientID
                                                                                 , patID
                                                                                 , groupSvcClassNameID
                                                                                 , null
                                                                                 , null
                                                                                 , null
                                                                                 , null
                                                                                 , orpApprovalState
                                                                                 , dc);
                                   });
            
        
      return rd;
    }

        /***************************************************************************
         * loadOrderOrProfileFromORPDoc */
        /**
         * Returns an order or profile given ORP document info
         * 
         * @return                 ReturnDataTable
         ***************************************************************************/

        public static ServiceJournalsPrescribedOrder loadOrderOrProfileFromORPDoc(SqlConnection connSpedmon
                                            , DetailsLog log
                                            , UserInfo uInfo
                                            , string clientID
                                            , string recID)
    {

        return (ServiceJournalsPrescribedOrder)Entities.load(connSpedmon, log, uInfo, recID, typeof(ServiceJournalsPrescribedOrder),
        delegate
        {
            return ORPDocuments.viewOrdersAndProfiles(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", clientID, null, null, null, null, null, null, null, null);
        });
    }

    /***************************************************************************
     * deleteOrderOrProfile */
    /**
     * "Deletes" an order or profile
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id for ORP document reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    public static ReturnSaveRecord deleteOrderOrProfile(
          SqlConnection   connSpedmon
        , DetailsLog      log
        , UserInfo        uInfo
        , string          editDelReason
        , string          validateRec
        , string          recID)
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
     
      return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "SVCJOURNAL_JOURNAL_ORDERS_PROFILES_DELETE", ref parms);
    }

    /*************************************************************************
    * viewList */
   /**
    * Return a list of Route Member records
    * 
    ***************************************************************************/

    public static List<ServiceJournalsPrescribedOrder> viewList( SqlConnection connSpedmon
                                                         , DetailsLog    log
                                                         , UserInfo      uInfo
                                                         , string        clientID
                                                         , string        patID
                                                         , string        active)
      
     {
        var recs = new List<ServiceJournalsPrescribedOrder>();
        ReturnDB rd = ORPDocuments.viewOrdersAndProfiles(connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, null, null, active, clientID, patID, null, null, null, null, null, null, null);       
        List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(ServiceJournalsPrescribedOrder));
        foreach (var o in slo) {
            recs.Add((ServiceJournalsPrescribedOrder) o);
        }
        return recs;
    }

    /*************************************************************************
    * viewSelPatOrdersForDos */
   /**
    * Returns patient orders that cover a date of service
    * Used on multi pat multi svc service records entry screen for pracs
    ***************************************************************************/

    public static ReturnSel viewSelPatOrdersForDos( SqlConnection connSpedmon
                                                    , DetailsLog    log
                                                    , UserInfo      uInfo
                                                    , string        clientID
                                                    , string        pracID
                                                    , string        patID
                                                    , string        dos
                                                    , string        recID)
      
     {
            
      /*###########################################################################
        # Define context columns
        ###########################################################################*/  

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {
          ss.addDisplayColumn("context1");
          ss.addDisplayColumn("svcNoteTemplateTitle                           as [recData1]");
          ss.addDisplayColumn("svcNoteTemplateText                            as [recData2]");
          ss.addDisplayColumn("convert(varchar, lastApprovalExpiresInDays)    as [recData3]");
          ss.addDisplayColumn("convert(varchar, lastApprovalExpirationState)  as [recData4]");
      };
     
      /*###########################################################################
        # Call the base method which handles the rest and return
        ###########################################################################*/  

      return Entities.viewSel(  connSpedmon
                              , log
                              , uInfo
                              , false
                              , null
                              , delegate{ return                              
                                ORPDocuments.view(
                                                     connSpedmon
                                                   , log
                                                   , uInfo
                                                   , Entities.REC_VIEW_SEL
                                                   , false
                                                   , null
                                                   , ""
                                                   , "1"
                                                   , clientID
                                                   , pracID
                                                   , null
                                                   , patID
                                                   , dos
                                                   , null
                                                   , null
                                                   , null    /* Limits patient profiles to most current*/
                                                   , dc);
                              });
    }

  }
}
