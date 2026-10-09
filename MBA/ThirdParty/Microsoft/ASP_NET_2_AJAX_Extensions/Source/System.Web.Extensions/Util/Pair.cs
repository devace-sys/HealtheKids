namespace System.Web.Util {
    using System;

    
    internal sealed class Pair<TFirst, TSecond> {
        private readonly TFirst _first;
        private readonly TSecond _second;

        public Pair(TFirst first, TSecond second) {
            if (first == null) {
                throw new ArgumentNullException("first");
            }
            if (second == null) {
                throw new ArgumentNullException("second");
            }
            _first = first;
            _second = second;
        }

        public TFirst First {
            get {
                return _first;
            }
        }

        public TSecond Second {
            get {
                return _second;
            }
        }

        public override bool Equals(object obj) {
            if (obj == this) {
                return true;
            }

            Pair<TFirst, TSecond> other = obj as Pair<TFirst, TSecond>;
            return (other != null) && (other._first.Equals(_first)) && (other._second.Equals(_second));
        }

        public override int GetHashCode() {
            int a = _first.GetHashCode();
            
            
            return ((a << 5) + a) ^ _second.GetHashCode();
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
