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
   * ServiceAuthorizationStatusConfirmationResponse */
  /**
   * Note: Keep in synch with the databaase table 
   * Spedmon.dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_RESPONSE_CODES   
   ****************************************************************************/
  
  public enum ServiceAuthorizationStatusConfirmationResponse
  {      
      [Description("YES, an order is signed/authorized by the ORP listed above")]
		  YES_ORP_APPROVED                    = 100	  	  
    , [Description("NO, an order is not yet signed, or is pending signature/authorization")]
      NO_PENDING_AUTH                     = 200	    
	  , [Description("NO, the ORP explictly declined a request for authorization")] 
      NO_ORP_DECLINED                     = 300      
	  , [Description("Authorization request was cancelled")] 
      REQUEST_FOR_AUTHORIZATION_CANCELLED = 400	    
	  , [Description("I am authorizing this order as the ORP listed above")] 
      YES_I_AM_THE_ORP                    = 500      
	  , [Description("Unknown")] 
      UNKNOWN                             = 999
  }
  
  /**************************************************************************
  * SelectServiceAuthorizationStatusConfirmationResponse */
  /**
   *
   ****************************************************************************/ 

  public class SelectServiceAuthorizationStatusConfirmationResponse:ControlBase
  {
    
    public SelectServiceAuthorizationStatusConfirmationResponse () 
    {    
    }
    
	  protected string       _id                         = @"svcauthstatusconfirmrespcode";
	  protected string       _title                      = @"Select One";
    protected string       _name                       = @"svcauthstatusconfirmrespcode";
    protected string       _onSelectValue              = @"function(oldval,newval){return true;}";
    protected bool         _displaySelectionsVertical  = true;
    protected bool         _renderLabel                = false;

    protected ServiceAuthorizationStatusConfirmationResponse  _value;
    protected string                                          _valueStr  = "";
	      
    public string                 id    { get { return _id;    } set { _id    = value; } }
    public string                 name  { get { return _name;  } set { _name  = value; } }
    public string                 title { get { return _title; } set { _title = value; } }
    
    public bool                   displaySelectionsVertical { get { return _displaySelectionsVertical;}
                                                              set {_displaySelectionsVertical = value;}}
    public bool renderLabel { get { return _renderLabel;} set { _renderLabel = value;} }
    public ServiceAuthorizationStatusConfirmationResponse value { get { return _value; } set { _value = value; } }
    public string onSelectValue { get {return _onSelectValue;} set {_onSelectValue = value;}}
    
    public static int getIntValueFromEnum (ServiceAuthorizationStatusConfirmationResponse valueInEnum)
    {
      return valueInEnum.GetValueAsInt();   
    }
    
    public static string getStringValueFromEnum (ServiceAuthorizationStatusConfirmationResponse valueInEnum)
    {
      return valueInEnum.GetValueAsString();      
    }
   
    public static ServiceAuthorizationStatusConfirmationResponse getEmumValueFromString (string valueInStr)
    {
      return (ServiceAuthorizationStatusConfirmationResponse) Enum.Parse(typeof(ServiceAuthorizationStatusConfirmationResponse),valueInStr,true);
    }
   
    public static bool isYesIAmTheORPAValidPossibleOption (ref RequestResponse rd)
    {
      if ((rd.loggedIn) && (rd.wu.usr.roleID == Constants.ROLE_LEA_PROVIDER_ID)) return true;      
      return false;
    }
	  protected override void Render (HtmlTextWriter writer) { 
	  
	    /*Note: No default or editable value is allowed.  User must always provide a fresh new value regardless of save type.*/

      MBA.RadioBox reqSvcAuthStatConfResp = new MBA.RadioBox ( _name);

      reqSvcAuthStatConfResp.ID                         = _id;
      reqSvcAuthStatConfResp.title                      = _title;
      reqSvcAuthStatConfResp.name                       = _name;
      reqSvcAuthStatConfResp.firedataselected           = true;      
      reqSvcAuthStatConfResp.labelIsSpan                = false;
      reqSvcAuthStatConfResp.noClear                    = false;
      reqSvcAuthStatConfResp.displaySelectionsVertical  = _displaySelectionsVertical;
      reqSvcAuthStatConfResp.renderLabel                = _renderLabel;
	    reqSvcAuthStatConfResp.onSelectValue              = _onSelectValue;

      reqSvcAuthStatConfResp.AddSelection(ServiceAuthorizationStatusConfirmationResponse.YES_ORP_APPROVED);
      reqSvcAuthStatConfResp.AddSelection(ServiceAuthorizationStatusConfirmationResponse.NO_PENDING_AUTH);
      
      /* Only practitioners should see this option regardless of discipline family.
       * We will vet if the practitioner is allowed to select this on the client side and the backend. */

      if (isYesIAmTheORPAValidPossibleOption(ref rd))
      {         
        reqSvcAuthStatConfResp.AddSelection(ServiceAuthorizationStatusConfirmationResponse.YES_I_AM_THE_ORP);
      }
      
      reqSvcAuthStatConfResp.RenderControl(writer);	
	  }    
  }
}

