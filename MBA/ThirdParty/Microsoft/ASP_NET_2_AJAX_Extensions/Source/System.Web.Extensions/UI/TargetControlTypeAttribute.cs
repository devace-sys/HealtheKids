namespace System.Web.UI {
    using System;
    using System.Security.Permissions;
    using System.Web;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AttributeUsage(AttributeTargets.Class, AllowMultiple = true)
    ]
    public sealed class TargetControlTypeAttribute : Attribute {
        private Type _targetControlType;

        public TargetControlTypeAttribute(Type targetControlType) {
            if (targetControlType == null) {
                throw new ArgumentNullException("targetControlType");
            }
            _targetControlType = targetControlType;
        }

        public Type TargetControlType {
            get {
                return _targetControlType;
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
