
using System;
using System.Collections.Generic;
using System.Web;
using MBA;


namespace Spedmon
{

    /***************************************************************************
     * clients.ashx */
    /*
     ***************************************************************************/

    public class ClaimServiceNameXrefAndFormDataRecordsRpt : WebReportDocument
    {



        public ClaimServiceNameXrefAndFormDataRecordsRpt()
        {
            /*-------------------------------
             * Define permitted roles 
             * Call framework method
             * _reportEditView;
             * _reportPageView;
             * _reportPageNumber;
             *------------------------------*/
           
            this._permittedRoles = Constants.ROLE_CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_ADMIN;
            this.cbReportData = delegate()
            {



                return Spedmon.ClaimServiceNameXrefAndFormDataRecords.viewTbl(
                    dbConnApp, log, uInfo, _reportPaging, _reportPageNumber 

                                        , ""  // canEdit 

                                        , "1"  //this.active
                                             // note: the existing restview isn't passing in active=1.
                                             // I've never understood why we so often pass in active=1
                                             // from requestData instead of securing it in middleware

                                        , this.clientid

                                        , MBA.HttpApplication.getParameter(
                                        "plantype"
                                        )  // this.plantype

                                        , this.groupid

                                        , MBA.HttpApplication.getParameter(
                                        "nameid"
                                        )  // this.nameid

                                        , MBA.HttpApplication.getParameter(
                                        "groupserviceclassnameid"
                                        ) // this.groupserviceclassnameid

                                        , MBA.HttpApplication.getParameter(
                                        "term"
                                        ) // this.term

                                        , this.svctypeid

                                        , MBA.HttpApplication.getParameter(
                                        "excludeClientBlank"
                                        )


                    );
            };
        }
    }
}

