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
   * EmploymentRelationship */
  /**
   ****************************************************************************/
  
  public enum EmploymentRelationship
  {      
      EMPLOYEE    = 10
    , CONTRACTOR  = 20
    , NONE        = 30
    , UNKNOWN     = 99
  }
  
  /**************************************************************************
  * SelectEmploymentRelationship */
  /**
   *
   ****************************************************************************/ 

  public class SelectEmploymentRelationship:ControlBase
  {
    
    public SelectEmploymentRelationship() 
    {    
    }
    
	protected string        _id                  = @"employment_relationship";
	protected string        _title               = @"Select employment relationship";
	protected string        _name                = @"employment_relationship";
    
    protected EmploymentRelationship  _value     = EmploymentRelationship.EMPLOYEE;
    protected string                  _valueStr  = "";
	      
    //private new String ID;
    public string                 id    { get { return _id;    } set { _id    = value; } }
    public string                 name  { get { return _name;  } set { _name  = value; } }
    public string                 title { get { return _title; } set { _title = value; } }
    public EmploymentRelationship value { get { return _value; } set { _value = value; } }
    
    public static int getIntValueFromEnum (EmploymentRelationship valueInEnum)
    {
      return (int) valueInEnum;
    }
    
    public static string getStringValueFromEnum (EmploymentRelationship valueInEnum)
    {
      return getIntValueFromEnum(valueInEnum).ToString();      
    }
   
    public static EmploymentRelationship getEmumValueFromString (string valueInStr)
    {
      return (EmploymentRelationship) Enum.Parse(typeof(EmploymentRelationship),valueInStr,true);
    }
   
	  protected override void Render (HtmlTextWriter writer) { 
	  
	    _valueStr = ((int)_value).ToString();           
      MBA.RadioBox employmentRelationships = new MBA.RadioBox ( _name, _valueStr);
      employmentRelationships.ID               = _id;
      employmentRelationships.title            = _title;
      employmentRelationships.name             = _name;
      employmentRelationships.firedataselected = true;
      employmentRelationships.labelIsSpan      = false;
      employmentRelationships.noClear          = false;
      employmentRelationships.additionalCssClassNameForContainer = @"modern2021";
      
      employmentRelationships.AddSelection("Employee",        ((int) EmploymentRelationship.EMPLOYEE).ToString());
      employmentRelationships.AddSelection("Contractor",      ((int) EmploymentRelationship.CONTRACTOR).ToString());
      employmentRelationships.AddSelection("No Relationship", ((int) EmploymentRelationship.NONE).ToString());
            
      employmentRelationships.RenderControl(writer);	
	  }    
  }
}

