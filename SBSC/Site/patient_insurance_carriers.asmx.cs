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
   * PatientInsuranceCarriersSvc */
  /**
   * 
   *************************************************************************/

  public class PatientInsuranceCarriersSvc : MBA.WebSvc
  {


    public PatientInsuranceCarriersSvc() : base() { }
	
   
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
        , string patid
        , string insurancecarrierid
        , string beneficiarylastname
        , string beneficiaryfirstname
        , string beneficiaryid

        , string policyholdername
        , string policygroupid
        , string expiredorinvalid
        , string cybhiregisteredwithtpa

        , string primarycarrier

        , string savetype
        , string recid  )
    {
        return (ReturnSaveRecord) callMethod(
            typeof(ReturnSaveRecord),
            delegate ()
            {
            return Spedmon.PatientInsuranceCarriers.save (

                this.dbConnApp
              , this.log
              , this.uInfo
              , clientid
              , patid
              , insurancecarrierid
              , beneficiarylastname
              , beneficiaryfirstname
              , beneficiaryid

              , policyholdername
              , policygroupid
              , expiredorinvalid
              , cybhiregisteredwithtpa

              , primarycarrier

              , ""
              , "N"
              , savetype
              , recid);
            },
            Constants.ROLE_ALL_PCAL_AND_CLIENT);  // TODO ???
    }

      /***************************************************************************
       * deleteinline */
      /**
       *        
       ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord deleteinline(
              string clientid
            , string recid)
        {
            return (ReturnSaveRecord) callMethod(
                typeof(ReturnSaveRecord),
                delegate ()
                {
                    return Spedmon.PatientInsuranceCarriers.delete (
                    this.dbConnApp
                  , this.log
                  , this.uInfo
                  , clientid
                  , ""   
                  , "0"  
                  , recid );
                },
                Constants.ROLE_SBS_ALL);  
        }

        /***************************************************************************
         * deletemultiinline */
        /**
         *        
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord deletemultiinline(
              string clientid
            , string recids )
        {
            return (ReturnSaveRecord) callMethod(
                typeof(ReturnSaveRecord),
                delegate ()
                {
                    return Spedmon.PatientInsuranceCarriers.deleteMulti (
                    this.dbConnApp
                  , this.log
                  , this.uInfo
                  , clientid
                  , ""   
                  , "0"  
                  , recids );
                },
                Constants.ROLE_SBS_ALL_LEA_COORD);  
        }
  }
}
