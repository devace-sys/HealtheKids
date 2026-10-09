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
using MBA;
using System.Collections.Generic;
using System.Data.SqlClient;

namespace Spedmon
{

  public class UserAllTimekeeperPanel : WebUI
  {


    public ReturnDB r_db_1;

    public string tkn      = "";


    public string clientSaveURL;
    public int saveType                      = 0;
    public string firstcheckVal              = "";
    public string claim_TCMEffectiveDateVal  = "";
    public string parentConsentAgreementEffectiveDateVal = "";
    public string planWriterAccessEndDateVal = "";
    public string TeleHealthAccessEndDateVal = "";
    public string TeleIEPAccessEndDateVal    = "";
    public string LEARecoveryBudgetVal       = "";
    public string hyQueueFeeVal              = "";
    public string planWriterFeeVal           = "";
    public string baselineReimbursementVal   = "";
    public List<ClientPBSDocumentRecord> specAuthRecs = new List<ClientPBSDocumentRecord>();
    public List<ClientContactsRecord>    contactRecs  = new List<ClientContactsRecord>();
    public List<ClientContractsRecord>   contractRecs  = new List<ClientContractsRecord>();

    public bool isDelinquentDTKUser;
    public string warning_out;
    public string warning_out_hidden;
    public string _lastDayOfSchedule;
    public string e_id;

    public string divcollg10_classes;
    public bool preselected_empid_scrollmenu = false;

    public UserAllTimekeeperPanel() : base("", "", "user_all_timekeeper_panel.css|bootstrap-multiselect.css", "sbs_mgmt_client_save.js|favorite-tasks-favorite-clients.js|bootstrap-multiselect.js", Constants.ROLE_SBS_ALL) {

            
    }
    protected void Page_Load(object sender, EventArgs e)
    {


            tkn = ((this.rd.loggedIn) ? this.rd.wu.usr.token : "");


            if (rd.wu.usr.timeSheetUserInfo == null)
                rd.wu.usr.timeSheetUserInfo = MBA.Security.BitteTimePeople.getTimeEntryPersonDetail(rd.wu.usr.userName);

            // this.isDelinquentDTKUser = rd.wu.usr.timeSheetUserInfo.isDelinquentDTKUser; 
            //if (this.isDelinquentDTKUser)
            //  MBA.Security.BitteTimePeople.isHourVerifyRequired(this.dbConnApp, log, uInfo, rd.wu.usr.timeSheetUserInfo.employeeid.ToString(), ref warning_out, ref warning_out_hidden, ref _lastDayOfSchedule); //rd.wu.usr.timeSheetUserInfo.isDelinquentDTKUser;

            e_id = rd.wu.usr.timeSheetUserInfo.employeeid.ToString();
            isDelinquentDTKUser = MBA.Security.BitteTimePeople.isHourVerifyRequired(this.dbConnApp, log, uInfo, e_id, ref warning_out, ref warning_out_hidden, ref _lastDayOfSchedule);



            //System.Web.UI.HtmlControls.HtmlElement divcollg10  = findControlRecu(this.Page, "div-col-lg-10") as HtmlElement;

            if (rd.wu.usr.timeSheetUserInfo.roleID == 2 /* employee role from [TimeKeeper].[dbo].[TimeSystemRole] */ )
            { divcollg10_classes = "col-12 col-lg-12 px-5"; }
            else
            {
                //divcollg10.Attributes.Add("class", "col-12 col-lg-10");
                divcollg10_classes = "col-12 col-lg-10";
                preselected_empid_scrollmenu = true;

                string _sqlStatement = @"[dbo].[TimeKeeper_TIMESHEET_ViewEmployeeList] ()";  //TODO: forgot this was here; this should have been in an entity somewhere

                List<SqlParameter> parms = new List<SqlParameter>();


                MBA.defineCols dc = delegate (ref MBA.SQLStatement ss, ref string pageroworder, ref List<SqlParameter> ppp)
                {
                    pageroworder = "id";
                };

                SqlConnection _con = new SqlConnection(ConfigurationManager.AppSettings["dbConnApp"]);

                _con.Open();

                r_db_1 = MBA.Entities.view(_con, log, uInfo, MBA.Entities.REC_VIEW_ALL, false, "", "", "", _sqlStatement, ref parms, null, dc);

            }




        }
  }
}