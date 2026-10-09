using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MBA
{
  /***************************************************************************
   * NameValue */
  /**
   ***************************************************************************/   
  
  public class NameValue:Field
  {
    public NameValue(){}
    public NameValue(string n, string v) { this.name = n; this.value = v;}
    public NameValue(string n, int v)    { this.name = n; this.value = v.ToString();}
    public NameValue(string n, long v)   { this.name = n; this.value = v.ToString();}
    public NameValue(string n, bool v)   { this.name = n; this.value = Util.boolTo1or0Str(v); }
    public NameValue(string n, Object v) {this.name = n;  this.value = v; }
    public NameValue(string n, string v, string t) {this.name = n; this.value = v; this.typename = t;}
    public NameValue(string n, Object v, string t) {this.name = n; this.value = v; this.typename = t;}
  }
}
