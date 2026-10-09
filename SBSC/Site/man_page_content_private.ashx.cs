using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * man_page_content_private.ashx */
  /*
   ***************************************************************************/
   
  public class ManPageContentPrivateViw : MBA.ManPageViewContentHandler
  {
    
    public ManPageContentPrivateViw()
    {
      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/

      this._permittedRoles = Spedmon.Constants.ROLE_ALL;
      this._cbReturnManPage = delegate()
      {
        return Spedmon.ManPages.returnContentSelection ( dbConnUser, log, uInfo, recID );		
      };
    }
  }
}