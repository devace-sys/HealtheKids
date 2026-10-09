using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MBA
{
  /***************************************************************************
   * Field */
  /**
   * Something having a name, value, and a type.
   ***************************************************************************/   

  public class Field
  {
    public string name;                       // Name
    public object value;                      // Value
    public string typename;                   // Internal type name or user specified type name
	      
  }
}
