using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Geo.CDE
{
  public class SchoolDirectoryEntry
  {    
    public String CdeDirectoryUrl;
    public String CdeProfileUrl;
    
    public String CountyName;
    public String DistrictName;
    public String SchoolName;
    
    public String CdsCode;
    public String CdsCodeFirst7;
    public String CdsCodeLast7;
    public String CdsCodeCounty;
    public String CdsCodeDistrict;
    public String CdsCodeSite;
    
    public String       StreetAddressLine;    
    public USPS.Address StreetAddress;
    
    public String       MailingAddressLine;    
    public USPS.Address MailingAddress;
    
    public String GoogleMapsUrl;
    
  }
}
