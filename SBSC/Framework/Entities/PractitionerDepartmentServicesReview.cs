using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using MBA;


namespace Spedmon
{
    
    /***************************************************************************
     * PractitionerDepartmentServicesReview */
    /**
     ***************************************************************************/

    public class PractitionerDepartmentServicesReview
    {
        public const string SEL_LABEL          = @"Department Services Review";
        public const string URL_REST_VIEW_BASE = @"api/v1/practitionersefficiency";
        public const string MENU_ID            = @"pracdeptsvcsreviewlnk";
        public const string BODY_ID            = @"pracdeptsvcsreview";
        public const string URL_USER_ALL_RPT   = @"user_all_department_services_review.aspx";
    }
}
