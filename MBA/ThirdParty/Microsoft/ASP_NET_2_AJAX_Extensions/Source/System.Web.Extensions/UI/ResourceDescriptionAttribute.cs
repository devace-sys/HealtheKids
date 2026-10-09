
namespace System.Web.UI {
    using System;
    using System.ComponentModel;
    using System.Reflection;
    using System.Web.Resources;

    [AttributeUsage(AttributeTargets.Property | AttributeTargets.Event, Inherited = true, AllowMultiple = false)]
    internal sealed class ResourceDescriptionAttribute : DescriptionAttribute {
        private bool _resourceLoaded;
        private readonly string _descriptionResourceName;

        public ResourceDescriptionAttribute(string descriptionResourceName) {
            _descriptionResourceName = descriptionResourceName;
        }

        public override string Description {
            get {
                if (!_resourceLoaded) {
                    _resourceLoaded = true;
                    PropertyInfo pi = typeof(AtlasWeb).GetProperty(_descriptionResourceName, BindingFlags.NonPublic | BindingFlags.Static);
                    if (pi != null) {
                        DescriptionValue = (string)pi.GetValue(null, null);
                    }
                }
                return base.Description;
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
