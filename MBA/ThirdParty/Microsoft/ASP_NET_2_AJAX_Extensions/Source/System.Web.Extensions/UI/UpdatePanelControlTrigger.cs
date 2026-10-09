namespace System.Web.UI {
    using System;
    using System.ComponentModel;
    using System.Diagnostics.CodeAnalysis;
    using System.Globalization;
    using System.Security.Permissions;
    using System.Web;
    using System.Web.UI;
    using System.Web.Resources;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal)
    ]
    public abstract class UpdatePanelControlTrigger : UpdatePanelTrigger {
        private string _controlID;

        protected UpdatePanelControlTrigger() {
        }

        [
        Category("Behavior"),
        DefaultValue(""),
        IDReferenceProperty(),
        ResourceDescription("UpdatePanelControlTrigger_ControlID"),
        SuppressMessage("Microsoft.Naming", "CA1706:ShortAcronymsShouldBeUppercase")
        ]
        public string ControlID {
            get {
                return _controlID ?? String.Empty;
            }
            set {
                _controlID = value;
            }
        }

        protected Control FindTargetControl(bool searchNamingContainers) {
            if (String.IsNullOrEmpty(ControlID)) {
                throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.UpdatePanelControlTrigger_NoControlID, Owner.ID));
            }
            Control foundControl = ControlUtil.FindTargetControl(ControlID, Owner, searchNamingContainers);
            if (foundControl == null) {
                throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.UpdatePanelControlTrigger_ControlNotFound, ControlID, Owner.ID));
            }
            return foundControl;
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
