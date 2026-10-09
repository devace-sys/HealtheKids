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
   * UserAllPatientPersonsSave */
  /**
   * 
   ***************************************************************************/   

  public class UserAllPatientPersonsSave: WebUI
  {
  
    public int saveType = 0;
    
    public UserAllPatientPersonsSave() : base(  @"patient_persons_save"
                                               , WebUI.CreatePageSubTitle(   PatientPersons.SEL_LABEL
                                                                           , PatientPersons.SEL_LABEL_ADD )
	                                             , @""
	                                             , @""				                             
										                           , Constants.ROLE_ALL_PCAL_AND_CLIENT){}    
    
    protected void Page_Load(object sender, EventArgs e)
    {      
      
      /*-------------------------------
       * Determine what save type
       * this is
       *------------------------------*/
     
      string  recid        = MBA.HttpApplication.getParameter("recid");
      string  savetype     = MBA.HttpApplication.getParameter("savetype");
	    string  clientid     = MBA.HttpApplication.getParameter(@"clientid");
	    string  patientid    = MBA.HttpApplication.getParameter(@"patientid");

	    long    clientID    = Spedmon.Validate.reqClientID (uInfo,clientid);	          
		  long    patientID   = Spedmon.Validate.reqInteger  (patientid,Messages.INVALID_PAT_ID);
           
      Object vSaveType = MBA.Validate.optInteger(savetype,Messages.INVALID_SAVE_TYPE);
   
      if (vSaveType == null)
        vSaveType = Constants.SAVE_TYPE_NEW;
     
      saveType = (int) vSaveType;

      clientid   = clientID.ToString();
      patientid  = patientID.ToString();
      savetype   = saveType.ToString();
 
      Steps        ctrlSteps       = findControlRecu(this.Page, "save")         as Steps;
      HiddenInput  ctrlSaveType    = findControlRecu(this.Page, "savetype")     as HiddenInput;
      HiddenInput  ctrlClientID    = findControlRecu(this.Page, "clientid")     as HiddenInput;
      HiddenInput  ctrlPatID       = findControlRecu(this.Page, "patientid")    as HiddenInput;      
      HiddenInput  ctrlRecID       = findControlRecu(this.Page, "recid")        as HiddenInput;
      MBA.ComboBox ctrlPersonRole  = findControlRecu(this.Page, "personroleid") as MBA.ComboBox;
            
      ctrlClientID.value = clientid;
      ctrlPatID.value    = patientid;
      ctrlSaveType.value = savetype;
                    
      if (saveType == Constants.SAVE_TYPE_EDIT)   
      {
        this.subTitle = WebUI.CreatePageSubTitle(PatientPersons.SEL_LABEL, PatientPersons.SEL_LABEL_EDIT);
        
        long recID = MBA.Validate.reqInteger(recid, Messages.INVALID_RECORD_ID);
        recid = recID.ToString();        
        ctrlRecID.value = recid;
        
        PatientPerson pp = PatientPersons.load (dbConnApp,log,uInfo,clientid,patientid,recid);
        
        Step ctrlStep1   = findControlRecu(this.Page, "step1")   as Step;
        Step ctrlStep2   = findControlRecu(this.Page, "step2")   as Step;
        Step ctrlStep3   = findControlRecu(this.Page, "step3")   as Step;
        Step ctrlStep4   = findControlRecu(this.Page, "step4")   as Step;
        Step ctrlStep5   = findControlRecu(this.Page, "step5")   as Step;
        Step ctrlStep6   = findControlRecu(this.Page, "step6")   as Step;
        Step ctrlStep7   = findControlRecu(this.Page, "step7")   as Step;
        Step ctrlStep8   = findControlRecu(this.Page, "step8")   as Step;
        Step ctrlStep9   = findControlRecu(this.Page, "step9")   as Step;
        Step ctrlStep10  = findControlRecu(this.Page, "step10")  as Step;
        Step ctrlStep11  = findControlRecu(this.Page, "step11")  as Step;
        Step ctrlStep12  = findControlRecu(this.Page, "step12")  as Step;
        Step ctrlStep13  = findControlRecu(this.Page, "step13")  as Step;
        Step ctrlStep14  = findControlRecu(this.Page, "step14")  as Step;
        Step ctrlStep15  = findControlRecu(this.Page, "step15")  as Step;
        
        MBA.ComboBox ctrlPersonRel  = findControlRecu(this.Page,"personrelationshipid")  as MBA.ComboBox;
        MBA.Input    ctrlLastName   = findControlRecu(this.Page,"lastname")              as MBA.Input;
        MBA.Input    ctrlFirstName  = findControlRecu(this.Page,"firstname")             as MBA.Input;
        MBA.Input    ctrlMiddleName = findControlRecu(this.Page,"middlename")            as MBA.Input;
        MBA.EmailBox ctrlEmail      = findControlRecu(this.Page,"email")                 as MBA.EmailBox;
        MBA.PhoneBox ctrlPhone      = findControlRecu(this.Page,"phone")                 as MBA.PhoneBox;
        MBA.PhoneBox ctrlFax        = findControlRecu(this.Page,"fax")                   as MBA.PhoneBox;
        MBA.TextBox  ctrlZip5       = findControlRecu(this.Page,"zip5")                  as MBA.TextBox;        
        MBA.TextBox  ctrlAddress1   = findControlRecu(this.Page,"address1")              as MBA.TextBox;
        MBA.TextBox  ctrlAddress2   = findControlRecu(this.Page,"address2")              as MBA.TextBox;        
        MBA.TextBox  ctrlCity       = findControlRecu(this.Page,"city")                  as MBA.TextBox;
        MBA.TextBox  ctrlState      = findControlRecu(this.Page,"state")                 as MBA.TextBox;
        MBA.TextBox  ctrlZip4       = findControlRecu(this.Page,"zip4")                  as MBA.TextBox;
        MBA.TextBox  ctrlAddData1   = findControlRecu(this.Page,"additionaldata1")       as MBA.TextBox;
        MBA.TextBox  ctrlAddData2   = findControlRecu(this.Page,"additionaldata2")       as MBA.TextBox;
        
        ctrlPersonRole.value = pp.classID1.ToString();
        ctrlPersonRel.value  = pp.classID2.ToString();
        ctrlLastName.value   = pp.lastName;
        ctrlFirstName.value  = pp.firstName;
        ctrlMiddleName.value = pp.middleName;
        ctrlEmail.value      = pp.email;
        ctrlPhone.value      = pp.phone;
        ctrlFax.value        = pp.fax;
        ctrlZip5.value       = pp.zip5;
        ctrlAddress1.value   = pp.address1;
        ctrlAddress2.value   = pp.address2;
        ctrlCity.value       = pp.city;
        ctrlState.value      = pp.state;
        ctrlZip4.value       = pp.zip4;
        ctrlAddData1.value   = pp.additionalData1;
        ctrlAddData2.value   = pp.additionalData2;
        
        ctrlStep1.label  = pp.className1;
        ctrlStep2.label  = pp.className2;
        ctrlStep3.label  = pp.name;
        ctrlStep4.label  = pp.email;
        ctrlStep5.label  = pp.phone;
        ctrlStep6.label  = pp.fax;
        ctrlStep7.label  = pp.zip5;
        ctrlStep8.label  = pp.address1;
        ctrlStep9.label  = pp.address2;
        ctrlStep10.label = pp.city;
        ctrlStep11.label = pp.state;
        ctrlStep12.label = pp.zip4;
        ctrlStep13.label = pp.additionalData1;
        ctrlStep14.label = pp.additionalData2;
        
        ctrlSteps.firstStep = 3;
      }
                                  
    }
  }
}
