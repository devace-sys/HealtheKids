using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * usersashx */
  /*
   ***************************************************************************/
  public class UsersRpt : WebReportDocument
  {
    public const int REPT_NUM_VIEW = 1;
        
    public UsersRpt()
    {
      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/

        this._permittedRoles = Constants.ROLE_SVC_PRAC;
       
       this.cbReportData = delegate()
       {
         return Spedmon.Users.viewTbl(dbConnUser, log, uInfo, _reportPaging, _reportPageNumber, clientid, roleid, _lastName, _firstName, _reportEditView, null);
       };
    }
  }
}