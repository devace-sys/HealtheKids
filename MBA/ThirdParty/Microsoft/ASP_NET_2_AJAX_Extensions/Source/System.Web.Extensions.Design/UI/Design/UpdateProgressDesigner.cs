namespace System.Web.UI.Design {
    using System;
    using System.Collections.Generic;
    using System.ComponentModel;
    using System.ComponentModel.Design;
    using System.Diagnostics;
    using System.Drawing;
    using System.Drawing.Design;
    using System.Web;
    using System.Web.UI;
    using System.Web.UI.Design;
    using System.Web.UI.WebControls;
    using System.Globalization;
    using System.Web.Resources.Design;

    public class UpdateProgressDesigner : ControlDesigner {
        private const string ContentTemplatePropertyName = "ProgressTemplate";

        private ITemplate Template {
            get {
                return UpdateProgress.ProgressTemplate;
            }
        }

        private PropertyDescriptor TemplateDescriptor {
            get {
                return TypeDescriptor.GetProperties(Component)[ContentTemplatePropertyName];
            }
        }

        private TemplateDefinition TemplateDefinition {
            get {
                return new TemplateDefinition(this, ContentTemplatePropertyName, Component, ContentTemplatePropertyName);
            }
        }

        private UpdateProgress UpdateProgress {
            get {
                return (UpdateProgress)Component;
            }
        }

        protected override bool UsePreviewControl {
            get {
                return true;
            }
        }

        public override string GetDesignTimeHtml(DesignerRegionCollection regions) {
            if (regions == null) {
                return base.GetDesignTimeHtml(regions);
            }

            EditableDesignerRegion region = new UpdateProgressDesignerRegion(Component, Template, TemplateDescriptor, TemplateDefinition);
            region.Description = AtlasWebDesign.UpdateProgressDesigner_RegionDescription;
            regions.Add(region);

            string regionAttributes = String.Format(
                    CultureInfo.InvariantCulture,
                    @" nowrap style=""border-top:1px solid #CCCCCC;padding: 1px; vertical-align:top; height: 100%"" {0}=""0""",
                    DesignerRegion.DesignerRegionAttributeName);

            return DesignUtil.GetContainerDesignTimeHtml(
                Component.Site,
                UpdateProgress.GetType().Name,
                UpdateProgress.ID,
                String.Empty,
                regionAttributes,
                false);
        }

        public override string GetEditableDesignerRegionContent(EditableDesignerRegion region) {
            UpdateProgressDesignerRegion upRegion = region as UpdateProgressDesignerRegion;
            if (upRegion != null) {
                ITemplate template = upRegion.Template;
                if (template != null) {
                    IDesignerHost host = (IDesignerHost)Component.Site.GetService(typeof(IDesignerHost));
                    return ControlPersister.PersistTemplate(template, host);
                }
            }
            return base.GetEditableDesignerRegionContent(region);
        }

        public override void SetEditableDesignerRegionContent(EditableDesignerRegion region, string content) {
            UpdateProgressDesignerRegion updatePanelRegion = region as UpdateProgressDesignerRegion;
            if (updatePanelRegion == null) {
                return;
            }

            IDesignerHost host = (IDesignerHost)Component.Site.GetService(typeof(IDesignerHost));
            Debug.Assert(host != null, "IDesignerHost is null.");

            ITemplate template = ControlParser.ParseTemplate(host, content);
            updatePanelRegion.PropertyDescriptor.SetValue(updatePanelRegion.Object, template);
            updatePanelRegion.Template = template;
        }

        private class UpdateProgressDesignerRegion : TemplatedEditableDesignerRegion {
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

            public UpdateProgressDesignerRegion(object obj, ITemplate template, PropertyDescriptor descriptor, TemplateDefinition definition)
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
