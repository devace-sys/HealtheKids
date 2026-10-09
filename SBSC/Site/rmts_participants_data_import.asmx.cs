using System.Web.Services;
using System.Web.Script.Services;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * RmtsParticipantsDataImportSvc */
    /*
     * Unless indicated, each of these methods require that the caller is 
     * logged in.
     * 
     * Each end point method provides a wrapper for a coresponding framework
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
    public class RmtsParticipantsDataImportSvc : MBA.WebSvc
    {
        public RmtsParticipantsDataImportSvc() : base() { }


        /***************************************************************************
         * importdata */
        /**
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecordWithJSONData importdata(
             string clientid
           , string fyquarterid
           , string datatoimportjson
           , string validaterec)
        {
            return (ReturnSaveRecordWithJSONData)

            callMethod(typeof(ReturnSaveRecordWithJSONData),
            delegate ()
            {
                return Spedmon.StructuredDataImportFilesRmtsParticipantsData.importData(
              this.dbConnApp
            , this.log
            , this.uInfo
            , clientid
            , fyquarterid
            , datatoimportjson
            , validaterec
           );
            },
            Constants.ROLE_SBS_ALL_LEA_COORD);  // Who can call this method           
        }

    }
}
