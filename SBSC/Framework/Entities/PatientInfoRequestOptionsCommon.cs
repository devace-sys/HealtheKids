using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA.Reporting;
using MBA;


namespace Spedmon
{
   
   /**************************************************************************
    * PatientInfoRequestOptionsCommon */
   /**
    * 
    * 
    ***************************************************************************/
	
    public class PatientInfoRequestOptionsCommon
    {
        public const string SEL_LABEL_INSURANCE_OPTION_MANAGE    = @"Insurance Messages";
		public const string URL_REQUEST_FORM_OPTIONS_MANAGE_BASE = @"user_all_student_info_request_form_options_manage.aspx";

		
       /***************************************************************************
         * URL_REQUEST_FORM_OPTION_MANAGE */
        /**
         * 
         **************************************************************************/
		 
        public static string URL_REQUEST_FORM_OPTIONS_MANAGE (string clientID)
        {
            return MBA.HttpApplication.createLink (  URL_REQUEST_FORM_OPTIONS_MANAGE_BASE
                                                   , true
                                                   , new NameValue(Constants.PARM_CLIENT_ID, clientID)
                                                   );
        }

      
        /***************************************************************************
         * userCanAccessCombinedManageScreen */
        /** 
         **************************************************************************/

        public static bool userCanAccessCombinedManageScreen (RequestResponse rd)
        {
            var roleNameLowered = rd.wu.usr.roleName.ToLower();            
            return MBA.UserAssignedRoles.userHasPermittedRole(Constants.ROLE_MANAGE_PATIENT_INFO_REQUEST_OPTIONS, roleNameLowered);
        }


    }
}