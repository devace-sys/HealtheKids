using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;
 
namespace Spedmon
{    
    
  /***************************************************************************
   * MissingServicesTreatmentCommon */
  /**
   * Common static methods
   **************************************************************************/  
    
  public class MissingServicesTreatmentsCommon 
  {

    public const string SEL_LABEL              = @"Missing Promised Services";
    public const string SEL_LABEL_IEP_IFSP     = @"Missing IEP/IFSP Services";
    public const string SEL_LABEL_NON_IEP_IFSP = @"Missing Non IEP/IFSP Services";

    public const string URL_WEB_REPORT     = @"missing_services_treatment.ashx";
    
    /***************************************************************************
     * showPotentialLostReimburseAmountToUser */
    /**
     * Can we show this amount to this user
     **************************************************************************/  
    
    public static bool showPotentialLostReimburseAmountToUser (UserInfo uInfo)
    {
       return ((IList)Constants.ROLE_ADMIN_CONSULTANT_LEA_COORD).Contains(uInfo.userRole.ToLower());
    }

    /***************************************************************************
     * addAndSetCommonUdfParms */
    /**
     * 
     **************************************************************************/  
    
    public static void addAndSetCommonUdfParms (  UserInfo uInfo
                                                , string   clientID
                                                , string   groupServiceClassNameID
                                                , string   spEdServiceCode
                                                , string   orpDocID
                                                , string   svcTrackingClass
                                                , string   leaBopOnlyOrAllSped          
                                                , ref List<SqlParameter> parms )
	{
       var    vClientID               = Validate.reqClientID               (uInfo, clientID);
       var    vGroupSvcClassNameID    = Validate.optStdGroupSvcClassNameID (uInfo, groupServiceClassNameID);
       Object vSpEdServiceCode        = Validate.optInteger (spEdServiceCode,     @"Invalid SpEd Service Code");
       Object vOrpDocID               = Validate.optInteger (orpDocID,            @"Invalid orp doc id");
       Object vSvcTrackingClass       = Validate.optInteger (svcTrackingClass,    @"Invalid service tracking class");
       string vLeaBopOnlyOrAllSped    = Validate.optString  (leaBopOnlyOrAllSped, @"Invalid selection");

       /* Show just Medi-cal elibible patients and billable services or show all patients and all services */

       if (String.IsNullOrWhiteSpace(vLeaBopOnlyOrAllSped)) vLeaBopOnlyOrAllSped = Constants.SPED_LEA_BOP_ONLY;

       Object vMcalPatients = null;
       Object vLeaBopSvc    = null;
       Object vMissingTmt   = true;

       if (vLeaBopOnlyOrAllSped == Constants.SPED_LEA_BOP_ONLY) 
       {
         vMcalPatients = true;
         vLeaBopSvc    = true;
       }
       else if (vLeaBopOnlyOrAllSped == Constants.SPED_ALL_SPED)
       {
         vMcalPatients = null;
         vLeaBopSvc    = null;
       }
       else
       {
         vMcalPatients = null;
         vLeaBopSvc    = null;
       }
       
       parms.Add(Database.SqlParm("@clientID",            SqlDbType.BigInt, vClientID,            ParameterDirection.Input));
       parms.Add(Database.SqlParm("@groupSvcClassNameID", SqlDbType.BigInt, vGroupSvcClassNameID, ParameterDirection.Input));
       parms.Add(Database.SqlParm("@spEdServiceCode",     SqlDbType.Int,    vSpEdServiceCode,     ParameterDirection.Input));
       parms.Add(Database.SqlParm("@orpDocID",            SqlDbType.BigInt, vOrpDocID,            ParameterDirection.Input));
       parms.Add(Database.SqlParm("@svcTrackingClass",    SqlDbType.Int,    vSvcTrackingClass,    ParameterDirection.Input));
       parms.Add(Database.SqlParm("@mcalPatients",        SqlDbType.Bit,    vMcalPatients,        ParameterDirection.Input));
       parms.Add(Database.SqlParm("@leaBopSvc",           SqlDbType.Bit,    vLeaBopSvc,           ParameterDirection.Input));
       parms.Add(Database.SqlParm("@missingTmt",          SqlDbType.Bit,    vMissingTmt,          ParameterDirection.Input));
            
     }

     /***************************************************************************
      * URL_WEB_REPORT_BASE */
     /**
      * 
      **************************************************************************/  
     public static string URL_WEB_REPORT_BASE()
     { 
        return MBA.HttpApplication.createLink(MissingServicesTreatmentsCommon.URL_WEB_REPORT, true);
     }

 
  }
}