namespace System.Web.UI {
    using System;
    using System.Web.UI;

    internal interface IClientScriptManager {
        string GetPostBackEventReference(PostBackOptions options);
        string GetWebResourceUrl(Type type, string resourceName);
        void RegisterClientScriptBlock(Type type, string key, string script);
        void RegisterClientScriptInclude(Type type, string key, string url);
        void RegisterClientScriptBlock(Type type, string key, string script, bool addScriptTags);
        void RegisterStartupScript(Type type, string key, string script, bool addScriptTags);
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
