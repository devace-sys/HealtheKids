using System.Web.Services;
using System.Web.Script.Services;
using MBA;
 
namespace Spedmon
{
  /***************************************************************************
   * PatientPromisedServicesDeliveryExceptionsSvc */
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
 
  public class PatientPromisedServicesDeliveryExceptionsSvc : MBA.WebSvc
  {    
 
    /***************************************************************************
     * deleteinline */
    /**
     * 
     ***************************************************************************/  
              
    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]
 
    public ReturnSaveRecord deleteinline (  
	    string clientid
	  , string patid	  
	  , string deliveryexceptionremovedreasonid
      , string deliveryexceptionremovednotes
	  , string recid 

	)
    {
        return (ReturnSaveRecord)
        callMethod(typeof(ReturnSaveRecord),
        delegate()
        {
 
          return Spedmon.PatientPromisedServicesDeliveryExceptions.delete(
                                              this.dbConnApp
                                            , this.log
                                            , this.uInfo                 
                                            , clientid
                                            , patid
                                            , deliveryexceptionremovedreasonid
                                            , deliveryexceptionremovednotes
                                            , @""
                                            , @"N"
                                            , recid );
        }, Constants.ROLE_MISSING_SERVICES_MANAGE);  // Who can call this method           
    
    }       
                
    /***************************************************************************
     * opflagasreviewed */
    /**
     * 
     ***************************************************************************/  
              
    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]
 
    public ReturnSaveRecord opflagasreviewedinline (  
	    string clientid
	  , string patid	  
	  , string recid 
	)
    {
        return (ReturnSaveRecord)
        callMethod(typeof(ReturnSaveRecord),
        delegate()
        {
 
          return Spedmon.PatientPromisedServicesDeliveryExceptions.opFlagAsReviewed (
                                              this.dbConnApp
                                            , this.log
                                            , this.uInfo                 
                                            , clientid
                                            , patid
                                            , @""
                                            , @"N"
                                            , recid );
        }, Constants.ROLE_MISSING_SERVICES_MANAGE);  // Who can call this method               
    }       
    
    /***************************************************************************
     * saveinline */
    /**
     * 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]
 
    public ReturnSaveRecord saveinline ( 
          string        clientid
	    , string        patid
	    , string        svctrackingclass
	    , string        spedservicecode
	    , string        orpdocstandardselectionnameid
	    , string        planstartdate
	    , string        planenddate
	    , string        spedfreqcode
	    , string        minsperfreq
	    , string        dosstart
	    , string        dosend
	    , string        numminsmissing
	    , string        deliveryexceptionaddedreasonid
	    , string        deliveryexceptionaddednotes )
    {
        return (ReturnSaveRecord)
        callMethod(typeof(ReturnSaveRecord),
        delegate()
        {
 
            return Spedmon.PatientPromisedServicesDeliveryExceptions.save(
                                                  this.dbConnApp
                                                , this.log
                                                , this.uInfo
                                                , clientid
	                                            , patid
	                                            , svctrackingclass
	                                            , spedservicecode
	                                            , orpdocstandardselectionnameid
	                                            , planstartdate
	                                            , planenddate
	                                            , spedfreqcode
	                                            , minsperfreq
	                                            , dosstart
	                                            , dosend
	                                            , numminsmissing
	                                            , deliveryexceptionaddedreasonid
	                                            , deliveryexceptionaddednotes
                                                , @""
                                                , @"N"
                                                , Constants.SAVE_TYPE_NEW.ToString()
                                                , @"");
 
 
        }, Constants.ROLE_MISSING_SERVICES_MANAGE);  // Who can call this method                    
    }
 

  }
 
}

    