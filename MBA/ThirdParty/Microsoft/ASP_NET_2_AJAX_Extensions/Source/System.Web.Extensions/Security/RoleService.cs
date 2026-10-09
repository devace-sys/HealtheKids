#if DEBUG && ORCAS



using System;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.Services;
using System.Web.Configuration;
using System.Web.Resources;
using System.Web.Script.Services;

namespace System.Web.Security {
    
    [ScriptService]
    internal sealed class RoleService : WebService {

        private static bool _configLoaded;
        private static object _configSync = new object();
        private static bool _enabled;

        private static bool Enabled {
            get {
                EnsureConfigLoaded();
                return _enabled;
            }
        }

        
        private static void CheckRoleServiceEnabled(HttpContext context) {
            if (!Enabled) {
                throw new InvalidOperationException(string.Format(AtlasWeb.AppService_Disabled, "RoleService"));
            }
        }

        private static void EnsureConfigLoaded() {
            if(!_configLoaded) {
                lock(_configSync) {
                    if(!_configLoaded) {
                        _enabled = true;
                        _configLoaded = true;

                    }
                }
            }
        }

        [WebMethod]
        public string[] GetRolesForUser() {
            CheckRoleServiceEnabled(this.Context);
            return Roles.GetRolesForUser();
        }
    }
}

#endif

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
