using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    
  /***************************************************************************
   * PractitionerCaseloadMember */
  /**
   * 
   ***************************************************************************/

  public class PractitionerPatientGroupMember:Entity
  {
        public const string DEFAULT_PAGING_ORDER = "name";

        public long     clientID;
        public string   clientName;
	    public long     pracID;
	    public string   pracName;
        public long     patID;
        public string   patName;    
        public string   dobStr;
        public string   siteName;
        public string   minsIndStr;
        public string   minsGrpStr;    
  }
  
 
  /***************************************************************************
   * PractitionerCaseloadMembers */
  /**
   * 
   ***************************************************************************/

  public class PractitionerPatientGroupMembers: Entities
  {
    public const string URL_ASMX            = "practitioner_patient_group_members.asmx";
    public const string URL_ASMX_SAVE       = URL_ASMX + "/save";
    public const string URL_ASMX_BULK_SAVE  = URL_ASMX + "/saveall";
    public const string URL_ASMX_DELETE     = URL_ASMX + "/delete";
    public const string URL_ASMX_VIEW_SEL   = URL_ASMX + "/viewSel";

    /********************************************
     * GEN_URL_ASMX_SAVE_ALL
     ********************************************/
    public static string GEN_URL_ASMX_SAVE_ALL() { 
        return MBA.HttpApplication.createLink(URL_ASMX_BULK_SAVE, true);
    }
    /********************************************
     * GEN_URL_ASMX_DELETE
     ********************************************/
    public static string GEN_URL_ASMX_DELETE() { 
        return MBA.HttpApplication.createLink(URL_ASMX_DELETE, true);
    }
    
    /********************************************
     * GEN_URL_ASMX_VIEW_SEL
     ********************************************/
    public static string GEN_URL_ASMX_VIEW_SEL() { 
        return MBA.HttpApplication.createLink(URL_ASMX_VIEW_SEL, true);
    }
    
    /********************************************
     * GEN_URL_ASMX_SAVE
     ********************************************/
    public static string GEN_URL_ASMX_SAVE() { 
        return MBA.HttpApplication.createLink(URL_ASMX_SAVE, true);
    }

    /***************************************************************************
     * REST VIEW */
    /**
     * 
     ***************************************************************************/
    public const string URL_REST_VIEW = @"api/v1/practitionerpatientgroupmembers";

    public static string URL_REST_VIEW_BASE()
    { 
       return MBA.HttpApplication.createLink(URL_REST_VIEW, true);
    }

    /***************************************************************************
     * saveMultiple */
    /**
     * 
     ***************************************************************************/

    public static Return saveall (   SqlConnection dbConnSpedmon
                                            , DetailsLog   log
                                            , UserInfo     uInfo
                                            , string       clientID				                                
                                            , string       pracID				                                                                   
                                            , string       patSelectedJSON
                                            , string       groupID
                                            , string       validateRec )
    {
        string saveType = Constants.SAVE_TYPE_NEW.ToString();
        string recID = "";

        string saveSproc = @"PRACTITIONER_PATIENT_GROUP_MEMBER_SAVE_MULTIPLE";
        string dupRecMsg = @"Record already exists";

        /*###########################################################################
            # Validate parameters specific to this entity save and create their 
            # database parameters
            ###########################################################################*/

        var vClientID           = Validate.reqClientID (uInfo, clientID);
        var vPracID             = Validate.reqPracID   (uInfo, pracID);
        var vGroupID            = Validate.reqInteger  (groupID,      @"Invalid group id");
        var vPatSelectedJSON    = Validate.reqString   (patSelectedJSON,  @"Invalid patient data");

        var parms = new List<SqlParameter>();

        parms.Add(Database.SqlParm("@clientID"                 , SqlDbType.BigInt   ,vClientID         , ParameterDirection.Input));
        parms.Add(Database.SqlParm("@pracID"                   , SqlDbType.BigInt   ,vPracID           , ParameterDirection.Input));
        parms.Add(Database.SqlParm("@groupID"                  , SqlDbType.BigInt   ,vGroupID          , ParameterDirection.Input));
        parms.Add(Database.SqlParm("@patSelectedJSON"          , SqlDbType.VarChar  ,vPatSelectedJSON  , ParameterDirection.Input, -1)); 

        /*###########################################################################
          # Call base method which handles the rest and returns the results
          ###########################################################################*/

        return Entities.save(dbConnSpedmon, log, uInfo, saveType, validateRec, "", recID, saveSproc, dupRecMsg, ref parms, null);
    } 

    /***************************************************************************
     * delete */
    /**
     * "Deletes" a practitioner patient group record
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/

    public static ReturnSaveRecord delete (
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        editDelReason
      , string        validateRec       
      , string        clientID
      , string        pracID
      , string        pracPatGroupID
      , string        patID)
    {

      /*----------------------------
       * Validate parameters specific
       * to this entity.delete
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
      
      long   vClientID        = Validate.reqClientID  (uInfo, clientID);
      long   vPracID          = Validate.reqPracID    (uInfo, pracID);      
      long   vPracPatGroupID  = Validate.reqInteger   (pracPatGroupID, Messages.INVALID_PRACTITIONER_PATIENT_GROUP_ID);
      long   vPatID           = Validate.reqInteger   (patID,          Messages.INVALID_PAT_ID);  
	  
      parms.Add(Database.SqlParm("@clientID",        SqlDbType.BigInt,    vClientID,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",          SqlDbType.BigInt,    vPracID,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracPatGroupID",  SqlDbType.BigInt,    vPracPatGroupID,  ParameterDirection.Input)); 
	    parms.Add(Database.SqlParm("@patID",           SqlDbType.BigInt,    vPatID,           ParameterDirection.Input)); 
	 
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, patID, @"PRACTITIONER_PATIENT_GROUP_MEMBER_DELETE", ref parms);
    }
   

   /***************************************************************************
    * save */
    /**
    * Save a practitioner patient group member record
    *
    * @param  userID          User id of who is recording service
    * @param  userGroup       1 = Client, 2 = SBSC (from users db)
    * @param  userRank        Users role ranking
    * @param  clientID        Patient's client id
    * @param  pracID          Practitioner id
    * @param  patID           Patient id

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
    * @param  recID           Record id of existing record to edit or delete.
    * @return                 ReturnSaveNewRecord
    ***************************************************************************/   
  
    public static ReturnSaveRecordWithJSONData save (
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        clientID
      , string        pracID
      , string        pracPatGroupID
      , string        patID
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
      
      long   vClientID        = Validate.reqClientID  (uInfo, clientID);
      long   vPracID          = Validate.reqPracID    (uInfo, pracID);      
      long   vPracPatGroupID  = Validate.reqInteger   (pracPatGroupID, Messages.INVALID_PRACTITIONER_PATIENT_GROUP_ID);
      long   vPatID           = Validate.reqInteger   (patID,          Messages.INVALID_PAT_ID);  
	  
      parms.Add(Database.SqlParm("@clientID",        SqlDbType.BigInt,    vClientID,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",          SqlDbType.BigInt,    vPracID,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracPatGroupID",  SqlDbType.BigInt,    vPracPatGroupID,  ParameterDirection.Input)); 
	  parms.Add(Database.SqlParm("@patID",           SqlDbType.BigInt,    vPatID,           ParameterDirection.Input)); 
	 
      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.saveAndReturnJSONData(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "PRACTITIONER_PATIENT_GROUP_MEMBER_SAVE", Messages.DUP_CASELOAD_REC , ref parms, null);
       
    }    
                                                    
   /***************************************************************************
    * view */
   /**
    * Returns a list of group members for given criteria
    * 
    ***************************************************************************/   

    public static ReturnDB view (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, 
                                 int    recViewType,
                                 bool   pagedOrTop,
                                 string idx,
                                 string canEdit,
                                 string active,
                                 string clientID, 
                                 string pracID,
                                 string pracPatGroupID,
                                 string term,
                                 string iep,
                                 string nameID,
                                 string refDate,
                                 defineCols dc)
    { 
      
      string viewUDF = "PRACTITIONER_PATIENT_GROUP_MEMBERS_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @pracPatGroupID, @term, @iep, @nameID, @refDate, @recID)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/  
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
      long   vClientID        = Validate.reqClientID  (uInfo, clientID);
      long   vPracID          = Validate.reqPracID    (uInfo, pracID);      
      long   vPracPatGroupID  = Validate.reqInteger   (pracPatGroupID, Messages.INVALID_PRACTITIONER_PATIENT_GROUP_ID);
      string vTerm            = Validate.optString    (term,           @"Invalid search term");
      
      Object vIEP     = Validate.optFlag    (iep,      Messages.INVALID_BOOL);
      Object vNameID  = Validate.optInteger (nameID,   Messages.INVALID_SERVICE);
      Object vRefDate = Validate.optDate    (refDate,  Messages.INVALID_DOS);
      
      parms.Add(Database.SqlParm("@clientID",        SqlDbType.BigInt,    vClientID,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",          SqlDbType.BigInt,    vPracID,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracPatGroupID",  SqlDbType.BigInt,    vPracPatGroupID,  ParameterDirection.Input)); 
      parms.Add(Database.SqlParm("@term",            SqlDbType.VarChar,   vTerm,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@iep",             SqlDbType.Bit,       vIEP,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@nameID",          SqlDbType.BigInt,    vNameID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@refDate",         SqlDbType.Date,      vRefDate,   ParameterDirection.Input));

      
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
      
      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

    }  

   
   /***************************************************************************
    * viewSel */
   /**
    * View group member record selections
    * 
    * @return                 ReturnSel
    ***************************************************************************/   
    
    public static ReturnSel viewSel (SqlConnection connSpedmon, 
                                     DetailsLog log, 
                                     UserInfo uInfo, 
                                     bool top, 
                                     string topSize, 
                                     string clientID, 
                                     string pracID,
                                     string pracPatGroupID,                                     
                                     string term,
                                     string iep,
                                     string nameID,
                                     string refDate ) 
    {

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){  
        ss.addSortColumn("name");
        ss.addDisplayColumn("dobStr + ' | ' + siteName + ' | Ind: ' + minsIndStr + ' | Grp: ' + minsGrpStr as [context1]");
        ss.addDisplayColumn("minsIndStr     as [recData1]");
        ss.addDisplayColumn("minsGrpStr     as [recData2]");
        ss.addDisplayColumn("ytdNumMinsStr  as [recData3]");
        ss.addDisplayColumn("mtdNumMinsStr  as [recData4]");

        ss.addDisplayColumn("ytdDosMinStr   as [recData5]");
        ss.addDisplayColumn("ytdDosMaxStr   as [recData6]");
        ss.addDisplayColumn("ytdNumSvcsStr  as [recData7]");

        ss.addDisplayColumn("mtdDosMinStr   as [recData8]");
        ss.addDisplayColumn("mtdDosMaxStr   as [recData9]");
        ss.addDisplayColumn("mtdNumSvcsStr  as [recData10]");
             
        ss.addDisplayColumn("[email]  as [recData11]");
        ss.addDisplayColumn("[phone] as [recData12]");

      };
            
      return Entities.viewSel(connSpedmon, log, uInfo,top, topSize,
        delegate{return PractitionerPatientGroupMembers.view (connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, top, topSize, "", "Y", clientID, pracID, pracPatGroupID, term, iep, nameID, refDate, dc);});
    } 
        
      
    /***************************************************************************
     * viewObjects */
    /**
     ***************************************************************************/
    public static ReturnObjects viewObjects (   SqlConnection connSpedmon
                                              , DetailsLog log
                                              , UserInfo uInfo
                                              , bool   pageObjectList
                                              , string pageOrder
                                              , string idx
                                              , string active
                                              , string clientID
                                              , string pracID
                                              , string pracPatGroupID
                                              , string term
                                              , string iep
                                              , string nameID
                                              , string refDate)

    {

      /* Default page order */

      if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PractitionerPatientGroupMember.DEFAULT_PAGING_ORDER;

      /* Define columns delegate is used to specify columns and page order 
       * We pass in the desired page row order here */

      defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        pageroworder = pageOrder;
      };

      return Entities.viewObjects (   connSpedmon
                                    , log
                                    , uInfo
                                    , typeof(PractitionerPatientGroupMember)
                                    , pageObjectList
                                    , pageOrder
                                    , delegate {
                                        return PractitionerPatientGroupMembers.view(
                                                                                   connSpedmon
                                                                                 , log
                                                                                 , uInfo
                                                                                 , Entities.REC_VIEW_OBJECTS
                                                                                 , pageObjectList
                                                                                 , idx
                                                                                 , ""
                                                                                 , active
                                                                                 , clientID 
                                                                                 , pracID
                                                                                 , pracPatGroupID
                                                                                 , term
                                                                                 , iep
                                                                                 , nameID
                                                                                 , refDate
                                                                                 , dc);
                                    });


    }
   
 } 
}

