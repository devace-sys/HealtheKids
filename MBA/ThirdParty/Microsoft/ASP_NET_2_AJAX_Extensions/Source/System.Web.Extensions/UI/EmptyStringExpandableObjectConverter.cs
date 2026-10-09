namespace System.Web.UI {
    using System;
    using System.ComponentModel;
    using System.Globalization;

    
    
    internal sealed class EmptyStringExpandableObjectConverter : ExpandableObjectConverter {
        public override object ConvertTo(ITypeDescriptorContext context, CultureInfo culture, object value,
                                         Type destinationType) {
            if (destinationType == typeof(string)) {
                return String.Empty;
            }
            else {
                return base.ConvertTo(context, culture, value, destinationType);
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
