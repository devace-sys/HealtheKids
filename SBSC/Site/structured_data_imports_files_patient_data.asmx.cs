using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.Services.Protocols;
using System.Web.Script.Serialization;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

  [WebService(Namespace = "http://spedcare.com/")]
  [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
  [ScriptService]


  
  public class StructuredDataImportFilesPatientDataSvc : MBA.WebSvc
  {


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSaveRecord sendFlaggedScheduledTonight(
                                               //string clientid,
                                               string pdiID
                                               )
    {
        return (ReturnSaveRecord)
        callMethod(typeof(ReturnSaveRecord),
        delegate ()
        {

            return Spedmon.StructuredDataImportFilesPatientData.sendFlaggedScheduledTonight(
                                          this.dbConnApp
                                        , this.log
                                        , this.uInfo
                                        //, clientid
                                        , pdiID
                                        );
        },
        Constants.ROLE_SBS_ALL);  // Who can call this method           
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSaveRecord sendFlaggedUnscheduled(
                                            //string clientid,
                                            string pdiID
                                            )
    {
        return (ReturnSaveRecord)
        callMethod(typeof(ReturnSaveRecord),
        delegate ()
        {

            return Spedmon.StructuredDataImportFilesPatientData.sendFlaggedUnschedule(

                                          this.dbConnApp
                                        , this.log
                                        , this.uInfo
                                        //, clientid
                                        , pdiID
                                        );

        },
        Constants.ROLE_SBS_ALL);  // Who can call this method           
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSaveRecord sendFlaggedReprocessLive(
                                            //string clientid,
                                            string pdiID
                                            )
    {
        return (ReturnSaveRecord)
        callMethod(typeof(ReturnSaveRecord),
        delegate ()
        {

            return Spedmon.StructuredDataImportFilesPatientData.sendFlaggedReprocessLive(

                                          this.dbConnApp
                                        , this.log
                                        , this.uInfo
                                        //, clientid
                                        , pdiID
                                        );

        },
        Constants.ROLE_SBS_ALL);  // Who can call this method           
    }

  }
}
