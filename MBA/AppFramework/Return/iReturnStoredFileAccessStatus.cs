using System;
using System.Collections.Generic;
using System.Text;
using EAW.MediaFile;

namespace MBA
{
  
   
  /***************************************************************************
   * iReturnStoredFileAccessStatus */
  /**
   * Stored file access
   ***************************************************************************/   
 
  public interface iReturnStoredFileAccessStatus
  {
    
    bool accessGranted { get; set; }
	long clientID { get; set; }

  }
}
