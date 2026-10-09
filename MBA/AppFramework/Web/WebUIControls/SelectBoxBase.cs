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
  public enum SelectType
  {
    SEARCH_BOX = 0,
    COMBO_BOX  = 1 
  }
  
  public class SelectBoxBase:WebUIControlDataField
  {
    public SelectBoxBase ()                          : base("input", true)              {  }
    public SelectBoxBase (string name, string value) : base("input", true, name, value) {  }
     
    // TODO: Pull in all shared properties from descendant controls
    
    protected string    _selectName                      = "";                  /* Selected label (or name) */
    protected bool      _multiSelect                     = false;               // Allows multiple selection of entities
    protected bool      _multiSelectShowOK               = true;
    protected string    _multiSelectListTitle            = "Selected records";      
    protected string    _multiselectvalues               = "";
    protected string    _multiselectnames                = "";
    protected string    _multiSelectContextLabels        = "null";
    protected bool      _multiselectload                 = false;
    protected bool      _multiSelectDisplayContextLabels = false;
    
    protected string    _multiSelectOnAdd                = "";
    protected string    _multiSelectOnRemove             = "";
    protected bool      _displayInline                   = false;
    protected bool      _showSelectControlLabel          = false;
	protected string    _selectControlLabel              = @"Select : ";	
    protected bool      _singleSelectClearAfterSelection = false;
    protected string    _afterRenderItem                 = "return $renderedli;";
        
    public bool   singleSelectClearAfterSelection { get { return _singleSelectClearAfterSelection;              } set { _singleSelectClearAfterSelection              = value; } }
    public string selectName               { get { return _selectName;               } set { _selectName               = value; } }              
    public bool   multiSelect              { get { return _multiSelect;              } set { _multiSelect              = value; } }
    public bool   multiSelectShowOK        { get { return _multiSelectShowOK;        } set {_multiSelectShowOK         = value; } }
    public string multiSelectListTitle     { get { return _multiSelectListTitle;     } set { _multiSelectListTitle     = value; } }
    public string multiSelectValues        { get { return _multiselectvalues;        } set { _multiselectvalues        = value; } } 
    public string multiSelectNames         { get { return _multiselectnames;         } set { _multiselectnames         = value; } } 
    public string multiSelectContextLabels { get { return _multiSelectContextLabels; } set { _multiSelectContextLabels  = value; } }
    public bool   multiSelectLoad          { get { return _multiselectload;          } set { _multiselectload           = value; } }     
    public string multiSelectOnAdd         { get { return _multiSelectOnAdd;         } set { _multiSelectOnAdd    = value; }}   
    public string multiSelectOnRemove      { get { return _multiSelectOnRemove;      } set { _multiSelectOnRemove = value; }}   
    
    public bool   multiSelectDisplayContextLabels { get {return _multiSelectDisplayContextLabels;} set {_multiSelectDisplayContextLabels = value;}}
    public bool   displayInline                   { get {return _displayInline;}                   set {_displayInline = value;}}

    /* Inline label INSIDE control container */
    public bool      showSelectControlLabel      { get {return _showSelectControlLabel;} set {_showSelectControlLabel = value;}}
	public string    selectControlLabel          { get {return _selectControlLabel;}     set {_selectControlLabel     = value;}}

    /* Used for replacing list item generated */
    public string   afterRenderItem {  get {  return _afterRenderItem; } set { _afterRenderItem = value; } }

   /**************************************************************************
    * setParentStepLabel */
   /**
    * Sets parent step label if it exists with selected name (if provided)
    **************************************************************************/

    public new Step setParentStepLabel()
  	{
  	  return this.setParentStepLabel ( this.selectName );
  	}

  }
}
