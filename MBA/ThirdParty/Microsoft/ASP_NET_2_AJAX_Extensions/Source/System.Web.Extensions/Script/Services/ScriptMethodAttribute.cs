namespace System.Web.Script.Services {
    using System;
    using System.Security.Permissions;
    using System.Web;
    using System.Web.Resources;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AttributeUsage(AttributeTargets.Method)
    ]
    public sealed class ScriptMethodAttribute : Attribute {
        private ResponseFormat _responseFormat;
        private bool _useHttpGet;
        private bool _xmlSerializeString;

        public ResponseFormat ResponseFormat {
            get {
                return _responseFormat;
            }
            set {
                _responseFormat = value;
            }
        }

        public bool UseHttpGet {
            get {
                return _useHttpGet;
            }
            set {
                _useHttpGet = value;
            }
        }

        public bool XmlSerializeString {
            get {
                return _xmlSerializeString;
            }
            set {
                _xmlSerializeString = value;
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
