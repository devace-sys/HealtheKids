using System.Web.Services;
using System.Web.Script.Services;
using MBA;
 
namespace Spedmon
{
  /***************************************************************************
   * ClientSchoolSessionAcademicYearsSvc.asmx */
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
 
  public class ClientSchoolSessionAcademicYearsSvc : MBA.WebSvc
  {    
 
    /***************************************************************************
     * deleteinline */
    /**
     * Deletes svc rec
     * 
     ***************************************************************************/  
              
    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]
 
    public ReturnSaveRecord deleteinline (  string clientid, string recid )
    {
        return (ReturnSaveRecord)
        callMethod(typeof(ReturnSaveRecord),
        delegate()
        {
 
          return Spedmon.ClientSchoolSessionAcademicYears.deleteInline (
                                              this.dbConnApp
                                            , this.log
                                            , this.uInfo     
                                            , clientid
                                            , recid );
        }, Constants.ROLE_SCHOOL_SESSIONS_ACADEMIC_YEARS_MANAGE);  // Who can call this method           
    
    }       
 
    /***************************************************************************
     * saveinline */
    /**
     * 
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod (ResponseFormat = ResponseFormat.Json)]
 
    public ReturnSaveRecord saveinline (  string clientid
                                        , string companyfiscalyearid
                                        , string name
                                        , string startdate
                                        , string enddate
                                        , string savetype
                                        , string recid)
    {
        return (ReturnSaveRecord)
        callMethod(typeof(ReturnSaveRecord),
        delegate()
        {
 
            return Spedmon.ClientSchoolSessionAcademicYears.saveInline (
                                                  this.dbConnApp
                                                , this.log
                                                , this.uInfo
                                                , clientid
                                                , companyfiscalyearid
                                                , name
                                                , startdate
                                                , enddate
                                                , savetype
                                                , recid);
 
 
        }, Constants.ROLE_SCHOOL_SESSIONS_ACADEMIC_YEARS_MANAGE);  // Who can call this method                    
    }
 
    /***************************************************************************
    * viewSel */
    /**
    * 
    ***************************************************************************/
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnSel viewSel ( string clientid, string term )
    {
      return (ReturnSel)
      callMethod(typeof(ReturnSel), 
      delegate()
      {
        return Spedmon.ClientSchoolSessionAcademicYears.viewSel(this.dbConnApp, this.log, this.uInfo, false, "", clientid, term); 
      },
      Constants.ROLE_SCHOOL_SESSIONS_ACADEMIC_YEARS_MANAGE); // Who can call this method    
    }
  
  }
}
