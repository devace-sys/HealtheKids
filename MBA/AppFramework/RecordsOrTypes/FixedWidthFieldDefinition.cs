using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MBA
{
  /**************************************************************************
   * FixedWidthFieldDefinition */
  /**
   * 
   * 
   ***************************************************************************/

  public class FixedWidthFieldDefinition
  {  
      public int    fieldNum;
      public string fieldName;
      public int    size;
      public int    startPos;
      public int    endPos;
      public bool   visible;
      public bool   padRight = true;
  }

}
