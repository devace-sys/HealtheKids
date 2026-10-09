using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    /**************************************************************************
     * PractitioenrPatientReferralsPublicMentalHealthRequestReferrallForm */
    /**
     **************************************************************************/

    public class PractitioenrPatientReferralsPublicMentalHealthRequestReferrallForm
    {
        public long    id;        
        public string  publicToken;
        public long    clientID;
        public string  clientName;
        public string  clientLogoFileData;
        public bool    recFound;
        public string  formURL;
    }

    
	/**************************************************************************
     * ReturnPractitioenrPatientReferralsPublicMentalHealthRequestReferrallForm */
    /**
     **************************************************************************/

    public class ReturnPractitioenrPatientReferralsPublicMentalHealthRequestReferrallForm : Return
    {
        public ReturnPractitioenrPatientReferralsPublicMentalHealthRequestReferrallForm() : base() { }
        public ReturnPractitioenrPatientReferralsPublicMentalHealthRequestReferrallForm(string msg) : base(msg) { }
        public ReturnPractitioenrPatientReferralsPublicMentalHealthRequestReferrallForm(Exception e) : base(e) { }
        public ReturnPractitioenrPatientReferralsPublicMentalHealthRequestReferrallForm(Warning e) : base(e) { }
        public ReturnPractitioenrPatientReferralsPublicMentalHealthRequestReferrallForm(Critical e) : base(e) { }
        public ReturnPractitioenrPatientReferralsPublicMentalHealthRequestReferrallForm(SessionExpired e) : base(e) { }

        public PractitioenrPatientReferralsPublicMentalHealthRequestReferrallForm dataobj;
    }


    /**************************************************************************
     * PractitioenrPatientReferralsPublicMentalHealthRequestReferrallForms */
    /**
     *
     **************************************************************************/

    public class PractitioenrPatientReferralsPublicMentalHealthRequestReferrallForms
    {
        /**************************************************************************
         * URL_REQUEST_FORM_PUBLIC_BASE */
        /**
         * 
         **************************************************************************/

   	    public const string URL_REQUEST_FORM_PUBLIC_BASE   = @"mental_health_request_referral.aspx";        
        public const string URL_WEB_SVC                    = @"practitioner_patient_referral_public_mental_health_request_forms.asmx";
        public const string URL_SVC_GET_FORM_BY_CLIENT_ID  = URL_WEB_SVC + @"/getformbyclientid";
        
        /***************************************************************************
         * URL_SVC_GET_FORM_BY_CLIENT_ID_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_SVC_GET_FORM_BY_CLIENT_ID_BASE()
        {
            return MBA.HttpApplication.createLink(URL_SVC_GET_FORM_BY_CLIENT_ID, true);
        }

        /**************************************************************************
         * getFormByPtkn */
        /**
         * Used in public form in code behind.  Do not make this available as a web
         * method.
         **************************************************************************/

	    public static PractitioenrPatientReferralsPublicMentalHealthRequestReferrallForm getFormByPtkn (
            SqlConnection connSpedmon
          , DetailsLog    log
          , string        ptkn )
        {
            PractitioenrPatientReferralsPublicMentalHealthRequestReferrallForm rec = new PractitioenrPatientReferralsPublicMentalHealthRequestReferrallForm();
            rec.recFound = false;
            string vPtkn = Validate.reqString(ptkn, @"Invalid token");
            var parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@ptkn", SqlDbType.VarChar, vPtkn, ParameterDirection.Input, 512));
            string sql = "select top 1 * FROM dbo.PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_FORMS_GET_BY_PTKN(@ptkn)";
            ReturnDB rd = Database.execQuery(connSpedmon, log, sql, false, parms);
            if (rd.hasRecords == false)   {
                rec.recFound = false;
                return rec;
            }
            rec = (PractitioenrPatientReferralsPublicMentalHealthRequestReferrallForm) Database.convertRecord(rd.records, typeof(PractitioenrPatientReferralsPublicMentalHealthRequestReferrallForm) );
            rec.recFound = true;
            rec.formURL = MBA.HttpApplication.createLink(URL_REQUEST_FORM_PUBLIC_BASE, new NameValue(Constants.PARM_PUBLIC_TOKEN, rec.publicToken));
            return rec;
        }

        /**************************************************************************
         * getFormByClientID */
        /**
         * Used by internal management screen for responses via web service.   
         **************************************************************************/

        public static ReturnPractitioenrPatientReferralsPublicMentalHealthRequestReferrallForm getFormByClientID (
            SqlConnection connSpedmon
           , DetailsLog   log
           , UserInfo     uInfo
           , string       clientID )
        {
            ReturnPractitioenrPatientReferralsPublicMentalHealthRequestReferrallForm rec = new ReturnPractitioenrPatientReferralsPublicMentalHealthRequestReferrallForm();
            var vClientID = Validate.reqClientID(uInfo, clientID);                                    
            var parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            string sql = "select top 1 * FROM dbo.PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_FORMS_GET_PTKN_FOR_CLIENT (@clientID)";
            ReturnDB rd = Database.execQuery(connSpedmon, log, sql, false, parms);
            rec.dataobj = (PractitioenrPatientReferralsPublicMentalHealthRequestReferrallForm)Database.convertRecord(rd.records, typeof(PractitioenrPatientReferralsPublicMentalHealthRequestReferrallForm));
            if (rd.hasRecords == false)
            {
                rec.dataobj.recFound = false;
                return rec;
            }
            rec.dataobj.recFound = true;
            rec.dataobj.formURL = MBA.HttpApplication.createLink(URL_REQUEST_FORM_PUBLIC_BASE, new NameValue(Constants.PARM_PUBLIC_TOKEN, rec.dataobj.publicToken));
            return rec;
        }
    }
}

