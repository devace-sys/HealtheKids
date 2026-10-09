using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.Net.Sockets;

namespace MBA
{
  public class Network
  {
    /***************************************************************************
     * GetMyUserName */
    /**
     * Returns the current network user name
     *
     * @return  string
     ***************************************************************************/
    
    public static string GetMyUserName()
    {
      string ntuser = Environment.UserName;
      return ntuser;
    }
    
    /***************************************************************************
     * GetMyIPAddress */
    /**
     * Returns the current network users ip address
     *
     * @return  string
     ***************************************************************************/
    
    public static string GetMyIPAddress()
    {      
      IPHostEntry host;
      string localIP = "?";
      host = Dns.GetHostEntry(Dns.GetHostName());
      
      foreach (IPAddress ip in host.AddressList)
      {
        if (ip.AddressFamily == AddressFamily.InterNetwork)
        {
          localIP = ip.ToString();
        }
      }
      
      return localIP;  
    }
  }
}
