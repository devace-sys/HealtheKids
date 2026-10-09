using MBA;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;

namespace Spedmon
{
    [WebService(Namespace = "http://spedcare.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]
    public class PractionerPatientReferalOptionsSvc : MBA.WebSvc
    {

        public PractionerPatientReferalOptionsSvc() : base() { }

        /***************************************************************************
           * save */
        /**
        * Save practitioner patient referal options
        ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveOrReplaceRecord save(string clientid
                                            , string useridforallroutinenotifications1
                                            , string useridforallroutinenotifications2
                                            , string useridforallroutinenotifications3
                                            , string useridforallurgentnotifications1
                                            , string useridforallurgentnotifications2
                                            , string useridforallurgentnotifications3
                                            , string useridforallcrisisnotifications1
                                            , string useridforallcrisisnotifications2
                                            , string useridforallcrisisnotifications3
                                            , string englishYesMessageTemplate
                                            , string spanishYesMessageTemplate
                                            , string englishNoMessageTemplate
                                            , string spanishNoMessageTemplate
                                            , string savetype
                                            )
        {
            return (ReturnSaveOrReplaceRecord)

            callMethod(typeof(ReturnSaveOrReplaceRecord),
            delegate ()
            {
                return Spedmon.PractionerPatientReferalOptions.save(this.dbConnApp
                                                            , this.log
                                                            , this.uInfo
                                                            , clientid
                                                            , useridforallroutinenotifications1
                                                            , useridforallroutinenotifications2
                                                            , useridforallroutinenotifications3
                                                            , useridforallurgentnotifications1
                                                            , useridforallurgentnotifications2
                                                            , useridforallurgentnotifications3
                                                            , useridforallcrisisnotifications1
                                                            , useridforallcrisisnotifications2
                                                            , useridforallcrisisnotifications3
                                                            , englishYesMessageTemplate
                                                            , spanishYesMessageTemplate
                                                            , englishNoMessageTemplate
                                                            , spanishNoMessageTemplate
                                                            , "1"
                                                            , ""
                                                            , "0"
                                                            , savetype
            );
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

        /***************************************************************************
         * loadreferaloptions */
        /**
         * 
         * Load practitioner patient referal options entity
         **************************************************************************/

        /* [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnEntity loadreferaloptions(string clientid)
        {
            return (ReturnEntity)
              callMethod(typeof(ReturnEntity),
              delegate ()
              {
                  return Spedmon.PractionerPatientReferalOptions.get(dbConnApp, log, uInfo, clientid);
              }, Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
        } */
    }
}
