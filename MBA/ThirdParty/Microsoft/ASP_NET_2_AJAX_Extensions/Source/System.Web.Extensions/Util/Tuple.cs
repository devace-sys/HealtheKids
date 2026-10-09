namespace System.Web.Util {
    using System;

    internal sealed class Tuple {
        private object[] _items;

        public Tuple(params object[] items) {
            _items = items;
        }

        public object this[int index] {
            get {
                return _items[index];
            }
        }

        public override int GetHashCode() {
            if (_items.Length == 0) return 0;
            
            
            int hash = _items[0].GetHashCode();
            for (int i = 1; i < _items.Length; i++) {
                hash = ((hash << 5) + hash) ^ _items[i].GetHashCode();
            }
            return hash;
        }

        public override bool Equals(object obj) {
            if (obj == null) return false;
            Tuple other = (Tuple)obj;
            if (other == this) return true;
            if ((other._items.Length != _items.Length)) return false;
            for (int i = 0; i < _items.Length; i++) {
                if (!other[i].Equals(this[i])) return false;
            }
            return true;
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
