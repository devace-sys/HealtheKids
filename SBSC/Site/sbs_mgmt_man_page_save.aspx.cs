using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Text;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * SBSMgmtManPageSave */
  /**
   * Saves a user announcement
   ***************************************************************************/

  public class SBSMgmtManPageSave: WebUI
  {
    public int saveType = 0;

    public SBSMgmtManPageSave() : base(   "man_page_save"
	                                    , WebUI.CreatePageSubTitle (  ManPages.SEL_LABEL
										                            , ManPages.SEL_LABEL_ADD)
						                , "sbs_mgmt_man_page_save.css"
                                        , ""
										, Constants.ROLE_ANNOUNCEMENT_ADMIN ){}

    protected void Page_Load(object sender, EventArgs e)
    {
      /*-------------------------------
       * Determine what save type
       * this is
       *------------------------------*/

      string recid     = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
      string savetype  = MBA.HttpApplication.getParameter(Constants.PARM_SAVE_TYPE);

      Object vSaveType = MBA.Validate.optInteger(savetype,Messages.INVALID_SAVE_TYPE);

      if (vSaveType == null)
        vSaveType = Constants.SAVE_TYPE_NEW;

      saveType = (int) vSaveType;

      DataEntryRowSaveOrEdit  ctrlSaveOrEdit          = findControlRecu(this.Page,"saveOrEdit")           as DataEntryRowSaveOrEdit;
        MBA.DateBoxHTML5      ctrlStartDate           = findControlRecu(this.Page,"startdate")            as MBA.DateBoxHTML5;
        MBA.ComboBox          ctrlForUserRoleIds      = findControlRecu(this.Page,"foruserroleids")       as MBA.ComboBox;
        MBA.ComboBox          ctrlForClientIds        = findControlRecu(this.Page,"forclientids")         as MBA.ComboBox;

        MBA.TextBox           ctrlTitle               = findControlRecu(this.Page,"announcementtitle")    as MBA.TextBox;
        MBA.RichTextAreaBox   ctrlContent             = findControlRecu(this.Page,"announcementcontent")  as MBA.RichTextAreaBox;

        MBA.TextAreaBox       ctrlDescription         = findControlRecu(this.Page,"descriptioncontent")   as MBA.TextAreaBox;

        MBA.SelectYesOrNo     ctrlOkToDisp            = findControlRecu(this.Page,"oktodisplay")          as MBA.SelectYesOrNo;
        var                   ctrlFeaturedImgFileData = findControlRecu(this.Page, "featuredimgfiledata") as MBA.HiddenTextArea;
        MBA.SelectYesOrNo     ctrlIncludeOnDashboard  = findControlRecu(this.Page, "includeondashboard")  as MBA.SelectYesOrNo;


        MBA.SelectYesOrNo ctrIncludeInWelcomePackage = findControlRecu(this.Page, "include_in_welcome_package") as MBA.SelectYesOrNo;

            //ctrIncludeInWelcomePackage.value = "No";
            //looks like if .value is assigned it can't be re-assigned a few lines down in this method???

        MBA.TextBox       ctrDisplayOrder            = findControlRecu(this.Page, "display_order")              as MBA.TextBox;


      if (saveType == Constants.SAVE_TYPE_EDIT)
      {

        this.subTitle = WebUI.CreatePageSubTitle(ManPages.SEL_LABEL, ManPages.SEL_LABEL_EDIT);

        ManPage rec = Spedmon.ManPages.load(dbConnUser, log, uInfo, recid);

        ctrlSaveOrEdit.saveType                     = saveType;
        ctrlSaveOrEdit.recID                        = rec.id.ToString();

        ctrlStartDate.value                         = (rec.startDate == DateTime.MinValue) ?
                                                      "" : rec.startDate.ToString("yyyy-MM-dd");
        ctrlForUserRoleIds.multiSelectLoad          = true; // Tell control we want to load multi values
        ctrlForUserRoleIds.multiSelectNames         = rec.forUserRoleIdNamesStr;
        ctrlForUserRoleIds.multiSelectValues        = rec.forUserRoleIdValsStr;
        ctrlForUserRoleIds.multiSelectContextLabels = "";

        ctrlForClientIds.multiSelectLoad          = true; // Tell control we want to load multi values
        ctrlForClientIds.multiSelectNames         = rec.forOrgsNamesStr;
        ctrlForClientIds.multiSelectValues        = rec.forOrgsIDsStr;
        ctrlForClientIds.multiSelectContextLabels = "";

        ctrlTitle.value                             = rec.title;

        ctrlDescription.value                       = rec.description;

        ctrlContent.value                           = rec.content;
        ctrlOkToDisp.value                          = Util.boolToYesNo(rec.okToDisplay);
        ctrlFeaturedImgFileData.value               = rec.featuredImgFileData;
        ctrlIncludeOnDashboard.value                = Util.boolToYesNo(rec.includeOnDashboard);


        if (rec.include_in_welcome_package)
          ctrIncludeInWelcomePackage.value = SelectYesOrNo.YES;
        else
          ctrIncludeInWelcomePackage.value = SelectYesOrNo.NO;


        //if ( rec.include_in_welcome_package )
        //  ctrDisplayOrder.value = rec.display_order.ToString();

        ctrDisplayOrder.value = rec.display_order.ToString() ;


      }
      else {

        ctrlOkToDisp.value = SelectYesOrNo.NO;
        ctrIncludeInWelcomePackage.value = SelectYesOrNo.NO;

      }

    }
  }
}
