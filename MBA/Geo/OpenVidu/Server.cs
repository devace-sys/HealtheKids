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
 * Server */
/**
 * 
 * 
 * 
 ***************************************************************************/  
public class Server
{  
   /***************************************************************************
    * GetActiveConfig */
   /**
    * 
   ***************************************************************************/  
   public static bool GetActiveConfig  (   string   server
                                         , string   username
                                         , string   password
                                         , out string response)  
   {
	   return OpenVidu.Common.RequestDataGet (server, username, password, @"config", out response);   
   }
  }  
}
