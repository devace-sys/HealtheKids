namespace System.Web.UI {
    using System;
    using System.ComponentModel;
    using System.Diagnostics.CodeAnalysis;
    using System.Globalization;
    using System.Security.Permissions;
    using System.Web;
    using System.Web.UI;
    using System.Web.Resources;
    using System.Web.Util;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal)
    ]
    public class PostBackTrigger : UpdatePanelControlTrigger {

        private IScriptManagerInternal _scriptManager;

        public PostBackTrigger() {
        }

        internal PostBackTrigger(IScriptManagerInternal scriptManager) {
            _scriptManager = scriptManager;
        }

        [
        SuppressMessage("Microsoft.Naming", "CA1706:ShortAcronymsShouldBeUppercase"),
        TypeConverter("System.Web.UI.Design.PostBackTriggerControlIDConverter, " +
            AssemblyRef.SystemWebExtensionsDesign)
        ]
        public new string ControlID {
            get {
                return base.ControlID;
            }
            set {
                base.ControlID = value;
            }
        }

        internal IScriptManagerInternal ScriptManager {
            get {
                if (_scriptManager == null) {
                    Page page = Owner.Page;
                    if (page == null) {
                        throw new InvalidOperationException(AtlasWeb.Common_PageCannotBeNull);
                    }
                    _scriptManager = UI.ScriptManager.GetCurrent(page);
                    if (_scriptManager == null) {
                        throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.Common_ScriptManagerRequired, Owner.ID));
                    }
                }
                return _scriptManager;
            }
        }

        protected internal override void Initialize() {
            base.Initialize();

            Control associatedControl = FindTargetControl(false);

            ScriptManager.RegisterPostBackControl(associatedControl);
        }

        protected internal override bool HasTriggered() {
            
            
            return false;
        }

        public override string ToString() {
            if (String.IsNullOrEmpty(ControlID)) {
                return "PostBack";
            }
            else {
                return "PostBack: " + ControlID;
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
