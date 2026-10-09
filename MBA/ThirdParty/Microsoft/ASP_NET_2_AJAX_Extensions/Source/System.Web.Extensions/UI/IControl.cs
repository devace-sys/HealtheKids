namespace System.Web.UI {
    using System;

    internal interface IControl : IClientUrlResolver {
        IHttpContext Context {
            get;
        }
        bool DesignMode {
            get;
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
