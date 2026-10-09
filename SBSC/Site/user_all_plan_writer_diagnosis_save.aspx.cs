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
  /***************************************************************************
  * ClientSave */
  /**
  * Saves a client
  ***************************************************************************/

  public class UserAllPlanWriterDiagnosis : WebUI
  {
    public int saveType = 0;
    public UserAllPlanWriterDiagnosis() : base("plan_writer_diagnosis_save", "Diagnosis - New", "", "", Constants.ROLE_SBS_ALL) { }
    protected void Page_Load(object sender, EventArgs e)
    {
      /*-------------------------------
       * Determine what save type
       * this is 
       *------------------------------*/

        string recid        = MBA.HttpApplication.getParameter("recid");
        string savetype     = MBA.HttpApplication.getParameter("savetype");
        string clientid;
        try {
            clientid = MBA.HttpApplication.getParameter("clientid");
        } catch {
            clientid = "";
        }
        string templatetype = MBA.HttpApplication.getParameter("templatetype");

        Object vSaveType = MBA.Validate.optInteger(savetype, Messages.INVALID_SAVE_TYPE);

        if (vSaveType == null) vSaveType = Constants.SAVE_TYPE_NEW;
        saveType = (int)vSaveType;

        /*-------------------------------
        * Locate data controls
        *------------------------------*/

        DataEntryRowSaveOrEdit  ctrlSaveOrEdit                               = findControlRecu(this.Page, "saveOrEdit")           as DataEntryRowSaveOrEdit;
        var                     ctrlclientid                                 = findControlRecu(this.Page, "clientid")             as MBA.HiddenInput;
        WebUIControlDataField   ctrldiagnosisname                            = findControlRecu(this.Page, "diagnosisName")        as WebUIControlDataField;
        RichTextAreaBox         ctrldiagnosisdescription                     = findControlRecu(this.Page, "diagnosisDescription") as RichTextAreaBox;
        HiddenInput             ctrltemplatetype                             = findControlRecu(this.Page, "templatetype")         as HiddenInput;

        /*-------------------------------
         * Load clientid into the hidden
         * input
         *------------------------------*/

        ctrlclientid.value = clientid;
        ctrltemplatetype.value = templatetype.ToString();


        if (saveType == Constants.SAVE_TYPE_EDIT)
        {
            /*-------------------------------
             * Load record and if its not
             * found get out
             *------------------------------*/

            PlanWriterDiagnosis d = PlanWriterDiagnoses.loadDiagnosis(dbConnApp, log, uInfo, clientid, templatetype.ToString(), recid);

            /*-------------------------------
             * Populate Data Values
             *------------------------------*/

            ctrlSaveOrEdit.saveType        = saveType;
            ctrlSaveOrEdit.recID           = d.id.ToString();
                                           
            ctrldiagnosisname.value        = d.name;
            ctrldiagnosisdescription.value = d.description;
  
            if (saveType == Constants.SAVE_TYPE_EDIT)   this.subTitle = "Diagnosis - Edit";
            if (saveType == Constants.SAVE_TYPE_DELETE) this.subTitle = "Diagnosis - Delete";

        }
        else
        {
            /*-------------------------------
             * Otherwise its a new record
             *------------------------------*/
            this.subTitle = "Diagnosis - New";
        }
    }
  }
}