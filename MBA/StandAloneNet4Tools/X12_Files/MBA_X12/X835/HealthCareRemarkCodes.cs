using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using OopFactory.X12.Parsing;
using OopFactory.X12.Parsing.Model;

namespace MBA.X12.X835
{     
  public class HealthCareRemarkCode
  {
    public HealthCareRemarkCode():this(@"",@"")
    {     
    }
    
    public HealthCareRemarkCode (  string codeListQualifierCode
                                 , string industryCode )
    {
      this.CodeListQualifierCode  = codeListQualifierCode;
      this.IndustryCode           = industryCode;
    }

    public String   CodeListQualifierCode    { get; set; }
    public String   IndustryCode             { get; set; }
  }      
}
