namespace System.Web.UI {
    using System;
    using System.Collections.Generic;
    using System.ComponentModel;
    using System.Diagnostics.CodeAnalysis;
    using System.Globalization;
    using System.Security.Permissions;
    using System.Text;
    using System.Web;
    using System.Web.UI;
    using System.Web.Script;
    using System.Web.Resources;
    using System.Web.Util;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal),
    DefaultProperty("AssociatedUpdatePanelID"),
    Designer("System.Web.UI.Design.UpdateProgressDesigner, " + AssemblyRef.SystemWebExtensionsDesign),
    ParseChildren(true),
    PersistChildren(false),
    ]
    public class UpdateProgress : Control, IScriptControl {
        private ITemplate _progressTemplate;
        private Control _progressTemplateContainer;
        private int _displayAfter = 500;
        private bool _dynamicLayout = true;
        private string _associatedUpdatePanelID;

        [
        Category("Behavior"),
        DefaultValue(""),
        IDReferenceProperty(typeof(UpdatePanel)),
        ResourceDescription("UpdateProgress_AssociatedUpdatePanelID"),
        SuppressMessage("Microsoft.Naming", "CA1706:ShortAcronymsShouldBeUppercase"),
        TypeConverter("System.Web.UI.Design.UpdateProgressAssociatedUpdatePanelIDConverter")
        ]
        public string AssociatedUpdatePanelID {
            get {
                if (_associatedUpdatePanelID == null) {
                    return String.Empty;
                }
                return _associatedUpdatePanelID;
            }
            set {
                _associatedUpdatePanelID = value;
            }
        }

        [
        DefaultValue(500),
        ResourceDescription("UpdateProgress_DisplayAfter"),
        Category("Behavior")
        ]
        public int DisplayAfter {
            get {
                return _displayAfter;
            }
            set {
                if (value < 0) {
                    throw new ArgumentOutOfRangeException(AtlasWeb.UpdateProgress_DisplayAfterInvalid);
                }
                _displayAfter = value;
            }
        }

        [
        Browsable(false),
        PersistenceMode(PersistenceMode.InnerProperty),
        ResourceDescription("UpdateProgress_ProgressTemplate"),
        ]
        public ITemplate ProgressTemplate {
            get {
                return _progressTemplate;
            }
            set {
                _progressTemplate = value;
            }
        }

        [
        DefaultValue(true),
        ResourceDescription("UpdateProgress_DynamicLayout"),
        Category("Behavior")
        ]
        public bool DynamicLayout {
            get {
                return _dynamicLayout;
            }
            set {
                _dynamicLayout = value;
            }
        }

        private ScriptManager ScriptManager {
            get {
                ScriptManager scriptManager = ScriptManager.GetCurrent(Page);
                if (scriptManager == null) {
                    throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.Common_ScriptManagerRequired, ID));
                }
                return scriptManager;
            }
        }

        [SuppressMessage("Microsoft.Security", "CA2109:ReviewVisibleEventHandlers")]
        protected override void OnPreRender(EventArgs e) {
            base.OnPreRender(e);

            ScriptManager.RegisterScriptControl(this);

            
            if (_progressTemplate == null) {
                throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.UpdateProgress_TemplateRequired, ID));
            }
            _progressTemplateContainer = new Control();
            _progressTemplate.InstantiateIn(_progressTemplateContainer);
            Controls.Add(_progressTemplateContainer);
        }

        protected override void Render(HtmlTextWriter writer) {
            writer.AddAttribute(HtmlTextWriterAttribute.Id, ClientID);
            if (_dynamicLayout) {
                writer.AddStyleAttribute(HtmlTextWriterStyle.Display, "none");
            }
            else {
                writer.AddStyleAttribute(HtmlTextWriterStyle.Visibility, "hidden");
                writer.AddStyleAttribute(HtmlTextWriterStyle.Display, "block");
            }
            writer.RenderBeginTag(HtmlTextWriterTag.Div);
            base.Render(writer);
            writer.RenderEndTag(); 

            ScriptManager.RegisterScriptDescriptors(this);
        }

        [SuppressMessage("Microsoft.Design", "CA1024:UsePropertiesWhereAppropriate",
            Justification = "Matches IScriptControl interface.")]
        protected virtual IEnumerable<ScriptReference> GetScriptReferences() {
            yield break;
        }

        [SuppressMessage("Microsoft.Design", "CA1024:UsePropertiesWhereAppropriate",
            Justification = "Matches IScriptControl interface.")]
        protected virtual IEnumerable<ScriptDescriptor> GetScriptDescriptors() {
            
            if (Page != null && ScriptManager.SupportsPartialRendering && Visible) {
                ScriptControlDescriptor desc = new ScriptControlDescriptor("Sys.UI._UpdateProgress", ClientID);
                string updatePanelClientID = null;
                if (!String.IsNullOrEmpty(AssociatedUpdatePanelID)) {
                    
                    UpdatePanel c = ControlUtil.FindTargetControl(AssociatedUpdatePanelID, this, true) as UpdatePanel;
                    if (c != null)
                        updatePanelClientID = c.ClientID;
                    else {
                        throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.UpdateProgress_NoUpdatePanel, AssociatedUpdatePanelID));
                    }
                }
                desc.AddProperty("associatedUpdatePanelId", updatePanelClientID);
                desc.AddProperty("dynamicLayout", DynamicLayout);
                desc.AddProperty("displayAfter", DisplayAfter);
                yield return desc;
            }

            yield break;
        }

        #region IScriptControl Members

        IEnumerable<ScriptReference> IScriptControl.GetScriptReferences() {
            return GetScriptReferences();
        }

        IEnumerable<ScriptDescriptor> IScriptControl.GetScriptDescriptors() {
            return GetScriptDescriptors();
        }

        #endregion
    }
}


// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
