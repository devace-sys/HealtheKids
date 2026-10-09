using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /**************************************************************************
     * PatientInfoRequestToPerson */
    /**
     **************************************************************************/
	 
    public class PatientInfoRequestToPerson : Person 
    {                                
        public bool    sendEmail        = false;
        public bool    sendText         = false;
        public string  requestURL       = "";
        public bool    sentEmail        = false;
        public bool    sentText         = false;
        public string  sentEmailStatus  = "";
        public string  sentTextStatus   = "";
       
    }

    /**************************************************************************
     * PatientInfoRequestResponsePublic */
    /**
     **************************************************************************/
    
	public class PatientInfoRequestResponsePublic
    {
        public long    id;
        public long    requestID;
        public string  publicToken;
        public long    clientID;
        public string  clientName;
        public string  clientLogoFileData;
        public string  studentIDLast2Chars;
        public string  requesterName;
        public string  requesterTitle;
        public string  requesterEmail;
        public string  requesterPhone;
        public string  requestSentToJSON;
        public bool    noInsuranceOptionSelected;
        public bool    otherInsuranceOptionSelected;          
        public bool    recFound;        
        public string  patName;
        public string  dobStr;
        public string  insuranceCarrierPolicyHolderFirstName;
        public string  insuranceCarrierPolicyHolderLastName;
        public long    insuranceCarrierID;        
        public string  policyNumber;
        public string  insuranceGroupNumberID;        
    }

    /**************************************************************************
     * PatientInfoRequestsResponsesCommon */
    /**
     *
     **************************************************************************/
	 
    public class PatientInfoRequestsResponsesCommon
    {
        public const string URL_REQUEST_FORM_PUBLIC_BASE = @"student_information_request_form.aspx";

        /**************************************************************************
         * parsePatientInfoRequestToPersonsJSONToList */
        /**
         *    
         **************************************************************************/

        public static List<PatientInfoRequestToPerson> parsePatientInfoRequestToPersonsJSONToList (string json) 
        {            
            List<PatientInfoRequestToPerson> persons = new List<PatientInfoRequestToPerson>();
            if (String.IsNullOrWhiteSpace(json)) return persons;
            persons = (List<PatientInfoRequestToPerson>) JSON.fromJSONString(json,typeof(List<PatientInfoRequestToPerson>),JsonLibrary.NEWTONSOFT);
            return persons;
        }

        /**************************************************************************
         * parsePatientInfoRequestToPersonsListToJSON */
        /**
         *    
         **************************************************************************/
        
        public static string parsePatientInfoRequestToPersonsListToJSON (List<PatientInfoRequestToPerson> persons)
        {
          return JSON.toJSONString(persons,JsonLibrary.NEWTONSOFT);
        }

        /**************************************************************************
         * findPatientInfoPersonByPatPerID */
        /**
         *    
         **************************************************************************/
		 
        public static bool findPatientInfoRequestToPersonByPatPerID (
              List<PatientInfoRequestToPerson> persons
            , long id
            , out PatientInfoRequestToPerson person )
        {
            person = new PatientInfoRequestToPerson();
            
            bool found = false;
            foreach (PatientInfoRequestToPerson p in persons) {
              if (p.id == id) {
                    person = p;
                    found  = true;
                    break;
                }
            };
            
            return found;
        }
        
        /**************************************************************************
         * getPatientInfoRequestResponseByPtkn */
        /**
         *    
         **************************************************************************/
		 
        public static PatientInfoRequestResponsePublic getPatientInfoRequestResponseByPtkn (
            SqlConnection connSpedmon
          , DetailsLog    log
          , string        ptkn )
        {
            PatientInfoRequestResponsePublic rec = new PatientInfoRequestResponsePublic();
            rec.recFound = false;
            string vPtkn = Validate.reqString(ptkn, @"Invalid token");
            var parms = new List<SqlParameter>();
            parms.Add(Database.SqlParm("@ptkn", SqlDbType.VarChar, vPtkn, ParameterDirection.Input, 512));
            string sql = "select top 1 * FROM dbo.PATIENT_INFO_REQUESTS_RESPONSES_GET_BY_PTKN(@ptkn)";
            ReturnDB rd = Database.execQuery(connSpedmon, log, sql, false, parms);
            if (rd.hasRecords == false)   {
                rec.recFound = false;
                return rec;
            }
            rec = (PatientInfoRequestResponsePublic) Database.convertRecord(rd.records, typeof(PatientInfoRequestResponsePublic) );
            rec.recFound = true;             
            return rec;
        }                       
       
    }
}

