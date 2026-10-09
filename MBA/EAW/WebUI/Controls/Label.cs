using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;

using EAW.Web.UI;
using EAW.Web.UI.Controls.Attributes;
using EAW.Web.UI.Controls.Base;

namespace EAW.Web.UI.Controls
{

	public class Label : ElementBase
	{

		public Label () : this(null,null)
		{
		}

		public Label (string labelText) : this(labelText,null)
		{
		}

		public Label (string labelText, string forId) : base("label","label")
		{
          this._labelText = labelText;
		  this._forId     = forId;
		}

		private string _labelText  = null;
		private string _forId      = null;

		[Description("What is the id of the field to associate this label with"), Category("HTML attribute"), DefaultValue(null)]
		public string ForId { get { return _forId; } set { _forId = value; } }

		[Description("Text content of label"), Category("HTML attribute"), DefaultValue(null)]
        public string LabelText { get { return _labelText; } set { _labelText = value; } }

		protected override void Render (HtmlTextWriter writer)
		{

			if (!String.IsNullOrEmpty (_forId))  this.AddAttribute ("for",  _forId);
		
			if (!String.IsNullOrEmpty (_labelText)) {
				this.Controls.Add (new System.Web.UI.LiteralControl (_labelText));
			}

			base.Render (writer);
		}

	}
}

