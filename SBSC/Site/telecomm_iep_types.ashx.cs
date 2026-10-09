using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Spedmon
{
    /***************************************************************************
    * telecommIEPTypesViw */
    /*
     ***************************************************************************/
    public class telecommIEPTypesViw : WebReportDocument
    {
        public const int REPT_NUM_VIEW = 1;
        public telecommIEPTypesViw()
        {
          /*-------------------------------
           * Define permitted roles 
           * Call framework method
           * _reportEditView;
           * _reportPageView;
           * _reportPageNumber;
           *------------------------------*/

            this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
            this.cbReportData = delegate ()
            {
                string term; // the search term
                if (!String.IsNullOrEmpty(name))
                {
                    Spedmon.TeleCommIEPType telecommIEPTypeObj = Spedmon.TeleCommIEPTypes.load(dbConnApp, log, uInfo, name);
                    term = telecommIEPTypeObj.name;
                }
                else
                {
                    term = "";
                }

                return Spedmon.TeleCommIEPTypes.viewTbl(dbConnApp, log, uInfo, _reportPaging, _reportPageNumber, _reportEditView, active, term);
            };
        }
    }
}