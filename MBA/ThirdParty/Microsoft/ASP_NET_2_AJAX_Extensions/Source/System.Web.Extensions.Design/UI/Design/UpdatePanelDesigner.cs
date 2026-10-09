namespace System.Web.UI.Design {
    using System;
    using System.ComponentModel;
    using System.ComponentModel.Design;
    using System.Diagnostics;
    using System.Globalization;
    using System.Web;
    using System.Web.UI;
    using System.Web.UI.Design;
    using System.Web.Resources.Design;

    public class UpdatePanelDesigner : ControlDesigner {
        private const string ContentTemplatePropertyName = "ContentTemplate";
        private bool _triggerEditorOpen;

        private object CurrentObject {
            get {
                return Component;
            }
        }

        private ITemplate CurrentTemplate {
            get {
                return UpdatePanel.ContentTemplate;
            }
        }

        private PropertyDescriptor CurrentTemplateDescriptor {
            get {
                return TypeDescriptor.GetProperties(Component)[ContentTemplatePropertyName];
            }
        }

        private TemplateDefinition TemplateDefinition {
            get {
                return new TemplateDefinition(this, ContentTemplatePropertyName, Component, ContentTemplatePropertyName);
            }
        }

        private UpdatePanel UpdatePanel {
            get {
                return (UpdatePanel)Component;
            }
        }

        protected override bool UsePreviewControl {
            get {
                return true;
            }
        }

        internal void EnterTriggerEditor() {
            _triggerEditorOpen = true;
        }

        internal void ExitTriggerEditor() {
            _triggerEditorOpen = false;
            OnComponentChanged(this, new ComponentChangedEventArgs(UpdatePanel, null, null, null));
        }

        public override string GetDesignTimeHtml(DesignerRegionCollection regions) {
            if (regions == null) {
                return base.GetDesignTimeHtml(regions);
            }

            EditableDesignerRegion region = new UpdatePanelDesignerRegion(CurrentObject, CurrentTemplate, CurrentTemplateDescriptor, TemplateDefinition);
            region.Description = AtlasWebDesign.UpdatePanelDesigner_RegionDescription;
            regions.Add(region);

            string regionAttributes = String.Format(
                    CultureInfo.InvariantCulture,
                    @" nowrap style=""border-top:1px solid #CCCCCC;padding: 1px; vertical-align:top; height: 100%"" {0}=""0""",
                    DesignerRegion.DesignerRegionAttributeName);

            return DesignUtil.GetContainerDesignTimeHtml(
                Component.Site,
                UpdatePanel.GetType().Name,
                UpdatePanel.ID,
                String.Empty,
                regionAttributes,
                false);
        }

        public override string GetEditableDesignerRegionContent(EditableDesignerRegion region) {
            UpdatePanelDesignerRegion upRegion = region as UpdatePanelDesignerRegion;
            if (upRegion != null) {
                ITemplate template = upRegion.Template;
                if (template != null) {
                    IDesignerHost host = (IDesignerHost)Component.Site.GetService(typeof(IDesignerHost));
                    return ControlPersister.PersistTemplate(template, host);
                }
            }
            return base.GetEditableDesignerRegionContent(region);
        }

        public override void OnComponentChanged(object sender, ComponentChangedEventArgs ce) {
            
            
            
            
            
            
            if (_triggerEditorOpen) {
                return;
            }
            base.OnComponentChanged(sender, ce);
        }

        public override void SetEditableDesignerRegionContent(EditableDesignerRegion region, string content) {
            UpdatePanelDesignerRegion updatePanelRegion = region as UpdatePanelDesignerRegion;
            if (updatePanelRegion == null) {
                return;
            }

            IDesignerHost host = (IDesignerHost)Component.Site.GetService(typeof(IDesignerHost));
            Debug.Assert(host != null, "IDesignerHost is null.");

            ITemplate template = ControlParser.ParseTemplate(host, content);
            updatePanelRegion.PropertyDescriptor.SetValue(updatePanelRegion.Object, template);
            updatePanelRegion.Template = template;
        }

        private class UpdatePanelDesignerRegion : TemplatedEditableDesignerRegion {
            private ITemplate _template;
            private object _object;
            private PropertyDescriptor _propertyDescriptor;

            public object Object {
                get {
                    return _object;
                }
            }

            public PropertyDescriptor PropertyDescriptor {
                get {
                    return _propertyDescriptor;
                }
            }

            public ITemplate Template {
                get {
                    return _template;
                }
                set {
                    _template = value;
                }
            }

            public UpdatePanelDesignerRegion(object obj, ITemplate template, PropertyDescriptor descriptor, TemplateDefinition definition)
                : base(definition) {
                _template = template;
                _object = obj;
                _propertyDescriptor = descriptor;
                EnsureSize = true;
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
