using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Mail;
using System.IO;
using System.Data;
using System.Data.SqlClient;

namespace MBA
{

    /***************************************************************************
     * userSignature */
    /**
     *
     ***************************************************************************/

    public class userSignature : Entity
    {
        public long userID;
        public long personID;
        public string signatureBase64;
    }

    /***************************************************************************
     * userSignatures */
    /**
     *
     ***************************************************************************/

    public class UserSignatures : Entities
    {

        /***************************************************************************
         * view */
        /**
         *
         **************************************************************************/

        public static ReturnDB view(SqlConnection connSpedmon
                                      , DetailsLog log
                                      , UserInfo uInfo
                                      , int recViewType
                                      , bool pagedOrTop
                                      , string idx
                                      , string canEdit
                                      , string active
                                      , string signatureUserID
                                      , string signaturePersonID
                                      , defineCols dc)
        {

            string viewUDF = @"dbo.USER_SIGNATURES_VIEW (@userID, @userGroup, @userRank, @signatureUserID, @signaturePersonID, @active, @recID)";

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            List<SqlParameter> parms = new List<SqlParameter>();

            Object vSignatureUserID = Validate.optInteger(signatureUserID, Messages.INVALID_USER_ID);
            Object vSignaturePersonID = Validate.optInteger(signaturePersonID, Messages.INVALID_PERSON_ID);

            parms.Add(Database.SqlParm("@signatureUserID", SqlDbType.BigInt, vSignatureUserID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@signaturePersonID", SqlDbType.BigInt, vSignaturePersonID, ParameterDirection.Input));

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon
                                  , log
                                  , uInfo
                                  , recViewType
                                  , pagedOrTop
                                  , idx
                                  , canEdit
                                  , active
                                  , viewUDF
                                  , ref parms
                                  , null
                                  , dc);
        }

        /***************************************************************************
         * viewSel */
        /**
         * Returns a data table of records for preview or record selection.
         *
         * @return                 ReturnDataTable
         ***************************************************************************/

        //public static ReturnSel viewSel(SqlConnection connSpedmon
        //                                  , DetailsLog log
        //                                  , UserInfo uInfo
        //                                  , bool top
        //                                  , string topSize
        //                                  , string clientID
        //                                  , string groupSvcClassNameID
        //                                  , string patientID
        //                                  , string planID
        //                                  , string term)
        //{

        //    /*----------------------------
        //     * Define our context column
        //     *----------------------------*/

        //    defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        //    {
        //        ss.addDisplayColumn("personRoleAndRelationship as context1");
        //        ss.addDisplayColumn("useInPlan as recFlagged");
        //    };

        //    /*----------------------------
        //     * Call base method which
        //     * handles the rest and return
        //     * results
        //     *----------------------------*/

        //    return Entities.viewSel(connSpedmon
        //                            , log
        //                            , uInfo
        //                            , top
        //                            , topSize
        //                            , delegate {
        //                                return userSignatures.view(connSpedmon
        //                                                                        , log
        //                                                                        , uInfo
        //                                                                        , Entities.REC_VIEW_SEL
        //                                                                        , top
        //                                                                        , topSize
        //                                                                        , ""
        //                                                                        , "Y"
        //                                                                        , clientID
        //                                                                        , planID
        //                                                                        , term
        //                                                                        , dc);
        //                            });

        //}

        /***************************************************************************
         * loadN */
        /**
         * Outputs data for a single record
         *
         * Note: This calls the view method and the view method takes care of
         * enforcing the client id.
         *
         * @param  connSpedmon     Spedmon database connection object
         * @param  log             Logging object
         * @param  clientID        Client ID
         * @param  patID           PatID
         * @return                 ReturnEntity
         ***************************************************************************/

        public static userSignature loadN(SqlConnection connUser
                                       , DetailsLog log
                                       , UserInfo uInfo
                                       , string appName
                                       , int n
                                       , string signatureUserID
                                       , string signaturePersonID
                                       , string recID)
        {
            return (userSignature)Entities.loadNRecord(connUser
                                                      , log
                                                      , uInfo
                                                      , n
                                                      , typeof(userSignature)
                                                      , delegate
                                                      {
                                                          return UserSignatures.view(connUser
                                                                                   , log
                                                                                   , uInfo
                                                                                   , Entities.REC_VIEW_LOAD_N
                                                                                   , false
                                                                                   , ""
                                                                                   , ""
                                                                                   , ""
                                                                                   , signatureUserID
                                                                                   , signaturePersonID
                                                                                   , null);
                                                      });
        }

        /***************************************************************************
         * loadAllRecords */
        /**    
         *
         ***************************************************************************/

        //public static List<PlanWriterPlansPatientPerson> loadAllRecords(SqlConnection connSpedmon
        //                                                                   , DetailsLog log
        //                                                                   , UserInfo uInfo
        //                                                                   , string clientID
        //                                                                   , string groupSvcClassNameID
        //                                                                                                         , string patientID
        //                                                                   , string planID)
        //{

        //    List<PlanWriterPlansPatientPerson> listItems = new List<PlanWriterPlansPatientPerson>();

        //    bool hasRecords = false;

        //    Object[] recs = loadAllRecords(connSpedmon
        //                                    , log
        //                                    , uInfo
        //                                    , typeof(PlanWriterPlansPatientPerson)
        //                                    , delegate {
        //                                        return userSignatures.view(connSpedmon
        //                                                                               , log
        //                                                                               , uInfo
        //                                                                               , Entities.REC_VIEW_ALL
        //                                                                               , false
        //                                                                               , ""
        //                                                                               , ""
        //                                                                               , "Y"
        //                                                                               , clientID
        //                                                                               , planID
        //                                                                               , null
        //                                                                               , null);
        //                                    }
        //                                                                                   , out hasRecords);

        //    if (hasRecords == true)
        //    {
        //        foreach (Object rec in recs)
        //        {
        //            PlanWriterPlansPatientPerson listItem = (PlanWriterPlansPatientPerson)rec;
        //            listItems.Add(listItem);
        //        }
        //    }
        //    return listItems;
        //}

    }
}
