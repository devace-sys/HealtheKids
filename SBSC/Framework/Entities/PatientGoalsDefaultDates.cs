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
   * PatientGoalDefaultDates */
  /**
   *
   **************************************************************************/

  public class PatientGoalDefaultDates
  {
    public long     clientID;
	public long     patID;
	public long     groupSvcClassNameID;
    public DateTime startDate;
    public DateTime endDate;
    public string   startDateStrYMD;
    public string   endDateStrYMD;
    public string   startDateStr;
    public string   endDateStr;
    public long     defaultGoalTypeID;
  }

  /***************************************************************************
   * PatientGoalsDefaultDates */
  /**
   ***************************************************************************/   
  
  public class PatientGoalsDefaultDates:Entities
  {
    public const string URL_SVC_VIEW_DEFAULT_DATES = PatientGoals.URL_SVC_BASE 
                                                   + @"/viewDefaultDates";

    public static string URL_SVC_VIEW_DEFAULT_DATES_BASE()
    {
      return MBA.HttpApplication.createLink(PatientGoalsDefaultDates.URL_SVC_VIEW_DEFAULT_DATES, true);
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
								 , string        groupSvcClassNameID
                                 , defineCols    dc)
    {

      string viewUDF  = "dbo.PATIENT_GOALS_VIEW_DEFAULT_DATES (@userID, @userGroup, @userRank, @clientID, @patID, @groupSvcClassNameID, @refDate)";
            
      int    vClientID             = Validate.reqClientID               (uInfo,  clientID);
      int    vPatID                = Validate.reqInteger                (patID,  Messages.INVALID_PAT_ID);
      long   vGroupSvcClassNameID  = Validate.reqStdGroupSvcClassNameID (uInfo,  groupSvcClassNameID);  
    
      var parms = new List<SqlParameter>();   

      parms.Add(Database.SqlParm("@clientID",            SqlDbType.BigInt, vClientID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",               SqlDbType.BigInt, vPatID,               ParameterDirection.Input));
      parms.Add(Database.SqlParm("@groupSvcClassNameID", SqlDbType.BigInt, vGroupSvcClassNameID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@refDate",             SqlDbType.DateTime, DateTime.Now,       ParameterDirection.Input));

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

    public static PatientGoalDefaultDates load (  SqlConnection connSpedmon
                                                 , DetailsLog    log
                                                 , UserInfo      uInfo
                                                 , string        clientID
                                                 , string        patID
                                                 , string        groupSvcClassNameID )
    {      
      return (PatientGoalDefaultDates) 
         
         Entities.loadNRecord(connSpedmon, log, uInfo, 1, typeof(PatientGoalDefaultDates)
          ,delegate {
             return PatientGoalsDefaultDates.view ( connSpedmon
                                                  , log
                                                  , uInfo
                                                  , Entities.REC_VIEW_LOAD_N
                                                  , false
                                                  , ""  /* idx */
                                                  , ""  /* canEdit */
                                                  , ""  /* active  */
                                                  , clientID
                                                  , patID
                                                  , groupSvcClassNameID
                                                  , null);
        });
    }
    
    /***************************************************************************
     * viewObject */
    /**
     * 
     * @return            ReturnObject
     ***************************************************************************/   

    public static ReturnObject viewObject (  SqlConnection connSpedmon
                                            , DetailsLog log
                                            , UserInfo uInfo
                                            , string clientID
                                            , string patID
                                            , string groupSvcClassNameID )
    {
       ReturnObject so = new ReturnObject();
       so = Entities.viewObject(  connSpedmon
                                 , log
                                 , uInfo
                                 , typeof(PatientGoalDefaultDates)
                                 , delegate {
                                     return PatientGoalsDefaultDates.view(connSpedmon
                                                                          , log
                                                                          , uInfo
                                                                          , Entities.REC_VIEW_OBJECT
                                                                          , false
                                                                          , ""  /* idx */
                                                                          , ""  /* canEdit */
                                                                          , ""  /* active  */
                                                                          , clientID
                                                                          , patID
                                                                          , groupSvcClassNameID
                                                                          , null);
                                  });
        return so;
    }   
  }
}
