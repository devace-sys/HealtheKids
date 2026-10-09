using System;
using System.Web;
using System.Web.Routing;
using System.Reflection;
using System.Data.SqlClient;

namespace MBA
{
     
  /***************************************************************************
   * EntitiesRestApiHttpHandler */
  /**
   *    
   ***************************************************************************/

   public abstract class EntitiesRestApiHttpHandler : IHttpHandler
   {    

     protected   SqlConnection           dbConnUser;             /* Connection to user database */
     protected   SqlConnection           dbConnApp;              /* Connection to this applications database */
     protected   DetailsLog              log;                    /* Our logging object */
     protected   RequestResponse         rd;                     /* Our request response object */
     protected   UserInfo                uInfo;                  /* User info */
     protected   RouteData               routeData;              /* Route data from handler mapping */
     protected   bool                    localNetworkAccessOnly; /* Is this handler only allowed to process requests from a whitelist */
     protected   string                  requestHttpVerb;        /* get, post, etc. */
     protected   string                  requestedMethod;

     public bool IsReusable                     { get { return false; } } /* Not thread safe.. Each request needs its own instance.*/
     public MethodCallback viewMethodCb         {get; set;}
     public string[] viewMethodPermittedRoles   {get; set;}    
     public MethodCallback saveMethodCb         {get; set;}
     public string[] saveMethodPermittedRoles   {get; set;}
     public MethodCallback deleteMethodCb       {get; set;}
     public string[] deleteMethodPermittedRoles {get; set;}
     public string selpacode        {get; set;}
     public string clientid         {get; set;}
     public string siteid           {get; set;}
     public string startdate        {get; set;}
     public string enddate          {get; set;}
     public string daterange        {get; set;}
     public string recid            {get; set;}
     public string lname            {get; set;}
     public string fname            {get; set;}
     public string name             {get; set;}
     public string term             {get; set;}     
     public string patid            {get; set;} 
     public string dos              {get; set;} 
     public string pracid           {get; set;}
     public string groupid          {get; set;}
     public string plantype         {get;set;}
     public string nameid           {get; set;}
     public string active           {get; set;}
     public string pagesize         {get; set;}
     public string pagenumber       {get; set;}
     public string pageorder        {get; set;}     
     public bool   recIDPassed      {get; set;}
     public bool   pageObjectList   {get; set;}
     public string idx              {get; set;}
     public string datasource              {get; set;}
     public string groupserviceclassnameid { get; set; }
     public string svctypeid               { get; set; }
     public string spEdServiceCode         { get; set; }   
     public string orpDocID                {  get; set; }
     public string svcTrackingClass        {  get; set; }
     public string leaBopOnlyOrAllSped     { get; set; }
     public string rmtsActivityCode        { get; set; }
     public string rptGroupID              { get ; set; } 
     public string orpDocStandardSelectionNameID { get; set; } 
     public string reviewed                      { get; set; }
     public string approved                      { get; set; }
     public string referencedentityid            { get; set; }
     public string fileclass                     { get; set; }
     public string filenamespace                 { get; set; }
     public string filesource                    { get; set; }
     public string useMinsPerFreqAssigned        { get; set; }
     public string includeContent                { get; set; }
     public string hasAltFormat                  { get; set; }
     public string completed                     { get; set; }
     public string practitionerPatientCaseloadExpectedServiceID { get; set; }
     public string personClassID1                { get; set; }
     public string personClassID2                { get; set; }
     public string pcalComplianceRatingForPat    { get; set; }
     public string svcOverDelivery               { get; set; }
     public string enabled                       { get; set; }

    public string notenamespace                 { get; set; }
    public string notesource                    { get; set; }

    /*Referral system*/
    public string filterascomplete               { get; set; } 
    public string referringbyuserid              { get; set; } 

    /* Service record review */
    public string reviewingpracid                { get; set; }
    public string renderingpracid                { get; set; }
    
    /* Billing consortiums */
    public string consortiumLeadClientID         { get ; set; }
        
     /* Datatables 1.10 specific */
     public bool dtViewMode   { get; set;}
     public int dtStart       { get; set;}
     public int dtDraw        { get; set;}

    /***************************************************************************
     * serializeReturnData */
    /**
     * Serializes return data.  
     * TODO: Expand to support XML and other text based mime types
     ***************************************************************************/       
    public static string serializeReturnData (Object rd)
    {
      return JSON.toJSONString(rd,JsonLibrary.NEWTONSOFT);     
    }

        /***************************************************************************
         * callMethod */
        /**
         * Wrapper for calling web methods
         * 
         * @param  rt              Return type of method call (use typeof() operator)
         * @param  cb              Method callback (use delegate) 
         * @param  permittedRoles  If this method should be private
         *                         supply all authorized roles
         * @return                 Object containing rt (need to cast)
         ***************************************************************************/

    protected Object callMethod (Type rt, MethodCallback cb, params string[] permittedRoles)
    {            
      if (permittedRoles == null)
      { 
        return HttpApplication.callMethod(ref this.dbConnUser,ref this.dbConnApp,ref this.log,ref this.rd,ref this.uInfo, rt,cb,false,null,"");
      }
      return HttpApplication.callMethod(ref this.dbConnUser,ref this.dbConnApp,ref this.log,ref this.rd, ref this.uInfo, rt,cb,true,permittedRoles);
    }                

    /***************************************************************************
     * init */
    /**
     ***************************************************************************/   

   protected void Init()
   {
     this.pageObjectList = false;
   }

    /***************************************************************************
     * initResponse */
    /**
     ***************************************************************************/   

    protected void InitResponse(ref HttpContext context)
    {
      context.Response.Clear();       
      context.Response.StatusCode      = 200;
      context.Response.ContentType     = "application/json";
      context.Response.ContentEncoding = System.Text.Encoding.UTF8;

      /* Set Cache-Control header value to private, no-store.
       * private  = The response is for a single user and must not be stored by a shared cache. A private cache (like the user's browser cache) may store the response.
       * no-store = The cache should not store anything about the client request or server response.
       */

      context.Response.Cache.SetCacheability(HttpCacheability.Private);
      context.Response.Cache.SetNoStore(); 
    }

    /***************************************************************************
     * getRequestedMethod */
    /**
     * Gets the requested method from a parameter or if the parameter is not
     * provided, derives the method from the HTTP method.
     ***************************************************************************/   

    protected void getRequestedMethod (ref HttpContext context)
    {
      this.requestHttpVerb = context.Request.HttpMethod.ToLower().Trim();
      this.requestedMethod = HttpApplication.getParameter(Constants.PARM_REQUESTED_METHOD);
      
      if (String.IsNullOrWhiteSpace(this.requestedMethod))
      { 
        /* Requested method is not passed, derive it from the HttpMethod */
        if      (this.requestHttpVerb == "get")     this.requestedMethod = Constants.REQUEST_METHOD_VIEW;
        else if (this.requestHttpVerb == "post")    this.requestedMethod = Constants.REQUEST_METHOD_SAVE;
        else if (this.requestHttpVerb == "delete")  this.requestedMethod = Constants.REQUEST_METHOD_DELETE;
        else this.requestedMethod = @"";
      }
      else
      {
        /* Requested method is passed, clean up the value so we can compare it later */
        this.requestedMethod = this.requestedMethod.ToLower().Trim();
      }

    }
   
    /***************************************************************************
     * getCommonEntityParameters */
    /**
     ***************************************************************************/   

    protected void getCommonEntityParameters ()
    {
      this.recid                   = HttpApplication.getParameter(Constants.PARM_REC_ID);
      this.selpacode               = HttpApplication.getParameter(Constants.PARM_SELPA_CODE);   
      this.clientid                = HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
      this.siteid                  = HttpApplication.getParameter(Constants.PARM_SITE_ID);
      this.patid                   = HttpApplication.getParameter(Constants.PARM_PATIENT_ID);
      this.pracid                  = HttpApplication.getParameter(Constants.PARM_PRACTITIONER_ID);
      this.groupid                 = HttpApplication.getParameter(Constants.PARM_GROUP_ID);
      this.plantype                = HttpApplication.getParameter(Constants.PARM_PLAN_TYPE);
      this.nameid                  = HttpApplication.getParameter(Constants.PARM_NAME_ID);
      this.groupserviceclassnameid = HttpApplication.getParameter(Constants.PARM_GRP_SVC_CLS_NME_ID);
      this.datasource              = HttpApplication.getParameter(Constants.PARM_DATA_SOURCE);
      this.svctypeid               = HttpApplication.getParameter(Constants.PARM_SVC_TYPE_ID);
      this.spEdServiceCode         = HttpApplication.getParameter(Constants.PARM_SPED_SERVICE_CODE);
      this.orpDocID                = HttpApplication.getParameter(Constants.PARM_ORP_DOC_ID);
      this.svcTrackingClass        = HttpApplication.getParameter(Constants.PARM_SVC_TRACKING_CLASS);
      this.leaBopOnlyOrAllSped     = HttpApplication.getParameter(Constants.PARM_LEA_BOP_ONLY_OR_ALL_SPED);      
      this.startdate               = HttpApplication.getParameter(Constants.PARM_START_DATE);
      this.enddate                 = HttpApplication.getParameter(Constants.PARM_END_DATE);
      this.daterange               = HttpApplication.getParameter(Constants.PARM_DATE_RANGE);
      this.lname                   = HttpApplication.getParameter(Constants.PARM_LNAME);
      this.fname                   = HttpApplication.getParameter(Constants.PARM_FNAME);
      this.name                    = HttpApplication.getParameter(Constants.PARM_NAME);
      this.active                  = HttpApplication.getParameter(Constants.PARM_ACTIVE);  
      this.term                    = HttpApplication.getParameter(Constants.PARM_SEARCH_TERM);
      this.rmtsActivityCode        = HttpApplication.getParameter(Constants.PARM_RMTS_ACTIVITY_CODE);
      this.rptGroupID              = HttpApplication.getParameter(Constants.PARM_RPT_GROUP_ID);

      this.orpDocStandardSelectionNameID = HttpApplication.getParameter(Constants.PARM_ORP_DOC_STD_SEL_NAME_ID);
      this.reviewed                      = HttpApplication.getParameter(Constants.PARM_REVIEWED);
      this.approved                      = HttpApplication.getParameter(Constants.PARM_APPROVED);
      this.referencedentityid            = HttpApplication.getParameter(Constants.PARM_REFERENCED_ENTITY_ID);
      this.fileclass                     = HttpApplication.getParameter(Constants.PARM_FILE_CLASS);
      this.filenamespace                 = HttpApplication.getParameter(Constants.PARM_FILE_NAMESPACE);
      this.filesource                    = HttpApplication.getParameter(Constants.PARM_FILE_SOURCE);
      this.useMinsPerFreqAssigned        = HttpApplication.getParameter(Constants.PARM_USE_MINS_PER_FREQ_ASSIGNED);
      this.includeContent                = HttpApplication.getParameter(Constants.PARM_INCLUDE_CONTENT);
      this.completed                     = HttpApplication.getParameter(Constants.PARM_COMPLETED);
      this.hasAltFormat                  = HttpApplication.getParameter(Constants.PARM_HAS_ALT_FORMAT);

      this.dos                           = HttpApplication.getParameter(Constants.PARM_DOS);

      this.practitionerPatientCaseloadExpectedServiceID = MBA.HttpApplication.getParameter(Constants.PARM_PRAC_PAT_CASELOAD_EXPECTED_SVC_ID);
      
      this.personClassID1                = MBA.HttpApplication.getParameter(Constants.PARM_PERSON_CLASS_ID_1);
      this.personClassID2                = MBA.HttpApplication.getParameter(Constants.PARM_PERSON_CLASS_ID_2);
      this.pcalComplianceRatingForPat    = MBA.HttpApplication.getParameter(Constants.PARM_PCAL_COMPLIANCE_RATING_FOR_PAT);      
      this.svcOverDelivery               = MBA.HttpApplication.getParameter(Constants.PARM_SVC_OVER_DELIVERY);

      /*Referral System*/
      /* TODO: Refactor filter as complete to use the existing completed parameter */

      this.filterascomplete              = MBA.HttpApplication.getParameter(Constants.PARM_FILTER_IS_COMPLETED);  
      this.enabled                       = MBA.HttpApplication.getParameter(Constants.PARM_ENABLED);
      this.referringbyuserid             = MBA.HttpApplication.getParameter(Constants.PARM_REFERRING_BY_USER_ID);  

      this.notenamespace                 = MBA.HttpApplication.getParameter(Constants.PARM_NOTE_NAMESPACE); 
      this.notesource                    = MBA.HttpApplication.getParameter(Constants.PARM_NOTE_SOURCE);  

      this.reviewingpracid               = MBA.HttpApplication.getParameter(Constants.PARM_REVIEWING_PRAC_ID);  
      this.renderingpracid               = MBA.HttpApplication.getParameter(Constants.PARM_RENDERING_PRAC_ID);  

      this.consortiumLeadClientID        = MBA.HttpApplication.getParameter(Constants.PARM_CONSORTIUM_CLIENT_ID);  
     
      if (routeData.Values.ContainsKey("id"))
      {          
        var _kvID = routeData.Values["id"].ToString();
        if (!Util.IsNullOrEmpty(_kvID)) {         
          this.recid = _kvID;
        }
      }

      recIDPassed = false;
      if (!Util.IsNullOrEmpty(this.recid)) recIDPassed = true;
    
    }

    /***************************************************************************
     * getCommonPagingParameters */
    /**
     ***************************************************************************/   

    protected void getCommonPagingParameters()
    {

      /* See if data table mode should be used for this view */
       
      var _dtViewModeStr = HttpApplication.getParameter(Constants.PARM_DT_VIEW_MODE);

      if (String.IsNullOrWhiteSpace(_dtViewModeStr))
      {
        this.dtViewMode = false;
      }
      
      /* Mode parameter has been passed */
      
      else
      {
        bool? _dtViewModeVal = Util.evaluateFlag(_dtViewModeStr, false);
        if (_dtViewModeVal.HasValue)
        {
          this.dtViewMode = _dtViewModeVal.Value;
        }
        else
        {
          this.dtViewMode = false;
        }
      }
      

      this.pagesize      = HttpApplication.getParameter(Constants.PARM_PAGE_SIZE);
      this.pageorder     = HttpApplication.getParameter(Constants.PARM_PAGE_ORDER);      
      this.pagenumber    = HttpApplication.getParameter(Constants.PARM_PAGE_NUMBER);
      
      /* If we are in datatables view mode then we parse some additional parmeters and override pagenumber */

      if (dtViewMode == true)
      {
      
        var _dtDrawStr    = HttpApplication.getParameter(Constants.PARM_DT_DRAW);

        if (int.TryParse(_dtDrawStr,out int _dtDrawInt))
        {
          this.dtDraw = _dtDrawInt;
        }
        else
        {
          this.dtDraw = 0;
        }

        var _dtStartStr = HttpApplication.getParameter(Constants.PARM_DT_START);
        if (int.TryParse(_dtStartStr,out int _dtStartInt))
        {
          this.dtStart = _dtStartInt;
        }
        else
        {
          this.dtStart = 0;
        }
      
        // Compute page # using dt paging parms and replace pagenumber parameter value with computed value
      
        this.pagenumber = Util.calculatePageNumber(this.dtStart,Rules.VIEW_TBL_PAGE_SIZE).ToString();
      
      }
      else
      {
        /* Mode is not being used so set the values to -1 */
        this.dtDraw = -1;
        this.dtStart= -1;
      }

    }

    /***************************************************************************
     * writeReturnSaveRecordResponse */
    /**
     ***************************************************************************/   

    protected void writeReturnSaveRecordResponse (ref HttpContext context, ref ReturnSaveRecord rd)
    {            
      context.Response.Write(serializeReturnData(rd));
    }
    
    /***************************************************************************
     * writeReturnViewResponse */
    /**
     ***************************************************************************/   
    protected void writeReturnViewResponse (ref HttpContext context, ref ReturnObjects rd)
    {      
      /* If we are in dtView mode then pass back the draw parameter value sent */
      if (this.dtViewMode) rd.draw = this.dtDraw;     
      context.Response.Write(serializeReturnData(rd));
    }
      
    /***************************************************************************
     * writeExceptionResponse */
    /**
     ***************************************************************************/   
    protected void writeExceptionResponse (ref HttpContext context, ref Critical e)
    {
      Return rd = new Return(e);      
      context.Response.Write(serializeReturnData(rd));
    }

    /***************************************************************************
     * writeExceptionResponse */
    /**
     ***************************************************************************/   
    protected void writeExceptionResponse (ref HttpContext context, ref Exception e)
    {
      Return rd = new Return(e);
      context.Response.Write(JSON.toJSONString(rd));
    }
    
    /***************************************************************************
     * checkIfMethodImplemented */
    /**
     ***************************************************************************/   

    protected void checkIfMethodImplemented (MethodCallback cb)
    {
      if (cb == null) throw new Critical("Method is not implemented");   
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
      
      try
      {
        Init();
        InitResponse(ref context);        
        getRequestedMethod(ref context);
      
        if (this.localNetworkAccessOnly == true)
        { 
          if (Util.isIpAddressIsInTrustedLocalIPs(context.Request.UserHostAddress) == false)
          {           
            throw new Critical ("Access forbidden");
          }
        }
       
        
        /* Get parameter values that any action might use */
      
        getCommonEntityParameters();
      
        /* View */
       
        if (this.requestedMethod == Constants.REQUEST_METHOD_VIEW)
  		  {                    
          checkIfMethodImplemented (this.viewMethodCb);
          getCommonPagingParameters();
        
          /* If the record id is passed then we will not page the results */
        
          if (this.recIDPassed) 
          { 
            this.pageObjectList = false;  
            this.idx            = recid;
          }
        
          /* Results will be paged */
        
          else
          {
            if (String.IsNullOrWhiteSpace(this.pagenumber)) this.pagenumber = @"1";
            this.pageObjectList = true;
            this.idx            = pagenumber;          
          }

          ReturnObjects rd = (ReturnObjects) callMethod ( typeof(ReturnObjects), this.viewMethodCb, this.viewMethodPermittedRoles);
          
          writeReturnViewResponse (ref context, ref rd);

         }
       
         /* Save */
       
         else if (this.requestedMethod == Constants.REQUEST_METHOD_SAVE)
         {
           checkIfMethodImplemented(this.saveMethodCb);
           ReturnSaveRecord rd = (ReturnSaveRecord) callMethod (typeof(ReturnSaveRecord), this.saveMethodCb, this.saveMethodPermittedRoles);
           writeReturnSaveRecordResponse (ref context,ref rd);
         }
       
         /* Delete */
       
         else if (this.requestedMethod == Constants.REQUEST_METHOD_DELETE)
         {
           checkIfMethodImplemented(this.deleteMethodCb);
           ReturnSaveRecord rd = (ReturnSaveRecord) callMethod (typeof(ReturnSaveRecord), this.deleteMethodCb, this.deleteMethodPermittedRoles);
           writeReturnSaveRecordResponse (ref context,ref rd);
         }
     
         else
         {           
           throw new Critical(@"Requested method is not suported");
         }
  
       }
       catch (Critical e)
       {
          writeExceptionResponse(ref context,ref e);         
       }
       catch (Exception e)
       {          
         writeExceptionResponse(ref context,ref e);
       }    
    }    
    public EntitiesRestApiHttpHandler (): this(null,false)
    {        
    }
    
    public EntitiesRestApiHttpHandler (RouteData routedata, bool localnetworkaccessonly)
    {
      this.routeData              = routedata;
      this.localNetworkAccessOnly = localnetworkaccessonly;
    }

  }     
  
  /***************************************************************************
   * RestApiRouteHandler */
  /**
   * 
   ***************************************************************************/   
  public class EntitiesRestApiRouteHandler : IRouteHandler
  {
    
    protected bool _localNetworkAccessOnly = false;
    protected Type _httpHandlerType        = typeof(EntitiesRestApiHttpHandler);

    public EntitiesRestApiRouteHandler():this(false,typeof(EntitiesRestApiHttpHandler))
    {            
    }

    public EntitiesRestApiRouteHandler (bool localNetworkAccessOnly, Type httpHandlerType)
    {      
      _localNetworkAccessOnly = localNetworkAccessOnly;
      _httpHandlerType        = httpHandlerType;
    }

	  IHttpHandler IRouteHandler.GetHttpHandler(RequestContext requestContext)
    {                  
      Object[] v = new Object[] {requestContext.RouteData,_localNetworkAccessOnly};
      IHttpHandler handler = (IHttpHandler) Activator.CreateInstance(_httpHandlerType,v);
      return handler;
    }
  }     
}


