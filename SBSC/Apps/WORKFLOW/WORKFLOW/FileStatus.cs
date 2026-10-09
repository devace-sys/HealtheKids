using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WORKFLOW
{
    class FileStatus
    {
        /***************************************************************************
         * Various constants File statuses
         ***************************************************************************/
        public const int ReadytoBatch        = 10;
        public const int PrescreenPENDING    = 30;
        public const int ReadytoAssign       = 50;
        public const int assignedInput       = 60;
        public const int inputStarted        = 70;
        public const int ReviewQuestionForm  = 80;
        public const int ReviewNotBillable   = 85;
        public const int CIS                 = 90;
        public const int ReviewInputComplete = 100;
        public const int ReviewStarted       = 110;
        public const int Retrain             = 130;
        public const int FinishedClaims      = 200;
        public const int QuestionFormToAnI   = 300;
        public const int NonBillableToAnI    = 310;
        public const int tooLarge            = 320;
        public const int corrupted           = 330;
        public const int deleted             = 340;
        public const int QuestionFormToPrac  = 290;
    }
}
