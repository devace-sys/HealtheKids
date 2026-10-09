using System;

namespace System.Web.UI {
    internal interface IHttpBrowserCapabilities {
        string Browser { get; }
        Version EcmaScriptVersion { get; }
        Version JScriptVersion { get; }
        bool SupportsCallback { get; }
        Version W3CDomVersion { get; }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
