using System;
using System.Collections.Generic;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using MBA.Reporting;

namespace MBA
{

/***************************************************************************
 * WebDataDocument */
/**
 * Provides a web handler that generates various documents from a ReturnRptData
 * instance.
 * 
 * NOTE: THIS IS A ONLY USED FOR FINANCIAL REPORTS THAT RETURN HIERARCHIAL DATA
 * 
 * @param  IsReusable       Can this be resused by .NET (required by interface contract)
 * @param  reportData       Document data in a ReturnDB instance
 * @param  permittedRoles   For call (framework) method
 * @param  reportForm       Document format
 ***************************************************************************/

public abstract class WebDataDocument : IHttpHandler
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
  protected string dateRange;
  protected string entryDateRange;
  protected string recID;

  /*-------------------------------
   * Properties
   *------------------------------*/

  protected string[]         _permittedRoles;              // Who can access this
  protected ReturnRptData    _reportData;                  // Data for view

  protected int              _reportForm;                  // Output format
  protected int              _reportNumber;                // Report number (used to identify data source)
  protected string           _reportRequestUid;            // Client generated uid for tracking report downloads  
  protected MethodCallback   _cbReportData;                // Delegate to retrieve data
  protected string           _lastName;                    // Entity last name
  protected string           _firstName;                   // Entity first name
  protected string           _name;                        // Entities name
  protected string           _active;                      // Entity is active

 /*-------------------------------
  * Commonly used report
  * parameters
  *------------------------------*/

  public    bool             IsReusable          {get {return false;}} 
  public    MethodCallback   cbReportData        {get {return _cbReportData;}                 set {_cbReportData     = value;}}
  public    string[]         permittedRoles      {get {return _permittedRoles;}               set {_permittedRoles   = value;}}
  public    ReturnRptData    reportData          {get {return _reportData;}                   set {_reportData       = value;}}  

  public    string           reportForm          {get {return _reportForm.ToString();}        set {_reportForm       = Validate.reqInteger (value,Messages.INVALID_REPT_FORM);}}
  public    string           reportNumber        {get {return _reportNumber.ToString();}      set {_reportNumber     = (int) Validate.optInteger(value,Messages.INVALID_REPT_NUMBER);}}
  public    string           reportRequestUid    {get {return _reportRequestUid; }            set { Validate.optGuid (value,Messages.INVALID_REPT_REQ_UID); _reportRequestUid = value;} }
  public    string           lastName            {get {return _lastName;}                     set {_lastName         = value;}}
  public    string           firstName           {get {return _firstName;}                    set {_firstName        = value;}}
  public    string           name                {get {return _name;}                         set {_name             = value;}}
  public    string           active              {get {return _active;}                       set {_active           = value;}} 

  
 /*-------------------------------
  * Constructors
  *------------------------------*/

  /***************************************************************************
   * WebReportDocument */
  /**
   * 
   * @param  purpose          What is the purpose of this request
   * @param  rptForm          FormatStrings of report document
   * @param  reportData       Report data
   ***************************************************************************/       
  
  public WebDataDocument()
  {
    
    /*-------------------------------
     * We do not have the report data
     * yet
     * 
     * So we need to fetch
     * the parameters required to
     * get the data the user
     * is looking for.
     * 
     * Assuming this is part of
     * a http request, fetch our
     * standard view/report parameters.
     * 
     * Our decsendants constructor will
     * fetch any application specific
     * parameters
     *------------------------------*/
    
    this.reportForm        = HttpApplication.getParameter(Constants.PARM_REP_FORM);            
    this.reportNumber      = HttpApplication.getParameter(Constants.PARM_REP_NUMBER);
    this.startDate         = HttpApplication.getParameter(Constants.PARM_START_DATE);
    this.endDate           = HttpApplication.getParameter(Constants.PARM_END_DATE);
    this.dateRange         = HttpApplication.getParameter("daterange");
    this.entryDateRange    = HttpApplication.getParameter("entrydaterange");
    this.recID             = HttpApplication.getParameter(Constants.PARM_REC_ID);
    this.lastName          = HttpApplication.getParameter(Constants.PARM_LNAME);
    this.firstName         = HttpApplication.getParameter(Constants.PARM_FNAME);
    this.name              = HttpApplication.getParameter(Constants.PARM_NAME);
    this.active            = HttpApplication.getParameter(Constants.PARM_ACTIVE);    
    this.reportRequestUid  = HttpApplication.getParameter(Constants.PARM_REP_REQUEST_UID);
  
  }
  protected void setGeneratedFileDownloadReadyCookie(HttpContext context, string value)
  {
    if (String.IsNullOrWhiteSpace(_reportRequestUid)) return; /* For backwards compatibility */
    context.Response.SetCookie(HttpApplication.createGeneratedFileDownloadReadyCookie(_reportRequestUid, value));
  }
  public WebDataDocument(ReturnRptData reportData, int rptForm)
  {
        
    /*-------------------------------
     * We have the view data and
     * the format we want it in
     * go ahead and generate the 
     * document
     *------------------------------*/

     this._reportForm = rptForm;
     this._reportData = reportData;
  }
         

  protected void ExceptionHTML (HttpContext context)
  {    
            
    /*-------------------------------
     * In the even of non success
     * transfer the HTML request to
     * our error message page
     *------------------------------*/

    string msg = _reportData.message;
    context.Response.Clear();
    context.Server.Transfer(@"error.aspx?msg=" + msg);

  }

   /***************************************************************************
    * callMethod */
    /**
    * Wrapper for calling framework methods to generate ReturnDB
    * 
    * @param  cb              Method callback (use delegate) 
    * @param  permittedRoles  If this method should be private
    *                         supply all authorized roles
    * @return                 Object containing rt (need to cast)
    ***************************************************************************/
       
  protected Object callMethod(MethodCallback cb)
  {
    return HttpApplication.callMethod(ref this.dbConnUser,ref this.dbConnApp,ref this.log, ref this.rd, ref this.uInfo, typeof(ReturnRptData), cb);
  }
    
  protected Object callMethod(MethodCallback cb, params string[] permittedRoles)
  {      
    return HttpApplication.callMethod(ref this.dbConnUser,ref this.dbConnApp,ref this.log,ref this.rd,ref this.uInfo, typeof(ReturnRptData), cb, true, permittedRoles);
  }   

  /***************************************************************************
   * ProcessRequest */
  /**
   * Required method to fulfill IHttpHandlert contract.
   * 
   * This method is called by the handler after the constructor
   * and it is where we define how to process the request.
   * 
   * @param  context         Current http request/response
   ***************************************************************************/       
  
  public void ProcessRequest(HttpContext context)
  {
                 
    /*-------------------------------
     * If view data is not provided
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
        _reportData = (ReturnRptData) callMethod(_cbReportData);
      else
        _reportData = (ReturnRptData) callMethod(_cbReportData,_permittedRoles);
    }
    
    /*-------------------------------
     * If its still null get out
     *------------------------------*/

    if (_reportData == null)
    {
      throw new MBA.Critical("Report data is required");    
    }
    
    /*-------------------------------
     * Check status and exit if it
     * is not OK
     *------------------------------*/

    if (_reportData.status != Return.RET_SUCCESS)
    {                 
      ExceptionHTML(context);
      return;
    }

    /*-------------------------------
     * Generate response
     *------------------------------*/

    context.Response.Clear();

    /*-------------------------------
     * Genererate view or document
     * depending on request
     *------------------------------*/
    
    switch(_reportForm)
    {                      
      /*-------------------------------
       * HTML
       *------------------------------*/

      case Constants.REPT_FORMAT_HTML_REPORT:
      {
        GenerateHTMLRpt(context);
        break;
      }
      case Constants.REPT_FORMAT_PDF_REPORT:
      {
        GeneratePDFRpt(context);
        break;
      }
      case Constants.REPT_FORMAT_XLS_REPORT:
      {
        GenerateXLSRpt(context);
        break;
      }
      default:
      {
        throw new Warning(@"Unknown format requested");
        //break;
      }
    }
  }

  /***************************************************************************
   * GeneratePDFRpt */
  /**
   * Generates a document
   * 
   * @param  context         Current http request/response
   ***************************************************************************/  
  
  protected void GeneratePDFRpt (HttpContext context)
  {      
    /*-------------------------------
     * Create response header
     *------------------------------*/
    
    string fname = PDF.GenerateFileName(reportData.filename);

    context.Response.ContentType = "application/pdf";
    context.Response.AppendHeader("content-disposition", "attachment; filename=\"" + fname + "\"");
    context.Response.SetCookie(HttpApplication.createFileDownloadCookie()); // Required for filedownload plugin
    setGeneratedFileDownloadReadyCookie(context, fname);
    
    /*-------------------------------
     * Ourput report
     *------------------------------*/
      
    context.Response.BinaryWrite(PDF.ReturnRptDataToPDF(ref _reportData));
    context.Response.End();

  }

  /***************************************************************************
   * GenerateXLSRpt */
  /**
   * Generates a document
   * 
   * @param  context         Current http request/response
   ***************************************************************************/  
  
  protected void GenerateXLSRpt (HttpContext context)
  {      
    /*-------------------------------
     * Create response header
     *------------------------------*/

    //string fname = Excel.GenerateFileName(_reportData.filename);   
    string fname = Excel2.generateFileName(_reportData.filename);

    //context.Response.ContentType = "application/vnd.ms-excel";
    context.Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

    context.Response.AppendHeader("content-disposition", "attachment;filename=\"" + fname + "\"");
    context.Response.SetCookie(HttpApplication.createFileDownloadCookie()); // Required for filedownload plugin       
    setGeneratedFileDownloadReadyCookie(context, fname);

    /*-------------------------------
     * Ourput report
     *------------------------------*/
      
    //context.Response.BinaryWrite(Excel.ReturnRptDataToXLS(ref _reportData));
    context.Response.BinaryWrite(Excel2.returnRptDataToFile (ref _reportData));
    context.Response.End();

  }
  
  /***************************************************************************
   * GenerateHTMLRpt */
  /**
   * Generates a document
   * 
   * @param  context         Current http request/response
   ***************************************************************************/  
  
  protected void GenerateHTMLRpt (HttpContext context)
  {      
    /*-------------------------------
     * Create response header
     *------------------------------*/

    context.Response.ContentType = "text/html";
    context.Response.Charset     = "utf-8";

    /*-------------------------------
     * Ourput report
     *------------------------------*/
      
    context.Response.BinaryWrite(HTML.ReturnRptDataToHTML(ref _reportData));
    //context.Response.BinaryWrite(HTML2.ReturnRptDataToHTML(ref _reportData));
    context.Response.End();

  } 
 }
}