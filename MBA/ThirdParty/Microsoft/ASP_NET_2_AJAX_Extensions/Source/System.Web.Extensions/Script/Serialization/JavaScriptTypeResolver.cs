namespace System.Web.Script.Serialization {
    using System;
    using System.Collections.Generic;
    using System.Security.Permissions;
    using System.Text;
    using System.Web;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal)
    ]
    public abstract class JavaScriptTypeResolver {
        public abstract Type ResolveType(string id);
        public abstract string ResolveTypeId(Type type);
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
