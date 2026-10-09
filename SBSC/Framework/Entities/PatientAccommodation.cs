using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;
 
namespace Spedmon
{    
  /***************************************************************************
   * PatientAccommodation */
  /**
   * 
   **************************************************************************/   
  public class PatientAccommodation : Entity
  {
    public const string DEFAULT_PAGING_ORDER = @"recordType asc, categoryName asc, id desc";

    public long     patID;
    public long     clientID;
    public int      recordType;
    public string   recordTypeStr;
    public int?     category;
    public string   categoryName;
    public string   accommodation;
    public string   details;
    public string   appliesTo;
    public string   appliesToNames;
    public string   startDateStr;
    public string   startDateYYYYMMDD;
    public string   endDateStr;
    public string   endDateYYYYMMDD;
    public int?     frequency;
    public string   frequencyName;
    public string   duration;
    public int?     location;
    public string   locationName;
    public string   locationOther;
    public string   linkedAreaOfNeed;
    public string   linkedAreaOfNeedNames;
    public string   alignedGoal;
    public string   alignedGoalNames;
    public string   staffResponsible;
    public string   staffResponsibleNames;
    public int      status;
    public string   statusStr;
    public string   discontinueReason;
    public string   activeStr;
    public int      isAssessmentSupport;
    public int      isDiscontinued;
  }  
  
  /***************************************************************************
   * PatientAccommodations */
  /**
   * 
   **************************************************************************/  
 
  public class PatientAccommodations: Entities
  {
    public const string URL_USER_ALL_SAVE_BASE      = @"user_all_pat_accommodations_save.aspx";

    public const string URL_SERVICE_BASE            = @"patient_accommodation.asmx";
    public const string URL_REST_DELETE_INLINE_BASE = URL_SERVICE_BASE + @"/deleteinline";
    public const string URL_VIEW_SEL                = URL_SERVICE_BASE + @"/viewSel";
    public const string URL_REST_VIEW_BASE          = @"api/v1/patientaccommodations";

    /***************************************************************************
     * URL_ADD_NEW_PATIENT_ACCOMMODATION */
    /**
     * 
     **************************************************************************/  
    public static string URL_ADD_NEW_PATIENT_ACCOMMODATION()
    {
      return MBA.HttpApplication.createLink( PatientAccommodations.URL_USER_ALL_SAVE_BASE
                                            , true
                                            , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                            , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW)                                            
                                            );
    }

    /***************************************************************************
     * URL_EDIT_PATIENT_ACCOMMODATION */
    /**
     * 
     **************************************************************************/  
    public static string URL_EDIT_PATIENT_ACCOMMODATION()
    {
      return MBA.HttpApplication.createLink (PatientAccommodations.URL_USER_ALL_SAVE_BASE
                                             , true
                                             , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                             , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT)
                                             , new NameValue(Constants.PARM_REC_ID, @"")
                                            );
    }

    /***************************************************************************
     * URL_CLONE_PATIENT_ACCOMMODATION */
    /**
     * 
     **************************************************************************/  
    public static string URL_CLONE_PATIENT_ACCOMMODATION()
    {
      return MBA.HttpApplication.createLink (PatientAccommodations.URL_USER_ALL_SAVE_BASE
                                             , true
                                             , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                             , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW)
                                             , new NameValue(Constants.PARM_REC_ID, @"")
                                            );
    }

    /***************************************************************************
     * URL_REST_DELETE_INLINE */
    /**
     * 
     **************************************************************************/ 

    public static string URL_REST_DELETE_INLINE()
    {
        return MBA.HttpApplication.createLink(PatientAccommodations.URL_REST_DELETE_INLINE_BASE, true);
    }

    /***************************************************************************
     * URL_REST_VIEW */
    /**
     * 
     **************************************************************************/  
    public static string URL_REST_VIEW()
    { 
       return MBA.HttpApplication.createLink(PatientAccommodations.URL_REST_VIEW_BASE, true);
    }

    /***************************************************************************
     * URL_VIEW_SEL_BASE */
    /**
     * 
     **************************************************************************/

    public static string URL_VIEW_SEL_BASE()
    { 
       return MBA.HttpApplication.createLink(URL_VIEW_SEL, true);
    }

    /***************************************************************************
     * view */
    /**
     * 
     **************************************************************************/

    public static ReturnDB view (  SqlConnection connSpedmon
                                 , DetailsLog    log
                                 , UserInfo      uInfo
                                 , int           recViewType
                                 , bool          pagedOrTop
                                 , string        idx
                                 , string        canEdit
                                 , string        active
                                 , string        clientID
                                 , string        patID                              
                                 , string        recordType
                                 , string        term 
                                 , string        refDate
                                 , defineCols    dc
                                 , bool requirePatID = false)
    { 

      var viewUDF = "PATIENT_ACCOMMODATIONS_VIEW (@userID, @userGroup, @userRank, @clientID, @patID, @recordType, @refDate, @term, @recID, @canEdit, @active)";  /* recid is null for now... */
 
      var parms = new List<SqlParameter>();
 
      /*----------------------------
       * Validate parameters specific
       * to this entity.view that 
       * will be used in all cases
       *----------------------------*/  
      
      Object    vClientID       = Validate.optClientID (uInfo, clientID);      
      Object    vPatID;
      
      if (requirePatID == true)
      {
        vPatID = Validate.reqPatID(uInfo, patID);
      }
      else
      {
        vPatID = Validate.optInteger(patID, Messages.INVALID_PAT_ID);
      }

      Object    vRecordType     = Validate.optInteger  (recordType,    @"Invalid record type");
      Object    vRefDate        = Validate.optDate     (refDate,       @"Invalid reference date");
      Object    vCanEdit        = Validate.optFlag     (canEdit,        Messages.INVALID_EDIT_FLAG);
      Object    vTerm           = Validate.optString(term);   
      Object    vIdx            = Validate.optInteger(idx, "Invalid id or page number");
              
      /*----------------------------
       * Populate database parameters
       *----------------------------*/
      
      parms.Add(Database.SqlParm("@clientID",             SqlDbType.BigInt     ,   vClientID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",                SqlDbType.BigInt     ,   vPatID,               ParameterDirection.Input));
      parms.Add(Database.SqlParm("@recordType",           SqlDbType.Int        ,   vRecordType,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@refDate",              SqlDbType.Date       ,   vRefDate,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",                 SqlDbType.VarChar    ,   vTerm,                ParameterDirection.Input, 50));
      
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
        
      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);
    }

    /***************************************************************************
     * load */
    /**
     * 
     **************************************************************************/  

    public static PatientAccommodation load (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string recID)
    {
        return (PatientAccommodation)Entities.load(connSpedmon, log, uInfo, recID, typeof(PatientAccommodation),
        delegate {
            return PatientAccommodations.view(connSpedmon
                            , log
                            , uInfo
                            , Entities.REC_VIEW_LOAD
                            , false
                            , recID
                            , ""
                            , ""
                            , ""
                            , ""
                            , null
                            , null
                            , null
                            , null); });
    }
   
    /***************************************************************************
     * get */
    /**
     * 
     **************************************************************************/  

    public static ReturnObjects get (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string recID)
    {
        ReturnObjects so = new ReturnObjects();

        PatientAccommodation rec = PatientAccommodations.load(connSpedmon, log, uInfo, recID);

        if (rec != null)
        {
          so.hasRecords = true;
          so.data       = new object[] { rec };
        }

        return so;
    }
   
    /***************************************************************************
     * viewSel */
    /**
     * 
     **************************************************************************/  

    public static ReturnSel viewSel(SqlConnection connSpedmon,
                                        DetailsLog log,
                                        UserInfo uInfo,
                                        bool top,
                                        string topSize,
                                        string active,
                                        string clientID,
                                        string patID,
                                        string recordType,
                                        string term)
    {
            
            /*----------------------------
             * Define our context column
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("cast(recordType as varchar(20)) as recData1");
                ss.addDisplayColumn("categoryName as recData2");
                ss.addDisplayColumn("accommodation as recData3");
                ss.addDisplayColumn("details as recData4");
                ss.addDisplayColumn("appliesToNames as recData5");
                ss.addDisplayColumn("case when isnull(frequencyName,'') = '' then isnull(duration,'') when isnull(duration,'') = '' then frequencyName else frequencyName + ' - ' + duration end as recData6");
                ss.addDisplayColumn("staffResponsibleNames as recData7");
                ss.addDisplayColumn("statusStr as recData8");
                ss.addDisplayColumn("cast(isAssessmentSupport as varchar(20)) as recData9");
                ss.addDisplayColumn("cast(isDiscontinued as varchar(20)) as recData10");
                ss.addDisplayColumn("selContextHTML as context1");
            };                         
            
            return Entities.viewSel(connSpedmon, log, uInfo, top, topSize,
            delegate { return view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, top, topSize, "", active, clientID, patID, recordType, term, "", dc, true); });

    }

    /***************************************************************************
     * viewObjects */
    /**
     * 
     **************************************************************************/  

    public static ReturnObjects viewObjects ( SqlConnection connSpedmon
                                             , DetailsLog log
                                             , UserInfo uInfo
                                             , bool pageObjectList
                                             , string pageOrder
                                             , string idx
                                             , string active
                                             , string clientID
                                             , string patID
                                             , string recordType)
 
    {
 
        /* Default page order */
 
        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PatientAccommodation.DEFAULT_PAGING_ORDER;
 
        /* Define columns delegate is used to specify columns and page order 
         * We pass in the desired page row order here */
 
        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            pageroworder = pageOrder;
        };
 
        return Entities.viewObjects(connSpedmon
                                      , log
                                      , uInfo
                                      , typeof(PatientAccommodation)
                                      , pageObjectList
                                      , pageOrder
                                      , delegate {
                                          return PatientAccommodations.view ( connSpedmon
                                                                               , log
                                                                               , uInfo
                                                                               , Entities.REC_VIEW_OBJECTS
                                                                               , pageObjectList
                                                                               , idx
                                                                               , "" /* Can edit */
                                                                               , active
                                                                               , clientID
                                                                               , patID
                                                                               , recordType
                                                                               , null
                                                                               , null
                                                                               , dc);
                                      });
 
 
    }
 
    /***************************************************************************
     * deleteInline */
    /**
     * 
     **************************************************************************/  
 
    public static ReturnSaveRecord deleteInline(SqlConnection connSpedmon
                                                   , DetailsLog log
                                                   , UserInfo uInfo
                                                   , string recID)
    {
        string deleteSproc  = @"PATIENT_ACCOMMODATIONS_Delete_Inline";
    
      /*###########################################################################
        # Validate parameters specific to this entity delete and create their 
        # database parameters.
        ###########################################################################*/  

      List<SqlParameter> parms = new List<SqlParameter>();
     
      /*###########################################################################
        # Call base method which handles the rest and returns the results
        ###########################################################################*/  

      return Entities.delete(connSpedmon,log,uInfo, @"", "N", recID,deleteSproc,ref parms);
    }
 
    /***************************************************************************
     * save */
    /**
     * 
     **************************************************************************/  

    public static ReturnSaveRecord save(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo
                                        , string patID
                                        , string recordType
                                        , string category
                                        , string categoryName
                                        , string accommodation
                                        , string details
                                        , string appliesTo
                                        , string appliesToNames
                                        , string startDate
                                        , string endDate
                                        , string frequency
                                        , string frequencyName
                                        , string duration
                                        , string location
                                        , string locationName
                                        , string locationOther
                                        , string linkedAreaOfNeed
                                        , string linkedAreaOfNeedNames
                                        , string alignedGoal
                                        , string alignedGoalNames
                                        , string staffResponsible
                                        , string staffResponsibleNames
                                        , string status
                                        , string discontinueReason
                                        , string editDelReason
                                        , string validateRec
                                        , string saveType
                                        , string recID)
    {

        long    vPatID                  = Validate.reqInteger (patID,                  Messages.INVALID_PAT_ID);

        Object  vRecordType             = Validate.optInteger (recordType,             @"Invalid record type");
        Object  vCategory               = Validate.optInteger (category,               @"Invalid category");
        Object  vCategoryName           = Validate.optString  (categoryName,           @"Invalid category name");
        Object  vAccommodation          = Validate.optString  (accommodation,          @"Invalid accommodation");
        Object  vDetails                = Validate.optString  (details,                @"Invalid details");
        Object  vAppliesTo              = Validate.optString  (appliesTo,              @"Invalid applies to");
        Object  vAppliesToNames         = Validate.optString  (appliesToNames,         @"Invalid applies to names");

        Object  vStartDate              = Validate.optDate    (startDate,              Messages.INVALID_START_DATE);
        Object  vEndDate                = Validate.optDate    (endDate,                Messages.INVALID_END_DATE);

        Object  vFrequency              = Validate.optInteger (frequency,              @"Invalid frequency");
        Object  vFrequencyName          = Validate.optString  (frequencyName,          @"Invalid frequency name");
        Object  vDuration               = Validate.optString  (duration,               @"Invalid duration");
        Object  vLocation               = Validate.optInteger (location,               @"Invalid location");
        Object  vLocationName           = Validate.optString  (locationName,           @"Invalid location name");
        Object  vLocationOther          = Validate.optString  (locationOther,          @"Invalid location other");

        Object  vLinkedAreaOfNeed       = Validate.optString  (linkedAreaOfNeed,       @"Invalid linked area of need");
        Object  vLinkedAreaOfNeedNames  = Validate.optString  (linkedAreaOfNeedNames,  @"Invalid linked area of need names");
        Object  vAlignedGoal            = Validate.optString  (alignedGoal,            @"Invalid aligned goal");
        Object  vAlignedGoalNames       = Validate.optString  (alignedGoalNames,       @"Invalid aligned goal names");
        Object  vStaffResponsible       = Validate.optString  (staffResponsible,       @"Invalid staff responsible");
        Object  vStaffResponsibleNames  = Validate.optString  (staffResponsibleNames,  @"Invalid staff responsible names");

        Object  vStatus                 = Validate.optInteger (status,                 @"Invalid status");
        Object  vDiscontinueReason      = Validate.optString  (discontinueReason,      @"Invalid discontinue reason");
 
        var parms = new List<SqlParameter>();
 
        parms.Add(Database.SqlParm("@patID",                 SqlDbType.BigInt,  vPatID,                 ParameterDirection.Input));
        parms.Add(Database.SqlParm("@recordType",            SqlDbType.Int,     vRecordType,            ParameterDirection.Input));
        parms.Add(Database.SqlParm("@category",              SqlDbType.Int,     vCategory,              ParameterDirection.Input));
        parms.Add(Database.SqlParm("@categoryName",          SqlDbType.VarChar, vCategoryName,          ParameterDirection.Input, 256));
        parms.Add(Database.SqlParm("@accommodation",         SqlDbType.VarChar, vAccommodation,         ParameterDirection.Input, 512));
        parms.Add(Database.SqlParm("@accomDetails",          SqlDbType.VarChar, vDetails,               ParameterDirection.Input, -1));
        parms.Add(Database.SqlParm("@appliesTo",             SqlDbType.VarChar, vAppliesTo,             ParameterDirection.Input, -1));
        parms.Add(Database.SqlParm("@appliesToNames",        SqlDbType.VarChar, vAppliesToNames,        ParameterDirection.Input, -1));
        parms.Add(Database.SqlParm("@startDate",             SqlDbType.Date,    vStartDate,             ParameterDirection.Input));
        parms.Add(Database.SqlParm("@endDate",               SqlDbType.Date,    vEndDate,               ParameterDirection.Input));
        parms.Add(Database.SqlParm("@frequency",             SqlDbType.Int,     vFrequency,             ParameterDirection.Input));
        parms.Add(Database.SqlParm("@frequencyName",         SqlDbType.VarChar, vFrequencyName,         ParameterDirection.Input, 256));
        parms.Add(Database.SqlParm("@duration",              SqlDbType.VarChar, vDuration,              ParameterDirection.Input, 512));
        parms.Add(Database.SqlParm("@location",              SqlDbType.Int,     vLocation,              ParameterDirection.Input));
        parms.Add(Database.SqlParm("@locationName",          SqlDbType.VarChar, vLocationName,          ParameterDirection.Input, 256));
        parms.Add(Database.SqlParm("@locationOther",         SqlDbType.VarChar, vLocationOther,         ParameterDirection.Input, 512));
        parms.Add(Database.SqlParm("@linkedAreaOfNeed",      SqlDbType.VarChar, vLinkedAreaOfNeed,      ParameterDirection.Input, -1));
        parms.Add(Database.SqlParm("@linkedAreaOfNeedNames", SqlDbType.VarChar, vLinkedAreaOfNeedNames, ParameterDirection.Input, -1));
        parms.Add(Database.SqlParm("@alignedGoal",           SqlDbType.VarChar, vAlignedGoal,           ParameterDirection.Input, -1));
        parms.Add(Database.SqlParm("@alignedGoalNames",      SqlDbType.VarChar, vAlignedGoalNames,      ParameterDirection.Input, -1));
        parms.Add(Database.SqlParm("@staffResponsible",      SqlDbType.VarChar, vStaffResponsible,      ParameterDirection.Input, -1));
        parms.Add(Database.SqlParm("@staffResponsibleNames", SqlDbType.VarChar, vStaffResponsibleNames, ParameterDirection.Input, -1));
        parms.Add(Database.SqlParm("@accomStatus",           SqlDbType.Int,     vStatus,                ParameterDirection.Input));
        parms.Add(Database.SqlParm("@discontinueReason",     SqlDbType.VarChar, vDiscontinueReason,     ParameterDirection.Input, 7000));
 
        return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "PATIENT_ACCOMMODATIONS_Save", Messages.DUP_CLIENT_REC, ref parms, null);
    }
  }
}