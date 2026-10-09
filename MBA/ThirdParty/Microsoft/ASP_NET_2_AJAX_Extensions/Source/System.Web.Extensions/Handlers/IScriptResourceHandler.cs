namespace System.Web.Handlers {
    using System;
    using System.Collections.Generic;
    using System.Globalization;
    using System.Reflection;
    using System.Text;

    internal interface IScriptResourceHandler {
        string GetScriptResourceUrl(
            Assembly assembly, string resourceName, CultureInfo culture, bool zip, bool notifyScriptLoaded);
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
