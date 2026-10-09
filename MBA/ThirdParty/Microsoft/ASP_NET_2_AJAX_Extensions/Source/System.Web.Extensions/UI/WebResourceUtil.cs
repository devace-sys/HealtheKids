namespace System.Web.UI {
    using System;
    using System.Reflection;
    using System.Diagnostics;
    using System.Collections;
    using System.Globalization;
    using System.Web.UI;
    using System.Web.Resources;
    using System.Web.Util;

    internal static class WebResourceUtil {
        
        private static readonly Hashtable _assemblyContainsWebResourceCache = Hashtable.Synchronized(new Hashtable());

        
        
        
        public static bool AssemblyContainsWebResource(Assembly assembly, string resourceName) {
            
            if (assembly == AssemblyRef.SystemWebExtensions) {
                return SystemWebExtensionsContainsWebResource(resourceName);
            }

            
            
            Pair<string, Assembly> key = new Pair<string, Assembly>(resourceName, assembly);
            object assemblyContainsWebResource = _assemblyContainsWebResourceCache[key];

            if (assemblyContainsWebResource == null) {
                assemblyContainsWebResource = false;

                object[] attrs = assembly.GetCustomAttributes(typeof(WebResourceAttribute), false);
                foreach (WebResourceAttribute attr in attrs) {
                    
                    if (String.Equals(attr.WebResource, resourceName, StringComparison.Ordinal)) {
                        if (assembly.GetManifestResourceStream(resourceName) != null) {
                            assemblyContainsWebResource = true;
                            break;
                        }
                        else {
                            
                            throw new InvalidOperationException(String.Format(
                                CultureInfo.CurrentUICulture,
                                AtlasWeb.WebResourceUtil_AssemblyDoesNotContainEmbeddedResource,
                                assembly, resourceName));
                        }
                    }
                }

                _assemblyContainsWebResourceCache[key] = assemblyContainsWebResource;
            }

            return (bool)assemblyContainsWebResource;
        }

        private static bool SystemWebExtensionsContainsWebResource(string resourceName) {
            
            
            
            
            
            switch (resourceName.Length) {
                case 16:
                    return resourceName == "MicrosoftAjax.js";
                case 24:
                    return resourceName == "MicrosoftAjaxWebForms.js";
                case 21:
                    return resourceName == "MicrosoftAjaxTimer.js";
                case 22:
                    return resourceName == "MicrosoftAjax.debug.js";
                case 30:
                    return resourceName == "MicrosoftAjaxWebForms.debug.js";
                case 27:
                    return resourceName == "MicrosoftAjaxTimer.debug.js";
                default:
                    return false;
            }
        }

        
        
        public static void VerifyAssemblyContainsReleaseWebResource(Assembly assembly, string releaseResourceName) {
            if (!AssemblyContainsWebResource(assembly, releaseResourceName)) {
                throw new InvalidOperationException(String.Format(
                    CultureInfo.CurrentUICulture,
                    AtlasWeb.WebResourceUtil_AssemblyDoesNotContainReleaseWebResource,
                    assembly, releaseResourceName));
            }
        }

        
        
        public static void VerifyAssemblyContainsDebugWebResource(Assembly assembly, string debugResourceName) {
            if (!AssemblyContainsWebResource(assembly, debugResourceName)) {
                throw new InvalidOperationException(String.Format(
                    CultureInfo.CurrentUICulture,
                    AtlasWeb.WebResourceUtil_AssemblyDoesNotContainDebugWebResource,
                   assembly, debugResourceName));
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
