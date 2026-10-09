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
     * SelectMaleOrFemale*/
    /**
     * <Spedmon:SelectMaleOrFemale ID="testmf" name="testmf" title="Select One" runat="server" />
     * 
     ****************************************************************************/

    public class SelectMaleOrFemale : RadioBox
    {
        public const string MALE       = Constants.GENDER_MALE;
        public const string lblMALE    = "Male";
        public const string FEMALE     = Constants.GENDER_FEMALE;
        public const string lblFEMALE  = "Female";
        public const string UNKNOWN    = Constants.GENDER_UNKNOWN;
        public const string lblUNKNOWN = "Unspecified";

        public SelectMaleOrFemale()
        {
            this.firedataselected = true;
            this.labelIsSpan = false;
            this.noClear = false;
            this._onSelectValue = @"function(oldval,newval){return true;}";
        }
 
        protected override void OnPreRender(EventArgs e)
        {
            this.addCssClass("ui-spedmon-box-radio-male-female-container");
            this.additionalCssClassNameForContainer = "modern2021";

            this.AddSelection (lblMALE,    Constants.GENDER_MALE);
            this.AddSelection (lblFEMALE,  Constants.GENDER_FEMALE);
            this.AddSelection (lblUNKNOWN, Constants.GENDER_UNKNOWN);

            base.OnPreRender(e);
        }
 
    }
}