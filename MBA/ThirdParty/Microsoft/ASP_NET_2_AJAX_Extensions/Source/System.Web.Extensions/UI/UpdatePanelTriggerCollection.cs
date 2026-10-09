namespace System.Web.UI {
    using System;
    using System.Collections.ObjectModel;
    using System.Diagnostics.CodeAnalysis;
    using System.Security.Permissions;
    using System.Web;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal)
    ]
    public class UpdatePanelTriggerCollection : Collection<UpdatePanelTrigger> {
        private bool _initialized;
        private UpdatePanel _owner;

        public UpdatePanelTriggerCollection(UpdatePanel owner) {
            if (owner == null) {
                throw new ArgumentNullException("owner");
            }
            _owner = owner;
        }

        public UpdatePanel Owner {
            get {
                return _owner;
            }
        }

        [SuppressMessage("Microsoft.Security", "CA2123:OverrideLinkDemandsShouldBeIdenticalToBase")]
        protected override void ClearItems() {
            foreach (UpdatePanelTrigger trigger in this) {
                trigger.SetOwner(null);
            }
            base.ClearItems();
        }

        internal bool HasTriggered() {
            foreach (UpdatePanelTrigger trigger in this) {
                if (trigger.HasTriggered()) {
                    return true;
                }
            }

            return false;
        }

        internal void Initialize() {
            foreach (UpdatePanelTrigger trigger in this) {
                trigger.Initialize();
            }
            _initialized = true;
        }

        [SuppressMessage("Microsoft.Security", "CA2123:OverrideLinkDemandsShouldBeIdenticalToBase")]
        protected override void InsertItem(int index, UpdatePanelTrigger item) {
            item.SetOwner(Owner);
            if (_initialized) {
                item.Initialize();
            }
            base.InsertItem(index, item);
        }

        [SuppressMessage("Microsoft.Security", "CA2123:OverrideLinkDemandsShouldBeIdenticalToBase")]
        protected override void RemoveItem(int index) {
            this[index].SetOwner(null);
            base.RemoveItem(index);
        }

        [SuppressMessage("Microsoft.Security", "CA2123:OverrideLinkDemandsShouldBeIdenticalToBase")]
        protected override void SetItem(int index, UpdatePanelTrigger item) {
            this[index].SetOwner(null);

            item.SetOwner(Owner);
            if (_initialized) {
                item.Initialize();
            }
            base.SetItem(index, item);
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
