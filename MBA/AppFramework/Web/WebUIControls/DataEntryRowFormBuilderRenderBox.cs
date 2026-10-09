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

    public class DataEntryRowFormBuilderRenderBox : DataEntryRow
    {

        /*-------------------------------
         * Note: We do not store this
         * controls value in an 
         * attribute.  Therefore we
         * override the value property.
         *------------------------------*/

        public DataEntryRowFormBuilderRenderBox() : base() { }

        protected MBA.HiddenTextArea _ctrlFormAnswersJSON      = new MBA.HiddenTextArea();
        protected MBA.HiddenTextArea _ctrlFormQuestionsJSON    = new MBA.HiddenTextArea();
        protected MBA.Button         _ctrlShowFormBuilderBtn   = new MBA.Button();
        protected string             _formBuilderQuestionsJSON = "[]";
        protected string             _formBuilderRenderBtnText = "Click To Enter / Edit Service Details";

        // the following strings are used to set IDs of related divs based on the ID passed in
        protected string             _dialogDivIDPostfix       = "FormBuilderRenderModalCont";
        protected string             _dialogButtonPostfix      = "RenderFormBuilderQuestionsBtn";
        protected string             _formQuestionsJSONPostfix = "FormBuilderQuestionsJSON";
        protected string             _formBuilderQuestionsJSONID;
        protected bool               _formEditable = true;
        protected bool               _renderInDialog = true;

        public string value                        { get { return _ctrlFormAnswersJSON.value; } set { _ctrlFormAnswersJSON.value = value; } }
        public string name                         { get { return _ctrlFormAnswersJSON.name; } set { _ctrlFormAnswersJSON.name = value; } }
        public string showFormBuilderBtnText       { get { return _formBuilderRenderBtnText; } set { _formBuilderRenderBtnText = value; } }
        public string formBuilderQuestionsJSON     { get { return _ctrlFormQuestionsJSON.value; } set { _ctrlFormQuestionsJSON.value = value; } }
        public bool formEditable                   { get { return _formEditable; } set { _formEditable = value; } }
        public bool renderInDialog                 { get { return _renderInDialog; } set { _renderInDialog = value; } }
        public string formBuilderQuestionsJSONID   { get { return this.name + this._formQuestionsJSONPostfix; } }
        public string formBuilderRenderDialogBtnID { get { return this.name + this._dialogButtonPostfix; } }

        protected override void Render(HtmlTextWriter writer)
        {
            // load js & disable bootstrap classes for formatting
            // ISSUE: These might be included twice if a formbuilder component is also on the screen
            this.useBootstrapGrid = false;
            writer.Write(@"<script src=""web-ui-3/openvidu/js/mba-util.js""></script>");

            // write dialog div for our form builder to load into
            string formBuilderModalContID = this.name + this._dialogDivIDPostfix;
            writer.Write(@"<div id=""" + formBuilderModalContID + @""" style=""display:none;""></div>");

            // set up hidden textareas for FormBuilder JSON questions and answers
            _ctrlFormAnswersJSON.name  = this.name;
            _ctrlFormAnswersJSON.title = this.name;
            _ctrlFormAnswersJSON.ID    = this.name;

            _ctrlFormQuestionsJSON.name       = this.formBuilderQuestionsJSONID;
            _ctrlFormQuestionsJSON.title      = this.formBuilderQuestionsJSONID;
            _ctrlFormQuestionsJSON.ID         = this.formBuilderQuestionsJSONID;

            // set up button to launch FormBuilder in dialog if it is used
            if (_renderInDialog)
            {
                _ctrlShowFormBuilderBtn.ID = this.name + _dialogButtonPostfix;
                _ctrlShowFormBuilderBtn.title = this.showFormBuilderBtnText;
                _ctrlShowFormBuilderBtn.onclick = "spedmonRenderFormBuilderFromJSON('" + this.name + "', " + Util.netBoolToJSBool(_formEditable) + ", " + Util.netBoolToJSBool(_renderInDialog) + ")";
                _ctrlShowFormBuilderBtn.text = _formBuilderRenderBtnText;

                this.Controls.Add(this._ctrlShowFormBuilderBtn);
            }
            // if no dialog then just render the form data
            else
            {
                if (this.entryInitiallyHidden == false) { 
                    writer.Write("<script>$(function() { spedmonRenderFormBuilderFromJSON('" + this.name + "', " + Util.netBoolToJSBool(_formEditable) + ", " + Util.netBoolToJSBool(_renderInDialog) + ");});</script>");
                }
            }


            /*-------------------------------
             * Add controls
             *------------------------------*/

            this.Controls.Add(this._ctrlFormQuestionsJSON);
            this.Controls.Add(this._ctrlFormAnswersJSON);

            // change container ID to avoid conflict with hidden textarea
            this.ID += "Cont";

            base.Render(writer);
        }
    }
}

