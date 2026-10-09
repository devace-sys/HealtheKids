using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

namespace Spedmon
{


  public class RptSBSTattle : WebUI
  {
      
      public RptSBSTattle () : base( "rpt_sbs_tattletale_report"
                                        , Practitioners.SEL_LABEL_RPT_TATTLETALE                                                                              
                                                                , ""
                                        , ""
                                        ,Constants.ROLE_SVC_PRAC
          ) { }

        protected void Page_Load(object sender, EventArgs e) //not sure why this needs to be here
        {
        }
  }
}