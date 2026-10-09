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

    public class PracticeOfficeKiosksSvc : MBA.WebSvc
    {
      /***************************************************************************
       * saveinline */
      /**
       * 
       ***************************************************************************/

      [WebMethod]
      [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

      public ReturnSaveRecord saveinline (    
            string clientid
          , string groupserviceclassnameid
          , string siteid
          , string name
          , string starttime
          , string endtime
          , string savetype
          , string recid )
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {                     
        return Spedmon.PracticeOfficeKiosks.save (                        
            this.dbConnApp
          , this.log
          , this.uInfo   
          , clientid
          , groupserviceclassnameid
          , siteid
          , name
          , starttime
          , endtime
          , @""  /*editDelReason*/
          , @"N" /*validaterec*/
          , savetype
          , recid);                                           
       }
      , Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }        		           
        
      /***************************************************************************
       * deleteinline */
      /**
       * 
       ***************************************************************************/

      [WebMethod]
      [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

      public ReturnSaveRecord deleteinline (    
            string clientid
          , string groupserviceclassnameid
          , string recid )
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {                     
        return Spedmon.PracticeOfficeKiosks.delete (                        
            this.dbConnApp
          , this.log
          , this.uInfo   
          , clientid
          , groupserviceclassnameid
          , @""  /*editDelReason*/
          , @"N" /*validaterec*/
          , recid);                                           
       }
      , Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }        		           

  }
}
