using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;
using System.Collections;
using System.Collections.Generic;
using EAW.Web.UI;
using EAW.Web.UI.Controls.Attributes;
using EAW.Web.UI.Controls.Base;

namespace EAW.Web.UI.Controls.Base
{
	
    /// <summary>
	/// Control base.
	/// </summary>

    public abstract class ControlBase : System.Web.UI.Control
	{

        #region Constructors

		/// <summary>
		/// Initializes a new instance of the <see cref="EAW.Web.UI.Controls.Base.ControlBase"/> class.
		/// </summary>
        public ControlBase () 
		{
		}
				        
        #endregion


		#region Methods
	    
		/// <summary>
	    /// Render the specified writer.
	    /// </summary>
	    /// <param name="writer">Writer.</param>

		protected override void Render (HtmlTextWriter writer)
		{

		base.Render (writer);

		} 

        #endregion


	}
}

