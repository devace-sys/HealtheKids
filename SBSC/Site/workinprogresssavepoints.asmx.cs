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

  public class WorkInProgressSavePointsSvc: MBA.WebSvc
  {
    
    /***************************************************************************
     * saveorreplace */
    /**
     * 
     ***************************************************************************/ 
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnSaveOrReplaceRecord saveorreplace (string requestresource, string savepointname, string saveddatajson)
    {
      return (ReturnSaveOrReplaceRecord)
      callMethod(typeof(ReturnSaveOrReplaceRecord), 
      delegate()
      {
        return Spedmon.WorkInProgressSavePoints.saveOrReplace(dbConnUser,log,uInfo,"N",requestresource,savepointname,saveddatajson);
        
      },
      Constants.ROLE_ALL); // Who can call this method    
    }

	/***************************************************************************
     * delete */
    /**
     * 
     ***************************************************************************/ 
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnSaveRecord delete (string requestresource, string savepointname)
    {
      return (ReturnSaveRecord)
      callMethod(typeof(ReturnSaveRecord), 
      delegate()
      {
        return Spedmon.WorkInProgressSavePoints.delete(dbConnUser,log,uInfo,"","N",requestresource,savepointname);
      },
      Constants.ROLE_ALL); // Who can call this method    
    }

  }
}
