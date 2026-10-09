using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.Services.Protocols;
using System.Web.Script.Serialization;
using System.ComponentModel;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * PatientsSvc */
    /*
     * Web services end point for Patient methods.
     *
     * Unless indicated, each of these methods require that the caller is 
     * logged in.
     * 
     * Each end point method provides a wrapper for a coresponding framework
     * method that is not accessible from the outside.
     * 
     * These wrappers handle access control and parameter replacement.
     * 
     * The method is restricted to calls for given user groups
     * 
     * Parameter replacement is used to enforce additional access control within
     * the user group but this is limited.
     *
     * The final line of defense for access control are the database udfs or 
     * sprocs that return or save data
     ***************************************************************************/

    [WebService(Namespace = "http://spedcare.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]

    public class PatientsSvc : MBA.WebSvc
    {
        /***************************************************************************
         * delete */
        /**
         * "delete" a service patient record.
         * 
         * @param  validaterec   Required, True=Yes, False=No
         * @param  editDelReason Reason for delete
         * @param  recid         Record id to delete
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord delete(
                                      string editDelReason,
                                      string validaterec,
                                      string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.Patients.delete(this.dbConnApp,
                                             this.log,
                                             this.uInfo,
                                             editDelReason,
                                             validaterec,
                                             recid);
            },
              Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

        /***************************************************************************
         * deleteinline */
        /**
         * "delete" a patient record.
         * 
         * @param  recid         Record id to delete
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord deleteinline(string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.Patients.delete(this.dbConnApp,
                                             this.log,
                                             this.uInfo,
                                             @"",
                                             "0",
                                             recid);
            },
              Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

        /***************************************************************************
         * undelete */
        /**
         * "undelete" a patient record.
         * 
         * @param  validaterec   Required, True=Yes, False=No
         * @param  editDelReason Reason for delete
         * @param  recid         Record id to delete
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord undelete(
                                      string editDelReason,
                                      string validaterec,
                                      string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.Patients.unDelete(this.dbConnApp,
                                             this.log,
                                             this.uInfo,
                                             editDelReason,
                                             validaterec,
                                             recid);
            },
              Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

        /***************************************************************************
         * undelete */
        /**
         * "undelete" a patient record.
         * 
         * @param  validaterec   Required, True=Yes, False=No
         * @param  editDelReason Reason for delete
         * @param  recid         Record id to delete
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord undeleteinline(string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.Patients.unDelete(this.dbConnApp,
                                             this.log,
                                             this.uInfo,
                                             "",
                                             "0",
                                             recid);
            },
              Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

        /***************************************************************************
         * saveprofile */
        /**
        * Save patient records
        ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord saveprofile(
            string clientid
          , string siteid
          , string studentid
          , string grade
          , string lname
          , string fname
          , string mname
          , string p_nickname
          , string teacherorcounselorname
          , string dob
          , string sex
          , string parentConsentMCAL
          , string parentConsentMCALEffectiveDate
          , string ferpaconsent
          , string ferpaconsenteffectivedate
          , string treatmentconsent
          , string treatmentconsenteffectivedate
          , string cybhitpaapproved
          , string cybhitpaapprovedon
          , string cybhitpaid
          , string cybhisubmitclaims
          , string hasplan
          , string ssn
          , string bic
          , string csis
          , string submitclaims
          , string submitClaimsEffectiveDate
          , string notes
          , string speciallyAdaptedVehicleForTransportation
          , string intransitionalhousingstatus
          , string email
          , string phone
          , string deceased

          , string patienthomeplaceid
          , string street1
          , string street2
          , string city
          , string state
          , string zip5
          , string zip4
          , string preferredContactMethodCode
          , string minorconsent
          , string minorconsenteffectivedate
          , string editDelReason
          , string validaterec
          , string savetype
          , string recid)
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.Patients.saveProfile(
              this.dbConnApp
            , this.log
            , this.uInfo
            , clientid
            , siteid
            , studentid
            , grade
            , lname
            , fname
            , mname
            , p_nickname
            , teacherorcounselorname
            , dob
            , sex
            , parentConsentMCAL
            , parentConsentMCALEffectiveDate
            , ferpaconsent
            , ferpaconsenteffectivedate
            , treatmentconsent
            , treatmentconsenteffectivedate
            , cybhitpaapproved
            , cybhitpaapprovedon
            , cybhitpaid
            , cybhisubmitclaims
            , hasplan
            , ssn
            , bic
            , csis
            , submitclaims
            , submitClaimsEffectiveDate
            , notes
            , speciallyAdaptedVehicleForTransportation
            , intransitionalhousingstatus
            , email
            , phone
            , deceased

            , patienthomeplaceid
            , street1
            , street2
            , city
            , state
            , zip5
            , zip4
            , preferredContactMethodCode
            , minorconsent
            , minorconsenteffectivedate
            , editDelReason
            , validaterec
            , savetype
            , recid);
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

        /***************************************************************************
         * save */
        /**
        * Save patient records
        ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord save
          (string clientid,
           string siteid,
           string studentid,
           string grade,

           string lname,
           string fname,
           string mname,

           string p_nickname,

           string teacherorcounselorname,

           string dob,
           string sex,
           string parentConsentMCAL,
           string parentConsentMCALEffectiveDate,

           string ferpaconsent,
           string ferpaconsenteffectivedate,
           string treatmentconsent,
           string treatmentconsenteffectivedate,

           string cybhitpaapproved,
           string cybhitpaapprovedon,
           string cybhitpaid,
           string cybhisubmitclaims,

           string hasplan,
           string ssn,
           string bic,
           string csis,
           string submitclaims,
           string submitClaimsEffectiveDate,
           string notes,
           string speciallyAdaptedVehicleForTransportation,
           string spedspecialtransportation,
           string spedlastevaldate,
           string spedlastannualiepdate,
           string spednextannualiepdate,
           string spedcuriepdate,
           string speddisability1code,
           string speddisability2code,
           string spedcasemanagername,
           string spedexitedspeddate,
           string spedstudentstrengths,
           string spedparentconcerns,
           string spedprogressmonitoringdata,
           string spedstudentpresentlevelsstatement,
           string spedstudentdisabilityaffectsperformance,
           string spedcureligibilitydate,
           string spediniteligibilitydate,
           string spediepattendeesidentified,
           string spedeligibilityreasons,
           string spedplantranslatetolanguagecodeid,
           string spedinitrefdate,
           string spedreferringpartycode,
           string spedreferringpartyotheroption,
           string speddistrictreceivedparentconsentdate,
           string spedmeetingpurposedatajson,
           string spedadditionalmeetingpurposedatajson,
           string spedamendmentreasonsdatajson,
           string spedplantypecode,
           string spedstudentlanguagecodeid,
           string spedstudentracecode,
           string spednextevaldate,
           string spedenteredspeddate,
           string spedstudentlanguageenglishlearner,
           string spedstudentlanguageinforeclassified,
           string spedstudentlanguageenglishlearnerundesignatedpreschool,
           string spedstudentlanguageinterpreterneeded,
           string spedstudentlanguagetranslationrequested,
           string spedservicesdatajson,

           string spedtransitiongoaleducation,
           string spedtransitiongoaltraining,
           string spedtransitiongoalemployment,
           string spedtransitiongoalindependentliving,

           string intransitionalhousingstatus,

           string speddevacafunskillsreading,
           string speddevacafunskillswriting,
           string speddevacafunskillsmath,
           string speddevacafunskillscommunicationdev,
           string speddevacafunskillsgrossfinemotordev,
           string speddevacafunskillshealth,
           string speddevacafunskillsvocational,
           string speddevacafunskillsadaptivedailyliving,
           string speddevacafunskillsareasofneccessity,

           string spedparticipantdetails,

           string editDelReason,
           string validaterec,
           string savetype,
           string recid)
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.Patients.save
           (this.dbConnApp,
            this.log,
            this.uInfo,
            clientid,
            siteid,
            studentid,
            grade,

            lname,
            fname,
            mname,

            p_nickname,

            teacherorcounselorname,

            dob,
            sex,
            parentConsentMCAL,
            parentConsentMCALEffectiveDate,

            ferpaconsent,
            ferpaconsenteffectivedate,
            treatmentconsent,
            treatmentconsenteffectivedate,

            cybhitpaapproved,
            cybhitpaapprovedon,
            cybhitpaid,
            cybhisubmitclaims,

            hasplan,
            ssn,
            bic,
            csis,
            submitclaims,
            submitClaimsEffectiveDate,
            notes,
            speciallyAdaptedVehicleForTransportation,
            spedspecialtransportation,
            spedlastevaldate,
            spedlastannualiepdate,
            spednextannualiepdate,
            spedcuriepdate,
            speddisability1code,
            speddisability2code,
            spedcasemanagername,
            spedexitedspeddate,
            spedstudentstrengths,
            spedparentconcerns,
            spedprogressmonitoringdata,
            spedstudentpresentlevelsstatement,
            spedstudentdisabilityaffectsperformance,
            spedcureligibilitydate,
            spediniteligibilitydate,
            spediepattendeesidentified,
            spedeligibilityreasons,
            spedplantranslatetolanguagecodeid,
            spedinitrefdate,
            spedreferringpartycode,
            spedreferringpartyotheroption,
            speddistrictreceivedparentconsentdate,
            spedmeetingpurposedatajson,
            spedadditionalmeetingpurposedatajson,
            spedamendmentreasonsdatajson,
            spedplantypecode,
            spedstudentlanguagecodeid,
            spedstudentracecode,
            spednextevaldate,
            spedenteredspeddate,
            spedstudentlanguageenglishlearner,
            spedstudentlanguageinforeclassified,
            spedstudentlanguageenglishlearnerundesignatedpreschool,
            spedstudentlanguageinterpreterneeded,
            spedstudentlanguagetranslationrequested,
            spedservicesdatajson,
            spedtransitiongoaleducation,
            spedtransitiongoaltraining,
            spedtransitiongoalemployment,
            spedtransitiongoalindependentliving,

            intransitionalhousingstatus,

            speddevacafunskillsreading,
            speddevacafunskillswriting,
            speddevacafunskillsmath,
            speddevacafunskillscommunicationdev,
            speddevacafunskillsgrossfinemotordev,
            speddevacafunskillshealth,
            speddevacafunskillsvocational,
            speddevacafunskillsadaptivedailyliving,
            speddevacafunskillsareasofneccessity,

            spedparticipantdetails,
            editDelReason,
            validaterec,
            savetype,
            recid);
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

        /***************************************************************************
         * saveiep */
        /**
        * Save patient IEP records
        ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord saveiep(
           string clientid
         , string patid
         , string spedspecialtransportation
         , string spedlastevaldate
         , string spedlastannualiepdate
         , string spednextannualiepdate
         , string spedcuriepdate
         , string speddisability1code
         , string speddisability2code
         // , string spedcasemanagername
         , string spedexitedspeddate
         , string spedstudentstrengths
         , string spedparentconcerns
         , string spedprogressmonitoringdata
         , string spedstudentpresentlevelsstatement
         , string spedstudentdisabilityaffectsperformance
         , string spedcureligibilitydate
         , string spediniteligibilitydate
         , string spediepattendeesidentified
         , string spedeligibilityreasons
         , string spedplantranslatetolanguagecodeid
         , string spedinitrefdate
         , string spedreferringpartycode
         , string spedreferringpartyotheroption
         , string speddistrictreceivedparentconsentdate
         , string spedmeetingpurposedatajson
         , string spedadditionalmeetingpurposedatajson
         , string spedamendmentreasonsdatajson
         , string spedplantypecode
         , string spedstudentlanguagecodeid
         , string spedstudentracecode
         , string spednextevaldate
         , string spedenteredspeddate
         , string spedstudentlanguageenglishlearner
         , string spedstudentlanguageinforeclassified
         , string spedstudentlanguageenglishlearnerundesignatedpreschool
         , string spedstudentlanguageinterpreterneeded
         , string spedstudentlanguagetranslationrequested
         , string spedservicesdatajson
         , string spedtransitiongoaleducation
         , string spedtransitiongoaltraining
         , string spedtransitiongoalemployment
         , string spedtransitiongoalindependentliving
         , string speddevacafunskillsreading
         , string speddevacafunskillswriting
         , string speddevacafunskillsmath
         , string speddevacafunskillscommunicationdev
         , string speddevacafunskillsgrossfinemotordev
         , string speddevacafunskillshealth
         , string speddevacafunskillsvocational
         , string speddevacafunskillsadaptivedailyliving
         , string speddevacafunskillsareasofneccessity
         , string speddevacafunskillssocialemotionalbehavioral
         , string spedparticipantdetailsjson
         , string spedproceduralsafeguardssentdate
         , string spedspecialtransportationcomments
         , string spedvehicleadaptationtype
         , string speciallyadaptedvehiclefortransportation
         , string spedcorrectiondetails
         , string spedpreferredlanguagecodeid
         , string spedpresentlevelsdatajson
         , string spedpresentlevelspreparedby
         , string spedpresentlevelspreparedbyname
         , string spedstudentstrengthssourcejson
         , string spedstudentstrengthsimpact
         , string spedparentconcernssourcejson
         , string spedreadingreviewedna
         , string spedreadingsourcejson
         , string spedreadingbaselinevalue
         , string spedreadingbaselineunit
         , string spedreadingtoolsused
         , string spedreadingtoolsusedjson
         , string spedreadingbaselinedate
         , string spedreadingimpactsummary
         , string spedwritingreviewedna
         , string spedwritingsourcejson
         , string spedwritingbaselinevalue
         , string spedwritingbaselineunit
         , string spedwritingtoolsused
         , string spedwritingtoolsusedjson
         , string spedwritingbaselinedate
         , string spedwritingimpactsummary
         , string spedmathreviewedna
         , string spedmathsourcejson
         , string spedmathbaselinevalue
         , string spedmathbaselineunit
         , string spedmathtoolsused
         , string spedmathtoolsusedjson
         , string spedmathbaselinedate
         , string spedmathimpactsummary
         , string spedcommunicationdevreviewedna
         , string spedcommunicationdevsourcejson
         , string spedcommunicationdevbaselinevalue
         , string spedcommunicationdevbaselineunit
         , string spedcommunicationdevtoolsused
         , string spedcommunicationdevtoolsusedjson
         , string spedcommunicationdevbaselinedate
         , string spedcommunicationdevimpactsummary
         , string spedgrossfinemotorreviewedna
         , string spedgrossfinemotorsourcejson
         , string spedgrossfinemotorbaselinevalue
         , string spedgrossfinemotorbaselineunit
         , string spedgrossfinemotortoolsused
         , string spedgrossfinemotortoolsusedjson
         , string spedgrossfinemotorbaselinedate
         , string spedgrossfinemotorimpactsummary
         , string spedhealthreviewedna
         , string spedhealthsourcejson
         , string spedhealthbaselinevalue
         , string spedhealthbaselineunit
         , string spedhealthtoolsused
         , string spedhealthtoolsusedjson
         , string spedhealthbaselinedate
         , string spedhealthimpactsummary
         , string spedvocationalreviewedna
         , string spedvocationalsourcejson
         , string spedvocationalbaselinevalue
         , string spedvocationalbaselineunit
         , string spedvocationaltoolsused
         , string spedvocationaltoolsusedjson
         , string spedvocationalbaselinedate
         , string spedvocationalimpactsummary
         , string spedadaptivedailylivingreviewedna
         , string spedadaptivedailylivingsourcejson
         , string spedadaptivedailylivingbaselinevalue
         , string spedadaptivedailylivingbaselineunit
         , string spedadaptivedailylivingtoolsused
         , string spedadaptivedailylivingtoolsusedjson
         , string spedadaptivedailylivingbaselinedate
         , string spedadaptivedailylivingimpactsummary
         , string spedsocialemotionalbehavioralreviewedna
         , string spedsocialemotionalbehavioralsourcejson
         , string spedsocialemotionalbehavioralbaselinevalue
         , string spedsocialemotionalbehavioralbaselineunit
         , string spedsocialemotionalbehavioraltoolsused
         , string spedsocialemotionalbehavioraltoolsusedjson
         , string spedsocialemotionalbehavioralbaselinedate
         , string spedsocialemotionalbehavioralimpactsummary
         , string spedstudentstrengthssource
         , string spedstudentstrengthssourcenames
         , string spedparentconcernssource
         , string spedparentconcernssourcenames
         , string spedreadingsource
         , string spedreadingsourcenames
         , string spedwritingsource
         , string spedwritingsourcenames
         , string spedmathsource
         , string spedmathsourcenames
         , string spedcommunicationdevsource
         , string spedcommunicationdevsourcenames
         , string spedgrossfinemotorsource
         , string spedgrossfinemotorsourcenames
         , string spedhealthsource
         , string spedhealthsourcenames
         , string spedvocationalsource
         , string spedvocationalsourcenames
         , string spedadaptivedailylivingsource
         , string spedadaptivedailylivingsourcenames
         , string spedsocialemotionalbehavioralsource
         , string spedsocialemotionalbehavioralsourcenames
         , string spedreadingbaselineunitnames
         , string spedwritingbaselineunitnames
         , string spedmathbaselineunitnames
         , string spedcommunicationdevbaselineunitnames
         , string spedgrossfinemotorbaselineunitnames
         , string spedhealthbaselineunitnames
         , string spedvocationalbaselineunitnames
         , string spedadaptivedailylivingbaselineunitnames
         , string spedsocialemotionalbehavioralbaselineunitnames
         , string sendmeetinginvitesflag
         , string resendparticipantemail
         , string resendparticipantname
         , string resendparticipantrole
         , string spedreadingtoolsusednames
         , string spedwritingtoolsusednames
         , string spedmathtoolsusednames
         , string spedcommunicationdevtoolsusednames
         , string spedgrossfinemotortoolsusednames
         , string spedhealthtoolsusednames
         , string spedvocationaltoolsusednames
         , string spedadaptivedailylivingtoolsusednames
         , string spedamendmentreasonsotheroption
         , string spedmeetingpurposeotheroption
         , string spedfacilitatoruserid
         , string spedfacilitatorusername
         , string spedcasemanageruserid
         , string spedcasemanagerusername
         , string spedmeetingdate
         , string spedmeetingdurationinmins
         , string spedmeetingtime
         , string spedmeetingtitle
         , string spedsocialemotionalbehavioraltoolsusednames
         , string meetingstatusoverrides
         , string editDelReason
         , string validaterec
         , string savetype
         , string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord)
           , delegate ()
           {
               return Spedmon.Patients.saveIEP(
                   this.dbConnApp
                  , this.dbConnUser
                  , this.log
                  , this.uInfo
                  , clientid
                  , patid
                  , spedspecialtransportation
                  , spedlastevaldate
                  , spedlastannualiepdate
                  , spednextannualiepdate
                  , spedcuriepdate
                  , speddisability1code
                  , speddisability2code
                  // , spedcasemanagername
                  , spedexitedspeddate
                  , spedstudentstrengths
                  , spedparentconcerns
                  , spedprogressmonitoringdata
                  , spedstudentpresentlevelsstatement
                  , spedstudentdisabilityaffectsperformance
                  , spedcureligibilitydate
                  , spediniteligibilitydate
                  , spediepattendeesidentified
                  , spedeligibilityreasons
                  , spedplantranslatetolanguagecodeid
                  , spedinitrefdate
                  , spedreferringpartycode
                  , spedreferringpartyotheroption
                  , speddistrictreceivedparentconsentdate
                  , spedmeetingpurposedatajson
                  , spedadditionalmeetingpurposedatajson
                  , spedamendmentreasonsdatajson
                  , spedplantypecode
                  , spedstudentlanguagecodeid
                  , spedstudentracecode
                  , spednextevaldate
                  , spedenteredspeddate
                  , spedstudentlanguageenglishlearner
                  , spedstudentlanguageinforeclassified
                  , spedstudentlanguageenglishlearnerundesignatedpreschool
                  , spedstudentlanguageinterpreterneeded
                  , spedstudentlanguagetranslationrequested
                  , spedservicesdatajson
                  , spedtransitiongoaleducation
                  , spedtransitiongoaltraining
                  , spedtransitiongoalemployment
                  , spedtransitiongoalindependentliving
                  , speddevacafunskillsreading
                  , speddevacafunskillswriting
                  , speddevacafunskillsmath
                  , speddevacafunskillscommunicationdev
                  , speddevacafunskillsgrossfinemotordev
                  , speddevacafunskillshealth
                  , speddevacafunskillsvocational
                  , speddevacafunskillsadaptivedailyliving
                  , speddevacafunskillsareasofneccessity
                  , speddevacafunskillssocialemotionalbehavioral
                  , spedparticipantdetailsjson
                  , spedproceduralsafeguardssentdate
                  , spedspecialtransportationcomments
                  , spedvehicleadaptationtype
                  , speciallyadaptedvehiclefortransportation
                  , spedcorrectiondetails
                  , spedpreferredlanguagecodeid
                  , spedpresentlevelsdatajson
                  , spedpresentlevelspreparedby
                  , spedpresentlevelspreparedbyname
                  , spedstudentstrengthssourcejson
                  , spedstudentstrengthsimpact
                  , spedparentconcernssourcejson
                  , spedreadingreviewedna
                  , spedreadingsourcejson
                  , spedreadingbaselinevalue
                  , spedreadingbaselineunit
                  , spedreadingtoolsused
                  , spedreadingtoolsusedjson
                  , spedreadingbaselinedate
                  , spedreadingimpactsummary
                  , spedwritingreviewedna
                  , spedwritingsourcejson
                  , spedwritingbaselinevalue
                  , spedwritingbaselineunit
                  , spedwritingtoolsused
                  , spedwritingtoolsusedjson
                  , spedwritingbaselinedate
                  , spedwritingimpactsummary
                  , spedmathreviewedna
                  , spedmathsourcejson
                  , spedmathbaselinevalue
                  , spedmathbaselineunit
                  , spedmathtoolsused
                  , spedmathtoolsusedjson
                  , spedmathbaselinedate
                  , spedmathimpactsummary
                  , spedcommunicationdevreviewedna
                  , spedcommunicationdevsourcejson
                  , spedcommunicationdevbaselinevalue
                  , spedcommunicationdevbaselineunit
                  , spedcommunicationdevtoolsused
                  , spedcommunicationdevtoolsusedjson
                  , spedcommunicationdevbaselinedate
                  , spedcommunicationdevimpactsummary
                  , spedgrossfinemotorreviewedna
                  , spedgrossfinemotorsourcejson
                  , spedgrossfinemotorbaselinevalue
                  , spedgrossfinemotorbaselineunit
                  , spedgrossfinemotortoolsused
                  , spedgrossfinemotortoolsusedjson
                  , spedgrossfinemotorbaselinedate
                  , spedgrossfinemotorimpactsummary
                  , spedhealthreviewedna
                  , spedhealthsourcejson
                  , spedhealthbaselinevalue
                  , spedhealthbaselineunit
                  , spedhealthtoolsused
                  , spedhealthtoolsusedjson
                  , spedhealthbaselinedate
                  , spedhealthimpactsummary
                  , spedvocationalreviewedna
                  , spedvocationalsourcejson
                  , spedvocationalbaselinevalue
                  , spedvocationalbaselineunit
                  , spedvocationaltoolsused
                  , spedvocationaltoolsusedjson
                  , spedvocationalbaselinedate
                  , spedvocationalimpactsummary
                  , spedadaptivedailylivingreviewedna
                  , spedadaptivedailylivingsourcejson
                  , spedadaptivedailylivingbaselinevalue
                  , spedadaptivedailylivingbaselineunit
                  , spedadaptivedailylivingtoolsused
                  , spedadaptivedailylivingtoolsusedjson
                  , spedadaptivedailylivingbaselinedate
                  , spedadaptivedailylivingimpactsummary
                  , spedsocialemotionalbehavioralreviewedna
                  , spedsocialemotionalbehavioralsourcejson
                  , spedsocialemotionalbehavioralbaselinevalue
                  , spedsocialemotionalbehavioralbaselineunit
                  , spedsocialemotionalbehavioraltoolsused
                  , spedsocialemotionalbehavioraltoolsusedjson
                  , spedsocialemotionalbehavioralbaselinedate
                  , spedsocialemotionalbehavioralimpactsummary
                  , spedstudentstrengthssource
                  , spedstudentstrengthssourcenames
                  , spedparentconcernssource
                  , spedparentconcernssourcenames
                  , spedreadingsource
                  , spedreadingsourcenames
                  , spedwritingsource
                  , spedwritingsourcenames
                  , spedmathsource
                  , spedmathsourcenames
                  , spedcommunicationdevsource
                  , spedcommunicationdevsourcenames
                  , spedgrossfinemotorsource
                  , spedgrossfinemotorsourcenames
                  , spedhealthsource
                  , spedhealthsourcenames
                  , spedvocationalsource
                  , spedvocationalsourcenames
                  , spedadaptivedailylivingsource
                  , spedadaptivedailylivingsourcenames
                  , spedsocialemotionalbehavioralsource
                  , spedsocialemotionalbehavioralsourcenames
                  , spedreadingbaselineunitnames
                  , spedwritingbaselineunitnames
                  , spedmathbaselineunitnames
                  , spedcommunicationdevbaselineunitnames
                  , spedgrossfinemotorbaselineunitnames
                  , spedhealthbaselineunitnames
                  , spedvocationalbaselineunitnames
                  , spedadaptivedailylivingbaselineunitnames
                  , spedsocialemotionalbehavioralbaselineunitnames
                  , sendmeetinginvitesflag
                  , resendparticipantemail
                  , resendparticipantname
                  , resendparticipantrole
                  , spedreadingtoolsusednames
                  , spedwritingtoolsusednames
                  , spedmathtoolsusednames
                  , spedcommunicationdevtoolsusednames
                  , spedgrossfinemotortoolsusednames
                  , spedhealthtoolsusednames
                  , spedvocationaltoolsusednames
                  , spedadaptivedailylivingtoolsusednames
                  , spedamendmentreasonsotheroption
                  , spedmeetingpurposeotheroption
                  , spedfacilitatoruserid
                  , spedfacilitatorusername
                  , spedcasemanageruserid
                  , spedcasemanagerusername
                  , spedmeetingdate
                  , spedmeetingdurationinmins
                  , spedmeetingtime
                  , spedmeetingtitle
                  , spedsocialemotionalbehavioraltoolsusednames
                  , meetingstatusoverrides
                  , editDelReason
                  , validaterec
                  , savetype
                  , recid);
           },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method
        }

        /***************************************************************************
         * merge */
        /**
        * Merge patient records
        ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord merge(string clientid
                                   , string patidstomerge
                                   , string patidtokeep
                                   , string validaterec)

        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.Patients.merge(this.dbConnApp
                                              , this.log
                                              , this.uInfo
                                              , clientid
                                              , patidtokeep
                                              , patidstomerge
                                              , validaterec);
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

        /***************************************************************************
         * viewEntity */
        /**
         * Details about the given clientID, patID
         *
         * @param  clientID       Required, client ID
         * @param  patID          Required, patient ID
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnEntity viewEntity(string clientid, string patid)
        {
            return (ReturnEntity)
            callMethod(typeof(ReturnEntity),
            delegate ()
            {
                ReturnEntity so = Spedmon.Patients.viewEntity(this.dbConnApp, this.log, this.uInfo, clientid, patid);
                so.entity.notes = Util.textToHTMLPre(so.entity.notes);
                return so;
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
        }

        /***************************************************************************
         * get */
        /**
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnObject get(string recid)
        {
            return (ReturnObject)
            callMethod(typeof(ReturnObject),
            delegate ()
            {
                ReturnObject so = Spedmon.Patients.get(this.dbConnApp, this.log, this.uInfo, recid);
                return so;
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
        }
        /***************************************************************************
         * viewSel */
        /**
         * Selection view of patients
         * 
         * @param  clientid     Required, client id
         * @param  pracid       Required, practitoner id
         * @param  term         Required, search term string (last, first)
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSel(string patdatasource, string clientid, string pracid, string term, string dos)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate ()
            {
                return Spedmon.Patients.viewSel(this.dbConnApp, this.log, this.uInfo, true, "", patdatasource, clientid, pracid, term, dos, "");
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
        }

        /***************************************************************************
         * viewSel2 */
        /**
         * Selection view of patients that includes site filter
         * 
         * @param  clientid     Required, client id
         * @param  pracid       Required, practitoner id
         * @param  term         Required, search term string (last, first)
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSel2(string patdatasource, string clientid, string pracid, string term, string dos, string siteid)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate ()
            {
                return Spedmon.Patients.viewSel(this.dbConnApp, this.log, this.uInfo, true, "", patdatasource, clientid, pracid, term, dos, siteid);
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
        }

        /***************************************************************************
         * viewSelForTransMgmt */
        /**
         * Selection view of patients for transporation management
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelForTransMgmt(string clientid, string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate ()
            {
                return Spedmon.Patients.viewSelForTransMgmt(this.dbConnApp, this.log, this.uInfo, true, "", clientid, term);
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
        }

        /***************************************************************************
         * viewSelElig */
        /**
         * Selection view of eligible patients
         * 
         * @param  clientid     Required, client id
         * @param  term         Required, search term string (last, first)
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSelElig(string clientid, string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate ()
            {
                return Spedmon.Patients.viewSel(this.dbConnApp, this.log, this.uInfo, true, "", "0", clientid, "", term, "", "");
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
        }

        /***************************************************************************
         * cybhipatsprocessfile */
        /**
         * Process cybhi pats file
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecordWithJSONData cybhipatsprocessfile(
            string clientid
          , string fileclass
          , string fromexternalsource
          , string filecontent
          , string validaterec)
        {
            return (ReturnSaveRecordWithJSONData)

            callMethod(typeof(ReturnSaveRecordWithJSONData),
            delegate ()
            {
                return Spedmon.Patients.cybhiPatsProcessFile(
              this.dbConnApp
            , this.log
            , this.uInfo
            , clientid
            , fileclass
            , fromexternalsource
            , filecontent
            , validaterec);
            },
            Constants.ROLE_SBS_ALL);  // Who can call this method           
        }

        /***************************************************************************
        * updatepatientdata */
        /**
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord updatepatientdata(string clientid
                                                , string patid
                                                , string phone
                                                , string email
                                                , string street1
                                                , string street2
                                                , string city
                                                , string state
                                                , string zip5
                                                , string zip4
                                                , string patienthomeplaceid
                                                , string contactmethod)
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Patients.updatepatientdata(
                this.dbConnApp
                , this.log
                , this.uInfo
                , clientid
                , patid
                , phone
                , email
                , street1
                , street2
                , city
                , state
                , zip5
                , zip4
                , patienthomeplaceid
                , contactmethod
                );
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

        /***************************************************************************
        * invitePatientToPortal */
        /**
         * create a new invitation to a parent/patient portal
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord invitePatientToPortal(string clientid
                                                      , string recid)
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.Patients.invitePatientToPortal(this.dbConnApp
                                                                , this.log
                                                                , this.uInfo
                                                                , clientid
                                                                , ""
                                                                , "false"
                                                                , "1"
                                                                , recid);
            },
                                        Constants.ROLE_ALL_PCAL_AND_CLIENT);
        }
    }
}