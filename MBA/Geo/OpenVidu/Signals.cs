using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Web;
using System.Net.Security;
using System.Web.Script.Serialization;
using System.Collections.Specialized;

namespace Geo.OpenVidu
{

/***************************************************************************
 * Signal */
/**
 * 
 * {"session": "SESSION_ID"
 * , "to": ["connectionId1", "connectionId2"]
 * , "type": "MY_TYPE"
 * , "data": "This is my signal data"} 
 * 
 ***************************************************************************/   
public class Signal 
{
  public Signal():this("","","") {
  }

  public Signal(string session, string type, string data) {
    this.session = session;
    this.type    = type;
    this.data    = data;
    this.to      = new string[0];
  }
 
  public string   session;
  public string[] to;
  public string   type;
  public string   data;
}

/***************************************************************************
 * Signals */
/**
 * 
 * 
 * 
 ***************************************************************************/  
public class Signals
{  
    /***************************************************************************
     * Send */
    /**
     * https://docs.openvidu.io/en/2.14.0/reference-docs/REST-API/#post-apisignal
	   ***************************************************************************/  
    public static bool Send  (  string   server
                              , string   username
                              , string   password
                              , Signal   signal
                              , out string response)  
    {
      
      var ser = new System.Web.Script.Serialization.JavaScriptSerializer(); 
      signal.type = @"signal:" + signal.type; /* REST API needs signal: prepended to type */
      string data = ser.Serialize(signal);     
      return OpenVidu.Common.RequestDataPost (server, username, password,@"signal",data,out response);   
    }
  }

  
}
