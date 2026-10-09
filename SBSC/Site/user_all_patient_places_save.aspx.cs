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
   * UserAllTransportMgmt */
  /**
   * Manage transportation services
   ***************************************************************************/   

  public class UserAllPatientPlacesSave : WebUI
  {
  
    public int saveType = 0;
    
    public UserAllPatientPlacesSave() : base(  @"patient_places_save"
                                             , WebUI.CreatePageSubTitle(   PatientPlaces.SEL_LABEL
                                                                         , PatientPlaces.SEL_LABEL_ADD )
	                                           , @""
	                                           , @""				                             
										                         , Constants.ROLE_ALL_PCAL_AND_CLIENT){}    
    
    protected void Page_Load(object sender, EventArgs e)
    {      
      
      /*-------------------------------
       * Determine what save type
       * this is
       *------------------------------*/
     
      string  recid       = MBA.HttpApplication.getParameter("recid");
      string  savetype    = MBA.HttpApplication.getParameter("savetype");
	    string  clientid    = MBA.HttpApplication.getParameter(@"clientid");
	    string  patid       = MBA.HttpApplication.getParameter(@"patid");
	    
	    long    clientID    = Spedmon.Validate.reqClientID (uInfo,clientid);	          
		  long    patID       = Spedmon.Validate.reqInteger  (patid,Messages.INVALID_PAT_ID);
           
      Object vSaveType = MBA.Validate.optInteger(savetype,Messages.INVALID_SAVE_TYPE);
   
      if (vSaveType == null)
        vSaveType = Constants.SAVE_TYPE_NEW;
     
      saveType = (int) vSaveType;

      clientid = clientID.ToString();
      patid    = patID.ToString();
      savetype = saveType.ToString();

      Steps       ctrlSteps    = findControlRecu(this.Page, "save")       as Steps;
      HiddenInput ctrlSaveType = findControlRecu(this.Page, "savetype")   as HiddenInput;
      HiddenInput ctrlClientID = findControlRecu(this.Page, "clientid")   as HiddenInput;
      HiddenInput ctrlPatID    = findControlRecu(this.Page, "patid")      as HiddenInput;      
      HiddenInput ctrlRecID    = findControlRecu(this.Page, "recid")      as HiddenInput;
            
      ctrlClientID.value = clientid;
      ctrlPatID.value    = patid;
      ctrlSaveType.value = savetype;
      
      if (saveType != Constants.SAVE_TYPE_NEW)
      {
        
        if (saveType == Constants.SAVE_TYPE_EDIT)   
        {
          this.subTitle = WebUI.CreatePageSubTitle(PatientPlaces.SEL_LABEL, PatientPlaces.SEL_LABEL_EDIT);
        }
        else if (saveType == Constants.SAVE_TYPE_DELETE) 
        {
          this.subTitle = WebUI.CreatePageSubTitle(PatientPlaces.SEL_LABEL, PatientPlaces.SEL_LABEL_DELETE);
        }
        else
        {
          throw new Warning(Messages.INVALID_SAVE_TYPE);  
        }
        
        long recID = MBA.Validate.reqInteger(recid, Messages.INVALID_RECORD_ID);
        recid = recID.ToString();
        
        ctrlRecID.value = recid;
        
        PatientPlace pp = PatientPlaces.load (dbConnApp, log, uInfo, clientid, patid, recid);
        
        
        Step ctrlStep1  = findControlRecu(this.Page, "step1")  as Step;
        Step ctrlStep2  = findControlRecu(this.Page, "step2")  as Step;
        Step ctrlStep3  = findControlRecu(this.Page, "step3")  as Step;
        Step ctrlStep4  = findControlRecu(this.Page, "step4")  as Step;
        Step ctrlStep5  = findControlRecu(this.Page, "step5")  as Step;
        Step ctrlStep6  = findControlRecu(this.Page, "step6")  as Step;
        Step ctrlStep7  = findControlRecu(this.Page, "step7")  as Step;
        Step ctrlStep8  = findControlRecu(this.Page, "step8")  as Step;
  
        MBA.TextBox ctrlName     = findControlRecu(this.Page,"name")     as MBA.TextBox;
        MBA.TextBox ctrlAddress1 = findControlRecu(this.Page,"address1") as MBA.TextBox;
        MBA.TextBox ctrlAddress2 = findControlRecu(this.Page,"address2") as MBA.TextBox;
        MBA.TextBox ctrlCity     = findControlRecu(this.Page,"city")     as MBA.TextBox;
        MBA.TextBox ctrlState    = findControlRecu(this.Page,"state")    as MBA.TextBox;
        MBA.TextBox ctrlZip5     = findControlRecu(this.Page,"zip5")     as MBA.TextBox;
        MBA.TextBox ctrlZip4     = findControlRecu(this.Page,"zip4")     as MBA.TextBox;
        
        ctrlName.value     = pp.name;
        ctrlAddress1.value = pp.address1;
        ctrlAddress2.value = pp.address2;
        ctrlCity.value     = pp.city;
        ctrlState.value    = pp.state;
        ctrlZip5.value     = pp.zip5;
        ctrlZip4.value     = pp.zip4;    
        
        ctrlStep1.label    = ctrlName.value;        
        ctrlStep2.label    = ctrlAddress1.value;
        ctrlStep3.label    = ctrlAddress2.value;
        ctrlStep4.label    = ctrlCity.value;
        ctrlStep5.label    = ctrlState.value;
        ctrlStep6.label    = ctrlZip5.value;
        ctrlStep7.label    = ctrlZip4.value;
        
        ctrlSteps.firstStep = 7;
      }                       
    }
  }
}
