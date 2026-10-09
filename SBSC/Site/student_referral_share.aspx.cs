using System;
using System.Data.SqlClient;
using System.Web.UI;
using MBA;
using System.Configuration;
using System.Collections.Generic;
using Newtonsoft.Json;
using System.Web.Script.Serialization;

namespace Spedmon
{
    /***************************************************************************
     * StudentReferralShare */
    /**
     * 
     ***************************************************************************/

    public class StudentReferralShare : WebUI3

    {
        public bool pageInitIsOK = true;
        public bool dataLoadedOk = false;
        public bool reqLoadedOk = false;        
        public byte parentguardianconsent = 0;
        public bool hasFiles = false;
        public bool includeDiagnoses = false;
        public bool includeSvcRecordsAssessementsOrScreenings = false;
        public bool includeOrdersOrPrescriptions = false;
        public bool includeServiceRecordsTreatments = false;
        public bool includeServiceNotesNonConfidential = false;
        public bool includeServiceNotesConfidential = false;
        public bool completed = false;
        public string clientID;
        public string pracID;
        public string patID;
        public string ptkn;
        public string refToParent;
        public string refToPrac;
        public string actionValue;
        public string pin;
        public string recid;
        public string clientname;
        public string pracname;
        public string pracemail;
        public string refpracname;
        public string refpracemail;
        public string refpracorg;
        public string refpracphone;
        public string groupSvcClassNameIDStr;
        public string checkInSvcURL = @"";        
        public string errorMessage;
        public string patientDiagnosesData;
        public string patientOrdersOrPrData;
        public string patientPrimisedServiceData;
        public string urlFileDownLoad;
        public string storedfiles;

        public string subtitle;

        public PracPatReferralPublic rec = new PracPatReferralPublic();
        public List<ServiceRecord> serviceRecordsDataT;
        public List<ServiceRecord> serviceRecordsDataAorS;
        public Patient pat;
        public Practitioner prac;

        public StudentReferralShare() : base(  "student_referral_share"
                                              , "Student Referal"
                                              , "student_referral_share.css"
                                              , "")
        { }

        protected void Page_Load(object sender, EventArgs e)
        {
            this.pageInitIsOK = true;
            this.reqLoadedOk = true;
            this.dataLoadedOk = false;
            this.renderOptionContentOnly = true;
            errorMessage = string.Empty;
            
            try
            {
                uInfo = new UserInfo();

                if (!IsPostBack)
                {
                    if (!LoadInitialData())
                    {
                        pageInitIsOK = false;
                        return;
                    }
                }
                else
                {
                    // Process postback events such as validating the PIN and loading additional data
                    ProcessPostBack();
                }
            }
            catch (Exception ex)
            {
                errorMessage = "An error occurred while loading the page.";
                pageInitIsOK = false;
                return;
            }
        }

        private bool LoadInitialData()
        {
            ptkn = MBA.HttpApplication.getParameter(Constants.PARM_PUBLIC_TOKEN);
            refToParent = MBA.HttpApplication.getParameter(Constants.PARM_REF_TO_PARENT);
            refToPrac = MBA.HttpApplication.getParameter(Constants.PARM_REF_TO_PRAC);            

            if ("true".Equals(refToParent, StringComparison.OrdinalIgnoreCase))
                subtitle = "Parent/Guardian Referral Authorization Request";
            else if ("true".Equals(refToPrac, StringComparison.OrdinalIgnoreCase))
                subtitle = "Practitioner Access to Patient Data";

            if (String.IsNullOrWhiteSpace(ptkn))
                pageInitIsOK = false;

            rec = PracPatReferralCommon.GetReferralByToken(dbConnApp, log, ptkn);
            if (rec != null)
            {
                MapReferralDataForRequest(rec);
            }
            else
            {
                errorMessage = "No referral found for the provided token.";
                pageInitIsOK = false;
            }

            pat = Patients.load(dbConnApp, log, uInfo, patID);
            prac = Practitioners.load(dbConnApp, log, uInfo, pracID);
            
            return pageInitIsOK;
        }

        /// <summary>
        /// Maps only the fields required to build the request from the referral record.
        /// </summary>
        /// <param name="referral">The referral record from which to extract the needed data.</param>
        private void MapReferralDataForRequest(PracPatReferralPublic rec)
        {
            pracID = rec.pracID.ToString();
            patID = rec.patID.ToString();
            clientname = rec.clientName;
            refpracname = rec.referredToPracName;
            refpracemail = rec.referredToPracEmail;
            refpracorg = rec.referredToOrgName;
            refpracphone = rec.referredToPracPhone;
            completed = rec.isUsed;
        }


        private void ProcessPostBack()
        {
            // Retrieve form parameters
            actionValue = Request.Form["action"];

            if (byte.TryParse(actionValue, out var b))
            {
                parentguardianconsent = b;
            }

            pin = Request.Form["txt_student_referral_pin"];
            ptkn = Request.Form[Constants.PARM_PUBLIC_TOKEN];

            try
            {
                // Retrieve the referral record using the provided token
                rec = PracPatReferralCommon.GetReferralByToken(dbConnApp, log, ptkn);
                if (rec != null)
                {
                    MapReferralDataForResponse(rec);
                }
                else
                {
                    errorMessage = "No referral found for the provided token.";
                    pageInitIsOK = false;
                    return;
                }

                // Load patient and practitioner data
                pat = Patients.load(dbConnApp, log, uInfo, patID);
                prac = Practitioners.load(dbConnApp, log, uInfo, pracID);
                groupSvcClassNameIDStr = prac.stdSvcClassNameID.ToString();

                // Verify that the provided PIN matches the referral record
                if (ValidatePin(rec, pin))
                {
                    try
                    {
                        if (!rec.isUsed)
                        {
                            // Process the referral response (approve/decline) and send the notification email to the practitioner.
                            var returnActionRequest = PractitionerPatientReferrals.processreferralresponse(dbConnApp,
                                                                                                            log,
                                                                                                            rd,
                                                                                                            ptkn,
                                                                                                            parentguardianconsent.ToString(),
                                                                                                            refpracname,
                                                                                                            refpracemail,
                                                                                                            pracname,
                                                                                                            pracemail,
                                                                                                            recid
                                                                                                            );
                        }

                        // If parent guardian consent is received, load additional patient details.
                        if (parentguardianconsent == 1)
                        {
                            if (includeDiagnoses)
                            {
                                var tblDiagnoses = PatientDiagnoses.viewTbl(dbConnApp,
                                                                             log,
                                                                             uInfo,
                                                                             false,
                                                                             "",
                                                                             clientID,
                                                                             patID,
                                                                             "1"
                                                                             );
                                patientDiagnosesData = ReturnDataTable.createHTMLTable(ref tblDiagnoses);
                            }

                            if (includeOrdersOrPrescriptions)
                            {
                                var tblOrderOrPr = ORPDocuments.viewTbl(dbConnApp,
                                                                         log,
                                                                         uInfo,
                                                                         false,
                                                                         "",
                                                                         clientID,
                                                                         patID,
                                                                         "",
                                                                         "",
                                                                         "1"
                                                                         );
                                patientOrdersOrPrData = ReturnDataTable.createHTMLTable(ref tblOrderOrPr);
                            }

                            if (includeSvcRecordsAssessementsOrScreenings)
                            {
                                serviceRecordsDataAorS = ServiceRecords.viewList(dbConnApp,
                                                                          log,
                                                                          uInfo,
                                                                          clientID,
                                                                          groupSvcClassNameIDStr,
                                                                          "",
                                                                          patID,
                                                                          "1",
                                                                          "",
                                                                          ""
                                                                          );
                            }
                            if (includeServiceRecordsTreatments)
                            {
                                serviceRecordsDataT = ServiceRecords.viewList(dbConnApp,
                                                                          log,
                                                                          uInfo,
                                                                          clientID,
                                                                          groupSvcClassNameIDStr,
                                                                          "",
                                                                          patID,
                                                                          "2",
                                                                          "",
                                                                          ""
                                                                          );
                            }

                            if (!string.IsNullOrEmpty(storedfiles))
                            {
                                hasFiles = true;
                                Dictionary<string, string> files_ids = new Dictionary<string, string>();
                                var values = JsonConvert.DeserializeObject<Dictionary<string, string>>(storedfiles);
                                foreach (KeyValuePair<string, string> kvp in values)
                                {
                                    string fileid = kvp.Key;
                                    string filename = kvp.Value;

                                    string downloadUrl = Spedmon.StoredFiles.generatePDFViewerURL(fileid);

                                    files_ids[downloadUrl] = filename;
                                }
                                urlFileDownLoad = JsonConvert.SerializeObject(files_ids);
                            }

                        }
                        dataLoadedOk = true;
                        reqLoadedOk = false;
                    }
                    catch (Exception ex)
                    {
                        errorMessage = "An error occurred while processing the response.";
                        pageInitIsOK = false;
                    }
                }
                else
                {
                    errorMessage = "Invalid PIN.";
                }
            }
            catch(Exception ex)
            {
                errorMessage = ex.Message;
            }
        }

        /// <summary>
        /// Validates the provided PIN against the referral record.
        /// Handles scenarios such as missing PIN, referral PIN not set, or PIN mismatch.
        /// </summary>
        /// <param name="referral">The referral record containing the correct PIN.</param>
        /// <param name="inputPin">The PIN input by the user.</param>
        /// <returns>True if the PIN is valid; otherwise, false.</returns>
        private bool ValidatePin(PracPatReferralPublic referral, string inputPin)
        {
            if (string.IsNullOrWhiteSpace(inputPin))
            {
                errorMessage = "PIN is required.";
                return false;
            }

            if (!referral.pinParent.Equals(inputPin) && !referral.pinPract.Equals(inputPin))
            {
                errorMessage = "Invalid PIN.";
                return false;
            }

            return true;
        }

        /// <summary>
        /// Maps the common properties of the referral record into class-level variables.
        /// </summary>
        /// <param name="referral">The referral record to map.</param>
        private void MapReferralDataForResponse(PracPatReferralPublic rec)
        {
            // Map referral record values to class-level properties
            clientID = rec.clientID.ToString();
            pracID = rec.pracID.ToString();
            patID = rec.patID.ToString();
            recid = rec.referralID.ToString();
            clientname = rec.clientName;
            refpracname = rec.referredToPracName;
            refpracemail = rec.referredToPracEmail;
            refpracorg = rec.referredToOrgName;
            refpracphone = rec.referredToPracPhone;
            includeDiagnoses = rec.includeDiagnoses;
            includeSvcRecordsAssessementsOrScreenings = rec.includeServiceRecordsAssessementsOrScreenings;
            includeOrdersOrPrescriptions = rec.includeOrdersOrPrescriptions;
            includeServiceRecordsTreatments = rec.includeServiceRecordsTreatments;
            includeServiceNotesNonConfidential = rec.includeServiceNotesNonConfidential;
            includeServiceNotesConfidential = rec.includeServiceNotesConfidential;
            storedfiles = rec.refFileID;
        }


    }
}
