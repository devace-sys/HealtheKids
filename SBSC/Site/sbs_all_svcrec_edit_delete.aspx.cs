using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MBA;

namespace Spedmon
{
  /***************************************************************************
  * ServiceRecordSelect */
  /**
  * Selects a service record
  ***************************************************************************/   

  public class SBSAllServiceRecordsEditDelete: WebUI
  {
    public SBSAllServiceRecordsEditDelete() : base("service_records_edit_delete",
                                                   ServiceRecords.SEL_LABEL_EDIT_SVCREC,
                                                   "",
                                                   "",
                                                   Constants.ROLE_SBS_ALL){}
    
    protected void Page_Load(object sender, EventArgs e)
    {    
    }

  }
}
