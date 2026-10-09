namespace System.Web.UI.Design {
    using System;
    using System.Collections.Generic;
    using System.ComponentModel;
    using System.ComponentModel.Design;
    using System.Web.UI;

    public class AsyncPostBackTriggerEventNameConverter : StringConverter {
        public override TypeConverter.StandardValuesCollection GetStandardValues(ITypeDescriptorContext context) {
            if (context != null) {
                AsyncPostBackTrigger trigger = context.Instance as AsyncPostBackTrigger;
                
                Control targetControl = null;
                if (!String.IsNullOrEmpty(trigger.ControlID)) {
                    if (trigger != null && trigger.Owner != null && trigger.Owner.Site != null) {
                        IDesignerHost host = (IDesignerHost)trigger.Owner.Site.GetService(typeof(IDesignerHost));
                        Control rootControl = host.RootComponent as Control;
                        if (rootControl != null) {
                            TriggerDesignUtil.WalkControlTree(rootControl, delegate(IComponent component) {
                                Control control = component as Control;
                                if (control != null &&
                                    String.Equals(control.ID, trigger.ControlID, StringComparison.InvariantCultureIgnoreCase)) {
                                    targetControl = control;
                                    return true;
                                }
                                return false;
                            }, true, trigger.Owner);
                        }
                    }
                }

                if (targetControl != null) {
                    List<string> eventNames = new List<string>();

                    
                    EventDescriptorCollection events = TypeDescriptor.GetEvents(targetControl);
                    foreach (EventDescriptor eventDesc in events) {
                        eventNames.Add(eventDesc.Name);
                    }

                    if (eventNames.Count > 0) {
                        eventNames.Sort(StringComparer.OrdinalIgnoreCase);
                        return new StandardValuesCollection(eventNames);
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
