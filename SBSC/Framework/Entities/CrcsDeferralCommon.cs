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
    /***************************************************************************
     * CRCSDeferralStatus  */
    /**
     * Used for summary reporting
     ***************************************************************************/
    public class CRCSDeferralStatus
    {
        public bool deferred;
        public int  crcsCategoryCode;
        public long clientID;
        public long fiscalYearID;
    }

    /***************************************************************************
     * ReturnCRCSDeferralStatus  */
    /**
     * Used for summary reporting
     ***************************************************************************/

    public class ReturnCRCSDeferralStatus : Return
    {
        public ReturnCRCSDeferralStatus() : base() { }
        public ReturnCRCSDeferralStatus(string msg) : base(msg) { }
        public ReturnCRCSDeferralStatus(Exception e) : base(e) { }
        public ReturnCRCSDeferralStatus(Warning e) : base(e) { }
        public ReturnCRCSDeferralStatus(Critical e) : base(e) { }
        public ReturnCRCSDeferralStatus(SessionExpired e) : base(e) { }
        public bool hasRecord = false;
        public CRCSDeferralStatus crcsDeferralStatus;
    }
    public class CrcsDeferralCommon : Entities
    {
        /***************************************************************************
         * getDeferralStatus
         *
         * Returns CRCS deferral status for different CRCS categories
         * 
         ***************************************************************************/

        public static ReturnCRCSDeferralStatus getDeferralStatus(SqlConnection connSpedmon
                                                  , DetailsLog log
                                                  , UserInfo uInfo
                                                  , string clientID
                                                  , string fiscalYearID
                                                  , string crcsCategoryCode
        )
        {
            
            var so = new ReturnCRCSDeferralStatus();
            
            long   vClientID         = Validate.reqClientID (uInfo, clientID);
            long   vFiscalYearID     = Validate.reqInteger  (fiscalYearID, Messages.INVALID_FISCAL_YEAR_ID);
            long   vCrcsCategoryCode = Validate.reqInteger  (crcsCategoryCode, "Invalid CRCS code");

            var parms = new List<SqlParameter>();

              parms.Add(Database.SqlParm("@clientID",          SqlDbType.BigInt,   vClientID,          ParameterDirection.Input));
              parms.Add(Database.SqlParm("@fiscalYearID"    ,  SqlDbType.BigInt,   vFiscalYearID    ,  ParameterDirection.Input));
              parms.Add(Database.SqlParm("@crcsCategoryCode",  SqlDbType.BigInt,   vCrcsCategoryCode,  ParameterDirection.Input));

              var sql = @"select top 1 * from dbo.CRCS_CATEGORY_DEFERRAL_VIEW (@clientID, @fiscalYearID, @crcsCategoryCode)";

              ReturnDB rd = Database.execQuery(connSpedmon,log,sql,false,parms);
      
              so.hasRecord = rd.hasRecords;
              so.crcsDeferralStatus = new CRCSDeferralStatus();
              if (so.hasRecord)
              {
                so.crcsDeferralStatus = (CRCSDeferralStatus)Database.convertRecord(rd.records, typeof(CRCSDeferralStatus));
              }
              return so;      
           
        }

        /***************************************************************************
         * defer         
         ***************************************************************************/
        public static ReturnSaveRecord defer(SqlConnection dbConnSpedmon
                        , DetailsLog log
                        , UserInfo uInfo
                        , string clientID
                        , string fiscalYearID
                        , string crcsCategoryCode
                        , string deferred
                        , string editDelReason
                        , string validateRec
        )
        {
            string saveSproc = @"CRCS_CATEGORY_DEFER";
            string dupRecMsg = @"Record already exists";

            /*###########################################################################
              # Validate parameters specific to this entity save and create their 
              # database parameters
              ###########################################################################*/

            var vClientID         = Validate.reqClientID(uInfo, clientID);
            long vFiscalYearID    = Validate.reqInteger (fiscalYearID, Messages.INVALID_FISCAL_YEAR_ID);
            var vCrcsCategoryCode = Validate.reqInteger (crcsCategoryCode, Messages.INVALID_NUMBER);
            var vDeferred         = Validate.reqFlag    (deferred, Messages.INVALID_FLAG);

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID"        , SqlDbType.BigInt, vClientID        , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fiscalYearID"    , SqlDbType.BigInt, vFiscalYearID    , ParameterDirection.Input));
            parms.Add(Database.SqlParm("@crcsCategoryCode", SqlDbType.Int   , vCrcsCategoryCode, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@deferred"        , SqlDbType.Bit   , vDeferred        , ParameterDirection.Input));


            /*###########################################################################
              # Call base method which handles the rest and returns the results
              ###########################################################################*/

            return Entities.save(dbConnSpedmon, log, uInfo, Constants.SAVE_TYPE_NEW.ToString(), validateRec, editDelReason, "-1", saveSproc, dupRecMsg, ref parms, null);
        }
    }
}
