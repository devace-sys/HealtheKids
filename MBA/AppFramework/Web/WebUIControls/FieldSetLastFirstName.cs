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
   * FieldSetLastFirstName */
  /**
   * Last and first name
   **************************************************************************/

  public class FieldSetLastFirstName:FieldSet
  {            
    
    protected string  _fmtStepLabel = @"{0}, {1}";
    
    protected MBA.LabelBox     _ctrlLastNameLbl     = new MBA.LabelBox();
    protected MBA.Input        _ctrlLastNameInp     = new MBA.Input();
    protected MBA.LabelBox     _ctrlFirstNameLbl    = new MBA.LabelBox();
    protected MBA.Input        _ctrlFirstNameInp    = new MBA.Input();   
    protected string           _lastNameFormName    = @"lname";
    protected string           _firstNameFormName   = @"fname";
    protected string           _lastNameFormValue   = @"";
    protected string           _firstNameFormValue  = @"";
    
    public string lastNameFormName      { get { return _lastNameFormName;  }  set { _lastNameFormName   = value; }}
    public string firstNameFormName     { get { return _firstNameFormName; }  set { _firstNameFormName  = value; }}
    public string lastNameFormValue     { get { return _lastNameFormValue; }  set { _lastNameFormValue  = value; }}
    public string firstNameFormValue    { get { return _firstNameFormValue;}  set { _firstNameFormValue = value; }}
    
    public FieldSetLastFirstName () : base()
    {  	    	    	  
  	  this.title                            = @"Enter name";
  	  this.includeLegend                    = true;
  	  this.legendText                       = @"Name";  	  
  	  this._ctrlLastNameLbl.text            = @"Last";
  	  this._ctrlLastNameInp.title           = @"Enter last name";
  	  this._ctrlLastNameInp.cssInline       = "width:20em";  	    	
  	  this._ctrlFirstNameLbl.text           = @"First";
  	  this._ctrlFirstNameInp.title          = @"Enter first name";
  	  this._ctrlFirstNameInp.cssInline      = "width:20em";  	  
  	}
  	
  	public string generateStepLabel ()
  	{
  	  return String.Format(_fmtStepLabel,this._lastNameFormValue, this._firstNameFormValue);  	  
  	}
  	
  	public Step setParentStepLabel()
  	{
  	  return this.setParentStepLabel ( generateStepLabel() );
  	}

  	protected override void Render(HtmlTextWriter writer)
  	{                  
      
      this._ctrlLastNameInp.ID     = Util.createFormFieldIdOrName(_fieldNamePrefix, _lastNameFormName, this.ID);
      this._ctrlLastNameInp.name   = Util.createFormFieldIdOrName(_fieldNamePrefix, _lastNameFormName);
      this._ctrlLastNameInp.value  = this._lastNameFormValue;
      
      this._ctrlFirstNameInp.ID    = Util.createFormFieldIdOrName(_fieldNamePrefix, _firstNameFormName,this.ID);      
      this._ctrlFirstNameInp.name  = Util.createFormFieldIdOrName(_fieldNamePrefix, _firstNameFormName);
      this._ctrlFirstNameInp.value = this._firstNameFormValue;
      
      this._ctrlLastNameLbl.forid  = this._ctrlLastNameInp.ID;
      this._ctrlFirstNameLbl.forid = this._ctrlFirstNameInp.ID;
            
      this.Controls.Add( new Wrapper(@"span", _ctrlLastNameLbl,  _ctrlLastNameInp));
      this.Controls.Add( new Wrapper(@"span", _ctrlFirstNameLbl, _ctrlFirstNameInp));
      
      
      this.fnControlValue = String.Format(@"var vl = $('#{0}').val() + ',' + $('#{1}').val(); return vl;"
                                           , this._ctrlLastNameInp.ID
                                           , this._ctrlFirstNameInp.ID);
      
      this.fnControlLabel = String.Format(@"var lbl = $('#{0}').val() + ', ' + $('#{1}').val(); return lbl;"
                                           , this._ctrlLastNameInp.ID
                                           , this._ctrlFirstNameInp.ID );
  	   /*-------------------------------
        * Render child controls
        *------------------------------*/

       base.Render(writer);
  	}
  	
  }
}