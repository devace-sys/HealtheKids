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
   * CaseloadEdit */
  /**
   * Edits a given caseload
   ***************************************************************************/   

  public class ClientAllCaseloadEdit : WebUI
  {
   
    public ClientAllCaseloadEdit() : base("caseload-edit",WebUI.CreatePageSubTitle(CaseLoads.SEL_LABEL, CaseLoads.SEL_LABEL_EDIT),"","",Constants.ROLE_CLIENT_ALL){}
    
    public string recid    = "";
    public string saveType = Constants.SAVE_TYPE_EDIT.ToString();
    public string prname   = "";
    public string ptname   = "";
    public string sdate    = "";
    
    
    protected void Page_Load(object sender, EventArgs e)
    {
      /*-------------------------------
       * Get parameters
       *------------------------------*/ 
      
      recid = MBA.HttpApplication.getParameter("recid");
     
      /*-------------------------------
       * Load record and if its not
       * found get out
       *------------------------------*/ 
        
      CaseLoad cl = CaseLoads.load(dbConnApp,log,uInfo,recid);
              
      /*-------------------------------
       * Locate steps control
       *------------------------------*/ 
       
       Steps ctrlSteps = findControlRecu(this.Page, "save") as Steps;
      
      /*-------------------------------
       * Locate step controls
       *------------------------------*/     
      
       Step ctrlStep1 = findControlRecu(this.Page,"step1") as Step;
       Step ctrlStep2 = findControlRecu(this.Page,"step2") as Step;
       Step ctrlStep3 = findControlRecu(this.Page,"step3") as Step;
       Step ctrlStep4 = findControlRecu(this.Page,"step4") as Step;
       Step ctrlStep5 = findControlRecu(this.Page,"step5") as Step;
        
       /*-------------------------------
        * Locate data controls
        *------------------------------*/ 

       WebUIControlDataField ctrlRecID         = findControlRecu(this.Page, "recid")         as WebUIControlDataField;
       WebUIControlDataField ctrlClientID      = findControlRecu(this.Page, "clientid")      as WebUIControlDataField;
       WebUIControlDataField ctrlPracID        = findControlRecu(this.Page, "pracid")        as WebUIControlDataField;
       WebUIControlDataField ctrlPatID         = findControlRecu(this.Page, "patid")         as WebUIControlDataField;
                
       WebUIControlDataField ctrlStartDate     = findControlRecu(this.Page, "startdate")     as WebUIControlDataField;
       WebUIControlDataField ctrlAsmtDueAnn    = findControlRecu(this.Page, "asmtdueann" )   as WebUIControlDataField;
       WebUIControlDataField ctrlAsmtDueTriAnn = findControlRecu(this.Page, "asmtduetriann") as WebUIControlDataField;
        
       WebUIControlDataField ctrlTpyTmtDurInd2 = findControlRecu(this.Page, "tpytmtdurind2") as WebUIControlDataField;        
       WebUIControlDataField ctrlTpyTmtFrqInd2 = findControlRecu(this.Page, "tpytmtfrqind2") as WebUIControlDataField;       
       WebUIControlDataField ctrlTpyTmtDurInd3 = findControlRecu(this.Page, "tpytmtdurind3") as WebUIControlDataField;        
       WebUIControlDataField ctrlTpyTmtFrqInd3 = findControlRecu(this.Page, "tpytmtfrqind3") as WebUIControlDataField;
       WebUIControlDataField ctrlTpyTmtDurInd4 = findControlRecu(this.Page, "tpytmtdurind4") as WebUIControlDataField;        
       WebUIControlDataField ctrlTpyTmtFrqInd4 = findControlRecu(this.Page, "tpytmtfrqind4") as WebUIControlDataField;
       WebUIControlDataField ctrlTpyTmtDurInd5 = findControlRecu(this.Page, "tpytmtdurind5") as WebUIControlDataField;        
       WebUIControlDataField ctrlTpyTmtFrqInd5 = findControlRecu(this.Page, "tpytmtfrqind5") as WebUIControlDataField;
       WebUIControlDataField ctrlTpyTmtDurInd6 = findControlRecu(this.Page, "tpytmtdurind6") as WebUIControlDataField;        
       WebUIControlDataField ctrlTpyTmtFrqInd6 = findControlRecu(this.Page, "tpytmtfrqind6") as WebUIControlDataField;

       WebUIControlDataField ctrlTpyTmtDurGrp2 = findControlRecu(this.Page, "tpytmtdurgrp2") as WebUIControlDataField;        
       WebUIControlDataField ctrlTpyTmtFrqGrp2 = findControlRecu(this.Page, "tpytmtfrqgrp2") as WebUIControlDataField;
       WebUIControlDataField ctrlTpyTmtDurGrp3 = findControlRecu(this.Page, "tpytmtdurgrp3") as WebUIControlDataField;        
       WebUIControlDataField ctrlTpyTmtFrqGrp3 = findControlRecu(this.Page, "tpytmtfrqgrp3") as WebUIControlDataField;
       WebUIControlDataField ctrlTpyTmtDurGrp4 = findControlRecu(this.Page, "tpytmtdurgrp4") as WebUIControlDataField;        
       WebUIControlDataField ctrlTpyTmtFrqGrp4 = findControlRecu(this.Page, "tpytmtfrqgrp4") as WebUIControlDataField;
       WebUIControlDataField ctrlTpyTmtDurGrp5 = findControlRecu(this.Page, "tpytmtdurgrp5") as WebUIControlDataField;        
       WebUIControlDataField ctrlTpyTmtFrqGrp5 = findControlRecu(this.Page, "tpytmtfrqgrp5") as WebUIControlDataField;
       WebUIControlDataField ctrlTpyTmtDurGrp6 = findControlRecu(this.Page, "tpytmtdurgrp6") as WebUIControlDataField;        
       WebUIControlDataField ctrlTpyTmtFrqGrp6 = findControlRecu(this.Page, "tpytmtfrqgrp6") as WebUIControlDataField;
        
       WebUIControlDataField ctrlTmtEffDate    = findControlRecu(this.Page, "tmteffdate")    as WebUIControlDataField;

       /*-------------------------------
        * Populate step labels
        *------------------------------*/
        
        ctrlRecID.value = cl.id.ToString();
        prname          = cl.pracName;
        ptname          = cl.patName;
        sdate           = Util.dateTimeToShortDate(cl.startDate);
  
        ctrlStep1.label = Util.dateTimeToShortDate(cl.AsmtDueAnn);
        ctrlStep2.label = Util.dateTimeToShortDate(cl.AsmtDueTriAnn);
        ctrlStep3.label = cl.TmtSchedule;
        ctrlStep4.label = Util.dateTimeToShortDate(cl.TmtEffectiveDate);

       /*-------------------------------
        * Populate data values that
        * cannot be edited but we need
        * to pass 
        *------------------------------*/

       ctrlClientID.value      = cl.clientID.ToString();
       ctrlPracID.value        = cl.pracID.ToString();
       ctrlPatID.value         = cl.patID.ToString();       
       ctrlStartDate.value     = sdate;
       
       /*-------------------------------
        * Populate data values that
        * can be edited 
        *------------------------------*/
       
       ctrlAsmtDueAnn.value    = Util.dateTimeToShortDate(cl.AsmtDueAnn);
       ctrlAsmtDueTriAnn.value = Util.dateTimeToShortDate(cl.AsmtDueTriAnn);
        
       ctrlTpyTmtDurInd2.value = (cl.TmtDurInd2 == 0) ? "" : cl.TmtDurInd2.ToString();
       ctrlTpyTmtFrqInd2.value = (cl.TmtFrqInd2 == 0) ? "" : cl.TmtFrqInd2.ToString();
       ctrlTpyTmtDurInd3.value = (cl.TmtDurInd3 == 0) ? "" : cl.TmtDurInd3.ToString();
       ctrlTpyTmtFrqInd3.value = (cl.TmtFrqInd3 == 0) ? "" : cl.TmtFrqInd3.ToString();       
       ctrlTpyTmtDurInd4.value = (cl.TmtDurInd4 == 0) ? "" : cl.TmtDurInd4.ToString();
       ctrlTpyTmtFrqInd4.value = (cl.TmtFrqInd4 == 0) ? "" : cl.TmtFrqInd4.ToString();
       ctrlTpyTmtDurInd5.value = (cl.TmtDurInd5 == 0) ? "" : cl.TmtDurInd5.ToString();
       ctrlTpyTmtFrqInd5.value = (cl.TmtFrqInd5 == 0) ? "" : cl.TmtFrqInd5.ToString();
       ctrlTpyTmtDurInd6.value = (cl.TmtDurInd6 == 0) ? "" : cl.TmtDurInd6.ToString();
       ctrlTpyTmtFrqInd6.value = (cl.TmtFrqInd6 == 0) ? "" : cl.TmtFrqInd6.ToString();

       ctrlTpyTmtDurGrp2.value = (cl.TmtDurGrp2 == 0) ? "" : cl.TmtDurGrp2.ToString();
       ctrlTpyTmtFrqGrp2.value = (cl.TmtFrqGrp2 == 0) ? "" : cl.TmtFrqGrp2.ToString();
       ctrlTpyTmtDurGrp3.value = (cl.TmtDurGrp3 == 0) ? "" : cl.TmtDurGrp3.ToString();
       ctrlTpyTmtFrqGrp3.value = (cl.TmtFrqGrp3 == 0) ? "" : cl.TmtFrqGrp3.ToString();       
       ctrlTpyTmtDurGrp4.value = (cl.TmtDurGrp4 == 0) ? "" : cl.TmtDurGrp4.ToString();
       ctrlTpyTmtFrqGrp4.value = (cl.TmtFrqGrp4 == 0) ? "" : cl.TmtFrqGrp4.ToString();
       ctrlTpyTmtDurGrp5.value = (cl.TmtDurGrp5 == 0) ? "" : cl.TmtDurGrp5.ToString();
       ctrlTpyTmtFrqGrp5.value = (cl.TmtFrqGrp5 == 0) ? "" : cl.TmtFrqGrp5.ToString();
       ctrlTpyTmtDurGrp6.value = (cl.TmtDurGrp6 == 0) ? "" : cl.TmtDurGrp6.ToString();
       ctrlTpyTmtFrqGrp6.value = (cl.TmtFrqGrp6 == 0) ? "" : cl.TmtFrqGrp6.ToString();

       ctrlTmtEffDate.value    = Util.dateTimeToShortDate(cl.TmtEffectiveDate);

       ctrlSteps.firstStep = 4;
                
   
    }
  }
}
