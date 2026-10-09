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
   * SubscriptionsSave */
  /**
   * Saves a report subscription
   ***************************************************************************/   

  public class clientcoorsubscriptionsave : WebUI
  {
    public int saveType = 0;
   
    public clientcoorsubscriptionsave() : base("subscription_save",WebUI.CreatePageSubTitle(Subscriptions.SEL_LABEL, Subscriptions.SEL_LABEL_ADD),"","",Constants.ROLE_LEA_CORDINATOR){}
    
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

        Subscription sr = Subscriptions.load(dbConnApp,log,uInfo,recid);

        /*-------------------------------
         * Locate data controls
         *------------------------------*/ 

        WebUIControlDataField    ctrlRecID               = findControlRecu(this.Page, "recid")              as WebUIControlDataField;
        WebUIControlDataField    ctrlClientID            = findControlRecu(this.Page, "clientid")           as WebUIControlDataField;        
        WebUIControlDataField    ctrlPublicationID       = findControlRecu(this.Page, "publicationid")      as WebUIControlDataField;        
        WebUIControlDataField    ctrlSubscriberID        = findControlRecu(this.Page, "subscriberid")       as WebUIControlDataField;        
        WebUIControlDataField    ctrlAutoDistribute      = findControlRecu(this.Page, "autodistribute" )    as WebUIControlDataField;        
        TextAreaBox              ctrlDistNotes           = findControlRecu(this.Page, "distributionnotes")  as TextAreaBox;        
        MBA.SelectReportFileType ctrlGrpReportFileType   = findControlRecu(this.Page, "reportFileType")     as MBA.SelectReportFileType;

        /*-------------------------------
         * Populate data values and step
         * labels
         *------------------------------*/

        ctrlRecID.value              = sr.id.ToString();     
        ctrlClientID.value           = sr.ClientID.ToString();
        
        ctrlPublicationID.value      = sr.PublicationID.ToString();
        ctrlPublicationID.setParentStepLabel(sr.PublicationName);

        ctrlSubscriberID.value       = sr.SubscriberID.ToString();
        ctrlSubscriberID.setParentStepLabel(sr.SubscriberName);

        ctrlAutoDistribute.value     = Util.boolToYesNo(sr.AutoDistribute);
        ctrlAutoDistribute.setParentStepLabel(ctrlAutoDistribute.value);

        ctrlDistNotes.value          = sr.DistributionNotes;
        ctrlDistNotes.setParentStepLabel(Util.previewString(sr.DistributionNotes));

        ctrlGrpReportFileType .value = sr.FileTypeRequestedValue.ToString();
        ctrlGrpReportFileType.setParentStepLabel(sr.FileTypeRequestedName);
        
        /*-------------------------------
         * Set title and 1st step
         *------------------------------*/ 
        
        this.subTitle = WebUI.CreatePageSubTitle(Subscriptions.SEL_LABEL, Subscriptions.SEL_LABEL_EDIT);
        
        ctrlSteps.firstStep = 4;
      
      }
   
    }
  }
}
