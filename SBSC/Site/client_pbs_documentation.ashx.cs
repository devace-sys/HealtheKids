using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * ClientPBSDocumentationViw */
  /*
   ***************************************************************************/
   
  public class ClientPBSDocumentationViw : WebReportDocument
  {
    
    public ClientPBSDocumentationViw()
    {
      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/

      this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
      this.cbReportData = delegate()
      {        
        return Spedmon.ClientPBSDocumentation.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, groupServiceClassNameID, _reportEditView, active);
      };
    }
  }
}