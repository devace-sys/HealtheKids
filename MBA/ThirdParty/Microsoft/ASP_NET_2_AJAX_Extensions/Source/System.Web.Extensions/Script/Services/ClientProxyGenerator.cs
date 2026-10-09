namespace System.Web.Script.Services {
    using System;
    using System.Reflection;
    using System.Collections;
    using System.Collections.Generic;
    using System.Diagnostics;
    using System.Text;
    using System.Web;
    using System.Web.UI;
    using System.Web.Script.Serialization;
    using System.Globalization;
    using System.IO;
    using System.Security.Permissions;
    using System.Security;

    internal abstract class ClientProxyGenerator {
        private Hashtable _registeredNamespaces = new Hashtable();
        protected StringBuilder _builder;
        protected bool _debugMode;
        

        internal string GetClientProxyScript(WebServiceData webServiceData) {
            if (webServiceData.MethodDatas.Count == 0) return null;
            _builder = new StringBuilder();

            
            GenerateConstructor(webServiceData);

            
            GeneratePrototype(webServiceData);

            GenerateRegisterClass(webServiceData);
            GenerateStaticInstance(webServiceData);
            GenerateStaticMethods(webServiceData);

            
            GenerateClientTypeProxies(webServiceData);
            GenerateEnumTypeProxies(webServiceData.EnumTypes);
            return _builder.ToString();
        }

        protected void GenerateRegisterClass(WebServiceData webServiceData) {
            
            string typeName = GetProxyTypeName(webServiceData);
            _builder.Append(typeName).Append(".registerClass('").Append(typeName).Append("',Sys.Net.WebServiceProxy);\r\n");
        }

        protected virtual void GenerateConstructor(WebServiceData webServiceData) {
            GenerateTypeDeclaration(webServiceData, false);
            _builder.Append("function() {\r\n");
            _builder.Append(GetProxyTypeName(webServiceData)).Append(".initializeBase(this);\r\n");
            GenerateFields();
            _builder.Append("}\r\n");
        }

        protected virtual void GeneratePrototype(WebServiceData webServiceData) {
            GenerateTypeDeclaration(webServiceData, true);
            _builder.Append("{\r\n");
            bool first = true;
            foreach (WebServiceMethodData methodData in webServiceData.MethodDatas) {
                if (!first) {
                    _builder.Append(",\r\n");
                }
                first = false;
                GenerateWebMethodProxy(methodData);
            }
            _builder.Append("}\r\n");
        }

        protected virtual void GenerateTypeDeclaration(WebServiceData webServiceData, bool genClass) {
            AppendClientTypeDeclaration(webServiceData.TypeData.TypeNamespace, webServiceData.TypeData.TypeName, genClass, true);
        }

        protected void GenerateFields() {
            _builder.Append("this._timeout = 0;\r\n");
            _builder.Append("this._userContext = null;\r\n");
            _builder.Append("this._succeeded = null;\r\n");
            _builder.Append("this._failed = null;\r\n");
        }

        protected virtual void GenerateMethods() {
        }

        protected void GenerateStaticMethods(WebServiceData webServiceData) {
            string className = GetProxyTypeName(webServiceData);
            
            foreach (WebServiceMethodData methodData in webServiceData.MethodDatas) {
                string methodName = methodData.MethodName;
                _builder.Append(className).Append('.').Append(methodName).Append("= function(");
                StringBuilder argBuilder = new StringBuilder();
                bool first = true;
                foreach (WebServiceParameterData paramData in methodData.ParameterDatas) {
                    if (!first) argBuilder.Append(',');
                    else first = false;
                    argBuilder.Append(paramData.ParameterInfo.Name);
                }
                if (!first) argBuilder.Append(',');
                argBuilder.Append("onSuccess,onFailed,userContext");

                _builder.Append(argBuilder.ToString()).Append(") {");

                
                
                
                

                _builder.Append(className).Append("._staticInstance.").Append(methodName).Append('(');
                _builder.Append(argBuilder.ToString()).Append("); }\r\n");
            }
        }

        protected abstract string GetProxyPath();

        protected void GenerateStaticInstance(WebServiceData data) {
            string typeName = GetProxyTypeName(data);
            _builder.Append(typeName).Append("._staticInstance = new ").Append(typeName).Append("();\r\n");

            
            if (_debugMode) {
                
                
                
                
                
                
                
                
                
                
                _builder.Append(typeName).Append(".set_path = function(value) { \r\nvar e = Function._validateParams(arguments, [{name: 'path', type: String}]); if (e) throw e; ").Append(typeName).Append("._staticInstance._path = value; }\r\n");
                _builder.Append(typeName).Append(".get_path = function() { return ").Append(typeName).Append("._staticInstance._path; }\r\n");
                _builder.Append(typeName).Append(".set_timeout = function(value) { var e = Function._validateParams(arguments, [{name: 'timeout', type: Number}]); if (e) throw e; if (value < 0) { throw Error.argumentOutOfRange('value', value, Sys.Res.invalidTimeout); }\r\n").Append(typeName).Append("._staticInstance._timeout = value; }\r\n");
                _builder.Append(typeName).Append(".get_timeout = function() { \r\nreturn ").Append(typeName).Append("._staticInstance._timeout; }\r\n");
                _builder.Append(typeName).Append(".set_defaultUserContext = function(value) { \r\n").Append(typeName).Append("._staticInstance._userContext = value; }\r\n");
                _builder.Append(typeName).Append(".get_defaultUserContext = function() { \r\nreturn ").Append(typeName).Append("._staticInstance._userContext; }\r\n");
                _builder.Append(typeName).Append(".set_defaultSucceededCallback = function(value) { \r\nvar e = Function._validateParams(arguments, [{name: 'defaultSucceededCallback', type: Function}]); if (e) throw e; ").Append(typeName).Append("._staticInstance._succeeded = value; }\r\n");
                _builder.Append(typeName).Append(".get_defaultSucceededCallback = function() { \r\nreturn ").Append(typeName).Append("._staticInstance._succeeded; }\r\n");
                _builder.Append(typeName).Append(".set_defaultFailedCallback = function(value) { \r\nvar e = Function._validateParams(arguments, [{name: 'defaultFailedCallback', type: Function}]); if (e) throw e; ").Append(typeName).Append("._staticInstance._failed = value; }\r\n");
                _builder.Append(typeName).Append(".get_defaultFailedCallback = function() { \r\nreturn ").Append(typeName).Append("._staticInstance._failed; }\r\n");
            }
            else {
                _builder.Append(typeName).Append(".set_path = function(value) { ").Append(typeName).Append("._staticInstance._path = value; }\r\n");
                _builder.Append(typeName).Append(".get_path = function() { return ").Append(typeName).Append("._staticInstance._path; }\r\n");
                _builder.Append(typeName).Append(".set_timeout = function(value) { ").Append(typeName).Append("._staticInstance._timeout = value; }\r\n");
                _builder.Append(typeName).Append(".get_timeout = function() { return ").Append(typeName).Append("._staticInstance._timeout; }\r\n");
                _builder.Append(typeName).Append(".set_defaultUserContext = function(value) { ").Append(typeName).Append("._staticInstance._userContext = value; }\r\n");
                _builder.Append(typeName).Append(".get_defaultUserContext = function() { return ").Append(typeName).Append("._staticInstance._userContext; }\r\n");
                _builder.Append(typeName).Append(".set_defaultSucceededCallback = function(value) { ").Append(typeName).Append("._staticInstance._succeeded = value; }\r\n");
                _builder.Append(typeName).Append(".get_defaultSucceededCallback = function() { return ").Append(typeName).Append("._staticInstance._succeeded; }\r\n");
                _builder.Append(typeName).Append(".set_defaultFailedCallback = function(value) { ").Append(typeName).Append("._staticInstance._failed = value; }\r\n");
                _builder.Append(typeName).Append(".get_defaultFailedCallback = function() { return ").Append(typeName).Append("._staticInstance._failed; }\r\n");
            }

            _builder.Append(typeName).Append(".set_path(\"").Append(GetProxyPath()).Append("\");\r\n");
        }

        private static void BuildArgsDictionary(WebServiceMethodData methodData, StringBuilder args, StringBuilder argsDict) {
            argsDict.Append('{');
            
            foreach (WebServiceParameterData paramData in methodData.ParameterDatas) {
                string name = paramData.ParameterInfo.Name;
                
                if (args.Length > 0) {
                    args.Append(',');
                    argsDict.Append(',');
                }
                args.Append(name);
                argsDict.Append(name).Append(':').Append(name);
            }
            argsDict.Append("}");
            if (args.Length > 0) args.Append(',');
            args.Append("succeededCallback, failedCallback, userContext");
        }

        private void GenerateWebMethodProxy(WebServiceMethodData methodData) {
            string methodName = methodData.MethodName;
            string typeName = GetProxyTypeName(methodData.Owner);
            string useGet = methodData.UseGet ? "true" : "false";

            _builder.Append(methodName).Append(':');
            
            
            StringBuilder args = new StringBuilder();
            StringBuilder argsDict = new StringBuilder();
            BuildArgsDictionary(methodData, args, argsDict);
            

            
            

            
            _builder.Append("function(").Append(args.ToString()).Append(") {\r\n");
            
            _builder.Append("return this._invoke(").Append(typeName).Append(".get_path(), ");
            _builder.Append("'").Append(methodName).Append("',");
            _builder.Append(useGet).Append(',');
            _builder.Append(argsDict.ToString()).Append(",succeededCallback,failedCallback,userContext); }");
        }

        


        private void GenerateClientTypeProxies(WebServiceData data) {
            bool first = true;
            foreach (Type t in data.ClientTypes) {
                if (first) {
                    _builder.Append("var gtc = Sys.Net.WebServiceProxy._generateTypedConstructor;\r\n");
                    first = false;
                }

                string typeID = data.GetTypeStringRepresentation(t.FullName);
                string typeName = GetClientTypeName(t.FullName);

                EnsureNamespace(t.Namespace);
                _builder.Append("if (typeof(").Append(typeName).Append(") === 'undefined') {\r\n");
                AppendClientTypeDeclaration(t.Namespace, t.FullName, false, false);
                
                _builder.Append("gtc(\"");
                _builder.Append(typeID);
                _builder.Append("\");\r\n");
                _builder.Append(typeName).Append(".registerClass('").Append(typeName).Append("');\r\n}\r\n");
            }
        }

        
        private void GenerateEnumTypeProxies(IEnumerable<Type> enumTypes) {
            foreach (Type t in enumTypes) {
                EnsureNamespace(t.Namespace);
                string typeName = GetClientTypeName(t.FullName);
                string[] enumNames = Enum.GetNames(t);
                int[] enumValues = (int[])Enum.GetValues(t);
                Debug.Assert(enumNames.Length == enumValues.Length);
                _builder.Append("if (typeof(").Append(typeName).Append(") === 'undefined') {\r\n");
                _builder.Append(typeName).Append(" = function() { throw Error.invalidOperation(); }\r\n");
                _builder.Append(typeName).Append(".prototype = {");
                for (int i = 0; i < enumNames.Length; i++) {
                    if (i > 0) _builder.Append(',');
                    _builder.Append(enumNames[i]);
                    _builder.Append(": ");
                    _builder.Append(enumValues[i]);
                }
                _builder.Append("}\r\n");
                _builder.Append(typeName).Append(".registerEnum('").Append(typeName).Append('\'');
                _builder.Append(", true);\r\n}\r\n");
            }
        }

        private void AppendClientTypeDeclaration(string ns, string typeName, bool genClass, bool ensureNS) {
            
            
            if (!String.IsNullOrEmpty(ns)) {
                if (ensureNS) EnsureNamespace(ns);
            }
            else if (!genClass) {
                
                _builder.Append("var ");
            }
            _builder.Append(GetClientTypeName(typeName));
            if (genClass) {
                _builder.Append(".prototype");
            }
            _builder.Append('=');

        }

        
        protected virtual string GetProxyTypeName(WebServiceData data) {
            return GetClientTypeName(data.TypeData.TypeName);
        }

        internal static string GetClientTypeName(string name) {
            
            return name.Replace('+', '_');
        }

        private void EnsureNamespace(string ns) {
            if (String.IsNullOrEmpty(ns)) return;

            
            if (!_registeredNamespaces.Contains(ns)) {
                _builder.Append("Type.registerNamespace('").Append(ns).Append("');\r\n");
                _registeredNamespaces[ns] = null;
            }
        }









    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
