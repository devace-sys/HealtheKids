using System;
using System.IO;
using System.IO.Compression;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Security.Cryptography;
using System.Web;
using System.Web.UI;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{

  /***************************************************************************
   * DataDrivenFormPageRequestContextCallback */
  /**
   * Delegate def
   ****************************************************************************/
       
  public delegate void DataDrivenFormPageHandlerCallback (   ref HttpContext      requestContext
                                                           , ref StringBuilder    requestContent
                                                           ,     ReturnSaveRecord rsr);
  
  /***************************************************************************
   * FormPageHandler */
  /**
   * Custom handler for data driven web forms
   * 
   ***************************************************************************/  

  public class DataDrivenFormPageHandler : IHttpHandler
  {

    /*###########################################################################
      # AppFramework and Spedmon objects
      ###########################################################################*/		
          
    protected   SqlConnection    dbConnUser;        // Connection to user database
    protected   SqlConnection    dbConnApp;         // Connection to application database
    protected   DetailsLog       log;               // Our logging object
    protected   RequestResponse  rd;                // Request/response data
    protected   UserInfo         uInfo;             // User info

    /*###########################################################################
      # Http parameter names and values
      ###########################################################################*/  

    public static string PARM_FORM_FORM_DEF_ID             = "ffdi";
    public static string PARM_FORM_PAGE_DEF_ID             = "fpdi";
    public static string PARM_FORM_REQ_UID                 = "frui";
    public static string PARM_FORM_REQ_UID_COPY            = "fruicpy";
    public static string PARM_FORM_REQ_COPY_START_PAGE_ID  = "frcspid";
    public static string PARM_FORM_REQ_PROC_MODE           = "frpm";
    public static string PARM_FORM_RESET                   = "frest";
    public static string PARM_FORM_GO_BACK                 = "fback";
    public static string PARM_FORM_SAVE_AND_PROCEED        = "fsave";         
    public static string REQ_PROC_MODE_GET                 = "g";    
    public static string REQ_PROC_MODE_SUB                 = "s";  
   
    /*###########################################################################
      # Class names 
      ###########################################################################*/  
           
    public static string MESSAGE                     = "message";
    public static string MESSAGE_DFLT                = "message-dflt";
    public static string MESSAGE_INFO                = "message-info";
    public static string MESSAGE_WARN                = "message-warn";
    public static string MESSAGE_CRIT                = "message-crit";

    /*###########################################################################
      # Standard element ids
      ###########################################################################*/  

    public static string PAGE_ID = "ddfp";
        
   /*###########################################################################
     # Third party CSS Links (all should be pre min)
     ###########################################################################*/  

    protected static string[] cssLinks = {  
        "css/jqui/jquery-ui.min.css"
      , "css/themes/south-street/south-street.min.css" 
      , "css/themes/south-street/jquery.mobile.icons.min.css"
      , "css/themes/south-street/jquery.mobile.structure-1.4.5.min.css"
    };

   /*###########################################################################
     # Third party JS Links (all should be pre min)
     ###########################################################################*/  

    protected static string[] jsLinks = {
        "js/jquery-1.11.1.min.js"
      , "js/jqui/jquery-ui.min.js"
      , "js/jquery.mobile-1.4.5.min.js"
    };

   /*###########################################################################
     # Vars
     ###########################################################################*/  

    protected   string           endPoint             = "";
    protected   string           exitURL              = "";
    protected   string           newURL               = "";
    protected   string           startOverURL         = "";
    protected   string           copyURL              = "";    

    protected   bool             formDefinitionIDIsPassed     = false;
    protected   bool             saveNewFormOnOpen            = false;
    protected   long             formDefinitionID             = 0; // Form definition id    
    protected   long             formPageDefinitionID         = 0;
    public      long             formInstanceID               = 0;
    protected   string[]         permittedRoles               = Constants.ROLE_ALL_PCAL_AND_CLIENT;
    protected   string           formRequestID                = "";
    protected   string           formRequestCopyID            = "";
    protected   string           formRequestEntityRefID1      = "";
    protected   string           formRequestEntityRefID2      = "";    
    protected   string           formRequestEntityRefID3      = "";
    protected   string           formRequestEntityRefID4      = "";
    protected   string           formRequestMode              = "";
    protected   string           uploadFolder                 = "";
    protected   string           formFormFormPageId           = "";
    protected   string           actionUrl                    = "";
    protected   string           pageTitle                    = "";
    protected   string           pageSubTitle                 = "";
    protected   string           title                        = "";
    protected   StringBuilder    sbPage;

   /*###########################################################################
     # Data driven form objects
     ###########################################################################*/  

    protected   DataDrivenForm                        f;      
    protected   DataDrivenFormPage                    fp;
    protected   List<DataDrivenFormPagePart>          fpps;
    protected   List<DataDrivenFormPagePartReqEntity> fppres;
    protected   DataDrivenFormRequestStatus           frs;


   /*###########################################################################
     # Delegates
     # Define these in constructor
     ###########################################################################*/                
   
   protected DataDrivenFormPageHandlerCallback beforeHandleRequest           = null;
   protected DataDrivenFormPageHandlerCallback afterHandleRequest            = null;
   
   protected DataDrivenFormPageHandlerCallback beforeHandleRequestPageType   = null;

   protected DataDrivenFormPageHandlerCallback afterSaveNewFormOnOpen        = null;
   protected DataDrivenFormPageHandlerCallback afterCopySubIntoNew           = null;
   
   protected DataDrivenFormPageHandlerCallback beforeNewRequest              = null;
   protected DataDrivenFormPageHandlerCallback afterNewRequest               = null;
   
   protected DataDrivenFormPageHandlerCallback beforeHandleRequestForm       = null;
   protected DataDrivenFormPageHandlerCallback afterHandleRequestForm        = null;
   
   protected DataDrivenFormPageHandlerCallback beforeHandleRequestNavigation = null;
   protected DataDrivenFormPageHandlerCallback afterHandleRequestNavigation  = null;
   
   protected DataDrivenFormPageHandlerCallback beforeHandleRequestNotice     = null;
   protected DataDrivenFormPageHandlerCallback afterHandleRequestNotice      = null;

   protected DataDrivenFormPageHandlerCallback beforeCompleteFormForm        = null;
   protected DataDrivenFormPageHandlerCallback afterCompleteFormForm         = null;
   
   /*###########################################################################
     # Constructor
     ###########################################################################*/  

   /***************************************************************************
    * DataDrivenFormPageHandler*/
   /**
    * @param    permittedRoles          Array of permitted roles
    * 
    *
    * This constructor is appropriate for "dependent" forms where the user
    * is taken to a form to fill out.
    * 
    * Handler will require the form definition id to be passed in as part of
    * the initial handler and this value will be passed in subsequence requests
    *
    * Also the initial open of the form page will save the form form submitted
    ***************************************************************************/   
         
    public DataDrivenFormPageHandler ( string[] permittedRoles ):this(true,0,true,permittedRoles)
    {           
    }
    
   /***************************************************************************
    * DataDrivenFormPageHandler*/
   /**
    * @parm     formdefinitionid        "Hardcoded" form definition id
    * @param    permittedRoles          Array of permitted roles
    * 
    * This constructor is appropriate for "stand alone" forms where the user
    * navigates directly to the end point from a menu or some other mechanism.
    * 
    * Form definition id passed on URL is ignored
    * 
    * Also the initial open of the form page will not save the form form until
    * the form on the page is submitted.  This is done to prevent creating
    * records that are never filled out.
    ***************************************************************************/   

    public DataDrivenFormPageHandler (   long     formdefinitionid
                                       , string[] permittedroles):this(false,formdefinitionid,false,permittedroles)
    {
    }
                                       
   /***************************************************************************
    * DataDrivenFormPageHandler*/
   /**
    * @parm     formdefinitionidpassed  Form definition id is passed in URL?
    * @parm     formdefinitionid        "Hardcoded" form definition id
    * @param    savenewformonopen       Form form is initially saved on the initial 
    *                                   page request
    * @param    permittedRoles          Array of permitted roles
    * 
    * Form definition id passed on URL is ignored
    ***************************************************************************/   

    public DataDrivenFormPageHandler (   bool     formdefinitionidpassed
                                       , long     formdefinitionid
                                       , bool     savenewformonopen
                                       , string[] permittedroles)
    {
          
      
      
      this.endPoint                  = MBA.HttpApplication.currentEndPointName();
      this.formDefinitionIDIsPassed  = formdefinitionidpassed;
      this.formDefinitionID          = formdefinitionid;
      this.saveNewFormOnOpen         = savenewformonopen;
      this.permittedRoles            = permittedroles;
      this.uploadFolder              = Constants.SEND_US_A_FILE_UPLOAD_PATH;
      this.sbPage                    = new StringBuilder();
    }    

    /*###########################################################################
      # Methods
      ###########################################################################*/		
         
    /***************************************************************************
     * getParameter */
    /**
     * Get given parameter starting first in the form, then in the query string
     * then in the entire collection.
     ***************************************************************************/       
     
    protected string _getParameter (ref HttpContext context, string parameterName)
    {
      /*###########################################################################
        # Look in form first for parameter
        ###########################################################################*/          
      
      string parameter = context.Request.Form[parameterName];

      /*###########################################################################
        # If it is not there check the query string
        ###########################################################################*/          
      
      if (String.IsNullOrEmpty(parameter))
      {
        parameter = context.Request.QueryString[parameterName];
        
        /*###########################################################################
          # If it is not there check the entire collection
          ###########################################################################*/          
        
        if (String.IsNullOrEmpty(parameter))
        {
          parameter = context.Request.Params[parameterName];
                   
         /*###########################################################################
           # If it is not there it must not exist
           ###########################################################################*/          
          
          if (String.IsNullOrEmpty(parameter))
          {
            parameter = "";
          }
        }

        /*###########################################################################
          # Clean up
          ###########################################################################*/          
        
        if (parameter == ",") parameter = "";
      }        
      
      return parameter;
    }         
      
    /***************************************************************************
     * _wasButtonNameUsed
    /**
     * Determine what submit button was used to submit form
     * 
     ***************************************************************************/        
     
    protected bool _wasButtonNameUsed (ref HttpContext context, string buttonName)
    {
      string buttonValue = _getParameter(ref context, buttonName);
      if (!String.IsNullOrEmpty(buttonValue)) return true;
      return false;
    }
     
    /***************************************************************************
     * getSubmittedPagePart */
    /**
     * Get given parameter starting first in the form, then in the query string
     * then in the entire collection.      
     ***************************************************************************/     
    
    protected DataDrivenFormPagePart _getSubmittedPagePart (ref HttpContext context, DataDrivenFormPagePart fppIn)
    {                     

      /*###########################################################################
        # Use in to init out
        ###########################################################################*/  
      
      DataDrivenFormPagePart fppOut = fppIn;

      /*###########################################################################
        # Get what was submitted
        ###########################################################################*/  

      string parmSelCountName        = DataDrivenFormPagePart.generateParmSelectedCount(fppIn.name);
      string parmSelNamesName        = DataDrivenFormPagePart.generateParmSelectedNames(fppIn.name);              
      string submittedValue          = _getParameter (ref context, fppIn.name);
      string submittedSelectedCount  = _getParameter (ref context, parmSelCountName);
      string submittedSelectedNames  = _getParameter (ref context, parmSelNamesName);     

      /*###########################################################################
        # If we are expecting a file replace submittedValue, submittedCount
        # submittedNames
        ###########################################################################*/                       
      
      if (fppIn.dataType == "file")
      { 
      
        List<string>         files         = new List<string>();  
        
        List<PostedFile> uploadedFiles = PostedFiles.getFilesPosted(context.Request.Files);

        submittedSelectedCount = uploadedFiles.Count.ToString();
        submittedSelectedNames = "";
        
        foreach (PostedFile uploadedFile in uploadedFiles){
          files.Add(uploadedFile.uploadedAs);
        }
        
        submittedSelectedNames = String.Join("|",files.ToArray());
        submittedValue         = String.Join(",",files.ToArray());        
      }
     
      /*###########################################################################
        # Pass back
        ###########################################################################*/  

      fppOut.value         = submittedValue;
      fppOut.selectedNames = submittedSelectedNames;
      fppOut.selectedCount = submittedSelectedCount;

      return fppOut;
    }

    /***************************************************************************
     * validateSubmittedPagePart */
    /**
     * Validate
     ***************************************************************************/   
         
    protected DataDrivenFormPagePart _validateSubmittedPagePart (ref HttpContext context, DataDrivenFormPagePart fppIn)
    {                     
      /*###########################################################################
        # Use in to init out
        ###########################################################################*/  
      
      DataDrivenFormPagePart fppOut = fppIn;

      /*###########################################################################
        # Init rest
        ###########################################################################*/  

      fppOut.valid = true;
      
      /*###########################################################################
        # Test for required if the value has been passed
        ###########################################################################*/    

      if ((fppIn.required == true) && (String.IsNullOrEmpty(fppIn.value)))
      {
        fppOut.partMessageClass = MESSAGE_WARN;
        fppOut.partMessageText  = "Required";
        fppOut.valid            = false;
        return fppOut;
      }

      string invalidMessage = @"Invalid";
      
      /*###########################################################################
        # Test for validity if the value has been passed
        ###########################################################################*/          

      if (!(String.IsNullOrEmpty(fppIn.value)))
      {         


        /*============================================================
         * File (check for file extension)
         *============================================================*/

        if (fppIn.dataType == "file")
        {
          string[] fileNames = fppIn.selectedNames.Split('|');
          fppOut.valid = true;

          foreach(string fileName in fileNames) {          
         
            string fileExt = String.Empty;
            fileExt = System.IO.Path.GetExtension(fileName);
            if (String.IsNullOrEmpty(fileExt)) {
              fppOut.valid   = false;
              invalidMessage = "The file is missing a file extension.  Please rename your file and add an extension to the end of the filename (ie .pdf).";            
              break;
            }
          }
        }

        /*============================================================
         * Number
         *============================================================*/

        if (fppIn.dataType == "number")
        {         
          Double result;
          invalidMessage = String.Format("{0} is an invalid number",fppIn.value);
          fppOut.valid = Double.TryParse(fppIn.value, out result);          
        }   
        
        /*============================================================
         * Date
         *============================================================*/
         
        else if (fppIn.dataType == "date")
        {
          DateTime result;
          invalidMessage = String.Format("{0} is an invalid date",fppIn.value);
          fppOut.valid = DateTime.TryParse( fppIn.value, out result);
        }
        
        /*============================================================
         * Bool
         *============================================================*/
         
        else if (fppIn.dataType == "bool")
        {
          bool? result = Util.evaluateFlag (fppIn.value, false);
          invalidMessage = String.Format("{0} is an invalid flag",fppIn.value);
          fppOut.valid = !result.HasValue;
        }       
                  
      }      
      
      /*###########################################################################
        # If its not valid
        ###########################################################################*/          

      if (!fppOut.valid)
      {
        fppOut.partMessageClass = MESSAGE_CRIT;
        fppOut.value = "";
        fppOut.partMessageText  = invalidMessage;
      }
      
      return fppOut;
    }
    
    /***************************************************************************
     * _generateActionURL */
    /**
     * Generate action url
     ***************************************************************************/      
    
    protected string _generateActionURL (string formpageid, string procmode)
    {      
      return _generateActionURL(formpageid, procmode, this.formDefinitionID, this.formRequestID);      
    }
    
    protected string _generateActionURL (string formpageid, string procmode, long formdefinitionid, string formrequestid)
    {
      return MBA.HttpApplication.createLink(   this.endPoint
                                             , true
                                             , new NameValue(PARM_FORM_FORM_DEF_ID,      formdefinitionid.ToString())
                                             , new NameValue(PARM_FORM_REQ_UID,          formrequestid)
                                             , new NameValue(PARM_FORM_PAGE_DEF_ID,      formpageid)
                                             , new NameValue(PARM_FORM_REQ_PROC_MODE,    procmode));
    
    }
   
   /***************************************************************************
    * _renderPageFormFieldContainerOpenAndLabel */
   /**
    * Render field container open and label
    ***************************************************************************/  

   protected string _renderPageFormFieldContainerOpenAndLabel (ref HttpContext context, DataDrivenFormPagePart fpp, int idx)
   {
     string inputId = fpp.id;
     return _renderPageFormFieldContainerOpenAndLabel (ref context, fpp, idx, inputId);
   }

   protected string _renderPageFormFieldContainerOpenAndLabel (ref HttpContext context, DataDrivenFormPagePart fpp, int idx, string inputId)
   {
     StringBuilder sb = new StringBuilder();

     if (String.IsNullOrEmpty(inputId)) inputId = fpp.id;
     
     string partMessage = "";
     string reqMessage  = "";

     if (fpp.required == true)
       reqMessage = @"<span title=""This is a required field"" class=""required-field"">*</span>";
     
     if (!String.IsNullOrEmpty(fpp.partMessageText))     
       partMessage = String.Format(@"<div class=""{0} {1}"">{2}</div>", MESSAGE, fpp.partMessageClass, fpp.partMessageText);
            
     sb.Append (@"<div class=""ui-field-contain data-driven-field-container"">");                
     sb.AppendFormat (@"<label for=""{0}"" class=""data-driven-field-label"">{1}{2}{3}</label>",inputId, reqMessage, fpp.label, partMessage);
     
     return sb.ToString();
   
   }
   
   /***************************************************************************
    * _renderPageFormInputField */
   /**
    * Render input based field
    ***************************************************************************/  

   protected string _renderPageFormInputField (ref HttpContext context, DataDrivenFormPagePart fpp, int idx, string type, string attributes)
   {
     StringBuilder sb = new StringBuilder(); 
        
     sb.AppendFormat (_renderPageFormFieldContainerOpenAndLabel(ref context, fpp, idx));
         
     sb.AppendFormat(@"<input id=""{0}"" name=""{1}"" value=""{2}"" placeholder=""{3}"" type=""{4}"" class=""{5}"" ",fpp.id, fpp.name, fpp.value, fpp.placeholder, type, fpp.partType);
     
     /*--------------------------------------
      * Optional attributes
      *-------------------------------------*/
     
     if (!String.IsNullOrEmpty(attributes)) sb.Append(attributes);
     if (fpp.multiple)                      sb.Append(@" multiple=""multiple""");
     if (fpp.required)                      sb.Append(@" required=""required""");     
     if (!String.IsNullOrEmpty(fpp.min))    sb.AppendFormat(@" min=""{0}""",  fpp.min);
     if (!String.IsNullOrEmpty(fpp.max))    sb.AppendFormat(@" max=""{0}""",  fpp.max);
     if (!String.IsNullOrEmpty(fpp.step))   sb.AppendFormat(@" step=""{0}""", fpp.step);
          
     /*--------------------------------------
      * Close tag
      *-------------------------------------*/

     sb.Append(@"/>");
     
     /*--------------------------------------
      * Close container
      *-------------------------------------*/

     sb.Append(@"</div>");
     
     /*--------------------------------------
      * Enhance if native HTML type not
      * supported
      *-------------------------------------*/

     sb.Append      (@"<script type=""text/javascript"">");
     sb.Append      (@"$( document ).ready(function() {{");
     sb.AppendFormat(@"enhanceFormPagePart('{0}','{1}');", fpp.id, fpp.partType);
     sb.AppendFormat(@"preventFormSubmitOnEnter('{0}',{1});", fpp.id, "true");
     sb.Append      (@"}})");
     sb.Append      (@"</script>");
                    
     return sb.ToString();
   }

   /***************************************************************************
    * _renderPageFormCheckBox */
   /**
    * Render text area based field
    ***************************************************************************/  

   protected string _renderPageFormCheckBox (ref HttpContext context, DataDrivenFormPagePart fpp, int idx)
   {
     
     StringBuilder sb = new StringBuilder(); 

     sb.AppendFormat (_renderPageFormFieldContainerOpenAndLabel(ref context, fpp, idx));
                    
     /*--------------------------------------
      * Open tag and standard atributes
      *-------------------------------------*/
      
     string required = "";
     string selected = "";
     
     if (fpp.required)  required = @"required=""required""";
     sb.AppendFormat(@"<select id=""{0}"" name=""{1}"" data-role=""flipswitch""{2}>", fpp.id, fpp.name, required);
     
     selected = "";
     if (fpp.value == "0") selected = @" selected=""selected""";
     sb.AppendFormat (@"<option value=""0""{0}>No</option>",selected);
     
     selected = "";
     if (fpp.value == "1") selected = @" selected=""selected""";
     sb.AppendFormat (@"<option value=""1""{0}>Yes</option>",selected);
     
     sb.Append(@"</select>");

     sb.Append(@"</div>");
     
     return sb.ToString();
   }
   
   /***************************************************************************
    * _renderPageFormYesNoNA */
   /**
    * Render radio buttons for Yes, No, and Does Not Apply
    ***************************************************************************/  

   protected string _renderPageFormYesNoNa (ref HttpContext context, DataDrivenFormPagePart fpp, int idx)
   {
     
     StringBuilder sb = new StringBuilder(); 
                          
     string required = "";
          
     if (fpp.required)  
       required = @"required=""required""";

     string optId1 = fpp.id + "-opt-1";
     string optId2 = fpp.id + "-opt-2";
     string optId3 = fpp.id + "-opt-3";
     
     string optLabel1  = "Yes";
     string optLabel2  = "No";
     string optLabel3  = "Does Not Apply";
     string optVal1    = "1";
     string optVal2    = "2";
     string optVal3    = "3";

     string optValChecked1 = "";
     string optValChecked2 = "";
     string optValChecked3 = "";
     
     string inputId = optId1;
     
     if (fpp.value == optVal1) {optValChecked1 = @" checked=""checked""";}
     if (fpp.value == optVal2) {optValChecked2 = @" checked=""checked""";}
     if (fpp.value == optVal3) {optValChecked3 = @" checked=""checked""";}         

     sb.Append (_renderPageFormFieldContainerOpenAndLabel(ref context, fpp, idx));

     sb.Append (@"<fieldset data-role=""controlgroup"">");

     sb.AppendFormat(@"<label for=""{0}"">{1}</label>",optId1,optLabel1);
     sb.AppendFormat(@"<input id=""{0}"" name=""{1}"" value=""{2}"" type=""radio""{3}{4}>",optId1,fpp.name,optVal1,required,optValChecked1);

     sb.AppendFormat(@"<label for=""{0}"">{1}</label>",optId2,optLabel2);
     sb.AppendFormat(@"<input id=""{0}"" name=""{1}"" value=""{2}"" type=""radio""{3}{4}>",optId2,fpp.name,optVal2,required,optValChecked2);
     
     sb.AppendFormat(@"<label for=""{0}"">{1}</label>",optId3,optLabel3);
     sb.AppendFormat(@"<input id=""{0}"" name=""{1}"" value=""{2}"" type=""radio""{3}{4}>",optId3,fpp.name,optVal3,required,optValChecked3);

     sb.Append (@"</fieldset>");     

     sb.Append(@"</div>");
     
     return sb.ToString();
   }
   

   /***************************************************************************
    * _renderPageFormNoteBox */
   /**
    * Render text area based field
    ***************************************************************************/  

   protected string _renderPageFormNoteBox (ref HttpContext context, DataDrivenFormPagePart fpp, int idx)
   {
     StringBuilder sb = new StringBuilder(); 

     sb.AppendFormat (_renderPageFormFieldContainerOpenAndLabel(ref context, fpp, idx));

     string attributes = "";    
     if (fpp.required) attributes = @" required=""required""";
     if (!String.IsNullOrEmpty(fpp.max)) attributes = attributes + @" maxlength=""" + fpp.max + @"""";
   
     sb.AppendFormat(@"<textarea id=""{0}"" name=""{1}"" placeholder=""{2}"" data-clear-btn=""true"" spellcheck=""true"" {3}>",fpp.id, fpp.name, fpp.placeholder, attributes);     
     sb.Append(fpp.value);
     sb.Append(@"</textarea>");
     sb.Append(@"</div>");
     
     return sb.ToString();
   }
   
   /***************************************************************************
    * _overrideValue */
   /**
    * 
    ***************************************************************************/ 
         
   protected bool _overrideValue (DataDrivenFormPagePart fpp, out string newValue)
   {
     bool overrideValue = false;
     newValue = fpp.value;
     
     if (fpp.selectReplaceValue == true)
     {       
       if ((fpp.selectReplaceWhoName == "@user-group") && (fpp.selectReplaceWhoValue == "@user-group-client") && (fpp.selectReplaceWithValue == "@user-client-id"))       
         if (uInfo.userGroup == Constants.USER_GROUP_CLIENT)
         {         
           newValue = this.uInfo.userClientIDStr;
           overrideValue = true;
         }
         
       if ((fpp.selectReplaceWhoName == "@user-role") && (fpp.selectReplaceWhoValue == "@user-role-practitioner") && (fpp.selectReplaceWithValue == "@user-prac-id"))       
         if (uInfo.userRoleLower == Constants.ROLE_LEA_PROVIDER)         
         {
           newValue = this.uInfo.userPracIDStr;       
           overrideValue = true;
         }
     } 
     
     return overrideValue;     
     
   }
   
   /***************************************************************************
    * _overrideSelectOrSearchBox*/
   /**
    * 
    ***************************************************************************/ 
    
   protected bool _overrideSelectOrSearchBox (ref HttpContext context, DataDrivenFormPagePart fpp, int idx, ref StringBuilder sb)
   {

     bool   overridePart = false;
     string newPart      = "";
     string newValue     = "";
    
     overridePart = _overrideValue(fpp, out newValue);
     
     if (overridePart == true)
     {
       newPart = String.Format(@"<input id=""{0}"" name=""{1}"" value=""{2}"" type=""hidden""/>",fpp.id, fpp.name, newValue);
       sb.Append(newPart);     
     }

     return overridePart;
     
   }
         
   /***************************************************************************
    * _renderPageFormSelectBox */
   /**
    * Render select value or search
    ***************************************************************************/  
       
   protected string _renderPageFormSelectBox (ref HttpContext context, DataDrivenFormPagePart fpp, int idx)
   {
     StringBuilder sb = new StringBuilder(); 
    
     /*###########################################################################
       # Override if neccessary and return
       ###########################################################################*/  

    if (_overrideSelectOrSearchBox (ref context, fpp, idx, ref sb)) return sb.ToString();
    
     
     /*###########################################################################
       # Get list of select options
       ###########################################################################*/  
      
     List<MBA.Selection> selectoptions = DataDrivenWebForms.viewFormPagePartSelectionsList(dbConnApp, log, uInfo,fpp.selectFrom, fpp.selectWhat,"1000","1","","","","","");
          
     /*###########################################################################
       # Determine select attributes
       ###########################################################################*/  
     
     string attributes = "";    
     if (fpp.required) attributes = @" required=""required""";
     if (fpp.multiple) attributes = attributes + @" multiple=""multiple""";
     
     /*###########################################################################
       # Render open container and label
       ###########################################################################*/  
    
     sb.AppendFormat (_renderPageFormFieldContainerOpenAndLabel(ref context, fpp, idx));
     
     
     /*###########################################################################
       # Determine if we include autoselect class
       ###########################################################################*/  

     string autoSelect = " data-driven-select-box-select-auto";
     if (fpp.selectAuto == false) autoSelect = "";
     
     /*###########################################################################
       # Render select itself
       ###########################################################################*/  
     
     sb.AppendFormat(@"<select id=""{0}"" name=""{1}"" class=""data-driven-select-box {2}"" data-native-menu=""false""{3}>" ,fpp.id, fpp.name, autoSelect, attributes);
            
     /*###########################################################################
       # Render select options and flag selected options
       ###########################################################################*/  

     string selectedAtr  = @" selected=""selected""";
     bool   hasSelected  = false;
     string selected     = "";
     string[] values     = fpp.value.Split(new String[]{","},StringSplitOptions.RemoveEmptyEntries);
     
     foreach (MBA.Selection selectoption in selectoptions)
     {
       selected = "";

       /*--------------------------------------
        * Determine if value is selected
        *-------------------------------------*/
        
       if (values != null)
       {
         foreach (string value in values)
         {
           if (selectoption.value == value)
           {
              selected    = selectedAtr;
              hasSelected = true;
              break;
           }
         }
       }
       
       /*--------------------------------------
        * Render option
        *-------------------------------------*/

       sb.AppendFormat(@"<option value=""{0}""{1}>{2}</option>",selectoption.value,selected,selectoption.name);
     }

     /*###########################################################################
       # Render placeholder option and set it to selected if no value was passed
       ###########################################################################*/  

     selected = "";     
     if (hasSelected == false) selected = selectedAtr;              
     sb.AppendFormat(@"<option value="""" data-placeholder=""true""{0}>{1}</option>",selected,fpp.placeholder);

     /*###########################################################################
       # Close select
       ###########################################################################*/  

     sb.Append (@"</select>");
     
    /*###########################################################################
      # Render close container
      ###########################################################################*/  

     sb.Append(@"</div>");

     /*###########################################################################
       # Render selected count and selected names hidden inputs
       ###########################################################################*/  

     string parmSelCountId     = DataDrivenFormPagePart.generateParmSelectedCount(fpp.id);
     string parmSelCountName   = DataDrivenFormPagePart.generateParmSelectedCount(fpp.name);
     string parmSelNamesId     = DataDrivenFormPagePart.generateParmSelectedNames(fpp.id);
     string parmSelNamesName   = DataDrivenFormPagePart.generateParmSelectedNames(fpp.name);

     sb.AppendFormat(@"<input data-enhance=""false"" id=""{0}"" name=""{1}"" value=""{2}"" type=""hidden""/>",parmSelCountId, parmSelCountName, fpp.selectedCount);
     sb.AppendFormat(@"<input data-enhance=""false"" id=""{0}"" name=""{1}"" value=""{2}"" type=""hidden""/>",parmSelNamesId, parmSelNamesName, fpp.selectedNames);
     
     /*###########################################################################
       # Render JS to keep these updated
       ###########################################################################*/  

     sb.Append (@"<script type=""text/javascript"">");     
     sb.Append (@"$(document).on ('pagecreate', function() {");     
     sb.AppendFormat (@"$('#{0}').on ('change', function() {{", fpp.id); 
     
     // Find all selected excluding data placeholder
     
     sb.Append (@"var selections = $(this).find('option:selected').not( ""[data-placeholder]"" );");    
     sb.Append (@"var strCount   = $(selections).length;");    
     
     // If the item count is > 0 remove placeholder
     sb.Append (@"if (strCount > 0) { $(this).find('[data-placeholder]').removeAttr('selected') }");
     
     sb.Append (@"var arrNames   = $(selections).map(function(idx,opt) { var n = $(opt).html(); return n; }).get();");
     sb.Append (@"var strNames   = arrNames.join('|');");    

     sb.AppendFormat (@"$('#{0}').val(strCount);",parmSelCountId);
     sb.AppendFormat (@"$('#{0}').val(strNames);",parmSelNamesId);   
         
     sb.Append(@"});");
     sb.Append(@"});");
     sb.Append(@"</script>");

     return sb.ToString();
   }
   
   /***************************************************************************
    * _renderPageFormSearchBox */
   /**
    * Render select value or search
    * Note: Label rendering, etc is handled by plugin
    ***************************************************************************/  

   protected string _renderPageFormSearchBox (ref HttpContext context, DataDrivenFormPagePart fpp, int idx)
   {
     StringBuilder sb = new StringBuilder(); 
     
     /*###########################################################################
       # Override if neccessary and return
       ###########################################################################*/  

     if (_overrideSelectOrSearchBox (ref context, fpp, idx, ref sb)) 
       return sb.ToString();
       
     /*###########################################################################
       # Generate ids and names
       ###########################################################################*/  

     string contID             = fpp.id    + "-search-container";          
     string parmSelCountId     = DataDrivenFormPagePart.generateParmSelectedCount(fpp.id);
     string parmSelCountName   = DataDrivenFormPagePart.generateParmSelectedCount(fpp.name);
     string parmSelNamesId     = DataDrivenFormPagePart.generateParmSelectedNames(fpp.id);
     string parmSelNamesName   = DataDrivenFormPagePart.generateParmSelectedNames(fpp.name);
          
     /*###########################################################################
       # Generate search url
       ###########################################################################*/  

     string searchUrl = MBA.HttpApplication.createLink(fpp.selectSourceURL,true);
               
     /*###########################################################################
       # Render required HTML to be enhanced into search
       ###########################################################################*/  

     sb.AppendFormat(@"<div id=""{0}"" class=""ui-field-contain""",contID);
     
     sb.Append      (@" data-role=""searchbox""");
     sb.AppendFormat(@" data-header-text=""{0}""",               fpp.label);
     sb.AppendFormat(@" data-search-input-label=""{0}""",        fpp.label);
     sb.AppendFormat(@" data-search-input-placeholder=""{0}""",  fpp.placeholder);
     sb.AppendFormat(@" data-search-url=""{0}""",                searchUrl);
     sb.AppendFormat(@" data-form-id=""{0}""",                   this.formFormFormPageId);   
     sb.AppendFormat(@" data-form-input-id=""{0}""",             fpp.id);
     sb.AppendFormat(@" data-form-input-sel-count-id=""{0}""",   parmSelCountId);
     sb.AppendFormat(@" data-form-input-sel-names-id=""{0}""",   parmSelNamesId);
     sb.AppendFormat(@" data-form-input-required=""{0}""",       Util.netBoolToJSBool(fpp.required));          
     sb.AppendFormat(@" data-select-multiple=""{0}""",           Util.netBoolToJSBool(fpp.multiple));
     sb.AppendFormat(@" data-search-auto=""{0}""",               Util.netBoolToJSBool(fpp.selectAuto));
     sb.AppendFormat(@" data-unselect-warning=""{0}""",          Util.netBoolToJSBool(false));
     
     if (!String.IsNullOrEmpty(fpp.min))sb.AppendFormat(@" data-select-min=""{0}""", fpp.min);
     if (!String.IsNullOrEmpty(fpp.max))sb.AppendFormat(@" data-select-max=""{0}""", fpp.max);
     
     sb.AppendFormat(@" data-search-select-from=""{0}""",       fpp.selectFrom);
     sb.AppendFormat(@" data-search-select-what=""{0}""",       fpp.selectWhat);
     sb.AppendFormat(@" data-search-req-ent-id1=""{0}""",       fpp.selectReqEntId1);
     sb.AppendFormat(@" data-search-req-ent-id2=""{0}""",       fpp.selectReqEntId2);
             
     if (!String.IsNullOrEmpty(fpp.partMessageText)) 
     {
       sb.AppendFormat(@" data-form-part-message=""{0}""",        fpp.partMessageText);
       sb.AppendFormat(@" data-form-part-message-class=""{0}""",  fpp.partMessageClass);
     }

     sb.Append      (@">");
        
     sb.AppendFormat(@"<input data-enhance=""false"" id=""{0}"" name=""{1}"" value=""{2}"" type=""hidden""/>",fpp.id, fpp.name, fpp.value);
     sb.AppendFormat(@"<input data-enhance=""false"" id=""{0}"" name=""{1}"" value=""{2}"" type=""hidden""/>",parmSelCountId, parmSelCountName, fpp.selectedCount);
     sb.AppendFormat(@"<input data-enhance=""false"" id=""{0}"" name=""{1}"" value=""{2}"" type=""hidden""/>",parmSelNamesId, parmSelNamesName, fpp.selectedNames);

     sb.Append      (@"</div>");
    
     return sb.ToString();
  }

         
   /***************************************************************************
    * _renderPageFormLinkOnly */
   /**
    * Render link only
    ***************************************************************************/  

   protected string _renderPageFormLinkOnly (ref HttpContext context, DataDrivenFormPagePart fpp)
   {
     StringBuilder sb = new StringBuilder();
     
     if      (fpp.value == "@new")  fpp.value = this.newURL;
     else if (fpp.value == "@copy") fpp.value = this.copyURL;
     else if (fpp.value == "@exit") fpp.value = this.exitURL;
     else                           fpp.value = MBA.HttpApplication.createLink(fpp.value,true);
     
     sb.AppendFormat(@"<a id=""{0}"" title=""{1}"" href=""{2}"" data-ajax=""false"" class=""ui-mini"">{3}</a>",fpp.id, fpp.placeholder, fpp.value, fpp.label);             
     return sb.ToString();
   }

  /***************************************************************************
   * _renderPageStart */
  /**
   * Renders start of page
   ***************************************************************************/  
 
  protected string _renderPageStart ()
  {

    StringBuilder sb = new StringBuilder();
    
   /*###########################################################################
     # Create page title
     ###########################################################################*/  
    
    this.title = String.Format("{0} - {1} - {2}", Constants.APP_TITLE , this.pageTitle, this.pageSubTitle);
    
   /*###########################################################################
     # Document
     ###########################################################################*/  

    sb.Append (@"<!DOCTYPE html>");
    sb.Append (@"<!-- Copyright (c) " + Messages.COPYRIGHT_DATE_ORG + @" -->");
    sb.Append (@"<html lang=""en"">");  

   /*###########################################################################
     # Head 
     ###########################################################################*/  

    sb.Append (@"<head>");
    
    /*============================================================
     * Meta and title
     *============================================================*/

    sb.Append (@"<meta charset=""utf-8"">");
    sb.Append (@"<meta name=""viewport"" content=""width=device-width, initial-scale=1"">");
    sb.AppendFormat (@"<title>{0}</title>", this.title);

    /*============================================================
     * CSS Links 
     *============================================================*/

     /*--------------------------------------
      * Third party - Already Minimized 
      *-------------------------------------*/

    foreach(string cssLink in cssLinks)
      sb.AppendFormat (@"<link rel=""stylesheet"" href=""{0}""/>",cssLink);

     /*--------------------------------------
      * Ours
      *-------------------------------------*/

     sb.Append(YuiCompressor.Generators.cssLink("themes/jquery.mobile-1.4.5-eaw.widgets"));
     sb.Append(YuiCompressor.Generators.cssLink("themes/data-driven-form-page"));
     sb.Append(YuiCompressor.Generators.cssLink("themes/data-driven-form-select"));
     
     
    /*============================================================
     * JS Links 
     *============================================================*/

     /*--------------------------------------
      * Third party - Already Minimized 
      *-------------------------------------*/

    foreach(string jsLink in jsLinks)
      sb.AppendFormat (@"<script type=""text/javascript"" src=""{0}""></script>",jsLink);

     /*--------------------------------------
      * Ours
      *-------------------------------------*/

     sb.Append(YuiCompressor.Generators.jsLink(""
                                               , "jquery.eaw.common"
                                               , "jquery.mobile-1.4.5-eaw.common"
                                               , "jquery.mobile-1.4.5-eaw.widgets"
                                               , "data-driven-form-page"
                                               , "data-driven-form-select"
                                               , "jquery-ui-date-picker-tweaks"                                 
                                               ));
                                                                                          
    sb.Append (@"</head>"); 

   /*###########################################################################
     # Body
     ###########################################################################*/  

    sb.Append (@"<body>");
        
    /*============================================================
     * Page open
     *============================================================*/
    
    sb.AppendFormat (@"<div id=""{0}"" data-role=""page"" data-title=""{1}"">", PAGE_ID, title); 
   
    return sb.ToString();
  }

  /***************************************************************************
   * _renderPageEnd */
  /**
   * Renders end of page
   ***************************************************************************/  

  protected string _renderPageEnd ()
  {
    StringBuilder sb = new StringBuilder();
 
    sb.Append(@"</div>");
    sb.Append(@"</body>");                           
    sb.Append(@"</html>");

    return sb.ToString();
  }
         
  /***************************************************************************
   * _renderPageHeader */
  /**
   * Renders standard header in a fixed position at the top
   ***************************************************************************/   

  protected string _renderPageHeader (ref HttpContext context)
  {
    StringBuilder sb = new StringBuilder();      
          
    sb.Append (@"<div data-role=""header"" data-position=""fixed"" data-tap-toggle=""true"">");
               
    /*###########################################################################
      # Render application notice if defined in its own block
      ###########################################################################*/  
  
     if (!String.IsNullOrEmpty(Constants.APP_NOTICE))
     {    
       sb.Append(@"<h6 class=""data-driven-form-app-notice"">");
       sb.Append(Constants.APP_NOTICE);
       sb.Append(@"</h6>");
     }   

    /*###########################################################################
      # Render form title and page title.  These should always be defined
      ###########################################################################*/  

    sb.AppendFormat (@"<h1 class=""data-driven-form-form-title"">{0}</h1>", this.f.formTitle);     
    sb.AppendFormat (@"<h2 class=""data-driven-form-page-title"">{0}</h2>", this.fp.pageTitle);
    
    /*###########################################################################
      # Render standard buttons
      ###########################################################################*/  

     /*============================================================
      * Render a close button in the top right.
      * If the form is set to open in a seperate window
      * clicking this button will close form (command is in url)
      * otherwise it will go home
      *============================================================*/
        
     sb.AppendFormat (@"<a class=""ui-btn-right"" href=""{0}"" data-icon=""delete"" data-iconpos=""notext"">Close</a>", this.exitURL);
                  
    sb.Append (@"</div>"); 
               
    return sb.ToString();      
  }
  
  /***************************************************************************
   * _renderFooter */
  /**
   * Renders standard footer in a fixed position at the bottom
   ***************************************************************************/  
   
  protected string _renderFooter (ref HttpContext context, string footerLeftContent, string footerCenterContent, string footerRightContent)
  {
    StringBuilder sb = new StringBuilder();    
         
    sb.Append (@"<div data-role=""footer"" data-position=""fixed"" data-tap-toggle=""true"">");    
    
    bool hasTopContent       = false;
    bool hasTopLeftContent   = false;
    bool hasTopCenterContent = false;
    bool hasTopRightContent  = false;
       
    if (!String.IsNullOrEmpty (footerLeftContent))   {hasTopLeftContent   = true; hasTopContent = true;}
    if (!String.IsNullOrEmpty (footerCenterContent)) {hasTopCenterContent = true; hasTopContent = true;}
    if (!String.IsNullOrEmpty (footerRightContent))  {hasTopRightContent  = true; hasTopContent = true;}
    
    /*###########################################################################
      # Render top content if it is defined
      ###########################################################################*/  
      
    if (hasTopContent)
    {
      
      sb.Append (@"<div class=""ui-grid-b"">");
        
      /*============================================================
       * Top Left
       *============================================================*/

      sb.Append (@"<div class=""ui-block-a"">");    
      if (hasTopLeftContent) sb.Append(footerLeftContent);  
      sb.Append (@"</div>");

      /*============================================================
       * Top Center
       *============================================================*/

      sb.Append (@"<div class=""ui-block-b"">");
      if (hasTopCenterContent) sb.Append(footerCenterContent);
      sb.Append (@"</div>");

      /*============================================================
       * Top Right
       *============================================================*/

      sb.Append (@"<div class=""ui-block-c"">");
      if (hasTopRightContent) sb.Append(footerRightContent);
      sb.Append (@"</div>");

      sb.Append(@"</div>"); /* ui-grid */
    }
    
    /*###########################################################################
      # Bottom Content
      ###########################################################################*/  

    sb.Append (@"<div class=""ui-grid-solo"">");    
    
    /*============================================================
     * Bottom all
     *============================================================*/

    sb.Append (@"<div class=""ui-block-a"">");   
    
    sb.AppendFormat (@"<p class=""footer footer-app-info"">Version {0} | {1}</p>"
    , Constants.APP_VERSION
    , Messages.COPYRIGHT);
    
    sb.AppendFormat (@"<p class=""footer footer-contact"">{0} | {1} | <a href=""mailto:{2}"" title=""Email us!"">{2}</a></p>"
    , Constants.APP_CONTACT.name
    , Constants.APP_CONTACT.mail
    , Constants.APP_CONTACT.email
    );
    
    sb.Append(@"</div>"); /* ui-block */
    sb.Append(@"</div>"); /* ui-grid */    
    sb.Append(@"</div>"); /* footer */

    return sb.ToString();
  }
  

  /***************************************************************************
   * _renderPageForm */
  /**
   * If page type is a form, render it
   ***************************************************************************/   

   protected string _renderPageForm (ref HttpContext context)
   {
    
     StringBuilder sb = new StringBuilder();      
     
     /*============================================================
      * Render header
      *============================================================*/ 
     
     sb.Append(_renderPageHeader(ref context));
     
     /*============================================================
      * Render start of content and start of form
      *============================================================*/

     sb.Append (@"<div role=""main"" class=""ui-content"">"); 
       
     /*============================================================
      * Render form instructions and page instructions if they exist
      *============================================================*/
   
     if (!String.IsNullOrEmpty(f.formInstructions))  sb.AppendFormat (@"<h3 class=""data-driven-form-form-instructions"">{0}</h3>", this.f.formInstructions);     
     if (!String.IsNullOrEmpty(fp.pageInstructions)) sb.AppendFormat (@"<h3 class=""data-driven-form-page-instructions"">{0}</h3>", this.fp.pageInstructions);
      
     /*============================================================
      * See if page has required fields
      *============================================================*/
     
     bool hasReqFields = false;
     bool hasFileBox   = false;
     
     int idx = 0;
   
     foreach(DataDrivenFormPagePart fpp in this.fpps)
     {         
       if (fpp.required)              hasReqFields = true;
       if (fpp.partType == "filebox") hasFileBox   = true;
       idx++;
     }
     
     /*============================================================
      * Render standard form instructions
      *============================================================*/
     
     string reqFieldsMessage = @"";
     
     if (hasReqFields) 
       reqFieldsMessage = @" If you see a <span class=""required-field"">*</span> in front of a question then an answer is required.";
     
     sb.AppendFormat(@"<h4 class=""data-driven-form-page-instructions-standard"">Please answer the question(s) and then click on Save & Proceed to continue.{0}</h4>",reqFieldsMessage);
        
     /*============================================================
      * Render form
      *============================================================*/
                          
     sb.AppendFormat (@"<form class=""data-driven-form-page-form"" id=""record"" method=""post"" action=""{0}"" data-ajax=""false"" novalidate=""novalidate"" enctype=""multipart/form-data"">", this.actionUrl);
       
     /*============================================================
      * Render form fields that are supported by this page type
      *============================================================*/
     
     idx = 0;
   
     foreach(DataDrivenFormPagePart fpp in this.fpps)
     {         
       if (fpp.partType == "textbox")       sb.Append ( _renderPageFormInputField (ref context, fpp, idx,  "text",   @" data-clear-btn=""true"""));
       if (fpp.partType == "numberbox")     sb.Append ( _renderPageFormInputField (ref context, fpp, idx,  "text",   @" data-clear-btn=""true""")); 
       if (fpp.partType == "numberslider")  sb.Append ( _renderPageFormInputField (ref context, fpp, idx,  "range",  @" data-highlight=""true"""));
       if (fpp.partType == "datebox")       sb.Append ( _renderPageFormInputField (ref context, fpp, idx,  "text",   @" data-clear-btn=""true""")); 
       if (fpp.partType == "checkbox")      sb.Append ( _renderPageFormCheckBox   (ref context, fpp, idx)); 
       if (fpp.partType == "urlbox")        sb.Append ( _renderPageFormInputField (ref context, fpp, idx,  "url",    @" data-clear-btn=""true""")); 
       if (fpp.partType == "emailbox")      sb.Append ( _renderPageFormInputField (ref context, fpp, idx,  "email",  @" data-clear-btn=""true""")); 
       if (fpp.partType == "phonebox")      sb.Append ( _renderPageFormInputField (ref context, fpp, idx,  "tel",    @" data-clear-btn=""true"""));  
       if (fpp.partType == "filebox")       sb.Append ( _renderPageFormInputField (ref context, fpp, idx,  "file",   @" data-clear-btn=""true"""));           
       if (fpp.partType == "notebox")       sb.Append ( _renderPageFormNoteBox    (ref context, fpp, idx));
       if (fpp.partType == "selectbox")     sb.Append ( _renderPageFormSelectBox  (ref context, fpp, idx));            
       if (fpp.partType == "searchbox")     sb.Append ( _renderPageFormSearchBox  (ref context, fpp, idx));
       if (fpp.partType == "yesnona"  )     sb.Append ( _renderPageFormYesNoNa    (ref context, fpp, idx));
                     
       idx++;
    
     }
     
     /*============================================================
      * Render required entity fields
      *============================================================*/

     foreach(DataDrivenFormPagePartReqEntity fppre in this.fppres)
     {
       sb.AppendFormat(@"<input id=""{0}"" name=""{1}"" value=""{2}"" type=""hidden""/>",fppre.id, fppre.name, fppre.value);
     }
     
     /*============================================================
      * Render special proceed instructions
      *============================================================*/
     
     if (hasFileBox)
     {
       sb.Append(@"<div class=""message message-info"">Please note that you are uploading a file when you click on Save and Proceed.  It may take some time to complete your request</div>");
     }
     
     /*============================================================
      * Render buttons and messages
      *============================================================*/
     
     sb.Append (@"<div class=""ui-grid-b data-driven-form-page-form-controls"">");
        
     /*============================================================
      * Exit, Start Over, and Go Back Buttons
      * Note: We are using tabindex=-1 to prevent focus using tabs
      *============================================================*/

     sb.Append (@"<div class=""ui-block-a"">");    
     sb.Append(@"<fieldset style=""text-align:left;"">");                    

     sb.AppendFormat (@"<a tabindex=""-1"" data-role=""confirmlink"" data-ajax=""false"" data-confirm-title=""Are you sure you wish to exit?"" data-confirm-text=""If you exit you will lose everything you have saved."" class=""ui-mini ui-btn ui-btn-inline ui-btn-icon-left ui-icon-delete"" href=""{0}"">Exit</a>", this.exitURL);
     sb.AppendFormat (@"<a tabindex=""-1"" data-role=""confirmlink"" data-ajax=""false"" data-confirm-title=""Are you sure you wish to start over?"" data-confirm-text=""If you start over you will lose everything you have saved."" class=""ui-mini ui-btn ui-btn-inline ui-btn-icon-left ui-icon-delete"" href=""{0}"">Start Over</a>", this.startOverURL);
     
     if (this.formPageDefinitionID != f.startFormPageID)     
       sb.AppendFormat (@"<button id=""{0}"" tabindex=""-1"" name=""{1}"" value=""Back"" type=""submit"" class=""ui-mini ui-btn ui-btn-inline ui-btn-icon-left ui-icon-arrow-l"" formnovalidate=""formnovalidate"">Go Back</button>", PARM_FORM_GO_BACK, PARM_FORM_GO_BACK);
     
     sb.Append (@"</fieldset>");
     sb.Append (@"</div>");

     /*============================================================
      * Page message
      *============================================================*/

     sb.Append (@"<div class=""ui-block-b"">");
      
     if (!String.IsNullOrEmpty(this.fp.pageMessageText)) 
       sb.AppendFormat (@"<div class=""message {0}"">{1}</div>", this.fp.pageMessageClass, this.fp.pageMessageText);
         
     sb.Append (@"</div>");

     /*============================================================
      * Submit
      *============================================================*/

     sb.Append (@"<div class=""ui-block-c"">");     
     sb.Append(@"<fieldset style=""text-align:right;"">");                    
     sb.AppendFormat (@"<button id=""{0}"" name=""{1}"" value=""Save"" type=""submit"" class=""ui-mini ui-btn ui-btn-inline ui-btn-icon-top ui-icon-arrow-r"">Save and Proceed</button>", PARM_FORM_SAVE_AND_PROCEED, PARM_FORM_SAVE_AND_PROCEED);
     sb.Append (@"</fieldset>");
     sb.Append (@"</div>");

     sb.Append(@"</div>"); /* ui-grid */
      
        
     /*============================================================
      * Render end of form and end of content (main)
      *============================================================*/
                
     sb.Append (@"</form>");
          
     sb.Append (@"<script type=""text/javascript"">");  
     sb.Append (@"$(function() {");
     sb.Append (@"$('form :input:visible:enabled:first').focus()");
     sb.Append (@"});");
     sb.Append (@"</script>");
     sb.Append (@"</div>"); 
     
    
    /*============================================================
     * Render footer
     * 
     * Note: We use labels associated with the hidden buttons in
     * the form to put "buttons" in our fixed footer.
     *============================================================*/
     
     sb.Append(_renderFooter(ref context,null, null, null));
     
     return sb.ToString();
    
    }

    /***************************************************************************
     * _renderPageNavigation */
    /**
     * If page type is a navigation page, render it
     ***************************************************************************/       
     
    protected string _renderPageNavigation(ref HttpContext context)
    {
      StringBuilder sb = new StringBuilder();

     /*============================================================
      * Render header and start of content
      *============================================================*/ 
     
     sb.Append(_renderPageHeader(ref context));     
     sb.Append (@"<div role=""main"" class=""ui-content"">");  

     /*============================================================
      * Render form instructions and page instructions if they exist
      *============================================================*/
   
     if (!String.IsNullOrEmpty(f.formInstructions))  sb.AppendFormat (@"<h3 class=""data-driven-form-form-instructions"">{0}</h3>", this.f.formInstructions);
     if (!String.IsNullOrEmpty(fp.pageInstructions)) sb.AppendFormat (@"<h3 class=""data-driven-form-page-instructions"">{0}</h3>", this.fp.pageInstructions);

     /*============================================================
      * Render start of list
      *============================================================*/

     sb.Append(@"<ul class=""data-driven-form-navigation-items"" data-role=""listview"" data-inset=""true"" data-ajax=""false"">");
     
     /*============================================================
      * Render form fields supported by this page type
      *============================================================*/

     foreach(DataDrivenFormPagePart fpp in this.fpps)
     {       
       if (fpp.partType == "link")
       {     
         sb.Append (@"<li>");
         sb.Append ( _renderPageFormLinkOnly(ref context,fpp));
         sb.Append (@"</li>");
       }
     }

     /*============================================================
      * Render end of list
      *============================================================*/

     sb.Append(@"</ul>");
     
     /*============================================================
      * Render end of content and footer
      *============================================================*/
     
     sb.Append(_renderFooter(ref context,"","",""));
      
     return sb.ToString();
    }
 
    /***************************************************************************
     * _renderPageNotice */
    /**
     * If page type is a notice page, render it
     ***************************************************************************/    
         
    protected string _renderPageNotice(ref HttpContext context)
    {
      StringBuilder sb = new StringBuilder();

      /*============================================================
       * Render form instructions and page instructions if they exist
       *============================================================*/
   
      if (!String.IsNullOrEmpty(f.formInstructions))  sb.AppendFormat (@"<h4 class=""data-driven-form-form-instructions"">{0}</h4>", this.f.formInstructions);
      if (!String.IsNullOrEmpty(fp.pageInstructions)) sb.AppendFormat (@"<h4 class=""data-driven-form-page-instructions"">{0}</h4>", this.fp.pageInstructions);

      return sb.ToString();
    }
    		                     		           

    /***************************************************************************
     * _handleRequestNavigation */
    /**
     * 
     ***************************************************************************/   

    protected int _handleRequestNavigation (ref HttpContext context, ref StringBuilder sbPageContent)
    {     
      /*###########################################################################
        # Getting form
        ###########################################################################*/    

      if (this.formRequestMode == REQ_PROC_MODE_GET)
      {
        sbPageContent.Append(_renderPageNavigation(ref context));
        return Return.RET_SUCCESS;   
      }
      
      return Return.RET_SUCCESS;   
    }
    
    /***************************************************************************
     * _handleRequestNotice */
    /**
     * 
     ***************************************************************************/   

    protected int _handleRequestNotice (ref HttpContext context, ref StringBuilder sbPageContent)
    {
      /*###########################################################################
        # Getting form
        ###########################################################################*/    

      if (this.formRequestMode == REQ_PROC_MODE_GET)
      {
        sbPageContent.Append(_renderPageNotice(ref context));
        return Return.RET_SUCCESS;   
      }
      
      return Return.RET_SUCCESS;
    }

    /***************************************************************************
     * _handleRequestForm */
    /**
     * 
     ***************************************************************************/   

    protected int _handleRequestForm (ref HttpContext context, ref StringBuilder sbPageContent)
    {
                
      /*###########################################################################
        # Getting form
        ###########################################################################*/    

      if (this.formRequestMode == REQ_PROC_MODE_GET)
      {       
        this.actionUrl  = _generateActionURL(this.formPageDefinitionID.ToString(),REQ_PROC_MODE_SUB);
        sbPageContent.Append(_renderPageForm (ref context));  
        return Return.RET_SUCCESS;
      }
      
      /*###########################################################################
        # Submitting form
        ###########################################################################*/    

      else if (this.formRequestMode == REQ_PROC_MODE_SUB)
      {
      
        /*============================================================
         * Save 
         *============================================================*/

        if (_wasButtonNameUsed(ref context, PARM_FORM_SAVE_AND_PROCEED))          
        {                               

          /*--------------------------------------
           * Get submitted values and perform
           * initial validation
           *-------------------------------------*/
           
          int idx          = 0;
          int invalidCount = 0;
                      
          foreach (DataDrivenFormPagePart fppSub in this.fpps)
          {

            DataDrivenFormPagePart fppVal = _getSubmittedPagePart(ref context, fppSub);
            DataDrivenFormPagePart fppOut = _validateSubmittedPagePart(ref context, fppVal);
            
            if (fppOut.valid == false) 
              invalidCount++;
              
            this.fpps[idx].value            = fppOut.value;
            this.fpps[idx].selectedCount    = fppOut.selectedCount;
            this.fpps[idx].selectedNames    = fppOut.selectedNames;
            this.fpps[idx].valid            = fppOut.valid;
            this.fpps[idx].partMessageClass = fppOut.partMessageClass;
            this.fpps[idx].partMessageText  = fppOut.partMessageText;              

            idx++;
          }

          /*--------------------------------------
           * If initial validation passed
           * proceed with save
           *-------------------------------------*/
        
          if (invalidCount == 0)
          {                      
            /*--------------------------------------
             * Save      
             *-------------------------------------*/

            DataDrivenWebForms.saveFormForm(dbConnApp, log, uInfo, this.formRequestID, this.formDefinitionID, ref context);
            DataDrivenWebForms.saveFormPage(dbConnApp, log, uInfo, this.formRequestID, this.formPageDefinitionID);            

            foreach (DataDrivenFormPagePart fpp in this.fpps)            
              DataDrivenWebForms.saveFormPagePart(dbConnApp, log, uInfo, this.formRequestID, fpp, this.uploadFolder, ref context);
                        
            /*--------------------------------------
             * Get status
             *-------------------------------------*/

            this.frs = DataDrivenWebForms.loadFormRequestStatus(dbConnApp, log, uInfo, this.formRequestID, this.formDefinitionID, this.formPageDefinitionID);

             /*--------------------------------------
              * No next page means form is complete
              * So redirect to last page
              *-------------------------------------*/

            if (this.frs.nextPageID == 0)
            {            
              ReturnSaveRecord rsr = new ReturnSaveRecord();              
              if (this.beforeCompleteFormForm != null) beforeCompleteFormForm (ref context, ref sbPageContent, null);              
              rsr = DataDrivenWebForms.completeFormForm(dbConnApp, log, uInfo, this.formRequestID, ref context);                            
              this.actionUrl = _generateActionURL(f.endFormPageID.ToString(),REQ_PROC_MODE_GET);              
              if (this.afterCompleteFormForm != null) afterCompleteFormForm(ref context,ref sbPageContent,rsr);              
              return Return.RET_REDIRECT;
            }

            /*--------------------------------------
             * Otherwise go to next page
             *-------------------------------------*/

            this.actionUrl = _generateActionURL(frs.nextPageID.ToString(),REQ_PROC_MODE_GET);
            
            return Return.RET_REDIRECT;

          }

          /*--------------------------------------
           * Otherwise let user known
           *-------------------------------------*/

          else
          {
            fp.pageMessageClass = MESSAGE_WARN;
            fp.pageMessageText  = "Please correct your entry and try again";
            this.actionUrl = _generateActionURL(this.formPageDefinitionID.ToString(),REQ_PROC_MODE_SUB);
            sbPageContent.Append(_renderPageForm (ref context));
            return Return.RET_SUCCESS;
          }
                    
       } /* Save */

       /*============================================================
        * Go back
        *============================================================*/  

       else if (_wasButtonNameUsed(ref context, PARM_FORM_GO_BACK)) 
       {         
         this.frs = DataDrivenWebForms.loadFormRequestStatus(dbConnApp, log, uInfo, this.formRequestID, this.formDefinitionID, this.formPageDefinitionID);         
         this.actionUrl = _generateActionURL(frs.prevPageID.ToString(),REQ_PROC_MODE_GET);
         // Call clear here
         return Return.RET_REDIRECT;    
      } /* Go back */
      
      else 
      {
        sbPageContent.Append(_renderPageForm (ref context));
        return Return.RET_SUCCESS;
      } /* Could be a refresh */
                                  
     }
     
     /*###########################################################################
       # Unknown mode
       ###########################################################################*/         

     else       
     {
       sbPageContent.Append(@"<h1>Unknown mode</h1>");
       return Return.RET_CRITICAL;
     }
     
     //return Return.RET_SUCCESS;
   }
    
   /***************************************************************************
    * _handleRequest */
   /**
    * Starting point
    ***************************************************************************/   
     
   protected Return _handleRequest (ref HttpContext context)
   {     
     Return rd = new Return();                                                                         
     StringBuilder sbPageContent = new StringBuilder();                                                        
     
     try
     {      
       
       /*###########################################################################
         # Call beforeHandleRequest if defined
         ###########################################################################*/  

       if (this.beforeHandleRequest != null) beforeHandleRequest (ref context, ref sbPageContent, null);
         
       /*###########################################################################
         # If the formdefinitionid is not passed we need to get it from the URL
         ###########################################################################*/  

        if (this.formDefinitionIDIsPassed == true)
        {
          this.formDefinitionID    = 0;        
          string      _fdiStr      = _getParameter (ref context, PARM_FORM_FORM_DEF_ID);
          this.formDefinitionID    = Validate.reqInteger(_fdiStr,@"Form definition ID is required");
        }

       /*###########################################################################
         # Get copy id if it exists
         ###########################################################################*/    
      
       this.formRequestCopyID = _getParameter(ref context, PARM_FORM_REQ_UID_COPY);

       /*###########################################################################
         # Test for request id.
         ###########################################################################*/       

       this.formRequestID = _getParameter(ref context, PARM_FORM_REQ_UID);
                                     
       /*###########################################################################
         # If none exists generate a new one, copy data from existing if neccessary
         # and then and redirect to first page
         ###########################################################################*/       

       if (String.IsNullOrEmpty(this.formRequestID))
       {
         /*============================================================
          * Generate new form request id call beforeNewRequest if it
          * is defined and determinee whether to create a new FormForm
          * from scratch or an existing record (copy)
          *============================================================*/

         this.formRequestID = Util.createUniqueID();                                                                   
         if (this.beforeNewRequest != null) beforeNewRequest(ref context, ref sbPageContent, null);         
         ReturnSaveRecord rsr = new ReturnSaveRecord();

         /*============================================================
          * Create new from existing and call afterCopySubIntoNew if
          * it is defined
          *============================================================*/
         
         if (!String.IsNullOrEmpty(formRequestCopyID))
         {         
           rsr = DataDrivenWebForms.copySubIntoNew(dbConnApp, log, uInfo, formRequestCopyID, this.formRequestID, ref context);                    
           if (this.afterCopySubIntoNew != null) afterCopySubIntoNew(ref context, ref sbPageContent, rsr);           
         }        
         
         /*============================================================
          * Create new and if desired initially save new and call after
          * afterSaveNewFormOnOpen if its defined
          *============================================================*/
         
         else
         {           
           if (saveNewFormOnOpen == true)
           {
             rsr = DataDrivenWebForms.saveFormForm(dbConnApp, log, uInfo, this.formRequestID, this.formDefinitionID, ref context);             
             if (this.afterSaveNewFormOnOpen != null) afterSaveNewFormOnOpen(ref context, ref sbPageContent, rsr);             
           }
         }
         
         this.f = DataDrivenWebForms.loadFormForm (dbConnApp, log, uInfo, this.formRequestID, this.formDefinitionID);                                    
         this.actionUrl = _generateActionURL (f.startFormPageID.ToString(),REQ_PROC_MODE_GET);                  
                  
         /*###########################################################################
           # Call afterNewRequest if defined
           ###########################################################################*/  

         if (this.afterNewRequest != null) afterNewRequest(ref context, ref sbPageContent, rsr);

         rd.status = Return.RET_REDIRECT;
         return rd;
       }
      
       /*###########################################################################
         # Get form request mode 
         ###########################################################################*/                         
                  
       this.formRequestMode = Validate.reqString ( _getParameter(ref context, PARM_FORM_REQ_PROC_MODE), @"Form request mode is required");

       /*###########################################################################
         # Get form definition again
         ###########################################################################*/                          

       this.f = DataDrivenWebForms.loadFormForm (dbConnApp, log, uInfo, this.formRequestID, this.formDefinitionID);
       if (this.f.formID == 0) throw new Warning("Form does not exist");

       /*###########################################################################
         # Define exit url
         ###########################################################################*/                         

       if (this.f.openInNewWindow)
         this.exitURL = "javascript:closeWindow();";
       else
         this.exitURL = MBA.HttpApplication.createLink(Constants.HOME_PRIVATE,true);
         
       /*###########################################################################
         # Define new url
         ###########################################################################*/                         
       
       this.newURL  = MBA.HttpApplication.createLink(this.endPoint, true);
       
       if (this.formDefinitionIDIsPassed == true)
       {
         this.newURL  = MBA.HttpApplication.createLink(this.endPoint, true, new NameValue(PARM_FORM_FORM_DEF_ID, this.formDefinitionID.ToString()));
       }

       /*###########################################################################
         # Define start over url
         ###########################################################################*/                         

       this.startOverURL = _generateActionURL (this.f.startFormPageID.ToString(),REQ_PROC_MODE_GET, this.f.formID, this.formRequestID);

       /*###########################################################################
         # Define copy url
         ###########################################################################*/                         

       this.copyURL = MBA.HttpApplication.createLink(this.endPoint, true, new NameValue(PARM_FORM_REQ_UID_COPY,this.formRequestID));

       /*###########################################################################
         # Get form page ID, form page, and form page parts
         ###########################################################################*/                         
       
       this.formPageDefinitionID = Validate.reqInteger ( _getParameter(ref context, PARM_FORM_PAGE_DEF_ID),   @"Page definition id required");

       this.fp = DataDrivenWebForms.loadFormPage (dbConnApp, log, uInfo, this.formRequestID, this.formDefinitionID, this.formPageDefinitionID);        
       if (this.fp.formPageID == 0) throw new Warning("Form page does not exist");

       this.fpps = DataDrivenWebForms.loadFormPageParts (dbConnApp, log, uInfo, this.formRequestID, this.formDefinitionID, this.formPageDefinitionID);        
       if (this.fpps.Count == 0) throw new Warning("Form page does not have any parts defined");         
                                                                
       this.fppres = DataDrivenWebForms.loadFormPagePartsReqEntities(dbConnApp, log, uInfo, this.formRequestID, this.formDefinitionID, this.formPageDefinitionID);
       
       /*###########################################################################
         # Generate urls and ids
         ###########################################################################*/  
                
       this.formFormFormPageId = String.Format("{0}-{1}-{2}",this.formDefinitionID, this.formPageDefinitionID, this.formRequestID);
       this.actionUrl          = _generateActionURL(this.formPageDefinitionID.ToString(),REQ_PROC_MODE_SUB);
              
       /*###########################################################################
         # Generate title
         ###########################################################################*/  
        
        this.pageTitle    = f.formTitle;
        this.pageSubTitle = fp.pageTitle;
        
       
        if (this.beforeHandleRequestPageType != null)
        {
          beforeHandleRequestPageType(ref context, ref sbPageContent, null);
        }
       
       /*###########################################################################
         # Handle requests for form page types
         ###########################################################################*/          
       
       rd.status = Return.RET_SUCCESS;

       if (this.fp.pageType == "form")       
       {
         if (this.beforeHandleRequestForm != null) beforeHandleRequestForm(ref context, ref sbPageContent, null);         
         rd.status = _handleRequestForm (ref context, ref sbPageContent);
         if (this.afterHandleRequestForm != null) afterHandleRequestForm(ref context, ref sbPageContent, null);

       }
       else if (this.fp.pageType == "navigation")
       {
         if (this.beforeHandleRequestNavigation != null) beforeHandleRequestNavigation(ref context, ref sbPageContent, null);
         rd.status = _handleRequestNavigation (ref context, ref sbPageContent);         
         if (this.afterHandleRequestNavigation != null) afterHandleRequestNavigation(ref context, ref sbPageContent, null);         
       }
       
       else if (this.fp.pageType == "notice") 
       {
         if (this.beforeHandleRequestNotice != null) beforeHandleRequestNotice(ref context, ref sbPageContent, null);
         rd.status = _handleRequestNotice (ref context, ref sbPageContent);         
         if (this.afterHandleRequestNotice != null) afterHandleRequestNotice(ref context, ref sbPageContent, null);
       }
       else  throw new Exception("Unknown page type");

      }

      catch (Exception e)
      {                       

        /*###########################################################################
          # An exception was thrown
          ###########################################################################*/

        /*============================================================
         * Clear page content
         *============================================================*/

        sbPageContent = null;
        sbPageContent = new StringBuilder();

        /*============================================================
         * Title
         *============================================================*/
       
        this.pageTitle    = @"An Unexpected Problem Has Occurred";
        this.pageSubTitle = e.Message;

        /*============================================================
         * Render page error
         *============================================================*/

        sbPageContent.Append(@"<h1>");
        sbPageContent.Append(@"Something Is Wrong With Our System");
        sbPageContent.Append(@"</h1>");
       
        sbPageContent.Append(@"<hr/>");

        sbPageContent.Append(@"<h2>");
        sbPageContent.Append(@"Problem");
        sbPageContent.Append(@"</h2>");

        sbPageContent.Append(@"<p>");
        sbPageContent.Append("We are sorry, the following unexpected problem has occurred with our system and we could not complete your request at this time.");
        sbPageContent.Append(@"</p>");

        sbPageContent.Append(@"<h3>");
        sbPageContent.Append(e.Message);
        sbPageContent.Append(@"</h3>");
       
        sbPageContent.Append(@"<hr/>");
       
        sbPageContent.Append(@"<h2>");
        sbPageContent.Append(@"Solution");
        sbPageContent.Append(@"</h2>");

        sbPageContent.Append(@"<ul>");
        sbPageContent.Append("<li>Our IT department has been notified and they will do their best to solve the problem on our end</li>");
        sbPageContent.Append("<li>Please close your browser and try again in a few minutes</li>");
        sbPageContent.Append("<li>If this problem persists please contact us</li>");
        sbPageContent.Append(@"</ul>");

        sbPageContent.Append(@"<hr/>");

        sbPageContent.Append(@"<p>" + Constants.APP_CONTACT.name + @" | " + Constants.APP_CONTACT.mail + @" | <a href=""mailto:" + Constants.APP_CONTACT.email + @""" title=""Email us!"">" + Constants.APP_CONTACT.email + @"</a></p>");
       
        
        rd.status = Return.RET_SUCCESS;
      }

      finally
      {		

        /*###########################################################################
          # Render our page with either the regular content or error content
          ###########################################################################*/
          
        sbPage.Append (_renderPageStart());        
        sbPage.Append ( sbPageContent.ToString() );       
        sbPage.Append (_renderPageEnd ());  

        if (this.afterHandleRequest != null) afterHandleRequest(ref context, ref sbPageContent, null);

      }

            
      return rd;
    }      
   
    /***************************************************************************
     * callMethod */
    /**
     * Wrapper for calling framework methods to generate Return
     * 
     * @param  cb              Method callback (use delegate) 
     * @param  permittedRoles  If this method should be private
     *                         supply all authorized roles
     * @return                 Object containing rt (need to cast)
     ***************************************************************************/

    protected Object callMethod(MethodCallback cb)
    {       
      return MBA.HttpApplication.callMethod(ref this.dbConnUser,ref this.dbConnApp,ref this.log, ref this.rd, ref this.uInfo, typeof(Return), cb, true, permittedRoles);
    }
   
     
    /*###########################################################################
      # Interface methods
      ###########################################################################*/		

    /***************************************************************************
     * IsReusable */
    /**
     * Indicates whether or not instances of this can be reused
     ***************************************************************************/  
 
    public bool IsReusable
    {
      get { return false; }
    }
		
    /***************************************************************************
     * ProcessRequest */
    /**
     * Entry point for the handler
     * 
     * @param    context    The request/response context
     ***************************************************************************/  
         
    public virtual void ProcessRequest (HttpContext context)
    {                                  
      
      /*###########################################################################
        # Delegae _handleRequest to process the rest.  We will use r.status
        # to determine what to do next.
        ###########################################################################*/       
      
      MethodCallback cb =  delegate() { return _handleRequest (ref context); };
      Return          r = (Return) callMethod(cb);

      /*###########################################################################
        # We need to redirect to another page
        ###########################################################################*/       

      if (r.status == Return.RET_REDIRECT)
      {
        context.Response.Redirect(this.actionUrl,true);
      }
      
      /*###########################################################################
        # Session expired.  Redirect to public home
        ###########################################################################*/       
       
      if (r.status == Return.RET_SESSION_EXPIRE) 
      {
        context.Response.Redirect(MBA.HttpApplication.createLink(Constants.HOME_PUBLIC),true);
      }
      
      /*###########################################################################
        # Not a success and not handled.  Redirect to error
        ###########################################################################*/       

      if (r.status != Return.RET_SUCCESS)
      {
        context.Response.Redirect(MBA.HttpApplication.createLink(@"error.aspx",false,new NameValue("msg",r.message)));      
      }

      /*###########################################################################
        # Otherwise it must be a success.  Return content
        ###########################################################################*/       

      /*============================================================
       * Get content bytes
       *============================================================*/
      
      byte[] resultBytes  = Encoding.UTF8.GetBytes (sbPage.ToString());
                  
      /*============================================================
       * Add our response type
       *===========================================================*/

      context.Response.ContentType = @"text/html";            
                     
      /*============================================================
       * Handle caching.  We dont want this cached.
       *============================================================*/
      
      context.Response.Cache.SetCacheability (HttpCacheability.NoCache);
            
      /*============================================================
       * Write out response
       *============================================================*/

      context.Response.BinaryWrite (resultBytes);
            
    }    
  }     
}


