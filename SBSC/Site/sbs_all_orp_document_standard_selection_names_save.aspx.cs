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
   * sbs_all_orp_document_standard_selection_names_save */
  /**
   * 
   ***************************************************************************/   

  public class sbs_all_orp_document_standard_selection_names_save : WebUI
  {

    public int saveType = 0;    
    
    public sbs_all_orp_document_standard_selection_names_save() : base ( 
        @"sbs_all_orp_document_standard_selection_names_save"
      , WebUI.CreatePageSubTitle(   ORPDocumentsStandardSelectionNames.SEL_LABEL
                                  , ORPDocumentsStandardSelectionNames.SEL_LABEL_NEW)
      , ""
      , ""
      , Constants.ROLE_SBS_ALL
    ){}

    protected void Page_Load(object sender, EventArgs e)
    {
          
      /*###########################################################################
        # Get parameters
        ###########################################################################*/  
      
      string recid     = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
      string savetype  = MBA.HttpApplication.getParameter(Constants.PARM_SAVE_TYPE);   
         
      /*###########################################################################
        # Check over save type
        ###########################################################################*/  

      Object vSaveType = MBA.Validate.optInteger(savetype,Messages.INVALID_SAVE_TYPE);   
      if (vSaveType == null)  vSaveType = Constants.SAVE_TYPE_NEW;      
      saveType = (int) vSaveType;

      /*###########################################################################
        # Find controls
        ###########################################################################*/  

      var ctrlSaveOrEdit             = findControlRecu(this.Page, "saveOrEdit")               as MBA.DataEntryRowSaveOrEdit; 
      var ctrlAllowMultipleOrders    = findControlRecu(this.Page, "allowmultipleorders")      as MBA.SelectYesOrNo;
      var ctrlOrderContextFieldName  = findControlRecu(this.Page, "ordercontextfieldname")    as MBA.DataEntryBoxText;
      var ctrlName                   = findControlRecu(this.Page, "name")                     as MBA.DataEntryBoxText;
      var ctrlGrpSvcClassNameID      = findControlRecu(this.Page, "groupserviceclassnameid")  as MBA.ComboBox;	    
      var ctrlNotes                  = findControlRecu(this.Page, "notes")                    as MBA.DataEntryBoxTextArea;      
      var ctrlSvcDescTempText        = findControlRecu(this.Page, "svcdesctemplatetext")      as MBA.DataEntryBoxTextArea;
      var ctrlNoteCrit1TempText      = findControlRecu(this.Page, "notecrit1templatetext")    as MBA.DataEntryBoxText;
      var ctrlNoteCrit2TempText      = findControlRecu(this.Page, "notecrit2templatetext")    as MBA.DataEntryBoxText;
      var ctrlNoteCrit3TempText      = findControlRecu(this.Page, "notecrit3templatetext")    as MBA.DataEntryBoxText;
      var ctrlNoteCrit4TempText      = findControlRecu(this.Page, "notecrit4templatetext")    as MBA.DataEntryBoxText;
      var ctrlNoteCrit5TempText      = findControlRecu(this.Page, "notecrit5templatetext")    as MBA.DataEntryBoxText;
      var ctrlNoteCrit6TempText      = findControlRecu(this.Page, "notecrit6templatetext")    as MBA.DataEntryBoxText;
      var ctrlNoteCrit7TempText      = findControlRecu(this.Page, "notecrit7templatetext")    as MBA.DataEntryBoxText;
      var ctrlNoteCrit8TempText      = findControlRecu(this.Page, "notecrit8templatetext")    as MBA.DataEntryBoxText;
      var ctrlNoteCrit9TempText      = findControlRecu(this.Page, "notecrit9templatetext")    as MBA.DataEntryBoxText;
      var ctrlNoteCrit10TempText     = findControlRecu(this.Page, "notecrit10templatetext")   as MBA.DataEntryBoxText;
      var ctrlClientID               = findControlRecu(this.Page, "clientid")                 as MBA.ComboBox;

      var ctrlFormBuilderContentJSON                            = findControlRecu(this.Page, "formBuilderContentJSON")                              as MBA.DataEntryRowFormBuilderBox;
      var ctrlFormBuilderContentForServiceJournalEntryNotesJSON = findControlRecu(this.Page, "formBuilderContentForServiceJournalEntryNotesJSON")   as MBA.DataEntryRowFormBuilderBox;
      var ctrlServiceJournalAssociatedEventTypeID               = findControlRecu(this.Page, @"serviceJournalAssociatedEventTypeID")                as MBA.RadioBox;
      
      /*###########################################################################
        #                                EDIT
        # Load record, set control values, step labels, first step, and page title
        ###########################################################################*/  

      if (saveType == Constants.SAVE_TYPE_EDIT)
      {
       
        /*============================================================
         * Load record and exit if not found
         *============================================================*/
         
        ORPDocumentStandardSelectionName ssn = ORPDocumentsStandardSelectionNames.load(dbConnApp,log,uInfo,recid);
               
        /*============================================================
         * Set control values and step labels for edit
         *============================================================*/

        /*-------------------------------
         * SaveType and RecID
         *------------------------------*/ 

        ctrlSaveOrEdit.saveType                     = saveType;
        ctrlSaveOrEdit.recID                        = ssn.id.ToString();

        /*-------------------------------
         * Client
         *------------------------------*/ 

        ctrlClientID.value = ssn.clientID.ToString();
        ctrlClientID.selectName = ssn.clientName;

        /*-------------------------------
         * Name
         *------------------------------*/

       ctrlName.value = ssn.name;
       
        /*-------------------------------
         * Group family
         *------------------------------*/ 

        ctrlGrpSvcClassNameID.value      = ssn.groupSvcClassNameID.ToString();
        ctrlGrpSvcClassNameID.selectName = ssn.groupSvcClassName;
                              
        /*-------------------------------
         * Notes
         *------------------------------*/ 

        ctrlNotes.value = ssn.notes;
      
        /*-------------------------------
         * Svc Description Template Text
         *------------------------------*/ 

        ctrlSvcDescTempText.value = ssn.svcDescTemplateText;

        /*-------------------------------
         * Note Criteria Template Text
         *------------------------------*/ 

        ctrlNoteCrit1TempText.value  = ssn.noteCrit1TemplateText;
        ctrlNoteCrit2TempText.value  = ssn.noteCrit2TemplateText;
        ctrlNoteCrit3TempText.value  = ssn.noteCrit3TemplateText;
        ctrlNoteCrit4TempText.value  = ssn.noteCrit4TemplateText;
        ctrlNoteCrit5TempText.value  = ssn.noteCrit5TemplateText;
        ctrlNoteCrit6TempText.value  = ssn.noteCrit6TemplateText;
        ctrlNoteCrit7TempText.value  = ssn.noteCrit7TemplateText;
        ctrlNoteCrit8TempText.value  = ssn.noteCrit8TemplateText;
        ctrlNoteCrit9TempText.value  = ssn.noteCrit9TemplateText;
        ctrlNoteCrit10TempText.value = ssn.noteCrit10TemplateText;

        /*-------------------------------
         * Allow multi orders controls
         *------------------------------*/

        ctrlAllowMultipleOrders.value   = Util.boolToYesNo(ssn.allowMultipleOrders);
        ctrlOrderContextFieldName.value = ssn.orderContextFieldName;

        /*-------------------------------
         * Form Builder Data JSON
         *------------------------------*/

        ctrlFormBuilderContentJSON.value                            = ssn.formBuilderContentJSON;
        ctrlFormBuilderContentForServiceJournalEntryNotesJSON.value = ssn.formBuilderContentForServiceJournalEntryNotesJSON;

        /*-------------------------------
         * Service journal associated 
         * event ID
         *------------------------------*/

        ctrlServiceJournalAssociatedEventTypeID.value = ssn.serviceJournalAssociatedEventTypeID.ToString();
        

         this.subTitle = WebUI.CreatePageSubTitle(  ORPDocumentsStandardSelectionNames.SEL_LABEL
                                                  , ORPDocumentsStandardSelectionNames.SEL_LABEL_EDIT);      
      }

      /*###########################################################################
        #                                NEW      
        ###########################################################################*/  
      
      else
      {
        
        ctrlServiceJournalAssociatedEventTypeID.value = "5"; /* Default event type */        
      
        this.subTitle = WebUI.CreatePageSubTitle(  ORPDocumentsStandardSelectionNames.SEL_LABEL
                                                  , ORPDocumentsStandardSelectionNames.SEL_LABEL_NEW);
      }
      
      /*###########################################################################
        # Add options for svc journal associated event type.
        # We do this AFTER setting the value so the selected value renders.
        ###########################################################################*/  
        
      ctrlServiceJournalAssociatedEventTypeID.AddSelection("Specialized Health Procedure", "5");
      ctrlServiceJournalAssociatedEventTypeID.AddSelection("Activities of Daily Living",   "6");
      
    }
  }
}
