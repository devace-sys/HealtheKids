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

    public class KnownHealthProblemssvc : MBA.WebSvc
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

         , string belongstohealthservices
         , string belongstomentalhealth

         , string savetype
         , string recid )
        {
          return (ReturnSaveRecord) 
     
         callMethod(typeof(ReturnSaveRecord),       
         delegate()
         {                     
           return Spedmon.KnownHealthProblems.save (                        
              this.dbConnApp
            , this.log
            , this.uInfo   
            , name

            , belongstohealthservices
            , belongstomentalhealth

            , ""
            , "N"
            , savetype
            , recid);                                           
        },
        Constants.ROLE_SBS_ALL);  // Who can call this method           
      }   
        
        /***************************************************************************
         * deleteinline */
        /**
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord deleteinline (string recid )
        {
          return (ReturnSaveRecord) 
     
         callMethod(typeof(ReturnSaveRecord),       
         delegate()
         {                     
           return Spedmon.KnownHealthProblems.delete (                        
              this.dbConnApp
            , this.log
            , this.uInfo   
            , ""
            , "N"
            , recid);                                           
        },
        Constants.ROLE_SBS_ALL);  // Who can call this method           
      }   

        /***************************************************************************
         * viewSel */
        /**
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSel(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate ()
            {
                return Spedmon.KnownHealthProblems.viewSel(dbConnApp
                                                            , log
                                                            , uInfo
                                                            , false
                                                            , ""
                                                            , "Y"
                                                            , term);
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
        }


    }
}
