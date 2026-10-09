using System;
using System.Collections.Specialized;

namespace System.Web.UI {
    internal interface IHttpRequest {
        IHttpBrowserCapabilities Browser {
            get;
        }

        string Path {
            get;
        }

        string FilePath {
            get;
        }

        NameValueCollection Headers {
            get;
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
