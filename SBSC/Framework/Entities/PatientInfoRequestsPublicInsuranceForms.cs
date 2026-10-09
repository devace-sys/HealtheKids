using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

    /**************************************************************************
     * PatientInfoRequestsPublicInsuranceForm */
    /**
     **************************************************************************/

    public class PatientInfoRequestsPublicInsuranceForm
    {
        public long    id;
        public long clientID;
        public string  publicToken;
        public string  clientName;
        public string  clientLogoFileData;
        public bool    recFound;
        public string  formURL;
    }

    
	/**************************************************************************
     * ReturnPatientInfoRequestsPublicInsuranceForm */
    /**
     **************************************************************************/

    public class ReturnPatientInfoRequestsPublicInsuranceForm : Return
    {
        public ReturnPatientInfoRequestsPublicInsuranceForm() : base() { }
        public ReturnPatientInfoRequestsPublicInsuranceForm(string msg) : base(msg) { }
        public ReturnPatientInfoRequestsPublicInsuranceForm(Exception e) : base(e) { }
        public ReturnPatientInfoRequestsPublicInsuranceForm(Warning e) : base(e) { }
        public ReturnPatientInfoRequestsPublicInsuranceForm(Critical e) : base(e) { }
        public ReturnPatientInfoRequestsPublicInsuranceForm(SessionExpired e) : base(e) { }

        public PatientInfoRequestsPublicInsuranceForm dataobj;
    }


    /**************************************************************************
     * PatientInfoRequestsPublicInsuranceForms */
    /**
     *
     **************************************************************************/

    public class PatientInfoRequestsPublicInsuranceForms
    {
        /**************************************************************************
         * URL_REQUEST_FORM_PUBLIC_BASE */
        /**
         * 
         **************************************************************************/

   	    public const string URL_REQUEST_FORM_PUBLIC_BASE   = @"student_insurance_info_request_form.aspx";        
        public const string URL_WEB_SVC                    = @"patient_info_requests_public_insurance_forms.asmx";
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

	    public static PatientInfoRequestsPublicInsuranceForm getFormByPtkn (
            SqlConnection connSpedmon
          , DetailsLog    log
          , string        ptkn )
        {
            PatientInfoRequestsPublicInsuranceForm rec = new PatientInfoRequestsPublicInsuranceForm();
            rec.recFound = false;
            string vPtkn = Validate.reqString(ptkn, @"Invalid token");
            var parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@ptkn", SqlDbType.VarChar, vPtkn, ParameterDirection.Input, 512));
            string sql = "select top 1 * FROM dbo.PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORMS_GET_BY_PTKN(@ptkn)";
            ReturnDB rd = Database.execQuery(connSpedmon, log, sql, false, parms);
            if (rd.hasRecords == false)   {
                rec.recFound = false;
                return rec;
            }
            rec = (PatientInfoRequestsPublicInsuranceForm) Database.convertRecord(rd.records, typeof(PatientInfoRequestsPublicInsuranceForm) );
            rec.recFound = true;
            rec.formURL = MBA.HttpApplication.createLink(URL_REQUEST_FORM_PUBLIC_BASE, new NameValue(Constants.PARM_PUBLIC_TOKEN, rec.publicToken));
            return rec;
        }

        /**************************************************************************
         * getFormByClientID */
        /**
         * Used by internal management screen for responses via web service.   
         **************************************************************************/

        public static ReturnPatientInfoRequestsPublicInsuranceForm getFormByClientID (
            SqlConnection connSpedmon
           , DetailsLog   log
           , UserInfo     uInfo
           , string       clientID )
        {
            ReturnPatientInfoRequestsPublicInsuranceForm rec = new ReturnPatientInfoRequestsPublicInsuranceForm();
            var vClientID = Validate.reqClientID(uInfo, clientID);                                    
            var parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            string sql = "select top 1 * FROM dbo.PATIENT_INFO_REQUESTS_PUBLIC_INSURANCE_FORMS_GET_PTKN_FOR_CLIENT (@clientID)";
            ReturnDB rd = Database.execQuery(connSpedmon, log, sql, false, parms);
            if (rd.hasRecords == false)
            {
                rec.dataobj.recFound = false;
                return rec;
            }
            rec.dataobj = (PatientInfoRequestsPublicInsuranceForm)Database.convertRecord(rd.records, typeof(PatientInfoRequestsPublicInsuranceForm));
            rec.dataobj.recFound = true;
            rec.dataobj.formURL = MBA.HttpApplication.createLink(URL_REQUEST_FORM_PUBLIC_BASE, new NameValue(Constants.PARM_PUBLIC_TOKEN, rec.dataobj.publicToken));
            return rec;
        }
    }
}

