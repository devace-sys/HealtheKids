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
  /***************************************************************************
   * PatientAccommodations.asmx */
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
 
  public class PatientAccommodationsSvc : MBA.WebSvc
  {    
 
    /***************************************************************************
     * deleteinline */
    /**
     * Deletes accommodation rec
     * 
     ***************************************************************************/  
              
    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]
 
    public ReturnSaveRecord deleteinline (  string recid )
    {
        return (ReturnSaveRecord)
        callMethod(typeof(ReturnSaveRecord),
        delegate()
        {
 
          return Spedmon.PatientAccommodations.deleteInline(
                                              this.dbConnApp
                                            , this.log
                                            , this.uInfo                                        
                                            , recid );
        }, Constants.ROLE_ALL);  // Who can call this method           
    
    }       
               
    /***************************************************************************
     * viewSel */
    /**
     * 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSel viewSel (string clientid, string active, string patid, string recordtype, string term)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel), 
      delegate()
      {
        return Spedmon.PatientAccommodations.viewSel(this.dbConnApp, this.log, this.uInfo, true, "", active, clientid, patid, recordtype, term);
      },
      Constants.ROLE_ALL); // Who can call this method
    } 
                    
    /***************************************************************************
     * get */
    /**
     * 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnObjects get (string recid)
    {
      return (ReturnObjects) 
      callMethod(typeof(ReturnObjects), 
      delegate()
      {
        return Spedmon.PatientAccommodations.get(this.dbConnApp, this.log, this.uInfo, recid);
      },
      Constants.ROLE_ALL); // Who can call this method
    } 
                    
    /***************************************************************************
     * save */
    /**
     * 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]
 
    public ReturnSaveRecord save ( string patid
                                 , string recordtype
                                 , string category
                                 , string accommodation
                                 , string details
                                 , string appliesto
                                 , string startdate
                                 , string enddate
                                 , string frequency
                                 , string duration
                                 , string location
                                 , string locationother
                                 , string linkedareaofneed
                                 , string alignedgoal
                                 , string alignedgoalnames
                                 , string staffresponsible
                                 , string status
                                 , string discontinuereason
                                 , string editDelReason
                                 , string validaterec
                                 , string savetype
                                 , string recid)
    {
        return (ReturnSaveRecord)
        callMethod(typeof(ReturnSaveRecord),
        delegate()
        {
 
            return Spedmon.PatientAccommodations.save(
                                                  this.dbConnApp
                                                , this.log
                                                , this.uInfo
                                                , patid
                                                , recordtype
                                                , category
                                                , ""
                                                , accommodation
                                                , details
                                                , appliesto
                                                , ""
                                                , startdate
                                                , enddate
                                                , frequency
                                                , ""
                                                , duration
                                                , location
                                                , ""
                                                , locationother
                                                , linkedareaofneed
                                                , ""
                                                , alignedgoal
                                                , alignedgoalnames
                                                , staffresponsible
                                                , ""
                                                , status
                                                , discontinuereason
                                                , editDelReason
                                                , validaterec
                                                , savetype
                                                , recid);
 
 
        }, Constants.ROLE_ALL);  // Who can call this method                    
    }
 
  }
 
}