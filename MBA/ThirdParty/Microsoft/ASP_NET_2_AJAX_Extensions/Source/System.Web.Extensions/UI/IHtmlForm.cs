using System;
using System.Web.UI;

namespace System.Web.UI {
    internal interface IHtmlForm {
        string ClientID {
            get;
        }

        void RenderControl(HtmlTextWriter writer);

        void SetRenderMethodDelegate(RenderMethod renderMethod);
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
