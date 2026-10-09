namespace System.Web.UI {
    using System;
    using System.Collections.Generic;
    using System.Diagnostics;
    using System.Diagnostics.CodeAnalysis;
    using System.Security.Permissions;
    using System.Web;
    using System.Web.Resources;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal)
    ]
    public class ScriptBehaviorDescriptor : ScriptComponentDescriptor {
        private string _name;

        public ScriptBehaviorDescriptor(string type, string elementID) : base(type, elementID) {
            RegisterDispose = false;
        }

        public override string ClientID {
            get {
                if (String.IsNullOrEmpty(ID)) {
                    Debug.Assert(!String.IsNullOrEmpty(ElementID), "Base ctor ensures ElementID is not null or empty");
                    return ElementID + "$" + Name;
                }
                else {
                    return ID;
                }
            }
        }

        [SuppressMessage("Microsoft.Naming", "CA1706:ShortAcronymsShouldBeUppercase")]
        public string ElementID {
            get {
                return base.ElementIDInternal;
            }
        }

        public string Name {
            get {
                if (String.IsNullOrEmpty(_name)) {
                    return GetTypeName(this.Type);
                }
                else {
                    return _name;
                }
            }
            set {
                _name = value;
            }
        }

        
        
        
        
        private static string GetTypeName(string type) {
            int index = type.LastIndexOf('.');
            if (index == -1) {
                return type;
            }
            else {
                return type.Substring(index + 1);
            }
        }

        protected internal override string GetScript() {
            if (!String.IsNullOrEmpty(_name)) {
                AddProperty("name", _name);
            }
            return base.GetScript();
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
