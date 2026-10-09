using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MBA;

/***************************************************************************
 * request_file_upload_public */
/**
 * Public page for users to request an account
 ***************************************************************************/

namespace Spedmon
{


  public class request_file_upload_public : WebUiJqm
  {
    public request_file_upload_public() : base("Send Us A File"){}      
    
    /*###########################################################################
      # Constants for parameter names
      ###########################################################################*/  

    public const string PARM_REQUEST_ID       = "reqid";
    public const string PARM_REQUEST_TOKEN    = "reqtoken";
    public const string PARM_REQUEST_PART     = "reqpart";
    public const string PARM_REQUEST_MODE     = "reqmode";
    public const string PARM_REQUEST_MESSAGE  = "reqmsg";
    public const string PARM_COUNTY_CODE      = "countycode";
    public const string PARM_DISTRICT_CODE    = "districtcode";
    public const string PARM_FIRST_NAME       = "firstname";
    public const string PARM_LAST_NAME        = "lastname";
    public const string PARM_WORK_EMAIL       = "workemail";
    public const string PARM_FILE_CLASS       = "fileclass";
    public const string PARM_FILE_TYPE        = "filetype";
    public const string PARM_REF_DATE         = "refdate";
    public const string PARM_FILE_NAME        = "filename";
    public const string PARM_REQUEST_COMPLETE = "rcplt";
    public const string PARM_PROCEED          = "proceed";
    public const string PARM_GO_BACK          = "back";
    public const string PARM_CANCEL           = "cancel";
    
    /*###########################################################################
      # Constants for parameter values
      ###########################################################################*/  

    public const string REQUEST_PART_1           = "1";
    public const string REQUEST_PART_2           = "2";
    public const string REQUEST_PART_3           = "3";
    public const string REQUEST_PART_4           = "4";
    public const string REQUEST_PART_5           = "5";
    public const string REQUEST_PART_6           = "6";  
    public const string REQUEST_PART_7           = "7";  
      
    public const string REQUEST_MODE_GET         = "g";    
    public const string REQUEST_MODE_SUB         = "s";        

    public const string FILE_CLASS_WORK_BATCH    = "1";
    public const string FILE_CLASS_STUDENT_DATA  = "2";
    
    /*###########################################################################
      # Other constants
      ###########################################################################*/  
    
    public    const string BASE_URL              = @"request_file_upload_public.aspx";
    protected const string OPTION_PLACE_HOLDER   = @"<option value="""" disabled=""disabled"" selected="""" data-placeholder=""true"">Select one</option>";
    protected const int    request_part_min_val  = 1;
    protected const int    request_part_max_val  = 7;
    
    /*###########################################################################
      # Variables to hold parameter values
      ###########################################################################*/  

    public string request_id         = "";
    public string request_token      = "";
    public string request_mode       = "";
    public string request_message    = "";
    public string request_part       = "";    
    public string county_code        = "";
    public string district_code      = "";
    public string last_name          = "";
    public string first_name         = "";
    public string work_email         = "";
    public string file_class         = "";
    public string file_type          = "";
    public string ref_date           = "";
    public string request_complete   = "";
    
    /*###########################################################################
      # Variables to hold form variables
      ###########################################################################*/ 

    public string get_url            = "";
    public string post_url           = "";
    public string another_file_url   = "";
    public string home_url           = "";
    public string captcha_url        = "";
    public string COUNTY_OPTIONS     = "";
    public string DISTRICT_OPTIONS   = "";
    public string FILE_CLASS_OPTIONS      = "";
    public string FILE_TYPE_OPTIONS        = "";
    public string request_date_yyyy_mm_dd  = "";
    
    /*###########################################################################
      # Variables to hold page data
      ###########################################################################*/ 

    public bool   request_complete_val       = false;

    /*###########################################################################
      # Variables to hold request/response state and control
      ###########################################################################*/ 

    protected string       request_part_next      = "";
    protected bool         needToRedirect         = false;
    protected int          request_part_val       = 0;
    protected int          request_part_next_val  = 0;            
    protected CaptchaImage captchaImage = null;

    /*###########################################################################
      # Variables to hold requesting user data
      ###########################################################################*/ 

    protected string   request_user_agent       = "";
    protected string   request_ip               = "";
    protected DateTime request_datetime         = DateTime.Now;        
    
    /*###########################################################################
      # Variables to hold options lists
      ###########################################################################*/ 
    
    protected List<CdeRecordCounty>   rlCounties;    
    protected List<CdeRecordDistrict> rlDistricts;   
    protected List<UploadFileClass>   rlFileClasses; 
    protected List<UploadFileType>    rlFileTypes;   
     
    /***************************************************************************
     * getParameter */
    /**
     * Get given parameter starting first in the form, then in the query string
     * then in the entire collection.
     * 
     * Note: We use this to preserve the value of paramters between requests
     * using the form and the query string.
     ***************************************************************************/     
    
    protected string getParameter(string parameterName)
    {
      /* Look in form first for parameter */
      
      string parameter = Context.Request.Form[parameterName];

      /* If its not there look in query string*/

      if (String.IsNullOrEmpty(parameter))
      {
        parameter = Context.Request.QueryString[parameterName];
        
        /* If its not there look at entire collection */
        
        if (String.IsNullOrEmpty(parameter))
        {
          parameter = Context.Request.Params[parameterName];
          
          /* If its not there then it must not exist */
          
          if (String.IsNullOrEmpty(parameter))
          {
            parameter = "";
          }
        }
        if (parameter == ",") parameter = "";
      }        
      
      return parameter;
    }
    
    /***************************************************************************
     * getParameters */
    /**
     * Get parameters 
     ***************************************************************************/

    protected void getParameters()
    {      
      request_id       = getParameter(PARM_REQUEST_ID);                  
      request_token    = getParameter(PARM_REQUEST_TOKEN);                  
      request_mode     = getParameter(PARM_REQUEST_MODE);   
      request_message  = getParameter(PARM_REQUEST_MESSAGE);   
      request_part     = getParameter(PARM_REQUEST_PART);
      county_code      = getParameter(PARM_COUNTY_CODE);
      district_code    = getParameter(PARM_DISTRICT_CODE);     
      first_name       = getParameter(PARM_FIRST_NAME);
      last_name        = getParameter(PARM_LAST_NAME);    
      work_email       = getParameter(PARM_WORK_EMAIL);
      file_class       = getParameter(PARM_FILE_CLASS); 
      file_type        = getParameter(PARM_FILE_TYPE); 
      ref_date         = getParameter(PARM_REF_DATE);
      request_complete = getParameter(PARM_REQUEST_COMPLETE);
      
      request_datetime   = DateTime.Now;      
      request_date_yyyy_mm_dd = String.Format("{0:yyyy-MM-dd}",request_datetime);
      request_ip         = Context.Request.UserHostAddress;
      request_user_agent = Context.Request.UserAgent;
    }

    /***************************************************************************
     * validateParameters */
    /**
     * Checks for valid parameters
     ***************************************************************************/
     
    protected bool validateParameters()
    {
      
      if (request_mode == REQUEST_MODE_SUB)
      {
        try
        {
          int file_class_val  = 0;
          Object ref_date_val = null;
                    
          if (request_part == REQUEST_PART_2) {
            county_code    = MBA.Validate.reqString  (county_code, @"County is required");
          }
          
          if (request_part == REQUEST_PART_3) {
            district_code  = MBA.Validate.reqString  (district_code, @"Local education agency is required");
          }
          
          if (request_part == REQUEST_PART_4) {
            first_name     = MBA.Validate.reqString  (first_name,    @"First name is required");
            last_name      = MBA.Validate.reqString  (last_name,     @"Last name is required");
            work_email     = MBA.Validate.reqEmail   (work_email,    @"Valid work email required");
          }
          
          if (request_part == REQUEST_PART_5) {          
            file_class_val = MBA.Validate.reqInteger (file_class, @"What information is in the file is required");
          }  
          
          if (request_part == REQUEST_PART_6) {
            if (file_class == FILE_CLASS_WORK_BATCH)
            {
              file_type      = MBA.Validate.reqString  (file_type,     @"Type of practitioner is required");
              ref_date_val   = MBA.Validate.reqDate    (ref_date,      @"Oldest date of service required and future dates are not allowed", Constants.VAL_OPT_DATE_NO_FUTURE);
            }
            else if (file_class == FILE_CLASS_STUDENT_DATA)
            {
              file_type      = MBA.Validate.reqString  (file_type,     @"Who or what is in this file required");
              ref_date_val   = MBA.Validate.optDate    (ref_date,      @"Valid date required");
            }
          }
          
          if (request_part == REQUEST_PART_7) 
          {
            int validFileCount = PostedFiles.getFilesPosted(Context.Request.Files).Count;
            
            if (validFileCount == 0) throw new Critical(@"A file or a non empty file is required");
          }
          request_message = "";
        }
        catch(Exception err)
        {          
          request_message   = err.Message;
          request_part_next = request_part;
          needToRedirect    = true;   
          return false;
        }
      }
      return true;
    }
    
    /***************************************************************************
     * removeRequest */
    /**
     * Removes request captcha
     ***************************************************************************/
    
    protected void removeRequest(string requestId)
    { 
      if (!String.IsNullOrEmpty(requestId))
      {
         HttpRuntime.Cache.Remove(requestId);
      }
    }

    /***************************************************************************
     * addRequest */
    /**
     * Adds request captcha
     ***************************************************************************/
        
    protected void addRequest(string requestId)
    {
      if (!String.IsNullOrEmpty(requestId))
      {
        captchaImage = new CaptchaImage();
        
        //TODO : See if we really need to use this tougher settings
        //captchaImage.TextLength = Util.RandomNumber(5,6);
        //captchaImage.TextChars  = Util.randomString(100);
        
        HttpRuntime.Cache.Add(  requestId
                               ,captchaImage
                               ,null
                               ,DateTime.Now.AddHours(2)
                               ,System.Web.Caching.Cache.NoSlidingExpiration
                               ,System.Web.Caching.CacheItemPriority.Default
                               ,null);   
      }
    }

    /***************************************************************************
     * resetRequest */
    /**
     * Resets request
     ***************************************************************************/

    protected void resetRequest(string oldRequestId, string newRequestId)
    {
      removeRequest (oldRequestId);
      addRequest    (newRequestId);             
           
      request_id        = newRequestId;
      request_token     = "";
      request_mode      = REQUEST_MODE_GET;
      request_part      = REQUEST_PART_1;       
      request_part_next = REQUEST_PART_1;
      needToRedirect    = true;     
    }
         
    /***************************************************************************
     * checkRequestID */
    /**
     * Check for request id
     ***************************************************************************/

    protected bool checkRequestId()
    {

      if (String.IsNullOrEmpty(request_id))
      {
        resetRequest(request_id, Util.createUniqueID());        
        return false;
      }
      else
      {        
        captchaImage = (CaptchaImage) HttpRuntime.Cache.Get(request_id);

        if (captchaImage == null)
        {
          resetRequest(request_id, "");        
          return false;
        }         
        
        /* Exception for first part get*/
        
        if ((request_part == REQUEST_PART_1) && (request_mode == REQUEST_MODE_GET)) return true;
        
                
        /* If captcha failed generate a new one */
                
        if (captchaImage.Text != request_token)
        {
            /* Exception for first part post */

            if ((request_part == REQUEST_PART_1) && (request_mode == REQUEST_MODE_SUB)) {
              request_message = @"Your answer was blank or incorrect";
            }
            resetRequest(request_id, "");        
            return false;
        }
                                                                           
      }
      return true;
    }

    /***************************************************************************
     * checkAndGetRequestCompleteValue */
    /**
     * Check request compelete value passed in and set a variable that holds an
     * boolean rep of it.
     ***************************************************************************/

    protected void checkAndGetRequestCompleteValue()
    {
      request_complete_val = false;
      bool.TryParse(request_complete, out request_complete_val);      
    }
    
    /***************************************************************************
     * checkAndGetRequestPartValue */
    /**
     * Check request part value passed in and set a variable that holds an
     * integer rep of it
     ***************************************************************************/

    protected bool checkAndGetRequestPartValue()
    {
      request_part_val = 0;
      if (Int32.TryParse(request_part,out request_part_val))
        if ((request_part_val >= request_part_min_val) && (request_part_val <= request_part_max_val)) return true;               
      return false;
    }
    
    /***************************************************************************
     * computeNextRequestPartValueAndSet */
    /**
     * Compute the next request part value and set its string rep
     ***************************************************************************/

    protected void computeNextRequestPartValueAndSet()
    {
      request_part_next_val = 0;
      request_part_next_val = request_part_val + 1;
      if (request_part_next_val > request_part_max_val) request_part_next_val = request_part_max_val;
      request_part_next = request_part_next_val.ToString();      
    }
    
        
    /***************************************************************************
     * generateGetPostUrls */
    /**
     * Generate get and post urls for page redirection and form submit
     ***************************************************************************/    
    
    protected void generateGetPostUrls()
    {

      get_url = MBA.HttpApplication.createLink (   BASE_URL
                                                 , new NameValue(PARM_REQUEST_ID,       request_id)
                                                 , new NameValue(PARM_REQUEST_TOKEN,    request_token)  
                                                 , new NameValue(PARM_REQUEST_PART,     request_part_next)
                                                 , new NameValue(PARM_REQUEST_MODE,     REQUEST_MODE_GET)
                                                 , new NameValue(PARM_COUNTY_CODE,      county_code)
                                                 , new NameValue(PARM_DISTRICT_CODE,    district_code)
                                                 , new NameValue(PARM_FIRST_NAME,       first_name)
                                                 , new NameValue(PARM_LAST_NAME,        last_name)
                                                 , new NameValue(PARM_WORK_EMAIL,       work_email)
                                                 , new NameValue(PARM_FILE_CLASS,       file_class)
                                                 , new NameValue(PARM_FILE_TYPE,        file_type)
                                                 , new NameValue(PARM_REF_DATE,         ref_date)
                                                 , new NameValue(PARM_REQUEST_COMPLETE, request_complete)
                                                 , new NameValue(PARM_REQUEST_MESSAGE,  request_message)
                                                 );

  
      post_url = MBA.HttpApplication.createLink (  BASE_URL
                                                  , new NameValue(PARM_REQUEST_ID,     request_id)                                                    
                                                  , new NameValue(PARM_REQUEST_TOKEN,  request_token)  
                                                  , new NameValue(PARM_REQUEST_PART,   request_part)
                                                  , new NameValue(PARM_REQUEST_MODE,   REQUEST_MODE_SUB)
                                                  , new NameValue(PARM_COUNTY_CODE,    county_code)
                                                  , new NameValue(PARM_DISTRICT_CODE,  district_code)
                                                  , new NameValue(PARM_FIRST_NAME,     first_name)
                                                  , new NameValue(PARM_LAST_NAME,      last_name)
                                                  , new NameValue(PARM_WORK_EMAIL,     work_email)
                                                  , new NameValue(PARM_FILE_CLASS,     file_class)
                                                  , new NameValue(PARM_FILE_TYPE,      file_type)
                                                  , new NameValue(PARM_REF_DATE,       ref_date)
                                                  , new NameValue(PARM_REQUEST_COMPLETE, request_complete)
                                                  );     
    }

    /***************************************************************************
     * generateAnotherFileUrl */
    /**
     * Generate a url that will preserve some of the info already entered and
     * starts the user off at the appropriate step
     ***************************************************************************/    

    protected void generateAnotherFileUrl()
    {
      another_file_url = MBA.HttpApplication.createLink (   BASE_URL
                                                          , new NameValue(PARM_REQUEST_ID,       request_id)
                                                          , new NameValue(PARM_REQUEST_TOKEN,    request_token)
                                                          , new NameValue(PARM_REQUEST_PART,     REQUEST_PART_5)
                                                          , new NameValue(PARM_REQUEST_MODE,     REQUEST_MODE_GET)
                                                          , new NameValue(PARM_COUNTY_CODE,      county_code)
                                                          , new NameValue(PARM_DISTRICT_CODE,    district_code)
                                                          , new NameValue(PARM_FIRST_NAME,       first_name)
                                                          , new NameValue(PARM_LAST_NAME,        last_name)
                                                          , new NameValue(PARM_WORK_EMAIL,       work_email)
                                                          , new NameValue(PARM_FILE_CLASS,       file_class)
                                                          , new NameValue(PARM_FILE_TYPE,        file_type)
                                                          , new NameValue(PARM_REF_DATE,         ref_date)
                                                          , new NameValue(PARM_REQUEST_COMPLETE, "False")
                                                 );
    }
    
    /***************************************************************************
     * checkRequestMode */
    /**
     *
     ***************************************************************************/
     
    protected void checkRequestMode()
    {
      if (needToRedirect == true) return;
      if (request_mode == REQUEST_MODE_GET) needToRedirect = false;
      if (request_mode == REQUEST_MODE_SUB) needToRedirect = true;
    }


    /***************************************************************************
     * generateLists
    /**
     *
     ***************************************************************************/    
   
    protected void generateLists()
    {
      if (request_part == REQUEST_PART_2) rlCounties    = Spedmon.CdeRecords.viewCountiesList(dbConnApp,log,uInfo,null,null);
      if (request_part == REQUEST_PART_3) rlDistricts   = Spedmon.CdeRecords.viewDistrictsList(dbConnApp,log,uInfo,county_code,null,null);
      if (request_part == REQUEST_PART_5) rlFileClasses = Spedmon.FileUploads.viewUploadFileClassesList(dbConnApp,log,uInfo,"1",null,null);
      if (request_part == REQUEST_PART_6) rlFileTypes   = Spedmon.FileUploads.viewUploadFileTypesList(dbConnApp, log, uInfo,"1",null,file_class,null);
    }

    /***************************************************************************
     * generateCountyOptions
    /**
     *
     ***************************************************************************/    
    
    protected void generateCountyOptions()
    {    
      COUNTY_OPTIONS = OPTION_PLACE_HOLDER;
      
      foreach(CdeRecordCounty r in rlCounties)
      {
        string selected = "";
        if (r.CountyCode == county_code) selected = @"selected=""selected""";
        COUNTY_OPTIONS = COUNTY_OPTIONS + @"<option " + selected + @" value=""" + r.CountyCode +@""">" + r.CountyName + @"</option>";
      }
    }
    
    /***************************************************************************
     * generateDistrictOptions
    /**
     *
     ***************************************************************************/    

    public void generateDistrictOptions()
    {
      DISTRICT_OPTIONS = OPTION_PLACE_HOLDER;

      foreach(CdeRecordDistrict r in rlDistricts)
      {
        string selected = "";
        if (r.DistrictCode == district_code) selected = @"selected=""selected""";
        DISTRICT_OPTIONS = DISTRICT_OPTIONS + @"<option " + selected + @" value=""" + r.DistrictCode +@""">" + r.DistrictName + @"</option>";
      }
    }
    
    /***************************************************************************
     * generateFileClassOptions
    /**
     *
     ***************************************************************************/    

    protected void generateFileClassOptions()
    {
      FILE_CLASS_OPTIONS = OPTION_PLACE_HOLDER;
      foreach(UploadFileClass r in rlFileClasses)
      {
        string selected = "";
        string fcv      = r.fileClassValue.ToString();
        if (fcv == file_class) selected = @"selected=""selected""";
        FILE_CLASS_OPTIONS = FILE_CLASS_OPTIONS + @"<option " + selected + @" value=""" + fcv +@""">" + r.fileClassName + @"</option>";
      }
    }

    /***************************************************************************
     * generateFileTypeOptions
    /**
     *
     ***************************************************************************/    
    
    protected void generateFileTypeOptions()
    {
      FILE_TYPE_OPTIONS = OPTION_PLACE_HOLDER;
      foreach(UploadFileType r in rlFileTypes)
      {
        string selected = "";
        string ftv      = r.fileTypeValue;
        if (ftv == file_type) selected = @"selected=""selected""";

        FILE_TYPE_OPTIONS = FILE_TYPE_OPTIONS + @"<option " + selected + @" value=""" + ftv +@""">" + r.fileTypeName + @"</option>";
      }
    }
    
    /***************************************************************************
     * generateOptions
    /**
     * Generate select/options strings
     ***************************************************************************/   

    protected void generateOptions()
    {
      if (request_part == REQUEST_PART_2) generateCountyOptions();
      if (request_part == REQUEST_PART_3) generateDistrictOptions();
      if (request_part == REQUEST_PART_5) generateFileClassOptions();
      if (request_part == REQUEST_PART_6) generateFileTypeOptions();
    }
    
    /***************************************************************************
     * ProcessRequest
    /**
     *
     ***************************************************************************/    

    protected void processRequest()
    {
      needToRedirect = false;
      home_url       = MBA.HttpApplication.createLink(MBA.Constants.HOME_PUBLIC);
            
      getParameters();
      
      if (!checkRequestId()) 
      {
        generateGetPostUrls();
        return;
      }
      
      
      captcha_url = MBA.CaptchaImage.generateImgUrl(request_id);
      
      checkAndGetRequestCompleteValue();        
      checkAndGetRequestPartValue();
      computeNextRequestPartValueAndSet();
      checkRequestMode();
      generateLists();
      generateOptions();
      
      if (!validateParameters())
      {
        generateGetPostUrls();
        return;
      }

      /*============================================================
       * If the user has submitted the final part, save
       *============================================================*/
      
      if ((request_part == REQUEST_PART_7) && (request_mode == REQUEST_MODE_SUB))
      {
                
        /*============================================================
         * Save file
         *============================================================*/

        List<PostedFile> lf = MBA.PostedFiles.saveFilesPosted(Context.Request.Files,Constants.SEND_US_A_FILE_UPLOAD_PATH);

        /*============================================================
         * Save record
         *============================================================*/

        int fileCtr  = 0;
        int maxFiles = 1;
        
        foreach (PostedFile f in lf)
        {          
          Spedmon.FileUploads.saveFileUploadRequest(dbConnApp,log, uInfo, true, false, request_id, request_token, request_ip, request_user_agent, request_datetime, county_code, district_code, first_name, last_name, work_email, file_class, file_type, ref_date, f.uploadedAs, f.savedAs, f.savedIn, 1, f.fileSize, f.mimeType);
          fileCtr++;
          if (fileCtr >= maxFiles) break;
        }
        
        request_complete_val = true;
        request_complete = request_complete_val.ToString(); 
      }

      if (request_complete_val == true)
      {
        generateAnotherFileUrl();
      }

      generateGetPostUrls();
              
    }
        
    /***************************************************************************
     * Page_Load
    /**
     *
     ***************************************************************************/
                  
    protected void Page_Load(object sender, EventArgs e)
    {    

      /* Take users to smartsheet*/
      Response.Redirect(Constants.REQUEST_FILE_UPLOAD_PUBLIC, false);Context.ApplicationInstance.CompleteRequest();

      processRequest();
      if (needToRedirect)
      {
        Response.Redirect(get_url, false);
        Context.ApplicationInstance.CompleteRequest();
      }  
         
                                  
    }
  }
}
