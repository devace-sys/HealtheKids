using MBA;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;

namespace Spedmon
{
    public class ServiceRecordDataIncomplete : Entity
    {
        public const string DEFAULT_PAGING_ORDER = @"clientName asc, id asc";

        public long     clientID;
        public string   clientName;
        public string   reference;
        public long     pracID;
        public long     groupID;
        public string   pracName;
        public long     patID;
        public string   patName;
        public DateTime dos;
        public string   dosStrYMD;
        public Int16    svcNamesListDataSourceID;
	    public byte     billingProgramID;
        public long     nameID;
        public string   svcName;
        public bool     viaTelehealth;
        public bool     isIEPOrIFSP;
        public TimeSpan startTime;
        public int      numMins;
        public bool     hasSvcDetFlags;
        public bool     svcDetFlag1;
        public bool     svcDetFlag2;
        public bool     svcDetFlag3;
        public bool     svcDetFlag4;
        public bool     hasOrpDocID;
        public long     orpDocID;
        public string   orpDocLabel;
        public long     inputBatchID;
        public string   inputBatchNotes;
        public long     createdByUserID;
        public string   createdByUserName;
        public DateTime createdOn;
        public string   createdOnYMD;
    }

    public class ServiceRecordsDataIncomplete : Entities
    {
        public const string SEL_LABEL_MANAGE         = @"Manage Question Forms";
        public const string URL_MANAGE               = @"user_all_svcrec_data_incomplete_manage.aspx";
        public const string MENU_LNK_USER_ALL_MANAGE = @"servicerecordsdataincompletemanagelnk";

        public const string URL_REST_VIEW            = @"api/v1/servicerecordsdataincomplete";

        public const string URL_WEB_SERVICE          = @"service_records_data_incomplete.asmx";
        public const string URL_SAVE                 = URL_WEB_SERVICE + @"/save";
        public const string URL_DELETE               = URL_WEB_SERVICE + @"/deleteinline";

        /***************************************************************************
         * URL_REST_VIEW */
        /**
         * 
         **************************************************************************/

        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(ServiceRecordsDataIncomplete.URL_REST_VIEW, true);
        }

        /***************************************************************************
         * URL_MANAGE_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_MANAGE_BASE()
        {
            return MBA.HttpApplication.createLink(ServiceRecordsDataIncomplete.URL_MANAGE, true);
        }

        public static string URL_SAVE_BASE()
        {
            return MBA.HttpApplication.createLink(ServiceRecordsDataIncomplete.URL_SAVE, true);
        }

        public static string URL_DELETE_BASE()
        {
            return MBA.HttpApplication.createLink(ServiceRecordsDataIncomplete.URL_DELETE, true);
        }

        /***************************************************************************
         * view */
        /**
         * 
         ***************************************************************************/
        public static ReturnDB view (  SqlConnection connSpedmon
                                     , DetailsLog log
                                     , UserInfo uInfo
                                     , int recViewType
                                     , bool pagedOrTop
                                     , string idx
                                     , string canEdit
                                     , string active
                                     , string clientID
                                     , defineCols dc )
        {

            string viewUDF = "dbo.SERVICE_RECORD_DATA_INCOMPLETE_VIEW (@userID, @userGroup, @userRank, @clientID, @recID)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            var vClientID = Validate.optClientID (uInfo, clientID);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }


        /***************************************************************************
         * viewObjects 
         *
         * Returns a list of objects
         * 
         ***************************************************************************/
        public static ReturnObjects viewObjects (   SqlConnection connSpedmon
                                                  , DetailsLog    log
                                                  , UserInfo      uInfo
                                                  , bool          pageObjectList
                                                  , string        pageOrder
                                                  , string        idx
                                                  , string        active
                                                  , string        clientID )
        {

            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = ServiceRecordDataIncomplete.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects (   connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(ServiceRecordDataIncomplete)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return ServiceRecordsDataIncomplete.view(
                                                                         connSpedmon
                                                                       , log
                                                                       , uInfo
                                                                       , Entities.REC_VIEW_OBJECTS
                                                                       , pageObjectList
                                                                       , idx
                                                                       , "" // canEdit
                                                                       , active
                                                                       , clientID
                                                                       , dc
                                               );
                                          });
        }

        /***************************************************************************
         * save 
         *
         * Note: LEA BOP services only and only services where patient was present
         * Basically the fields that the pcal input staff would be able to input.
         ***************************************************************************/

        public static Return save ( SqlConnection dbConnSpedmon
                                   , DetailsLog   log
                                   , UserInfo     uInfo
                                   , string       reference                                   
                                   , string       dos
                                   , string       clientID
                                   , string       pracID
                                   , string       patID
                                   , string       isIEPOrIFSP
                                   , string       nameID
                                   , string       hasOrpDocID
                                   , string       orpDocID
                                   , string       hasSvcDetFlags
                                   , string       svcDetFlag1
                                   , string       svcDetFlag2
                                   , string       svcDetFlag3
                                   , string       svcDetFlag4
                                   , string       numMins
                                   , string       editDelReason
                                   , string       validateRec
                                   , string       saveType
                                   , string       recID )
        {
            string saveSproc = @"SERVICE_RECORD_DATA_INCOMPLETE_SAVE";
            string dupRecMsg = @"Record already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vReference      = Validate.reqSvcRecReference (uInfo, reference);          
            var vDos            = Validate.reqDate            (dos,            Messages.SERVICE_DATE_BAD, Constants.VAL_OPT_DATE_NO_FUTURE);
            var vClientID       = Validate.reqClientID        (uInfo,          clientID);
            var vPracID         = Validate.reqInteger         (pracID,         Messages.INVALID_PRAC_ID);
            var vPatID          = Validate.reqInteger         (patID,          Messages.INVALID_PAT_ID);
            var vIsIEPOrIFSP    = Validate.reqFlag            (isIEPOrIFSP,    Messages.IFSP_IEP_FLAG_BAD);
            var vNameID         = Validate.reqInteger         (nameID,         Messages.INVALID_SERVICE);
            var vHasOrpDocID    = Validate.reqFlag            (hasOrpDocID,    Messages.INVALID_HAS_ORP_DOC_ID);
            var vOrpDocID       = Validate.optInteger         (orpDocID,       Messages.INVALID_ORP_DOC_ID);
            var vHasSvcDetFlags = Validate.reqFlag            (hasSvcDetFlags, @"Invalid service details flag", true);
            var vSvcDetFlag1    = Validate.optFlag            (svcDetFlag1,    @"Invalid service detail flag");
            var vSvcDetFlag2    = Validate.optFlag            (svcDetFlag2,    @"Invalid service detail flag");
            var vSvcDetFlag3    = Validate.optFlag            (svcDetFlag3,    @"Invalid service detail flag");
            var vSvcDetFlag4    = Validate.optFlag            (svcDetFlag4,    @"Invalid service detail flag");            
            var vNumMins        = Validate.optInteger         (numMins,        Messages.INVALID_NUM_MINS);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@reference",      SqlDbType.VarChar,  vReference,      ParameterDirection.Input, 500));            
            parms.Add(Database.SqlParm("@dos",            SqlDbType.DateTime, vDos,            ParameterDirection.Input));
            parms.Add(Database.SqlParm("@clientID",       SqlDbType.BigInt,   vClientID,       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID",         SqlDbType.BigInt,   vPracID,         ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID",          SqlDbType.BigInt,   vPatID,          ParameterDirection.Input));
            parms.Add(Database.SqlParm("@isIEPOrIFSP",    SqlDbType.Bit,      vIsIEPOrIFSP,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@nameID",         SqlDbType.BigInt,   vNameID,         ParameterDirection.Input));
            parms.Add(Database.SqlParm("@hasOrpDocID",    SqlDbType.Bit,      vHasOrpDocID,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@orpDocID",       SqlDbType.BigInt,   vOrpDocID,       ParameterDirection.Input));
            parms.Add(Database.SqlParm("@hasSvcDetFlags", SqlDbType.Bit,      vHasSvcDetFlags, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag1",    SqlDbType.Bit,      vSvcDetFlag1,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag2",    SqlDbType.Bit,      vSvcDetFlag2,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag3",    SqlDbType.Bit,      vSvcDetFlag3,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@svcDetFlag4",    SqlDbType.Bit,      vSvcDetFlag4,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@numMins",        SqlDbType.Int,      vNumMins,        ParameterDirection.Input));

            parms.Add(Database.SqlParm("@MsgInvCombo",     SqlDbType.VarChar, Messages.INVALID_PPN_COMBO,      ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinReq",       SqlDbType.VarChar, Messages.MIN_REQ,                ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMinDef",       SqlDbType.VarChar, Messages.MIN_DEF,                ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgMilReq",       SqlDbType.VarChar, Messages.MIL_REQ,                ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatElg",       SqlDbType.VarChar, Messages.PAT_ELG,                ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatDOBGteDOS", SqlDbType.VarChar, Messages.PAT_DOB_GTE_DOS,        ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgPatAbsent",    SqlDbType.VarChar, Messages.PAT_ABSENT_NO_CLAIM,    ParameterDirection.Input, 1000));
            parms.Add(Database.SqlParm("@MsgFutureDOS",    SqlDbType.VarChar, Messages.VAL_SVC_REC_DOS_FUTURE, ParameterDirection.Input, 1000));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.save (dbConnSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);
        }

        /***************************************************************************
         * delete */
        /**
         * Deactivates an existing question form record.
         *
         * @param  editDelReason   Reason for edit/delete
         * @param  validateRec     Perform validation for this record?
         * @param  recID           Record id reference for delete
         * @return                 ReturnSaveRecord
         ***************************************************************************/

        public static ReturnSaveRecord delete (  SqlConnection connSpedmon
                                               , DetailsLog    log
                                               , UserInfo      uInfo
                                               , string        editDelReason
                                               , string        validateRec
                                               , string        recID)
        {
            string deleteSproc = @"SERVICE_RECORD_DATA_INCOMPLETE_DELETE";
            
            var vClientID = Validate.optClientID (uInfo,""); /* Forces clientid selection for non pcal staff */

            var parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, deleteSproc, ref parms);
        }

    }
}
