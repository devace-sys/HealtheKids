using System;

namespace Spedmon
{
    public class UserAllServicesByPracRpt : WebUI
    {

        public UserAllServicesByPracRpt() : base( ServicesByPracRpt.BODY_ID
                                                , ServicesByPracRpt.SEL_LABEL
                                                , ""
                                                , ""
                                                , Constants.ROLE_PRAC_DIR_SUP_ADMINS)
        { }
        public bool rptGrpIsPreloaded = false;
        protected void Page_Load(object sender, EventArgs e)
        {

            // set up radio box for report type radiobox
            var ctrlCrcsTabID  = findControlRecu(this.Page, "reptnumber") as MBA.RadioBox;
            var ctrlEndDate    = findControlRecu(this.Page, "enddate")    as MBA.DataEntryBoxDate;

            ctrlEndDate.value = DateTime.Now;

            ctrlCrcsTabID.value = ((int)ServicesByPracRptTypes.BY_NUM_SERVICES).ToString(); /* Default */                        
            ctrlCrcsTabID.AddSelection(@"Minutes",                          ((int)ServicesByPracRptTypes.BY_MINS).ToString());
            ctrlCrcsTabID.AddSelection(@"Number Of Services",               ((int)ServicesByPracRptTypes.BY_NUM_SERVICES).ToString());
            ctrlCrcsTabID.AddSelection(@"Summary (Including Missing Svcs)", ((int)ServicesByPracRptTypes.TATTLE).ToString());
            ctrlCrcsTabID.AddSelection (ServicesByPracRpt.SEL_LABEL_RPT_EFFICIENCY, ((int)ServicesByPracRptTypes.EFFICIENCY).ToString());

            // if not PCal staff, preload prac group
            if (uInfo.pcalStaff == false && uInfo.userPracID != 0)
            {
                rptGrpIsPreloaded = true;

                var ctrlRptGrp     = findControlRecu(this.Page, "rptgroupid") as MBA.ComboBox;
                var pr = Practitioners.load(dbConnApp, log, uInfo, uInfo.userPracIDStr);

                ctrlRptGrp.value = pr.groupIDRept.ToString();
                ctrlRptGrp.hidden = true;
                ctrlRptGrp.cssClass = "d-none";
            }
        }

    }
}
