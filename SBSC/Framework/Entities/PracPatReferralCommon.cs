using MBA;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;

namespace Spedmon
{

    public class PracPatReferralPublic
    {
        public long referralID;
        public long clientID;
        public long pracID;
        public long patID;
        public string clientName;
        public string pinParent;
        public string pinPract;
        public string ptkn;
        public byte priority;
        public byte parentGuardianConsent;
        public byte referralType;
        public string referredToPracName;
        public string referredToPracEmail;
        public string referredToOrgName;
        public string referredToPracPhone;
        public string parentGuardianName;
        public string parentGuardianRelationship;
        public string parentGuardianEmail;
        public string parentGuardianPhone;
        public bool includeDiagnoses;
        public bool includeOrdersOrPrescriptions;
        public bool includeServiceRecordsTreatments;
        public bool includeServiceRecordsAssessementsOrScreenings;
        public bool includeServiceNotesNonConfidential;
        public bool includeServiceNotesConfidential;
        public DateTime approvalRejectionDate;
        public string approvalRejectionDateStr;
        public TimeSpan approvalRejectionTime;
        public string approvalRejectionTimeStr;
        public DateTime expirationDate;
        public string expirationDateStr;
        public TimeSpan expirationTime;
        public string expirationTimeStr;
        public bool isUsed;
        public string refFileID;
    }

    /**************************************************************************
     * PracPatReferralCommon */
    /**
     **************************************************************************/
    public class PracPatReferralCommon
    {

        public static PracPatReferralPublic GetReferralByToken(SqlConnection connSpedmon
                                                                      , DetailsLog log
                                                                      , string ptoken)
        {
            string vPtkn = Validate.reqString(ptoken, @"Invalid token");
            var parms = new List<SqlParameter>();
            PracPatReferralPublic rec = new PracPatReferralPublic();
            parms.Add(Database.SqlParm("@ptkn", SqlDbType.VarChar, vPtkn, ParameterDirection.Input, 512));

            string sql = "select top 1 * FROM dbo.PRATITIONER_PATIENT_REFERRAL_REQUESTS_GET_BY_PTKN(@ptkn)";
            ReturnDB rd = Database.execQuery(connSpedmon, log, sql, false, parms);
            if (rd.hasRecords == false)
            {
                return rec;
            }
            rec = (PracPatReferralPublic) Database.convertRecord(rd.records, typeof(PracPatReferralPublic));
            return rec;
        }

    }
}
