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
     * DataEntryRowIframeContentEntitySaveOrView */
    /**
     * Renders an iFrame and changes its source based on what is selected on the
     * screen
     * 
     * the js file will need to be included for this component
     * 
     ****************************************************************************/

    public class DataEntryRowIframeContentEntitySaveOrView : ControlBase
    {

        /*-------------------------------
         * Note: We do not store this
         * controls value in an 
         * attribute.  Therefore we
         * override the value property.
         *------------------------------*/

        public DataEntryRowIframeContentEntitySaveOrView() : base() { }

        protected string _parentCssClasses      = @"";              // The css classes for the iFrame's parent div
        protected string _iFrameCssClasses      = @"";              // The css classes for the iFrame
        protected string _urlAddNew             = @"";              // URL for add new (token will be appended once passed in)
        protected string _urlEdit               = @"";              // URL for edit    (token will be appended once passed in)
        protected string _urlView               = @"";              // URL for view    (token will be appended once passed in)
        protected string _addNewReqFieldIDs     = @"";              // Field IDs required in URL for add new
        protected string _addNewReqParamNames   = @"";              // Parameter names required in URL for add new
        protected string _editReqFieldIDs       = @"";              // Field IDs required in URL for edits
        protected string _editReqParamNames     = @"";              // Parameter names required in URL for edits
        protected string _viewReqFieldIDs       = @"";              // Field IDs required in URL for view
        protected string _viewReqParamNames     = @"";              // Parameter names required in URL for view
        protected string _iFrameResetFieldNames = @"";              // Field names upon which the iFrame will reset on change
        protected string _editFieldID           = @"";              // The ID of the field that launches the edit upon selection
        protected string _fnCustomAddNew        = @"function() { return true; }"; // a function that will run at the end of the add new callback (for example, used for extra error messages), needs to return true for execution to continue
        protected string _fnCustomEdit          = @"function() { return true; }"; // a function that will run at the end of the edit callback (for example, used for extra error messages), needs to return true for execution to continue
        protected string _fnCustomView          = @"function() { return true; }"; // a function that will run at the end of the view callback (for example, used for extra error messages), needs to return true for execution to continue
        protected bool   _hasAddNew             = true;             // Determines whether component will have add new functionality
        protected bool   _hasEdit               = true;             // Determines whether component will have edit functionality
        protected bool   _hasView               = true;             // Determines whether component will have view functionality
        protected bool   _hidden                = false;            // Decides whether component is hidden or not

        public string parentCssClasses       { get { return _parentCssClasses;      } set { _parentCssClasses      = value; } }
        public string iFramecssClasses       { get { return _iFrameCssClasses;      } set { _iFrameCssClasses      = value; } }
        public string urlAddNew              { get { return _urlAddNew;             } set { _urlAddNew             = value; } }
        public string urlEdit                { get { return _urlEdit;               } set { _urlEdit               = value; } }
        public string urlView                { get { return _urlView;               } set { _urlView               = value; } }
        public string addNewReqFieldIDs      { get { return _addNewReqFieldIDs;     } set { _addNewReqFieldIDs     = value; } }
        public string addNewReqParamNames    { get { return _addNewReqParamNames;   } set { _addNewReqParamNames   = value; } }
        public string editReqFieldIDs        { get { return _editReqFieldIDs;       } set { _editReqFieldIDs       = value; } }
        public string editReqParamNames      { get { return _editReqParamNames;     } set { _editReqParamNames     = value; } }
        public string viewReqFieldIDs        { get { return _viewReqFieldIDs;       } set { _viewReqFieldIDs       = value; } }
        public string viewReqParamNames      { get { return _viewReqParamNames;     } set { _viewReqParamNames     = value; } }
        public string iFrameResetFieldNames  { get { return _iFrameResetFieldNames; } set { _iFrameResetFieldNames = value; } }
        public string editFieldID            { get { return _editFieldID;           } set { _editFieldID           = value; } }
        public string fnCustomAddNew         { get { return _fnCustomAddNew;        } set { _fnCustomAddNew        = value; } }
        public string fnCustomEdit           { get { return _fnCustomEdit;          } set { _fnCustomEdit          = value; } }
        public string fnCustomView           { get { return _fnCustomView;          } set { _fnCustomView          = value; } }
        public bool   hidden                 { get { return _hidden;                } set { _hidden                = value; } }
        public bool   hasAddNew              { get { return _hasAddNew;             } set { _hasAddNew             = value; } }
        public bool   hasEdit                { get { return _hasEdit;               } set { _hasEdit               = value; } }
        public bool   hasView                { get { return _hasView;               } set { _hasView               = value; } }
        protected override void Render(HtmlTextWriter writer)
        {
            // if hidden, don't render anything
            if (_hidden)
            {
                return;
            }

            var _iFrameID  = @"mbaiframecontent" + "_" + Guid.NewGuid().ToString(); // the ID of the iFrame

            // If add new, edit, or view URLs are missing, throw error
            if (
                   (_hasAddNew && String.IsNullOrEmpty( _urlAddNew ))  // check add new
                || (_hasEdit   && String.IsNullOrEmpty( _urlEdit   ))  // check edit
                || (_hasView   && String.IsNullOrEmpty( _urlView   ))  // check view
            )
            {
                throw new Exception("Add New, Edit, or View URL is not provided for DataEntryRowIframeContentEntitySaveOrView, but is required!");
            }

            // render view and add new buttons if required
            var _addNewBtnID = _iFrameID + "_" + "addnew";
            var _viewBtnID   = _iFrameID + "_" + "view";

            writer.Write(@"<div class=""d-flex align-items-center"">"
                + ((_hasAddNew) ? @"<i id=""{0}"" class=""fas fa-plus"" style=""font-size: 1.5em; color: #76a6d2;"" title=""Add New Record""></i>" : "")
                + ((_hasView)   ? @"<i id=""{1}"" class=""fas fa-eye ml-2"" title=""View Records""></i>" : "")
            + @"</div>", _addNewBtnID, _viewBtnID);

            // render iFrame
            writer.Write(@"<div class=""mba-data-entry-row-iframe-content-wrapper row mt-3 {0}"">"
                            + @"<iframe "
                            + @"    id=""{1}"""
                            + @"    name=""{1}"""
                            + @"    class=""mba-data-entry-row-iframe-content col-12 {2}"""
                            + @"    src=""about:blank"">"
                            + @"</iframe>"
                        + @"</div>"
            , _parentCssClasses
            , _iFrameID
            , _iFrameCssClasses
            );

            string _opts = @"{"
                         + @"'hasAddNew':"               + Util.netBoolToJSBool(_hasAddNew) 
                         + @",'hasEdit':"                + Util.netBoolToJSBool(_hasEdit) 
                         + @",'hasView':"                + Util.netBoolToJSBool(_hasView) 
                         + @",'urlAddNew':'"             + _urlAddNew              + @"'"
                         + @",'urlEdit':'"               + _urlEdit                + @"'"
                         + @",'urlView':'"               + _urlView                + @"'"
                         + @",'addNewReqFieldIDs':'"     + _addNewReqFieldIDs      + @"'"
                         + @",'addNewReqParamNames':'"   + _addNewReqParamNames    + @"'"
                         + @",'editReqFieldIDs':'"       + _editReqFieldIDs        + @"'"
                         + @",'editReqParamNames':'"     + _editReqParamNames      + @"'"
                         + @",'viewReqFieldIDs':'"       + _viewReqFieldIDs        + @"'"
                         + @",'viewReqParamNames':'"     + _viewReqParamNames      + @"'"
                         + @",'iFrameResetFieldNames':'" + _iFrameResetFieldNames  + @"'"
                         + @",'$addNewBtn':"             + @"$('#" + _addNewBtnID  + @"')" 
                         + @",'editFieldID':'"           + _editFieldID            + @"'"
                         + @",'$viewBtn':"               + @"$('#" + _viewBtnID    + @"')"
                         + @",'fnCustomAddNew':"         + _fnCustomAddNew
                         + @",'fnCustomEdit':"           + _fnCustomEdit  
                         + @",'fnCustomView':"           + _fnCustomView
                         + @"}";
            writer.Write("<script>$( document ).ready(function(){ $('#" + _iFrameID + "').dataEntryRowIframeContentEntitySaveOrView(" + _opts + ");})</script>");

            base.Render(writer);
        }
    }
}

