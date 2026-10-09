namespace System.Web.Configuration {
    using System;
    using System.Configuration;
    using System.Security.Permissions;
    using System.Web;

    [AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal)]
    public sealed class ScriptingSectionGroup : ConfigurationSectionGroup {

        [ConfigurationProperty("webServices")]
        public ScriptingWebServicesSectionGroup WebServices {
            get {
                return (ScriptingWebServicesSectionGroup)SectionGroups["webServices"];
            }
        }

        [ConfigurationProperty("scriptResourceHandler")]
        public ScriptingScriptResourceHandlerSection ScriptResourceHandler {
            get {
                return (ScriptingScriptResourceHandlerSection)Sections["scriptResourceHandler"];
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
