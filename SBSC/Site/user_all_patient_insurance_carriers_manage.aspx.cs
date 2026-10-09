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
using System.Collections.Generic;


namespace Spedmon
{

    public class UserAllPatientInsuranceCarriersManage : WebUI
    {
        
        public UserAllPatientInsuranceCarriersManage() : base( PatientInsuranceCarriers.PAGE_ID_USER_ALL_MANAGE
                                                               ,  PatientInsuranceCarriers.PAGE_MANAGE_SEL_LABEL
                                                               , ""
                                                               , "patient-insurance.js"
                                                               , Constants.ROLE_SBS_ALL_LEA_COORD_CYBHI_COORD)
        { }
        
        public bool pcalStaff = false;

        protected void Page_Load(object sender, EventArgs e)
        {

            pcalStaff = rd.wu.usr.pcalStaff;

            var ctrlGotoPatInsImport = findControlRecu(this.Page, "gotoPatInsImport")    as MBA.LinkInternal; 


            ctrlGotoPatInsImport.url = PatientInsuranceCarriersDataImports.URL_PAGE_IMPORT;   
                
        }
    }
}