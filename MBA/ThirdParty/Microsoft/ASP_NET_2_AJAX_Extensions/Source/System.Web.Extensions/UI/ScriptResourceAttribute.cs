namespace System.Web.UI {
    using System;
    using System.Security.Permissions;
    using System.Web;
    using System.Web.Resources;

    [AttributeUsage(AttributeTargets.Assembly, AllowMultiple = true)]
    [AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal)]
    public sealed class ScriptResourceAttribute : Attribute {
        private string _scriptName;
        private string _scriptResourceName;
        private string _typeName;

        public ScriptResourceAttribute(string scriptName, string scriptResourceName, string typeName) {
            if (String.IsNullOrEmpty(scriptName)) {
                throw new ArgumentException(AtlasWeb.Common_NullOrEmpty, "scriptName");
            }
            if (String.IsNullOrEmpty(scriptResourceName)) {
                throw new ArgumentException(AtlasWeb.Common_NullOrEmpty, "scriptResourceName");
            }
            if (String.IsNullOrEmpty(typeName)) {
                throw new ArgumentException(AtlasWeb.Common_NullOrEmpty, "typeName");
            }
            _scriptName = scriptName;
            _scriptResourceName = scriptResourceName;
            _typeName = typeName;
        }

        public string ScriptName {
            get {
                return _scriptName;
            }
        }

        public string ScriptResourceName {
            get {
                return _scriptResourceName;
            }
        }

        public string TypeName {
            get {
                return _typeName;
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
