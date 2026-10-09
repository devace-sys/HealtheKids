

namespace System.Web.Security {
    using System;
    using System.Web.Configuration;
    using System.Web.Resources;
    using System.Web.Services;
    using System.Web.Script.Services;
    using System.Globalization;

    [ScriptService]
    internal sealed class AuthenticationService {
        private static bool _configLoaded;
        private static object _configSync = new object();
        private static bool _enabled;
        private static bool _requireSSL;

        internal static bool Enabled {
            get {
                EnsureConfigLoaded();
                return _enabled;
            }
        }

        private static bool RequireSSL {
            get {
                EnsureConfigLoaded();
                return _requireSSL;
            }
        }

        
        private static void CheckAuthenticationServicesEnabled(HttpContext context, bool enforceSSL) {
            if(!Enabled) {
                throw new InvalidOperationException(string.Format(CultureInfo.CurrentCulture, AtlasWeb.AppService_Disabled, "AuthenticationService"));
            }

            
            if(enforceSSL && RequireSSL && !context.Request.IsSecureConnection) {
                throw new HttpException(403, AtlasWeb.AppService_RequiredSSL);
            }
        }

        private static void EnsureConfigLoaded() {
            if (!_configLoaded) {
                lock (_configSync) {
                    if (!_configLoaded) {

                        ScriptingAuthenticationServiceSection authServicesSection = ScriptingAuthenticationServiceSection.GetConfigurationSection();

                        if (authServicesSection != null) {
                            _enabled = authServicesSection.Enabled;
                            _requireSSL = authServicesSection.RequireSSL;
                        }

                        _configLoaded = true;
                    }
                }
            }
        }

        [WebMethod]
        public bool Login(string userName, string password, bool createPersistentCookie) {
            CheckAuthenticationServicesEnabled(HttpContext.Current, true);

            MembershipProvider provider = Membership.Provider;

            if(provider.ValidateUser(userName, password)) {
                FormsAuthentication.SetAuthCookie(userName, createPersistentCookie);
                return true;
            }

            return false;
        }

        [WebMethod]
        public void Logout() {
            CheckAuthenticationServicesEnabled(HttpContext.Current, false);
            FormsAuthentication.SignOut();
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
