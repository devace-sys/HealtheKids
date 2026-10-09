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
   * SBSAllUserSave */
  /**
   * Saves a user account
   ***************************************************************************/   

  public class clientcoorusersave : WebUI
  {
    public int saveType = 0;

    public clientcoorusersave() : base("user_save", "Users - New", "", "", Constants.ROLE_CLIENT_BO) { }

    protected void Page_Load(object sender, EventArgs e)
    {
      /*-------------------------------
       * Determine what save type
       * this is 
       *------------------------------*/ 
      
      string recid     = MBA.HttpApplication.getParameter("recid");
      string savetype  = MBA.HttpApplication.getParameter("savetype");
      
      Object vSaveType = MBA.Validate.optInteger(savetype,Messages.INVALID_SAVE_TYPE);
   
      if (vSaveType == null) vSaveType = Constants.SAVE_TYPE_NEW;

      saveType = (int) vSaveType;

      WebUIControlDataField ctrlSaveType = findControlRecu(this.Page, "savetype")      as WebUIControlDataField;
      Steps                 ctrlSteps    = findControlRecu(this.Page, "save")          as Steps;
      
      ctrlSaveType.value = saveType.ToString();
        
      if (saveType == Constants.SAVE_TYPE_EDIT)
      {
        /*-------------------------------
         * Load record and if its not
         * found get out
         *------------------------------*/

        MBA.User u = Spedmon.Users.load(dbConnUser,log,uInfo,recid);

        /*-------------------------------
         * Locate step controls
         *------------------------------*/

        Step ctrlStep1 = findControlRecu(this.Page, "step1") as Step;
        Step ctrlStep3 = findControlRecu(this.Page, "step3") as Step;
        Step ctrlStep4 = findControlRecu(this.Page, "step4") as Step;
        Step ctrlStep5 = findControlRecu(this.Page, "step5") as Step;
        Step ctrlStep6 = findControlRecu(this.Page, "step6") as Step;
        Step ctrlStep7 = findControlRecu(this.Page, "step7") as Step;

        StepSelectPractitioner ctrlStep2 = findControlRecu(this.Page, "step2") as StepSelectPractitioner;


        /*-------------------------------
         * Locate data controls
         *------------------------------*/

        WebUIControlDataField ctrlRecID     = findControlRecu(this.Page, "recid")     as WebUIControlDataField;
        WebUIControlDataField ctrlClientID  = findControlRecu(this.Page, "clientid")  as WebUIControlDataField;
        WebUIControlDataField ctrlLname     = findControlRecu(this.Page, "lname")     as WebUIControlDataField;
        WebUIControlDataField ctrlFname     = findControlRecu(this.Page, "fname")     as WebUIControlDataField;
        WebUIControlDataField ctrlPhone     = findControlRecu(this.Page, "phone")     as WebUIControlDataField;
        WebUIControlDataField ctrlEmail     = findControlRecu(this.Page, "email")     as WebUIControlDataField;
        WebUIControlDataField ctrlRoleID    = findControlRecu(this.Page, "roleid")    as WebUIControlDataField;
        WebUIControlDataField ctrlUserName  = findControlRecu(this.Page, "username")  as WebUIControlDataField;
        WebUIControlDataField ctrlRecvEmail = findControlRecu(this.Page, "receiveEmailNotifications") as WebUIControlDataField;
        
        var ctrlSelpaCode = findControlRecu(this.Page, "selpacode") as MBA.HiddenInput; 
        
        /*-------------------------------
         * Populate step labels
         *------------------------------*/

        ctrlStep1.label = u.email;
        ctrlStep2.label = u.pracName;
        ctrlStep3.label = u.name;
        ctrlStep4.label = u.phone;
        ctrlStep5.label = u.userName;
        ctrlStep6.label = u.roleName;
        ctrlStep7.label = Util.boolToYesNo(u.sendUserEmailNotifications);

        /*-------------------------------
         * Populate Data Values
         *------------------------------*/

        ctrlRecID.value       = u.id.ToString();
        ctrlClientID.value    = u.clientID.ToString();
        ctrlStep2.selectvalue = u.pracID.ToString();
        ctrlLname.value       = u.lastName;
        ctrlFname.value       = u.firstName;
        ctrlEmail.value       = u.email;
        ctrlPhone.value       = u.phone;
        ctrlRoleID.value      = u.roleID.ToString();
        ctrlUserName.value    = u.userName;
        ctrlRecvEmail.value   = Util.boolToYesNo(u.sendUserEmailNotifications);
        ctrlSelpaCode.value   = u.selpaCode.ToString();

        if (saveType == Constants.SAVE_TYPE_EDIT)   this.subTitle = "Users - Edit";
        if (saveType == Constants.SAVE_TYPE_DELETE) this.subTitle = "Users - Delete";

        ctrlSteps.firstStep = 7;

      }
      else
      {
        /*-------------------------------
         * Otherwise its a new record
         *------------------------------*/ 

        this.subTitle = "Users - New";
        
      }
    }
  }
}
