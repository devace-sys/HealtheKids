using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MBA
{
  /***************************************************************************
   * Machine */
  /**
   * What machine is the application or service running on
   ***************************************************************************/    
  
  public class Machine
  {
    /// ***********************************************************************
    /// * GetMachineName()
    /// ***********************************************************************
    /// 
    /// <summary>
    ///   Returns the name of the machine this process is running on.
    /// </summary>
    /// <returns>string</returns>
    ///
    /// ***********************************************************************
    
    public static string GetMachineName()
    {
      string value = System.Environment.MachineName;
      return value;
    }
  
  }
}
