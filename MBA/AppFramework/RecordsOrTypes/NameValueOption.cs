using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MBA
{
  /***************************************************************************
   * NameValueOption */
  /**
   ***************************************************************************/   
  
  public class NameValueOption:NameValue
  {
    public NameValueOption():base(){}	
    public NameValueOption(NameValue nv, bool hidden = false, bool disabled = false):base(nv.name,nv.value){
      if (String.IsNullOrWhiteSpace(nv.typename)) this.typename = @"";
      this.hidden   = hidden;
      this.disabled = disabled;
    }
	public NameValueOption (string n, string v, bool hidden = false, bool disabled = false):base(n,v){
      this.hidden   = hidden;
      this.disabled = disabled;
      this.typename = @"";
    }
    public NameValueOption (string n, int v, bool hidden = false, bool disabled = false):base(n,v) {
      this.hidden   = hidden;
      this.disabled = disabled;
      this.typename = @"";
    }
    public NameValueOption (string n, long v, bool hidden = false, bool disabled = false):base(n,v){ 
      this.hidden   = hidden;
      this.disabled = disabled;
      this.typename = @"";
    }
    public NameValueOption (string n, bool v, bool hidden = false, bool disabled = false):base(n,v){ 
      this.hidden   = hidden;
      this.disabled = disabled;
      this.typename = @"";
    }
    public NameValueOption (string n, string v, string optgroup, bool hidden = false, bool disabled = false):base(n,v,optgroup){
      this.hidden   = hidden;
      this.disabled = disabled;      
    }
    public NameValueOption (string n, Object v, string optgroup, bool hidden = false, bool disabled = false):base(n, v, optgroup) {
      this.hidden   = hidden;
      this.disabled = disabled;      
    }

	public bool disabled = false;
    public bool hidden   = false;
    public bool selected = false; 
  }
}
