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
   * sbs_all_orp_doc_svc_rec_asc */
  /**
   * 
   ***************************************************************************/   

  public class sbs_all_orp_doc_svc_rec_asc : WebUI
  {

    public int saveType = 0;    
    
    public sbs_all_orp_doc_svc_rec_asc() : base ( 
        @"sbs_all_orp_doc_svc_rec_asc"
      , WebUI.CreatePageSubTitle(   @"Service Records"
                                  , @"Associate ORP Documents")
      , ""
      , ""
      , Constants.ROLE_SBS_ALL
    ){}
    
    public    string  recsHTML  { get { return _recsHtml; } }
    protected string  _recsHtml = @"";
    
    protected void Page_Load(object sender, EventArgs e)
    {
      ReturnInfoTable rd = ServiceRecords.viewInfoTblNoORPDocAscPCALOnly(dbConnApp,log,uInfo);      
     _recsHtml = ReturnInfoTable.ToHTMLTableString(ref rd);    
              
    }
                     
  }
}
