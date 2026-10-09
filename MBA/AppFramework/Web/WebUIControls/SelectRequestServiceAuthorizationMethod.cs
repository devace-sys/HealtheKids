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
   * RequestServiceAuthorizationMethod */
  /**
   ****************************************************************************/
  
  public enum RequestServiceAuthorizationMethod
  {      
      ELECTRONIC        = 10
    , PAPER             = 20
    , UNKNOWN           = 99
  }
  
  /**************************************************************************
  * SelectRequestServiceAuthorizationMethod */
  /**
   *
   ****************************************************************************/ 

  public class SelectRequestServiceAuthorizationMethod:ControlBase
  {
    
    public SelectRequestServiceAuthorizationMethod () 
    {    
    }
    
	  protected string        _id                  = @"requestAuthorizationForm";
	  protected string        _title               = @"Select One";
    protected string        _name                = @"requestAuthorizationForm";
    protected string       _onSelectValue        = @"function(oldval,newval){return true;}";

    protected RequestServiceAuthorizationMethod  _value     = RequestServiceAuthorizationMethod.ELECTRONIC;
    protected string                  _valueStr  = "";
	      
    //private new String ID;
    public string                 id    { get { return _id;    } set { _id    = value; } }
    public string                 name  { get { return _name;  } set { _name  = value; } }
    public string                 title { get { return _title; } set { _title = value; } }
    public RequestServiceAuthorizationMethod value { get { return _value; } set { _value = value; } }
    public string onSelectValue { get {return _onSelectValue;} set {_onSelectValue = value;}}
    
    public static int getIntValueFromEnum (RequestServiceAuthorizationMethod valueInEnum)
    {
      return (int) valueInEnum;
    }
    
    public static string getStringValueFromEnum (RequestServiceAuthorizationMethod valueInEnum)
    {
      return getIntValueFromEnum(valueInEnum).ToString();      
    }
   
    public static RequestServiceAuthorizationMethod getEmumValueFromString (string valueInStr)
    {
      return (RequestServiceAuthorizationMethod) Enum.Parse(typeof(RequestServiceAuthorizationMethod),valueInStr,true);
    }
   
	  protected override void Render (HtmlTextWriter writer) { 
	  
	    _valueStr = ((int)_value).ToString();           
      MBA.RadioBox requestOrpDocAuthorizationFrom = new MBA.RadioBox ( _name, _valueStr);
      requestOrpDocAuthorizationFrom.ID               = _id;
      requestOrpDocAuthorizationFrom.title            = _title;
      requestOrpDocAuthorizationFrom.name             = _name;
      requestOrpDocAuthorizationFrom.firedataselected = true;      
      requestOrpDocAuthorizationFrom.labelIsSpan      = false;
      requestOrpDocAuthorizationFrom.noClear          = false;
	    requestOrpDocAuthorizationFrom.onSelectValue    = _onSelectValue;
      requestOrpDocAuthorizationFrom.AddSelection("Electronic", ((int) RequestServiceAuthorizationMethod.ELECTRONIC).ToString());
      requestOrpDocAuthorizationFrom.AddSelection("Paper",      ((int) RequestServiceAuthorizationMethod.PAPER).ToString());
            
      requestOrpDocAuthorizationFrom.RenderControl(writer);	
	  }    
  }
}

