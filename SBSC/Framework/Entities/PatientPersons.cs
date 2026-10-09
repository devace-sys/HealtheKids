using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * ParentPatientCommom */
  /**
   *
   ***************************************************************************/
    
   public class ParentPatientCommom
    {
        public string patID;
        public string pracID;
        public string patName;
        public string patEmail;
        public string patPhone;
        public string patStreet1;
        public string patStreet2;
        public string patCity;
        public string patState;
        public string patZip5;
        public string patZip4;
        public string patAge;
        public string patGender;
        public string patConsentToRelease;
        public int patPreferredContactMethod;
        public string patplaceHomeID;
        public List<PatientInsuranceCarrier> insurance;
        public List<TeleIEPSession> upcomingVisits;
    }

  /***************************************************************************
   * PatientPerson */
  /**
   *
   ***************************************************************************/

  public class PatientPerson : MBA.PatientPerson
  {
  }
     
  /***************************************************************************
   * ReturnPatientPerson */
  /**
   * Return class for loading a patient person and returning the data for client
   * side use
   **************************************************************************/

  public class ReturnPatientPerson : Return
  {
 
    public ReturnPatientPerson ()            : base(){}
    public ReturnPatientPerson (string msg)  : base(msg){}
    public ReturnPatientPerson (Exception e) : base(e){}
    public ReturnPatientPerson (Warning e)   : base(e){}
    public ReturnPatientPerson (Critical e)  : base(e){}
    public ReturnPatientPerson (SessionExpired e):base(e){}
    
    public bool hasPatientPerson = false;
    public PatientPerson patientPerson;
  }

  /***************************************************************************
   * PatientPersons */
  /**
   *
   ***************************************************************************/
  
  public class PatientPersons : Entities
  {
    
    public const string SEL_LABEL               = "Patient Persons";
    public const string SEL_LABEL_ADD           = "Record New";
    public const string SEL_LABEL_VIEW          = "View";
    public const string SEL_LABEL_EDIT_DELETE   = "Review, Edit or Delete";
    public const string SEL_LABEL_EDIT          = "Edit";
    public const string SEL_LABEL_DELETE        = "Delete";
    public const string SEL_LABEL_MANAGE        = "Manage";
    public const string URL_USER_ALL_SAVE       = @"user_all_patient_persons_save.aspx";
    public const string URL_USER_ALL_MANAGE     = @"user_all_patient_person_manage.aspx";
    public const string SEL_LABEL_USER_ALL_VIEW = @"Patient Persons - View";

    public const string URL_ASMX           = @"patient_persons.asmx";
    public const string URL_ASHX           = @"patient_persons.ashx";
    public const string URL_VIEW_SEL       = URL_ASMX + @"/viewSel";
    public const string URL_SAVE           = URL_ASMX + @"/save";
    public const string URL_SAVE_INLINE    = URL_ASMX + @"/saveinline";
    public const string URL_DELETE         = URL_ASMX + @"/delete";
    public const string URL_DELETE_INLINE  = URL_ASMX + @"/deleteinline";
	public const string URL_INVITE_PORTAL  = URL_ASMX + @"/inviteParentGuardianPortal";
    public const string URL_UPLOAD_COMPLETED_REQUEST_FORM = @"https://app.smartsheet.com/b/form/da864e58ee6d45be8cd9a831d4740691";																					  

    public const string URL_USER_ALL_VIEW  = @"user_all_view_patient_persons.aspx";

    public static string URL_USER_ALL_VIEW_BASE (string searchTerm = "")
    {

      return MBA.HttpApplication.createLink ( URL_USER_ALL_VIEW
                                            , true
                                            , new NameValue(Constants.PARM_APP_MODE,    Constants.AMD_UI_DBS_SUB_PAGE)
                                            , new NameValue(Constants.PARM_SEARCH_TERM, searchTerm)
                                            );
    }
    
    public static string URL_VIEW_SEL_BASE()
    {
        return MBA.HttpApplication.createLink(URL_VIEW_SEL, true);
    }

    public const long  PERSON_CLASS_1_PARENT_OR_GUARDIAN       = 1;
    public const long  PERSON_CLASS_1_PERSONAL_PRACTITIONER    = 2;
    public const long  PERSON_CLASS_1_DISTRICT_OR_SCHOOL_STAFF = 3;

    public const string URL_REST_VIEW    = @"api/v1/patientpersons";
    
    /***************************************************************************
     * URL_REST_VIEW */
    /**
     * 
     **************************************************************************/

    public static string URL_REST_VIEW_BASE()
    {
        return MBA.HttpApplication.createLink(PatientPersons.URL_REST_VIEW, true);
    }

    /***************************************************************************
     * URL_SAVE_BASE */
    /**
     * 
     **************************************************************************/

    public static string URL_SAVE_BASE()
    {
        return MBA.HttpApplication.createLink(PatientPersons.URL_SAVE, true);
    }

    /***************************************************************************
     * URL_SAVE_INLINE_BASE */
    /**
     * 
     **************************************************************************/
    public static string URL_SAVE_INLINE_BASE()
    {
        return MBA.HttpApplication.createLink(PatientPersons.URL_SAVE_INLINE, true);
    }

    /***************************************************************************
     * URL_SERVICE_DELETE_BASE */
    /**
     * 
     **************************************************************************/

    public static string URL_DELETE_BASE()
    {
        return MBA.HttpApplication.createLink(PatientPersons.URL_DELETE_INLINE, true);
    }

    
    /***************************************************************************
     * URL_DELETE_INLINE_BASE */
    /**
     * 
     **************************************************************************/
    public static string URL_DELETE_INLINE_BASE()
    {
        return MBA.HttpApplication.createLink(PatientPersons.URL_DELETE_INLINE, true);
    }

    /***************************************************************************
     * URL_INVITE_PARENT_PORTAL_BASE */
    /**
     * 
     **************************************************************************/

    public static string URL_INVITE_PARENT_PORTAL_BASE()
    {
        return MBA.HttpApplication.createLink(PatientPersons.URL_INVITE_PORTAL, true);
    }
        
	/***************************************************************************			  
     * save */
    /**
     * Save 
     *
     * @param  userID          User id of who is recording service
     * @param  userGroup       1 = Client, 2 = SBSC (from users db)
     * @param  userRank        Users role ranking
     * @param  clientID        Patient's client id
     * @param  patID
     *
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

    public static ReturnSaveRecord save (   SqlConnection connSpedmon
                                          , DetailsLog    log
                                          , UserInfo      uInfo
                                          , string        clientID
										  , string        patientID
                                          , string        personroleid
										  , string        personrelationshipid
                                          , string        lastName
										  , string        firstName
										                      , string        middleName
										                      , string        phone
										                      , string        fax
										                      , string        email
										                      , string        address1
										                      , string        address2
										                      , string        city
										                      , string        state
										                      , string        zip5
										                      , string        zip4
										                      , string        additionalData1
                                          , string        additionalData2
										                      , string        editDelReason
                                          , string        validateRec
                                          , string        saveType
                                          , string        recID )  
    {
     
      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
       
      List<SqlParameter> parms = new List<SqlParameter>();
     
      long    vClientID         = Validate.reqClientID    (uInfo, clientID);	  
	    long    vPatientID        = Validate.reqInteger     (patientID,             Messages.INVALID_PAT_ID);      
	    long    vPersonClassID1   = Validate.reqInteger     (personroleid,          Messages.INVALID_PERSON_CLASS_ID_1);      
	    long    vPersonClassID2   = Validate.reqInteger     (personrelationshipid,  Messages.INVALID_PERSON_CLASS_ID_2);	        
	    string  vLastName         = Validate.reqString      (lastName,              Messages.INVALID_LNAME);
      string  vFirstName        = Validate.reqString      (firstName,             Messages.INVALID_FNAME);                 
      string  vMiddleName       = Validate.optString      (middleName,            Messages.INVALID_MNAME);      
	    Object  vPhone            = Validate.optPhoneNumber (phone,                 Messages.INVALID_PHONE_NUMBER); 
	    Object  vFax              = Validate.optPhoneNumber (fax,                   Messages.INVALID_PHONE_NUMBER); 
	    Object  vEmail            = Validate.optEmail       (email,                 Messages.INVALID_EMAIL); 
	    string  vAddress1         = Validate.optString      (address1,              Messages.INVALID_ADDRESS);
      string  vAddress2         = Validate.optString      (address2,              Messages.INVALID_ADDRESS);
      string  vCity             = Validate.optString      (city,                  Messages.INVALID_ADDRESS);
      string  vState            = Validate.optString      (state,                 Messages.INVALID_ADDRESS);
      string  vZip5             = Validate.optZip5        (zip5,                  Messages.INVALID_ZIP);
      Object  vZip4             = Validate.optZip4        (zip4,                  Messages.INVALID_ZIP);      
	    string  vAdditionalData1  = Validate.optString      (additionalData1, @"Invalid additional data 1");
      string  vAdditionalData2  = Validate.optString      (additionalData2, @"Invalid additional data 2");
	 	  
      parms.Add(Database.SqlParm("@clientID",           SqlDbType.BigInt,   vClientID,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patientID",          SqlDbType.BigInt,   vPatientID,        ParameterDirection.Input));	  
	    parms.Add(Database.SqlParm("@CLASS_ID_1",         SqlDbType.BigInt,   vPersonClassID1,   ParameterDirection.Input));
	    parms.Add(Database.SqlParm("@CLASS_ID_2",         SqlDbType.BigInt,   vPersonClassID2,   ParameterDirection.Input));
	    parms.Add(Database.SqlParm("@LAST_NAME",          SqlDbType.VarChar,  vLastName,         ParameterDirection.Input, 255));
	    parms.Add(Database.SqlParm("@FIRST_NAME",         SqlDbType.VarChar,  vFirstName,        ParameterDirection.Input, 255));
	    parms.Add(Database.SqlParm("@MIDDLE_NAME",        SqlDbType.VarChar,  vMiddleName,       ParameterDirection.Input, 255));
	    parms.Add(Database.SqlParm("@PHONE",              SqlDbType.VarChar,  vPhone,            ParameterDirection.Input, 255));
	    parms.Add(Database.SqlParm("@FAX",                SqlDbType.VarChar,  vFax,              ParameterDirection.Input, 255));
	    parms.Add(Database.SqlParm("@EMAIL",              SqlDbType.VarChar,  vEmail,            ParameterDirection.Input, 255));	  	 
	    parms.Add(Database.SqlParm("@ADDRESS_1",          SqlDbType.VarChar,  vAddress1,         ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@ADDRESS_2",          SqlDbType.VarChar,  vAddress2,         ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@CITY",               SqlDbType.VarChar,  vCity,             ParameterDirection.Input, 100));
      parms.Add(Database.SqlParm("@STATE",              SqlDbType.VarChar,  vState,            ParameterDirection.Input, 2));
      parms.Add(Database.SqlParm("@ZIP_5",              SqlDbType.VarChar,  vZip5,             ParameterDirection.Input, 5));
      parms.Add(Database.SqlParm("@ZIP_4",              SqlDbType.VarChar,  vZip4,             ParameterDirection.Input, 4));	    
	    parms.Add(Database.SqlParm("@ADDITIONAL_DATA_1",  SqlDbType.VarChar,  vAdditionalData1,  ParameterDirection.Input, 1000));
	    parms.Add(Database.SqlParm("@ADDITIONAL_DATA_2",  SqlDbType.VarChar,  vAdditionalData2,  ParameterDirection.Input, 1000));
	  
      return Entities.save (  connSpedmon
                            , log
                            , uInfo
                            , saveType
                            , validateRec
                            , editDelReason
                            , recID
                            , "PATIENT_PERSONS_SAVE"
                            , "There is already an active person with this name"
                            , ref parms
                            , null );
    }

    /***************************************************************************
     * view */
    /**
     *
     **************************************************************************/  
    
    public static ReturnDB view (   SqlConnection connSpedmon
                                  , DetailsLog    log
                                  , UserInfo      uInfo
                                  , int           recViewType
                                  , bool          pagedOrTop
                                  , string        idx
                                  , string        canEdit
                                  , string        active
                                  , string        clientID
								  , string        patientID 
								  , string        personClassID1
							      , string        personClassID2           
                                  , string        term
                                  , defineCols    dc )
    {
      
       var rd = new ReturnDB();

       string viewUDF = @"dbo.PATIENT_PERSONS_VIEW (@userID, @userGroup, @userRank, @clientID, @patientID, @CLASS_ID_1, @CLASS_ID_2, @term, @active, @recID)";
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
       
      var    vClientID        = Validate.optClientID (uInfo, clientID);  /* Was required */
      var    vPatientID       = Validate.optPatID    (uInfo, patientID); /* Was required */
      var    vPersonClassID1  = Validate.optInteger  (personClassID1, @"Invalid person class id 1");
      var    vPersonClassID2  = Validate.optInteger  (personClassID2, @"Invalid person class id 1");
      string vTerm            = Validate.optString   (term,           @"Invalid search term");
      
      parms.Add(Database.SqlParm("@clientID",   SqlDbType.BigInt,  vClientID,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patientID",  SqlDbType.BigInt,  vPatientID,        ParameterDirection.Input));
	  parms.Add(Database.SqlParm("@CLASS_ID_1", SqlDbType.BigInt,  vPersonClassID1,   ParameterDirection.Input));
	  parms.Add(Database.SqlParm("@CLASS_ID_2", SqlDbType.BigInt,  vPersonClassID2,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",       SqlDbType.VarChar, vTerm,             ParameterDirection.Input, 256));
      
      bool hasClientID = true;
      bool hasPatID    = true;
      bool hasTerm     = true;

      if (vClientID  is null)                       hasClientID = false;
      if (vPatientID is null)                       hasPatID    = false;
      if (String.IsNullOrWhiteSpace(vTerm) == true) hasTerm     = false;
      
      if ((hasClientID == true) || (hasPatID == true) || (hasTerm == true)) {
            
        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/
       
        rd = Entities.view (  connSpedmon
                              , log
                              , uInfo
                              , recViewType
                              , pagedOrTop
                              , idx
                              , canEdit
                              , active
                              , viewUDF
                              , ref parms
                              , null
                              , dc );    
    
      }
      else {
        rd.hasRecords     = false;        
        rd.hasOutputParms = false;
        rd.hasSpDetails   = false;
        rd.message        = "Search parameters required";
      }
      return rd;
    }
    

   /***************************************************************************
     * viewTbl */
    /**
     * Returns a data table of records for preview or record selection.
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewTbl (   SqlConnection connSpedmon
                                            , DetailsLog    log
                                            , UserInfo      uInfo
                                            , bool          paged
                                            , string        pageNumber
                                            , string        canEdit
                                            , string        active
                                            , string        clientID
                                            , string        patID
                                            , string        personClassID1
                                            , string        personClassID2
                                            , string        term
)
    {
      ReturnDataTable so = new ReturnDataTable();
     
      /*----------------------------
       * Define our columns and
       * set the page order for
       * paging
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        ss.addDisplayColumn("id");
        ss.addDisplayColumn("name                             as [Name]", true);
        ss.addDisplayColumn("relationshipWithPatientLabel     as [Relationship With Patient]");
        ss.addDisplayColumn("email          as [Email]");
        ss.addDisplayColumn("phone          as [Phone]");
        ss.addDisplayColumn("placeAddress   as [Address]");

        ss.addDisplayColumn("patientName    as [Patient Name]");
        ss.addDisplayColumn("clientName     as [District Name]");    
        pageroworder = ss.pageRowOrder();
      };

      /*----------------------------
       * Call base method which
       * handles the rest
       *----------------------------*/

      so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
        delegate { return PatientPersons.view ( connSpedmon
                                             , log
                                             , uInfo
                                             , Entities.REC_VIEW_TBL
                                             , paged
                                             , pageNumber
                                             , canEdit
                                             , active
                                             , clientID
                                             , patID
                                             , personClassID1
                                             , personClassID2
                                             , term
                                             , dc); });
   
      /*----------------------------
       * Add a title and footer
       *----------------------------*/
                   
      so.tableName   = @"Patient Persons";
      so.tableFooter = Messages.CONFIDENTIAL;
     
      /*----------------------------
       * Done
       *----------------------------*/

      return so;
    }

    /***************************************************************************
     * viewSel */
    /**
     * Returns a data table of records for preview or record selection.
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnSel viewSel (   SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , bool          top
                                      , string        topSize
                                      , string        clientID                                      
					   			      , string        patientID
                                      , string        term )
    {

        /*----------------------------
         * Define our context column
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
          ss.addDisplayColumn("lastName                         as [recData1]");
          ss.addDisplayColumn("firstName                        as [recData2]");
          ss.addDisplayColumn("convert(varchar(256), classID2)  as [recData3]");
          ss.addDisplayColumn("email                            as [recData4]");
          ss.addDisplayColumn("phone                            as [recData5]");
          ss.addDisplayColumn("className2                       as [recData6]");
          ss.addDisplayColumn("address1                         as [recData7]");
          ss.addDisplayColumn("address2                         as [recData8]");
          ss.addDisplayColumn("city                             as [recData9]");
          ss.addDisplayColumn("state                            as [recData10]");
          ss.addDisplayColumn("zip5                             as [recData11]");
          ss.addDisplayColumn("zip4                             as [recData12]");
          ss.addDisplayColumn("fax                              as [recData13]");
          ss.addDisplayColumn("additionalData1                  as [recData14]");
          ss.addDisplayColumn("additionalData2                  as [recData15]");
        };

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        return Entities.viewSel(  connSpedmon
                                , log
                                , uInfo
                                , top
                                , topSize
                                , delegate { 
                                  return PatientPersons.view ( connSpedmon
                                                              , log
                                                              , uInfo
                                                              , Entities.REC_VIEW_SEL
                                                              , top
                                                              , topSize
                                                              , ""
                                                              , "Y"
                                                              , clientID
                                                              , patientID
                                                              , null
										                      , null
                                                              , term
                                                              , dc); 
                                });
                                                                    
    }

    
    /***************************************************************************
     * viewSelParentsGuardiansOnly */
    /**
     * Returns a data table of records for preview or record selection.
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnSel viewSelParentsGuardiansOnly (  SqlConnection connSpedmon
                                                         , DetailsLog    log
                                                         , UserInfo      uInfo
                                                         , bool          top
                                                         , string        topSize
                                                         , string        clientID                                      
					   			                         , string        patientID
                                                         , string        term )
    {

        /*----------------------------
         * Define our context column
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
          ss.addDisplayColumn("relationshipWithPatientLabel as context1");
        };

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        return Entities.viewSel(  connSpedmon
                                , log
                                , uInfo
                                , top
                                , topSize
                                , delegate { 
                                  return PatientPersons.view ( connSpedmon
                                                              , log
                                                              , uInfo
                                                              , Entities.REC_VIEW_SEL
                                                              , top
                                                              , topSize
                                                              , ""
                                                              , "Y"
                                                              , clientID
                                                              , patientID
                                                              , "1" /* 1 = Parent or Guardian */
 										                      , null
                                                              , term
                                                              , dc); 
                                });
                                                                    
    }

   /***************************************************************************
    * viewObjects 
    *
    * Returns a list of patient persons objects
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
                                              , string     patID
                                              , string     personClassID1
                                              , string     personClassID2
                                              , string     term )

    {           
      /* Default page order */  

      if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PatientPerson.DEFAULT_PAGING_ORDER;
     
      /* Define columns delegate is used to specify columns and page order 
       * We pass in the desired page row order here */

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        pageroworder = pageOrder;
      };

      return Entities.viewObjects(  connSpedmon
                                   , log
                                   , uInfo
                                   , typeof(PatientPerson)
                                   , pageObjectList
                                   , pageOrder
                                   , delegate {                                      
                                       return PatientPersons.view ( connSpedmon
                                                                   , log
                                                                   , uInfo
                                                                   , Entities.REC_VIEW_OBJECTS
                                                                   , pageObjectList
                                                                   , idx
                                                                   , "" /* Can edit */
                                                                   , active                                                                   
                                                                   , clientID
                                                                   , patID
                                                                   , personClassID1
                                                                   , personClassID2
                                                                   , term                                                              
                                                                   , dc); 
                                    });
      
    }
    
    /***************************************************************************
     * load */
    /**
     * Outputs data for a single record
     *
     * Note: This calls the view method and the view method takes care of
     * enforcing the client id.
     *
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @param  patID           PatID
     * @return                 ReturnEntity
     ***************************************************************************/

    public static PatientPerson load (  SqlConnection connSpedmon
                                       , DetailsLog    log
                                       , UserInfo      uInfo
                                       , string        clientID
                                       , string        patientID
                                       , string        recID )
    {
      return (PatientPerson) Entities.load (   connSpedmon
                                              , log
                                                   , uInfo
                                                   , recID
                                                   , typeof (PatientPerson)
                                                   , delegate {          
                                                      return PatientPersons.view (  connSpedmon
                                                                                   , log
                                                                                   , uInfo
                                                                                   , Entities.REC_VIEW_LOAD
                                                                                   , false
                                                                                   , recID
                                                                                   , ""
                                                                                   , ""
                                                                                   , clientID																						 
                                                                                   , patientID
                                                                                   , null
										                                                               , null
                                                                                   , ""
                                                                                   , null );
                                                  });
    }
   
    /***************************************************************************
     * getPatientPerson */
    /**
     * Outputs data for a single record
     *
     *
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @param  patID           PatID
     * @return                 ReturnEntity
     ***************************************************************************/

    public static ReturnPatientPerson getPatientPerson ( SqlConnection  connSpedmon
                                                         , DetailsLog    log
                                                         , UserInfo      uInfo
                                                         , string        clientID
                                                         , string        patientID
                                                         , string        recID )
    {
      ReturnPatientPerson rpp = new ReturnPatientPerson();
      try
      { 
        rpp.hasPatientPerson = false;      
        rpp.patientPerson = load(connSpedmon,log,uInfo,clientID,patientID,recID);
        rpp.hasPatientPerson = true;
      }
      catch (Exception e)
      {
        rpp = new ReturnPatientPerson(e);
        rpp.hasPatientPerson = false;
      }
      
      return rpp;
    }

    /***************************************************************************
     * delete */
    /**    
     *
     * @param  editDelReason   Reason for edit/delete
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/

    public static ReturnSaveRecord delete (   SqlConnection connSpedmon
                                            , DetailsLog    log
                                            , UserInfo      uInfo
                                            , string        editDelReason
                                            , string        validateRec
                                            , string        clientID                                       
                                            , string        patientID
                                            , string        recID )
    {

       /*----------------------------
        * Check for required and
        * optional parameters
        * and validate data integrity
        * of all supplied parameters
        *----------------------------*/

       long   vClientID     = Validate.reqClientID  (uInfo, clientID);
       long   vPatientID    = Validate.reqInteger   (patientID,      Messages.INVALID_PAT_ID);  	  
               
        /*----------------------------
         * Collect all of the parameters
         * that are specific to this
         * delete method.
         *----------------------------*/

        List<SqlParameter> parms = new List<SqlParameter>();
  
        parms.Add(Database.SqlParm("@clientID",    SqlDbType.BigInt,  vClientID,   ParameterDirection.Input));     
        parms.Add(Database.SqlParm("@patientID",   SqlDbType.BigInt,  vPatientID,  ParameterDirection.Input));

        /*----------------------------
         * Call base method
         *----------------------------*/

        return Entities.delete (   connSpedmon
                                 , log
                                 , uInfo
                                 , editDelReason
                                 , validateRec
                                 , recID
                                 , "PATIENT_PERSONS_DELETE"
                                 , ref parms);
    }

    /*************************************************************************
    * viewList */
   /**
    * Return a list of patient contact records
    * 
    ***************************************************************************/

    public static List<PatientPerson> viewList( SqlConnection connSpedmon
                                                         , DetailsLog    log
                                                         , UserInfo      uInfo
                                                         , string        clientID
                                                         , string        patID
                                                         , string        active)
      
     {
        var recs = new List<PatientPerson>();
        ReturnDB rd = PatientPersons.view(connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, null, null, active, clientID, patID, null, null, null, null);       
        List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(PatientPerson));
        foreach (var o in slo) {
            recs.Add((PatientPerson) o);
        }
        return recs;
    }

	public static ReturnSaveRecordWithJSONData inviteParentGuardianPortal( SqlConnection connSpedmon
                                                                                , DetailsLog log
                                                                                , UserInfo uInfo
                                                                                , string clientID
                                                                                , string patID
                                                                                , string editDelReason
                                                                                , string validateRec
                                                                                , string saveType
                                                                                , string recID)
        {
            string saveSproc = @"PATIENT_PERSON_PORTAL_INVITE_SAVE";

            long vClientID = Validate.reqClientID(uInfo, clientID);
            long vPatID = Validate.reqInteger(patID, Messages.INVALID_PAT_ID);
            bool vValidateRec = Validate.reqFlag(validateRec, Messages.INVALID_VALIDATE_FLAG);
            int vSaveType = Validate.reqInteger(saveType, Messages.INVALID_SAVE_TYPE);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID", SqlDbType.BigInt, vPatID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pwdMinLen", SqlDbType.Int, Rules.PWD_MIN_LENGTH, ParameterDirection.Input));

            var so = Entities.saveAndReturnJSONData( connSpedmon
                                                        , log
                                                        , uInfo
                                                        , saveType
                                                        , validateRec
                                                        , editDelReason
                                                        , recID
                                                        , saveSproc
                                                        , @"Active invite already exists"
                                                        , ref parms
                                                        , null);

            return PatientPersonPortalCommon.ExtractAndProcessReturnData(ref so, vValidateRec);
        }																					   
  }
}
