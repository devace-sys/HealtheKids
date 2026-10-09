namespace System.Web.UI {
    using System;
    using System.Collections.Generic;
    using System.Diagnostics;
    using System.Diagnostics.CodeAnalysis;
    using System.Globalization;
    using System.Security.Permissions;
    using System.Web;
    using System.Web.Resources;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal)
    ]
    public class ScriptControlDescriptor : ScriptComponentDescriptor {
        public ScriptControlDescriptor(string type, string elementID)
            : base(type, elementID) {
            RegisterDispose = false;
        }

        public override string ClientID {
            get {
                return ElementID;
            }
        }

        [SuppressMessage("Microsoft.Naming", "CA1706:ShortAcronymsShouldBeUppercase")]
        public string ElementID {
            get {
                return base.ElementIDInternal;
            }
        }

        public override string ID {
            get {
                return base.ID;
            }
            set {
                throw new InvalidOperationException(
                    String.Format(CultureInfo.InvariantCulture, AtlasWeb.ScriptControlDescriptor_IDNotSettable,
                                  "ID", typeof(ScriptControlDescriptor).FullName));
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
