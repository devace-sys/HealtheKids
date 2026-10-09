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
   * PatientGoalProgressMeasurement */
  /**
   * Used for deserialization of measurement data from svc rec
   **************************************************************************/
  public class PatientGoalProgressMeasurement
  {
    public string goalID;
    public string goalName;
    public string totalAttempts;
    public string successfulAttempts;
    public string score;
    public string practitionerSessionRating;
    public string patientSessionRating;
    public string inputGoalProgressUsingWhat;
    public string goalType;
  }

  /***************************************************************************
   * PatientGoalsProgressMeasurements */
  /**
   ***************************************************************************/   

  public class PatientGoalsProgressMeasurements
  {
    
    /***************************************************************************
     * parseGoalMeasurementsJSONIntoList */
    /**
     *
     ***************************************************************************/   

    public static List<PatientGoalProgressMeasurement> parseGoalMeasurementsJSONIntoList (
          SqlConnection connSpedmon
        , DetailsLog    log
        , UserInfo      uInfo
        , string        clientID
        , string        patID
        , string        groupSvcClassNameID
        , string        patientGoalProgressJSON
        , string        dos )
    {
      List<PatientGoalProgressMeasurement> progressMeasurements = new List<PatientGoalProgressMeasurement>();
      var objProgressMeasurements = MBA.JSON.fromJSONString(patientGoalProgressJSON,typeof(PatientGoalProgressMeasurement[]));
      var arrProgressMeasurements = (PatientGoalProgressMeasurement[]) objProgressMeasurements;            
      var patientGoals = PatientGoals.viewList(connSpedmon,log,uInfo,clientID,patID,groupSvcClassNameID,dos);
            
       foreach(var progressMeasurement in arrProgressMeasurements) { 
         progressMeasurement.goalName = patientGoals.Find(g => g.id.ToString() == progressMeasurement.goalID).name;
         progressMeasurements.Add(progressMeasurement);
      }
      return progressMeasurements;
    }
     
  }
}
