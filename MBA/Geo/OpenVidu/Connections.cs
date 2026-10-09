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
   * Connections */
  /**
   * Think of these as the meeting participants
   * 
   * https://docs.openvidu.io/en/2.16.0/reference-docs/REST-API/#post-openviduapisessionsltsession_idgtconnection
   * 
   ***************************************************************************/  
  public class Connections
  {
    /***************************************************************************
     * Method */
    /**
     ***************************************************************************/  
    public static string METHOD (string sessionID) {
      return @"sessions/" + sessionID + @"/connection";
    }
    public static string METHOD (string sessionID,string connectionID) {
      return METHOD(sessionID) + @"/" + connectionID;
    }

    /***************************************************************************
     * CreateConnection */
    /**
     ***************************************************************************/  
	  public static bool CreateConnection  (  string server
                                          , string username
                                          , string password
                                          , string sessionID
                                          , string participantName 
                                          , string participantRoomRole /* SUBSCRIBER, PUBLISHER, MODERATOR*/
                                          , string connectionType      /* WEBRTC, IPCAM */
    					    			                  , out string response)  
    {
      response = @"";
      
      
             
      string method = METHOD(sessionID);
      string data   = @"{""type"":""" + connectionType + @""",""data"":""" + participantName + @""",""record"":false,""role"":""" + participantRoomRole + @"""}";

      return OpenVidu.Common.RequestDataPost (  server
                                              , username
                                              , password
                                              , method
                                              , data
                                              , out response);         
    }

    /***************************************************************************
     * CreateConnectionForUser` */
    /**
     ***************************************************************************/  
	  public static bool CreateConnectionForUser (  string server
                                                , string username
                                                , string password
                                                , string sessionID
                                                , string participantName 
                                                , bool   participantIsFacilitator                                 
							    			                        , out string response)  
    {
      response = @"";
             
      var participantRoomRole = @"PUBLISHER";
      if (participantIsFacilitator == true) participantRoomRole = @"MODERATOR";
      
      var connectionType = @"WEBRTC";    
      return CreateConnection(server,username,password,sessionID,participantName,participantRoomRole,connectionType,out response);
    }
  
    /**************************************************************************
     * GetConnections */
    /**
     * Gets all active connections identified by a sessionID
     ***************************************************************************/      
    public static bool GetConnections  (string server, string username, string password, string sessionID, out string response)  
    {
      response = @"";      
      string method = METHOD(sessionID);

      return OpenVidu.Common.RequestDataGet (server, username, password, method, out response);   
    }
  
    /**************************************************************************
     * GetConnection */
    /**
     * Gets a active connection identified by a sessionID and connectionID
     ***************************************************************************/      
    public static bool GetConnection  (string server, string username, string password, string sessionID, string connectionID, out string response)  
    {
      response = @"";      
      string method = METHOD(sessionID,connectionID);

      return OpenVidu.Common.RequestDataGet (server, username, password, method, out response);   
    }
    
    /**************************************************************************
     * DeleteConnection */
    /**
     * Delete a active connection identified by a sessionID and connectionID
     ***************************************************************************/      
    public static bool DeleteConnection  (string server, string username, string password, string sessionID, string connectionID, out string response)  
    {
      response = @"";      
      string method = METHOD(sessionID,connectionID);
      return OpenVidu.Common.RequestDataDelete (server, username, password, method, out response);   
    }

  }
}
