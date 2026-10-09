namespace System.Web.Configuration {
    using System;
    using System.Configuration;
    using System.Security.Permissions;
    using System.Web;

    [AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal)]
    public sealed class SystemWebExtensionsSectionGroup : ConfigurationSectionGroup {

        [ConfigurationProperty("scripting")]
        public ScriptingSectionGroup Scripting {
            get {
                return (ScriptingSectionGroup)SectionGroups["scripting"];
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
