using System;
using MBA;

namespace Spedmon
{
    public class userAllInputBatchesManage : WebUI
    {
        public userAllInputBatchesManage() : base(InputBatchesCommon.MENU_ID_MANAGE
                                            , InputBatchesCommon.SEL_LABEL_MANAGE
                                            , ""
                                            , ""
                                            , Constants.ROLE_SBS_ALL)
        { }
        protected void Page_Load(object sender, EventArgs e)
        {
          /* input_batches_manage.css|input_batches_rest_view_manage.css|user_all_batches_in_process_manage.css*/
        
            var ctrlShowJustBatchesInProcess = findControlRecu(this.Page,"showjustbatchesinprocess") as MBA.SelectYesIsTrueNoIsBlank;
            ctrlShowJustBatchesInProcess.setValue(true);

        }
    }
}