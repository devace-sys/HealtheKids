namespace System.Web.UI {
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Collections.ObjectModel;
    using System.ComponentModel;
    using System.Configuration;
    using System.Diagnostics.CodeAnalysis;
    using System.Globalization;
    using System.Text;
    using System.Security.Permissions;
    using System.Web;
    using System.Web.Profile;
    using System.Web.UI;
    using System.Web.UI.WebControls;
    using System.Web.Resources;
    using System.Web.Script.Serialization;
    using System.Web.Configuration;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal),
    DefaultProperty("Path"),
    TypeConverter(typeof(EmptyStringExpandableObjectConverter))
    ]
    public class ProfileServiceManager {
        private const int StringBuilderCapacity = 128;

        private string[] _loadProperties;
        private string _path;

        internal static void ConfigureProfileService(ref StringBuilder sb, HttpContext context, ScriptManager scriptManager, List<ScriptManagerProxy> proxies) {
            string profileServiceUrl = null;
            ArrayList loadedProperties = null;
            ProfileServiceManager profileManager;

            if(scriptManager.HasProfileServiceManager) {
                profileManager = scriptManager.ProfileService;

                
                profileServiceUrl = profileManager.Path.Trim();
                if(profileServiceUrl.Length > 0) {
                    profileServiceUrl = scriptManager.ResolveClientUrl(profileServiceUrl);
                }

                
                if(profileManager.HasLoadProperties) {
                    loadedProperties = new ArrayList(profileManager._loadProperties);
                }
            }

            
            
            if(proxies != null) {
                foreach(ScriptManagerProxy proxy in proxies) {
                    if(proxy.HasProfileServiceManager) {
                        profileManager = proxy.ProfileService;

                        
                        profileServiceUrl = ApplicationServiceManager.MergeServiceUrls(profileManager.Path, profileServiceUrl, proxy);

                        
                        if(profileManager.HasLoadProperties) {
                            if(loadedProperties == null) {
                                loadedProperties = new ArrayList(profileManager._loadProperties);
                            }
                            else {
                                loadedProperties = ProfileServiceManager.MergeProperties(loadedProperties, profileManager._loadProperties);
                            }
                        }
                    }
                }
            }

            ProfileServiceManager.GenerateInitializationScript(ref sb, context, scriptManager, profileServiceUrl, loadedProperties);
        }

        private static void GenerateInitializationScript(ref StringBuilder sb, HttpContext context, ScriptManager scriptManager, string serviceUrl, ArrayList loadedProperties) {

            if(ProfileService.Enabled) {
                if (sb == null) {
                    sb = new StringBuilder(StringBuilderCapacity);
                }

                
                
                
                
                string defaultServicePath = scriptManager.ResolveClientUrl("~/" + System.Web.Script.Services.WebServiceData._profileServiceFileName);
                sb.Append("Sys.Services._ProfileService.DefaultWebServicePath = '");
                sb.Append(JavaScriptString.QuoteString(defaultServicePath));
                sb.Append("';\n");
            }

            if(!string.IsNullOrEmpty(serviceUrl)) {
                if (sb == null) {
                    sb = new StringBuilder(StringBuilderCapacity);
                }

                sb.Append("Sys.Services.ProfileService.set_path('");
                sb.Append(JavaScriptString.QuoteString(serviceUrl));
                sb.Append("');\n");
            }

            if(loadedProperties != null && loadedProperties.Count > 0) {
                if (sb == null) {
                    sb = new StringBuilder(StringBuilderCapacity);
                }

                
                
                
                SortedList<string, object> topLevelSettings = new SortedList<string, object>(loadedProperties.Count);
                SortedList<string, SortedList<string, object>> profileGroups = null;

                ProfileBase profile = context.Profile;
                foreach(string propertyFullName in loadedProperties) {
                    GetSettingsProperty(profile, propertyFullName, ref topLevelSettings, ref profileGroups,  true);
                }

                RenderProfileProperties(sb, topLevelSettings, profileGroups);
            }
        }

        internal static ArrayList MergeProperties(ArrayList existingProperties, string[] newProperties) {
            
            
            
            
            
            
            foreach(string property in newProperties) {
                if(!string.IsNullOrEmpty(property)) {
                    string trimmedProperty = property.Trim();
                    if((trimmedProperty.Length > 0) && !existingProperties.Contains(trimmedProperty)) {
                        existingProperties.Add(trimmedProperty);
                    }
                }
            }

            return existingProperties;
        }

        private static void GetSettingsProperty(
            ProfileBase profile,
            string fullPropertyName,
            ref SortedList<string, object> topLevelSettings,
            ref SortedList<string, SortedList<string, object>> profileGroups,
            bool ensureExists) {
            
            
            

            int dotIndex = fullPropertyName.IndexOf('.');
            string groupName;
            string propertyName;
            SortedList<string, object> containingObject;

            if(dotIndex == -1) {
                groupName = null;
                propertyName = fullPropertyName;
                containingObject = topLevelSettings;
            }
            else {
                groupName = fullPropertyName.Substring(0, dotIndex);
                propertyName = fullPropertyName.Substring(dotIndex + 1);

                if(profileGroups == null) {
                    profileGroups = new SortedList<string, SortedList<string, object>>();
                    containingObject = new SortedList<string, object>();
                    profileGroups.Add(groupName, containingObject);
                }
                else {
                    containingObject = profileGroups[groupName];
                    if(containingObject == null) {
                        containingObject = new SortedList<string, object>();
                        profileGroups.Add(groupName, containingObject);
                    }
                }
            }

            bool exists = ProfileBase.Properties[fullPropertyName] != null;
            if(ensureExists && !exists) {
                throw new ArgumentException(string.Format(CultureInfo.CurrentCulture, AtlasWeb.AppService_UnknownProfileProperty, fullPropertyName));
            }

            if(exists) {
                containingObject[propertyName] = profile == null ? null : profile[fullPropertyName];
            }
        }

        private static void RenderProfileProperties(StringBuilder sb, SortedList<string, object> topLevelSettings, SortedList<string, SortedList<string, object>> profileGroups) {
            JavaScriptSerializer serializer = new JavaScriptSerializer();

            
            sb.Append("Sys.Services.ProfileService.properties = Sys.Serialization.JavaScriptSerializer.deserialize('");
            
            
            
            
            
            

            
            
            
            sb.Append(JavaScriptString.QuoteString(serializer.Serialize(topLevelSettings)));
            sb.Append("');\n");

            
            
            if(profileGroups != null) {
                foreach(KeyValuePair<string, SortedList<string, object>> group in profileGroups) {
                    sb.Append("Sys.Services.ProfileService.properties.");
                    sb.Append(group.Key); 
                    sb.Append(" = new Sys.Services.ProfileGroup(Sys.Serialization.JavaScriptSerializer.deserialize('");
                    sb.Append(JavaScriptString.QuoteString(serializer.Serialize(group.Value)));
                    sb.Append("'));\n");
                }
            }
        }

        private bool HasLoadProperties {
            get {
                return _loadProperties != null && _loadProperties.Length > 0;
            }
        }

        [
        DefaultValue(null),
        Category("Behavior"),
        NotifyParentProperty(true),
        TypeConverter(typeof(StringArrayConverter)),
        ResourceDescription("ProfileServiceManager_LoadProperties"),
        SuppressMessage("Microsoft.Performance", "CA1819:PropertiesShouldNotReturnArrays",
            Justification="Required by ASP.NET parser.")
        ]
        public string[] LoadProperties {
            get {
                if(_loadProperties == null) {
                    _loadProperties = new string[0];
                }
                return (string[]) _loadProperties.Clone();
            }
            set {
                if(value != null)
                    value = (string[])value.Clone();
                _loadProperties = value;
            }
        }

        [
        DefaultValue(""),
        Category("Behavior"),
        NotifyParentProperty(true),
        ResourceDescription("ApplicationServiceManager_Path")
        ]
        public string Path {
            get { return _path ?? string.Empty; }
            set { _path = value; }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
