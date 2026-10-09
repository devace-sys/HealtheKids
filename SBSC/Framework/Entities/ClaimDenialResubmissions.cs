using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;



namespace Spedmon
{

    public class ClaimDenialResubmissions : Entities
    {
      public const string MENU_ID_MANGE_DENIED_CLAIMS      = @"managedeniedclaimslink";
      public const string SEL_LABEL_MANAGE_DENIED_CLAIMS   = @"Manage Denied Claims";      
      public const string URL_SBS_ALL_MANAGE_DENIED_CLAIMS = @"sbs_all_claim_denials_w_reasons.aspx";
      
      /***************************************************************************
       * denialSaveDismissed*/
      /**
       * User has opted to dismiss this denied claim from consideration for
       * resubmission
       **************************************************************************/  

      public static ReturnSaveRecord denialSaveDismissed (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string claimids) {
        return claimDeniedResubmitDispositionSave(connSpedmon, log, uInfo, claimids, "0", "1");
      }

      /***************************************************************************
       * denialSaveResub*/
      /**
       * User has opted to resubmit this denied claim
       **************************************************************************/  

      public static ReturnSaveRecord denialSaveResub (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string claimids) {
        return claimDeniedResubmitDispositionSave(connSpedmon, log, uInfo, claimids, "1", "0");
      }
      
      /***************************************************************************
       * claimDeniedResubmitDispositionSave */
      /**
       * Protected base save method.  Do not call directly
       **************************************************************************/  

      protected static ReturnSaveRecord claimDeniedResubmitDispositionSave (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string claimids, string flaggedForResubmit, string flaggedDismissed) {
          
        bool vResub = Validate.reqFlag(flaggedForResubmit, "error! resubmit?");
        bool vDismissed = Validate.reqFlag(flaggedDismissed, "error! dismiss?");
        List<SqlParameter> parms = new List<SqlParameter>();

        parms.Add(Database.SqlParm("@claimIDs",           SqlDbType.VarChar, claimids,   ParameterDirection.Input, 8000));
        parms.Add(Database.SqlParm("@flaggedForResubmit", SqlDbType.Bit,     vResub,     ParameterDirection.Input));
        parms.Add(Database.SqlParm("@flaggedDismissed",   SqlDbType.Bit,     vDismissed, ParameterDirection.Input));

        return Entities.save(connSpedmon, log, uInfo, "1", "0", "", null, "CLAIM_Denied_Resubmit_Disposition_Save", Messages.DUP_CLIENT_REC, ref parms, null);
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
                                  , defineCols    dc )
    {
    
      string viewUDF = "dbo.CLAIM_Denied_Resubmit_Disposition_View ( @userID, @userGroup, @userRank, @clientID)";
      
      /*###########################################################################
        # Validate parameters specific to this entity view and create their 
        # database parameters
        ###########################################################################*/  
       
      Object  vClientID = Validate.reqClientID (uInfo,  clientID);
      	    
	    List<SqlParameter> parms = new List<SqlParameter>();
                         
      parms.Add(Database.SqlParm("@clientID",                 SqlDbType.BigInt,   vClientID,                    ParameterDirection.Input));  
	    	  
      /*###########################################################################
        # Call base method which handles the rest and return the results
        ###########################################################################*/  
      
      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

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
       # Define our display columns and set the page order.  Page order needs to
       # be in the same sort order as the udf called in the view.
       ###########################################################################*/  

     defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
     {       

       ss.addDisplayColumn("id");
       ss.addDisplayColumn("denialCodeValue          as [Code]");
       ss.addDisplayColumn("denialCodeText           as [Description]");
       ss.addDisplayColumn("patDhcsLastName          as [Patient DHCS LName]");
       ss.addDisplayColumn("patDhcsFirstName         as [Patient DHCS FName]");
       ss.addDisplayColumn("patDOBStr                as [Patient DOB]");
       ss.addDisplayColumn("patSex                   as [Patient Sex]");
       ss.addDisplayColumn("patBIC                   as [Patient BIC]");
       ss.addDisplayColumn("procName                 as [Proc Name]");
       ss.addDisplayColumn("procSvcDateStr           as [Service Date]");
       ss.addDisplayColumn("patID                    as [Patient ID]",     true);
       ss.addDisplayColumn("procProcModCombo         as [Proc Mod Combo]", true);
       ss.addDisplayColumn("claimID                  as [Claim ID]",       true);
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
                             ClaimDenialResubmissions.view (  connSpedmon
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
               
     so.tableName   = @"Denied Claims That Might Be Resubmittable After Correction";
     so.tableFooter = Messages.CONFIDENTIAL;
         
     return so;
     
    }            

    }
}

