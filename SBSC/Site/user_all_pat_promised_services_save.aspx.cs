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
  * PatientSave */
  /**
  * Saves a patient
  ***************************************************************************/   
 
  public class UserAllPatientPromisedServicesSave : WebUI
  {
    public int    saveType = 0;
    public string patNameDisplay = @"";
    public bool   showReplacementFields = false;        
    public bool   hasSvcLinesDetails = false;
    public string svcLinesDetailsJSON   = "";
    public UserAllPatientPromisedServicesSave() : base( "patient_save"
                                      , Patients.SEL_LABEL_SAVE
                                      , "user_all_pat_promised_services_save.css"
                                      , ""
                                      , Constants.ROLE_ALL_PCAL_AND_CLIENT) {}
 
    protected void Page_Load(object sender, EventArgs e)
    {
 
      /*-------------------------------
       * Determine what save type
       * this is 
       *------------------------------*/ 
      
      string recid     = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
      string patid     = MBA.HttpApplication.getParameter(Constants.PARM_PATIENT_ID);
      string savetype  = MBA.HttpApplication.getParameter(Constants.PARM_SAVE_TYPE);
   
      Object vSaveType = MBA.Validate.optInteger(savetype,Messages.INVALID_SAVE_TYPE);
      if (vSaveType == null) vSaveType = Constants.SAVE_TYPE_NEW;
      saveType = (int) vSaveType;
 
      /*-------------------------------
       * Locate data controls
       *------------------------------*/
 
      DataEntryRowSaveOrEdit ctrlSaveOrEdit         = findControlRecu(this.Page, "saveOrEdit")         as DataEntryRowSaveOrEdit;
      HiddenInput            ctrlPatid              = findControlRecu(this.Page, "patid")              as HiddenInput;
      ComboBox               ctrlSpedservicecode    = findControlRecu(this.Page, "spedservicecode")    as ComboBox;
      ComboBox               ctrlSpedprovidercode   = findControlRecu(this.Page, "spedprovidercode")   as ComboBox;
      ComboBox               ctrlSpedfreqcode       = findControlRecu(this.Page, "spedfreqcode")       as ComboBox;
      DateBoxHTML5           ctrlStartdate          = findControlRecu(this.Page, "startdate")          as DateBoxHTML5;
      DateBoxHTML5           ctrlEnddate            = findControlRecu(this.Page, "enddate")            as DateBoxHTML5;
      SelectYesOrNo          ctrlIndividualdelivery = findControlRecu(this.Page, "individualdelivery") as SelectYesOrNo;
      SelectYesOrNo          ctrlGroupdelivery      = findControlRecu(this.Page, "groupdelivery")      as SelectYesOrNo;
      WebUIControlDataField  ctrlMinsperfreq        = findControlRecu(this.Page, "minsperfreq")        as WebUIControlDataField;
      ComboBox               ctrlSpedlocationcode   = findControlRecu(this.Page, "spedlocationcode")   as ComboBox;
      
      var ctrlReplacementDataActive         = findControlRecu(this.Page, "replacementdataactive")         as SelectYesOrNo;
      var ctrlReplacementSpEdServiceCode    = findControlRecu(this.Page, "replacementspedservicecode")    as ComboBox;
      var ctrlReplacementSpEdFreqCode       = findControlRecu(this.Page, "replacementspedfreqcode")       as ComboBox;
      var ctrlReplacementMinsPerFreq        = findControlRecu(this.Page, "replacementminsperfreq")        as WebUIControlDataField;
               

      /*------------------------------------*/
      /* Set patient information            */
      /*------------------------------------*/

      Patient pp      = Patients.load(dbConnApp, log, uInfo, patid);
      patNameDisplay  = "Patient: " + pp.name;

      ctrlPatid.value = patid;
      showReplacementFields = false;

      if (saveType == Constants.SAVE_TYPE_EDIT)
      {
        showReplacementFields = true;

        /*-------------------------------
         * Load record and if its not
         * found get out
         *------------------------------*/
 
        PatientPromisedService p = PatientPromisedServices.load(this.dbConnApp, this.log, this.uInfo, recid);

        ctrlSaveOrEdit.saveType = saveType;
        ctrlSaveOrEdit.recID    = p.id.ToString();
        
        ctrlSpedservicecode.value       =  p.spEdServiceCode.ToString();
        ctrlSpedservicecode.selectName  =  p.spEdServiceCodeAndName;
        ctrlSpedprovidercode.value      =  p.spEdProviderCode.ToString();
        ctrlSpedprovidercode.selectName =  p.spEdProviderCodeAndName;
        ctrlSpedfreqcode.value          =  p.spEdFreqCode.ToString();
        ctrlSpedfreqcode.selectName     =  p.spEdFreqCodeAndName;
        ctrlStartdate.value             = (p.startDate == DateTime.MinValue) ?
                                             "" : p.startDate.ToString("yyyy-MM-dd");
        ctrlEnddate.value               = (p.endDate == DateTime.MinValue) ?
                                             "" : p.endDate.ToString("yyyy-MM-dd");
        ctrlIndividualdelivery.value    = Util.boolToYesNo(p.individualDelivery);
        ctrlGroupdelivery.value         = Util.boolToYesNo(p.groupDelivery);
        ctrlMinsperfreq.value           = p.minsPerFreq.ToString();
        ctrlSpedlocationcode.value      = p.spEdLocationCode.ToString();
        ctrlSpedlocationcode.selectName = p.spEdLocationCodeAndName;

        ctrlReplacementDataActive.value = Util.boolToYesNo(p.replacementDataActive); 

        if (p.replacementSpEdServiceCode.HasValue) { 
          ctrlReplacementSpEdServiceCode.value = p.replacementSpEdServiceCode.Value.ToString();
          ctrlReplacementSpEdServiceCode.selectName = p.replacementSpEdServiceCodeAndName;
        }

        if (p.replacementSpEdFreqCode.HasValue) {    
          ctrlReplacementSpEdFreqCode.value       = p.replacementSpEdFreqCode.Value.ToString();
          ctrlReplacementSpEdFreqCode.selectName  = p.replacementSpEdFreqCodeAndName;
        }

        if (p.replacementMinsPerFreq.HasValue) ctrlReplacementMinsPerFreq.value = p.replacementMinsPerFreq.Value.ToString();
        
        if (p.hasSvcLinesDetails) { 
          hasSvcLinesDetails  = p.hasSvcLinesDetails;
          svcLinesDetailsJSON = p.svcLinesDetailsJSON;
        }

        /*============================================================
         * Set page title
         *============================================================*/

        this.subTitle = "Promised Service - Edit";

      }
      else
      {

        /*============================================================
         * Set page title
         *============================================================*/

        this.subTitle = "Promised Service - New";

      }
 
    }
  }
}