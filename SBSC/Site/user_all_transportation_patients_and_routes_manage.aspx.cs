using System;
using MBA;

namespace Spedmon
{
    public class userAllTransportationPatientsAndRoutesManage : WebUI
    {
        public userAllTransportationPatientsAndRoutesManage() : base("user_all_transportation_patients_and_routes_manage"
                                            , TransportationMgmtRecords.SEL_LABEL
                                            , "user_all_transportation_patients_and_routes_manage.css"
                                            , ""
                                            , Constants.ROLE_ALL_PCAL_AND_CLIENT)
        { }

        public string startDateDefault = "";
        public string addNewPlaceURL = "";
        public string editPlacesURL = "";
        public string addNewSiteURL = "";
        public TransportationMgmtRecord tmr = new TransportationMgmtRecord();

        protected void Page_Load(object sender, EventArgs e)
        {
            var ctrlClientID    = findControlRecu(this.Page, "selectClient") as MBA.DataEntryRowSelectClient;
            var ctrlTransmgmtid = findControlRecu(this.Page, "transmgmtid")  as MBA.HiddenInput;

            /* preselect clientid if passed */

            if (this.rd.loggedIn)
            {
                startDateDefault = Util.generateStartDateThisMondayOrNext(null).ToShortDateString();

                string clientIDStr = Spedmon.Validate.reqClientID(uInfo, MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID)).ToString();

                if (!String.IsNullOrEmpty(clientIDStr))
                {
                    ctrlClientID.selectValue = clientIDStr;
                    ctrlClientID.entryInitiallyHidden = true;
                    ctrlClientID.entryAllowed = false;
                }

                TransportationMgmtRecords.autoCreateOrUpdate(dbConnApp
                                                         , log
                                                         , uInfo
                                                         , clientIDStr);

                tmr = TransportationMgmtRecords.loadCurrent(dbConnApp
                                                              , log
                                                              , uInfo
                                                              , clientIDStr);

                ctrlTransmgmtid.value = tmr.id.ToString();

                addNewPlaceURL = MBA.HttpApplication.createLink(PatientPlaces.URL_USER_ALL_SAVE
                                                                , true
                                                                , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                                );
                editPlacesURL = MBA.HttpApplication.createLink(PatientPlaces.URL_USER_ALL_EDIT
                                                                , true
                                                                , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                                );
                addNewSiteURL = MBA.HttpApplication.createLink(Sites.URL_SAVE
                                                                , true
                                                                , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                                );
            }

        }
    }
}