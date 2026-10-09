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
   * FieldSetYesNoUnknownAndEffectiveDate */
  /**
   * Last and first name
   **************************************************************************/

  public class FieldSetYesNoUnknownAndEffectiveDate:FieldSet
  {            
    
    protected MBA.LabelBox      _ctrlYesNoLbl       = new MBA.LabelBox();
    protected MBA.YesNoUnknown  _ctrlYesNoInp       = new MBA.YesNoUnknown();    
	  protected MBA.LabelBox      _ctrlEffDateLbl     = new MBA.LabelBox();
    protected MBA.DateBox       _ctrlEffDateInp     = new MBA.DateBox();       
	  
	  protected string            _parmNameYesNo        = @"yesno";
    protected string            _parmValueYesNo       = @"";	
    protected string            _parmNameEffDate      = @"effdate";
    protected string            _parmValueEffDate     = @"";
	  
    public string  parmNameYesNo          { get { return _parmNameYesNo; }
                                            set { _parmNameYesNo = value; }}
    
    public string  parmValueYesNo         { get { return _parmValueYesNo;}
                                            set { _parmValueYesNo = value ;}}

	  public  string yesNoLabelTitle        { get { return this._ctrlYesNoLbl.title;}
	                                          set { this._ctrlYesNoLbl.title = value;}}

	  public  string yesNoLabelText         { get { return this._ctrlYesNoLbl.text;}
	                                          set { this._ctrlYesNoLbl.text = value;}}
	                                          
	  public  bool   yesNoUseDefaultValue   { get { return this._ctrlYesNoInp.useDefaultValue; } 
	                                          set { this._ctrlYesNoInp.useDefaultValue = value; }}

	  public string  yesNoDefaultValue      { get { return this._ctrlYesNoInp.defaultValue; }
                                            set { this._ctrlYesNoInp.defaultValue = value; }}
    
	  public string  parmNameEffDate        { get { return _parmNameEffDate; }
                                            set { _parmNameEffDate = value; }}
    
    public string  parmValueEffDate       { get { return _parmValueEffDate;}
                                            set { _parmValueEffDate = value;}}

	  public bool   effDateUseDefaultValue  { get { return this._ctrlEffDateInp.useDefaultValue; } 
	                                          set { this._ctrlEffDateInp.useDefaultValue = value; }}
    
    public int    effDateDefaultType      { get { return this._ctrlEffDateInp.defaultType; } 
	                                          set { this._ctrlEffDateInp.defaultType = value; }}
    
    public string effDateDefaultValue     { get { return this._ctrlEffDateInp.defaultValue; } 
	                                          set { this._ctrlEffDateInp.defaultValue = value; }}

    public int    effDateNumMonths        { get { return this._ctrlEffDateInp.numMonths; } 
	                                          set { this._ctrlEffDateInp.numMonths = value; }}
    
    public FieldSetYesNoUnknownAndEffectiveDate () : base()
    {  	    	    	  
  	  this.title                        = @"Enter Yes or No and Effective Date";
  	  this.includeLegend                = true;
  	  this.legendText                   = @"Yes or No and Effective Date";  	  
  	  this._ctrlYesNoLbl.text           = @"Yes or No";
  	  this._ctrlYesNoLbl.title          = @"Yes or No";
  	  this._ctrlEffDateLbl.text         = @"Effective Date";
  	  this._ctrlEffDateLbl.title        = @"Effective Date";
  	  this._ctrlYesNoInp.title          = @"Select or enter Yes or No";
  	  this._ctrlEffDateInp.title        = @"Select or enter date";
  	  this._ctrlEffDateInp.showOK       = false;	  
  	}
  	
  	public string generateStepLabel ()
  	{
  	   	return base.generateStepLabel(  
  	                                  this._parmValueYesNo
  	                                 , @", "
  	                                 , this._parmValueEffDate);

  	}
  	
  	public Step setParentStepLabel()
  	{
  	  return this.setParentStepLabel ( generateStepLabel() );
  	}

  	protected override void Render(HtmlTextWriter writer)
  	{                        
      
      this._ctrlYesNoInp.ID      = Util.createFormFieldIdOrName(_fieldNamePrefix, _parmNameYesNo, this.ID);
      this._ctrlYesNoInp.name    = Util.createFormFieldIdOrName(_fieldNamePrefix, _parmNameYesNo);
      this._ctrlYesNoInp.value   = this._parmValueYesNo;
      
      this._ctrlEffDateInp.ID    = Util.createFormFieldIdOrName(_fieldNamePrefix, _parmNameEffDate, this.ID);
      this._ctrlEffDateInp.name  = Util.createFormFieldIdOrName(_fieldNamePrefix, _parmNameEffDate);
      this._ctrlEffDateInp.value = this._parmValueEffDate;
      
      this._ctrlYesNoLbl.forid   = this._ctrlYesNoInp.ID;
      this._ctrlEffDateLbl.forid = this._ctrlEffDateInp.ID;
            
      this.Controls.Add( new Wrapper(@"span", _ctrlYesNoLbl,   _ctrlYesNoInp));
      this.Controls.Add( new Wrapper(@"span", _ctrlEffDateLbl, _ctrlEffDateInp));
            
      this.fnControlValue = String.Format(@"var vl = $('#{0}').val() + ',' + $('#{1}').val(); return vl;"
                                           , this._ctrlYesNoInp.ID
                                           , this._ctrlEffDateInp.ID);
      
      this.fnControlLabel = String.Format(@"var lbl = $('#{0}').val() + ', ' + $('#{1}').val(); return lbl;"
                                           , this._ctrlYesNoInp.ID
                                           , this._ctrlEffDateInp.ID );
  	  /*-------------------------------
       * Render child controls
       *------------------------------*/

       base.Render(writer);
  	}
  	
  }
}