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
  /***************************************************************************
   * InputBatchesStatusCodesSvc */


  [WebService(Namespace = "http://spedcare.com/")]
  [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
  [ScriptService]
  
  public class InputBatchesStatusCodesSvc : MBA.WebSvc
  {

    /***************************************************************************
     * viewSel */
    /**
     * Selection view of input staff
     * 
     * @param  term         Required, search term string (last, first)
     ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSelByCode (string term) //TODO: this should not require a search term; all options should be shown
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel), 
      delegate()
      {
          return Spedmon.InputBatchesStatus.viewSel(this.dbConnApp, this.log, this.uInfo, true, "", null, term);        
      },
      Constants.ROLE_SBS_ALL); // Who can call this method
    }                                                         

  }
}
