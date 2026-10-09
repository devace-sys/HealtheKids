using System.Web.Services;
using System.Web.Script.Services;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * ClientComplianceItemsSvc */
  /*
   * Web services end point for Client Compliance Tasks methods
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
  public class ClientComplianceItemsSvc : MBA.WebSvc
  {
    public ClientComplianceItemsSvc() : base() { }             

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    
    public ReturnEntity loadN( string taskid
                             , string recid
    )
    {
      return (ReturnEntity)
      callMethod(typeof(ReturnEntity), 
      delegate()
      {
        ReturnEntity re = new ReturnEntity();
          re.entity = Spedmon.ClientComplianceItems.loadN(
              this.dbConnApp
            , this.log
            , this.uInfo
            , 0
            , "1"
            , taskid
            , recid
          );

          return re;
      },
      Constants.ROLE_SBS_ALL_LEA_COORD_AND_ASSIST ); // Who can call this method
                         //  TODO: test further (later) and determine if this webmethod is used anywhere
                         //        in the frontend functionality.  Comment whether this can be safely removed.
                         //        Document the intended purpose of this method.=, in terms of the controls on the page
                         //        and the use case scenario.
    }

  }
}
