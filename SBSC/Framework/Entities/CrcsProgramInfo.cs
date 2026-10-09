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
    public class CrcsProgramInfoRec : Entity
    {
        public long     clientID;
        public long     fiscalYearID;
        public decimal  indirectCostRate;
        public long     studentCensusPopulation;
        public long     mediCalEligibleStudents;
        public decimal  MER;
        public string   fmapTitleXIX;
        public string   fmapTitleXIXEnhanced;
        public string   fmapTitleXXI;
        public string   fmapTitleXXIEnhanced;
        public decimal  rmtsCode2APercentage;
        public long     contactID;
        public string   contactName;
        public string   contactTitle;
        public string   contactEmail;
        public string   contactPhone;
        public string   providerFax;
        public bool     SMAA;
        public bool     pracsWithZeroReimbursementCosts;
        public long     crcsBusinessOfficialID;
        public string   crcsBusinessOfficialName;
        public string   crcsBusinessOfficialTitle;
        public string   leaBOPConsortium;
        public bool     contactInfoVerified;
        public bool     personSigningInfoVerified;
        public bool     consortiumBillingInfoVerified;
        public bool     programInfoVerified;
        public long     lecOrLgaID;
        public string   lecOrLgaName;
    }

    /***************************************************************************
     * CrcsProgramInfoOneWayTrips  */
    /**
     * Used for getting number of one-way trips from service records
     ***************************************************************************/
    public class CrcsProgramInfoOneWayTrips
    {
        public long clientID;
        public long fiscalYearID;
        public long allPats;
        public long mcalPats;
    }

    /***************************************************************************
     * ReturnCrcsProgramInfoOneWayTrips  */
    /**
     * 
     ***************************************************************************/

    public class ReturnCrcsProgramInfoOneWayTrips : Return
    {
        public ReturnCrcsProgramInfoOneWayTrips() : base() { }
        public ReturnCrcsProgramInfoOneWayTrips(string msg) : base(msg) { }
        public ReturnCrcsProgramInfoOneWayTrips(Exception e) : base(e) { }
        public ReturnCrcsProgramInfoOneWayTrips(Warning e) : base(e) { }
        public ReturnCrcsProgramInfoOneWayTrips(Critical e) : base(e) { }
        public ReturnCrcsProgramInfoOneWayTrips(SessionExpired e) : base(e) { }
        public bool hasRecord = false;
        public CrcsProgramInfoOneWayTrips crcsProgramInfoOneWayTrips;
    }

    /***************************************************************************
     * CrcsProgramInfoLEABOPConsortium  */
    /**
     *
     ***************************************************************************/
    public class CrcsProgramInfoLEABOPConsortium
    {
        [IsDataGridCol(1)]
        [DataGridColTitle("IDX")]
        [DataGridColIsInputLabel(true)]
        [DataGridColIsInputKey(true)]
        [DataGridColIsHidden(true)]
        [DataGridColWidth(1)]
        public long idx;

        [IsDataGridCol(2)]
        [DataGridColTitle("LEA Name")]
        [DataGridColWidth(200)]
        public string leaName;

        [IsDataGridCol(3)]
        [DataGridColTitle("CDS Code")]
        [DataGridColWidth(200)]
        public string CDS;
    }

    public class CrcsProgramInfo : Entities
    {
        public const string URL_MANAGE      = @"user_all_crcs_program_info_manage.aspx";

        public const string URL_WEB_SERVICE = @"crcs_program_info.asmx";
        public const string URL_SAVE        = URL_WEB_SERVICE + @"/save";

        /***************************************************************************
         * URL_MANAGE_BASE */
        /**
         * 
         **************************************************************************/

        public static string URL_MANAGE_BASE()
        {
            return MBA.HttpApplication.createLink(CrcsProgramInfo.URL_MANAGE, true);
        }

        /***************************************************************************
         * view */
        /**
         * 
         ***************************************************************************/

        public static ReturnDB view(SqlConnection connSpedmon
                                     , DetailsLog log
                                     , UserInfo uInfo
                                     , int recViewType
                                     , bool pagedOrTop
                                     , string idx
                                     , string canEdit
                                     , string active
                                     , string clientID
                                     , string fiscalYearID
                                     , defineCols dc)
        {

            string viewUDF = "dbo.CRCS_PROGRAM_INFO_VIEW (@userID, @userGroup, @userRank, @clientID, @fiscalYearID, @active, @recID)";

            /*----------------------------
            * Validate parameters specific
            * to this entity.view
            * and populate their
            * coresponding database
            * parameters
            *----------------------------*/

            var vClientID     = Validate.optClientID(uInfo       , clientID);
            var vFiscalYearID = Validate.optInteger (fiscalYearID, Messages.INVALID_FISCAL_YEAR_ID);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"    , SqlDbType.BigInt, vClientID    , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fiscalYearID", SqlDbType.BigInt, vFiscalYearID, ParameterDirection.Input));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }

        /***************************************************************************
         * save */
        /**
         * 
         ***************************************************************************/

        public static Return save(SqlConnection dbConnSpedmon
                                , DetailsLog log
                                , UserInfo uInfo
                                , string clientID				
                                , string fiscalYearID
                                , string indirectCostRate
                                , string studentCensusPopulation
                                , string mediCalEligibleStudents
                                , string MER
                                , string fmapTitleXIX
                                , string fmapTitleXIXEnhanced
                                , string fmapTitleXXI
                                , string fmapTitleXXIEnhanced
                                , string rmtsCode2APercentage
                                , string contactID
                                , string contactTitle
                                , string contactEmail
                                , string contactPhone
                                , string providerFax
                                , string SMAA
                                , string pracsWithZeroReimbursementCosts
                                , string crcsBusinessOfficialID
                                , string crcsBusinessOfficialTitle
                                , string leaBOPConsortium
                                , string contactInfoVerified
                                , string personSigningInfoVerified
                                , string consortiumBillingInfoVerified
                                , string programInfoVerified
                                , string lecOrLgaID
                                , string editDelReason
                                , string validateRec
                                , string saveType
                                , string recID)
        {
            string saveSproc = @"CRCS_PROGRAM_INFO_SAVE";
            string dupRecMsg = @"Record already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vClientID                        = Validate.reqClientID    (uInfo                          , clientID);
            var vFiscalYearID                    = Validate.reqInteger     (fiscalYearID                   , Messages.INVALID_FISCAL_YEAR_ID);
            var vIndirectCostRate                = Validate.optFixed       (indirectCostRate               , @"Invalid indirect cost rate");
            var vStudentCensusPopulation         = Validate.optInteger     (studentCensusPopulation        , @"Invalid student census population", true);
            var vMediCalEligibleStudents         = Validate.optInteger     (mediCalEligibleStudents        , @"Invalid number of medi-cal eligible students", true);
            var vMER                             = Validate.optFixed       (MER                            , @"Invalid MER %");
            var vFmapTitleXIX                    = Validate.optString      (fmapTitleXIX                   , @"Invalid FMAP Title XIX");
            var vFmapTitleXIXEnhanced            = Validate.optString      (fmapTitleXIXEnhanced           , @"Invalid FMAP Title XIX Enhanced");
            var vFmapTitleXXI                    = Validate.optString      (fmapTitleXXI                   , @"Invalid FMAP Title XXI");
            var vFmapTitleXXIEnhanced            = Validate.optString      (fmapTitleXXIEnhanced           , @"Invalid FMAP Title XXI Enhanced");
            var vRmtsCode2APercentage            = Validate.optFixed       (rmtsCode2APercentage           , @"Invalid RMTS 2A Percentage");
            var vContactID                       = Validate.optInteger     (contactID                      , @"Invalid Contact", true);
            var vContactTitle                    = Validate.optString      (contactTitle                   , @"Invalid Contact Title");
            var vContactEmail                    = Validate.optEmail       (contactEmail                   , Messages.INVALID_EMAIL);
            var vContactPhone                    = Validate.optPhoneNumber (contactPhone                   , Messages.INVALID_PHONE_NUMBER);
            var vProviderFax                     = Validate.optPhoneNumber (providerFax                    , Messages.INVALID_PHONE_NUMBER);
            var vSMAA                            = Validate.optFlag        (SMAA                           , Messages.INVALID_MAA_FLAG);
            var vPracsWithZeroReimbursementCosts = Validate.optFlag        (pracsWithZeroReimbursementCosts, Messages.INVALID_FLAG);
            var vCrcsBusinessOfficialID          = Validate.optInteger     (crcsBusinessOfficialID         , @"Invalid Business Official", true);
            var vCrcsBusinessOfficialTitle       = Validate.optString      (crcsBusinessOfficialTitle      , @"Invalid Business Official Title");
            var vLeaBOPConsortium                = Validate.optString      (leaBOPConsortium               , @"Invalid LEA BOP Consortium");
            var vContactInfoVerified             = Validate.optFlag        (contactInfoVerified            , Messages.INVALID_FLAG);
            var vPersonSigningInfoVerified       = Validate.optFlag        (personSigningInfoVerified      , Messages.INVALID_FLAG);
            var vConsortiumBillingInfoVerified   = Validate.optFlag        (consortiumBillingInfoVerified  , Messages.INVALID_FLAG);
            var vProgramInfoVerified             = Validate.optFlag        (programInfoVerified            , Messages.INVALID_FLAG);
            var vLecOrLgaID                      = Validate.optInteger     (lecOrLgaID                     , Messages.INVALID_LEC_OR_LGA, true);


            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"                       , SqlDbType.BigInt  , vClientID                       , ParameterDirection.Input     ));
            parms.Add(Database.SqlParm("@fiscalYearID"                   , SqlDbType.BigInt  , vFiscalYearID                   , ParameterDirection.Input     ));
            parms.Add(Database.SqlParm("@indirectCostRate"               , SqlDbType.Decimal , vIndirectCostRate               , ParameterDirection.Input     ));
            parms.Add(Database.SqlParm("@studentCensusPopulation"        , SqlDbType.BigInt  , vStudentCensusPopulation        , ParameterDirection.Input     ));
            parms.Add(Database.SqlParm("@mediCalEligibleStudents"        , SqlDbType.BigInt  , vMediCalEligibleStudents        , ParameterDirection.Input     ));
            parms.Add(Database.SqlParm("@MER"                            , SqlDbType.Decimal , vMER                            , ParameterDirection.Input     ));
            parms.Add(Database.SqlParm("@fmapTitleXIX"                   , SqlDbType.VarChar , vFmapTitleXIX                   , ParameterDirection.Input, 50 ));
            parms.Add(Database.SqlParm("@fmapTitleXIXEnhanced"           , SqlDbType.VarChar , vFmapTitleXIXEnhanced           , ParameterDirection.Input, 50 ));
            parms.Add(Database.SqlParm("@fmapTitleXXI"                   , SqlDbType.VarChar , vFmapTitleXXI                   , ParameterDirection.Input, 50 ));
            parms.Add(Database.SqlParm("@fmapTitleXXIEnhanced"           , SqlDbType.VarChar , vFmapTitleXXIEnhanced           , ParameterDirection.Input, 50 ));
            parms.Add(Database.SqlParm("@rmtsCode2APercentage"           , SqlDbType.Decimal , vRmtsCode2APercentage           , ParameterDirection.Input     ));
            parms.Add(Database.SqlParm("@contactID"                      , SqlDbType.BigInt  , vContactID                      , ParameterDirection.Input     ));
            parms.Add(Database.SqlParm("@contactTitle"                   , SqlDbType.VarChar , vContactTitle                   , ParameterDirection.Input, 50 ));
            parms.Add(Database.SqlParm("@contactEmail"                   , SqlDbType.VarChar , vContactEmail                   , ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@contactPhone"                   , SqlDbType.VarChar , vContactPhone                   , ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@providerFax"                    , SqlDbType.VarChar , vProviderFax                    , ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@SMAA"                           , SqlDbType.Bit     , vSMAA                           , ParameterDirection.Input     ));
            parms.Add(Database.SqlParm("@pracsWithZeroReimbursementCosts", SqlDbType.Bit     , vPracsWithZeroReimbursementCosts, ParameterDirection.Input     ));
            parms.Add(Database.SqlParm("@crcsBusinessOfficialID"         , SqlDbType.BigInt  , vCrcsBusinessOfficialID         , ParameterDirection.Input     ));
            parms.Add(Database.SqlParm("@crcsBusinessOfficialTitle"      , SqlDbType.VarChar , vCrcsBusinessOfficialTitle      , ParameterDirection.Input, 50 ));
            parms.Add(Database.SqlParm("@leaBOPConsortium"               , SqlDbType.VarChar , vLeaBOPConsortium               , ParameterDirection.Input, -1 ));
            parms.Add(Database.SqlParm("@contactInfoVerified"            , SqlDbType.Bit     , vContactInfoVerified            , ParameterDirection.Input     ));
            parms.Add(Database.SqlParm("@personSigningInfoVerified"      , SqlDbType.Bit     , vPersonSigningInfoVerified      , ParameterDirection.Input     ));
            parms.Add(Database.SqlParm("@consortiumBillingInfoVerified"  , SqlDbType.Bit     , vConsortiumBillingInfoVerified  , ParameterDirection.Input     ));
            parms.Add(Database.SqlParm("@programInfoVerified"            , SqlDbType.Bit     , vProgramInfoVerified            , ParameterDirection.Input     ));
            parms.Add(Database.SqlParm("@lecOrLgaID"                     , SqlDbType.BigInt  , vLecOrLgaID                     , ParameterDirection.Input     ));

            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.save(dbConnSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);
        }

        /***************************************************************************
         * load */
        /**
         * 
         ***************************************************************************/

        public static CrcsProgramInfoRec load(SqlConnection connSpedmon
                                            , DetailsLog log
                                            , UserInfo uInfo
                                            , string clientID
                                            , string fiscalYearID)
        {
            return (CrcsProgramInfoRec)

                Entities.loadNRecord(connSpedmon, log, uInfo, 0, typeof(CrcsProgramInfoRec)
                  ,delegate {
                     return CrcsProgramInfo.view ( connSpedmon
                                                          , log
                                                          , uInfo
                                                          , Entities.REC_VIEW_LOAD_N
                                                          , false
                                                          , ""  /* idx */
                                                          , ""  /* canEdit */
                                                          , ""  /* active  */
                                                          , clientID
                                                          , fiscalYearID
                                                          , null);
                });
        }

        /***************************************************************************
         * getNumOneWayTrips */
        /**
         * 
         ***************************************************************************/

        public static ReturnCrcsProgramInfoOneWayTrips getNumOneWayTrips (SqlConnection connSpedmon
                                     , DetailsLog log
                                     , UserInfo uInfo
                                     , string clientID
                                     , string fiscalYearID)
        {

            var so = new ReturnCrcsProgramInfoOneWayTrips();
            
            long   vClientID     = Validate.reqClientID (uInfo, clientID);
            long   vFiscalYearID = Validate.reqInteger  (fiscalYearID, Messages.INVALID_FISCAL_YEAR_ID);

            var parms = new List<SqlParameter>();

              parms.Add(Database.SqlParm("@clientID",      SqlDbType.BigInt,   vClientID,      ParameterDirection.Input));
              parms.Add(Database.SqlParm("@fiscalYearID",  SqlDbType.BigInt,   vFiscalYearID,  ParameterDirection.Input));

              var sql = @"select * from dbo.CRCS_PROGRAM_INFO_NUM_TRIPS (@clientID, @fiscalYearID)";

              ReturnDB rd = Database.execQuery(connSpedmon,log,sql,false,parms);
      
              so.hasRecord = rd.hasRecords;
              so.crcsProgramInfoOneWayTrips = new CrcsProgramInfoOneWayTrips();
              if (so.hasRecord)
              {
                so.crcsProgramInfoOneWayTrips = (CrcsProgramInfoOneWayTrips)Database.convertRecord(rd.records, typeof(CrcsProgramInfoOneWayTrips));
              }
              return so;

        }

    }
}
