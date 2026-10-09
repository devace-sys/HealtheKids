using System;
using System.Web.UI;
using System.Text;
using System.Collections;
using System.Collections.Generic;

namespace MBA
{
	
	/**************************************************************************
     * DataEntryBoxBase */
	/**
     * 
     **************************************************************************/

	public abstract class DataEntryBoxBase : ControlBase
	{
		public DataEntryBoxBase(string type) : base() {	
			
		  this._type = type;

		  if      (this._type == @"select") { this._canAddSelections = true; }
		  else if (this._type == @"radio")  { this._canAddSelections = true; }
		  else                              { this._canAddSelections = false;}

		  if (this._canAddSelections)
          {
		    this._selections    = new List<NameValueOption>();
		    this._optionGroups  = new Dictionary<string, List<NameValueOption>>();
		  }  
		}

		private const string _nameValueFmtStr            = @" {0}=""{1}""";
		private const string _attrNameLowLen             = @"data-mba-data-entry-box-low-len";
		private const string _attrNameHighLen            = @"data-mba-data-entry-box-high-len";
		private const string _attrNameShowCharCountMeter = @"data-mba-data-entry-box-show-char-count-meter";
		private const string _attrNameFireSpedmonInput   = @"data-mba-data-entry-box-fire-spedmon-input";

		private string _type         = @"text";

		protected string _title      = String.Empty;
		protected string _label      = String.Empty;
		protected string _list       = String.Empty;
		protected int?   _minLen     = null;
		protected int?   _maxLen     = null;
		protected int?   _lowLen     = null;
		protected int?   _highLen    = null;
		protected string _minValStr  = String.Empty;
		protected string _maxValStr  = String.Empty;
		protected string _stepStr    = String.Empty;
		protected string _valueStr   = String.Empty;
		protected bool?  _required   = null;
		protected string _name       = String.Empty;
		protected int?   _size       = null;
		protected bool   _showCharCountMeter = false;
		protected bool   _fireSpedmonInput   = true;
		protected bool   _canAddSelections   = false;
		protected bool   _floatingLabel      = true;
		protected bool   _initiallyHidden    = false;
		
		protected bool   _addSelectOneSelection = true; /* Change in desendant classes if needed */
		protected string _altFieldID            = ""; /* Keeps this field in synch */
		
		protected Dictionary <String,List<NameValueOption>>   _optionGroups = null;
		protected List<NameValueOption>                       _selections   = null;
		
        public void addSelection(NameValue newSelection, bool hidden = false, bool disabled = false)
        {
			NameValueOption nvo = new NameValueOption(newSelection,hidden,disabled);
			addSelection(nvo);
        }
		public void addSelection(NameValueOption newSelection)
        {
		  if (_canAddSelections) this._selections.Add(newSelection);	
        }
		public string altFieldID
        {
			get { return _altFieldID;  }
			set { _altFieldID = value; }
        }

		public string label { 
			get { return _label;  } 
			set { _label = value; } 
		}
		public string list
		{
			get { return _list; }
			set { _list = value; }
		}
		public string title { 
			get { return _title; }     
			set { _title = value; }
		}
		public string name { 
			get { return _name; }
			set { _name = value; } 
		}
		public string value
        {
			get { return _valueStr; }
			set { _valueStr = value; }
        }		
		public int? size
		{
			get { return _size; }
			set { _size = value; }

			// Suggestion: let's implement length and width options, along the x and Y axes, instead of just a "size" option.
			//             let's also implement an inlineCSS option for setting custom values for text alignment and font-size and the like

			//             I would also suggest allowing customizable sizing and positioning for the meter widget.
            //             We may possibly want to render a smaller sized meter, 1/4 the x-width of the field,
            //             for optional, less conspicuous fields.
		}
		public int? minLen
        {
			get { return _minLen; }
			set { _minLen = value; }
        }
		public int? maxLen
		{
			get { return _maxLen; }
			set { _maxLen = value; }
		}
		public int? lowLen
        {
			get { return _lowLen; }
			set { _lowLen = value; }
        }
		public int? highLen
		{
			get { return _highLen; }
			set { _highLen = value; }
		}
		public bool showCharCountMeter
        {
			get { return _showCharCountMeter; }
			set { _showCharCountMeter = value; }
        }
		public bool? required {  
			get { return _required; } 
			set { _required = value; } 
		}

		public bool fireSpedmonInput
		{
			get { return _fireSpedmonInput; }
			set { _fireSpedmonInput = value; }
		}

		public bool floatingLabel
        {
		  get { return _floatingLabel;}
		  set { _floatingLabel = value;}
        }
		public bool initiallyHidden 
		{ 
		  get { return _initiallyHidden;}
		  set { _initiallyHidden = value;}
		}

		protected string renderAttributeNameVal (string name, string value)
        {
		  return (!String.IsNullOrWhiteSpace(value)) ? String.Format(_nameValueFmtStr, name, value) : String.Empty;
		}

		protected string renderAttributeNameVal(string name, int? value)
		{
		  return (value.HasValue) ? String.Format(_nameValueFmtStr, name, value.Value) : String.Empty;
		}
		protected string renderAttributeNameVal (string name, bool? value)
		{
		  if (value.HasValue) {
			if (value.Value) return String.Format(_nameValueFmtStr, name, name); 
          }
		  return String.Empty;
		}
        
		protected string renderAttributeNameVal (string name, bool value)
        {
			if (value == true) return String.Format(_nameValueFmtStr, name, @"true");
			return String.Format(_nameValueFmtStr, name, @"false");
		}
		protected string renderCommonAttributes()
        {
			var sb = new StringBuilder();
			sb.Append(renderAttributeNameVal(@"id",          this.ID));
			sb.Append(renderAttributeNameVal(@"name",        _name));
			sb.Append(renderAttributeNameVal(@"title",       _title));
			sb.Append(renderAttributeNameVal(@"placeholder", _label));  /* Note: placeholder is technically not supported in select elements */			
			sb.Append(renderAttributeNameVal(@"required",    _required));
			sb.Append(renderAttributeNameVal(_attrNameFireSpedmonInput,   _fireSpedmonInput));

			return sb.ToString();
		}

		protected string renderCommonInputAndTextAreaAttributes()
        {
			var sb = new StringBuilder();

			sb.Append(renderAttributeNameVal(@"minlength",   _minLen));
			sb.Append(renderAttributeNameVal(@"maxlength",   _maxLen));
			sb.Append(renderAttributeNameVal(@"min",         _minValStr));
			sb.Append(renderAttributeNameVal(@"max",         _maxValStr));

			sb.Append(renderAttributeNameVal(_attrNameLowLen,  _lowLen));
			sb.Append(renderAttributeNameVal(_attrNameHighLen, _highLen));
			sb.Append(renderAttributeNameVal(_attrNameShowCharCountMeter, _showCharCountMeter));

			return sb.ToString();
		}

		protected string renderTextAreaAttributes()
        {
			var sb = new StringBuilder();
			sb.Append(renderAttributeNameVal(@"cols", _size));
			return sb.ToString();
		}
		protected string renderInputAttributes()
        {
			var sb = new StringBuilder();
			sb.Append(renderAttributeNameVal(@"type",  _type));
			sb.Append(renderAttributeNameVal(@"size",  _size));
			sb.Append(renderAttributeNameVal(@"value", _valueStr));
			sb.Append(renderAttributeNameVal(@"step",  _stepStr));
			sb.Append(renderAttributeNameVal(@"list",  _list));
			return sb.ToString();
		}	
		protected override void Render(HtmlTextWriter writer)
        {
			/* #### text area #### */

			if (_type == "textarea") {	
			  writer.Write (  @"<textarea{0}{1}{2}>{3}</textarea>"
                             , renderCommonAttributes()
							 , renderCommonInputAndTextAreaAttributes()
							 , renderTextAreaAttributes()
							 , this._valueStr
							);			  
	        }
			
			/* #### select #### */

			else if (_type == "select") {
			  
			  /* Create select one default first option if applicable */
			 
	          if (_addSelectOneSelection) { 
			    _selections.Insert(0,new NameValueOption ("-- Select One --","",""));
			  }

			  /* Find each option group (if any) and create lists for each option group.  
			   * There will always be one empty "" option group.  Also find selected options. 
			   */

			  int _idx               = 0;
			  int _firstNonHiddenIdx = -1;
			  bool _hasSelectedValue = false;
		      
			  foreach (var _selection in _selections) {
				
		        /* If this is the first non hidden option make a note of its idx */ 

		        if ((_selection.hidden == false) && (_firstNonHiddenIdx == -1)) {
			      _firstNonHiddenIdx = _idx;
                }
                
				/* If this option matches the value flag it */			   

			    if (this._valueStr == _selection.value.ToString()) {
				  _selections[_idx].selected = true;
				  _hasSelectedValue = true;
                }

				/* Create option group */

			    if (!_optionGroups.ContainsKey(_selection.typename)) {
				  _optionGroups.Add(_selection.typename,new List<NameValueOption>());
                }
				_idx++;
			  } 

			  /* If there is no pre selected value then set the first non hidden selection as the default */

			  if (_hasSelectedValue == false)
              {
			    if (_firstNonHiddenIdx != -1) {
				  _selections[_firstNonHiddenIdx].selected = true;
                }
              }
			  
			  /* Populate option groups from selections */

			  foreach (var _selection in _selections) {
			     _optionGroups[_selection.typename].Add(_selection);
			  } 
			  
			  /* Render select */
		
			  writer.Write ( @"<select{0}>"
                             , renderCommonAttributes()
                           );             			  			  

			  /* Render options */

			  foreach (var _optGroup in _optionGroups)
              {
			 
			    bool _renderOptGroup = (!String.IsNullOrWhiteSpace(_optGroup.Key));
			    if (_renderOptGroup) writer.Write(@"<optgroup label=""{0}"">",_optGroup.Key);

			    foreach (var _option in _optGroup.Value) 
			    { 
			     
			      string _selected = @"";
				  string _hidden   = @"";
			      string _disabled = @"";

		          if (_option.selected == true) {
				    _selected = @" selected";					
             	  }
				  
				  if (_option.hidden == true) {
				    _hidden = @" hidden";
                  }

				  if (_option.disabled == true) {
				    _disabled = @" disabled";
                  }

				  writer.Write(@"<option value=""{0}"" title=""{1}""{2}{3}{4}>{5}</option>"
                               , _option.value
					 		   , _option.typename
							   , _selected
							   , _disabled
							   , _hidden
							   , _option.name);
			    } /* options */

                if (_renderOptGroup) writer.Write(@"</optgroup>");			
			  } /* optgroups */ 
               
			  writer.Write(@"</select>");
		    }
			
			/* #### input #### */
            
			else {
              writer.Write(@"<input{0}{1}{2}/>"
                           , renderCommonAttributes()
                           , renderCommonInputAndTextAreaAttributes()
					       , renderInputAttributes()
                           );                
            }
			
		    string optsJSON = @"{" 
                             + @"floatingLabel:"    + Util.netBoolToJSBool(_floatingLabel) 
							 + @",initiallyHidden:" + Util.netBoolToJSBool(_initiallyHidden)
		                     + @",altFieldID:"      + @"'" + _altFieldID + @"'"
							 + @"}";

			writer.Write ("<script>$(document).ready(function(){ $('#" + this.ID + "').MBA_DataEntryBox(" + optsJSON+ ");})</script>");
			base.Render(writer);

        }
    }
}
