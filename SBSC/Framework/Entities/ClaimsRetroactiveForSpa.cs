using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * ClaimsRetroactiveForSpaPotentialReimburseSums  */
  /**
   * Used for summary reporting
   ***************************************************************************/
  public class ClaimsRetroactiveForSpaPotentialReimburseSums 
  {
    public decimal Y = 0.00M;
    public decimal N = 0.00M;
    public decimal U = 0.00M;
  }

  /***************************************************************************
   * ReturnClaimsRetroactiveForSpaPotentialReimburseSums  */
  /**
   * Used for summary reporting
   ***************************************************************************/

  public class ReturnClaimsRetroactiveForSpaPotentialReimburseSums : Return
  {
    public ReturnClaimsRetroactiveForSpaPotentialReimburseSums ()                 : base()    {}
    public ReturnClaimsRetroactiveForSpaPotentialReimburseSums (string msg)       : base(msg) {}
    public ReturnClaimsRetroactiveForSpaPotentialReimburseSums (Exception e)      : base(e)   {}
    public ReturnClaimsRetroactiveForSpaPotentialReimburseSums (Warning e)        : base(e)   {}
    public ReturnClaimsRetroactiveForSpaPotentialReimburseSums (Critical e)       : base(e)   {}
    public ReturnClaimsRetroactiveForSpaPotentialReimburseSums (SessionExpired e) : base(e)   {}
    public bool hasRecord = false;
    public ClaimsRetroactiveForSpaPotentialReimburseSums sums;
  }
  
  /***************************************************************************
   * ReturnClaimsRetroactiveForSpaPossibleSelection  */
  /**
   * Used for selection for approval or defer
   ***************************************************************************/
  public class ClaimsRetroactiveForSpaPossibleSelection
  {
        public const string DEFAULT_PAGING_ORDER = @"pracName,groupName,svcPlan,svcName,fyName";

        public string   id;          /* id is a composite string */
        public string   pracName;
        public string   fyName;
        public string   groupName;
        public string   svcPlan;
        public string   svcName;
        public long     numSvcRecs;
        public Decimal  totEstReimburse;
        public string   totEstReimburseStr;
        public string   authorizedYNU;
  }

  /***************************************************************************
   * ClaimsRetroactiveForSpa  */
  /**
   * 
   ***************************************************************************/

  public class ClaimsRetroactiveForSpa : Entities
  {
    public const string FOR_SPA_2015                       = "1";
    public const string PARM_FOR_SPA                       = @"forspaid";
    public const string PARM_FOR_FY                        = @"fyid";
    public const string PARM_FOR_AUTH_YNU                  = @"authynu";
    public const string MENU_ID_AUTHORIZATION              = @"authorizeretroclaimslink";
    public const string SEL_LABEL_AUTHORIZATION            = @"Authorize Retroactive Claims";
    public const string URL_USER_ALL_AUTHORIZATION         = @"user_all_authorize_retroactive_claims.aspx";
    public const string URL_REST_VIEW_POSSIBLE_SELECTIONS  = @"api/v1/claimsretroactiveforspapossibleselections";

    public const string URL_SVC_BASE     = "claims_retroactive_for_spa.asmx";
    public const string URL_SVC_APPROVE  = URL_SVC_BASE + @"/saveclientauthorizationsapprove";
    public const string URL_SVC_DECLINE  = URL_SVC_BASE + @"/saveclientauthorizationsdecline";
    public const string URL_SVC_GET_SUMS = URL_SVC_BASE + @"/getpotentialreimbursesums";

    /***************************************************************************
     * URL_REST_VIEW_POSSIBLE_SELECTIONS_BASE */
        /**
         * 
        **************************************************************************/
    public static string URL_REST_VIEW_POSSIBLE_SELECTIONS_BASE()
    { 
       return MBA.HttpApplication.createLink(ClaimsRetroactiveForSpa.URL_REST_VIEW_POSSIBLE_SELECTIONS, true);
    }

    /***************************************************************************
     * URL_SVC_APPROVE_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_SVC_APPROVE_BASE()
    { 
       return MBA.HttpApplication.createLink(ClaimsRetroactiveForSpa.URL_SVC_APPROVE, true);
    }

    /***************************************************************************
     * URL_SVC_DECLINE_BASE */
    /**
     * 
     **************************************************************************/
    public static string URL_SVC_DECLINE_BASE()
    {
      return MBA.HttpApplication.createLink(ClaimsRetroactiveForSpa.URL_SVC_DECLINE, true);
    }

    /***************************************************************************
     * URL_SVC_GET_SUMS_BASE */
    /**
     * 
     **************************************************************************/
    public static string URL_SVC_GET_SUMS_BASE()
    {
      return MBA.HttpApplication.createLink(ClaimsRetroactiveForSpa.URL_SVC_GET_SUMS, true);
    }


    /***************************************************************************
     * getPotentialReimburseSums */
    /**
     * 
     **************************************************************************/
    public static ReturnClaimsRetroactiveForSpaPotentialReimburseSums getPotentialReimburseSums (  SqlConnection connSpedmon
                                                                                                 , DetailsLog    log
                                                                                                 , UserInfo      uInfo
                                                                                                 , string        forSpaID
                                                                                                 , string        clientID
                                                                                                 , string        fyID )
    {
            
      var so = new ReturnClaimsRetroactiveForSpaPotentialReimburseSums();
      
      long   vForSpaID   = Validate.reqInteger  (forSpaID, @"Invalid SPA ID");
      long   vClientID   = Validate.reqClientID (uInfo, clientID);
      Object vFYID       = Validate.optInteger  (fyID, Messages.INVALID_FISCAL_YEAR_ID); 
            
      var parms = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@forSpaID",      SqlDbType.BigInt,   vForSpaID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@clientID",      SqlDbType.BigInt,   vClientID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fyID",          SqlDbType.BigInt,   vFYID,          ParameterDirection.Input));

      var sql = @"select top 1 * from dbo.CLAIM_RETROACTIVE_FOR_SPA_POTENTIAL_REIMBURSE_SUMS (@forSpaID, @clientID,@fyID)";

      ReturnDB rd = Database.execQuery(connSpedmon,log,sql,false,parms);
      
      so.hasRecord = rd.hasRecords;
      so.sums = new ClaimsRetroactiveForSpaPotentialReimburseSums();
      if (so.hasRecord)
      {
        so.sums = (ClaimsRetroactiveForSpaPotentialReimburseSums)Database.convertRecord(rd.records, typeof(ClaimsRetroactiveForSpaPotentialReimburseSums));
      }
      return so;      
           
    }

    /***************************************************************************
     * saveClientAuthorization */
    /**
     * 
     **************************************************************************/  
    public static ReturnSaveOrReplaceRecord saveClientAuthorizations ( 
        SqlConnection connSpedmon
      , DetailsLog   log
      , UserInfo     uInfo
      , string       selectionIDs      
      , string       authorized ) 

    {        
      
      /*###########################################################################
        # Validate incoming parameters
        ###########################################################################*/  
       
      string vSelectionIDs  = Validate.reqString (selectionIDs, @"Invalid selections");
      bool   vAuthorized    = Validate.reqFlag   (authorized,   @"Invalid authorization flag");

      /*###########################################################################
        # Create and populate database parameters
        ###########################################################################*/  

      var parms = new List<SqlParameter>();
 
      parms.Add(Database.SqlParm("@selectionIDs",  SqlDbType.VarChar, vSelectionIDs,  ParameterDirection.Input,-1)); 
      parms.Add(Database.SqlParm("@authorized",    SqlDbType.Bit,     vAuthorized,    ParameterDirection.Input));

      parms.Add(Database.SqlParm("@editDelReason", SqlDbType.VarChar,  @"", ParameterDirection.Input, 8000));

      /*###########################################################################
        # Call base method which handles the rest 
        ###########################################################################*/  
      
      return Entities.saveOrReplaceRecord (  connSpedmon
                                           , log
                                           , uInfo
                                           , "N"
                                           , @"CLAIM_RETROACTIVE_FOR_SPA_CLIENT_AUTHORIZATION_SAVE"
                                           , ref parms
                                           , null);                                       
    }

    /***************************************************************************
     * viewPossibleSelections */
    /**
     * 
     **************************************************************************/    
     protected static ReturnDB viewPossibleSelections (
         SqlConnection connSpedmon
       , DetailsLog    log
       , UserInfo      uInfo
       , int           recViewType
       , bool          pagedOrTop
       , string        idx
       , string        canEdit
       , string        active
       , string        forSpaID
       , string        clientID
       , string        fyID
       , string        authorizedYNU
       , defineCols    dc )
     {
    
       string viewUDF = "dbo.CLAIM_RETROACTIVE_FOR_SPA_PAT_BY_FY_AND_PRAC_GROUP_SELECTIONS_POSSIBLE_VIEW (@userID, @userGroup, @userRank, @forSpaID, @clientID, @fyID, @authorizedYNU)";
      
      /*###########################################################################
        # Validate parameters specific to this entity view and create their 
        # database parameters
        ###########################################################################*/  
      
      long   vForSpaID      = Validate.reqInteger  (forSpaID,@"Invalid SPA ID");
      long   vClientID      = Validate.reqClientID (uInfo, clientID);
      Object vFYID          = Validate.optInteger  (fyID, Messages.INVALID_FISCAL_YEAR_ID); 
      string vAuthorizedYNU = Validate.reqOption   (  Validate.reqString (authorizedYNU, @"Authorization state required")
                                                    , @"Y|N|?"
                                                    , @"Invalid authorized state");
      
      List<SqlParameter> parms = new List<SqlParameter>();
                         
      parms.Add(Database.SqlParm("@forSpaID",      SqlDbType.BigInt,   vForSpaID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@clientID",      SqlDbType.BigInt,   vClientID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fyID",          SqlDbType.BigInt,   vFYID,          ParameterDirection.Input));	    	  
      parms.Add(Database.SqlParm("@authorizedYNU", SqlDbType.VarChar,  vAuthorizedYNU, ParameterDirection.Input, 1));	    	  
      
      /*###########################################################################
        # Call base method which handles the rest and return the results
        ###########################################################################*/  
      
      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

    }

    /***************************************************************************
     * viewObjectsPossibleSelections 
     *
     * 
     ***************************************************************************/

    public static ReturnObjects viewObjectsPossibleSelections (  SqlConnection connSpedmon
                                                                , DetailsLog log
                                                                , UserInfo   uInfo                                                    
                                                                , bool       pageObjectList
                                                                , string     pageOrder
                                                                , string     idx
                                                                , string     active
											                    , string     forSpaID
                                                                , string     clientID
                                                                , string     fyID
                                                                , string     authorizedYNU )

    {           
      /* Default page order */  

      if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = ClaimsRetroactiveForSpaPossibleSelection.DEFAULT_PAGING_ORDER;
     
      /* Define columns delegate is used to specify columns and page order 
       * We pass in the desired page row order here */

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        pageroworder = pageOrder;
      };

      return Entities.viewObjects(  connSpedmon
                                   , log
                                   , uInfo
                                   , typeof(ClaimsRetroactiveForSpaPossibleSelection)
                                   , pageObjectList
                                   , pageOrder
                                   , delegate {                                      
                                       return ClaimsRetroactiveForSpa.viewPossibleSelections(  connSpedmon
                                                             , log
                                                             , uInfo
                                                             , Entities.REC_VIEW_OBJECTS
                                                             , pageObjectList 
                                                             , idx
                                                             , "" /* Can edit */
                                                             , active
                                                             , forSpaID
                                                             , clientID
                                                             , fyID
                                                             , authorizedYNU                                                            
                                                             , dc );
                                    });
      

    }

    /***************************************************************************
     * viewTblPossibleSelections */
    /**
     * Returns a data table of records for preview or record selection.
     * 
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewTblPossibleSelections (  
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , bool          paged
      , string        pageNumber
      , string        canEdit
      , string        active 
      , string        forSpaID
      , string        clientID
      , string        fyID
      , string        authorizedYNU)
   {
   
     ReturnDataTable so = new ReturnDataTable();
     
     /*###########################################################################
       # Define our display columns and set the page order.  Page order needs to
       # be in the same sort order as the udf called in the view.
       ###########################################################################*/  

     defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
     {       
       ss.addDisplayColumn("id");
       ss.addDisplayColumn("pracName        as [Practitioner]",  true);
       ss.addDisplayColumn("fyName          as [Fiscal Year]",   true);
       ss.addDisplayColumn("groupName       as [Practice]",      true);
       ss.addDisplayColumn("svcPlan         as [Plan]",          true);
       ss.addDisplayColumn("svcName         as [Service]",       true);
       ss.addDisplayColumn("numSvcRecs      as [Services\nEntered]");
       ss.addDisplayColumn("totEstReimburse as [Estimated\nReimbursement]");
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
                               ClaimsRetroactiveForSpa.viewPossibleSelections (
                                   connSpedmon
                                 , log
                                 , uInfo
                                 , Entities.REC_VIEW_TBL
                                 , paged
                                 , pageNumber
                                 , canEdit
                                 , active
                                 , forSpaID
                                 , clientID
                                 , fyID
                                 , authorizedYNU
                                 , dc); 
                             });
   
     /*###########################################################################
       # Add a title and footer to ReturnDataTable then return
       ###########################################################################*/  
               
     so.tableName   = @"Claims for Services Authorized By SPA";
     so.tableFooter = Messages.CONFIDENTIAL;
         
     return so;
     
    }            
 
  }
}

