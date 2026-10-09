using System;
using System.Collections.Generic;
using System.Reflection;
using System.Text;
using System.ComponentModel;

namespace System.Web.Script.Services {
    internal class WebServiceParameterData {
        private ParameterInfo _param;
        private int _index;     

        internal WebServiceParameterData(ParameterInfo param, int index) {
            _param = param;
            _index = index;
        }

        internal ParameterInfo ParameterInfo {
            get { return _param; }
        }

        internal int Index {
            get { return _index; }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
