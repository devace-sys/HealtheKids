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
  
  public class ClaimsRetroactiveForSpaSvc : MBA.WebSvc
  {
    /***************************************************************************
     * saveclientauthorizationsapprove */
    /**
     * 
     **************************************************************************/ 
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
	public ReturnSaveOrReplaceRecord saveclientauthorizationsapprove ( string recids ) 
    
    {
      return (ReturnSaveOrReplaceRecord) callMethod ( typeof (ReturnSaveOrReplaceRecord),
      delegate()
      { 
        return ClaimsRetroactiveForSpa.saveClientAuthorizations ( 
            dbConnApp 
          , log
          , uInfo
          , recids 
          , "1");
     }
     , Constants.ROLE_ADMIN_CONSULTANT_LEA_COORD);
    }
    
    /***************************************************************************
     * saveclientauthorizationsdecline */
    /**
     * 
     **************************************************************************/ 
   
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
	public ReturnSaveOrReplaceRecord saveclientauthorizationsdecline ( string recids ) 
    {
      return (ReturnSaveOrReplaceRecord) callMethod ( typeof (ReturnSaveOrReplaceRecord),
      delegate()
      { 
        return ClaimsRetroactiveForSpa.saveClientAuthorizations ( 
            dbConnApp 
          , log
          , uInfo
          , recids 
          , "0" );
     }
     , Constants.ROLE_ADMIN_CONSULTANT_LEA_COORD);
    }

    /***************************************************************************
     * getpotentialreimbursesums */
    /**
     * 
     **************************************************************************/ 
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnClaimsRetroactiveForSpaPotentialReimburseSums getpotentialreimbursesums (string clientid, string fyid)
    {
           
      return (ReturnClaimsRetroactiveForSpaPotentialReimburseSums)
      callMethod(typeof(ReturnClaimsRetroactiveForSpaPotentialReimburseSums),
      delegate()
      {
        return Spedmon.ClaimsRetroactiveForSpa.getPotentialReimburseSums (dbConnApp, log, uInfo, Spedmon.ClaimsRetroactiveForSpa.FOR_SPA_2015, clientid, fyid);
      },
      Constants.ROLE_ADMIN_CONSULTANT_LEA_COORD);

    }

  }
}
