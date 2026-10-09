using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Web.Script.Serialization;

namespace MBA
{
  
  /***************************************************************************
   * ReturnFileBytes */
  /**
   ***************************************************************************/   

  public class ReturnFileBytes : Return
  {
    public ReturnFileBytes ()                 : base()    {}
    public ReturnFileBytes (string msg)       : base(msg) {}
    public ReturnFileBytes (Exception e)      : base(e)   {}
    public ReturnFileBytes (Warning e)        : base(e)   {}
    public ReturnFileBytes (Critical e)       : base(e)   {}
    public ReturnFileBytes (SessionExpired e) : base(e)   {}
    
    public string contentType;
    public string metaTitle;
    public string fileName;
    public byte[] fileBytes;        
  }
}
