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

    public class SBSAllManageServiceNameFormData : WebUI
    {

        public SBSAllManageServiceNameFormData() : base(@"sbs_all_manage_service_name_form_data"
                                                         , ClaimServiceNameXrefAndFormDataRecords.SEL_LABEL_MANAGE  //
                                                         , @"sbs_all_manage_service_name_form_data.css"             //

                                                         ,  @"sbs_all_manage_service_name_form_data.js"


                                                         , Constants.ROLE_ANNOUNCEMENT_ADMIN)   // NOTE: this ROLE_ is pre_existing in code, but it seems like maybe it's not the most appropriate selection


        {
        }



        public string clientNvpString      = "";
        public string spEdSvcCodeNvpString = "";

        protected void Page_Load(object sender, EventArgs e)
        {


          /* Set default filter values */

          var ctrlSearchTerm       = findControlRecu( this.Page, @"term")        as MBA.DataEntryBoxSearch;
          var ctrlPlanTypeID       = findControlRecu (this.Page, @"plantype")    as MBA.SelectPlanType;
          var ctrlSvcTypeID        = findControlRecu (this.Page, @"svctypeid")   as MBA.SelectServiceType;

           
          ctrlSearchTerm.value = "";
          ctrlPlanTypeID.value = "";
          ctrlSvcTypeID.value  = "";

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

           /* Get list of CALPAD code names and values */
           
           var spedSvcs = SpEdServices.viewList(dbConnApp,log,uInfo);
           var sb2 = new StringBuilder();
           sb2.Append(@"[{name:'None',value:'-1'}");
           foreach(var spEdSvc in spedSvcs)
           {
             sb2.AppendFormat(@",{{name:'{0}',value:'{1}'}}", spEdSvc.name, spEdSvc.id); 
           }
           sb2.Append(@"]");
           spEdSvcCodeNvpString = sb2.ToString();

         }
    }


}