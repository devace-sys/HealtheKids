using System;
using System.Collections.Generic;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.IO;

// JSON Serialization 

using System.Web.Script.Services;
using System.Web.Script.Serialization;

namespace MBA
{

/***************************************************************************
 * WebReportDocument */
/**
 * Provides a web handler that generates JSON, HTML, Excel, or PDF file
 * from ReturnDataTable.
 * 
 * NOTE: THIS IS THE MOST COMMONLY USED HANDLER THAT PROVIDES THIS FUNCTIONALITY
 * 
 * @param  IsReusable       Can this be resused by .NET (required by interface contract)
 * @param  rptData          Report document data
 * @param  permittedRoles   For call (framework) method
 * @param  reportData       Report data
 * @param  reportForm       Report format
 ***************************************************************************/

public abstract class WebReportDocument : IHttpHandler
{
      
  /*-------------------------------
   * Database connection, request
   * response, and logging objects
   * Used by call method for
   * invoking framework methods
   *------------------------------*/

  protected   SqlConnection    dbConnUser;  // Connection to user database
  protected   SqlConnection    dbConnApp;   // Connection to application database
  protected   DetailsLog       log;         // Our logging object
  protected   RequestResponse  rd;          // Request/response data
  protected   UserInfo         uInfo;       // User info
  
  protected string startDate;
  protected string endDate;
  protected string createdOrModifiedOn;
  protected string dateRange;
  protected string entryDateRange;
  protected string recID;
  protected string completed;
  
  /*-------------------------------
   * Properties
   *------------------------------*/

  protected string[]         _permittedRoles;              // Who can access this
  protected ReturnDataTable  _reportData;                  // Data for report
  protected bool             _reportColsOnly;              // Retrieve column list
  protected string           _reportEditView;              // null or blank = everything, 0 = non editable records, 1 = editable records only (validated by framework)
  protected bool             _reportPaging;                // Page output?
  protected int              _reportStartRow;              // Start row (convert to page number)
  protected string           _reportPageNumber;            // What page (this is validated by framework method)?
  protected int              _reportForm;                  // Output format
  protected int              _reportNumber;                // Optional report number
  protected string           _reportRequestUid;            // Client generated uid for tracking report downloads  
  protected int              _sEcho;                       // Required draw count for data tables
  protected MethodCallback   _cbReportData;                // Delegate to retrieve data
  protected string           _lastName;                    // Entity last name
  protected string           _firstName;                   // Entity first name
  protected string           _name;                        // Entities name
  protected string           _active;                      // Entity is active
  
 /*-------------------------------
  * Commonly used report
  * parameters
  * 
  * Note: We perform data validation
  * as part of the property set.
  *------------------------------*/

  public    bool             IsReusable          {get {return false;}} 
  public    string           reportColsOnly      {get {return _reportColsOnly.ToString();}    set {_reportColsOnly   = Validate.reqFlag (value,Messages.INVALID_REPT_COL_ONLY);}}
  public    MethodCallback   cbReportData        {get {return _cbReportData;}                 set {_cbReportData     = value;}}
  public    string[]         permittedRoles      {get {return _permittedRoles;}               set {_permittedRoles   = value;}}
  public    ReturnDataTable  reportData          {get {return _reportData;}                   set {_reportData       = value;}}  
  public    string           reportEditView      {get {return _reportEditView;}               set {_reportEditView   = value;}} 
  public    string           reportForm          {get {return _reportForm.ToString();}        set {_reportForm       = Validate.reqInteger (value,Messages.INVALID_REPT_FORM);}}
  public    string           reportPaging        {get {return _reportPaging.ToString();}      set {_reportPaging     = Validate.reqFlag    (value,Messages.INVALID_REPT_PAGE_FLG);}}
  public    string           reportNumber        {get {return _reportNumber.ToString();}      set {_reportNumber     = (int) Validate.optInteger(value,Messages.INVALID_REPT_NUMBER);}}
  public    string           reportRequestUid    {get {return _reportRequestUid; }            set {Validate.optGuid (value,Messages.INVALID_REPT_REQ_UID); _reportRequestUid = value;} }
  public    string           sEcho               {get {return _sEcho.ToString();}             set {_sEcho            = Validate.reqInteger(value,Messages.INVALID_S_ECHO,true);}}
  public    string           reportStartRow      {get {return _reportStartRow.ToString();}    set {_reportStartRow   = Validate.reqInteger(value,Messages.INVALID_PAGE_NUMBER,true);}}
  public    string           reportPageNumber    {get {return _reportPageNumber.ToString();}  set {_reportPageNumber = value;}}
  public    string           lastName            {get {return _lastName;}                     set {_lastName         = value;}}
  public    string           firstName           {get {return _firstName;}                    set {_firstName        = value;}}
  public    string           name                {get {return _name;}                         set {_name             = value;}}
  public    string           active              {get {return _active;}                       set {_active           = value;}} 
  
  /***************************************************************************
   * WebReportDocument */
  /**
   * Constructor
   * 
   * @param  rptData         Report document data
   * @param  rptForm         Format of report document
   ***************************************************************************/       

  public WebReportDocument()
  {
    
    /*-------------------------------
     * We do not have the report data
     * yet.  Assuming this is part of
     * a http request, fetch our
     * standard report parameters.
     * Our decsendants constructor will
     * do the rest
     *------------------------------*/
    
    this.reportForm     = HttpApplication.getParameter(Constants.PARM_REP_FORM);
    
    // Fetch paging parms only if we are not generating a preview

    if (_reportForm == Constants.REPT_FORMAT_PREVIEW)
    {
      this.reportColsOnly   = HttpApplication.getParameter(Constants.PARM_REP_COLS_ONLY);
      this.reportPaging     = HttpApplication.getParameter(Constants.PARM_REP_PAGING);

      if (!_reportColsOnly)
      {
        this.sEcho            = HttpApplication.getParameter(Constants.PARM_REP_S_ECHO);
        this.reportStartRow   = HttpApplication.getParameter(Constants.PARM_REP_START_ROW);
        this.reportPageNumber = Util.calculatePageNumber(_reportStartRow,Rules.VIEW_TBL_PAGE_SIZE).ToString();
      }
      else
      {
        _reportStartRow   = 0;
         this.reportPageNumber = Util.calculatePageNumber(_reportStartRow,Rules.VIEW_TBL_PAGE_SIZE).ToString();
        _sEcho = 1;
      }
    }
    else
    {
      // We have to set the report page # to 1 to support new paging system
      this.reportPageNumber = "1";
    }
    
    this.reportNumber        = HttpApplication.getParameter(Constants.PARM_REP_NUMBER);    
    this.startDate           = HttpApplication.getParameter(Constants.PARM_START_DATE);
    this.endDate             = HttpApplication.getParameter(Constants.PARM_END_DATE);
    this.createdOrModifiedOn = HttpApplication.getParameter(Constants.PARM_CREATED_OR_MODIFIED_ON); 
    this.dateRange           = HttpApplication.getParameter(Constants.PARM_DATE_RANGE);
    this.entryDateRange      = HttpApplication.getParameter(Constants.PARM_ENTRY_DATE_RANGE);
    this.recID               = HttpApplication.getParameter(Constants.PARM_REC_ID);
    this.reportEditView      = HttpApplication.getParameter(Constants.PARM_REP_EDIT_VIEW);    
    this.lastName            = HttpApplication.getParameter(Constants.PARM_LNAME);
    this.firstName           = HttpApplication.getParameter(Constants.PARM_FNAME);
    this.name                = HttpApplication.getParameter(Constants.PARM_NAME);
    this.active              = HttpApplication.getParameter(Constants.PARM_ACTIVE);    
	this.completed           = HttpApplication.getParameter(Constants.PARM_COMPLETED);
    this.reportRequestUid    = HttpApplication.getParameter(Constants.PARM_REP_REQUEST_UID);

  }

  public WebReportDocument(ReturnDataTable rptData, int rptForm)
  {
    
    /*-------------------------------
     * We have the report data and
     * the format we want it in
     * go ahead and generate the 
     * document
     *------------------------------*/

    this._reportForm = rptForm;
    this._reportData = rptData;
  }
   
  protected void setGeneratedFileDownloadReadyCookie(HttpContext context, string value)
  {
    if (String.IsNullOrWhiteSpace(_reportRequestUid)) return; /* For backwards compatibility */
    context.Response.SetCookie(HttpApplication.createGeneratedFileDownloadReadyCookie(_reportRequestUid, value));
  }

  protected void noRecordsResponse(HttpContext context)
  {
    context.Response.Clear();
    context.Response.ContentType = "text/html";
    context.Response.Charset     = "utf-8";
    context.Response.Write("<html><head><title>No Records</title></head><body>No records</body></html>");
    setGeneratedFileDownloadReadyCookie(context, @"norecords");
    context.Response.End();
  }

  protected void tooManyRowsResponse (HttpContext context, string message)
  {
    context.Response.Clear();
    context.Response.ContentType = "text/html";
    context.Response.Charset     = "utf-8";
    context.Response.Write("<!doctype html><html><head><title>Too Many Rows</title></head><body>" + message + @"</body></html>");
    setGeneratedFileDownloadReadyCookie(context, @"tomanyrows");    
    context.Response.End();
  }
  
   /***************************************************************************
    * callMethod */
    /**
    * Wrapper for calling framework methods to generate ReturnDataTable
    * 
    * @param  cb              Method callback (use delegate) 
    * @param  permittedRoles  If this method should be private
    *                         supply all authorized roles
    * @return                 Object containing rt (need to cast)
    ***************************************************************************/
       
  protected Object callMethod(MethodCallback cb)
  {
    return HttpApplication.callMethod(ref this.dbConnUser,ref this.dbConnApp,ref this.log, ref this.rd, ref this.uInfo, typeof(ReturnDataTable), cb);
  }
    
  protected Object callMethod(MethodCallback cb, params string[] permittedRoles)
  {      
    return HttpApplication.callMethod(ref this.dbConnUser,ref this.dbConnApp,ref this.log,ref this.rd,ref this.uInfo, typeof(ReturnDataTable), cb, true, permittedRoles);
  }   
    
  /***************************************************************************
   * ProcessRequest */
  /**
   * Required method to fulfill interface contract.
   * This method does the actual work.
   * 
   * @param  context         Current http request/response
   ***************************************************************************/       

  public void ProcessRequest(HttpContext context)
  {
    
    /*-------------------------------
     * If report data is not provided
     * see if there is a method 
     * provided to generate it
     *------------------------------*/

    if (_reportData == null)
    {

     /*-------------------------------
      * Determine if this is a public
      * or private report and call the 
      * appropriate method wrapper
      *------------------------------*/

      if (_permittedRoles == null)
        _reportData = (ReturnDataTable) callMethod(_cbReportData);
      else
        _reportData = (ReturnDataTable) callMethod(_cbReportData,_permittedRoles);
    }
    
    /*-------------------------------
     * If its still null get out
     *------------------------------*/

    if (_reportData == null) throw new MBA.Critical("Report data is required");
    context.Response.Clear();
    
    /*-------------------------------
     * Pass back challenge/response
     * type of parameters
     *------------------------------*/
    
    _reportData.sEcho = _sEcho;

    /*-------------------------------
     * Determine document form
     * default is HTML
     *------------------------------*/
 
    switch(_reportForm)
    {
      case Constants.REPT_FORMAT_PREVIEW:
      case Constants.REPT_FORMAT_JSON:
      {
       /*-------------------------------
        * Serialize the reportData
        * object into JSON
        * Note: Processing for no records
        * is handled on the client so 
        * we pass the object back as is
        *------------------------------*/

        context.Response.ContentType = "application/json";
        context.Response.Charset     = "utf-8";
        context.Response.AppendHeader("content-disposition", "attachment;filename=\"report.json\"");
        JavaScriptSerializer ser     = new JavaScriptSerializer();
        string               json    = ser.Serialize(reportData);
        context.Response.Write(json);
        context.Response.End();
        break;
      }
      
      case Constants.REPT_FORMAT_XLS:
      {
       
       /*-------------------------------
        * Handle no rows and too many
        * rows
        *------------------------------*/
        
        if (!_reportData.hasRecords) noRecordsResponse(context);
       
        /*-------------------------------
         * Generate file bytes
         *------------------------------*/
        
        Byte[] fileBytes = Excel2.returnDataTableToFile (ref _reportData);
        
        /*-------------------------------
         * Create response header
         *------------------------------*/
        
        string tname       = _reportData.tableName;        
        string fname       = Excel2.generateFileName(tname);        
        string contType    = @"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
        
        /*-------------------------------
         * If we are using a template and
         * the template is Excel 2003
         * override the filename and
         * content types we just 
         * specified
         *------------------------------*/
        
        if ( (_reportData.useTemplates) && (_reportData.excelTemplate.templateFileIsXLS()) ) 
        {
            fname    = File2.GenerateFileName(tname,@"xls");
            contType = @"application/vnd.ms-excel";
        }                                           
        
        /*-------------------------------
         * Generate and send response
         *------------------------------*/

        context.Response.ContentType = contType;        
        context.Response.AppendHeader("content-disposition", "attachment;filename=\"" + fname + "\"");
        context.Response.SetCookie(HttpApplication.createFileDownloadCookie()); // Required for filedownload plugin
        setGeneratedFileDownloadReadyCookie(context, fname);
        context.Response.BinaryWrite(fileBytes);
        context.Response.End();
        break;
        
      }
              
      case Constants.REPT_FORMAT_PDF:
      {
        /*-------------------------------
         * Handle no rows 
         *------------------------------*/
        
        if (!_reportData.hasRecords) noRecordsResponse(context);
        
        /*-------------------------------
         * Create response header
         *------------------------------*/

        string tname = _reportData.tableName;
        string fname = PDF.GenerateFileName(tname);

        context.Response.ContentType = "application/pdf";
        context.Response.AppendHeader("content-disposition", "attachment;filename=\"" + fname + "\"");
        context.Response.SetCookie(HttpApplication.createFileDownloadCookie()); // Required for filedownload plugin
        setGeneratedFileDownloadReadyCookie(context, fname);
                        
        /*-------------------------------
         * Output view
         *------------------------------*/
      
        context.Response.BinaryWrite(PDF.ReturnDataTableToPDF(ref _reportData));
        context.Response.End();
        break;
      
      }
      case Constants.REPT_FORMAT_CSV:
      {
        /*-------------------------------
         * Handle no rows and too many
         * rows
         *------------------------------*/
        
        if (!_reportData.hasRecords) noRecordsResponse(context);
       
        /*-------------------------------
         * Generate file bytes
         *------------------------------*/
        
        Byte[] fileBytes = CSV.returnDataTableToFile (ref _reportData);
        
        /*-------------------------------
         * Create response header
         *------------------------------*/
        
        string tname       = _reportData.tableName;        
        string fname       = CSV.generateFileName(tname);        
        string contType    = @"text/csv";
        
        /*-------------------------------
         * Generate and send response
         *------------------------------*/

        context.Response.ContentType = contType;        
        context.Response.AppendHeader("content-disposition", "attachment;filename=\"" + fname + "\"");
        context.Response.SetCookie(HttpApplication.createFileDownloadCookie()); // Required for filedownload plugin
        setGeneratedFileDownloadReadyCookie(context, fname);
        context.Response.BinaryWrite(fileBytes);
        context.Response.End();
        break;
      }
     
      case Constants.REPT_FORMAT_PSV:
      {
        /*-------------------------------
         * Handle no rows and too many
         * rows
         *------------------------------*/
        
        if (!_reportData.hasRecords) noRecordsResponse(context);
       
        /*-------------------------------
         * Generate file bytes
         *------------------------------*/
        
        Byte[] fileBytes = PSV.returnDataTableToFile (ref _reportData);
        
        /*-------------------------------
         * Create response header
         *------------------------------*/
        
        string tname       = _reportData.tableName;        
        string fname       = PSV.generateFileName(tname);        
        string contType    = @"text/plain";
        
        /*-------------------------------
         * Generate and send response
         *------------------------------*/

        context.Response.ContentType = contType;        
        context.Response.AppendHeader("content-disposition", "attachment;filename=\"" + fname + "\"");
        context.Response.SetCookie(HttpApplication.createFileDownloadCookie()); // Required for filedownload plugin
        setGeneratedFileDownloadReadyCookie(context, fname);
        context.Response.BinaryWrite(fileBytes);
        context.Response.End();
        break;
      }

      case Constants.REPT_FORMAT_FIXED:
      {
        /*-------------------------------
         * Handle no rows and too many
         * rows
         *------------------------------*/
        
        if (!_reportData.hasRecords) noRecordsResponse(context);
       
        /*-------------------------------
         * Generate file bytes
         *------------------------------*/
        
        Byte[] fileBytes = FixedWidth.returnDataTableToFile (ref _reportData);
        
        /*-------------------------------
         * Create response header
         *------------------------------*/
        
        string tname       = _reportData.tableName;        
        string fname       = PSV.generateFileName(tname);        
        string contType    = @"text/plain";
        
        /*-------------------------------
         * Generate and send response
         *------------------------------*/

        context.Response.ContentType = contType;        
        context.Response.AppendHeader("content-disposition", "attachment;filename=\"" + fname + "\"");
        context.Response.SetCookie(HttpApplication.createFileDownloadCookie()); // Required for filedownload plugin
        setGeneratedFileDownloadReadyCookie(context, fname);
        context.Response.BinaryWrite(fileBytes);
        context.Response.End();
        break;
      }

      case Constants.REPT_FORMAT_HTML:
      default:
      {
       
       /*-------------------------------
        * Handle no rows and too many
        * rows
        *------------------------------*/
       
        if (!_reportData.hasRecords) noRecordsResponse(context); 

        /*-------------------------------
         * Create response header
         *------------------------------*/

        context.Response.ContentType = "text/html";
        context.Response.Charset     = "utf-8";
        
        /*-------------------------------
         * Output view
         *------------------------------*/
      
        //context.Response.BinaryWrite(HTML.ReturnDataTableToHTMLFile(ref _reportData));
        context.Response.BinaryWrite(HTML2.ReturnDataTableToHTML(ref _reportData));
        context.Response.End();
        break;
      }     		
    }
  }
 }
}
