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
   * SelectPractitionerORP */
  /**
   * ComboBox with options prefilled to select ORP
   * TODO : This is used in the service auth request right now.
   * Get rid of it when we refactor the service auth request page to use
   * the new form stuff
   ****************************************************************************/
  public class SelectPractitionerORP:ComboBox 
  {
    public SelectPractitionerORP ()                          : base()            { }
    public SelectPractitionerORP (string name, string value) : base(name, value) { }

    protected string _controlIDClientID            = @"clientid";
    protected string _controlIDGroupSvcClassNameID = @"groupserviceclassnameid";
    public string controlIDClientID            {get { return this._controlIDClientID;}            set {this._controlIDClientID            = value;}}
	  public string controlIDGroupSvcClassNameID {get { return this._controlIDGroupSvcClassNameID;} set {this._controlIDGroupSvcClassNameID = value;}}    
	  protected override void Render(HtmlTextWriter writer)
    {     
	    this.title       = @"Select A ORP Professional";
  	  this.dataPrivate = true; 
      this.dataParms   = "[{id:'" + controlIDClientID + "'},{id:'" + controlIDGroupSvcClassNameID + "'}]";
      this.dataURL     = "practitioners.asmx/viewSelPotentialORPOnly";
      
      var addInfo = new RawHTML(@"<div class=""additional-info-below-select-entity"">" + Messages.MSG_PRAC_SELECTION_IS_QUALIFIED_ORP_ONLY + @"</div>");
      this.addPostControl(addInfo);
	    
      base.Render(writer);
    }
  }
}
