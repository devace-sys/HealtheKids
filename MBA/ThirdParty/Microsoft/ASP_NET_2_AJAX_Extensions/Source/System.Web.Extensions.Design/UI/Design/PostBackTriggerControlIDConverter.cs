namespace System.Web.UI.Design {
    using System;
    using System.Collections.Generic;
    using System.ComponentModel;
    using System.ComponentModel.Design;
    using System.Diagnostics.CodeAnalysis;
    using System.Web.UI;

    [SuppressMessage("Microsoft.Naming", "CA1706:ShortAcronymsShouldBeUppercase")]
    public class PostBackTriggerControlIDConverter : StringConverter {
        public override TypeConverter.StandardValuesCollection GetStandardValues(ITypeDescriptorContext context) {
            if (context != null) {
                PostBackTrigger trigger = context.Instance as PostBackTrigger;
                if (trigger != null && trigger.Owner != null) {
                    
                    List<string> controlIDs = new List<string>();
                    TriggerDesignUtil.WalkControlTree(trigger.Owner, delegate(IComponent component) {
                        Control control = component as Control;
                        if (control != null &&
                            !String.IsNullOrEmpty(control.ID) &&
                            !controlIDs.Contains(control.ID)) {
                            controlIDs.Add(control.ID);
                        }
                        return false;
                    }, false, null);

                    if (controlIDs.Count > 0) {
                        controlIDs.Sort(StringComparer.OrdinalIgnoreCase);
                        return new StandardValuesCollection(controlIDs);
                    }
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
