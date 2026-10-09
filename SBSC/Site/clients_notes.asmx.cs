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
using System.IO;

namespace Spedmon
{
 
  [WebService(Namespace = "http://spedcare.com/")]
  [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
  [ScriptService]

  public class ClientsNotesSvc : MBA.WebSvc
  {

    public ClientsNotesSvc() : base() { }

    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord saveinline( string topicid, string subject, string notetext, string sharedwithclient, string clientid,

       //string editDelReason,
       //string validaterec,

       string savetype,
       string recid)
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.ClientsNotes.save(this.dbConnApp, this.log, this.uInfo,

                                                topicid,
                                                subject,
                                                notetext,
                                                sharedwithclient,
                                                clientid,

                                                "" , //editDelReason,
                                                "N" , //validateRec,
                                                savetype,
                                                recid);            },
            Constants.ROLE_SBS_ALL_LEA_COORD);  // Who can call this method           
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord deleteinline( string recid )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.ClientsNotes.delete(this.dbConnApp, this.log, this.uInfo, 
                                                "", //editDelReason,
                                                "N", //validateRec,
                                                recid);
            },
            Constants.ROLE_SBS_ALL_LEA_COORD);  // Who can call this method           
        }

    }
}
