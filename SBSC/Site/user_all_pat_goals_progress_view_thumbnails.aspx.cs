using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Text;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * userAllPatGoalsProgressViewThumbnails */
    /**
     ***************************************************************************/

    public class userAllPatGoalsProgressViewThumbnails : WebUI
    {
        public userAllPatGoalsProgressViewThumbnails() : base(@"user_all_pat_goal_progress_view"
                                             , "Goal Progress"
                                             , @"user_all_patient_goal_progress_reporting_thumbnails.css"
                                             , @"user_all_patient_goal_progress_reporting_thumbnails.js"
                                             , Constants.ROLE_PATIENT_GOALS)
        { 
		  
        }

        public List<PatientGoalsProgressViewItem> progressItems = new List<PatientGoalsProgressViewItem>();
        protected void Page_Load(object sender, EventArgs e)
        {
          string clientID              = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
          string patID                 = MBA.HttpApplication.getParameter(Constants.PARM_PATIENT_ID);
          string groupSvcClassNameID   = MBA.HttpApplication.getParameter(Constants.PARM_GRP_SVC_CLS_NME_ID);
            
        
          progressItems = Spedmon.PatientGoalsProgressIndividualGoals.viewItems ( dbConnApp
                                                                                 , log
                                                                                 , uInfo
                                                                                 , clientID
                                                                                 , patID
                                                                                 , groupSvcClassNameID
                                                                                 , "");

        }
}
}