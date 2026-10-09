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
   * InsuranceCarriersSvc */
  /**
   * 
   *************************************************************************/

  public class InsuranceCarriersSvc : MBA.WebSvc
  {

    public InsuranceCarriersSvc() : base() { }

        /***************************************************************************
         * viewSel */
        /**
         * 
         * @param  term  Required, search term string (blank for all)
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel viewSel(string term)
        {
            return (ReturnSel)
            callMethod(typeof(ReturnSel),
            delegate ()
            {
                return Spedmon.InsuranceCarriers.viewSel(this.dbConnApp, this.log, this.uInfo, true, "", term);
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);
        }

        /***************************************************************************
        * deleteinline */
        /**
         * "delete" a insurance carrier record.
         * 
         * @param  recid         Record id to delete
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord deleteinline(string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.InsuranceCarriers.delete(this.dbConnApp,
                                                             this.log,
                                                             this.uInfo,
                                                             @"",
                                                             "0",
                                                             recid);
            },
              Constants.ROLE_SBS_ADMIN);  // Who can call this method           
        }

        /***************************************************************************
            * saveinline */
        /**
        * Save insurance carrier records
        ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord saveinline(string carriercode
                                            , string name
                                            , string ohccode
                                            , string plantypecode
                                            , string plansupportedbycybhi
                                            , string usstate
                                            , string savetype
                                            , string recid
            )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.InsuranceCarriers.save(this.dbConnApp
                                                            , this.log
                                                            , this.uInfo
                                                            , carriercode
                                                            , name
                                                            , ohccode
                                                            , plantypecode
                                                            , plansupportedbycybhi
                                                            , usstate
                                                            , ""
                                                            , "0"
                                                            , savetype
                                                            , recid
            );
            },
            Constants.ROLE_SBS_ADMIN);  // Who can call this method           
        }

    }
}
