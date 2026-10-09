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
  public enum SelectTypeMultiSelect
  {
    SEARCH_BOX = 0,
    COMBO_BOX  = 1 
  }
  
  /**************************************************************************
   * SelectBoxBaseMultiSelect */
  /**
   * base class for multi-select controls with inline tags
   ****************************************************************************/

  public class SelectBoxBaseMultiSelect : WebUIControlDataField
  {
    public SelectBoxBaseMultiSelect ()                          : base("input", true)              {  }
    public SelectBoxBaseMultiSelect (string name, string value) : base("input", true, name, value) {  }
     
    protected string    _selectName                      = "";
    protected bool      _displayInline                   = false;
    protected bool      _showSelectControlLabel          = false;
    protected string    _selectControlLabel              = @"Select : ";	
    protected bool      _singleSelectClearAfterSelection = false;

    protected bool      _multiSelect                     = true;
    protected bool      _multiSelectShowOK               = false;
    protected string    _multiSelectListTitle            = "";
    protected string    _multiselectvalues               = "";
    protected string    _multiselectnames                = "";
    protected string    _multiSelectContextLabels        = "null";
    protected bool      _multiselectload                 = false;
    protected bool      _multiSelectDisplayContextLabels = false;
    
    protected string    _multiSelectOnAdd                = "";
    protected string    _multiSelectOnRemove             = "";
    protected string    _multiSelectOnChange             = "";

    protected bool      _multiSelectShowTags             = true;
    protected bool      _multiSelectShowClearAll         = true;
    protected bool      _multiSelectShowCount            = false;
    protected int       _multiSelectMaxSelections        = 0;
    protected string    _multiSelectEmptyText            = "";
    protected string    _multiSelectTagRemoveTitle       = "Remove";
    protected bool      _multiSelectAllowKeyboardNav     = true;
    protected bool      _multiSelectScroll               = false;
    protected int       _multiSelectScrollAfter          = 3;

    protected string    _afterRenderItem                 = "return $li;";

    public bool   singleSelectClearAfterSelection { get { return _singleSelectClearAfterSelection; } set { _singleSelectClearAfterSelection = value; } }
    public string selectName                      { get { return _selectName;                      } set { _selectName               = value; } }              
    public bool   displayInline                   { get { return _displayInline;                   } set { _displayInline            = value; } }
    public bool   showSelectControlLabel          { get { return _showSelectControlLabel;          } set { _showSelectControlLabel   = value; } }
    public string selectControlLabel              { get { return _selectControlLabel;              } set { _selectControlLabel       = value; } }

    public bool   multiSelect                     { get { return _multiSelect;                     } set { _multiSelect              = value; } }
    public bool   multiSelectShowOK               { get { return _multiSelectShowOK;               } set { _multiSelectShowOK        = value; } }
    public string multiSelectListTitle            { get { return _multiSelectListTitle;            } set { _multiSelectListTitle     = value; } }
    public string multiSelectValues               { get { return _multiselectvalues;               } set { _multiselectvalues        = value; } } 
    public string multiSelectNames                { get { return _multiselectnames;                } set { _multiselectnames         = value; } } 
    public string multiSelectContextLabels        { get { return _multiSelectContextLabels;        } set { _multiSelectContextLabels = value; } }
    public bool   multiSelectLoad                 { get { return _multiselectload;                 } set { _multiselectload          = value; } }     
    public bool   multiSelectDisplayContextLabels { get { return _multiSelectDisplayContextLabels; } set { _multiSelectDisplayContextLabels = value; } }

    public string multiSelectOnAdd                { get { return _multiSelectOnAdd;                } set { _multiSelectOnAdd         = value; } }   
    public string multiSelectOnRemove             { get { return _multiSelectOnRemove;             } set { _multiSelectOnRemove      = value; } }
    public string multiSelectOnChange             { get { return _multiSelectOnChange;             } set { _multiSelectOnChange      = value; } }
    
    public bool   multiSelectShowTags             { get { return _multiSelectShowTags;             } set { _multiSelectShowTags          = value; } }
    public bool   multiSelectShowClearAll         { get { return _multiSelectShowClearAll;         } set { _multiSelectShowClearAll      = value; } }
    public bool   multiSelectShowCount            { get { return _multiSelectShowCount;            } set { _multiSelectShowCount         = value; } }
    public int    multiSelectMaxSelections        { get { return _multiSelectMaxSelections;        } set { _multiSelectMaxSelections     = value; } }
    public string multiSelectEmptyText            { get { return _multiSelectEmptyText;            } set { _multiSelectEmptyText         = value; } }
    public string multiSelectTagRemoveTitle       { get { return _multiSelectTagRemoveTitle;       } set { _multiSelectTagRemoveTitle    = value; } }
    public bool   multiSelectAllowKeyboardNav     { get { return _multiSelectAllowKeyboardNav;     } set { _multiSelectAllowKeyboardNav  = value; } }
    public bool   multiSelectScroll               { get { return _multiSelectScroll;               } set { _multiSelectScroll            = value; } }
    public int    multiSelectScrollAfter          { get { return _multiSelectScrollAfter;          } set { _multiSelectScrollAfter       = value; } }

    public string afterRenderItem                 { get { return _afterRenderItem;                 } set { _afterRenderItem = value; } }

   /**************************************************************************
    * setParentStepLabel */
   /**
    * sets parent step label if it exists with selected name (if provided)
    **************************************************************************/

    public new Step setParentStepLabel()
    {
      return this.setParentStepLabel ( this.selectName );
    }

  }
}