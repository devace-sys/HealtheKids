using System;
using System.Collections.Generic;
using System.Text;
using System.Net;
using Geo.Google;

namespace MBA
{
  /***************************************************************************
   * ReturnGoogleDistanceMatrix */
  /**
   * 
   ***************************************************************************/   
 
  public class ReturnGoogleDistanceMatrix:Return
  {
    public ReturnGoogleDistanceMatrix ()                 : base(){}
    public ReturnGoogleDistanceMatrix (string msg)       : base(msg){}
    public ReturnGoogleDistanceMatrix (Exception e)      : base(e){}
    public ReturnGoogleDistanceMatrix (Warning e)        : base(e){}
    public ReturnGoogleDistanceMatrix (Critical e)       : base(e){}  
    public ReturnGoogleDistanceMatrix (SessionExpired e) : base(e){}
        
    public string  originIn;
	  public string  destinationIn;
	  public string  originOut;
	  public string  destinationOut;
	  public string  durationInSeconds;
	  public string  durationInMinutes;
	  public string  distanceInMiles;
    public string  distanceInMeters;
    public string  requestData;
    public string  responseData;
    public string  mapsURL; 
  }
}
