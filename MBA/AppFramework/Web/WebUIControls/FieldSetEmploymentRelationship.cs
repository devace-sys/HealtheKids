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
   * FieldSetEmploymentRelationship */
  /**
   * Employment relationship
   **************************************************************************/

  public class FieldSetEmploymentRelationship:FieldSet
  {            
    
    protected MBA.SelectEmploymentRelationship _ctrlEmployeeRelationshipInp  = new MBA.SelectEmploymentRelationship();

    protected MBA.DataEntryBoxText  _ctrlEmployeeIdInp          = new MBA.DataEntryBoxText();    
    protected MBA.DataEntryBoxDate  _ctrlStartDateInp           = new MBA.DataEntryBoxDate();   
    protected MBA.DataEntryBoxDate  _ctrlEndDateInp             = new MBA.DataEntryBoxDate();
       
    protected string                   _relationshipFormName    = @"employee_relationship";
    protected EmploymentRelationship   _relationshipFormValue   = EmploymentRelationship.EMPLOYEE;
    
    protected string                   _employeeIdFormName      = @"employee_id";
    protected string                   _employeeIdFormValue     = @"";
       
    protected string                   _startDateFormName       = @"start_date";
    protected string                   _startDateFormValue      = @"";
    
    protected string                   _endDateFormName         = "end_date";
    protected string                   _endDateFormValue        = @"";
    
    public string  parmNameRelationship  { get { return _relationshipFormName; }
                                           set { _relationshipFormName      = value; }}
    
    public string  parmValueRelationship { get { return SelectEmploymentRelationship.getStringValueFromEnum(_relationshipFormValue);}
                                           set { _relationshipFormValue = SelectEmploymentRelationship.getEmumValueFromString(value);}}
    
    public string  parmNameEmployeeId    { get { return _employeeIdFormName;}
                                           set { _employeeIdFormName  = value; }}
    
    public string  parmValueEmployeeId   { get { return _employeeIdFormValue;}
                                           set { _employeeIdFormValue = value; }}
           
    public string  parmNameStartDate     { get { return _startDateFormName;}
                                           set { _startDateFormName  = value; }}
                                           
    public string  parmValueStartDate    { get { return _startDateFormValue;}
                                           set { _startDateFormValue = value; }}
    
    public string  parmNameEndDate       { get { return _endDateFormName;}
                                           set { _endDateFormName  = value; }}
                                           
    public string  parmValueEndDate      { get { return _endDateFormValue;}
                                           set { _endDateFormValue = value; }}
    
    public FieldSetEmploymentRelationship () : base()
    {  	    	    	  
  	  this.title                           = @"Employment Relationship";
  	  this.includeLegend                   = true;
  	  this.legendText                      = @"Employment Relationship";
  	    	  
  	  this._ctrlEmployeeIdInp.title        = @"Employee identification";
      this._ctrlEmployeeIdInp.label        = @"Employee ID";
      this._ctrlEmployeeIdInp.maxLen       = 500; 
  	  
  	  this._ctrlStartDateInp.title         = @"Starting date of relationship";
      this._ctrlStartDateInp.label         = "Start Date";
  	    	  
      this._ctrlEndDateInp.title           = @"Ending date of relationship";
      this._ctrlEndDateInp.label           = "End Date";
  	}
  	
  	public string generateStepLabel ()
  	{      
  	  
  	  return base.generateStepLabel(  
  	                                  Enum.GetName(typeof(EmploymentRelationship), this._relationshipFormValue)
  	                                , @", "  	                                  	                                
  	                                , this._employeeIdFormValue
  	                                , @", "  	                                  	                                
  	                                , this._startDateFormValue
  	                                , @", "  	                                  	                                
  	                                , this._endDateFormValue

  	                                );
  	}
  	
  	public Step setParentStepLabel()
  	{
  	  return this.setParentStepLabel ( generateStepLabel() );
  	}
  	  	
  	protected override void Render(HtmlTextWriter writer)
  	{                  
      /* Note lowercase id instead of ID for _ctrlEmployeeRelationshipInp*/
      
      this._ctrlEmployeeRelationshipInp.id      = Util.createFormFieldIdOrName(_fieldNamePrefix, this._relationshipFormName, this.ID);
      this._ctrlEmployeeRelationshipInp.name    = Util.createFormFieldIdOrName(_fieldNamePrefix, this._relationshipFormName);
      this._ctrlEmployeeRelationshipInp.value   = this._relationshipFormValue;

      this._ctrlEmployeeIdInp.ID    = Util.createFormFieldIdOrName(_fieldNamePrefix, this._employeeIdFormName, this.ID);
      this._ctrlEmployeeIdInp.name  = Util.createFormFieldIdOrName(_fieldNamePrefix, this._employeeIdFormName);
      this._ctrlEmployeeIdInp.value = this._employeeIdFormValue;
      this._ctrlEmployeeIdInp.size  = 15;
      
      this._ctrlStartDateInp.ID     = Util.createFormFieldIdOrName(_fieldNamePrefix, this._startDateFormName, this.ID);
      this._ctrlStartDateInp.name   = Util.createFormFieldIdOrName(_fieldNamePrefix, this._startDateFormName);
      this._ctrlStartDateInp.setValue (this._startDateFormValue);

      this._ctrlEndDateInp.ID       = Util.createFormFieldIdOrName(_fieldNamePrefix, this._endDateFormName, this.ID);
      this._ctrlEndDateInp.name     = Util.createFormFieldIdOrName(_fieldNamePrefix, this._endDateFormName);
      this._ctrlEndDateInp.setValue (this._endDateFormValue);
                                
      this.Controls.Add( new Wrapper(@"div",_ctrlEmployeeRelationshipInp));
      
      this.Controls.Add(_ctrlEmployeeIdInp);
      this.Controls.Add(_ctrlStartDateInp);
      this.Controls.Add(_ctrlEndDateInp);
                                          
      this.fnControlValue = String.Format(@"var vl = $('#{0}').val() + ',' + $('#{1}').val() + ',' + $('#{2}').val() + ',' + $('#{3}').val(); return vl;"
                                           , this._ctrlEmployeeRelationshipInp.id
                                           , this._ctrlEmployeeIdInp.ID
                                           , this._ctrlStartDateInp.ID
                                           , this._ctrlEndDateInp.ID);
      
      this.fnControlLabel = String.Format(@"var lbl = $('#{0}').attr('data-selected-label') + ', ' + $('#{1}').val() + ', ' + $('#{2}').val() + ', ' + $('#{3}').val(); return lbl;"
                                           , this._ctrlEmployeeRelationshipInp.id
                                           , this._ctrlEmployeeIdInp.ID 
                                           , this._ctrlStartDateInp.ID
                                           , this._ctrlEndDateInp.ID
                                           );
  	   /*-------------------------------
        * Render child controls
        *------------------------------*/

       base.Render(writer);
  	}
  	
  }
}