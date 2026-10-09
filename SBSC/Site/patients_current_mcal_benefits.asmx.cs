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
    /***************************************************************************
     * PatientsCurrentMcalBenefitsSvc */
    /*
     * Web services end point 
     *
     * Unless indicated, each of these methdos are for sbs users only
     *
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

   public class PatientsCurrentMcalBenefitsSvc : MBA.WebSvc
   {
     public PatientsCurrentMcalBenefitsSvc() : base() { }

    /***************************************************************************
     * updatepatientparentmcalconsent */
    /**
     ***************************************************************************/
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord updateoutreachnotes (
        string clientid
      , string notes 
	  , string recid
	  )
    {
      return (ReturnSaveRecord)
      callMethod (  typeof(ReturnSaveRecord)
                 , delegate () {
        return Spedmon.PatientsCurrentMcalBenefits.updateOutreachNotes (
            this.dbConnApp
          , this.log
          , this.uInfo
          , clientid
          , recid
          , notes
        );
      }
      , Constants.ROLE_SBS_ALL_LEA_COORD);  // Who can call this method           
    }

      
    }
}
