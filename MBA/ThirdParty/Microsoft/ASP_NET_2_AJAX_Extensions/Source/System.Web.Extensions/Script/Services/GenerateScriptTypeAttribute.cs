namespace System.Web.Script.Services {
    using System;
    using System.Security.Permissions;
    using System.Web;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AttributeUsage(AttributeTargets.Class | AttributeTargets.Interface | AttributeTargets.Method, AllowMultiple = true)
    ]
    public sealed class GenerateScriptTypeAttribute : Attribute {

        
        public GenerateScriptTypeAttribute(Type type) {
            if (type == null) {
                throw new ArgumentNullException("type");
            }
            _type = type;
        }

        
        private Type _type;
        public Type Type {
            get {
                return _type;
            }
        }

        private string _typeId;
        public string ScriptTypeId {
            get {
                return _typeId ?? String.Empty;
            }
            set {
                _typeId = value;
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
