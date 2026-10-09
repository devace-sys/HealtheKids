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
    public class PatientCareNotesSvc : MBA.WebSvc
    {

        public PatientCareNotesSvc() : base() { }

        /***************************************************************************
           * savenotes */
        /**
        * Save patient notes
        ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveOrReplaceRecord savenotes(string clientid
                                            , string groupserviceclassnameid
                                            , string note
                                            , string patid
                                            , string savetype
                                            )
        {
            return (ReturnSaveOrReplaceRecord)

            callMethod(typeof(ReturnSaveOrReplaceRecord),
            delegate ()
            {
                return Spedmon.PatientCareNotes.saveNotes(this.dbConnApp
                                                            , this.log
                                                            , this.uInfo
                                                            , clientid
                                                            , groupserviceclassnameid
                                                            , patid
                                                            , note
                                                            , "1"
                                                            , ""
                                                            , "0"
                                                            , savetype
            );
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

        /***************************************************************************
         * loadnotes */
        /**
         * 
         * Load patient notes entity
         **************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnEntity loadnotes(      string clientid
                                            , string groupserviceclassnameid
                                            , string patid)
        {
            return (ReturnEntity)
              callMethod(typeof(ReturnEntity),
              delegate ()
              {
                  return Spedmon.PatientCareNotes.get(dbConnApp, log, uInfo, clientid, groupserviceclassnameid, patid);
              }, Constants.ROLE_ALL_PCAL_AND_CLIENT); // Who can call this method
        }

        /***************************************************************************
           * loadnotes */
        /**
        * Load patient notes
        ***************************************************************************/

        /*[WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSel loadnotes(string clientid
                                            , string groupserviceclassnameid
                                            , string patid
                                            )
        {
            return (ReturnSel)

            callMethod(typeof(ReturnSel),
            delegate ()
            {
                return Spedmon.PatientCareNotes.viewSel(this.dbConnApp
                                                            , this.log
                                                            , this.uInfo
                                                            , clientid
                                                            , groupserviceclassnameid
                                                            , patid
            );
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }*/
    }
}
