using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * ClientDomainsViw */
  /*
   ***************************************************************************/

  public class ClientDomainsViw : WebReportDocument
  {    
    public const int REPT_NUM_VIEW = 1;
	
    public ClientDomainsViw()
    {


       /*-------------------------------
        * Define permitted roles 
        * Refine access
        * Call framework method based
        * on report number
        *------------------------------*/


      this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL;
      this.cbReportData = delegate()
      {

          return Spedmon.ClientDomains.viewTbl( dbConnApp
                                               , log
                                               , uInfo
                                               , _reportPaging
                                               , _reportPageNumber
                                               , _reportEditView
                                               , _active
                                               , this.clientid );

      };
    }
  }
}