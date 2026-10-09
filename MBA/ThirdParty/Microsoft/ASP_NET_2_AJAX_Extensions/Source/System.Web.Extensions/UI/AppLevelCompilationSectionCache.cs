namespace System.Web.UI {
    using System;
    using System.Configuration;
    using System.Security;
    using System.Security.Permissions;
    using System.Web.Configuration;

    
    
    internal sealed class AppLevelCompilationSectionCache : ICompilationSection {
        private static readonly AppLevelCompilationSectionCache _instance = new AppLevelCompilationSectionCache();

        
        private bool? _debug;

        private AppLevelCompilationSectionCache() {
        }

        public static AppLevelCompilationSectionCache Instance {
            get {
                return _instance;
            }
        }

        public bool Debug {
            get {
                if (_debug == null) {
                    _debug = GetDebugFromConfig();
                }
                return _debug.Value;
            }
        }

        [
        ConfigurationPermission(SecurityAction.Assert, Unrestricted = true),
        SecurityCritical(),
        SecurityTreatAsSafe(),
        ]
        private static bool GetDebugFromConfig() {
            CompilationSection section =
                (CompilationSection)WebConfigurationManager.GetWebApplicationSection("system.web/compilation");
            return section.Debug;
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
