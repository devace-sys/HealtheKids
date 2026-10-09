namespace System.Web.UI {
    using System;
    using System.Configuration;
    using System.Security;
    using System.Security.Permissions;
    using System.Web.Configuration;

    
    internal sealed class DeploymentSectionCache : IDeploymentSection {
        private static readonly DeploymentSectionCache _instance = new DeploymentSectionCache();
        
        private bool? _retail;

        private DeploymentSectionCache() {
        }

        public static DeploymentSectionCache Instance {
            get {
                return _instance;
            }
        }

        public bool Retail {
            get {
                if (_retail == null) {
                    _retail = GetRetailFromConfig();
                }
                return _retail.Value;
            }
        }

        [
        ConfigurationPermission(SecurityAction.Assert, Unrestricted = true),
        SecurityCritical(),
        SecurityTreatAsSafe(),
        ]
        private static bool GetRetailFromConfig() {
            DeploymentSection section = (DeploymentSection)WebConfigurationManager.GetSection("system.web/deployment");
            return section.Retail;
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
