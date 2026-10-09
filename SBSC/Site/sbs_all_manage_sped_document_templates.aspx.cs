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
using System.Text;
using MBA;
using System.Collections.Generic;

namespace Spedmon
{

    public class SBSAllManageSpedDocumentTemplates : WebUI
    {
        public SBSAllManageSpedDocumentTemplates() : base(@"sbs_all_manage_sped_document_templates"
                                                         , SpEdDocumentTemplates.SEL_LABEL_MANAGE
                                                         , @""
                                                         , @""
                                                         , Constants.ROLE_SBS_ALL)
        {
        }

        public string clientNvpString      = "";
		
        protected void Page_Load(object sender, EventArgs e)
        {
           /* Get list of clients that we will use to pass to field definition for selecting client */

           var clients = Clients.viewList(dbConnApp, log, uInfo);
           
           var sb1 = new StringBuilder();
           sb1.Append(@"[{name:'',value:''}");
           foreach(var client in clients)
           {
             sb1.AppendFormat(@",{{name:'{0}',value:'{1}'}}", client.name, client.id); 
           }
           sb1.Append(@"]");
           clientNvpString = sb1.ToString();

         }
    }
}