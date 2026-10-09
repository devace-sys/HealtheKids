namespace System.Web.Script.Services {
    using System;

    internal class WebServiceTypeData {
        private string _typeName;
        private string _typeNamespace;
        
        private Type _actualType;

        internal WebServiceTypeData(string name, string ns, Type type) {
            _typeName = name;
            _typeNamespace = ns;
            _actualType = type;
        }

        internal string TypeName {
            get { return _typeName; }
        }

        internal string TypeNamespace {
            get { return _typeNamespace; }
        }

        internal Type Type {
            get { return _actualType; }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
