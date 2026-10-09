using System.Web.Services;
using System.Web.Script.Services;
using MBA;



namespace Spedmon
{

  /***************************************************************************
   * ClientComplianceClientItemsSvc */
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

  public class ClientComplianceClientItemsSvc : MBA.WebSvc
  {

    public ClientComplianceClientItemsSvc() : base() { }             

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSaveRecord save( string clientid
                                , string clientcomplianceitemid
                                , string notes
                                , string iscomplete

                                , string duedate
                                , string datetoshowondashboard

                                , string editduedateallclients
                                , string editdashboarddateallclients

                                , string taskname

                                , string datecompleted
                                , string savetype 
                                , string recid
    )
    {
      return (ReturnSaveRecord)
      callMethod(typeof(ReturnSaveRecord), 
      delegate()
      {
        return Spedmon.ClientComplianceClientItems.save(this.dbConnApp, this.log, this.uInfo, clientid, clientcomplianceitemid, notes, iscomplete,
        duedate ,

        datetoshowondashboard       ,
        editduedateallclients       ,
        editdashboarddateallclients ,

        taskname ,
         datecompleted,
         "", "0", savetype, recid); 
      },
      Constants.ROLE_SBS_ALL_LEA_COORD_AND_ASSIST); // Who can call this method    
    }



    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord deleteinline( string deleteforallclients, string recid)
    {
        return (ReturnSaveRecord)

        callMethod(
             typeof(ReturnSaveRecord)
           , delegate ()
            {

              return Spedmon.ClientComplianceClientItems.delete(dbConnApp
                                    , log
                                    , uInfo
                                    , deleteforallclients
                                    , recid);
           }
           , Constants.ROLE_SBS_ALL ); // Who can call this method  
        }

  }


}
