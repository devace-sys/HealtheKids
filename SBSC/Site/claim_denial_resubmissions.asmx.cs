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
  
  public class ClaimDenialResubmissionsSvc : MBA.WebSvc
  {
    
    /***************************************************************************
     * viewSel */
    /**
     * Selection view 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord saveDismissed (  string recids )
    {
      return (ReturnSaveRecord) 
      callMethod(typeof(ReturnSaveRecord),
      delegate()
      { 
        return Spedmon.ClaimDenialResubmissions.denialSaveDismissed (   dbConnApp 
                                             , log
                                             , uInfo
                                             , recids //MBA.HttpApplication.getParameter("recids")
                                             );                                             
      },
      Constants.ROLE_SBS_ALL); // Who can call this method
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord saveResub (  string recids )
    {
      return (ReturnSaveRecord) 
      callMethod(typeof(ReturnSaveRecord),
      delegate()
      { 
        return Spedmon.ClaimDenialResubmissions.denialSaveResub (   dbConnApp 
                                             , log
                                             , uInfo
                                             , recids);                                               
      },
      Constants.ROLE_SBS_ALL); // Who can call this method
    }     
         
  }
}
