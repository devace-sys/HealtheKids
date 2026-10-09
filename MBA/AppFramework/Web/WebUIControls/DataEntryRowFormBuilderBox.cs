using System;
using System.Collections;
using System.Globalization;
using System.Threading;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text.RegularExpressions;

namespace MBA
{

    /**************************************************************************
     * FormBuilderTextAreaBox */
    /**
     * Form Builder textarea
     * 
     * @param  name             name
     * @param  value            value
     ****************************************************************************/

    public class DataEntryRowFormBuilderBox : DataEntryRow
    {

        /*-------------------------------
         * Note: We do not store this
         * controls value in an 
         * attribute.  Therefore we
         * override the value property.
         *------------------------------*/

        public DataEntryRowFormBuilderBox() : base() { }

        protected MBA.HiddenTextArea _ctrlFormContentJSON     = new MBA.HiddenTextArea();
        protected MBA.Button         _ctrlShowFormBuilderBtn  = new MBA.Button();
        protected string             _showFormBuilderBtnText  = "Build / Edit A Form";
        // the following strings are used to set IDs of related divs based on the ID passed in
        protected string             _dialogDivIDPostfix      = "FormBuilderModalCont";
        protected string             _dialogButtonPostfix     = "ShowFormBuilderBtn";
        public string value { get { return _ctrlFormContentJSON.value; } set { _ctrlFormContentJSON.value = value; } }
        public string name  { get { return _ctrlFormContentJSON.name; } set { _ctrlFormContentJSON.name = value; } }
        public string showFormBuilderBtnText { get { return _showFormBuilderBtnText; } set { _showFormBuilderBtnText = value; } }

        protected override void Render(HtmlTextWriter writer)
        {
            // load js & disable bootstrap classes for formatting
            this.useBootstrapGrid = false;
            
            writer.Write(@"<script src=""web-ui-3/openvidu/js/mba-util.js""></script>");
            // write dialog div for our form builder to load into
            string formBuilderModalContID = this.name + this._dialogDivIDPostfix;
            writer.Write(@"<div id=""" + formBuilderModalContID + @""" style=""display:none;""></div>");            

            // set up button to launch FormBuilder in dialog
            _ctrlShowFormBuilderBtn.ID = this.name + _dialogButtonPostfix;
            _ctrlShowFormBuilderBtn.title = "Launch Form Builder";
            _ctrlShowFormBuilderBtn.onclick = "spedmonShowFormBuilderBox('" + this.name + "', '" + formBuilderModalContID + "')";
            _ctrlShowFormBuilderBtn.text = _showFormBuilderBtnText;

            // set up hidden textarea for FormBuilder JSON content
            _ctrlFormContentJSON.name  = this.name;
            _ctrlFormContentJSON.title = this.name;
            _ctrlFormContentJSON.ID    = this.name;

            // add a data list for class options
            writer.Write(@"<datalist id=""form-builder-bs-class-options"">"
                         + @"<option value=""font-italic"">"
                         + @"<option value=""font-weight-bold"">"
                         + @"<option value=""mark"">"
                         + @"<option value=""text-capitalize"">"
                         + @"<option value=""text-center"">"
                         + @"<option value=""text-dark"">"
                         + @"<option value=""text-lowercase"">"
                         + @"<option value=""text-muted"">"
                         + @"<option value=""text-primary"">"
                         + @"<option value=""text-secondary"">"
                         + @"<option value=""text-right"">"
                         + @"<option value=""text-success"">"
                         + @"<option value=""text-uppercase"">"
                         + @"<option value=""text-warning"">"
                         + @"<option value=""small"">"
                         + @"<option value=""lead"">"
                         + @"<option value=""bg-danger"">"
                         + @"<option value=""bg-dark"">"
                         + @"<option value=""bg-info"">"
                         + @"<option value=""bg-light"">"
                         + @"<option value=""bg-primary"">"
                         + @"<option value=""bg-secondary"">"
                         + @"<option value=""bg-success"">"
                         + @"<option value=""bg-warning"">"
                         + @"</datalist>");


            /*-------------------------------
             * Add controls
             *------------------------------*/

            this.Controls.Add(this._ctrlShowFormBuilderBtn);
            this.Controls.Add(this._ctrlFormContentJSON);

            // change container ID to avoid conflict with hidden textarea
            this.ID += "Cont";

            base.Render(writer);
        }
    }
}

