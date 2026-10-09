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
using System.IO;

namespace Spedmon
{
  /***************************************************************************
   * PatientGoalsSvc */
  /*
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
  public class PatientGoalsSvc : MBA.WebSvc
  {
    public PatientGoalsSvc() : base() { }
    
   /***************************************************************************
    * delete */
   /**
    * "delete" a record.
    * 
    * @param  validaterec   Required, True=Yes, False=No
    * @param  editDelReason Reason for delete
    * @param  recid         Record id to delete
    ***************************************************************************/  
              
    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord delete (string recid, string clientid)
    {
    return (ReturnSaveRecord)
    callMethod(typeof(ReturnSaveRecord),    
    delegate()
    {    
      return Spedmon.PatientGoals.delete(this.dbConnApp,
                                         this.log,
                                         this.uInfo,
                                         "",
                                         "0",
                                         clientid,
                                         recid);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }

    /***************************************************************************
     * save */
    /**
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save (
         string clientid
       , string groupsvcclassnameid
       , string patid
       , string name
       , string goaltypeid
       , string baselinevalue
       , string startdate
       , string enddate
       , string goalmet

       , string goalmeton
       , string backgroundtext
       , string notes
       , string objective1text
       , string objective1met
       , string objective1meton

       , string objective2text
       , string objective2met
       , string objective2meton

       , string objective3text
       , string objective3met
       , string objective3meton

       , string savetype
       , string recid )
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {                     
        return Spedmon.PatientGoals.save (                        
            this.dbConnApp
          , this.log
          , this.uInfo   
          , clientid
          , groupsvcclassnameid
          , patid
          , name
          , goaltypeid
          , baselinevalue
          , startdate
          , enddate
          , goalmet

          , goalmeton
          , backgroundtext
          , notes
          , objective1text
          , objective1met
          , objective1meton

          , objective2text
          , objective2met
          , objective2meton

          , objective3text
          , objective3met
          , objective3meton

          , ""
          , "0"
          , savetype
          , recid);                                           
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }   
        
/***************************************************************************
     * save */
    /**
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSaveOrReplaceRecord createorgetserviceratinggoal (
          string clientid
        , string patid
        , string groupsvcclassnameid
        , string svcname )
    {
      return (ReturnSaveOrReplaceRecord) 
     
      callMethod(typeof(ReturnSaveOrReplaceRecord),       
      delegate()
      {                     
        return Spedmon.PatientGoals.createOrGetServiceRatingGoal (                        
            this.dbConnApp
          , this.log
          , this.uInfo   
          , clientid          
          , patid 
          , groupsvcclassnameid
          , svcname
        );        
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
   }       
        
   /***************************************************************************
    * viewSel */
    /**
    * 
    ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnSel viewSel( string clientid
                            , string patid
                            , string groupsvcclassnameid)
    {
      return (ReturnSel)
      callMethod(typeof(ReturnSel), 
      delegate()
      {
        return Spedmon.PatientGoals.viewSel(this.dbConnApp, this.log, this.uInfo, false, "", clientid, patid, groupsvcclassnameid, ""); 
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method    
    }

   /***************************************************************************
    * viewSel2 */
    /**
    * Same as viewSel but with the addition of a dos to limit selections
    * to goals that are in effect for the dos date
    ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSel viewSel2 (  string clientid
                               , string patid
                               , string groupsvcclassnameid
                               , string dos )
    {
      return (ReturnSel)
      callMethod(typeof(ReturnSel), 
      delegate()
      {
        return Spedmon.PatientGoals.viewSel(this.dbConnApp, this.log, this.uInfo, false, "", clientid, patid, groupsvcclassnameid, dos); 
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method    
    }
    /***************************************************************************
     * viewProgressIndividualGoal */
    /**
     * 
     ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnObjects viewProgressIndividualGoal (  string clientid
                                                     , string patid
                                                     , string goalid )
    {
      return (ReturnObjects)
      callMethod(typeof(ReturnObjects), 
      delegate()
      {
        return Spedmon.PatientGoalsProgressIndividualGoals.viewObjects(  this.dbConnApp
                                                                        , this.log
                                                                        , this.uInfo
                                                                        , false
                                                                        , ""
                                                                        , goalid
                                                                        , ""
                                                                        , clientid
                                                                        , patid
                                                                        , goalid);  
      
      },
      Constants.ROLE_PATIENT_GOALS); // Who can call this method    
    }


    /***************************************************************************
     * viewDefaultDates */
    /**
     * 
     ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnObject viewDefaultDates (string clientid, string groupserviceclassnameid, string patid)
    {
      return (ReturnObject)
      callMethod(typeof(ReturnObject), 
      delegate()
      {
        return Spedmon.PatientGoalsDefaultDates.viewObject (  this.dbConnApp
                                                              , this.log
                                                              , this.uInfo
                                                              , clientid
                                                              , patid
                                                              , groupserviceclassnameid);  
      
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method    
    }
  }
}
