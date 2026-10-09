/*
 * TODO: This entity has been retired.  Refactor to remove.
 */

using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * CYBHIHoldMissingInfoPat */
    /**
     * Represents an individual CYBHI Hold Missing Info Patient record
     ***************************************************************************/
    public class CYBHIHoldMissingInfoPat : PatientWithMissingInfo
    {
    }

    /***************************************************************************
     * CYBHIHoldsMissingInfoPats */
    /**
     * Manages operations related to CYBHI Holds Patient Missing Info
     ***************************************************************************/
    public class CYBHIHoldsMissingInfoPats : Entities
    {
        //public const string URL_MANAGE_HOLDS     = @"user_all_cybhi_holds_manage.aspx";
     
        public const string URL_REST_VIEW        = @"api/v1/cybhiholdsmissinginfopats";

        //public const string URL_ASHX = @"cybhiholds_missing_info_pats.ashx";

/*        public const string URL_WEB_SERVICE = @"cybhiholds_missing_info_pats.asmx";
        public const string URL_GET_SUMS = URL_WEB_SERVICE + @"/getCYBHIHoldsMissingInfoSums";*/

        /***************************************************************************
         * URL_REST_VIEW_BASE */
        /**
         * Returns the base URL for the REST view
         ***************************************************************************/
        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(URL_REST_VIEW, true);
        }

        /***************************************************************************
         * URL_SVC_GET_SUMS */
        /**
         * Returns the URL for getting sums
         ***************************************************************************/
/*        public static string URL_SVC_GET_SUMS()
        {
            return MBA.HttpApplication.createLink(URL_GET_SUMS, true);
        }
*/
        /*public static string URL_MANAGE_HOLDS_BASE()
        {
            return MBA.HttpApplication.createLink(URL_MANAGE_HOLDS, true);
        }*/

      /*  public static string URL_ASHX_BASE()
        {
            return MBA.HttpApplication.createLink(URL_ASHX, true);
        }
*/
        /***************************************************************************
         * viewObjects */
        /**
         * Returns a list of CYBHIHoldMissingInfoPat objects
         ***************************************************************************/
        public static ReturnObjects viewObjects ( SqlConnection connSpedmon
                                                 , DetailsLog  log
                                                 , UserInfo    uInfo
                                                 , bool        pageObjectList
                                                 , string      pageOrder
                                                 , string      idx
                                                 , string      active
                                                 , string      clientID
                                                 , string      patID
                                                 , string      missingInsuranceInfo
                                                 , string      missingAddressInfo
                                                 , string      missingFerpaConsent
                                                 , string      missingPGEmails                                  
                                                 , string      hasPrevInfoRqstThatReqRvw ) 
        {
            return PatientsWithMissingInfo.viewObjects(connSpedmon,log,uInfo,pageObjectList,pageOrder,idx,active,clientID,patID,"1",missingInsuranceInfo, missingAddressInfo, missingFerpaConsent, missingPGEmails, "", "", "", hasPrevInfoRqstThatReqRvw);
        }
    }
}

