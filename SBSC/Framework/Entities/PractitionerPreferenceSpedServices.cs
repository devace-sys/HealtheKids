using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    public class PractitionerPreferenceSpedService : Entity
    {
        public const string DEFAULT_PAGING_ORDER = "id";

        public long clientID;
        public string clientName;

        public long pracID;
        public string pracName;

        //public long   disciplineGroupID;
        //public string disciplineGroupName;

        public long   spEdServiceCode; // spedServiceID;
        public string spedServiceName;

        public string codeName;
        public string codeValue;
        public string codeValueAndName;

    }


    /***************************************************************************
     * PractitionerCaseloadMembers */
    /**
     * 
     ***************************************************************************/

    public class PractitionerPreferenceSpedServices : Entities
    {

        public const string calpadsCodeSupportTitle        = @"CALPADS I Support";
        public const string calpadsCodeSupportInstructions = @"By choosing the CALPADS code(s) you support (before Importing), SpEdCare can filter caseload imports to only include relevant services.  This will reduce the number of rows you may need to remove after each caseload import or update.";
        public const string calpadsCodeSupportTooltip      = "Click here to manage the CALPADS codes I support.  " + calpadsCodeSupportInstructions;

        public const string URL_ASMX          = "practitioner_preference_sped_services.asmx";
        public const string URL_ASMX_SAVE     = URL_ASMX + "/save";
        public const string URL_ASMX_DELETE   = URL_ASMX + "/delete";
        public const string URL_ASMX_VIEW_SEL = URL_ASMX + "/viewSel";

        /********************************************
         * GEN_URL_ASMX_DELETE
         ********************************************/
        public static string GEN_URL_ASMX_DELETE()
        {
            return MBA.HttpApplication.createLink(URL_ASMX_DELETE, true);
        }

        /********************************************
         * GEN_URL_ASMX_VIEW_SEL
         ********************************************/
        public static string GEN_URL_ASMX_VIEW_SEL()
        {
            return MBA.HttpApplication.createLink(URL_ASMX_VIEW_SEL, true);
        }

        /********************************************
         * GEN_URL_ASMX_SAVE
         ********************************************/
        public static string GEN_URL_ASMX_SAVE()
        {
            return MBA.HttpApplication.createLink(URL_ASMX_SAVE, true);
        }


        public const string URL_REST_VIEW = @"api/v1/practitionerpreferencespedservices";

        public static string URL_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(URL_REST_VIEW, true);
        }


        public static ReturnSaveRecord delete(

            SqlConnection connSpedmon
          , DetailsLog log
          , UserInfo uInfo
          , string editDelReason
          , string validateRec

          , string clientID
          , string pracID

          // TODO: figure out if we need these params submitted w/ the AJAX, instead of found within the uInfo object;
          //       figure out how to submit additional params in the JSON with the .delete() AJAX call
                   // DONE

          , string recID                      )
        {

            List<SqlParameter> parms = new List<SqlParameter>();

            long paramClientID = Validate.reqClientID(uInfo, clientID);
            long paramPracID        =  Validate.reqPracID(uInfo, pracID);


            Validate.reqInteger(recID, "delete requires valid record ID");
                        
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, paramClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID", SqlDbType.BigInt, paramPracID, ParameterDirection.Input));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, @"PRACTITIONER_PREFERENCE_SPED_SERVICE_DELETE", ref parms);
        }

        public static ReturnSaveOrReplaceRecord save(
            SqlConnection connSpedmon
          , DetailsLog log
          , UserInfo uInfo

          , string clientID
          , string pracID
          , string spEdServiceCode

          //, string editDelReason
          //, string validateRec
          //, string saveType
          //, string recID
          )

        {

            List<SqlParameter> parms = new List<SqlParameter>();

            long vClientID       = Validate.reqClientID(uInfo, clientID);
            long vPracID         = Validate.reqPracID(uInfo, pracID);
            long vSpedSvc = Validate.reqInteger(spEdServiceCode, "requires valid sped service code");
            
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID", SqlDbType.BigInt, vPracID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdServiceCode", SqlDbType.BigInt, vSpedSvc, ParameterDirection.Input));
            
            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.saveOrReplaceRecord(connSpedmon, log, uInfo, "" /* validateRec */, "PRACTITIONER_PREFERENCE_SPED_SERVICE_SAVE_OR_REPLACE", ref parms, null);

        }


        public static ReturnDB view(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                     int recViewType,
                                     bool pagedOrTop,
                                     string idx,
                                     string canEdit,
                                     string active,

                                     string clientID           ,
                                     string pracID             ,
                                     string disciplineGroupID  ,
                                     string spEdServiceID      ,

                                     defineCols dc)
        {

            string viewUDF = "PRACTITIONER_PREFERENCE_SPED_SERVICES_VIEW (" +
                               "@userID, @userGroup, @userRank, @clientID, @pracID, @disciplineGroupID, @spEdServiceID, @active, @recID)";
                                                                        
            List<SqlParameter> parms = new List<SqlParameter>();

            Object vClientID = Validate.reqClientID(uInfo, clientID );
            Object vPracID   = Validate.reqPracID  (uInfo, pracID   );

            Object vDisciplineGroupID = Validate.optInteger( disciplineGroupID  , "requires valid discipline group ID");
            Object vSpEdServiceID     = Validate.optInteger( spEdServiceID      , "requires spEdServiceIDID");


            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID"  , SqlDbType.BigInt, vPracID, ParameterDirection.Input));

            parms.Add(Database.SqlParm("@disciplineGroupID", SqlDbType.BigInt, vDisciplineGroupID , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@spEdServiceID"    , SqlDbType.BigInt, vSpEdServiceID     , ParameterDirection.Input));



            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }


        /***************************************************************************
         * viewSel */
        /**
         * View group member record selections
         * 
         * @return                 ReturnSel
         ***************************************************************************/

        public static ReturnSel viewSel(SqlConnection connSpedmon,
                                         DetailsLog log,
                                         UserInfo uInfo,
                                         bool top,
                                         string topSize,

                                         string clientID,
                                         string pracID,

                                         string disciplineGroupID ,
                                         string spEdServiceID
                                )
        {

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {

                // TODO: fix

                ss.addSortColumn("name");
                ss.addDisplayColumn("dobStr + ' | ' + siteName + ' | Ind: ' + minsIndStr + ' | Grp: ' + minsGrpStr as [context1]");
                ss.addDisplayColumn("minsIndStr     as [recData1]");
                ss.addDisplayColumn("minsGrpStr     as [recData2]");
                ss.addDisplayColumn("ytdNumMinsStr  as [recData3]");
                ss.addDisplayColumn("mtdNumMinsStr  as [recData4]");

                ss.addDisplayColumn("ytdDosMinStr   as [recData5]");
                ss.addDisplayColumn("ytdDosMaxStr   as [recData6]");
                ss.addDisplayColumn("ytdNumSvcsStr  as [recData7]");

                ss.addDisplayColumn("mtdDosMinStr   as [recData8]");
                ss.addDisplayColumn("mtdDosMaxStr   as [recData9]");
                ss.addDisplayColumn("mtdNumSvcsStr  as [recData10]");

                ss.addDisplayColumn("[email]  as [recData11]");
                ss.addDisplayColumn("[phone] as [recData12]");

            };

            return Entities.viewSel(connSpedmon, log, uInfo, top, topSize,
              delegate {
                          return PractitionerPreferenceSpedServices.view(
                                     connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, top, topSize, "", "Y",
                                     clientID, pracID, disciplineGroupID, spEdServiceID, 
                                     dc
                                 );
                       }
            );
        }


        /***************************************************************************
         * viewObjects */
        /**
         ***************************************************************************/


        
        public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                                  , DetailsLog log
                                                  , UserInfo uInfo
                                                  , bool pageObjectList
                                                  , string pageOrder
                                                  , string idx
                                                  , string active

                                                  , string clientID
                                                  , string pracID

                                                  , string disciplineGroupID
                                                  , string spEdServiceID

                                                  )

        {

            // Default page order 

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PractitionerPreferenceSpedService.DEFAULT_PAGING_ORDER;

            // Define columns delegate is used to specify columns and page order 
            // We pass in the desired page row order here 

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(PractitionerPreferenceSpedService)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate {
                                              return PractitionerPreferenceSpedServices.view(
                                                                                         connSpedmon
                                                                                       , log
                                                                                       , uInfo
                                                                                       , Entities.REC_VIEW_OBJECTS
                                                                                       , pageObjectList
                                                                                       , idx
                                                                                       , ""
                                                                                       , (  Util.IsNullOrEmpty( active )
                                                                                            ?
                                                                                            "1"
                                                                                            :
                                                                                            active )

                                                                                       , clientID
                                                                                       , pracID
                                                                                       , disciplineGroupID
                                                                                       , spEdServiceID
                                                                                       , dc);
                                          });


        }

    }
}

