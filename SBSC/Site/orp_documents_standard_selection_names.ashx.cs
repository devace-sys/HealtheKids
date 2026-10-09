using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * orp_documents_standard_selection_names_viw */
  /*
   ***************************************************************************/
   
  public class orp_documents_standard_selection_names_viw : WebReportDocument
  {
    
    public orp_documents_standard_selection_names_viw()
    {
      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/

      this._permittedRoles = Spedmon.Constants.ROLE_SBS_ALL;
      
      this.cbReportData = delegate() { return 
      
        Spedmon.ORPDocumentsStandardSelectionNames.viewTbl (  dbConnApp
                                                            , log
                                                            , uInfo
                                                            , _reportPaging
                                                            , _reportPageNumber
                                                            , _reportEditView
                                                            , active
                                                            , clientid
                                                            , groupServiceClassNameID);
      };
    }
  }
}