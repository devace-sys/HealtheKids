using System;
using System.Collections;
using System.Globalization;
using System.Threading;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text.RegularExpressions;

namespace MBA
{  
  /**************************************************************************
   * RequestServiceAuthorizationResponse */
  /**
   ****************************************************************************/
  
  public enum RequestServiceAuthorizationResponse
  {      
      NO_RESPONSE_REQUIRED = 1000
	  , PENDING              = 2000
	  , APPROVED             = 3000
    , DECLINED             = 4000    
  }
  
  /**************************************************************************
  * SelectRequestServiceAuthorizationResponse */
  /**
   *
   ****************************************************************************/ 

  public class SelectRequestServiceAuthorizationResponse:ControlBase
  {
    
    public SelectRequestServiceAuthorizationResponse () 
    {    
    }
    
	  protected string        _id                  = @"responsecode";
	  protected string        _title               = @"Select One";
    protected string        _name                = @"responsecode";
    protected string       _onSelectValue        = @"function(oldval,newval){return true;}";
    protected bool         _showPendingOption    = false;
    protected string       _selectionTextApproved = @"Approved";
    protected string       _selectionTextDeclined = @"Declined";

    protected RequestServiceAuthorizationResponse  _value     = RequestServiceAuthorizationResponse.PENDING;
    protected string                  _valueStr  = "";
	      
    //private new String ID;
    public string                 id    { get { return _id;    } set { _id    = value; } }
    public string                 name  { get { return _name;  } set { _name  = value; } }
    public string                 title { get { return _title; } set { _title = value; } }
    public RequestServiceAuthorizationResponse value { get { return _value; } set { _value = value; } }
    public string onSelectValue { get {return _onSelectValue;} set {_onSelectValue = value;}}
    
    public bool showPendingOption         { get {return _showPendingOption;} set {_showPendingOption = value;}}
    public string selectionTextApproved   { get {return _selectionTextApproved;} set {_selectionTextApproved = value;}}
    public string selectionTextDeclined   { get { return _selectionTextDeclined;} set {_selectionTextDeclined = value;}}
    public static int getIntValueFromEnum (RequestServiceAuthorizationResponse valueInEnum)
    {
      return (int) valueInEnum;
    }
    
    public static string getStringValueFromEnum (RequestServiceAuthorizationResponse valueInEnum)
    {
      return getIntValueFromEnum(valueInEnum).ToString();      
    }
   
    public static RequestServiceAuthorizationResponse getEmumValueFromString (string valueInStr)
    {
      return (RequestServiceAuthorizationResponse) Enum.Parse(typeof(RequestServiceAuthorizationResponse),valueInStr,true);
    }
   
	  protected override void Render (HtmlTextWriter writer) { 
	  
	    _valueStr = ((int)_value).ToString();
      MBA.RadioBox requestOrpDocAuthorizationResp = new MBA.RadioBox ( _name, _valueStr);
      requestOrpDocAuthorizationResp.ID               = _id;
      requestOrpDocAuthorizationResp.title            = _title;
      requestOrpDocAuthorizationResp.name             = _name;
      requestOrpDocAuthorizationResp.firedataselected = true;      
      requestOrpDocAuthorizationResp.labelIsSpan      = false;
      requestOrpDocAuthorizationResp.noClear          = false;
	    requestOrpDocAuthorizationResp.onSelectValue    = _onSelectValue;

      if (_showPendingOption == true) 
      { 
        requestOrpDocAuthorizationResp.AddSelection("Pending",               ((int) RequestServiceAuthorizationResponse.PENDING).ToString());
        requestOrpDocAuthorizationResp.AddSelection(_selectionTextDeclined,  ((int) RequestServiceAuthorizationResponse.DECLINED).ToString());
        requestOrpDocAuthorizationResp.AddSelection(_selectionTextApproved,  ((int) RequestServiceAuthorizationResponse.APPROVED).ToString());
      }
      else
      {        
        requestOrpDocAuthorizationResp.AddSelection(_selectionTextApproved,  ((int) RequestServiceAuthorizationResponse.APPROVED).ToString());
        requestOrpDocAuthorizationResp.AddSelection(_selectionTextDeclined,  ((int) RequestServiceAuthorizationResponse.DECLINED).ToString());  
      }

            
      requestOrpDocAuthorizationResp.RenderControl(writer);	
	  }    
  }
}

