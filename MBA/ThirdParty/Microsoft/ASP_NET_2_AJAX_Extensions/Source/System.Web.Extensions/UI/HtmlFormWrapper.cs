using System;
using System.Collections;
using System.Diagnostics;
using System.Web.UI;
using System.Web.UI.HtmlControls;

namespace System.Web.UI {
    internal sealed class HtmlFormWrapper : IHtmlForm {
        private HtmlForm _form;

        public HtmlFormWrapper(HtmlForm form) {
            Debug.Assert(form != null);
            _form = form;
        }

        #region IHtmlForm Members
        string IHtmlForm.ClientID {
            get {
                return _form.ClientID;
            }
        }

        void IHtmlForm.RenderControl(HtmlTextWriter writer) {
            _form.RenderControl(writer);
        }

        void IHtmlForm.SetRenderMethodDelegate(RenderMethod renderMethod) {
            _form.SetRenderMethodDelegate(renderMethod);
        }
        #endregion
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
