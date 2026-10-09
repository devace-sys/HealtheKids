using System.Web.Services;
using System.Web.Script.Services;
using MBA;
 
namespace Spedmon
{
  /***************************************************************************
   * PatientPromisedServices.asmx */
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
 
  public class PatientPromisedServicesSvc : MBA.WebSvc
  {    
 
    /***************************************************************************
     * deleteinline */
    /**
     * Deletes svc rec
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
 
          return Spedmon.PatientPromisedServices.deleteInline(
                                              this.dbConnApp
                                            , this.log
                                            , this.uInfo                                        
                                            , recid );
        }, Constants.ROLE_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC);  // Who can call this method           
    
    }       
               
    /***************************************************************************
     * viewSel */
    /**
     * 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSel viewSel (string clientid, string active, string patid, string term)
    {
      return (ReturnSel) 
      callMethod(typeof(ReturnSel), 
      delegate()
      {
        return Spedmon.PatientPromisedServices.viewSel(this.dbConnApp, this.log, this.uInfo, true, "", active, clientid, patid, term);
      },
      Constants.ROLE_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC); // Who can call this method
    } 
                    
    /***************************************************************************
     * save */
    /**
     * 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]
 
    public ReturnSaveRecord save ( string patid
                                 , string spedservicecode
                                 , string spedprovidercode
                                 , string spedfreqcode
                                 , string spedlocationcode
                                 , string startdate
                                 , string enddate
                                 , string individualdelivery
                                 , string groupdelivery
                                 , string minsperfreq
                                 , string replacementdataactive
                                 , string replacementspedservicecode
                                 , string replacementspedfreqcode
                                 , string replacementminsperfreq
                                 , string editDelReason
                                 , string validaterec
                                 , string savetype
                                 , string recid)
    {
        return (ReturnSaveRecord)
        callMethod(typeof(ReturnSaveRecord),
        delegate()
        {
 
            return Spedmon.PatientPromisedServices.save(
                                                  this.dbConnApp
                                                , this.log
                                                , this.uInfo
                                                , patid
                                                , spedservicecode
                                                , spedprovidercode
                                                , spedfreqcode
                                                , spedlocationcode
                                                , startdate
                                                , enddate
                                                , individualdelivery
                                                , groupdelivery
                                                , minsperfreq
                                                , replacementdataactive
                                                , replacementspedservicecode
                                                , replacementspedfreqcode
                                                , replacementminsperfreq                             
                                                , editDelReason
                                                , validaterec
                                                , savetype
                                                , recid);
 
 
        }, Constants.ROLE_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC);  // Who can call this method                    
    }
 

    /***************************************************************************
     * getnonpromisedspedservicesdelivery */
    /**
     * 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]
 
    public ReturnObjects getnonpromisedspedservicesdelivery (  string clientid
                                                             , string patid
                                                             , string startdate
                                                             , string enddate )
    {
        return (ReturnObjects)
        callMethod(typeof(ReturnObjects),
        delegate()
        {
 
            return Spedmon.PatientPromisedServices.getNonPromisedSpEdServicesDelivery (
                                                  this.dbConnApp
                                                , this.log
                                                , this.uInfo
                                                , clientid
                                                , patid
                                                , startdate
                                                , enddate);
                                               
 
        }, Constants.ROLE_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC);  // Who can call this method                    
    }

  }
 
}

    