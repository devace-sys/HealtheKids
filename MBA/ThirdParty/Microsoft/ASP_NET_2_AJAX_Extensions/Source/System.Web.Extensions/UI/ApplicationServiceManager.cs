namespace System.Web.UI {
    using System;
    using System.Web.UI;
    using System.Web.Resources;
    using System.Globalization;

    internal static class ApplicationServiceManager {
        public static string MergeServiceUrls(string serviceUrl, string existingUrl, Control urlBase) {
            serviceUrl = serviceUrl.Trim();

            if(serviceUrl.Length > 0) {
                serviceUrl = urlBase.ResolveClientUrl(serviceUrl);

                if(existingUrl.Length == 0) {
                    
                    existingUrl = serviceUrl;
                }
                else {
                    
                    
                    if(!string.Equals(serviceUrl, existingUrl, StringComparison.OrdinalIgnoreCase)) {
                        throw new ArgumentException(AtlasWeb.AppService_MultiplePaths);
                    }
                }
            }
            return existingUrl;
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
