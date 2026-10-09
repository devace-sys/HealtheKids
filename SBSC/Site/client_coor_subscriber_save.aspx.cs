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

namespace Spedmon
{
  /***************************************************************************
   * clentcoorsubscribersave */
  /**
   * Saves a report subscriber
   * 
   * Note: the only possible value for isInternal for users of this screen
   * is "0"
   * 
   ***************************************************************************/   

  public class clentcoorsubscribersave : WebUI
  {
    public int saveType = 0;
   
    public clentcoorsubscribersave() : base("subscriber_save",WebUI.CreatePageSubTitle(Subscribers.SEL_LABEL, Subscribers.SEL_LABEL_ADD),"","",Constants.ROLE_LEA_CORDINATOR){}
    
    protected void Page_Load(object sender, EventArgs e)
    {
      /*-------------------------------
       * Determine what save type
       * this is 
       *------------------------------*/ 
      
      string recid     = MBA.HttpApplication.getParameter("recid");
      string savetype  = MBA.HttpApplication.getParameter("savetype");
            
      Object vSaveType = MBA.Validate.optInteger(savetype,Messages.INVALID_SAVE_TYPE);
   
      if (vSaveType == null) 
        vSaveType = Constants.SAVE_TYPE_NEW;
      
      saveType = (int) vSaveType;

      WebUIControlDataField ctrlSaveType = findControlRecu(this.Page, "savetype")   as WebUIControlDataField;      
      Steps                 ctrlSteps    = findControlRecu(this.Page, "save")       as Steps;
      

      ctrlSaveType.value = saveType.ToString();
      
      if (saveType == Constants.SAVE_TYPE_EDIT)
      {
        /*-------------------------------
         * Load record and if its not
         * found get out
         *------------------------------*/ 

        Subscriber sr = Subscribers.load(dbConnApp,log,uInfo,recid);
        
        /*-------------------------------
         * Locate step controls
         *------------------------------*/ 

        Step ctrlStep1 = findControlRecu(this.Page,"step1") as Step;
        Step ctrlStep2 = findControlRecu(this.Page,"step2") as Step;
        Step ctrlStep3 = findControlRecu(this.Page,"step3") as Step;
       

       /*-------------------------------
        * Locate data controls
        *------------------------------*/ 

        WebUIControlDataField ctrlRecID          = findControlRecu(this.Page, "recid")     as WebUIControlDataField;
        WebUIControlDataField ctrlClientID       = findControlRecu(this.Page, "clientid")  as WebUIControlDataField;
        WebUIControlDataField ctrlLastName       = findControlRecu(this.Page, "lname")     as WebUIControlDataField;        
        WebUIControlDataField ctrlFirstName      = findControlRecu(this.Page, "fname")     as WebUIControlDataField;
        WebUIControlDataField ctrlEmail          = findControlRecu(this.Page, "email" )    as WebUIControlDataField;

        /*-------------------------------
         * Populate step labels
         *------------------------------*/
        
       
        ctrlStep1.label = sr.name;
        ctrlStep2.label = sr.email;

        /*-------------------------------
         * Populate data values
         *------------------------------*/

        ctrlRecID.value         = sr.id.ToString();     
        ctrlClientID.value      = sr.clientID.ToString();
        ctrlEmail.value         = sr.email;
        ctrlFirstName.value     = sr.firstName;
        ctrlLastName.value      = sr.lastName;
                 
        /*-------------------------------
         * Set title and 1st step
         *------------------------------*/ 
        
        this.subTitle = WebUI.CreatePageSubTitle(Subscribers.SEL_LABEL, Subscribers.SEL_LABEL_EDIT);
        
        ctrlSteps.firstStep = 2;
      
      }
   
    }
  }
}
