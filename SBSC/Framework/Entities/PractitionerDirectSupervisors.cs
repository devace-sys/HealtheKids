using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

/*
 * TODO: The entity class and entities class in this file are partially retired.
 * Need to migrate the methods still in active use.  Then we can fully retire both classes.
 */

namespace Spedmon
{
    
    /***************************************************************************
     * PractitionerDirectSupervisor */
    /**
     * 
     *
     * 
     **************************************************************************/
    public class PractitionerDirectSupervisor: Entity
    {
        public long   clientID;
        public string clientName;
        public long   pracID;
        public string pracName;
        public string supervisingPracDetailsJSON;
    }
    
    /***************************************************************************
     * PractitionerDirectSupervisors */
    /**
     * 
     *
     * 
     **************************************************************************/

    public class PractitionerDirectSupervisors : Entities
    {

      public const string SEL_LABEL               = PractitionerDirectSupervisedSupervisors.SEL_LABEL_MANAGE;
      public const string SEL_LABEL_MANAGE        = PractitionerDirectSupervisedSupervisors.SEL_LABEL_MANAGE;
      public const string SEL_LABEL_ADD_NEW       = @"Add New";
      public const string SEL_LABEL_EDIT          = @"Edit";
      public const string MENU_LINK_MANAGE        = @"pracdirectsupmanagelink";
      public const string URL_USER_ALL_SAVE       = @"user_all_practitioner_direct_supervisor_save.aspx";
      public const string URL_SBS_MANAGE          = @"sbs_all_practitioner_direct_supervision_manage.aspx";
      public const string URL_CLIENT_COOR_MANAGE  = @"client_coor_all_practitioner_direct_supervision_manage.aspx";
      public const string URL_CLIENT_MANAGE       = @"client_all_practitioner_direct_supervision_manage.aspx";

      public static string VAL_FILE_CLASS_PROOF_OF_QUALIFICATIONS    = MBA.StoredFiles.FILE_CLASS_PROOF_OF_QUALIFICATIONS;
      public static string VAL_FILE_NAMESPACE                        = "direct_supervision_tracking";
      public static string VAL_FILE_SOURCE                           = "direct_supervision_save";

         
     /***************************************************************************
      *  isPracSomeoneWhoCanManageDirectSupervisionTracking */
     /**
      * 
      **************************************************************************/  
     public static bool isPracSomeoneWhoCanManageDirectSupervisionTracking (ref RequestResponse rd) {
       if (rd.wu.pr != null) { 
         return rd.wu.pr.isPracSomeoneWhoCanManageDirectSupervisionTracking;   /* Additional checks are performed on back end and results accessed here */
       }
       return false;
     } 

     /***************************************************************************
      * isUserRoleInPermittedRoles
     /**
      * 
      **************************************************************************/  
     
     public static bool isUserRoleInPermittedRoles (string userRoleLower)
     {
       var roleNameLowered = userRoleLower.ToLower();
       return MBA.UserAssignedRoles.userHasPermittedRole(Constants.ROLE_PRAC_DIR_SUP_ADMINS, roleNameLowered);
     }
   
     /***************************************************************************
      * userHasAccess
     /**
      * 
      **************************************************************************/  
     
     public static bool userHasAccess(ref RequestResponse rd)
     {
       if (isUserRoleInPermittedRoles(rd.wu.usr.roleName) == true) {
         if (rd.wu.usr.roleID == Constants.ROLE_LEA_PROVIDER_ID) return isPracSomeoneWhoCanManageDirectSupervisionTracking(ref rd);
         return true;
       }
       return false;
     }

     /***************************************************************************
      * isAllowedUserSomeoneWhoCanManageDirectSupervisionTracking */
     /**
      * 
      **************************************************************************/  
     public static bool isUserSomeoneWhoCanManageDirectSupervisionTracking (UserInfo uInfo) {            
       if (isUserRoleInPermittedRoles(uInfo.userRoleLower) == true)
       { 
         if (uInfo.userRoleID == Constants.ROLE_LEA_PROVIDER_ID) return uInfo.userPracIsPracSomeoneWhoCanManageDirectSupervisionTracking;
         return true;
       }
       return false;
     }
        
     /***************************************************************************
      * verifyIfUserIsSomeoneWhoCanManageDirectSupervisionTracking */
     /**
      * 
      **************************************************************************/  
     public static void verifyIfUserIsSomeoneWhoCanManageDirectSupervisionTracking (UserInfo uInfo) {            
       if (!isUserSomeoneWhoCanManageDirectSupervisionTracking(uInfo)) { 
         throw new MBA.Warning(Messages.ACCESS_DENIED);
       }
     } 
     
    /***************************************************************************
     * doesPracHavePracsAssignedToSuperviseDirectly */
    /**
     * 
     * @param  rd              Current request response object
     * @return                 bool
     ***************************************************************************/

    public static bool doesPracHavePracsAssignedToSuperviseDirectly (ref RequestResponse rd) {
      if (rd.wu.pr != null) {
        if (rd.wu.pr.pracsAssignedToSuperviseDirectlyCount > 0) return true;      
      }
      return false;
    }

    /***************************************************************************
     * doesPracAsDeptHeadHavePracsTheyCanViewSvcRecsFor */
    /**
     * 
     * @param  rd              Current request response object
     * @return                 bool
     ***************************************************************************/
        
    public static bool doesPracAsDeptHeadHavePracsTheyCanViewSvcRecsFor (ref RequestResponse rd)
    {
      if (rd.wu.pr != null) {
        if (rd.wu.pr.pracsAsDeptHeadAllowedToViewSvcRecsCount > 0) return true;      
      }
      return false;
    } 
            
    /***************************************************************************
     * shouldPracSeeServiceRecReviewForNonHS */
    /**
     * 
     * @param  rd              Current request response object
     * @return                 bool
     ***************************************************************************/

    public static bool shouldPracSeeServiceRecReviewForNonHS (ref RequestResponse rd)
    {      
      if (rd.wu.pr.stdSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES) return false; /* If this is a HS prac exit */
      if (PractitionerDirectSupervisors.doesPracHavePracsAssignedToSuperviseDirectly(ref rd)) return true;   /* If supervising prac has pracs assigned then yes */
      if (PractitionerDirectSupervisors.doesPracAsDeptHeadHavePracsTheyCanViewSvcRecsFor(ref rd)) return true; /* If this prac is a dept head and they are allowed access */      
      return false;
    }

     /***************************************************************************
      * save */
     /**
      * Save 
      * 
      ***************************************************************************/   
  
      public static ReturnSaveRecord save (   SqlConnection connSpedmon
                                            , DetailsLog    log
                                            , UserInfo      uInfo
                                            , string        clientID
                                            , string        pracID
                                            , string        supervisingPracsDetailsJSON
                                            , string        saveType
                                            , string        validateRec
                                            , string        editDelReason
                                            , string        recID )
      {           
    
        /*----------------------------
         * Validate parameters specific
         * to this entity.save
         * and populate their
         * coresponding database
         * parameters
         *----------------------------*/
        
       string saveSproc = "PRACTITIONER_DIRECT_SUPERVISORS_SAVE";                
		   
       long      vClientID                     = Validate.reqClientID ( uInfo, clientID);
       long      vPracID                       = Validate.reqInteger  ( pracID, Messages.INVALID_PRAC_ID);
		   string    vSupervisingPracDetailsJSON   = Validate.optString   ( supervisingPracsDetailsJSON, @"Invalid Details");
                
       List<SqlParameter> parms = new List<SqlParameter>();  

 		   parms.Add(Database.SqlParm( "@clientID",                      SqlDbType.BigInt,    vClientID,                        ParameterDirection.Input) );
 		   parms.Add(Database.SqlParm( "@pracID",                        SqlDbType.BigInt,    vPracID,                          ParameterDirection.Input) );
       parms.Add(Database.SqlParm( "@supervisingPracDetailsJSON",    SqlDbType.VarChar,   vSupervisingPracDetailsJSON,      ParameterDirection.Input, -1) );
                
       /*----------------------------
        * Call base method which 
        * handles the rest and return
        * results
        *----------------------------*/  

       ReturnSaveRecord so = Entities.save (   connSpedmon
                                             , log
                                             , uInfo
                                             , saveType
                                             , validateRec
                                             , editDelReason
                                             , recID
                                             , saveSproc
                                             , @"A supervision tracking record already exists for this practitioner"
                                             , ref parms
                                             , delegate(){});
                                                                                       
    
       return so;

    }

    /*************************************************************************
     * view */
    /**
     *
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
                                  , defineCols    dc )
    {
      
      string viewUDF = "dbo.PRACTITIONER_DIRECT_SUPERVISORS_VIEW (@userID, @userGroup, @userRank, @clientID, @active, @recID)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      var vClientID = Validate.reqClientID (uInfo, clientID);

      var parms = new List<SqlParameter>();   
      
      parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      
      
    }
        
    /*************************************************************************
     * load */
    /**
     *
     * 
     **************************************************************************/   

    public static PractitionerDirectSupervisor load (   SqlConnection connSpedmon
                                  , DetailsLog    log
                                  , UserInfo      uInfo
                                  , string        clientID
                                  , string        recID)
    {
      

        return (PractitionerDirectSupervisor) Entities.load (  connSpedmon
                                                      , log
                                                      , uInfo
                                                      , recID
                                                      , typeof(PractitionerDirectSupervisor)
                                                      , delegate { 
                                                          return PractitionerDirectSupervisors.view ( connSpedmon
                                                                                                , log
                                                                                                , uInfo
                                                                                                , Entities.REC_VIEW_LOAD                                                                                               
                                                                                                , false
                                                                                                , recID
                                                                                                , ""
                                                                                                , ""
                                                                                                , clientID
                                                                                                , null );});
        
        
        
      
    }
    
    /***************************************************************************
     * loadInitial */
    /**
     * Initial data for new record
     * 
     ***************************************************************************/

    public static PractitionerDirectSupervisor loadInitialData (  SqlConnection connSpedmon
                                                                , DetailsLog    log
                                                                , UserInfo      uInfo
                                                                , string        clientID )
    {
      var so = new PractitionerDirectSupervisor();
     
     /*###########################################################################
       # We need to get the client id for client users because we call the client
       # load method.  Practi-cal users pass the client ID (which is required)
       # so this helps validate that.
       ###########################################################################*/  

      var vClientID = Validate.reqClientID (uInfo, clientID);
      clientID = vClientID.ToString();

      var clc = Clients.load(connSpedmon,log,uInfo,clientID);

      so.clientID   = clc.id;
      so.clientName = clc.name;
      so.pracID     = 0;
      so.pracName   = "";
      so.supervisingPracDetailsJSON = "[]";

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
                                           , string        canEdit
                                           , string        active )
   {
     ReturnDataTable so = new ReturnDataTable();
     
     /*###########################################################################
       # We need to get the client id for client users because we call the client
       # load method.  Practi-cal users pass the client ID (which is required)
       # so this helps validate that.
       ###########################################################################*/  

     var vClientID = Validate.reqClientID (uInfo, clientID);
     clientID = vClientID.ToString();

     /*###########################################################################
       # Define our display columns and set the page order.  Page order needs to
       # be in the same sort order as the udf called in the view.
       ###########################################################################*/  

     defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
     {       
       ss.addDisplayColumn("id");   
       ss.addDisplayColumn("name                      as [Staff Being Supervised]",        true);
       ss.addDisplayColumn("supervisingPracDetailsStr as [Supervisor Name]");
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
                             PractitionerDirectSupervisors.view (  connSpedmon
                                                                 , log
                                                                 , uInfo
                                                                 , Entities.REC_VIEW_TBL
                                                                 , paged
                                                                 , pageNumber
                                                                 , canEdit
                                                                 , active
                                                                 , clientID
                                                                 , dc); 
                            });
   
     /*###########################################################################
       # Add a title and footer to ReturnDataTable then return
       ###########################################################################*/  
               
     var clc = Clients.load(connSpedmon,log,uInfo,clientID);

     so.tableName   = clc.name + @" - " + SEL_LABEL;
     so.tableFooter = Messages.CONFIDENTIAL;
         
     return so;
     
    }            
      
    }
}
