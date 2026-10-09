using System;
using System.Collections.Generic;
using System.Reflection;
using System.Text;
using System.Diagnostics;
using System.Web.Services;
using System.Web.Script.Serialization;
using System.Web.Resources;
using System.Globalization;

namespace System.Web.Script.Services {

    internal class WebServiceMethodData {
        private MethodInfo _methodInfo;
        private WebMethodAttribute _webMethodAttribute;
        private ScriptMethodAttribute _scriptMethodAttribute;
        private string _methodName;
        private Dictionary<string, WebServiceParameterData> _parameterData;
        private WebServiceData _owner;

        internal WebServiceMethodData(WebServiceData owner, MethodInfo methodInfo, WebMethodAttribute webMethodAttribute, ScriptMethodAttribute scriptMethodAttribute) {
            _owner = owner;
            _methodInfo = methodInfo;
            _webMethodAttribute = webMethodAttribute;
            _methodName = _webMethodAttribute.MessageName;
            _scriptMethodAttribute = scriptMethodAttribute;
            if (string.IsNullOrEmpty(_methodName)) _methodName = methodInfo.Name;
        }

        internal WebServiceData Owner {
            get { return _owner; }
        }

        private void EnsureParameters() {

            
            if (_parameterData != null)
                return;

            lock (this) {
                Dictionary<string, WebServiceParameterData> parameterData = new Dictionary<string, WebServiceParameterData>();
                int index = 0;
                foreach (ParameterInfo param in _methodInfo.GetParameters()) {
                    parameterData[param.Name] = new WebServiceParameterData(param, index);
                    index++;
                }
                _parameterData = parameterData;
            }
        }

        internal string MethodName {
            get {
                return _methodName;
            }
        }

        internal MethodInfo MethodInfo {
            get {
                return _methodInfo;
            }
        }

        internal IDictionary<string, WebServiceParameterData> ParameterDataDictionary {
            get {
                EnsureParameters();
                return _parameterData;
            }
            set {
                
                ParameterDataDictionary = value;
            }
        }

        internal ICollection<WebServiceParameterData> ParameterDatas {
            get {
                return ParameterDataDictionary.Values;
            }
        }

        internal int CacheDuration {
            get {
                return _webMethodAttribute.CacheDuration;
            }
        }

        internal bool RequiresSession {
            get {
                return _webMethodAttribute.EnableSession;
            }
        }

        internal bool IsStatic {
            get {
                return _methodInfo.IsStatic;
            }
        }

        internal Type ReturnType {
            get {
                return _methodInfo.ReturnType;
            }
        }
        
        internal bool UseXmlResponse {
            get {
                if (_scriptMethodAttribute != null) {
                    return _scriptMethodAttribute.ResponseFormat == ResponseFormat.Xml;
                }
                return false;
            }
        }

        internal bool XmlSerializeString {
            get {
                if (_scriptMethodAttribute != null) {
                    return _scriptMethodAttribute.XmlSerializeString;
                }
                return false;
            }
        }

        internal bool UseGet {
            get {
                if (_scriptMethodAttribute != null) {
                    return _scriptMethodAttribute.UseHttpGet;
                }
                return false;
            }
        }

        internal object CallMethodFromRawParams(object target, IDictionary<string, object> parameters) {
            
            parameters = StrongTypeParameters(parameters);
            return CallMethod(target, parameters);
        }

        private object CallMethod(object target, IDictionary<string, object> parameters) {
            
            EnsureParameters();

            
            object[] actualParams = new object[_parameterData.Count];

            
            foreach (WebServiceParameterData paramData in _parameterData.Values) {
                object value;
                if (parameters.TryGetValue(paramData.ParameterInfo.Name, out value)) {
                    actualParams[paramData.Index] = value;
                }
                else {
                    throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.WebService_MissingArg, paramData.ParameterInfo.Name));
                }
            }

            
            return _methodInfo.Invoke(target, actualParams);
        }

        private IDictionary<string, object> StrongTypeParameters(IDictionary<string, object> rawParams) {
            Debug.Assert(ParameterDataDictionary != null);
            IDictionary<string, WebServiceParameterData> paramDataDictionary = ParameterDataDictionary;

            
            IDictionary<string, object> result = new Dictionary<string, object>(rawParams.Count);

            
            foreach (KeyValuePair<string, object> pair in rawParams) {
                string memberName = pair.Key;
                if (paramDataDictionary.ContainsKey(memberName)) {
                    
                    Type paramType = paramDataDictionary[memberName].ParameterInfo.ParameterType;

                    
                    result[memberName] = ObjectConverter.ConvertObjectToType(pair.Value, paramType, Owner.Serializer);
                }
            }
            return result;
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
