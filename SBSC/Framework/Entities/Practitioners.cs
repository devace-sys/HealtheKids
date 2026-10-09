using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;

using System.Text.RegularExpressions;
using MBA;


namespace Spedmon
{
  /***************************************************************************
   * Practitioner */
  /**
   **************************************************************************/   

  public class Practitioner:MBA.Practitioner
  {
    // TODO: Refactor users so Practitioner does not need to be declared there
  }
 
  /***************************************************************************
   * ReturnPractitioner */
  /**
   * Return class for loading a practitioner and returning the data for client
   * side use
   **************************************************************************/

  public class ReturnPractitioner : Return
  {
 
    public ReturnPractitioner ()            : base(){}
    public ReturnPractitioner (string msg)  : base(msg){}
    public ReturnPractitioner (Exception e) : base(e){}
    public ReturnPractitioner (Warning e)   : base(e){}
    public ReturnPractitioner (Critical e)  : base(e){}
    public ReturnPractitioner (SessionExpired e):base(e){}
    
    public bool         hasPractitioner = false;
    public Practitioner practitioner;
  }

  /***************************************************************************
   * Practitioners */
  /**
   * Practitioners provide services to patients.  Practitioners are associated
   * with a client.
   ***************************************************************************/

  public class Practitioners:Entities
  {


    public const string SEL_LABEL_RPT_TATTLETALE = "Practitioner Submissions Report";
    public const string MENU_ID_TATTLE_TALE_RPT = "viewtattletalelink";
    
    public const string URL_SBS_ALL_RPT_TATTLETALE = ServicesByPracRpt.URL_USER_ALL_RPT;    //"rpt_sbs_tattletale_report.aspx";
    public const string URL_LEA_COORD_RPT_TATTLETALE = ServicesByPracRpt.URL_USER_ALL_RPT;  //"rpt_sbs_tattletale_report.aspx";

    public const string SEL_LABEL_MANAGE    = @"Manage Practitioners";
    public const string SEL_LABEL_SAVE      = @"Practitioners - Save";
 
    public const string MENU_ID_MANAGE      = @"pracsmanage";
    public const string URL_SVC_BASE        = @"practitioners.asmx";
 
    public const string URL_VIEW_REPORT     = @"practitioners.ashx";          
    public const string URL_USER_ALL_MANAGE = @"user_all_prac_manage.aspx";          
    public const string URL_USER_ALL_SAVE   = @"user_all_prac_save.aspx"; 
    public const string URL_USER_ALL_VIEW   = @"user_all_prac_view.aspx";          

    public const string URL_REST_VIEW             = @"api/v1/practitioners";
    public const string URL_SVC_DELETE_INLINE     = URL_SVC_BASE + @"/deleteinline";
    public const string URL_SVC_UNDELETE_INLINE   = URL_SVC_BASE + @"/undeleteinline";

    public const string URL_VIEW_SEL    = URL_SVC_BASE + "/viewSel";
    public const string URL_VIEW_SEL2   = URL_SVC_BASE + "/viewSel2";
    public const string URL_GET_PRAC    = URL_SVC_BASE + "/getPractitioner";
    public const string URL_NPI_LOOKUP  = URL_SVC_BASE + "/npiLookup";

    public const string URL_FLAG_CURR_W_CLIENT     = URL_SVC_BASE + "/updateflagcurrentlywclient";
    public const string URL_SVC_CYBHI_PROCESS_FILE = URL_SVC_BASE + "/cybhipracsprocessfile";


    public static string URL_NPI_LOOKUP_BASE()
    { 
       return MBA.HttpApplication.createLink( URL_NPI_LOOKUP, true);                                                            
    }

    /***************************************************************************
     * Rest view methods */
    /**
     * 
     **************************************************************************/

    public static string URL_REST_VIEW_BASE()
    { 
       return MBA.HttpApplication.createLink(Practitioners.URL_REST_VIEW, true);
    }
    public static string URL_WEB_REPORT_BASE()
    { 
       return MBA.HttpApplication.createLink(Practitioners.URL_VIEW_REPORT, true);
    }

    public static string URL_SVC_CYBHI_PROCESS_FILE_BASE()
    {
        return MBA.HttpApplication.createLink(Practitioners.URL_SVC_CYBHI_PROCESS_FILE
                                                , true);
    }

    public static string URL_CYBHI_PROCESS_FILE_BASE ()
    {
        return MBA.HttpApplication.createLink( "user_all_cybhi_practitioner_process_tpa_file.aspx"
                                                , true);                        
    }

    /***************************************************************************
     * URL_SVC_DELETE_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_SVC_DELETE_INLINE_BASE()
    { 
       return MBA.HttpApplication.createLink(Practitioners.URL_SVC_DELETE_INLINE, true);
    }        

    /***************************************************************************
     * URL_SVC_UNDELETE_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_SVC_UNDELETE_INLINE_BASE()
    { 
       return MBA.HttpApplication.createLink(Practitioners.URL_SVC_UNDELETE_INLINE, true);
    }        


    public static string URL_FLAG_CURR_W_CLIENT_BASE()
    { 
       return MBA.HttpApplication.createLink(Practitioners.URL_FLAG_CURR_W_CLIENT, true);
    }
        
    /***************************************************************************
     * URL_VIEW_SEL2_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_VIEW_SEL2_BASE()
    { 
       return MBA.HttpApplication.createLink(Practitioners.URL_VIEW_SEL2, true);
    }

        
    /***************************************************************************
     * URL_SAVE_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_SAVE_BASE()
    { 
       return MBA.HttpApplication.createLink(Spedmon.Practitioners.URL_USER_ALL_SAVE
                                                                      , true);
    }


        
    /***************************************************************************
     * URL_SAVE_NEW_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_SAVE_NEW_BASE()
    { 
       return MBA.HttpApplication.createLink(Spedmon.Practitioners.URL_USER_ALL_SAVE
                                                                      , true
                                                                      , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                                      , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW));
    }

    /***************************************************************************
     * URL_EDIT_EXISTING_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_EDIT_EXISTING_BASE(string recID = "")
    { 
       return MBA.HttpApplication.createLink(Spedmon.Practitioners.URL_USER_ALL_SAVE
                                                                      , true
                                                                      , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                                      , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT)
                                                                      , new NameValue(Constants.PARM_REC_ID, recID));
    }        
    /***************************************************************************
     * URL_GET_PRAC_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_GET_PRAC_BASE()
    { 
       return MBA.HttpApplication.createLink(Spedmon.Practitioners.URL_GET_PRAC
                                                                      , true);
    }

    public static string URL_MANAGE_BASE()
    {
            return MBA.HttpApplication.createLink("user_all_prac_manage.aspx", true);
    }

    /***************************************************************************
     * isPracSomeoneWhoCanAddEditViewDelOtherPracs */
    /**
     * 
     **************************************************************************/

    public static bool isPracSomeoneWhoCanAddEditViewDelOtherPracs (ref RequestResponse rd) {      
      return ServiceJournals.isPracSomeoneWhoCanRecordServiceRecords(ref rd);
    }


     
    /***************************************************************************
     * isPracADepartmentHead */
    /**
     * is the prac a department head?
     ***************************************************************************/
    
    public static bool isPracADepartmentHead (ref RequestResponse rd)
    {
       if (rd.wu.pr != null) 
       { 
         if (rd.wu.pr.deptHead == true) return true;
       }
       return false;
    }
      
    /***************************************************************************
     * createNotesTemplateText */
    /**
     * Creates template text used for free form notes
     ***************************************************************************/
     
    public static string createNotesTemplateText()
    {
      StringBuilder sb = new StringBuilder();
      
      sb.AppendLine("-CREDENTIAL INFORMATION-");
      sb.AppendLine();
      sb.AppendLine("Document #: ");
      sb.AppendLine("Issuance Date: ");
      sb.AppendLine("Expiration Date: ");
      sb.AppendLine("Authorized Subjects: ");
      sb.AppendLine("Full Name: ");
      sb.AppendLine("Updated by: ");
      sb.AppendLine("Date Updated: ");
      
      sb.AppendLine();
      sb.AppendLine("-LICENSE INFORMATION-");
      sb.AppendLine();
      sb.AppendLine("License #: ");
      sb.AppendLine("License Type: ");
      sb.AppendLine("Issuance Date: ");
      sb.AppendLine("Expiration Date: ");
      sb.AppendLine("Full Name: ");
      sb.AppendLine("Updated by: ");
      sb.AppendLine("Date Updated: ");
      
      sb.AppendLine();
      sb.AppendLine("-SUPERVISOR INFORMATION-");
      sb.AppendLine();
      sb.AppendLine("Supervisor's SpEdCare Practitioner ID #: ");
      sb.AppendLine("Supervisor's Credential or License Type: ");
      sb.AppendLine("Document #: ");
      sb.AppendLine("Issuance Date: ");
      sb.AppendLine("Expiration Date: ");
      sb.AppendLine("Full Name: ");
      sb.AppendLine("Updated by: ");
      sb.AppendLine("Date Updated: ");     
      sb.AppendLine();
      
      return sb.ToString();
    }
    
    /***************************************************************************
     * delete */
    /**
     * "Deletes" a practitioner record
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    public static ReturnSaveRecord delete (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, 
                                           string editDelReason, string validateRec, string recID)
    {           
     
      /*----------------------------
       * Check for required and 
       * optional parameters
       * and validate data integrity
       * of all supplied parameters
       *----------------------------*/

      Object vClientID = Validate.optClientID(uInfo, ""); 
     
      /*----------------------------
       * Collect all of the parameters
       * that are specific to this
       * delete method.
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
      parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
     
     /*----------------------------
      * Call base method 
      *----------------------------*/
     
      return Entities.delete(connSpedmon,log,uInfo,editDelReason,validateRec,recID,"PRACTITIONERS_Delete",ref parms);
    }


    /***************************************************************************
     * unDelete */
    /**
     * "Un Deletes" a practitioner record
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    public static ReturnSaveRecord unDelete (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, 
                                           string editDelReason, string validateRec, string recID)
    {           
     
      /*----------------------------
       * Check for required and 
       * optional parameters
       * and validate data integrity
       * of all supplied parameters
       *----------------------------*/

      Object vClientID = Validate.optClientID(uInfo, ""); 
     
      /*----------------------------
       * Collect all of the parameters
       * that are specific to this
       * delete method.
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
      parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
     
     /*----------------------------
      * Call base method 
      *----------------------------*/
     
      return Entities.unDelete(connSpedmon,log,uInfo,editDelReason,validateRec,recID,"PRACTITIONERS_Undelete",ref parms);
    }

   /***************************************************************************
    * load */
   /**
    * Outputs data for a single practitioner
    * 
    * Note: This calls the view method and the view method takes care of
    * enforcing the client id.
    * 
    * @param  connSpedmon     Spedmon database connection object
    * @param  log             Logging object
    * @param  clientID        Client ID
    * @param  pracID          PractitionerID
    * @return                 ReturnEntity
    ***************************************************************************/ 
    
    public static Practitioner load (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, 
                                     string recID)
    { 
      return (Practitioner) Entities.load (connSpedmon, log, uInfo , recID, typeof(Practitioner),
      delegate{return Practitioners.view (connSpedmon,log,uInfo,Entities.REC_VIEW_LOAD, false, recID, "", "", "", "", "", "", "", "", "", "","",null);});      
    } 

   
   /***************************************************************************
    * getPractitioner*/
   /**
    * Outputs data for a single practitioner
    * 
    * Note: This calls the load method and the load method takes care of
    * enforcing the client id.
    * 
    * @param  connSpedmon     Spedmon database connection object
    * @param  log             Logging object    
    * @param  recID           PractitionerID
    * @return                 ReturnEntity
    ***************************************************************************/ 
    
    public static ReturnPractitioner getPractitioner (   SqlConnection connSpedmon
                                                       , DetailsLog log
                                                       , UserInfo uInfo
                                                       , string recID)
    { 

      ReturnPractitioner rp = new ReturnPractitioner();
      try
      { 
        rp.hasPractitioner = false;      
        rp.practitioner = load (connSpedmon,log,uInfo,recID);
        rp.hasPractitioner = true;        
      }
      catch (Exception e)
      {
        rp = new ReturnPractitioner(e);        
        rp.hasPractitioner = false;      
      }
      
      return rp;

    } 

    
    /***************************************************************************
    * save */
    /**
    * Save a practitioner record
    *
    * @param  userID          User id of who is recording service
    * @param  userGroup       1 = Client, 2 = SBSC (from users db)
    * @param  userRank        Users role ranking
    * @param  clientID        Patient's client id
    * @param  lname           Patient's last name
    * @param  fname           Patient's first name
    * @param  startDate       Practitioners startdate   
    * @param  groupDisp
    * @param  groupRept 
    * @param  email
    * @param  phone
    * @param  fax
    * @param  claim_TCM       Claim TCM for reimbursement
    * @param  notes
    * @param  editDelReason   Reason for record edit or delete
    * @param  validateRec     1 = Performs data integrity validation tasks
    *                             Perform advisory validation tasks that can
    *                             only be conducted by referencing data from the
    *                             database and then exits WITHOUT saving the record
    *                         0 = Peform data integrity validation tasks and
    *                             if these tasks succeed peforms the desired
    *                             operation (saveType) on the record and exits
    * @param  saveType        Type of operation to perform
    *                         1 = New, 2 = Edit, 3 = Delete
    * @param  recID           Record id of existing patient record to edit or
    *                         delete.
    * @return                 ReturnSaveNewRecord
    ***************************************************************************/

    public static ReturnSaveRecord save (  SqlConnection connSpedmon
                                         , DetailsLog    log
                                         , UserInfo      uInfo
                                         , string        clientID
                                         , string        lname
                                         , string        fname
                                         , string        groupDisp
                                         , string        employeeRelationship
                                         , string        clientEmployeeID
                                         , string        startDate
                                         , string        endDate
                                         , string        cprCertEffectiveDate
                                         , string        cprCertExpirationDate
                                         , string        email
                                         , string        phone
                                         , string        fax
                                         , string        street1
                                         , string        street2
                                         , string        city
                                         , string        state
                                         , string        zip5
                                         , string        zip4
                                         , string        npiNumber
                                         , string        isValidMcalOrp
                                         , string        isValidMcalOrpLastValidated                                         
                                         , string        groupRept
                                         , string        incInFinRepts

                                         , string        participatesinleabop
                                         , string        participatesinleabopnonsped
                                         , string        participatesincyhbi
                                         , string        participatesinruhealth

                                         , string        currentlywithclient

                                         , string        submitClaims
                                         , string        submitClaimsEffectiveDate                                         
                                         , string        claim_TCM
                                         , string        claim_TCMEffectiveDate
                                         , string        cybhiTpaApproved
                                         , string        cybhiTpaApprovedOn
                                         , string        cybhiTpaID
                                         , string        cybhiSubmitClaims

                                         , string        notes
                                         , string        qualificationsJSONData
                                         , string        deptHead
                                         , string        deptHeadCanSeeEntirePracticeFamilyInDeptReviewReports
                                         , string        displayPercent
                                         , string        displayMoney
                                         , string        acesCertCompletedOn
                                         , string        dob
                                         , string        gender
                                         , string        ssn
                                         , string        cybhiDegreeCode
                                         , string        cybhiDegreeCode2
                                         , string        cybhiDegreeCode3
                                         , string        cybhiSpecialtyCode
                                         , string        cybhiSpecialtyCode2
                                         , string        cybhiSpecialtyCode3
                                         , string        cybhiSpecialtyCode4
                                         , string        editDelReason
                                         , string        validateRec
                                         , string        saveType
                                         , string        recID )
    {           


      /*----------------------------
       * If a prac is entering a 
       * NEW prac we need to provide
       * default values for the hidden
       * fields.  If they are editing
       * an existing prac we will
       * use the passed in values.
       *----------------------------*/

      if (saveType == Constants.SAVE_TYPE_NEW.ToString())
      {
        if (uInfo.userRoleLower == Constants.ROLE_LEA_PROVIDER)
        {
          /* Practitioner is usually only adding a third party ORP as part of the order process and they don't have access
           * to the tabs that present these fields so we provide the required answers here. */

          string today = DateTime.Now.ToShortDateString();
          employeeRelationship        = ((int) EmploymentRelationship.NONE).ToString();
          incInFinRepts               = "No";
          submitClaims                = "No";
          participatesinleabop        = "No";  /* Third party ORP */
          participatesinleabopnonsped = "No";
          participatesincyhbi         = "No";  /* Third party ORP */
          submitClaimsEffectiveDate   = today;
          claim_TCM                   = @"No";
          claim_TCMEffectiveDate      = today;          
        }
      }
      
      List<SqlParameter> parms = new List<SqlParameter>();
            
      /*----------------------------
       * Check for required and 
       * optional parameters
       * and validate data integrity
       * of all supplied parameters
       *----------------------------*/
      
      int      vClientID                     = Validate.reqClientID             (uInfo, clientID);
      string   vLname                        = Validate.reqString               (lname,                       Messages.INVALID_LNAME);
      string   vFname                        = Validate.reqString               (fname,                       Messages.INVALID_FNAME);
      long     vGroupDisp                    = Validate.reqInteger              (groupDisp,                   Messages.INVALID_GROUP_ID);
      long     vEmployeeRelationship         = Validate.reqInteger              (employeeRelationship,        Messages.INVALID_EMPLOYEE_RELATIONSHIP);
      Object   vClientEmployeeID             = Validate.optString               (clientEmployeeID,            Messages.INVALID_EMPLOYEE_ID); 
      Object   vStartDate                    = Validate.optDate                 (startDate,                   Messages.INVALID_START_DATE);
      Object   vEndDate                      = Validate.optDate                 (endDate,                     Messages.INVALID_END_DATE);
      Object   vCprCertEffectiveDate         = Validate.optDate                 (cprCertEffectiveDate,        Messages.INVALID_START_DATE);
      Object   vCprCertExpirationDate        = Validate.optDate                 (cprCertExpirationDate,       Messages.INVALID_END_DATE);
      Object   vEmail                        = Validate.optEmail                (email,                       Messages.INVALID_EMAIL);
      Object   vPhone                        = Validate.optPhoneNumber          (phone,                       Messages.INVALID_PHONE_NUMBER);
      Object   vFax                          = Validate.optPhoneNumber          (fax,                         Messages.INVALID_PHONE_NUMBER);            
      Object   vNpiNumber                    = Validate.optNPI                  (npiNumber);
      Object   vIsValidMcalOrp               = Validate.reqFlagOrUnknown        (isValidMcalOrp,              @"Invalid is valid orp value");
      Object   vIsValidMcalOrpLastValidated  = Validate.optDate                 (isValidMcalOrpLastValidated, @"Invalid is valid orp date");
      Object   vGroupRept                    = Validate.optInteger              (groupRept,                   Messages.INVALID_GROUP_ID);
      
      bool     vIncInFinRepts                = Validate.reqFlag                 (incInFinRepts,               Messages.INVALID_INCLUDE_IN_REPTS);

      bool     vParticipatesInLEABOP         = Validate.reqFlag (participatesinleabop,        @"Invalid value for participates in LEA BOP SpEd",     true);
      bool     vParticipatesInLEABOPNonSpEd  = Validate.reqFlag (participatesinleabopnonsped, @"Invalid value for participates in LEA BOP Non SpEd", true);
      bool     vParticipatesInCYBHI          = Validate.reqFlag (participatesincyhbi,         @"Invalid value for participates in CYBHI",            true);
      bool     vParticipatesInRuHealth       = Validate.reqFlag (participatesinruhealth,      @"Invalid value for participates in RU Health",        true);

      bool     vCurrentlyWithClient          = Validate.reqFlag( currentlywithclient,         @"Invalid value for currently with client?", true);


      bool     vSubmitClaims                 = Validate.reqFlag                 (submitClaims,                Messages.SUB_CLMS_FLAG_BAD);

      DateTime vSubmitClaimsEffectiveDate    = Validate.reqDate                 (submitClaimsEffectiveDate,   Messages.INVALID_SUBMIT_CLAIMS_EFF_DATE);
      Object   vclaim_TCM                    = Validate.reqFlagOrUnknown        (claim_TCM,                   Messages.INVALID_CLAIM_TCM);      
      DateTime vclaim_TCMEffectiveDate       = Validate.reqDate                 (claim_TCMEffectiveDate,      Messages.INVALID_CLAIM_TCM_EFF_DATE);
      Object   vCybhiTpaApproved             = Validate.reqFlag                 (cybhiTpaApproved,            @"Invalid cybhiTpaApproved flag", true);
      Object   vCybhiTpaApprovedOn           = Validate.optDate                 (cybhiTpaApprovedOn,          @"Invalid cybhiTpaApprovedOn date ");
      Object   vCybhiTpaID                   = Validate.optString               (cybhiTpaID,                  @"Invalid cybhiTpaID");
      bool     vCybhiSubmitClaims            = Validate.reqFlag                 (cybhiSubmitClaims,           @"Invalid cybhiSubmitClaims flag", true);
      Object   vNotes                        = Validate.optString               (notes,                       Messages.INVALID_NOTES);      
      Object   vQualificationsJSONData       = Validate.optString               (qualificationsJSONData,      @"Invalid Qualification Data");      
      
      var      vDisplayPercent               = Validate.reqFlag                 (displayPercent,              Messages.INVALID_FLAG);
      var      vDisplayMoney                 = Validate.reqFlag                 (displayMoney,                Messages.INVALID_FLAG);

      var      vAcesCertCompletedOn          = Validate.optDate                 (acesCertCompletedOn,         @"Invalid ACES date");

      bool     vDeptHead                     = Validate.reqFlag                 (deptHead,                    @"Invalid department head flag");

      bool     vDeptHeadCanSeeEntirePracticeFamilyInDeptReviewReports = Validate.reqFlag (deptHeadCanSeeEntirePracticeFamilyInDeptReviewReports, @"Invalid department head can review flag");
            
      var     vDob                = Validate.optDate   (dob,                 Messages.INVALID_DOB);
      var     vGender             = Validate.optSex    (gender,              Messages.INVALID_SEX);
      var     vSsn                = Validate.optSSN    (ssn,                 Messages.INVALID_SSN);
      var     vCybhiDegreeCode    = Validate.optString (cybhiDegreeCode,     "Invalid CYBHI degree code");
      var     vCybhiDegreeCode2   = Validate.optString (cybhiDegreeCode2,    "Invalid CYBHI degree code");
      var     vCybhiDegreeCode3   = Validate.optString (cybhiDegreeCode3,    "Invalid CYBHI degree code");
      var     vCybhiSpecialtyCode = Validate.optString (cybhiSpecialtyCode,  "Invalid CYBHI speciality code");
      var     vCybhiSpecialtyCode2 = Validate.optString (cybhiSpecialtyCode2,  "Invalid CYBHI speciality code");
      var     vCybhiSpecialtyCode3 = Validate.optString (cybhiSpecialtyCode3,  "Invalid CYBHI speciality code");
      var     vCybhiSpecialtyCode4 = Validate.optString (cybhiSpecialtyCode4,  "Invalid CYBHI speciality code");

      /*----------------------------
       * Validate and add USPS address
       * values and parms
       *----------------------------*/

     validateAndAddCommonAddressParameters (  ref street1
                                            , ref street2
                                            , ref city
                                            , ref state
                                            , ref zip5
                                            , ref zip4
                                            , ref parms);
      
     /*----------------------------
      * Collect all of the remaining
      * parameters that are specific
      * to this save method.
      *----------------------------*/
            
      parms.Add(Database.SqlParm("@clientID",                    SqlDbType.Int,      vClientID,                      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@lname",                       SqlDbType.VarChar,  vLname,                         ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@fname",                       SqlDbType.VarChar,  vFname,                         ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@groupIDDisp",                 SqlDbType.Int,      vGroupDisp,                     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@employeeRelationship",        SqlDbType.BigInt,   vEmployeeRelationship,          ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@clientEmployeeID",            SqlDbType.VarChar,  vClientEmployeeID,              ParameterDirection.Input, 500));            
      parms.Add(Database.SqlParm("@startDate",                   SqlDbType.DateTime, vStartDate,                     ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@endDate",                     SqlDbType.DateTime, vEndDate,                       ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@cprCertEffectiveDate",        SqlDbType.Date,     vCprCertEffectiveDate,                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@cprCertExpirationDate",       SqlDbType.Date,     vCprCertExpirationDate,                    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@email",                       SqlDbType.VarChar,  vEmail,                         ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@phone",                       SqlDbType.VarChar,  vPhone,                         ParameterDirection.Input, 14));
      parms.Add(Database.SqlParm("@fax",                         SqlDbType.VarChar,  vFax,                           ParameterDirection.Input, 14));              
      parms.Add(Database.SqlParm("@npiNumber",                   SqlDbType.VarChar,  vNpiNumber,                     ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@isValidMcalOrp",              SqlDbType.Bit,      vIsValidMcalOrp,                ParameterDirection.Input));
      parms.Add(Database.SqlParm("@isValidMcalOrpLastValidated", SqlDbType.DateTime, vIsValidMcalOrpLastValidated,   ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@groupIDRept",                 SqlDbType.Int,      vGroupRept,                     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@incInFinRepts",               SqlDbType.Bit,      vIncInFinRepts,                 ParameterDirection.Input));

      parms.Add(Database.SqlParm("@participatesInLEABOP",        SqlDbType.Bit,      vParticipatesInLEABOP,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@participatesInLEABOPNonSpEd", SqlDbType.Bit,      vParticipatesInLEABOPNonSpEd,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@participatesInCYBHI",         SqlDbType.Bit,      vParticipatesInCYBHI,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@participatesInRUHealth",      SqlDbType.Bit,      vParticipatesInRuHealth,        ParameterDirection.Input));

      parms.Add(Database.SqlParm("@currentlyWithClient", SqlDbType.Bit, vCurrentlyWithClient, ParameterDirection.Input));

      parms.Add(Database.SqlParm("@submitClaims",                SqlDbType.Bit,      vSubmitClaims,                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@submitClaimsEffectiveDate",   SqlDbType.DateTime, vSubmitClaimsEffectiveDate,     ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@claim_TCM",                   SqlDbType.Bit,      vclaim_TCM,                     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@claim_TCMEffectiveDate",      SqlDbType.DateTime, vclaim_TCMEffectiveDate,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@cybhiTpaApproved",            SqlDbType.Bit,      vCybhiTpaApproved,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@cybhiTpaApprovedOn",          SqlDbType.Date,     vCybhiTpaApprovedOn,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@cybhiTpaID",                  SqlDbType.VarChar,  vCybhiTpaID,                    ParameterDirection.Input, 256));
      parms.Add(Database.SqlParm("@cybhiSubmitClaims",           SqlDbType.Bit,      vCybhiSubmitClaims,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@notes",                       SqlDbType.VarChar,  vNotes,                         ParameterDirection.Input, -1));      
      parms.Add(Database.SqlParm("@qualificationsJSONData",      SqlDbType.VarChar,  vQualificationsJSONData,        ParameterDirection.Input, -1));      
      parms.Add(Database.SqlParm("@displayPercent",              SqlDbType.Bit,      vDisplayPercent,                ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@displayMoney",                SqlDbType.Bit,      vDisplayMoney,                  ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@MsgNoClient",                 SqlDbType.VarChar,  Messages.INVALID_CLIENT_ID,     ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoGroup",                  SqlDbType.VarChar,  Messages.INVALID_GROUP_ID,      ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoFullEdit",               SqlDbType.VarChar,  Messages.EDIT_REC_NO_EDIT_FULL, ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@acesCertCompletedOn",         SqlDbType.Date,     vAcesCertCompletedOn,           ParameterDirection.Input));

      parms.Add(Database.SqlParm("@deptHead",                                               SqlDbType.Bit,      vDeptHead,                                                ParameterDirection.Input));
      parms.Add(Database.SqlParm("@deptHeadCanSeeEntirePracticeFamilyInDeptReviewReports",  SqlDbType.Bit,      vDeptHeadCanSeeEntirePracticeFamilyInDeptReviewReports,   ParameterDirection.Input));
            
      parms.Add(Database.SqlParm("@dob",                  SqlDbType.Date,     vDob,                ParameterDirection.Input));
      parms.Add(Database.SqlParm("@gender",               SqlDbType.VarChar,  vGender,             ParameterDirection.Input, 1));
      parms.Add(Database.SqlParm("@ssn",                  SqlDbType.VarChar,  vSsn,                ParameterDirection.Input, 9));
      parms.Add(Database.SqlParm("@cybhiDegreeCode",      SqlDbType.VarChar,  vCybhiDegreeCode,    ParameterDirection.Input, 256));
      parms.Add(Database.SqlParm("@cybhiDegreeCode2",     SqlDbType.VarChar,  vCybhiDegreeCode2,    ParameterDirection.Input, 256));
      parms.Add(Database.SqlParm("@cybhiDegreeCode3",     SqlDbType.VarChar,  vCybhiDegreeCode3,    ParameterDirection.Input, 256));
      parms.Add(Database.SqlParm("@cybhiSpecialtyCode",   SqlDbType.VarChar,  vCybhiSpecialtyCode,  ParameterDirection.Input, 256));
      parms.Add(Database.SqlParm("@cybhiSpecialtyCode2",  SqlDbType.VarChar,  vCybhiSpecialtyCode2, ParameterDirection.Input, 256));
      parms.Add(Database.SqlParm("@cybhiSpecialtyCode3",  SqlDbType.VarChar,  vCybhiSpecialtyCode3, ParameterDirection.Input, 256));
      parms.Add(Database.SqlParm("@cybhiSpecialtyCode4",  SqlDbType.VarChar,  vCybhiSpecialtyCode4, ParameterDirection.Input, 256));

      /*----------------------------
       * Call base method with 
       * the new parms and the
       * pre database call validate
       * delegate
       *----------------------------*/

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "PRACTITIONERS_Save", Messages.DUP_PRAC_REC, ref parms, null);
    }

    /***************************************************************************
     * rptCybhiPracsTPAExport */
    /**
     * Returns a list of CYBHI providers for submission to the third party admin 
     * (TPA).  The list is limited to provider rows that are OK for export.
     * OK for export = all criticial and required fields as defined by the TPA
     * are filled out.
     * 
     * Please see http://sbscitdev.help4schools.com/dokuwiki/lib/exe/fetch.php?media=cybhi:2._carelon_standard_provider_data_exchange_layout_guide.pdf
     * for more information on what fields are critical and required.
     * 
     * @return ReturnDataTable
     ***************************************************************************/
    
    public static ReturnDataTable rptCybhiPracsTPAExport (  SqlConnection connSpedmon
                                                          , DetailsLog    log
                                                          , UserInfo      uInfo
                                                          , bool          paged
                                                          , string        pageNumber
                                                          , string        clientID )
    {
      ReturnDataTable so = new ReturnDataTable();

      var vClientID = Validate.reqClientID(uInfo,clientID);
      var clc       = Clients.load(connSpedmon,log,uInfo,clientID);
      var parms     = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
      string udf = @"dbo.CYBHI_PROVIDER_LIST_TPA_EXPORT_RPT(@clientID)";

      /* Note: the viewTitle (filename) convention is defined by the TPA. See http://sbscitdev.help4schools.com/dokuwiki/lib/exe/fetch.php?media=cybhi:2._carelon_standard_provider_data_exchange_layout_guide.pdf
       * for more info */

      string viewTitle = clc.cybhiClientCode 
                       + "toCarelon_Provider_" 
                       +  DateTime.Today.ToYYYYMMDDString();

      so = viewRpt(connSpedmon,log,uInfo,paged, pageNumber, "Y", udf, parms, null, null,viewTitle,Messages.DATA_VIEW_NO_FOOTER);

      return so;
    }                          

    /***************************************************************************
     * rptCybhiPracsAudit */
    /**
     * Returns a list of CYBHI providers for submission to the third party admin
     * (TPA) but only returns the columns that the LEA is required to complete
     * and returns additional information on required or critical data that is 
     * missing.  This list is for internal use only and NOT to be submitted to
     * the TPA.  This list should be used to troubleshoot why provider rows are not
     * being included in the official export.
     *
     * @return ReturnDataTable
     ***************************************************************************/    
    public static ReturnDataTable rptCybhiPracsAudit (  SqlConnection connSpedmon
                                                          , DetailsLog    log
                                                          , UserInfo      uInfo
                                                          , bool          paged
                                                          , string        pageNumber
                                                          , string        clientID )
    {
      ReturnDataTable so = new ReturnDataTable();

      var vClientID = Validate.reqClientID(uInfo,clientID);
      var clc       = Clients.load(connSpedmon,log,uInfo,clientID);
      var parms     = new List<SqlParameter>();

      parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

      string udf = @"dbo.CYBHI_PROVIDER_LIST_AUDIT_RPT(@clientID)";

      string viewTitle = clc.name
                       + " CYBHI Providers Audit " 
                       +  DateTime.Today.ToYYYYMMDDString();

      so = viewRpt(connSpedmon,log,uInfo,paged, pageNumber, "Y", udf, parms, null, null,viewTitle,Messages.DATA_VIEW_NO_FOOTER);

      return so;
    }                          

    /***************************************************************************
     * rptQualificationsMissingOrExpired */
    /**
     * Returns all practitioners who have expired (or about to expire) or missing
     * qualification data
     *
     * @return ReturnDataTable
     ***************************************************************************/
    
    public static ReturnDataTable rptQualificationsMissingOrExpired (  
          SqlConnection connSpedmon
        , DetailsLog    log
        , UserInfo      uInfo
        , bool          paged
        , string        pageNumber
        , string        clientID )
    {

      ReturnDataTable so = new ReturnDataTable();
      var vClientID = Validate.optClientID(uInfo,clientID);
      var prms = new List<SqlParameter>();
      prms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
      string viewUdf   = @"dbo.RPT_PRACTITIONER_QUALIFICATIONS_MISSING_OR_EXPIRED(null,null,null,@clientID)";
      string viewTitle = @"Practitioner Qualifications Missing or Expired";

        /*----------------------------
         * Define our columns and
         * set the page order for 
         * paging
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            ss.addDisplayColumn("clientName      as [Client]", true);
            ss.addDisplayColumn("lastName        as [Last]",   true);
            ss.addDisplayColumn("firstName       as [First]",  true);
            ss.addDisplayColumn("dispGroupName   as [Title]",  true);
            ss.addDisplayColumn("npiNumber       as [NPI]");
            ss.addDisplayColumn("employmentRelationship as [Relationship With Client]");
            ss.addDisplayColumn("pracCreatedOn   as [Added On]");
            ss.addDisplayColumn("latestDosStr    as [Latest DOS]");
            ss.addDisplayColumn("expiredStr      as [Expired]");
            ss.addDisplayColumn("missingStr      as [Missing]");
            ss.addDisplayColumn("licenseNums     as [License Numbers]");
            ss.addDisplayColumn("clientID");
            ss.addDisplayColumn("pracID");
   
            pageroworder = ss.pageRowOrder();

        };


        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

      so = Entities.viewRpt (connSpedmon, log, uInfo, paged, pageNumber, "Y", viewUdf, prms, null, dc);
      so.tableName   = viewTitle;     
      return so;
    }                          

    /***************************************************************************
     * rpt_Practitioner_XREF_LEA_MAA_Issues */
    /**
     * Returns a list of practitioners that currently:
     *
     * - are common between LEA and MAA
     * - are active in both programs
     * - are coded as "not MAA" in LEA
     *    
     * @param  clientID        ID of client 
     * @return                 List of practitioner data
     ***************************************************************************/

    public static ReturnDataTable rpt_Practitioner_XREF_LEA_MAA_Issues (SqlConnection connSpedmon, 
                                                                        DetailsLog    log, 
                                                                        UserInfo      uInfo,
                                                                        bool          paged,
                                                                        string        pageNumber,
                                                                        string        clientID)
    {

      string viewTitle = "Miscoded MAA Participants";
      string viewUDF   = "dbo.PRACTITONERS_VIEW_LEA_MAA_XREF_GROUP_MISMATCH(@clientID)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
 
      Object vClientID = Validate.optClientID(uInfo, clientID);

      /*----------------------------
       * Populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> prms = new List<SqlParameter>();

      prms.Add(Database.SqlParm("@clientID",   SqlDbType.Int,       vClientID,   ParameterDirection.Input));

      /*----------------------------
       * Define our columns and
       * set the page order for 
       * paging
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        ss.addPageOrderColumn("[LEA Client] asc");
        pageroworder = ss.pageRowOrder();
      };

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.viewRpt(connSpedmon,
                              log,
                              uInfo,
                              paged, 
                              pageNumber,
                              "", 
                              viewUDF, 
                              prms, 
                              null, 
                              dc,
                              viewTitle,
                              Messages.CONFIDENTIAL);
      
    }
    
    
    /***************************************************************************
     * rptReview*/
    /**
     * Returns a list of practitioners for a given clientID and excludes 
     * demo client 'Spedcare USD' from the report.
     ***************************************************************************/

    public static ReturnDataTable rptReview (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                           bool   paged,
                                           string pageNumber,
                                           string clientID,
                                           string groupID,
                                           string lname,
                                           string fname,
                                           string canEdit,
                                           string active)
    {

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

        List<SqlParameter> prms = new List<SqlParameter>();
                           
        string viewUDF   = "dbo.PRACTITONERS_VIEW (@userID, @userGroup, @userRank, 0, @recID, @clientID, null, @groupID, @lname, @fname, null, null, @active, @canEdit,null)";
        Object vClientID = Validate.optClientID(uInfo, clientID);
        Object vGroupID  = Validate.optInteger(groupID,Messages.INVALID_GROUP_ID);
        Object vLname    = Validate.optString(lname);
        Object vFname    = Validate.optString(fname);

        prms.Add(Database.SqlParm("@clientID", SqlDbType.Int,     vClientID, ParameterDirection.Input));
        prms.Add(Database.SqlParm("@groupID",  SqlDbType.Int,     vGroupID,  ParameterDirection.Input));
        prms.Add(Database.SqlParm("@lname",    SqlDbType.VarChar, vLname,    ParameterDirection.Input, 50));
        prms.Add(Database.SqlParm("@fname",    SqlDbType.VarChar, vFname,    ParameterDirection.Input, 50));


        /*----------------------------
         * Define our columns and
         * set the page order for 
         * paging
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {

            ss.addDisplayColumn("id");

            ss.addDisplayColumnIfParmValueIsNull("clientName as [Client Name]", "@clientID", true, ref parms);

            ss.addDisplayColumn("dbo.RPT_BIT_TO_YN(active)      as [Is Active]");

            ss.addDisplayColumn("groupName  as [Practitioner Type]", true);
            ss.addDisplayColumn("name       as [Practitioner Last,First]", true);
            ss.addDisplayColumn("email      as [Email]");
            ss.addDisplayColumn("phone      as [Phone]");
            ss.addDisplayColumn("startDate  as [Start Date]");
            ss.addDisplayColumn("endDate    as [End Date]");

            ss.addDisplayColumn("submitClaimsEffectiveDate       as [Submit Claims Eff Date]");
            ss.addDisplayColumn("dbo.RPT_BIT_TO_YNU(claim_TCM)   as [Claim TCM?]");
            ss.addDisplayColumn("claim_TCMEffectiveDate          as [Claim TCM Eff Date]");
            ss.addDisplayColumn("dbo.RPT_BIT_TO_YN(hasLogin)     as [Has User Account]");
            ss.addDisplayColumn("dbo.RPT_BIT_TO_YN(isLockedOut)  as [User Account Is Locked Out]");
            ss.addDisplayColumn("clientID");
            ss.addDisplayColumn("id as pracID");

            ss.colsWhere = "clientID <> 112";
            
            pageroworder = ss.pageRowOrder();

        };

        /*---------------------------------
         * This is done so that if the user 
         * selects 'No' for active the report 
         * will display all Practitioners
         *---------------------------------*/

        Object vActive = Validate.optFlag(active, Messages.INVALID_FLAG_ACTIVE);

        if (vActive != null)
        {
            bool vFlag = (bool)vActive;
            if (!vFlag) active = null;
        }


        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

         return Entities.viewRpt(connSpedmon, log, uInfo, paged, pageNumber,active, viewUDF, prms, null, dc);

    }
  
    
   /***************************************************************************
    * view */
   /**
    * Returns a list of practitioners for a given clientID
    * 
    * 
    ***************************************************************************/   

    public static ReturnDB view (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, 
                                 int    recViewType,
                                 bool   pagedOrTop,
                                 string idx,
                                 string canEdit,
                                 string active,
                                 string source,
                                 string clientID,
                                 string patID,                                
                                 string groupID,
                                 string lname, 
                                 string fname,

                                 string currentlyWithClient  ,

                                 string dos,
                                 string refPracGroupSvcClsNameID,
                                 defineCols dc
                                 )
    { 
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/  
      
      List<SqlParameter> parms      = new List<SqlParameter>();
      string             viewUDF    = "dbo.PRACTITONERS_VIEW (@userID, @userGroup, @userRank, @source, @recID, @clientID, @patID, @groupID, @lname, @fname, @currentlyWithClient, @dos, @active, @canEdit,@refPracGroupServiceClassNameID)";
      
      /*----------------------------
       * Client ID is required
       * for select views
       *----------------------------*/  
      
      Object vClientID  = null;

      if (recViewType != REC_VIEW_SEL)  vClientID  = Validate.optClientID (uInfo, clientID);
      else                              vClientID  = Validate.reqClientID (uInfo, clientID);

      Object   vGroupID                  = Validate.optInteger  (groupID,                    Messages.INVALID_GROUP_ID);
      Object   vLname                    = Validate.optString   (lname);
      Object   vFname                    = Validate.optString   (fname);
      Object   vSource                   = Validate.optInteger  (source,                     Messages.INVALID_DATA_SOURCE, true);
      Object   vDos                      = Validate.optDate     (dos,                        Messages.SERVICE_DATE_BAD, Constants.VAL_OPT_DATE_NO_FUTURE);
      Object   vPatID                    = Validate.optInteger  (patID,                      Messages.INVALID_PAT_ID);      
      Object   vRefPracGroupSvcClsNameID = Validate.optInteger  (refPracGroupSvcClsNameID,   @"Invalid group service class name id");

      Object vCurrentlyWithClient        = Validate.optFlagYNUnknown(currentlyWithClient, "Invalid boolean flag selection for currently with client?");

      parms.Add(Database.SqlParm("@source",                           SqlDbType.Int,       vSource,                   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@clientID",                         SqlDbType.Int,       vClientID,                 ParameterDirection.Input));
      parms.Add(Database.SqlParm("@groupID",                          SqlDbType.Int,       vGroupID,                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@lname",                            SqlDbType.VarChar,   vLname,                    ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@fname",                            SqlDbType.VarChar,   vFname,                    ParameterDirection.Input, 50));
      parms.Add(Database.SqlParm("@patID",                            SqlDbType.Int,       vPatID,                    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@dos",                              SqlDbType.DateTime,  vDos,                      ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@refPracGroupServiceClassNameID",   SqlDbType.BigInt,    vRefPracGroupSvcClsNameID, ParameterDirection.Input));

      parms.Add(Database.SqlParm("@currentlyWithClient", SqlDbType.Bit, vCurrentlyWithClient, ParameterDirection.Input));

       /*----------------------------
        * Call base method which
        * handles the rest and return
        * results
        *----------------------------*/

      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      

    }  
  
       
   /***************************************************************************
    * viewEntity */
   /**
    * Outputs data for a single practitioner
    * 
    * @param  connSpedmon     Spedmon database connection object
    * @param  log             Logging object
    * @param  clientID        Client ID
    * @param  pracID          PractitionerID
    * @return                 ReturnEntity
    ***************************************************************************/ 
    
    public static ReturnEntity viewEntity (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, 
                                           string clientID, 
                                           string pracID)
    {
 
      // TODO: Legacy remove

      ReturnEntity so = new ReturnEntity();
      Practitioner p = load(connSpedmon, log, uInfo,pracID);
      so.entity = (Entity) p;
      
      return so;                  
   } 

   /***************************************************************************
    * viewSel */
   /**
    * Returns a list of practitioners for a given clientID
    * 
    ***************************************************************************/   

   public static ReturnSel viewSel (SqlConnection connSpedmon, 
                                    DetailsLog    log, 
                                    UserInfo      uInfo, 
                                    bool          top, 
                                    string        topSize, 
                                    string        source,
                                    string        clientID, 
                                    string        patID,
                                    string        term,
                                    string        dos,
                                    string        refPracGroupSvcClsNameID)
   {
          
     /*----------------------------
      * Parse search term
      *----------------------------*/

     string vTerm    = Validate.optString (term);
     string lname    = "";
     string fname    = "";
     string vOther   = "";     
     
     Parse.searchTermToLastFirstOther(vTerm,out lname, out fname, out vOther); 
     
     /*----------------------------
      * Define our context column
      *----------------------------*/

     defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){                
        
        /* Internal staff see different context values */
        
        if (uInfo.userGroup == Constants.USER_GROUP_SBSC)
        {
            ss.addDisplayColumn("dbo.BIT_TO_MSG(submitClaims,(dbo.BIT_TO_MSG (ISNULL(CLAIM_TCM,1), '', '** TCM -- DO NOT BILL FOR TCM -- TCM ** |')),'** DO NOT BILL ** | ') + groupName + ' | Last DOS: ' + latestServiceDate + ' | Last Updated: ' + modifedOrCreatedOn as context1");
        }
        else
        {
          ss.addDisplayColumn("groupName as context1");
        }

        ss.addDisplayColumn ("convert(varchar, groupID) as recData1");
        ss.addDisplayColumn ("groupName as recData2");
        ss.addDisplayColumn ("convert(varchar, groupIDRept) as recData3");
        ss.addDisplayColumn ("groupNameRept as recData4");
        ss.addDisplayColumn ("convert(varchar, isnull(stdSvcClassNameID,0)) as recData5");
     };

     /* filter on active depending on datasource */
     string active = "1";

     if (source == ((int)PractitionerDataSource.INACTIVE_PRACTITIONERS).ToString())
         active = "0";

     if (source == ((int)PractitionerDataSource.ALL_ACTIVE_AND_INACTIVE).ToString())
         active = "";

     /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

     return Entities.viewSel(connSpedmon, log, uInfo ,top, topSize, 
     delegate{return Practitioners.view (connSpedmon,log,uInfo,Entities.REC_VIEW_SEL, top, topSize, "", active, source, clientID, patID, null, lname, fname, "", dos, refPracGroupSvcClsNameID,dc);});

   }

   /***************************************************************************
    * viewTbl */
   /**
    * Returns a data table of records for preview or record selection.
    * 
    * @return                 ReturnDataTable
    ***************************************************************************/   


   public static ReturnDataTable viewTbl (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, 
                                          bool   paged,
                                          string pageNumber,
                                          string clientID, 
                                          string groupID,                                 
                                          string lname,
                                          string fname,

                                          string currentlyWithClient,

                                          string canEdit,
                                          string active)
   {
     
     string source   = "";
     string patID    = "";
     string dos      = "";
     
     /*----------------------------
      * Get clientID of 
      * user if user is a client 
      * We need this for the 
      * dataview title
      *----------------------------*/
     
     Object vClientID = Validate.optClientID (uInfo, clientID);
     if (vClientID != null) clientID = vClientID.ToString();
     
     /*----------------------------
      * Define our columns and
      * set the page order for 
      * paging
      *----------------------------*/
     
     defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder,  ref List<SqlParameter> parms)
     {
       
       ss.addDisplayColumn ("id");
       
       ss.addDisplayColumnIfParmValueIsNull ("clientName as [Client Name]", "@clientID", true, ref parms);
       
       ss.addDisplayColumn ("activeYN                         as [Is\nActive]");
       ss.addDisplayColumn ("name                             as [Practitioner\nLast, First]", true);
       ss.addDisplayColumn ("groupName                        as [Practitioner\nType]");
       ss.addDisplayColumn ("employeeRelationship             as [Employement\nRelationship]");

       ss.addDisplayColumn("currentlyWithClient               as [Currently With Client?]");

       ss.addDisplayColumn ("isRMTSPart1                      as [RMTS\nQ1]");        
       ss.addDisplayColumn ("isRMTSPart2                      as [RMTS\nQ2]");        
       ss.addDisplayColumn ("isRMTSPart3                      as [RMTS\nQ3]");        
       ss.addDisplayColumn ("isRMTSPart4                      as [RMTS\nQ4]");        
       ss.addDisplayColumn ("clientEmployeeID                 as [Employee ID]");
       ss.addDisplayColumn ("startDate                        as [Start Date]");
       ss.addDisplayColumn ("endDate                          as [End Date]");
       ss.addDisplayColumn ("npiNumber                        as [NPI#]");
       ss.addDisplayColumn ("isValidMcalOrpYN                 as [Is Valid\nMedi-Cal ORP?]");
       ss.addDisplayColumn ("isValidMcalOrpLastValidatedStr   as [Is Valid\nMedi-Cal ORP\nLast Validated On]");
       ss.addDisplayColumn ("email                            as [Email]");
       ss.addDisplayColumn ("phone                            as [Phone]");
       ss.addDisplayColumn ("placeAddress                     as [Professional\nAddress]");
       ss.addDisplayColumn ("latestServiceDate                as [Last\nDate\nof Service\nEntered]"); 
       ss.addDisplayColumn ("groupNameRept                    as [Reporting\nGroup]");


       ss.addDisplayColumn("participatesInLEABOP_YN as [LEA BOP/\nIDEA Services?]");
       ss.addDisplayColumn("participatesInCYBHI as [CYBHI ?]");

       ss.addDisplayColumn ("includeInFinReptsYN              as [Include\nin Financial\nReports?]");
       ss.addDisplayColumn ("submitClaimsYN                   as [Submit\nClaims?]");
       ss.addDisplayColumn ("submitClaimsEffectiveDate        as [Submit\nClaims\nEffective\nDate]");
       ss.addDisplayColumn ("claim_TCMYN                      as [Claim TCM?]");
       ss.addDisplayColumn ("claim_TCMEffectiveDate           as [Claim TCM\nEffective\nDate]");
       ss.addDisplayColumn ("hasLoginYN                       as [Has A\nUser\nAccount]");
       ss.addDisplayColumn ("isLockedOutYN                    as [User\nAccount\nIs\nLocked\nOut]");

         // TODO: add column?

       if (uInfo.userGroup == Constants.USER_GROUP_SBSC)
       {
           ss.addDisplayColumn ("clientID");       
           ss.addDisplayColumn ("id                           as pracID");
       }
       
       pageroworder = ss.pageRowOrder();
     
     };

     
     string tableName   = @"Practitioners - View";
     string tableFooter = Messages.CONFIDENTIAL;
     
     if ( ! Util.IsNullOrEmpty (clientID) )
     {
       Client c = Clients.load(connSpedmon,log,uInfo,clientID);
       tableName = tableName + " - " + c.name;
     }
     
     /*----------------------------
      * Call base method which
      * handles the rest and return
      * results
      *----------------------------*/
     
     return Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber, 
       delegate{return Practitioners.view (connSpedmon,log,uInfo,Entities.REC_VIEW_TBL, paged, pageNumber, canEdit, active, source, clientID, patID, groupID, lname, fname, currentlyWithClient, dos, "", dc);}
       , tableName
       , tableFooter

       );
    }       

    /***************************************************************************
     * viewQFormInfoTable */
    /**
     * Outputs qform info for the given clientID and pracID
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @param  pracID          Practitioner ID
     * @return                 ReturnInfoTable
     ***************************************************************************/ 
    
    public static ReturnInfoTable viewQFormInfoTable (  SqlConnection connSpedmon
                                                      , DetailsLog    log
                                                      , UserInfo      uInfo
                                                      , string        clientID
                                                      , string        pracID)
    {
           
     ReturnInfoTable so = new ReturnInfoTable();
     Practitioner    p = load(connSpedmon, log, uInfo,pracID);
     
     /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/  
      
      List<SqlParameter> parms = new List<SqlParameter>();

      string viewUDF    = "INPUT_BATCHES_QFORM_QUESTION_ANSWERS_VIEW_INFO (null,null,null,@clientID,@pracID,1)";
                  
      int    vClientID  = Validate.reqClientID (uInfo, clientID);
      int    vPracID    = Validate.reqPracID   (uInfo, pracID);

      parms.Add(Database.SqlParm("@clientID",  SqlDbType.Int,  vClientID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",    SqlDbType.Int,  vPracID,   ParameterDirection.Input));
                        
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      so = Entities.viewInfoTbl (connSpedmon, log, uInfo, viewUDF, parms);
      so.caption = p.name;
      
      return so;
      
    }

    public static ReturnDataTable rptTattle (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                  bool paged,
                                  string pageNumber,
                                  string clientID,
                                  string asOfDate,
                                  string canEdit,
                                  string pracID,
                                  string groupid
                                                )
    {

        ReturnDataTable rdt;
        
        List<SqlParameter> prms = new List<SqlParameter>();
      
        Object vClientID = Validate.optClientID ( uInfo,    clientID);
        Object vAsOfDate = Validate.optDate     ( asOfDate, Messages.INVALID_START_DATE);
        Object vPracID   = Validate.optPracID   ( uInfo,    pracID);        
        Object vGroupID  = Validate.optInteger  (groupid,   Messages.INVALID_GROUP_ID);

        prms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt, vClientID, ParameterDirection.Input));
        prms.Add(Database.SqlParm("@pracID",    SqlDbType.BigInt, vPracID,   ParameterDirection.Input));
        prms.Add(Database.SqlParm("@groupID",   SqlDbType.BigInt, vGroupID,  ParameterDirection.Input));
        prms.Add(Database.SqlParm("asofdate",   SqlDbType.Date,   vAsOfDate, ParameterDirection.Input));

        string reportUDF = "dbo.RPT_TATTLETALE (@clientID, @pracID, @groupID, @asofdate)";

        /*----------------------------
         * Define our columns and
         * set the page order for
         * paging
         *----------------------------*/
        
        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {

            
            /*
             * with apologies to EAW, I believe that these four lines are breaking the query whenever the pracID is left blank.
             * The query will run and render correctly if we put the same columns in
             * each time.
             
            ss.addDisplayColumnIfParmValueIsNull(@"@pracID",  @"[Practitioner ID]",          ref parms);
            ss.addDisplayColumnIfParmValueIsNull(@"@pracID",  @"[Last Name (Practitioner)]", ref parms);
            ss.addDisplayColumnIfParmValueIsNull(@"@pracID",  @"[First Name]",                ref parms);
                                                           //the syntax here is obviously wrong; I think there is a left-bracket missing

            ss.addDisplayColumnIfParmValueIsNull(@"@groupID", @"[Practitioner Type]",        ref parms);

            */
                // these four columns must always be shown; they can't be dynamically shown or hidden, here; we can hide them below
            //ss.addDisplayColumn("[Practitioner ID]");
            ss.addDisplayColumn("[Last Name (Practitioner)]");
            ss.addDisplayColumn("[First Name]");
            ss.addDisplayColumn("[Practitioner Type]");
            // TODO: fix the framework so that the method .addDisplayColumnIfParmValueIsNull() will actually, you know, work someday
                        
            ss.addDisplayColumn("[Reporting Group]", true);
            ss.addDisplayColumn("[Added to SpEdCare]");

            ss.addDisplayColumn("[c13(_col_label)]");   /* Note: cx(_col_label) is in brackets.  This is to prevent sql from evaluating this as a udf */
            ss.addDisplayColumn("c13");

            ss.addDisplayColumn("[c12(_col_label)]");
            ss.addDisplayColumn("c12");

            ss.addDisplayColumn("[c11(_col_label)]");
            ss.addDisplayColumn("c11");

            ss.addDisplayColumn("[c10(_col_label)]");
            ss.addDisplayColumn("c10");

            ss.addDisplayColumn("[c9(_col_label)]");
            ss.addDisplayColumn("c9");

            ss.addDisplayColumn("[c8(_col_label)]");
            ss.addDisplayColumn("c8");

            ss.addDisplayColumn("[c7(_col_label)]");
            ss.addDisplayColumn("c7");

            ss.addDisplayColumn("[c6(_col_label)]");
            ss.addDisplayColumn("c6");

            ss.addDisplayColumn("[c5(_col_label)]");
            ss.addDisplayColumn("c5");

            ss.addDisplayColumn("[c4(_col_label)]");
            ss.addDisplayColumn("c4");

            ss.addDisplayColumn("[c3(_col_label)]");
            ss.addDisplayColumn("c3");

            ss.addDisplayColumn("[c2(_col_label)]");
            ss.addDisplayColumn("c2");

            ss.addDisplayColumn("[c1(_col_label)]");
            ss.addDisplayColumn("c1");

            pageroworder = ss.pageRowOrder();
        };

        /* TODO: Group name */

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/
        string tableName;

        if (clientID != "") {  //earlier on we said that clientID was optional... 
          Client c = Clients.load(connSpedmon, log, uInfo, vClientID.ToString());
                //because the clientID param may have come in blank (depending on the user role of whoever is requesting this report),
                //we must instead use the validated client id.  vClientID.ToString()

          tableName = SEL_LABEL_RPT_TATTLETALE + " for " + c.name;
        } else
          tableName = SEL_LABEL_RPT_TATTLETALE;

        rdt = Entities.viewRpt(   connSpedmon
                                 , log
                                 , uInfo
                                 , paged
                                 , pageNumber
                                 , null
                                 , reportUDF
                                 , prms
                                 , null
                                 , dc
                                 , tableName
                                 , Messages.CONFIDENTIAL);


        /*if (!Util.IsNullOrEmpty(pracID))
        {
            Practitioner p = Practitioners.load(connSpedmon, log, uInfo, pracID);
            rdt.presented_cols[0].bVisible = false;
            rdt.presented_cols[1].bVisible = false;
            rdt.presented_cols[2].bVisible = false;
            rdt.presented_cols[3].bVisible = false;
            rdt.tableName = tableName + " - " + p.name + " #" + pracID;
        }*/
        
        return rdt;
        
    }  


    /***************************************************************************
     * viewObjects 
     *
     * Returns a list of practitioner objects
     * 
     ***************************************************************************/

    public static ReturnObjects viewObjects (  SqlConnection connSpedmon
                                              , DetailsLog log
                                              , UserInfo   uInfo                                                    
                                              , bool       pageObjectList
                                              , string     pageOrder
                                              , string     idx
                                              , string     active
                                              , string     clientID
                                              , string     lName
                                              , string     fName

                                              , string currentlyWithClient

                                              , string     groupID)

    {
            
      /* Default page order */  

      if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = Practitioner.DEFAULT_PAGING_ORDER;

      /* Define columns delegate is used to specify columns and page order 
       * We pass in the desired page row order here */

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        pageroworder = pageOrder;
      };

      return Entities.viewObjects(  connSpedmon
                                   , log
                                   , uInfo
                                   , typeof(Practitioner)
                                   , pageObjectList
                                   , pageOrder
                                   , delegate {                                      
                                       return Practitioners.view (  connSpedmon
                                                             , log
                                                             , uInfo
                                                             , Entities.REC_VIEW_OBJECTS
                                                             , pageObjectList
                                                             , idx
                                                             , "" /* Can edit */
                                                             , active
                                                             , "0" /* Data source for all is 0 */                                                             
                                                             , clientID                                                             
                                                             , "" /* patID */
                                                             , groupID /* dispGroupID */
                                                             , lName
                                                             , fName

                                                             , currentlyWithClient

                                                             , "" /* DOS */
                                                             , "" /* groupSvcClassNameID */
                                                             , dc );
                                    });
      

    }
    
    /***************************************************************************
     * npiLookup
     *
     * Returns 
     * 
     ***************************************************************************/

    public static ReturnValue npiLookup(string term, string selectMode)
    {
      return GeoUtil.requestIndividualProviderDataFromCMS(term,selectMode,false);      
    }


    /***************************************************************************
        * updateFlagCurrentlyWClient */
    /** 
        ***************************************************************************/
    public static ReturnSaveRecord updateFlagCurrentlyWClient(
            SqlConnection connSpedmon
        , DetailsLog log
        , UserInfo uInfo
        , string clientID
        , string pracID
        , string currentlyWClient )

    {

        var parms = new List<SqlParameter>();

        int vClientID = Validate.reqClientID(uInfo, clientID);
        int vPracID = Validate.reqInteger(pracID, Messages.INVALID_PRAC_ID, false);
        Object vFlag = Validate.reqFlag(currentlyWClient, Messages.INVALID_PARENT_CONSENT_MCAL);


        parms.Add(MBA.Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
        parms.Add(MBA.Database.SqlParm("@currentlyWClient", SqlDbType.Bit, vFlag, ParameterDirection.Input));

        return recordOp(connSpedmon
                            , log
                            , uInfo
                            , ""
                            , "0"
                            , vPracID.ToString()
                            , "[dbo].[PRACTITIONER_FLAG_CURRENTLY_W_CLIENT]"
                            , ref parms);

    }

    /***************************************************************************
        * cybhiPracsProcessFile */
    /**
    * Processes file
    *
    * @return                     ReturnSaveNewRecordWithJSONData
    ***************************************************************************/

    public static ReturnSaveRecordWithJSONData cybhiPracsProcessFile (
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string clientID
      , string fileClass
      , string fromExternalSource
      , string fileContents
      , string validateRec )
    {

        /*----------------------------
            * Validate parameters specific
            * to this entity.save
            * and populate their
            * coresponding database
            * parameters
            *----------------------------*/


        int    vClientID = Validate.reqClientID(uInfo, clientID);
        int    vFileClass = Validate.reqInteger(fileClass, "Invalid file class", true);
        bool   vfromExternalSource = Validate.reqFlag(fromExternalSource, "Invalid external source");
        string vFileContents = Validate.reqString(fileContents, "Invalid file contents");

        var parms = new List<SqlParameter>();

        parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
        parms.Add(Database.SqlParm("@fileClass", SqlDbType.TinyInt, vFileClass, ParameterDirection.Input));
        parms.Add(Database.SqlParm("@fromExternalSource", SqlDbType.Bit, vfromExternalSource, ParameterDirection.Input));
        parms.Add(Database.SqlParm("@fileContents", SqlDbType.VarChar, vFileContents, ParameterDirection.Input, -1));

        /*----------------------------
            * Call base method which 
            * handles the rest and return
            * results
            *----------------------------*/

        var so = Entities.saveAndReturnJSONData(connSpedmon
            , log
            , uInfo
            , "1" /*saveType*/
            , validateRec
            , "" /*editDelReason*/
            , "" /* recID*/
            , "CYBHI_TPA_RETURN_FILE_PROCESS_PRAC_REG"
            , "Duplicate file"
            , ref parms
            , null);

        return so;
    }
  }
}