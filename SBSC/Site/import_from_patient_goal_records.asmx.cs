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
  
  /***************************************************************************
   * ImportFromPatientGoalRecordsSvc */
  /**
   * 
   *************************************************************************/

  public class ImportFromPatientGoalRecordsSvc : MBA.WebSvc
  {


    public ImportFromPatientGoalRecordsSvc() : base() { }

    /***************************************************************************
     * viewSel */
    /**
     *
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSel(string clientid
                            , string patid
                            , string dos
                            )
    {
        return (ReturnSel)

        callMethod(
            typeof(ReturnSel),

            delegate()
            {
                return Spedmon.ImportFromPatientGoalRecords.viewSel(this.dbConnApp
                                                                    , this.log
                                                                    , this.uInfo
                                                                    , true
                                                                    , clientid
                                                                    , patid
                                                                    , dos
                                                                );
            },

            Constants.ROLE_ALL_PCAL_AND_CLIENT
        );
    }
	
    /***************************************************************************
     * importdata */
    /**
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecordWithJSONData importdata (string clientid
                                                    , string datatoimportjson       
                                                    , string validaterec )
    {
      return (ReturnSaveRecordWithJSONData) 
     
      callMethod(typeof(ReturnSaveRecordWithJSONData),       
      delegate()
      {                     
        return Spedmon.ImportFromPatientGoalRecords.importData (this.dbConnApp
                                                                  , this.log
                                                                  , this.uInfo   
                                                                  , clientid
                                                                  , datatoimportjson          
                                                                  , validaterec
                                                                 );                                           
      },
      Constants.ROLE_ADMIN);  // Who can call this method           
    }  
    
  }
}
