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
    [WebService(Namespace = "http://spedcare.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]

    public class PracticeOfficeVisitReasonSvc : MBA.WebSvc
    {
      /***************************************************************************
       * saveinline */
      /**
       * 
       ***************************************************************************/

      [WebMethod]
      [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

      public ReturnSaveRecord saveinline (         
         string name
       , string groupserviceclassnameid
       , string formdatajson
       , string practiceofficevisitresolutionid
       , string hidevisitsection
       , string savetype
       , string recid )
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {                     
        return Spedmon.PracticeOfficeVisitReasons.save (                        
            this.dbConnApp
          , this.log
          , this.uInfo   
          , name
          , groupserviceclassnameid
          , formdatajson
          , practiceofficevisitresolutionid
          , hidevisitsection
          , @""  /*editDelReason*/
          , @"N" /*validaterec*/
          , savetype
          , recid);                                           
       }
      , Constants.ROLE_SBS_ALL);  // Who can call this method           
    }   
     /***************************************************************************
     * deleteinline */
     /**
       * 
     ***************************************************************************/

      [WebMethod]
      [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

      public ReturnSaveRecord deleteinline ( string recid )
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()

      {                     
        return Spedmon.PracticeOfficeVisitReasons.delete (                        
            this.dbConnApp
          , this.log
          , this.uInfo             
          , @""  /*editDelReason*/
          , @"N" /*validaterec*/
          , recid);                                           
       }
      , Constants.ROLE_SBS_ALL);  // Who can call this method           
    }        		           
        
        
    /***************************************************************************
     * viewSel */
    /**
     * 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSel(string groupserviceclassnameid, string term)
    {
      return (ReturnSel)
      callMethod(typeof(ReturnSel),
      delegate ()
      {
        return Spedmon.PracticeOfficeVisitReasons.viewSel ( dbConnApp
                                                           , log
                                                           , uInfo
                                                           , false
                                                           , ""
                                                           , "Y"
                                                           , groupserviceclassnameid
                                                           , term
                                                          );
      }, Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }
  }
}
