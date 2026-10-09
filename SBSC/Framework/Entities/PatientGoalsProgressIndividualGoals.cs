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
   * PatientGoalsProgressIndividualGoal */
  /**
   *
   **************************************************************************/

  public class PatientGoalsProgressIndividualGoal: Entity
  {
    public const string DEFAULT_PAGING_ORDER = @"sessionNumber asc";

    public long     goalID;
    public long     sessionNumber;
    public string   sessionDateStr;
    public DateTime sessionDateTime;
    public string   sessionDateTimeStr;
    public Decimal  scoreValue;
    public string   scoreValueStr;
    public int?     successfulAttempts;
    public int?     totalAttempts;
    public string   successfulAttemptsStr;
    public string   totalAttemptsStr;
    public long?    pracID;
    public string   pracName;
    public string   pracGroup;
    public Decimal  measurementValue;
    public Decimal  measurementValue2;
    public string   sessionRatingPracStr;
    public string   sessionRatingPatStr;
    public string   measurementTitle;
  }

  /***************************************************************************
   * PatientGoalsProgressViewItem */
  /**
   *
   **************************************************************************/

  public class PatientGoalsProgressViewItem
  {
     public PatientGoal goal;
     public string      chartID;
  }

  /***************************************************************************
   * PatientGoalsProgressIndividualGoals */
  /**
   ***************************************************************************/   
  public class PatientGoalsProgressIndividualGoals:Entities
  {

    public const string MENU_ID                                = "patgoalproginvgoallnk";
    public const string URL_REST_VIEW                          = @"api/v1/patientgoalsprogressindividualgoal";
    public const string URL_SVC_VIEW_PROGRESS_INDIVIDUAL_GOALS = PatientGoals.URL_SVC_BASE 
                                                               + @"/viewProgressIndividualGoal";
    
    public const string URL_USER_ALL_VIEW_ALL_GOALS_PROGRESS = @"user_all_pat_goals_progress_view.aspx";

    public const string URL_USER_ALL_VIEW_ALL_GOALS_PROGRESS_THUMBNAILS = @"user_all_pat_goals_progress_view_thumbnails.aspx";

    public static string URL_REST_VIEW_BASE()
    {
        return MBA.HttpApplication.createLink(PatientGoalsProgressIndividualGoals.URL_REST_VIEW, true);
    }
    
    public static string URL_SVC_VIEW_PROGRESS_INDIVIDUAL_GOALS_BASE()
    {
      return MBA.HttpApplication.createLink(PatientGoalsProgressIndividualGoals.URL_SVC_VIEW_PROGRESS_INDIVIDUAL_GOALS, true);
    }
    
    public static string URL_USER_ALL_VIEW_ALL_GOALS_PROGRESS_BASE ()
    {
      return MBA.HttpApplication.createLink(PatientGoalsProgressIndividualGoals.URL_USER_ALL_VIEW_ALL_GOALS_PROGRESS          
          , true
          , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
          );
    }

    public static string URL_USER_ALL_VIEW_ALL_GOALS_PROGRESS_BASE (string clientid, string patid)
    {
      return MBA.HttpApplication.createLink(PatientGoalsProgressIndividualGoals.URL_USER_ALL_VIEW_ALL_GOALS_PROGRESS          
          , true
          , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
          , new NameValue(Constants.PARM_CLIENT_ID,  clientid)
          , new NameValue(Constants.PARM_PATIENT_ID, patid)
          );
    }

    public static string URL_USER_ALL_VIEW_ALL_GOALS_PROGRESS_PREVIEW_BASE (string clientid, string patid)
    {
      return MBA.HttpApplication.createLink(
            PatientGoalsProgressIndividualGoals.URL_USER_ALL_VIEW_ALL_GOALS_PROGRESS_THUMBNAILS
          , true
          , new NameValue(Constants.PARM_CONTENT_ONLY, 1)
          , new NameValue(Constants.PARM_CLIENT_ID,  clientid)
          , new NameValue(Constants.PARM_PATIENT_ID, patid)
          );
    }

    public static string URL_USER_ALL_VIEW_ALL_GOALS_PROGRESS_MENU_ITEM_BASE (string clientid, string patid)
    {
      return MBA.HttpApplication.createLink(PatientGoalsProgressIndividualGoals.URL_USER_ALL_VIEW_ALL_GOALS_PROGRESS          
          , true          
          , new NameValue(Constants.PARM_CLIENT_ID,  clientid)
          , new NameValue(Constants.PARM_PATIENT_ID, patid)
          );
    }
    
    /***************************************************************************
     * generateParentPortalPatientGoalsProgressReviewUrlsFromUInfo*/
    /**
     *
     ***************************************************************************/   

    public static List<PCalPerformanceWidgetUrlSet> generateParentPortalPatientGoalsProgressReviewUrlSetFromUInfo (UserInfo uInfo)
    {
        var urlSets = new List<PCalPerformanceWidgetUrlSet>();

        if (uInfo != null && uInfo.userRoleID == Constants.ROLE_PARENT_GUARDIAN_ID)
        {
          if (uInfo.associatedPatientPersons != null)
          {
             foreach (var patientPerson in uInfo.associatedPatientPersons)
             {
               var urlSet = new PCalPerformanceWidgetUrlSet();
               urlSet.title          = "Goal Progress for <br>" + patientPerson.patientName;
               urlSet.label          = "Patient Goal Progress for " + patientPerson.patientName;
               urlSet.iframeSrcUrl   = URL_USER_ALL_VIEW_ALL_GOALS_PROGRESS_PREVIEW_BASE(patientPerson.clientID.ToString(),patientPerson.patientID.ToString());
               urlSet.popUpPageUrl   = URL_USER_ALL_VIEW_ALL_GOALS_PROGRESS_BASE(patientPerson.clientID.ToString(),patientPerson.patientID.ToString());
               urlSet.regularPageUrl = URL_USER_ALL_VIEW_ALL_GOALS_PROGRESS_MENU_ITEM_BASE(patientPerson.clientID.ToString(),patientPerson.patientID.ToString());
               urlSet.menuID         = MENU_ID + patientPerson.patientID.ToString();
               urlSets.Add(urlSet);
             }
          }
        }
        return urlSets;
    }

    /***************************************************************************
     * view */
    /**
     * 
     * @return            ReturnDB
     ***************************************************************************/   

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
								 , string        goalID
                                 , defineCols    dc)
    {

      string viewUDF  = "dbo.PATIENT_GOALS_INDIVIDUAL_GOAL_PROGRESS_VIEW (@userID, @userGroup, @userRank, @clientID, @patID, @groupSvcClassNameID, @goalID)";
            
      int    vClientID             = Validate.reqClientID               (uInfo,  clientID);
      int    vPatID                = Validate.reqInteger                (patID,  Messages.INVALID_PAT_ID);
      Object vGroupSvcClassNameID  = Validate.optStdGroupSvcClassNameID (uInfo,  @"");  /* Ensures pracs can only see their practice family */
      int    vGoalID               = Validate.reqInteger                (goalID, @"Invalid goalID");

      var parms = new List<SqlParameter>();   

      parms.Add(Database.SqlParm("@clientID",            SqlDbType.BigInt, vClientID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",               SqlDbType.BigInt, vPatID,               ParameterDirection.Input));
      parms.Add(Database.SqlParm("@groupSvcClassNameID", SqlDbType.BigInt, vGroupSvcClassNameID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@goalID",              SqlDbType.BigInt, vGoalID,              ParameterDirection.Input));

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      
      
    }

    /***************************************************************************
     * viewObjects 
     *
     * Returns a list of objects
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
                                               , string     goalID )
     {

         /* Default page order */

         if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PatientGoalsProgressIndividualGoal.DEFAULT_PAGING_ORDER;

         /* Get patient goal header data */

         var pg = PatientGoals.load(connSpedmon, log, uInfo, clientID, patID, "", goalID);

         /* Define columns delegate is used to specify columns and page order 
          * We pass in the desired page row order here */

         defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
         {
             pageroworder = pageOrder;
         };

         var vo = Entities.viewObjects (   connSpedmon
                                       , log
                                       , uInfo
                                       , typeof(PatientGoalsProgressIndividualGoal)
                                       , pageObjectList
                                       , pageOrder
                                       , delegate {
                                           return PatientGoalsProgressIndividualGoals.view ( connSpedmon
                                                                                            , log
                                                                                            , uInfo
                                                                                            , Entities.REC_VIEW_OBJECTS
                                                                                            , pageObjectList
                                                                                            , idx
                                                                                            , "" // canEdit
                                                                                            , active
                                                                                            , clientID
                                                                                            , patID                                                                                            
                                                                                            , goalID
                                                                                            , dc);
                                       });

           
            /* Put in header and footer data*/
            
            vo.header1 = pg.patName;
            vo.header2 = pg.name;
            vo.header3 = pg.groupSvcClassName;
            vo.header4 = pg.startDateStr + " to " + pg.endDateStr;

            vo.footer1 = "Generated using SpEdCare on " + DateTime.Now.ToString();
            vo.footer2 = Messages.CONFIDENTIAL;
            
            /* If we have data determine first and last session dates and add these to
               the patient goal object*/

            if (vo.hasRecords == true) { 
              List<DateTime> sessionDates = new List<DateTime>();
              foreach (Object o in vo.data) {
                PatientGoalsProgressIndividualGoal pig = (PatientGoalsProgressIndividualGoal) o;
                sessionDates.Add(pig.sessionDateTime);
              };
              sessionDates.Sort();
              int lastIdx = sessionDates.Count - 1;
              pg.numSessionsWithProgressData         = sessionDates.Count;
              pg.firstSessionDateWithProgressData    = sessionDates[0];
              pg.lastSessionDateWithProgressData     = sessionDates[lastIdx];
              pg.firstSessionDateWithProgressDataStr = pg.firstSessionDateWithProgressData.ToShortDateString();
              pg.lastSessionDateWithProgressDataStr  = pg.lastSessionDateWithProgressData.ToShortDateString();
              /* Replace date range header */
              vo.header4 = pg.firstSessionDateWithProgressDataStr + " to " + pg.lastSessionDateWithProgressDataStr;
             }
            
            /* Add patient goal to output */

            vo.referenceObject1           = pg;
            vo.referenceObject1FullName   = typeof(PatientGoal).FullName;

            
            return vo;
     }
  
     /***************************************************************************
      * viewItems */
     /**
      * 
      ***************************************************************************/
      public static List<PatientGoalsProgressViewItem> viewItems ( SqlConnection connSpedmon
                                                                  , DetailsLog log
                                                                  , UserInfo uInfo
                                                                  , string   clientID
                                                                  , string   patID
                                                                  , string   groupSvcClassNameID
                                                                  , string   dos )
      {
         var recs = new List<PatientGoalsProgressViewItem>();

         var goals = PatientGoals.viewList(connSpedmon, log, uInfo, clientID, patID, groupSvcClassNameID, dos);
         foreach (var goal in goals) {
           var rec     = new PatientGoalsProgressViewItem();
           rec.goal    = goal;
           rec.chartID = "goal" + goal.id;
           recs.Add(rec);
         }
         return recs;
        }
  }
}
