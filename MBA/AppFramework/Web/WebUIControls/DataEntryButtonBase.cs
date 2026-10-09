using System;
using System.Web.UI;
using System.Text;
using System.ComponentModel; 

namespace MBA
{
	/**************************************************************************
     * DataEntryButtonStyle */
	/**
     * 
     **************************************************************************/
	 
	public enum DataEntryButtonStyle
    {
		  [Description("btn-primary")]   PRIMARY   = 1      
		, [Description("btn-secondary")] SECONDARY = 2
		, [Description("btn-success")]   SUCCESS   = 3
		, [Description("btn-danger")]    DANGER    = 4
		, [Description("btn-warning")]   WARNING   = 5
		, [Description("btn-info")]      INFO      = 6
        , [Description("btn-light")]     LIGHT     = 7
		, [Description("btn-dark")]      DARK      = 8
		, [Description("btn-link")]      LINK      = 9
    }
    
	/**************************************************************************
     * DataEntryButtonSize */
	/**
     * 
     **************************************************************************/
	 
	public enum DataEntryButtonSize
    {
		  [Description("")]        REGULAR   = 1      
		, [Description("btn-sm")]  SMALL     = 2      
		, [Description("btn-lg")]  LARGE     = 3
    }
	
	/**************************************************************************
     * DataEntryButtonBase */
	/**
     * 
     **************************************************************************/
	public abstract class DataEntryButtonBase : ControlBase
	{
		public DataEntryButtonBase()
        {

        }
		
		private const string _nameValueFmtStr            = @" {0}=""{1}""";
		private const string _attrNameFireSpedmonInput   = @"data-mba-data-entry-button-fire-spedmon-input";

		private string _type = @"button";
        
		protected DataEntryButtonStyle _style            = DataEntryButtonStyle.PRIMARY;
		protected DataEntryButtonSize  _size             = DataEntryButtonSize.REGULAR;

		protected string _cssClasses           = String.Empty;
		protected string _valueStr             = String.Empty;
		protected string _title                = String.Empty;
		protected string _label                = String.Empty;
		protected string _name                 = String.Empty;
		protected string _cssClass             = String.Empty;

		protected bool   _fireSpedmonInput     = true;
		protected string _faIcon               = "";
		protected bool   _assignBsCssClasses   = true;
		protected bool   _iconOnly             = false;

		public string faIcon { 
			get { return _faIcon;            } 
			set { _faIcon = value.ToLower(); } 
		}

		public DataEntryButtonStyle style { 
			get { return _style;  } 
			set { _style = value; } 
		}
		public DataEntryButtonSize size { 
			get { return _size;  } 
			set { _size = value; } 
		}
		public string label { 
			get { return _label;  } 
			set { _label = value; } 
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
	    public string type 
		{
		    get { return _type; }
			set { _type = value; }
   	    }		
		public bool fireSpedmonInput
		{
			get { return _fireSpedmonInput; }
			set { _fireSpedmonInput = value; }
		}
		public string cssClass
        {
	        get { return _cssClass; }
			set { _cssClass = value; }
        }
		
		public bool assignBsCssClasses
        {
			get {  return _assignBsCssClasses;}
			set {  _assignBsCssClasses = value;}
        }
		public bool iconOnly
		{ 
			get {  return _iconOnly;}
			set {  _iconOnly = value;}
		}
		protected void assignCssClasses()
        {
			StringBuilder sb = new StringBuilder();
			if (_assignBsCssClasses == true)
			{ 
			  sb.Append(@"btn");
			  sb.Append(@" ");
			  sb.Append(_style.GetDescription());
			  sb.Append(@" ");
			  sb.Append(_size.GetDescription());
			  sb.Append(@" ");
			}
			else
            {
				if (_iconOnly == true)
                {
					sb.Append(@"ui-spedmon-button-blank");
					sb.Append(@" ");
                }
            }
			sb.Append(_cssClass);
			_cssClasses = sb.ToString().Trim();
        }

		protected string renderAttributeNameVal (string name, string value)
        {
		  return (!String.IsNullOrWhiteSpace(value)) ? String.Format(_nameValueFmtStr, name, value) : String.Empty;
		}
		protected string renderAttributeNameVal (string name, bool? value)
		{
		  if (value.HasValue) {
			if (value.Value) return String.Format(_nameValueFmtStr, name, name); 
          }
		  return String.Empty;
		}
        
		protected string renderAttributes()
        {
			var sb = new StringBuilder();
			sb.Append(renderAttributeNameVal(@"id",    this.ID));
			sb.Append(renderAttributeNameVal(@"name",  _name));
			sb.Append(renderAttributeNameVal(@"title", _title));
            sb.Append(renderAttributeNameVal(@"type",  _type));
			sb.Append(renderAttributeNameVal(@"value", _valueStr));
            sb.Append(renderAttributeNameVal(@"class", _cssClasses));
			return sb.ToString();
		}
	
		protected override void Render(HtmlTextWriter writer)
        {
			assignCssClasses();
			writer.Write(@"<button {0}>", renderAttributes()); 			
		    
			if (_iconOnly == false) writer.Write(_label);

			if (!String.IsNullOrWhiteSpace(_faIcon))
			{ 
		      string _iconMargin = @"ml-2 ";
			  if (_iconOnly == true) _iconMargin = @" ";
		      writer.Write(@"<i class=""{0} {1}""></i>", _iconMargin,_faIcon);
		    }
			writer.Write(@"</button>");
            base.Render(writer);
        		
		}
    }
}
