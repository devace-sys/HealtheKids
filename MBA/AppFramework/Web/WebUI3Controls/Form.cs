using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;

using EAW.Web.UI;
using EAW.Web.UI.Controls.Attributes;
using EAW.Web.UI.Controls.Base;
using EAW.Web.UI.Controls;

namespace MBA.WebUI3Controls
{

  
  public class Form : EAW.Web.UI.Controls.Form
  {
    
    private bool       _statusList     = false;
    private string      _statusListID    = @"";
    private string      _statusListClass = @"";

    private bool       _submitButton     = false;
    private string      _submitButtonID  = @"";
    private string      _submitButtonClass = @"";
    private ChildMarkup _submitButtonContentMarkup = new ChildMarkup();
 

    /// <summary>
		/// Render a unordered list to use as a status list
		/// </summary>
		/// <value>True or False</value>
    
    [Description("Render a status list?"), Category("Render Option"), DefaultValue(false)] 
    public bool StatusList { get { return _statusList; } set {_statusList = value;}}

   /// <summary>
		/// Render a submit button?
		/// </summary>
		/// <value>True or False</value>
    
    [Description("Render a submit button?"), Category("Render Option"), DefaultValue(false)] 
    public bool SubmitButton { get { return _submitButton; } set {_submitButton = value;}}

    /// <summary>
		/// Gets or sets the submit button CSS class
		/// </summary>
		/// <value>String</value>
    
    [Description("The submit button CSS class.  Used in HTML forms."), Category("Render Option"), DefaultValue(null)] 
    public string SubmitButtonClass { get { return _submitButtonClass; } set {_submitButtonClass = value;}}

    [Description("Submit button content"), Category("Render Option"), DefaultValue(false)] 
	  public string SubmitButtonContentMarkup { get { return  _submitButtonContentMarkup.Markup; } set {  _submitButtonContentMarkup.Markup = value; } }

    [Description("Submit button ID"), Category("Render Option"), DefaultValue(false)] 
		public string SubmitButtonID { get { return _submitButtonID; } set {_submitButtonID = value;}}

    /// <summary>
    [Description("Status list ID"), Category("Render Option"), DefaultValue(false)] 
    public string StatusListID { get { return _statusListID; } set {_statusListID = value;}}

  	protected override void Render (HtmlTextWriter writer)
		{
			
      if (_submitButton) 
      {        
        var sb = new EAW.Web.UI.Controls.Button(ButtonType.submit);
        sb.ID    = _submitButtonID;
        sb.Class = _submitButtonClass;
        sb.AppendChildControl(_submitButtonContentMarkup);
        this.AppendChildControl(sb);
      }

      if (_statusList) {
        var ul = new Notifications(_statusListID);
        this.AppendChildControl(ul);
      }
                 
      base.Render (writer);
		}
	}
}



