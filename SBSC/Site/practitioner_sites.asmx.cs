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
     * PractitionerSitesSvc  */
    /**
     * 
     *************************************************************************/

    public class PractitionerSitesSvc : MBA.WebSvc
  {


    public PractitionerSitesSvc() : base() { }



        /***************************************************************************
         * saveinline */
        /**
         * 
         * Save or edit
         ***************************************************************************/


        [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSaveRecord saveinline (
          string clientid
        , string pracid
        , string siteid

        , string savetype
        , string recid  )
    {
        return (ReturnSaveRecord) callMethod(
            typeof(ReturnSaveRecord),
            delegate ()
            {
            return Spedmon.PractitionerSites.save (

                this.dbConnApp
              , this.log
              , this.uInfo
              , clientid
              , pracid
              , siteid
              , ""
              , "N"
              , savetype
              , recid);
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);  // TODO ???
    }

  }
}
