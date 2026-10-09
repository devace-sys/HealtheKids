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
   * TeleCommFormSelectParentRole */
  /**
   * 
   * 
   ****************************************************************************/ 

  public class TeleCommFormSelectParentRole:ControlBase
  {
    public TeleCommFormSelectParentRole(){}
    
    protected string _radioInputContainerCssClasses  = @"custom-control custom-radio custom-control-inline";
    protected string _radioInputCssClasses           = @"custom-control-input";
    protected string _radioInputLabelCssClasses      = @"custom-control-label";
    protected string _fieldNamePrefix                = @"";
    protected string _fieldName                      = @"parent-role";
    
    public string radioInputContainerCssClasses  { get { return _radioInputContainerCssClasses;} set { _radioInputContainerCssClasses = value;}}    
    public string radioInputCssClasses           { get { return _radioInputCssClasses;}          set { _radioInputCssClasses = value;}}
    public string radioInputLabelClasses         { get { return _radioInputLabelCssClasses;}     set { _radioInputLabelCssClasses = value;}}
    
    public string fieldName                      { get { return _fieldName;}                     set { _fieldName = value;}}
    public string fieldNamePrefix                { get { return _fieldNamePrefix;}               set { _fieldNamePrefix = value;}}
    
    protected void renderRadioButton (ref HtmlTextWriter writer, int idx, string value, string label)
    {

      var _inpName = String.Format(@"{0}{1}"
                   , _fieldNamePrefix
                   , _fieldName);

      var _inpID = String.Format(@"{0}-{1}-{2}-{3}"
                 , this.ID
                 , _inpName
                 , value
                 , idx);


      writer.Write(@"<div class=""{0}"">"
                   , _radioInputContainerCssClasses);

      writer.Write(@"<input id=""{0}"" name=""{1}"" type=""radio"" value=""{2}"" class=""{3}"" required/>"
                   , _inpID
                   , _inpName
                   , value
                   , _radioInputCssClasses);

      writer.Write(@"<label for=""{0}"" class=""{1}"">{2}</label>"
                     , _inpID
                     , _radioInputLabelCssClasses
                     , label);
      
      writer.Write(@"</div>");

    }
    protected override void Render (HtmlTextWriter writer) 
	  { 
    
      renderRadioButton (ref writer, 1, @"parent",    @"Parent");
      renderRadioButton (ref writer, 2, @"guardian",  @"Guardian");
      renderRadioButton (ref writer, 3, @"surrogate", @"Surrogate");
      renderRadioButton (ref writer, 3, @"student",   @"Adult Student");
      
	  }  
  }
}

