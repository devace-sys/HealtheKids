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
   * PatientGoal */
  /**
   *
   **************************************************************************/

  public class PatientGoal: Entity
  {
    public const string DEFAULT_PAGING_ORDER = @"name asc, id desc";

    public long     clientID;
    public long     groupSvcClassNameID;
    public string   groupSvcClassName;
    public long     patID;
    public string   patName;
    public string   startDateStrYMD;
    public string   endDateStrYMD;
    public string   startDateStr;
    public string   endDateStr;
    public bool     goalMet;

    public DateTime goalMetOn;
    public string   goalMetOnStrYMD;
    public string   goalMetOnStr;

    public string   backgroundText;
    public string   notes;
    public bool     hasObjectives;

    public bool     hasObjective1;
    public string   objective1Text;
    public bool     objective1Met;
    public DateTime objective1MetOn;
    public string   objective1MetOnStrYMD;
    public string   objective1MetOnStr;

    public bool     hasObjective2;
    public string   objective2Text;
    public bool     objective2Met;
    public DateTime objective2MetOn;
    public string   objective2MetOnStrYMD;
    public string   objective2MetOnStr;

    public bool     hasObjective3;
    public string   objective3Text;
    public bool     objective3Met;
    public DateTime objective3MetOn;
    public string   objective3MetOnStrYMD;
    public string   objective3MetOnStr;

    public long     goalTypeID;
    public string   goalTypeName;
    public int      inputGoalProgressUsingWhat;
    public Decimal  baseLineValue;
    public bool     userDefinedGoal;
    public int      numSessionsWithProgressData = 0;
    public DateTime firstSessionDateWithProgressData;
    public DateTime lastSessionDateWithProgressData;
    public string   firstSessionDateWithProgressDataStr = "";
    public string   lastSessionDateWithProgressDataStr  = "";

  }

  /***************************************************************************
   * PatientGoals */
  /**
   ***************************************************************************/   
  
  public class PatientGoals:Entities
  {

    public const string URL_SVC_BASE                = @"patient_goals.asmx";
    public const string URL_REST_SAVE_INLINE        = URL_SVC_BASE + @"/save";
    public const string URL_REST_DELETE_INLINE      = URL_SVC_BASE + @"/delete";

    public const string URL_REST_VIEW               = @"api/v1/patientgoals";

    /***************************************************************************
     * URL_REST_VIEW */
    /**
     * 
     **************************************************************************/
    public static string URL_REST_VIEW_BASE()
    {
        return MBA.HttpApplication.createLink(PatientGoals.URL_REST_VIEW, true);
    }
    public static string URL_REST_SAVE_INLINE_BASE()
    {
        return MBA.HttpApplication.createLink(PatientGoals.URL_REST_SAVE_INLINE, true);
    }

    public static string URL_REST_DELETE_INLINE_BASE()
    {
        return MBA.HttpApplication.createLink(PatientGoals.URL_REST_DELETE_INLINE, true);
    }

    /***************************************************************************
     * delete */
    /**
     * "Deletes" record
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    public static ReturnSaveRecord delete (  SqlConnection   connSpedmon
                                           , DetailsLog      log
                                           , UserInfo        uInfo
                                           , string          editDelReason
                                           , string          validateRec
                                           , string          clientID
                                           , string          recID )
    {           
                
      string deleteSproc  = @"PATIENT_GOALS_DELETE";
    
      /*###########################################################################
        # Validate parameters specific to this entity delete and create their 
        # database parameters.
        ###########################################################################*/  

      Object vClientID = Validate.optClientID(uInfo, clientID);      
      
      List<SqlParameter> parms = new List<SqlParameter>();
      parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
     
      /*###########################################################################
        # Call base method which handles the rest and returns the results
        ###########################################################################*/  

      return Entities.delete(connSpedmon,log,uInfo,editDelReason,validateRec,recID,deleteSproc,ref parms);
    }
    
   /***************************************************************************
    * save */
   /**
    * Save new or update existing record
    *
    * @param  userID          User id of who is recording service
    * @param  userGroup       1 = Client, 2 = SBSC (from users db)
    * @param  userRank        Users role ranking
    * @param  clientID        Client id
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
                                         , string        groupSvcClassNameID
                                         , string        patID
                                         , string        name
                                         , string        goalTypeID
                                         , string        baseLineValue
                                         , string        startDate
                                         , string        endDate
                                         , string        goalMet

                                         , string        goalMetOn
                                         , string        backgroundText
                                         , string        notes

                                         , string        objective1Text
                                         , string        objective1Met
                                         , string        objective1MetOn

                                         , string        objective2Text
                                         , string        objective2Met
                                         , string        objective2MetOn

                                         , string        objective3Text
                                         , string        objective3Met
                                         , string        objective3MetOn

                                         , string        editDelReason
                                         , string        validateRec
                                         , string        saveType
                                         , string        recID)
    {           
                       
      string saveSproc = @"PATIENT_GOALS_SAVE";
      string dupRecMsg = @"Patient goal already exists";

      /*###########################################################################
        # Validate parameters specific to this entity save and create their 
        # database parameters
        ###########################################################################*/

      long     vClientID            = Validate.reqClientID               (uInfo,     clientID);
      long     vGroupSvcClassNameID = Validate.reqStdGroupSvcClassNameID (uInfo,     groupSvcClassNameID);
      long     vPatID               = Validate.reqInteger                (patID,     Messages.INVALID_PAT_ID);
      string   vName                = Validate.reqString                 (name,      @"Invalid goal description");
      Object   vStartDate           = Validate.optDate                   (startDate, Messages.INVALID_START_DATE);
      Object   vEndDate             = Validate.optDate                   (endDate,   Messages.INVALID_END_DATE);
      Object   vGoalMet             = Validate.optFlag                   (goalMet,   @"Invalid goal met flag");
      
      Object vGoalMetOn             = Validate.optDate                   (goalMetOn, @"Invalid goal met date");
      string vBackgroundText        = Validate.optString                 (backgroundText);
      string vNotes                 = Validate.optString                 (notes);

      string vObjective1Text        = Validate.optString                 (objective1Text);
      Object vObjective1Met         = Validate.optFlag                   (objective1Met,    @"Invalid objective 1 met flag");
      Object vObjective1MetOn       = Validate.optDate                   (objective1MetOn,  @"Invalid objective 1 met date");

      string vObjective2Text        = Validate.optString                 (objective2Text);
      Object vObjective2Met         = Validate.optFlag                   (objective2Met,    @"Invalid objective 2 met flag");
      Object vObjective2MetOn       = Validate.optDate                   (objective2MetOn,  @"Invalid objective 2 met date");

      string vObjective3Text        = Validate.optString                 (objective3Text);
      Object vObjective3Met         = Validate.optFlag                   (objective3Met,    @"Invalid objective 3 met flag");
      Object vObjective3MetOn       = Validate.optDate                   (objective3MetOn,  @"Invalid objective 3 met date");

      long     vGoalTypeID          = Validate.reqInteger                (goalTypeID,    @"Invalid type of goal");           
      Object   vBaseLineValue       = Validate.optInteger                (baseLineValue, @"Invalid baseline", true);

      var parms = new List<SqlParameter>();
  
      parms.Add(Database.SqlParm("@clientID",            SqlDbType.BigInt,  vClientID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@groupSvcClassNameID", SqlDbType.BigInt,  vGroupSvcClassNameID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",               SqlDbType.BigInt,  vPatID,               ParameterDirection.Input));
      parms.Add(Database.SqlParm("@name",                SqlDbType.VarChar, vName,                ParameterDirection.Input, -1));
      parms.Add(Database.SqlParm("@startDate",           SqlDbType.Date,    vStartDate,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",             SqlDbType.Date,    vEndDate,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@goalMet",             SqlDbType.Bit,     vGoalMet,             ParameterDirection.Input));

      parms.Add(Database.SqlParm("@goalMetOn",           SqlDbType.Date,    vGoalMetOn,           ParameterDirection.Input));

      parms.Add(Database.SqlParm("@backgroundText",      SqlDbType.VarChar, vBackgroundText,      ParameterDirection.Input, -1));
      parms.Add(Database.SqlParm("@notes",               SqlDbType.VarChar, vNotes,               ParameterDirection.Input, -1));

      parms.Add(Database.SqlParm("@objective1Text",      SqlDbType.VarChar, vObjective1Text,      ParameterDirection.Input, -1));
      parms.Add(Database.SqlParm("@objective1Met",       SqlDbType.Bit, vObjective1Met,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@objective1MetOn",     SqlDbType.Date, vObjective1MetOn,        ParameterDirection.Input));

      parms.Add(Database.SqlParm("@objective2Text",      SqlDbType.VarChar, vObjective2Text,      ParameterDirection.Input, -1));
      parms.Add(Database.SqlParm("@objective2Met",       SqlDbType.Bit, vObjective2Met,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@objective2MetOn",     SqlDbType.Date, vObjective2MetOn,        ParameterDirection.Input));

      parms.Add(Database.SqlParm("@objective3Text",      SqlDbType.VarChar, vObjective3Text,      ParameterDirection.Input, -1));
      parms.Add(Database.SqlParm("@objective3Met",       SqlDbType.Bit, vObjective3Met,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@objective3MetOn",     SqlDbType.Date, vObjective3MetOn,        ParameterDirection.Input));

      parms.Add(Database.SqlParm("@goalTypeID",          SqlDbType.BigInt,  vGoalTypeID,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@baseLineValue",       SqlDbType.Int,     vBaseLineValue,       ParameterDirection.Input));
      
      /*###########################################################################
        # Call base method which handles the rest and returns the results
        ###########################################################################*/  

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms,null);
    }

    /***************************************************************************
     * createOrGetServiceRatingGoal */
    /**
     * 
     ***************************************************************************/   
    public static ReturnSaveOrReplaceRecord createOrGetServiceRatingGoal (  
          SqlConnection connSpedmon
        , DetailsLog    log
        , UserInfo      uInfo
        , string        clientID
        , string        patID
        , string        groupSvcClassNameID
        , string        svcName )
    {

      string opSproc = @"PATIENT_GOALS_CREATE_OR_GET_SERVICE_RATING_GOAL";

      var parms = new List<SqlParameter>();

      long     vClientID            = Validate.reqClientID               (uInfo,     clientID);
      long     vGroupSvcClassNameID = Validate.reqStdGroupSvcClassNameID (uInfo,     groupSvcClassNameID);
      long     vPatID               = Validate.reqInteger                (patID,     Messages.INVALID_PAT_ID);
      string   vSvcName             = Validate.reqString                 (svcName,   @"Invalid service name");
      
      parms.Add(Database.SqlParm("@clientID",            SqlDbType.BigInt,  vClientID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@groupSvcClassNameID", SqlDbType.BigInt,  vGroupSvcClassNameID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",               SqlDbType.BigInt,  vPatID,               ParameterDirection.Input));
      parms.Add(Database.SqlParm("@svcName",             SqlDbType.VarChar, vSvcName,             ParameterDirection.Input, 1000));

      return Entities.saveOrReplaceRecord(connSpedmon,log,uInfo,"",opSproc,ref parms,null);
      
    }

    /***************************************************************************
     * view */
    /**
     * View patient goals
     * 
     * @return            ReturnDB
     ***************************************************************************/   

    public static ReturnDB view ( SqlConnection connSpedmon
                                 , DetailsLog log
                                 , UserInfo uInfo
                                 , int recViewType
                                 , bool   pagedOrTop
                                 , string idx
                                 , string canEdit
                                 , string active
                                 , string clientID
                                 , string patID
                                 , string groupSvcClassNameID
                                 , string startDate
                                 , string endDate
                                 , defineCols dc)
    {

      string viewUDF  = "dbo.PATIENT_GOALS_VIEW (@userID, @userGroup, @userRank, @clientID, @patID, @groupSvcClassNameID, @startDate, @endDate, @active, @recID)";
      
      /*----------------------------
      * Validate parameters specific
      * to this entity.view
      * and populate their
      * coresponding database
      * parameters
      *----------------------------*/
      
      Object vClientID            = Validate.optClientID               (uInfo, clientID, true);
      Object vPatID               = Validate.optPatID                  (uInfo, patID);
      Object vGroupSvcClassNameID = Validate.optStdGroupSvcClassNameID (uInfo, groupSvcClassNameID);      
      Object[] vDates             = Validate.optStartAndEndDate        (startDate, endDate, Messages.INVALID_DATE_RANGE);

      var parms = new List<SqlParameter>();   

      parms.Add(Database.SqlParm("@clientID",            SqlDbType.BigInt, vClientID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",               SqlDbType.BigInt, vPatID,               ParameterDirection.Input));
      parms.Add(Database.SqlParm("@groupSvcClassNameID", SqlDbType.BigInt, vGroupSvcClassNameID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startDate",           SqlDbType.Date,   vDates[0],            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",             SqlDbType.Date,   vDates[1],            ParameterDirection.Input));
   
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
     * Loads single record
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing client specific data
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @return                 ReturnEntity
     ***************************************************************************/

    public static PatientGoal load (  SqlConnection connSpedmon
                                                 , DetailsLog    log
                                                 , UserInfo      uInfo
                                                 , string        clientID
                                                 , string        patID
                                                 , string        groupSvcClassNameID
                                                 , string        recID )
    {      
      return (PatientGoal) Entities.load(connSpedmon, log, uInfo, recID, typeof(PatientGoal),
      delegate { return PatientGoals.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", clientID, patID, groupSvcClassNameID, "","", null); });
    }

    /***************************************************************************
     * viewObjects 
     *
     * Returns a list of objects
     * 
     ***************************************************************************/

     public static ReturnObjects viewObjects (   SqlConnection connSpedmon
                                               , DetailsLog    log
                                               , UserInfo      uInfo
                                               , bool          pageObjectList
                                               , string        pageOrder
                                               , string        idx
                                               , string        active
                                               , string        clientID
                                               , string        patID
                                               , string        groupSvcClassNameID
     )
     {

         /* Default page order */

         if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PatientGoal.DEFAULT_PAGING_ORDER;

         /* Define columns delegate is used to specify columns and page order 
          * We pass in the desired page row order here */

         defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
         {
             pageroworder = pageOrder;
         };

         return Entities.viewObjects(connSpedmon
                                       , log
                                       , uInfo
                                       , typeof(PatientGoal)
                                       , pageObjectList
                                       , pageOrder
                                       , delegate
                                       {
                                           return PatientGoals.view (connSpedmon
                                                                    , log
                                                                    , uInfo
                                                                    , Entities.REC_VIEW_OBJECTS
                                                                    , pageObjectList
                                                                    , idx
                                                                    , "" // canEdit
                                                                    , active
                                                                    , clientID
                                                                    , patID
                                                                    , groupSvcClassNameID
                                                                    , ""
                                                                    , ""
                                                                    , dc);
                                       });


     }

    /***************************************************************************
     * viewSel */
    /**
     * 
     ***************************************************************************/

     public static ReturnSel viewSel (  SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , bool          top
                                      , string        topSize
                                      , string        clientID
                                      , string        patID
                                      , string        groupSvcClassNameID
                                      , string        dos )
     {

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {
                ss.addDisplayColumn("convert(varchar(50),inputGoalProgressUsingWhat) as recData1");
                ss.addDisplayColumn("convert(varchar(50),goalTypeID) as recData2");
                ss.addDisplayColumn("dbo.BIT_TO_YN(goalMet) as recData3");
                ss.addDisplayColumn("dbo.RPT_DATE_FMT_YYYY_MM_DD(goalMetOn) as recData4");
                ss.addDisplayColumn("dbo.BIT_TO_YN(hasObjectives) as recData5");
                ss.addDisplayColumn("dbo.BIT_TO_YN(hasObjective1) as recData6");
                ss.addDisplayColumn("objective1Text as recData7");
                ss.addDisplayColumn("dbo.BIT_TO_YN(objective1Met) as recData8");
                ss.addDisplayColumn("dbo.RPT_DATE_FMT_YYYY_MM_DD(objective1MetOn) as recData9");
                ss.addDisplayColumn("dbo.BIT_TO_YN(hasObjective2) as recData10");
                ss.addDisplayColumn("objective2Text as recData11");
                ss.addDisplayColumn("dbo.BIT_TO_YN(objective2Met) as recData12");
                ss.addDisplayColumn("dbo.RPT_DATE_FMT_YYYY_MM_DD(objective2MetOn) as recData13");
                ss.addDisplayColumn("dbo.BIT_TO_YN(hasObjective3) as recData14");
                ss.addDisplayColumn("objective3Text as recData15");
                ss.addDisplayColumn("dbo.BIT_TO_YN(objective3Met) as recData16");
                ss.addDisplayColumn("dbo.RPT_DATE_FMT_YYYY_MM_DD(objective3MetOn) as recData17");

            };
     
       return Entities.viewSel(  connSpedmon
                               , log
                               , uInfo
                               , top
                               , topSize
                               , delegate {
                                   return PatientGoals.view (  connSpedmon
                                                      , log
                                                      , uInfo
                                                      , Entities.REC_VIEW_SEL
                                                      , top
                                                      , topSize
                                                      , ""
                                                      , "1"
                                                      , clientID
                                                      , patID
                                                      , groupSvcClassNameID
                                                      , dos
                                                      , dos
                                                      , dc);});
    
         
     }
     
     /***************************************************************************
      * viewList */
     /**
      * 
      ***************************************************************************/
      public static List<PatientGoal> viewList ( SqlConnection connSpedmon
                                                , DetailsLog log
                                                , UserInfo uInfo
                                                , string clientID
                                                , string patID
                                                , string groupSvcClassNameID
                                                , string dos )
      {
         var recs = new List<PatientGoal>();
         
         var rd = PatientGoals.view (  connSpedmon
                                     , log
                                     , uInfo
                                     , Entities.REC_VIEW_RAW
                                     , false
                                     , ""
                                     , ""
                                     , "Y"
                                     , clientID
                                     , patID
                                     , groupSvcClassNameID
                                     , dos
                                     , dos
                                     , null);

         var slo = Database.convertRecordsToList(ref rd.records, typeof(PatientGoal));
         foreach (var o in slo) {
            recs.Add((PatientGoal)o);
         }
         return recs;
        }
    }
 }
