using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * ServiceJournalsServiceDescriptionsViw */
  /*
   ***************************************************************************/
   
  public class ServiceJournalsServiceDescriptionsViw : WebReportDocument
  {
    public const int REPT_NUM_VIEW = 1;
    
    public ServiceJournalsServiceDescriptionsViw()
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
        
        /*###########################################################################
          # If the user is a prac make sure they have access
          ###########################################################################*/    
        
        if (rd.wu.usr.roleName == Constants.ROLE_LEA_PROVIDER)
        {           
          if (!ServiceJournals.isPracSomeoneWhoCanManageSvcDescr (ref rd)) throw new MBA.Critical(Messages.ACCESS_DENIED);
        }
        
        return Spedmon.ServiceJournalsServiceDescriptions.viewTbl (dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, clientid, patid, _reportEditView, active);
      };
    }
  }
}