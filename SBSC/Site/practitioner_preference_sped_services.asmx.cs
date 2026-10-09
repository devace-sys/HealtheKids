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


using Spedmon;



namespace Spedmon
{


  [WebService(Namespace = "http://spedcare.com/")]
  [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
  [ScriptService]
  
  public class PractitionerPreferenceSpedServicesWebsvc : MBA.WebSvc
  {
    /***************************************************************************
     * delete */
    /**
     * "delete" a record
     * 
     * @param  validaterec   Required, True=Yes, False=No
     * @param  editDelReason Reason for delete
     * @param  recid         Record id to delete
     ***************************************************************************/


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord delete(

          //  string editDelReason
          //, string validateRec

            string clientid
          , string pracid

                // TODO: figure out if we need these params submitted w/ the AJAX, instead of found within the uInfo object;
                //       figure out how to submit additional params in the JSON with the .delete() AJAX call
                   // DONE

          , string recid)
        {
      return (ReturnSaveRecord)
      callMethod(typeof(ReturnSaveRecord),
      delegate()
      {
          
        return Spedmon.PractitionerPreferenceSpedServices.delete(

            this.dbConnApp
          , this.log
          , this.uInfo
          , "" //  editDelReason
          , "0" // validateRec

          , clientid
          , pracid
          , recid);
      }
       , Constants.ROLE_ALL);  // TODO: tighten  
    }


    /***************************************************************************
     * save */
    /**
     * Save man pages
     ***************************************************************************/    

    /* Eight code changes/bugfixes implemented:



       - allow clientID and pracID input via widgets or hidden fields, not from uInfo     -- DONE
       - data selection listener on clientID and pracID widgets                           -- DONE
       - remove dynamically-created DIV content from JS; place hidden HTML in page code   -- DONE

       - remove timeOut callback                                                          -- DONE
       - create a self-executing function in the JS file                                  -- DONE
       - create an init function that accepts opts_in;                                    -- DONE

       - require pracID and clientID as params on save - NOT extracted from uInfo                        -- DONE
       - require and submit clientID and pracID as params on delete; validate permissions server side    -- DONE


     */


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveOrReplaceRecord
            save(      string clientid
                     , string pracid
                   // , string spedSvcID
                      , string codeValue

                    //, string editDelReason
                    //, string validateRec
                    //, string saveType
                    //, string recID
                    )
        {

      return (ReturnSaveOrReplaceRecord) 
     
      callMethod(
        typeof(ReturnSaveOrReplaceRecord)
      , delegate()
      {

          return Spedmon.PractitionerPreferenceSpedServices.save(
                      this.dbConnApp
                    , this.log
                    , this.uInfo

                    , clientid
                    , pracid

                    , codeValue //spedSvcID

                    //, "" // string editDelReason
                    //, "0" //validateRec
                    //, "1" //saveType
                    //, string recID
                    );
      }
      , Constants.ROLE_ALL);  // TODO: tighten  

    }


  }

}
