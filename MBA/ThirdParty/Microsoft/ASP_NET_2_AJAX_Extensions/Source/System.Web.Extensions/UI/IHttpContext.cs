namespace System.Web.UI {
    using System;
    using System.Web;

    internal interface IHttpContext {
        bool IsCustomErrorEnabled {
            get;
        }
        IHttpRequest Request {
            get;
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
