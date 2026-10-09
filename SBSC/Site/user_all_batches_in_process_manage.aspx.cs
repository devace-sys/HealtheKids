using System;
using MBA;

namespace Spedmon
{
    public class userAllBatchesInProcessManage : WebUI
    {
        public int ParmClientID { get; set; }
        public userAllBatchesInProcessManage() : base(InputBatchesCommon.MENU_ID_MANAGE
                                            , Clients.SEL_LABEL_RPT_BATCHES_IN_PROCESS
                                            , "input_batches_rest_view_manage.css|user_all_batches_in_process_manage.css"
                                            , ""
                                            , Constants.ROLE_SBS_ALL)
        { }
        protected void Page_Load(object sender, EventArgs e)
        {
            var ctrlClientid = findControlRecu(this.Page, "clientid") as MBA.HiddenInput;
            var ctrlBatchstatuscode = findControlRecu(this.Page, "batch_status_code") as MBA.HiddenInput;
            var ctrlBatchid = findControlRecu(this.Page, "batchid") as MBA.HiddenInput;
            var ctrlWorktypeid = findControlRecu(this.Page, "worktypeid") as MBA.HiddenInput;
            var ctrlRecuserid = findControlRecu(this.Page, "recuserid") as MBA.HiddenInput;

            ctrlClientid.value = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
            ctrlBatchstatuscode.value = MBA.HttpApplication.getParameter(Constants.PARM_BATCH_STATUS_CODE);
            ctrlBatchid.value = MBA.HttpApplication.getParameter(Constants.PARM_BATCH_ID);
            ctrlWorktypeid.value = MBA.HttpApplication.getParameter("worktypeid");
            ctrlRecuserid.value = MBA.HttpApplication.getParameter("recuserid");
        }
    }
}