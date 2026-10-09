#if ORCAS

namespace System.Web.UI {
    using System;
    using System.Collections.ObjectModel;
    using System.ComponentModel;
    using System.Security.Permissions;
    using System.Text;
    using System.Web;
    using System.Web.Security;
    using System.Web.Script.Serialization;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal),
    DefaultProperty("Path"),
    TypeConverter(typeof(System.ComponentModel.ExpandableObjectConverter))
    ]
    public class RoleServiceManager : ApplicationServiceManager {
        private bool _loadRoles;

        internal static void ConfigureRoleService(StringBuilder sb, HttpContext context, ScriptManager scriptManager, List<ScriptManagerProxy> proxies) {
            string roleServiceUrl = null;
            bool loadRoles = false;
            RoleServiceManager roleManager;

            if(scriptManager.HasRoleServiceManager) {
                roleManager = scriptManager.RoleServiceManager;

                
                loadRoles = roleManager.LoadRoles;

                
                roleServiceUrl = roleManager.Path.Trim();
                if(roleServiceUrl.Length > 0) {
                    roleServiceUrl = scriptManager.ResolveUrl(roleServiceUrl);
                }
            }

            
            if(proxies != null) {
                foreach(ScriptManagerProxy proxy in proxies) {
                    if(proxy.HasRoleServiceManager) {
                        roleManager = proxy.RoleServiceManager;

                        
                        loadRoles |= roleManager.LoadRoles;

                        
                        roleServiceUrl = RoleServiceManager.MergeServiceUrls(roleManager, roleServiceUrl, proxy);
                    }
                }
            }

            RoleServiceManager.GenerateInitializationScript(sb, context, loadRoles, roleServiceUrl);
        }
        private static void GenerateInitializationScript(StringBuilder sb, HttpContext context, bool loadRoles, string serviceUrl) {
            if(!string.IsNullOrEmpty(serviceUrl)) {
                sb.Append("Sys.Services.RoleService.set_path('");
                sb.Append(JavaScriptString.QuoteString(serviceUrl));
                sb.Append("');\n");
            }

            if(loadRoles) {
                string[] roles = Roles.GetRolesForUser();
                if(roles != null && roles.Length > 0) {
                    sb.Append("Sys.Services.RoleService._preloadRoles(Sys.Serialization.JavaScriptSerializer.deserialize('");
                    sb.Append(JavaScriptString.QuoteString(JavaScriptSerializer.SerializeInternal(roles)));
                    sb.Append("'));\n");
                }
            }
        }

        [
        DefaultValue(false),
        Category("Behavior"),
        NotifyParentProperty(true),
        ]
        public bool LoadRoles {
            get { return _loadRoles; }
            set { _loadRoles = value; }
        }
    }
}

#endif

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
