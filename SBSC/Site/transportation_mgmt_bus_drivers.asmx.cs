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
   * TransportationMgmtBusDriversSvc */
  /*
   * Unless indicated, each of these methods require that the caller is
   * logged in.
   *
   * Each end point method provides a wrapper for a corresponding framework
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
  
  public class TransportationMgmtBusDriversSvc : MBA.WebSvc
  {
    public TransportationMgmtBusDriversSvc() : base() { }
   
    /***************************************************************************
     * viewSel */
    /**
     * 
     * @param  clientid     Required, client id
     * @param  term         Required, search term string (blank for all)
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSel viewSel (string clientid, string term)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel),
      delegate()
      {
        return Spedmon.TransportationMgmtBusDrivers.viewSel(this.dbConnApp, this.log, this.uInfo, true, "", "", clientid, term);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    }

    /***************************************************************************
     * save */
    /**
     * 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSaveRecord save(
         string clientid
       , string firstname           
       , string lastname
       , string recid
       , string savetype
    )
    {
        return (ReturnSaveRecord)
        callMethod(typeof(ReturnSaveRecord),
        delegate ()
        {
            return Spedmon.TransportationMgmtBusDrivers.save(
              this.dbConnApp
            , this.log
            , this.uInfo
            , clientid
            , firstname
            , lastname
            , ""
            , "0"
            , savetype
            , recid);
        },
        Constants.ROLE_ALL_PCAL_AND_CLIENT);
    }

    /***************************************************************************
    * delete */
    /**
    *
    ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord delete(string recid)
    {
        return (ReturnSaveRecord)
        callMethod(typeof(ReturnSaveRecord),
        delegate ()
        {
            return Spedmon.TransportationMgmtBusDrivers.delete(this.dbConnApp,
                                       this.log,
                                       this.uInfo,
                                       "",
                                       "0",
                                       recid);
        },
        Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }

    /***************************************************************************
     * viewEntity */
    /**
     * load one record
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnEntity viewEntity(string clientid, string recid)
    {
      return (ReturnEntity) 
      callMethod(typeof(ReturnEntity),
      delegate()
      {
        return Spedmon.TransportationMgmtBusDrivers.viewEntity(
            this.dbConnApp
          , this.log
          , this.uInfo
          , clientid
          , recid);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
    } 
  }
}
