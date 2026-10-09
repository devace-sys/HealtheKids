namespace System.Web.Configuration {
    using System;
    using System.Configuration;
    using System.Security.Permissions;
    using System.Web;

    [AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal)]
    public sealed class ScriptingWebServicesSectionGroup : ConfigurationSectionGroup {

        [ConfigurationProperty("jsonSerialization")]
        public ScriptingJsonSerializationSection JsonSerialization {
            get {
                return (ScriptingJsonSerializationSection)Sections["jsonSerialization"];
            }
        }

        [ConfigurationProperty("profileService")]
        public ScriptingProfileServiceSection ProfileService {
            get {
                return (ScriptingProfileServiceSection)Sections["profileService"];
            }
        }


        [ConfigurationProperty("authenticationService")]
        public ScriptingAuthenticationServiceSection AuthenticationService {
            get {
                return (ScriptingAuthenticationServiceSection)Sections["authenticationService"];
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
