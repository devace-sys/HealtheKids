using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.Services.Protocols;
using System.Web.Script.Serialization;
using System.ComponentModel;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using MBA;


namespace Spedmon
{

    /***************************************************************************
     * SpEdAssessmentToolsSvc */
    /**
     ***************************************************************************/

    [WebService(Namespace = "http://spedcare.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]

    public class SpEdAssessmentToolsSvc : MBA.WebSvc
    {

        /***************************************************************************
         * viewSel */
        /**
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSel(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdAssessmentTools.viewSel(dbConnApp, log, uInfo, false, "", "1", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelReading */
        /**
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelReading(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdAssessmentTools.viewSelReading(dbConnApp, log, uInfo, false, "", "1", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelWriting */
        /**
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelWriting(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdAssessmentTools.viewSelWriting(dbConnApp, log, uInfo, false, "", "1", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelMath */
        /**
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelMath(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdAssessmentTools.viewSelMath(dbConnApp, log, uInfo, false, "", "1", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelCommunicationDev */
        /**
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelCommunicationDev(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdAssessmentTools.viewSelCommunicationDev(dbConnApp, log, uInfo, false, "", "1", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelGrossFineMotor */
        /**
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelGrossFineMotor(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdAssessmentTools.viewSelGrossFineMotor(dbConnApp, log, uInfo, false, "", "1", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelHealth */
        /**
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelHealth(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdAssessmentTools.viewSelHealth(dbConnApp, log, uInfo, false, "", "1", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelVocational */
        /**
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelVocational(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdAssessmentTools.viewSelVocational(dbConnApp, log, uInfo, false, "", "1", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelAdaptiveDailyLiving */
        /**
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelAdaptiveDailyLiving(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdAssessmentTools.viewSelAdaptiveDailyLiving(dbConnApp, log, uInfo, false, "", "1", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelSocialEmotionalBehavioral */
        /**
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelSocialEmotionalBehavioral(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdAssessmentTools.viewSelSocialEmotionalBehavioral(dbConnApp, log, uInfo, false, "", "1", term); },
            Constants.ROLE_ALL);
        }

    }
}