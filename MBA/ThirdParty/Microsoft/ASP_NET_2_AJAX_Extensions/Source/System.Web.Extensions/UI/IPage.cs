namespace System.Web.UI {
    using System;
    using System.Collections;
    using System.Web.UI;
    using System.Web.UI.HtmlControls;
    using System.Web;

    internal interface IPage {
        string AppRelativeVirtualPath {
            get;
        }

        IClientScriptManager ClientScript {
            get;
        }

        bool EnableEventValidation {
            get;
        }

        IHtmlForm Form {
            get;
        }

        HtmlHead Header {
            get;
        }

        bool IsPostBack {
            get;
        }

        IDictionary Items {
            get;
        }

        IHttpRequest Request {
            get;
        }

        IHttpResponse Response {
            get;
        }

        IHttpServerUtility Server {
            get;
        }

        string Title {
            get;
        }

        event EventHandler Error;
        event EventHandler InitComplete;
        event EventHandler PreRender;
        event EventHandler PreRenderComplete;

        void SetFocus(Control control);
        void SetFocus(string clientID);
        void SetRenderMethodDelegate(RenderMethod renderMethod);
        void VerifyRenderingInServerForm(Control control);
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
