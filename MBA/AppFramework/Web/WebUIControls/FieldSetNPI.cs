using System;
using System.Collections;
using System.Globalization;
using System.Threading;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text.RegularExpressions;

namespace MBA
{
  
  /**************************************************************************
   * FieldSetNPI */
  /**
   * National Provider ID
   **************************************************************************/

  public class FieldSetNPI:FieldSet
  {            
    
    //protected MBA.LabelBox     _ctrlNumLbl           = new MBA.LabelBox();
    //protected MBA.Input        _ctrlNumInp           = new MBA.Input();
    protected MBA.DataEntryBoxText  _ctrlNumInp = new MBA.DataEntryBoxText();

    protected MBA.LinkExternal _ctrlNpiLnk           = new MBA.LinkExternal();
    
    protected string   _npiNumFormName            = @"npi_number";
    protected string   _npiNumFormValue           = @"";
    
    public string numParmName            { get { return _npiNumFormName; }           set { _npiNumFormName            = value; }}
    public string numParmValue           { get { return _npiNumFormValue; }          set { _npiNumFormValue           = value; }}
           
    public FieldSetNPI () : base()
    {  	    	    	  
  	  this.title                           = @"National Provider ID (NPI)";
  	  this.includeLegend                   = true;
  	  this.legendText                      = @"National Provider ID (NPI)";
  	  //this._ctrlNumLbl.text                = @"NPI #";
  	  
      this._ctrlNumInp.label               = @"National Provider ID (NPI)";
      this._ctrlNumInp.minLen              = 10; 
      this._ctrlNumInp.maxLen              = 10;
      this._ctrlNumInp.title               = @"Enter 10 digit NPI#";
      this._ctrlNumInp.size                = 20;
      this._ctrlNpiLnk.text                = @"Public NPI Registry";
  	  this._ctrlNpiLnk.title               = @"Click here to open the National Plan & Provider Enumeration System's Public NPI Registry";
  	  this._ctrlNpiLnk.url                 = @"https://npiregistry.cms.hhs.gov/";      
  	}
  	
  	public string generateStepLabel ()
  	{
  	  return base.generateStepLabel( this._npiNumFormValue );  	  
  	}
  	
  	public Step setParentStepLabel()
  	{
  	  return this.setParentStepLabel ( generateStepLabel() );
  	}

  	protected override void Render(HtmlTextWriter writer)
  	{                        
      this._ctrlNumInp.ID        = Util.createFormFieldIdOrName(_fieldNamePrefix, _npiNumFormName, this.ID);
      this._ctrlNumInp.name      = Util.createFormFieldIdOrName(_fieldNamePrefix, _npiNumFormName);
      this._ctrlNumInp.value     = this._npiNumFormValue;           
      //this._ctrlNumLbl.forid     = this._ctrlNumInp.ID;
      
      this._ctrlLnks.Controls.Add(new Wrapper(@"div", _ctrlNpiLnk));
           

      this.Controls.Add(_ctrlNumInp);

      this.Controls.Add( new Wrapper(@"span",_ctrlLnks));
      
      this.fnControlValue = String.Format(@"var vl = $('#{0}').val(); return vl;"
                                           , this._ctrlNumInp.ID
                                           );
      
      this.fnControlLabel = String.Format(@"var lbl = $('#{0}').val(); return lbl;"                                           
                                           , this._ctrlNumInp.ID 
                                           );
  	   /*-------------------------------
        * Render child controls
        *------------------------------*/

       base.Render(writer);
  	}
  	
  }
}