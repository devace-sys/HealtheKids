namespace System.Web.UI {
    using System;
    using System.Collections.Generic;
    using System.ComponentModel;
    using System.Diagnostics.CodeAnalysis;
    using System.Globalization;
    using System.Security.Permissions;
    using System.Web;
    using System.Web.Resources;
    using System.Web.UI;
    using System.Web.UI.WebControls;
    using System.Web.Util;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal),
    ]
    public abstract class ScriptControl : WebControl, IScriptControl {
        private IScriptManagerInternal _scriptManager;

        protected ScriptControl() {
        }

        internal ScriptControl(IScriptManagerInternal scriptManager) {
            _scriptManager = scriptManager;
        }

        private IScriptManagerInternal ScriptManager {
            get {
                if (_scriptManager == null) {
                    Page page = Page;
                    if (page == null) {
                        throw new InvalidOperationException(AtlasWeb.Common_PageCannotBeNull);
                    }
                    _scriptManager = System.Web.UI.ScriptManager.GetCurrent(page);
                    if (_scriptManager == null) {
                        throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture,
                            AtlasWeb.Common_ScriptManagerRequired, ID));
                    }
                }
                return _scriptManager;
            }
        }

        [SuppressMessage("Microsoft.Security", "CA2109:ReviewVisibleEventHandlers")]
        protected override void OnPreRender(EventArgs e) {
            base.OnPreRender(e);
            ScriptManager.RegisterScriptControl(this);
        }

        protected override void Render(HtmlTextWriter writer) {
            base.Render(writer);

            
            if (!DesignMode) {
                ScriptManager.RegisterScriptDescriptors(this);
            }
        }

        [SuppressMessage("Microsoft.Design", "CA1024:UsePropertiesWhereAppropriate",
            Justification = "Implementation will likely return a new collection, which is too slow for a property")]
        protected abstract IEnumerable<ScriptDescriptor> GetScriptDescriptors();

        [SuppressMessage("Microsoft.Design", "CA1024:UsePropertiesWhereAppropriate",
            Justification = "Implementation will likely return a new collection, which is too slow for a property")]
        protected abstract IEnumerable<ScriptReference> GetScriptReferences();

        #region IScriptControl Members
        IEnumerable<ScriptDescriptor> IScriptControl.GetScriptDescriptors() {
            return GetScriptDescriptors();
        }

        IEnumerable<ScriptReference> IScriptControl.GetScriptReferences() {
            return GetScriptReferences();
        }
        #endregion
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
