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
   * SelectCronTabOccurance */
  /**
   * 
   ****************************************************************************/ 
 
  public class SelectCronTabOccurance : RadioBox
  {
    
    public SelectCronTabOccurance() 
    {    
      this.firedataselected = true;      
      this.labelIsSpan      = false;
      this.noClear          = false;
      this._onSelectValue   = @"function(oldval,newval){return true;}";
    }             
   
    protected bool _includeDaily     = true;
    protected bool _includeWeekly    = true;
    protected bool _includeMonthly   = true;
    protected bool _includeQuarterly = true;
    protected bool _includeYearly    = true;

    public bool includeDaily     { get { return _includeDaily;}     set { _includeDaily     = value; } }
    public bool includeWeekly    { get { return _includeWeekly;}    set { _includeWeekly    = value; } }
    public bool includeMonthly   { get { return _includeMonthly;}   set { _includeMonthly   = value; } }
    public bool includeQuarterly { get { return _includeQuarterly;} set { _includeQuarterly = value; } }
    public bool includeYearly    { get { return _includeYearly;}    set { _includeYearly    = value; } }

    public static int getIntValueFromEnum (MBA.Schedule.ScheduleSelection valueInEnum)
    {
      return (int) valueInEnum;
    }
    
    public static string getStringValueFromEnum (MBA.Schedule.ScheduleSelection valueInEnum)
    {
      return getIntValueFromEnum(valueInEnum).ToString();      
    }
   
    public static MBA.Schedule.ScheduleSelection getEnumValueFromString (string valueInStr)
    {
      return (MBA.Schedule.ScheduleSelection) Enum.Parse(typeof(MBA.Schedule.ScheduleSelection),valueInStr,true);
    }

    protected override void OnPreRender(EventArgs e)
    {
      this.addCssClass("ui-spedmon-box-radio-select-cron-tab-occurance");
      this.additionalCssClassNameForContainer = "modern2021";
         
      this.AddSelection(MBA.Schedule.ScheduleSelection.NONE);
         
	  if (this._includeDaily)     this.AddSelection(MBA.Schedule.ScheduleSelection.DAILY);
	  if (this._includeWeekly)    this.AddSelection(MBA.Schedule.ScheduleSelection.START_OF_WEEK);
	  if (this._includeMonthly)   this.AddSelection(MBA.Schedule.ScheduleSelection.START_OF_MONTH);
	  if (this._includeQuarterly) this.AddSelection(MBA.Schedule.ScheduleSelection.START_OF_QUARTER);
	  if (this._includeYearly)    this.AddSelection(MBA.Schedule.ScheduleSelection.START_OF_YEAR);

      base.OnPreRender(e);
    }
 
  }
}