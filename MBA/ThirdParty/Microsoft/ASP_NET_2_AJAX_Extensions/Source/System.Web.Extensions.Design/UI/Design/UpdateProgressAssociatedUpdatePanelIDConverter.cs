namespace System.Web.UI.Design {
    using System;
    using System.Collections.Generic;
    using System.ComponentModel;
    using System.ComponentModel.Design;
    using System.Diagnostics;
    using System.Security.Permissions;
    using System.Diagnostics.CodeAnalysis;
    using System.Web;
    using System.Web.UI;
    using System.Web.UI.Design;

    [
    SuppressMessage("Microsoft.Naming", "CA1706:ShortAcronymsShouldBeUppercase",
        Justification = "TODO: Pending global exclusion of ID acronym."),
    ]
    public class UpdateProgressAssociatedUpdatePanelIDConverter : StringConverter {
        public override TypeConverter.StandardValuesCollection GetStandardValues(ITypeDescriptorContext context) {
            if (context != null) {
                
                List<string> controlIDs = new List<string>();
                IContainer container = context.Container;
                if (container != null) {
                    foreach (IComponent comp in container.Components) {
                        UpdatePanel panel = comp as UpdatePanel;
                        if (panel != null &&
                            !String.IsNullOrEmpty(panel.ID) &&
                            !controlIDs.Contains(panel.ID)) {
                            controlIDs.Add(panel.ID);
                        }
                    }
                }
                if (controlIDs.Count > 0) {
                    controlIDs.Sort(StringComparer.OrdinalIgnoreCase);
                    return new StandardValuesCollection(controlIDs);
                }
            }
            return base.GetStandardValues(context);
        }

        public override bool GetStandardValuesExclusive(ITypeDescriptorContext context) {
            return false;
        }

        public override bool GetStandardValuesSupported(ITypeDescriptorContext context) {
            return true;
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
