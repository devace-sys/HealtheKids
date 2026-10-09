using System;
using System.Collections;
using System.Globalization;
using System.Threading;
using System.Text;
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
   * FieldSetPracIsValidMCALORP */
  /**
   * Practitioner is a valid Ordering, Referring and Prescribing practitioner
   **************************************************************************/

  public class FieldSetPracIsValidMCALORP:FieldSet
  {            
    
    protected MBA.LabelBox      _ctrlIsValidLbl       = new MBA.LabelBox();
    protected MBA.YesNoUnknown  _ctrlIsValidInp       = new MBA.YesNoUnknown();    
	  
	  protected MBA.LabelBox      _ctrlLastValidatedLbl = new MBA.LabelBox();
    protected MBA.DateBox       _ctrlLastValidatedInp = new MBA.DateBox();
    
    protected MBA.LinkExternal  _ctrlOrpValidationLnk = new MBA.LinkExternal();
    protected MBA.LinkExternal  _ctrlOrpInfoLnk       = new MBA.LinkExternal();
    
    protected string   _orpIsValidFormName            = @"is_valid_mcal_orp";
    protected string   _orpIsValidFormValue           = @"";
        
    protected string   _orpLastValidatedFormName      = @"is_valid_mcal_orp_last_validated";
    protected string   _orpLastValidatedFormValue     = @"";
    
    public string isValidParmName        { get { return _orpIsValidFormName; }       set { _orpIsValidFormName        = value; }}
    public string isValidParmValue       { get { return _orpIsValidFormValue; }      set { _orpIsValidFormValue       = value; }}
    public string lastValidatedParmName  { get { return _orpLastValidatedFormName;}  set { _orpLastValidatedFormName  = value; }}
    public string lastValidatedParmValue { get { return _orpLastValidatedFormValue;} set { _orpLastValidatedFormValue = value; }}
           
    public FieldSetPracIsValidMCALORP () : base()
    {  	    	    	  
  	  this.title                           = @"Practitioner is a valid Ordering, Referring and Prescribing (ORP) practitioner";
  	  this.includeLegend                   = true;
  	  this.legendText                      = @"Practitioner is a Valid ORP";
  	  
  	  this._ctrlIsValidLbl.text            = @"Is Valid?";
      this._ctrlIsValidInp.title           = @"Select or enter Yes or No";
      
  	  //this._ctrlIsValidInp.cssInline       = @"width:12em";
  	  
  	  this._ctrlLastValidatedLbl.text      = @"Last Validated On";
  	  this._ctrlLastValidatedInp.showOK    = false;  	  
  	  this._ctrlLastValidatedInp.title     = @"Select or Enter Date";
  	  this._ctrlLastValidatedInp.cssInline = @"width:12em";
  	  
  	  this._ctrlOrpValidationLnk.text                = @"ORP Enrollment Validation Lookup";
  	  this._ctrlOrpValidationLnk.title               = @"Click here to open the CA DHS ORP Directory Lookup Tool. Please note that you may have to scroll down to see the validation tool.";
  	  this._ctrlOrpValidationLnk.url                 = @"https://mcweb.apps.prd.cammis.medi-cal.ca.gov/orp/orp-enroll";
  	  
  	  this._ctrlOrpInfoLnk.text                      = @"Additional Information on ORP Enrollment";
  	  this._ctrlOrpInfoLnk.title                     = @"Click here to open the CA DHS ORP Page";
  	  this._ctrlOrpInfoLnk.url                       = @"https://www.dhcs.ca.gov/provgovpart/Documents/ACLSS/LEA%20BOP/Program_Req_and_Info/ORP-Req-Guide.pdf";
  	}
  	
  	public string generateStepLabel ()
  	{
  	  return base.generateStepLabel(  this._orpIsValidFormValue
  	                                , @", "  	                                  	                                
  	                                , this._orpLastValidatedFormValue);
  	}
  	
  	public Step setParentStepLabel()
  	{
  	  return this.setParentStepLabel ( generateStepLabel() );
  	}

  	protected override void Render(HtmlTextWriter writer)
  	{                  
      
      this._ctrlIsValidInp.ID          = Util.createFormFieldIdOrName(_fieldNamePrefix, _orpIsValidFormName, this.ID);
      this._ctrlIsValidInp.name        = Util.createFormFieldIdOrName(_fieldNamePrefix, _orpIsValidFormName);
      this._ctrlIsValidInp.value       = this._orpIsValidFormValue;
      
      this._ctrlLastValidatedInp.ID    = Util.createFormFieldIdOrName(_fieldNamePrefix, _orpLastValidatedFormName,this.ID);
      this._ctrlLastValidatedInp.name  = Util.createFormFieldIdOrName(_fieldNamePrefix, _orpLastValidatedFormName);
      this._ctrlLastValidatedInp.value = this._orpLastValidatedFormValue;
      
      this._ctrlIsValidLbl.forid       = this._ctrlIsValidInp.ID;
      this._ctrlLastValidatedLbl.forid = this._ctrlLastValidatedInp.ID;
            
      this._ctrlLnks.Controls.Add(new Wrapper(@"div",_ctrlOrpValidationLnk));
      this._ctrlLnks.Controls.Add(new Wrapper(@"div",_ctrlOrpInfoLnk));
      this.Controls.Add( _ctrlLnks );
        
      this.Controls.Add( new Wrapper(@"span",_ctrlIsValidLbl,       _ctrlIsValidInp));
      this.Controls.Add( new Wrapper(@"span",_ctrlLastValidatedLbl, _ctrlLastValidatedInp));
      
      
      this.fnControlValue = String.Format(@"var vl = $('#{0}').val() + ',' + $('#{1}').val(); return vl;"
                                           , this._ctrlIsValidInp.ID
                                           , this._ctrlLastValidatedInp.ID);
      
      this.fnControlLabel = String.Format(@"var lbl = $('#{0}').val() + ', ' + $('#{1}').val(); return lbl;"
                                           , this._ctrlIsValidInp.ID
                                           , this._ctrlLastValidatedInp.ID );
  	   /*-------------------------------
        * Render child controls
        *------------------------------*/

       base.Render(writer);
  	}
  	
  }
}