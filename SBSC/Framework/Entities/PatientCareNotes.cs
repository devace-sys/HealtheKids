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
    * PatientCareNote */
   /**
    * 
    * 
    ***************************************************************************/
    public class PatientCareNote : Entity
    {
       public const string DEFAULT_PAGING_ORDER = @"note asc";
       public long      id;  
	   public long      clientID;
       public long      groupSvcClassNameID;
	   public long      patID;
       public string    note;
       public DateTime  created;
       public long      createdBy;
       public DateTime  lastModified;
       public long      lastModifiedBy;
    }

   /**************************************************************************
    * PracticeOfficeVisits */
   /**
    * 
    * 
    ***************************************************************************/
    public class PatientCareNotes: Entities
    {

        public const string URL_WEB_SVC                        = @"patient_care_notes.asmx";
        public const string URL_SAVE_NOTE                      = URL_WEB_SVC + @"/savenotes";
        public const string URL_LOAD_NOTE                      = URL_WEB_SVC + @"/loadnotes";
        public const string URL_REST_VIEW                      = @"api/v1/patientcarenotes";


        /***************************************************************************
         * URL_SAVE_NOTE_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SAVE_NOTE_BASE()
        {
            return MBA.HttpApplication.createLink(PatientCareNotes.URL_SAVE_NOTE, true);
        }

        /***************************************************************************
         * URL_LOAD_NOTE_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_LOAD_NOTE_BASE()
        {
            return MBA.HttpApplication.createLink(PatientCareNotes.URL_LOAD_NOTE, true);
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
         * saveNotes */
        /**
         * 
         **************************************************************************/
        public static ReturnSaveOrReplaceRecord saveNotes(SqlConnection connSpedmon
                                                       , DetailsLog log
                                                       , UserInfo uInfo
                                                       , string clientID
                                                       , string groupSvcClassNameID
                                                       , string patID
                                                       , string note
                                                       , string active
                                                       , string editDelReason
                                                       , string validateRec
                                                       , string saveType)
        {

            var parms = new List<SqlParameter>();

            string saveSproc = "PATIENT_CARE_NOTES_SAVE";

            long vClientID                              = Validate.reqClientID                      (uInfo, clientID);
            long vGroupSvcClassNameID                   = Validate.reqStdGroupSvcClassNameID        (uInfo, groupSvcClassNameID);
            long vPatID                                 = Validate.reqPatID                         (uInfo, patID);            
            string vNote                               = Validate.optString                         (note,     @"Invalid notes");
            

            parms.Add(Database.SqlParm("@clientID",             SqlDbType.BigInt,   vClientID,                  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@groupSvcClassNameID",  SqlDbType.BigInt,   vGroupSvcClassNameID,       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID",                SqlDbType.BigInt,   vPatID,                     ParameterDirection.Input));           
            parms.Add(Database.SqlParm("@note",                 SqlDbType.VarChar,  vNote,                      ParameterDirection.Input, -1));

            ReturnSaveOrReplaceRecord so = Entities.saveOrReplaceRecord(connSpedmon
                                             , log
                                             , uInfo
                                             , validateRec
                                             , saveSproc
                                             , ref parms
                                             , delegate () { });

            return so;

        }       

       
        
        /***************************************************************************
         * view */
        /**
         * 
         **************************************************************************/
        protected static ReturnDB view (  SqlConnection connSpedmon
                                        , DetailsLog    log
                                        , UserInfo      uInfo
                                        , int           recViewType
                                        , string        clientID                                   
                                        , string        groupSvcClassNameID
                                        , string        patID
                                        , bool          pagedOrTop
                                        , string        canEdit
                                        , string        active
                                        , string        dataSource
                                        , defineCols    dc)
        {
            
            long     vClientID                       = Validate.reqClientID                (uInfo, clientID);
            long     vGroupSvcClassNameID            = Validate.reqStdGroupSvcClassNameID  (uInfo, groupSvcClassNameID);
            long     vPatID                          = Validate.reqPatID                   (uInfo, patID); 
            
            string viewUDF = "PATIENT_CARE_NOTES_VIEW (@userID, @userGroup, @userRank, @clientID, @groupSvcClassNameID, @patID, @active)";

            var parms = new List<SqlParameter>();
            
            parms.Add(Database.SqlParm("@clientID",              SqlDbType.BigInt,  vClientID,              ParameterDirection.Input));
            parms.Add(Database.SqlParm("@groupSvcClassNameID",   SqlDbType.BigInt,  vGroupSvcClassNameID,   ParameterDirection.Input));            
            parms.Add(Database.SqlParm("@patID",                 SqlDbType.BigInt,  vPatID,                 ParameterDirection.Input));
           
                            
            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, "-1", canEdit, active, viewUDF, ref parms, null, dc);
        }

        /***************************************************************************
        * load */
        /**
         * 
         ***************************************************************************/
        public static PatientCareNote load(SqlConnection connSpedmon
                                                       , DetailsLog log
                                                       , UserInfo uInfo
                                                       , string clientID
                                                       , string groupServiceClassNameID
                                                       , string patID)
        {
            return (PatientCareNote)Entities.load(connSpedmon, log, uInfo, typeof(PatientCareNote),
            delegate {
            return PatientCareNotes.view(   connSpedmon
                                            , log
                                            , uInfo
                                            , Entities.REC_VIEW_LOAD
                                            , clientID
                                            , groupServiceClassNameID
                                            , patID
                                            , false
                                            , ""
                                            , "Y" /* Active */
                                            , ""
                                            , null);
            }
          );
        }

        /***************************************************************************
        * get */
        /**
         *
         **************************************************************************/

        public static ReturnEntity get(SqlConnection connSpedmon
                                          , DetailsLog log
                                          , UserInfo uInfo
                                          , string clientID
                                          , string groupServiceClassNameID
                                          , string patID)
        {
            var so = new ReturnEntity();
            so.entity = PatientCareNotes.load(connSpedmon, log, uInfo, clientID, groupServiceClassNameID, patID);
            return so;
        }
    }
}