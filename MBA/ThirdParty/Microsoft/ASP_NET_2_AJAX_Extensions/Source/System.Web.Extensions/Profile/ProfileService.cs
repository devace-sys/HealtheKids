


namespace System.Web.Profile {
    using System;
    using System.Collections.Generic;
    using System.Configuration;
    using System.Globalization;
    using System.Web.Profile;
    using System.Web.Configuration;
    using System.Web.Resources;
    using System.Web.Services;
    using System.Web.Script.Serialization;
    using System.Web.Script.Services;
    using System.Diagnostics;

    [ScriptService]
    internal sealed class ProfileService {
        
        
        
        
        
        
        
        private static Dictionary<string, object> _allowedGet;
        private static Dictionary<string, object> _allowedSet;
        private static bool? _profileServicesEnabled;
        private static JavaScriptSerializer _javaScriptSerializer;

        internal static bool Enabled {
            get {
                
                if (_profileServicesEnabled == null) {
                    ScriptingProfileServiceSection profileServiceSection = ScriptingProfileServiceSection.GetConfigurationSection();
                    Dictionary<string, object> readAccessProperties = null;
                    Dictionary<string, object> writeAccessProperties = null;

                    bool enabled = (profileServiceSection != null) && profileServiceSection.Enabled;

                    if (enabled) {
                        string[] enabledForRead = profileServiceSection.ReadAccessProperties;

                        if (enabledForRead != null && enabledForRead.Length > 0) {
                            readAccessProperties = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
                            ParseProperties(readAccessProperties, enabledForRead);
                        }

                        string[] enabledForWriting = profileServiceSection.WriteAccessProperties;

                        if (enabledForWriting != null && enabledForWriting.Length > 0) {
                            writeAccessProperties = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
                            ParseProperties(writeAccessProperties, enabledForWriting);
                        }
                    }

                    _allowedGet = readAccessProperties;
                    _allowedSet = writeAccessProperties;
                    _profileServicesEnabled = enabled;
                }

                return _profileServicesEnabled.Value;
            }
        }

        private static JavaScriptSerializer JavaScriptSerializer {
            get {
                if (_javaScriptSerializer == null) {
                    WebServiceData webServiceData = WebServiceData.GetWebServiceData(HttpContext.Current, HttpContext.Current.Request.FilePath);
                    _javaScriptSerializer = webServiceData.Serializer;
                    
                    Debug.Assert(_javaScriptSerializer != null);
                }
                return _javaScriptSerializer;
            }
        }

        
        private static void CheckProfileServicesEnabled() {
            if(!Enabled) {
                throw new InvalidOperationException(string.Format(CultureInfo.CurrentCulture, AtlasWeb.AppService_Disabled, "ProfileService"));
            }
        }

        private static IDictionary<string, object> GetProfile(HttpContext context, string[] properties) {
            ProfileBase profile = context.Profile;

            if(profile == null) {
                return null;
            }
            if (_allowedGet == null || _allowedGet.Count == 0) {
                
                return new Dictionary<string, object>(0);
            }

            IDictionary<string, object> dictionary = null;

            if(properties == null) {
                
                dictionary = new Dictionary<string, object>(_allowedGet.Count, StringComparer.OrdinalIgnoreCase);

                
                string propertyName;
                foreach(KeyValuePair<string,object> entry in _allowedGet) {
                    
                    propertyName = entry.Key;
                    dictionary.Add(propertyName, profile[propertyName]);
                }
            }
            else {
                
                
                
                
                
                dictionary = new Dictionary<string, object>(Math.Min(_allowedGet.Count, properties.Length), StringComparer.OrdinalIgnoreCase);

                
                foreach(string propertyName in properties) {
                    if(_allowedGet.ContainsKey(propertyName)) {
                        dictionary.Add(propertyName, profile[propertyName]);
                    }
                }
            }

            return dictionary;
        }

        private static void ParseProperties(Dictionary<string, object> dictionary, string[] properties) {
            foreach(string property in properties) {
                string trimmed = property == null ? string.Empty : property.Trim();
                if(property.Length > 0) {
                    dictionary[trimmed] = true;
                }
            }
        }
       
        private static int SetProfile(HttpContext context, IDictionary<string, object> values) {
            if(values == null || values.Count == 0 || _allowedSet == null) {
                return 0;
            }

            ProfileBase profile = context.Profile;

            if(profile == null) {
                return 0;
            }

            int savedSettings = 0;
            
            
            

            foreach(KeyValuePair<string, object> entry in values) {
                string propertyName = entry.Key;
                if(_allowedSet.ContainsKey(propertyName)) {
                    SettingsProperty settingProperty = ProfileBase.Properties[propertyName];

                    
                    
                    
                    
                    if (settingProperty != null && !settingProperty.IsReadOnly &&
                        (!profile.IsAnonymous || (bool)settingProperty.Attributes["AllowAnonymous"])) {

                        Type propertyType = settingProperty.PropertyType;
                        try {
                            profile[propertyName] = ObjectConverter.ConvertObjectToType(entry.Value, propertyType, JavaScriptSerializer);
                            
                            savedSettings++;
                        }
                        catch(InvalidOperationException) {
                            
                            
                            
                        }
                        catch(MissingMethodException) {
                            
                            
                            
                        }
                    }
                    
                        
                        
                    
                }
                
                    
                    
                
            }

            return savedSettings;
        }

        [WebMethod]
        public IDictionary<string, object> GetAllPropertiesForCurrentUser() {
            CheckProfileServicesEnabled();
            return ProfileService.GetProfile(HttpContext.Current, null);
        }

        [WebMethod]
        public IDictionary<string, object> GetPropertiesForCurrentUser(string[] properties) {
            CheckProfileServicesEnabled();
            return ProfileService.GetProfile(HttpContext.Current, properties);
        }

        [WebMethod]
        public int SetPropertiesForCurrentUser(IDictionary<string, object> values) {
            CheckProfileServicesEnabled();
            return ProfileService.SetProfile(HttpContext.Current, values);
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
