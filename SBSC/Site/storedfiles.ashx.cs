using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * StoredFilesRpt
   */
  /*
   ***************************************************************************/

  public class StoredFilesRpt : WebReportDocument
  {    
    
    public const int REPT_NUM_VIEW = 1;

    public StoredFilesRpt()
    {

      /*-------------------------------
       * Define permitted roles 
       * Refine access
       * Call framework method based
       * on report number
       *------------------------------*/

      this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;

      this.cbReportData = delegate()
      {
              
        if (this._reportNumber == REPT_NUM_VIEW)
        {                            
          return StoredFiles.viewTbl (dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, null, active, clientid, pracid, patid, referencedentityid, fileclass, filedaterange, filenamespace, filesource);
		}
        else
        {
          return null;
        }
      };
    }
  }
}