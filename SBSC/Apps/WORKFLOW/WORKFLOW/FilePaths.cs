using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WORKFLOW
{
    /***************************************************************************
     * Contains various constants for file paths
     ***************************************************************************/ 
    class FilePaths
    {
     /*-------------------------------
      * Application File Paths
      *------------------------------*/
        public static string PATH_Archive          = SBSCParent.oldpath  + @"08 Archive\Scans\";
        public static string PATH_WorkinProcess    = SBSCParent.oldpath  + @"Work in Process\";
        public static string PATH_SafetyCopies     = SBSCParent.oldpath  + @"SafetyCopies\";
        public static string PATH_QuestionForms    = SBSCParent.oldpath  + @"0 A&I Folders\03 Question Forms From MBA to Give to District Representatives\";
        public static string PATH_NotBillableForms = SBSCParent.oldpath  + @"0 A&I Folders\02 Not Billable Files From MBA to Give to District Representatives\";
        public static string PATH_FinishedClaims   = SBSCParent.oldpath  + @"09 Finished Claims\";
        public static string PATH_CIS              = SBSCParent.oldpath  + @"CIS\";
        public static string PATH_SplitFiles       = SBSCParent.oldpath  + @"SplitFiles\";
        public static string PATH_STAFF_FOLDER     = SBSCParent.oldpath  + @"STAFF_FOLDERS\";
        public static string PATH_Deleted          = SBSCParent.oldpath  + @"DeletedFiles\";
        public static string PATH_FilledForms      = SBSCParent.oldpath  + @"Temp\FilledForms\";
        public static string PATH_Template_QForm   = SBSCParent.oldpath  + @"FormTemplates\QuestionForm.pdf";
        public static string PATH_Template_NBslip  = SBSCParent.oldpath  + @"FormTemplates\NOT BILLABLE slip.pdf";
        public static string PATH_Help             = SBSCParent.oldpath  + @"HelpFiles\Workflow.chm";
        public static string PATH_Images           = SBSCParent.oldpath  + @"Images\";
        public static string PATH_Training_Record  = SBSCParent.oldpath  + @"STAFF-TRAINING-RECORDS\";
        public static string PATH_Staff_Schedule   = SBSCParent.oldpath  + @"STAFF-Schedule\";
        public static string PATH_AnI_Reports      = SBSCParent.rptAnIpath + @"A&I Weekly Report\Reports Sent\";
        public static string PATH_WFSummaryRpt     = SBSCParent.basePath   + @"0 Archive\z SBSC Weekly Report from E\WorkflowSummaryReports\";
    }  

}
