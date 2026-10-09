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
 * Sessions */
/**
 * Think of these as the meetings
 * 
 * https://openvidu.io/docs/reference-docs/REST-API/#post-apisessions
 * 
 ***************************************************************************/  
public class Sessions
{  
    /***************************************************************************
     * Method */
    /**
     ***************************************************************************/  
    public static string METHOD () {
      return @"sessions";
    }
    public static string METHOD (string sessionID) {
      return METHOD(sessionID) + @"/" + sessionID;
    }

    /***************************************************************************
     * CreateSession */
    /**
     ***************************************************************************/  
    public static bool CreateSession  (string server, string username, string password, string sessionID, out string response)  
    {
      response = @"";
      string data = @"{""customSessionId"":""" + sessionID + @"""}";
      return OpenVidu.Common.RequestDataPost (server, username, password,Sessions.METHOD(),data,out response);   
    }

    /***************************************************************************
     * GetSessions */
    /**
     * Gets all active sessions
     ***************************************************************************/  
    
    public static bool GetSessions  (string server, string username, string password, out string response)  
    {
      response = @"";      
      return OpenVidu.Common.RequestDataGet (server, username, password, Sessions.METHOD(), out response);   
    }

    /***************************************************************************
     * GetSession */
    /**
     * Gets a single active session identified by sessionID
     ***************************************************************************/      
    public static bool GetSession  (string server, string username, string password, string sessionID, out string response)  
    {
      response = @"";      
      return OpenVidu.Common.RequestDataGet (server, username, password, Sessions.METHOD(sessionID), out response);   
    }
    
    /***************************************************************************
     * DeleteSession */
    /**
     * Deletes a single active session identified by sessionID
     ***************************************************************************/      
   
    public static bool DeleteSession (string server, string username, string password, string sessionID, out string response)
    {
      response = @"";      
      return OpenVidu.Common.RequestDataDelete (server, username, password, Sessions.METHOD(sessionID), out response);   
    }


  }
}
