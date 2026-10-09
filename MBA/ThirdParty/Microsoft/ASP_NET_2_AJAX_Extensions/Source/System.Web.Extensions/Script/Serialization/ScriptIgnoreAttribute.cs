namespace System.Web.Script.Serialization {
    using System;
    using System.Security.Permissions;
    using System.Web;
    using System.Xml.Serialization;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AttributeUsage(AttributeTargets.Property | AttributeTargets.Field)
    ]
    public sealed class ScriptIgnoreAttribute : Attribute {
        public ScriptIgnoreAttribute() {
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
