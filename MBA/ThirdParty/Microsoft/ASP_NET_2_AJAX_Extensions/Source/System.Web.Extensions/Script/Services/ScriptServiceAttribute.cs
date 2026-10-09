namespace System.Web.Script.Services {
    using System;
    using System.Security.Permissions;
    using System.Web;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AttributeUsage(AttributeTargets.Class | AttributeTargets.Interface)
    ]
    public sealed class ScriptServiceAttribute : Attribute {
        public ScriptServiceAttribute() {
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
