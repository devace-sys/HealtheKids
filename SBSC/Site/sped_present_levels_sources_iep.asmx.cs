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
     * SpEdPresentLevelsSourcesSvc */
    /**
     * Web services end point for SpEd Present Levels Sources
     ***************************************************************************/

    [WebService(Namespace = "http://spedcare.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]

    public class SpEdPresentLevelsSourcesSvc : MBA.WebSvc
    {

        /***************************************************************************
         * viewSel */
        /**
         * View selection list - General sources for all domains
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSel(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdPresentLevelsSources.viewSel(dbConnUser, log, uInfo, false, "", "1", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelReading */
        /**
         * View selection list - Reading domain sources
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelReading(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdPresentLevelsSources.viewSelReading(dbConnUser, log, uInfo, false, "", "1", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelWriting */
        /**
         * View selection list - Writing domain sources
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelWriting(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdPresentLevelsSources.viewSelWriting(dbConnUser, log, uInfo, false, "", "1", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelMath */
        /**
         * View selection list - Math domain sources
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelMath(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdPresentLevelsSources.viewSelMath(dbConnUser, log, uInfo, false, "", "1", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelCommunicationDev */
        /**
         * View selection list - Communication Development domain sources
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelCommunicationDev(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdPresentLevelsSources.viewSelCommunicationDev(dbConnUser, log, uInfo, false, "", "1", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelGrossFineMotor */
        /**
         * View selection list - Gross/Fine Motor domain sources
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelGrossFineMotor(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdPresentLevelsSources.viewSelGrossFineMotor(dbConnUser, log, uInfo, false, "", "1", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelHealth */
        /**
         * View selection list - Health domain sources
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelHealth(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdPresentLevelsSources.viewSelHealth(dbConnUser, log, uInfo, false, "", "1", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelVocational */
        /**
         * View selection list - Vocational domain sources
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelVocational(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdPresentLevelsSources.viewSelVocational(dbConnUser, log, uInfo, false, "", "1", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelAdaptiveDailyLiving */
        /**
         * View selection list - Adaptive/Daily Living domain sources
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelAdaptiveDailyLiving(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdPresentLevelsSources.viewSelAdaptiveDailyLiving(dbConnUser, log, uInfo, false, "", "1", term); },
            Constants.ROLE_ALL);
        }

        /***************************************************************************
         * viewSelSocialEmotionalBehavioral */
        /**
         * View selection list - Social/Emotional/Behavioral domain sources
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelSocialEmotionalBehavioral(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate () { return SpEdPresentLevelsSources.viewSelSocialEmotionalBehavioral(dbConnUser, log, uInfo, false, "", "1", term); },
            Constants.ROLE_ALL);
        }

    }
}