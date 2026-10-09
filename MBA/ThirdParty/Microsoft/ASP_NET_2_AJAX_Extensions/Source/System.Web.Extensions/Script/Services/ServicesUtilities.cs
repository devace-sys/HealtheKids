using System;
using System.IO;
using System.Text;
using System.Xml;
using System.Xml.Serialization;

namespace System.Web.Script.Services {
    internal static class ServicesUtilities {
        
        internal static string XmlSerializeObjectToString(object obj) {
            
            XmlSerializer xs = new XmlSerializer(obj.GetType());
            MemoryStream ms = new MemoryStream();
            using (XmlTextWriter writer = new XmlTextWriter(ms, Encoding.UTF8)) {
                xs.Serialize(writer, obj);
                ms.Position = 0;
                using (StreamReader reader = new StreamReader(ms)) {
                    return reader.ReadToEnd();
                }
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
