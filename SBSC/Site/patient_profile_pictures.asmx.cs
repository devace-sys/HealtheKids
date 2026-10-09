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
     * PatientProfilePicturesSvc */
    /**
     **************************************************************************/

    public class PatientProfilePicturesSvc : MBA.WebSvc
    {
        public PatientProfilePicturesSvc() : base()
        {
        }

        /***************************************************************************
         * savethenget */
        /**
         * Save or replace a patient profile picture then call the get method
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnPatientProfilePicture savethenget (
             string clientid
           , string patid
           , string filename
           , string profilepicturebase64                      
        )
        {
            return (ReturnPatientProfilePicture) callMethod(
                typeof(ReturnPatientProfilePicture),
                delegate ()
                {
                    return Spedmon.PatientProfilePictures.saveThenGet (
                         this.dbConnApp
                       , this.log
                       , this.uInfo
                       , clientid
                       , patid
                       , filename
                       , profilepicturebase64      
                       , "N"
                    );
                },
                Constants.ROLE_ALL_PCAL_AND_CLIENT
            );
        }

        /***************************************************************************
         * get */
        /**
         * Get patient profile picture data
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnPatientProfilePicture get (
            string clientid
            , string patid
            , string recid
        )
        {
            return (ReturnPatientProfilePicture)callMethod(
                typeof(ReturnPatientProfilePicture),
                delegate ()
                {
                    return Spedmon.PatientProfilePictures.get(
                        this.dbConnApp
                        , this.log
                        , this.uInfo
                        , clientid
                        , patid
                        , recid
                    );
                },
                Constants.ROLE_ALL_PCAL_AND_CLIENT
            );
        }

       
    }
}