using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;
 
namespace Spedmon
{    
   /**************************************************************************
    * PracticeOfficeKioskPublic */
   /**    
    *
    ***************************************************************************/

  public class PracticeOfficeKioskPublic
  {
    public bool     recFound = false;
    public long     id;
    public string   kioskName;
    public string   clientName;
    public string   siteName;
    public string   practiceName;
    public TimeSpan startTime;
    public TimeSpan endTime;
    public string   startTimeStr;
    public string   endTimeStr;
    public string   clientLogoFileBase64;
    public long     groupSvcClassNameID;
    public long     siteID;
    public long     clientID;
  }

   /**************************************************************************
    * PracticeOfficeCommon */
   /**
    * Methods that are common to all classes related to practice offices
    * but are not appropriate to place in a base class.
    ***************************************************************************/
  public class PracticeOfficeCommon 
  {
    public const string SEL_LABEL                               = @"Health Offices"; /* Was Health e Kids */
    public const string SEL_LABEL_HEALTH_SERVICES_BASE          = @"Health Services";
    public const string SEL_LABEL_MENTAL_HEALTH_SERVICES_BASE   = @"Mental Health Services";
    public const string SEL_LABEL_MANAGE_VISIT_REASONS_BASE     = @"Manage Visit Reasons";
    public const string SEL_LABEL_MANAGE_KIOSKS_BASE            = @"Manage Kiosks";
    public const string SEL_LABEL_WAITING_ROOM_BASE             = @"Waiting Room";
    public const string SEL_LABEL_MANAGE_COMPLETED_VISITS_BASE  = @"Manage Completed Visits";
    public const string SEL_LABEL_PATIENT_VISIT_MANAGE_BASE     = @"Patient Visit";
    public const string SEL_LABEL_MANAGE_VISIT_RESOLUTIONS_BASE = @"Manage Visit Resolutions";

    public const string BODY_ID_KIOSK                     = @"userallpracticeofficekioskpage";
    public const string URL_KIOSK_MANAGE_BASE             = @"user_all_practice_office_kiosks_manage.aspx";
    public const string URL_KIOSK_BASE                    = @"user_all_practice_office_kiosk.aspx";
    public const string URL_WAITING_ROOM_MANAGE_BASE      = @"user_all_practice_office_waiting_room_manage.aspx";
    public const string URL_PATIENT_VISIT_MANAGE_BASE     = @"user_all_practice_office_patient_visit_manage.aspx";
    public const string URL_COMPLETED_VISITS_MANAGE_BASE  = @"user_all_practice_office_completed_visits_manage.aspx";
    
    public const string URL_VISIT_REASONS_MANAGE_BASE     = @"sbs_all_practice_office_visit_reasons_manage.aspx";
    public const string URL_KIOSK_PUBLIC_BASE             = @"practice_office_public_check_in.aspx";
    public const string URL_VISIT_RESOLUTIONS_MANAGE_BASE = @"sbs_all_practice_office_visit_resolutions_manage.aspx";

    public const string PRACTICE_OFFICE_VISIT_SOURCE_WAITING_ROOM                    = @"1";
    public const string PRACTICE_OFFICE_VISIT_SOURCE_PATIENT_PROFILE                 = @"2";
    public const string PRACTICE_OFFICE_VISIT_SOURCE_PATIENT_PROFILE_MANAGE_PATIENTS = @"3";

        /***************************************************************************
         * getPracticeOfficeKioskByPtkn */
        /**
         *
         **************************************************************************/
        public static PracticeOfficeKioskPublic getPracticeOfficeKioskByPtkn (  SqlConnection connSpedmon
                                                                          , DetailsLog  log                                                                    
                                                                          , string      ptkn )
    {
            
      PracticeOfficeKioskPublic rec = new PracticeOfficeKioskPublic();          
      string vPtkn = Validate.reqString(ptkn,@"Invalid token");
      var parms = new List<SqlParameter>();
      parms.Add(Database.SqlParm("@ptkn", SqlDbType.VarChar, vPtkn, ParameterDirection.Input, 500));
      string sql = "select top 1 * from dbo.PRACTICE_OFFICE_KIOSK_GET_BY_PTKN (@ptkn)";
      ReturnDB rd = Database.execQuery(connSpedmon, log, sql, false, parms);
      if (rd.hasRecords == false) {
        rec.recFound = false;
        return rec;
      }
      rec = (PracticeOfficeKioskPublic) Database.convertRecord(rd.records, typeof(PracticeOfficeKioskPublic));
      rec.recFound = true;
      return rec;
    }
   
   /**************************************************************************
    * userHasAccessToPracticeOffices */
   /**
    * Returns true if user can access 
    ***************************************************************************/         
   public static bool userHasAccessToPracticeOffices (RequestResponse rd)
   {
     if (rd.wu.usr.pcalStaff == true) {
       return true;
     }
     else {       
       if (rd.wu.usr.roleID == Constants.ROLE_LEA_PROVIDER_ID) {
         if (rd.wu.pr.stdSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES) {
           return true;
         }
         else if (rd.wu.pr.stdSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_MENTAL_HEALTH_SERVICES)
         {
           return false; /* TODO: Set to true once we have this practice family supported*/
         }
         return false;
       }
       else if (rd.wu.usr.roleID == Constants.ROLE_LEA_COORDINATOR_ID) {
         return true;
       }
       else { 
         return false;
       }
     }   
   }

   /**************************************************************************
    * userHasAccessToHealthServicesPracticeOffice */
   /**
    * Returns true if user can access 
    ***************************************************************************/         
   public static bool userHasAccessToHealthServicesPracticeOffice (RequestResponse rd)
   {
     if (rd.wu.usr.pcalStaff == true) {
       return true;
     }
     else {       
       if (rd.wu.usr.roleID == Constants.ROLE_LEA_PROVIDER_ID) {
         if (rd.wu.pr.stdSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES) {
           return true;
         }
         return false;
       }
       else if (rd.wu.usr.roleID == Constants.ROLE_LEA_COORDINATOR_ID) {
         return true;
       }
       else { 
         return false;
       }
     }   
   }
   
   /**************************************************************************
    * userHasAccessToManagePracticeOfficeVisitResolutions */
   /**
    * Returns true if user can access 
    ***************************************************************************/
   public static bool userHasAccessToManagePracticeOfficeVisitResolutions (RequestResponse rd)
   {
     if (rd.wu.usr.pcalStaff == true)
     {
       return true;
     }
     return false;
   }

   /**************************************************************************
    * userHasAccessToManageHealthServicesPracticeOfficeVisitReasons */
   /**
    * Returns true if user can access 
    ***************************************************************************/
   public static bool userHasAccessToManageHealthServicesPracticeOfficeVisitReasons (RequestResponse rd)
   {
     if (rd.wu.usr.pcalStaff == true) {
       return true;
     }
     return false;
   }

   /**************************************************************************
    * userHasAccessToManageHealthServicesPracticeOfficeKiosks */
   /**
    * Returns true if user can access 
    ***************************************************************************/         
   public static bool userHasAccessToManageHealthServicesPracticeOfficeKiosks (RequestResponse rd)
   {
     if (rd.wu.usr.pcalStaff == true) {
       return true;
     }
     else {       
       if (rd.wu.usr.roleID == Constants.ROLE_LEA_PROVIDER_ID) {
         if (rd.wu.pr.stdSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES) {
           return true;
         }
         return false;
       }
       else if (rd.wu.usr.roleID == Constants.ROLE_LEA_COORDINATOR_ID) {
         return true;
       }
       else { 
         return false;
       }
     }  
   }
   
   /**************************************************************************
    * URL_KIOSK_PUBLIC */
   /**
    * Returns url for kiosk based on groupSvcClassNameID
    ***************************************************************************/
    public static string URL_KIOSK_PUBLIC ()
    {
      return MBA.HttpApplication.createLink ( URL_KIOSK_PUBLIC_BASE
                                             , false
                                             , new NameValue(Constants.PARM_PUBLIC_TOKEN,@""));
    }

   /**************************************************************************
    * URL_KIOSK_MANAGE */
   /**
    * Returns url for kiosk manage screen based on groupSvcClassNameID
    ***************************************************************************/
    public static string URL_KIOSK_MANAGE (long groupSvcClassNameID)
    {
      return MBA.HttpApplication.createLink ( URL_KIOSK_MANAGE_BASE
                                             , true
                                             , new NameValue(Constants.PARM_GRP_SVC_CLS_NME_ID,groupSvcClassNameID));
    }

   /**************************************************************************
    * URL_WAITING_ROOM_MANAGE */
   /**
    * Returns url for waiting room based on groupSvcClassNameID
    ***************************************************************************/

    public static string URL_WAITING_ROOM_MANAGE (long groupSvcClassNameID)
    {
      return MBA.HttpApplication.createLink ( URL_WAITING_ROOM_MANAGE_BASE
                                             , true                                             
                                             , new NameValue(Constants.PARM_GRP_SVC_CLS_NME_ID,groupSvcClassNameID));
    }

   /**************************************************************************
    * URL_PATIENT_VISIT_MANAGE */
   /**
    * Returns url for patient visit manage.  Rest of URL is built later.
    ***************************************************************************/
    public static string URL_PATIENT_VISIT_MANAGE ()
    {
      return MBA.HttpApplication.createLink ( URL_PATIENT_VISIT_MANAGE_BASE
                                             , true                                             
                                             );
    }

   /**************************************************************************
    * URL_COMPLETED_VISITS_MANAGE */
   /**
    * Returns url for completed visits manage based on groupSvcClassNameID
    ***************************************************************************/
    public static string URL_COMPLETED_VISITS_MANAGE (long groupSvcClassNameID)
    {
      return MBA.HttpApplication.createLink ( URL_COMPLETED_VISITS_MANAGE_BASE
                                             , true
                                             , new NameValue(Constants.PARM_GRP_SVC_CLS_NME_ID,groupSvcClassNameID)
                                             );
    }

   /**************************************************************************
    * URL_VISIT_REASONS_MANAGE */
   /**
    * Returns url for managing visit reasons based on groupSvcClassNameID
    * This includes form builder data
    ***************************************************************************/
    public static string URL_VISIT_REASONS_MANAGE (long groupSvcClassNameID)
    {
      return MBA.HttpApplication.createLink ( URL_VISIT_REASONS_MANAGE_BASE
                                             , true
                                             , new NameValue(Constants.PARM_GRP_SVC_CLS_NME_ID,groupSvcClassNameID)
                                             );
    }

   /**************************************************************************
    * URL_VISIT_RESOLUTIONS_MANAGE*/
   /**
    * Returns url for managing visit resolutions
    * This includes form builder data
    ***************************************************************************/
    public static string URL_VISIT_RESOLUTIONS_MANAGE ()
    {
      return MBA.HttpApplication.createLink ( URL_VISIT_RESOLUTIONS_MANAGE_BASE
                                             , true                                             
                                             );
    }

    /**************************************************************************
    * MENU_LNK_KIOSK_MANGE */
   /**
    * Returns menu lnk id for kiosk manage screen based on groupSvcClassNameID
    ***************************************************************************/
    public static string MENU_LNK_KIOSK_MANAGE (long groupSvcClassNameID)
    {
      if (groupSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_MENTAL_HEALTH_SERVICES) { 
        return @"practiceofficekioskmanagementalhealthserviceslnk";
      }
      else if (groupSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES) 
      {
        return "practiceofficekioskmanagehealthserviceslnk";
      }
      else return "practiceofficekioskmanagelnk";
    }
   
   /**************************************************************************
    * MENU_LNK_WAITING_ROOM */
   /**
    * Returns menu lnk id for waiting room based on groupSvcClassNameID
    ***************************************************************************/

    public static string MENU_LNK_WAITING_ROOM (long groupSvcClassNameID)
    {
      if (groupSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_MENTAL_HEALTH_SERVICES) { 
        return @"practiceofficewaitingroommentalhealthserviceslnk";
      }
      else if (groupSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES) 
      {
        return "practiceofficewaitingroomhealthserviceslnk";
      }
      else return "practiceofficewaitingroomlnk";
    }
   
   /**************************************************************************
    * MENU_LNK_WAITING_ROOM */
   /**
    * Returns menu lnk id for waiting room based on groupSvcClassNameID
    ***************************************************************************/
    public static string MENU_LNK_COMPLETED_VISITS (long groupSvcClassNameID)
    {
      if (groupSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_MENTAL_HEALTH_SERVICES) { 
        return @"practiceofficecompletedvisitsmanagementalhealthserviceslnk";
      }
      else if (groupSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES) 
      {
        return "practiceofficecompletedvisitsmanagehealthserviceslnk";
      }
      else return "practiceofficecompletedvisitsmanagelnk";
    }
   /**************************************************************************
    * MENU_LNK_VISIT_REASONS_MANAGE */
   /**
    * Returns menu lnk id for managing reasons based on groupSvcClassNameID
    ***************************************************************************/
    public static string MENU_LNK_VISIT_REASONS_MANAGE (long groupSvcClassNameID)
    {
      if (groupSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_MENTAL_HEALTH_SERVICES) { 
        return @"practiceofficevisitreasonsmentalhealthservicessmanagelnk";
      }
      else if (groupSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES) 
      {
        return "practiceofficevisitreasonsmentalhealthservicessmanagelnk";
      }
      else return "practiceofficevisitreasonsmanagelnk";
    }

   /**************************************************************************
    * MENU_LNK_VISIT_RESOLUTIONS_MANAGE */
   /**
    * Returns menu lnk id for managing reasons based on groupSvcClassNameID
    ***************************************************************************/
    public static string MENU_LNK_VISIT_RESOLUTIONS_MANAGE()
    {
      return @"practiceofficevisitresolutionsmanagelnk";
    }

   /**************************************************************************
    * SEL_LABEL_KIOSK_MANAGE */
   /**
    * Returns selection label/page title for kiosk manage screen 
    * based on groupSvcClassNameID
    ***************************************************************************/
    public static string SEL_LABEL_KIOSK_MANAGE (long groupSvcClassNameID, bool includeSelLabel)
    {
      
      string label;

      if (groupSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_MENTAL_HEALTH_SERVICES) { 
        label = SEL_LABEL_MANAGE_KIOSKS_BASE;
      }
      else if (groupSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES) 
      {
        label = SEL_LABEL_MANAGE_KIOSKS_BASE;
      }
      else
      { 
        label = SEL_LABEL_MANAGE_KIOSKS_BASE;    
      }
      if (includeSelLabel) label = SEL_LABEL + @" - " + label;
      return label;
    }

    /**************************************************************************
     * SEL_LABEL_WAITING_ROOM */
    /**
     * Returns selection label/page title for waiting room based on 
     * groupSvcClassNameID
     ***************************************************************************/
    public static string SEL_LABEL_WAITING_ROOM (long groupSvcClassNameID, bool includeSelLabel)
    {
      string label;

      if (groupSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_MENTAL_HEALTH_SERVICES) { 
        label = SEL_LABEL_WAITING_ROOM_BASE;
      }
      else if (groupSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES) 
      {
        label = SEL_LABEL_WAITING_ROOM_BASE;
      }
      else
      { 
        label = SEL_LABEL_WAITING_ROOM_BASE;    
      }
      if (includeSelLabel) label = SEL_LABEL + @" - " + label;
      return label;
    }

    /**************************************************************************
     * SEL_LABEL_COMPLETED_VISITS */
    /**
     * Returns selection label/page title for completed visits based on 
     * groupSvcClassNameID
     ***************************************************************************/
    public static string SEL_LABEL_COMPLETED_VISITS (long groupSvcClassNameID, bool includeSelLabel)
    {

      string label;

      if (groupSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_MENTAL_HEALTH_SERVICES) { 
        label = SEL_LABEL_MANAGE_COMPLETED_VISITS_BASE;
      }
      else if (groupSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES) 
      {
        label = SEL_LABEL_MANAGE_COMPLETED_VISITS_BASE;
      }
      else
      { 
        label = SEL_LABEL_MANAGE_COMPLETED_VISITS_BASE;    
      }
      if (includeSelLabel) label = SEL_LABEL + @" - " + label;
      return label;
    }

    /**************************************************************************
     * SEL_LABEL_VISIT_REASONS_MANAGE */
    /**
     * Returns selection label/page title for visit reasons manage based on 
     * groupSvcClassNameID
     ***************************************************************************/
    public static string SEL_LABEL_VISIT_REASONS_MANAGE (long groupSvcClassNameID, bool includeSelLabel)
    {              

      string label;

      if (groupSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_MENTAL_HEALTH_SERVICES) { 
        label = SEL_LABEL_MANAGE_VISIT_REASONS_BASE;
      }
      else if (groupSvcClassNameID == Constants.GROUP_SERVICE_CLASS_NAME_ID_HEALTH_SERVICES) 
      {
        label = SEL_LABEL_MANAGE_VISIT_REASONS_BASE;
      }
      else
      { 
        label = SEL_LABEL_MANAGE_VISIT_REASONS_BASE;    
      }

      if (includeSelLabel) label = SEL_LABEL + @" - " + label;
      return label;  
    }

        /**************************************************************************
         * SEL_LABEL_VISIT_RESOLUTIONS_MANAGE */
        /**
         * Returns selection label/page title          
         ***************************************************************************/
        public static string SEL_LABEL_VISIT_RESOLUTIONS_MANAGE (bool includeSelLabel)
        {

            string label = SEL_LABEL_MANAGE_VISIT_RESOLUTIONS_BASE;

            if (includeSelLabel) label = SEL_LABEL + @" - " + label;
            return label;
        }
    }
}