using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * ClientStudentInformationSystem */
    /**
     * 
     *************************************************************************/

    public class ClientStudentInformationSystem
    {
        public const string DEFAULT_PAGING_ORDER = @"studentInfoSystemName asc, id desc";

        public long      id;
        public long      clientID;
        public string    clientName;
        public long      studentInfoSystemID;
        public string    studentInfoSystemName;
        public string    apiUrl;
        public string    apiToken;
        public string    schoolNamesToExclude;
        public string    additionalDataJSON;
        public bool      enabled;
        public DateTime  created;
        public long      createdBy;
        public DateTime? lastModified;
        public long?     lastModifiedBy;
        public bool      active;
    }

    /***************************************************************************
     * ClientStudentInformationSystems */
    /**
     * 
     *************************************************************************/

    public class ClientStudentInformationSystems : Entities
    {
        public const string URL_WEB_SVC           = @"client_student_information_systems.asmx";
        public const string URL_SVC_SAVE_INLINE   = URL_WEB_SVC + @"/saveinline";
        public const string URL_SVC_DELETE_INLINE = URL_WEB_SVC + @"/deleteinline";
        public const string URL_REST_VIEW         = @"api/v1/clientstudentinformationsystems";

        /***************************************************************************
         * URL_SVC_SAVE_INLINE_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SVC_SAVE_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink(URL_SVC_SAVE_INLINE, true);
        }

        /***************************************************************************
         * URL_SVC_DELETE_INLINE_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_SVC_DELETE_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink(URL_SVC_DELETE_INLINE, true);
        }

        /***************************************************************************
         * URL_REST_VIEW_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(URL_REST_VIEW, true);
        }

        /***************************************************************************
         * view */
        /**
         * 
         *************************************************************************/

        protected static ReturnDB view (  SqlConnection connSpedmon
                                        , DetailsLog log
                                        , UserInfo uInfo
                                        , int recViewType
                                        , bool pagedOrTop
                                        , string idx
                                        , string canEdit
                                        , string clientID
                                        , string studentInfoSystemID
                                        , string enabled
                                        , string active
                                        , defineCols dc)
        {

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * corresponding database
             * parameters
             *----------------------------*/

            var vClientID              = Validate.optClientID (uInfo, clientID);
            var vStudentInfoSystemID   = Validate.optInteger  (studentInfoSystemID, @"Invalid student information system");
            var vEnabled               = Validate.optFlag     (enabled,@"Invalid enabled flag", true, true);

            var parms = new List<SqlParameter>(); 

            parms.Add(Database.SqlParm("@clientID",            SqlDbType.BigInt, vClientID,            ParameterDirection.Input));
            parms.Add(Database.SqlParm("@studentInfoSystemID", SqlDbType.BigInt, vStudentInfoSystemID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@enabled",             SqlDbType.Bit,    vEnabled,             ParameterDirection.Input));

            string viewUDF = "dbo.CLIENT_STUDENT_INFORMATION_SYSTEMS_VIEW (@userID, @userGroup, @userRank, @clientID, @studentInfoSystemID, @enabled, @active)";

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        /***************************************************************************
         * viewObjects */
        /**
         * 
         *************************************************************************/

        public static ReturnObjects viewObjects (  SqlConnection connSpedmon
                                                  , DetailsLog log
                                                  , UserInfo uInfo
                                                  , bool pageObjectList
                                                  , string pageOrder
                                                  , string idx
                                                  , string active
                                                  , string clientID
                                                  , string studentInfoSystemID
                                                  , string enabled )
        {

            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = ClientStudentInformationSystem.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(
                  connSpedmon
                , log
                , uInfo
                , typeof(ClientStudentInformationSystem)
                , pageObjectList
                , pageOrder
                , delegate
                {
                    return ClientStudentInformationSystems.view (
                          connSpedmon
                        , log
                        , uInfo
                        , Entities.REC_VIEW_OBJECTS
                        , pageObjectList
                        , idx
                        , "" /*canEdit*/
                        , clientID
                        , studentInfoSystemID
                        , enabled
                        , active
                        , dc);
                });

        }

        /***************************************************************************
         * viewList */
        /**
         * Return a list of client student information system records
         * 
         ***************************************************************************/

        public static List<ClientStudentInformationSystem> viewList  (  SqlConnection connSpedmon
                                                                      , DetailsLog log
                                                                      , UserInfo uInfo
                                                                      , string active
                                                                      , string clientID
                                                                      , string studentInfoSystemID
                                                                      , string enabled )
        {
            var recs = new List<ClientStudentInformationSystem>();

            ReturnDB rd = ClientStudentInformationSystems.view (
                  connSpedmon
                , log
                , uInfo
                , Entities.REC_VIEW_RAW
                , false
                , null
                , null
                , clientID
                , studentInfoSystemID
                , enabled
                , active
                , null);

            List<Object> slo = Database.convertRecordsToList(ref rd.records, typeof(ClientStudentInformationSystem));

            foreach (var o in slo)
            {
                recs.Add((ClientStudentInformationSystem)o);
            }

            return recs;
        }
        
        /***************************************************************************
         * load */
        /**
         * This is the by recid.  
         * TODO: This is untested and for possible future use.  Remove this notice once tested.
         *************************************************************************/
        public static ClientStudentInformationSystem load (
             SqlConnection connSpedmon
            , DetailsLog   log
            , UserInfo     uInfo
            , string       clientID            
            , string       recID )
        {
          return (ClientStudentInformationSystem) Entities.load(connSpedmon, log, uInfo, recID, typeof(ClientStudentInformationSystem),
          delegate {
            return ClientStudentInformationSystems.view (
                  connSpedmon
                , log
                , uInfo
                , Entities.REC_VIEW_LOAD
                , false
                , recID
                , ""
                , clientID
                , ""
                , ""
                , @"Y"
                , null);; 
           });
        }
   
        /***************************************************************************
         * getSIS */
        /**
         * 
         *************************************************************************/
        public static ClientStudentInformationSystem getSIS (
             SqlConnection connSpedmon
            , DetailsLog   log
            , UserInfo     uInfo
            , string       clientID
            , string       studentInfoSystemID )
        {          
          return (ClientStudentInformationSystem) Entities.load(connSpedmon, log, uInfo, typeof(ClientStudentInformationSystem),
          delegate {
            return ClientStudentInformationSystems.view (
                  connSpedmon
                , log
                , uInfo
                , Entities.REC_VIEW_RAW
                , false
                , ""
                , ""
                , clientID
                , studentInfoSystemID
                , ""
                , @"Y"
                , null);; 
           });         
        }

        /***************************************************************************
         * save */
        /**
         * 
         *************************************************************************/

        public static ReturnSaveRecord save (  SqlConnection connSpedmon
                                             , DetailsLog log
                                             , UserInfo   uInfo
                                             , string     clientID
                                             , string     studentInfoSystemID
                                             , string     apiUrl
                                             , string     apiToken
                                             , string     schoolNamesToExclude
                                             , string     enabled
                                             /*, string     additionalDataJSON*/
                                             , string     editDelReason
                                             , string     validateRec
                                             , string     saveType
                                             , string     recID )
        {

            string saveSproc = @"CLIENT_STUDENT_INFORMATION_SYSTEMS_SAVE";
            string dupRecMsg = @"This student information system is already configured for this client";

            long vClientID               = Validate.reqClientID (uInfo, clientID);
            long vStudentInfoSystemID    = Validate.reqInteger  (studentInfoSystemID,  @"Please select a student information system");
            string vApiUrl               = Validate.reqString   (apiUrl,               @"Invalid API URL");
            string vApiToken             = Validate.reqString   (apiToken,             @"Invalid API token");
            string vSchoolNamesToExclude = Validate.optString   (schoolNamesToExclude, @"Invalid set of school names");
            bool   vEnabled              = Validate.reqFlag     (enabled,              @"Invalid value for enabled", false);

            if (String.IsNullOrWhiteSpace(vSchoolNamesToExclude)) {
              vSchoolNamesToExclude = @"";
            }

            string vAdditionalDataJSON   = "{}"; /* For future use */


            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID",              SqlDbType.BigInt,    vClientID,              ParameterDirection.Input));
            parms.Add(Database.SqlParm("@studentInfoSystemID",   SqlDbType.BigInt,    vStudentInfoSystemID,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@apiUrl",                SqlDbType.VarChar,   vApiUrl,                ParameterDirection.Input, 1024));
            parms.Add(Database.SqlParm("@apiToken",              SqlDbType.VarChar,   vApiToken,              ParameterDirection.Input, 1024));
            parms.Add(Database.SqlParm("@schoolNamesToExclude",  SqlDbType.VarChar,   vSchoolNamesToExclude,  ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@enabled",               SqlDbType.Bit,       vEnabled,               ParameterDirection.Input));
            parms.Add(Database.SqlParm("@additionalDataJSON",    SqlDbType.VarChar,   vAdditionalDataJSON,    ParameterDirection.Input, -1));

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);
        }

        /***************************************************************************
         * delete */
        /**
         * 
         *************************************************************************/

        public static ReturnSaveRecord delete (  SqlConnection connSpedmon
                                               , DetailsLog log
                                               , UserInfo uInfo
                                               , string editDelReason
                                               , string validateRec
                                               , string recID )
        {

            string deleteSproc = @"CLIENT_STUDENT_INFORMATION_SYSTEMS_DELETE";

            var vClientID = Validate.optClientID(uInfo, @""); /* For future use if needed for client users */

            var parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, deleteSproc, ref parms);
        }
    }
}