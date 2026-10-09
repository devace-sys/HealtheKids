using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MBA;
using System.Web.Script.Serialization;

namespace Spedmon
{
    /***************************************************************************
     * UserAllPractitionerPatientGroupSave */
    /**
     *
 	 ***************************************************************************/

    public class UserAllPractitionerPatientGroupSave : WebUI
    {
        public int saveType = Constants.SAVE_TYPE_NEW;
        public bool clientAndPracAreOK = true;
        public DateTime today = DateTime.Now;
        public bool showSvcsForLeaBop = true;
        public bool showSvcsForLeaBopNonSpEd = true;
        public bool showSvcsForCYBHI = true;
        public bool showSvcsForRUHealth = true;

        public UserAllPractitionerPatientGroupSave() : base(
                                                       @"user_all_practitioner_patient_group_save"
                                                     , PractitionerPatientGroups.SEL_LABEL_ADD_NEW
                                                     , @""
                                                     , @""
                                                     , Constants.ROLE_ALL_PCAL_AND_CLIENT)
        { }

        

        protected void Page_Load(object sender, EventArgs e)
        {
            this.renderOptionContentOnly = true;

            /*###########################################################################
              # Fetch parameters 
              ###########################################################################*/

            string savetype = MBA.HttpApplication.getParameter(Constants.PARM_SAVE_TYPE);
            string recid = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
            string clientid = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID);
            string pracid = MBA.HttpApplication.getParameter(Constants.PARM_PRACTITIONER_ID);
            string patidsjson = MBA.HttpApplication.getParameter("patIdsJSON");
           

            /*###########################################################################
              # Determine save type
              ###########################################################################*/

            Object vSaveType = Spedmon.Validate.optInteger(savetype, Messages.INVALID_SAVE_TYPE);
            saveType = Constants.SAVE_TYPE_NEW;
            if (vSaveType == null) vSaveType = Constants.SAVE_TYPE_NEW;
            saveType = (int)vSaveType;

            clientAndPracAreOK = true;
            try
            {
                int vClientID = Spedmon.Validate.reqClientID(uInfo, clientid);
                int vPracID = Spedmon.Validate.reqPracID(uInfo, pracid);
                
                clientid = vClientID.ToString();
                pracid = vPracID.ToString();
            }
            catch
            {
                clientAndPracAreOK = false;
            }

            if (clientAndPracAreOK == false) return;

            /*###########################################################################
              # Get references to data entry controls 
              ###########################################################################*/
            
            var ctrlSelectPlanType = findControlRecu(this.Page, Constants.PARM_SVC_NAMES_LIST_DATA_SOURCE_ID) as MBA.DataEntryBoxSelect;

            var ctrlClientID = findControlRecu(this.Page, Constants.PARM_CLIENT_ID) as MBA.HiddenInput;
            var ctrlPracID = findControlRecu(this.Page, Constants.PARM_PRACTITIONER_ID) as MBA.HiddenInput;
            var ctrlPatientID = findControlRecu(this.Page, Constants.PARM_PATIENT_ID) as MBA.HiddenInput;
            var ctrlSelectRecurring = findControlRecu(this.Page, "recurring") as MBA.HiddenInput;
            var ctrlgroupName = findControlRecu(this.Page, Constants.PARM_GROUP_NAME) as MBA.DataEntryBoxText;
            var ctrlSelectViaTeleHealth = findControlRecu(this.Page, "viatelehealth") as MBA.SelectYesOrNo;
            var ctrlSelectService = findControlRecu(this.Page, "nameid") as MBA.DataEntryBoxSelect;
            var ctrlAltModNameID = findControlRecu(this.Page, "altmodalitynameid") as MBA.HiddenInput;
            var ctrlStartDate = findControlRecu(this.Page, "startdate") as MBA.DataEntryBoxDate;
            var ctrlDos = findControlRecu(this.Page, "dos") as MBA.HiddenInput;
            var ctrlEndDate = findControlRecu(this.Page, "enddate") as MBA.DataEntryBoxDate;
            var ctrlNumMins = findControlRecu(this.Page, "nummins") as MBA.DataEntryBoxNumber;
            var ctrlMon = findControlRecu(this.Page, "mon") as MBA.CheckBox;
            var ctrlTue = findControlRecu(this.Page, "tue") as MBA.CheckBox;
            var ctrlWed = findControlRecu(this.Page, "wed") as MBA.CheckBox;
            var ctrlThu = findControlRecu(this.Page, "thu") as MBA.CheckBox;
            var ctrlFri = findControlRecu(this.Page, "fri") as MBA.CheckBox;

            var ctrlMonStartTime = findControlRecu(this.Page, "monstarttime") as MBA.DataEntryBoxTime;
            var ctrlTueStartTime = findControlRecu(this.Page, "tuestarttime") as MBA.DataEntryBoxTime;
            var ctrlWedStartTime = findControlRecu(this.Page, "wedstarttime") as MBA.DataEntryBoxTime;
            var ctrlThuStartTime = findControlRecu(this.Page, "thustarttime") as MBA.DataEntryBoxTime;
            var ctrlFriStartTime = findControlRecu(this.Page, "fristarttime") as MBA.DataEntryBoxTime;
            var ctrlNotes = findControlRecu(this.Page, "notes") as MBA.DataEntryBoxTextArea;
            var ctrlSaveType = findControlRecu(this.Page, Constants.PARM_SAVE_TYPE) as MBA.HiddenInput;
            var ctrlRecId = findControlRecu(this.Page, Constants.PARM_REC_ID) as MBA.HiddenInput;

            //var ctrlSelectService2 = findControlRecu(this.Page, "nameid") as MBA.DataEntryRowSelectService;
            /*###########################################################################
              # Load practitioner data
              ###########################################################################*/

            var prac = Practitioners.load(dbConnApp, log, uInfo, pracid);
            showSvcsForLeaBop = prac.participatesInLEABOP;
            showSvcsForLeaBopNonSpEd = prac.participatesInLEABOPNonSpEd;
            showSvcsForCYBHI = prac.participatesInCYBHI;
            showSvcsForRUHealth = prac.participatesInRUHealth;

            /*###########################################################################
              # Get service name list data sources prac can pick from
              ###########################################################################*/

            var svcNameDataSources = Services.viewListOfSvcNameListDataSources(
                  showSvcsForLeaBop
                , showSvcsForLeaBopNonSpEd
                , showSvcsForCYBHI
                , showSvcsForRUHealth);

            /*###########################################################################
              # Add options for plan type using the service name list data sources
              ###########################################################################*/
            ctrlSelectService.addSelectOneSelection = true;
            ctrlSelectPlanType.addSelectOneSelection = true;

            foreach (var svcNameDataSource in svcNameDataSources)
            {
                var newSelection = svcNameDataSource;
                newSelection.typename = @"";
                ctrlSelectPlanType.addSelection(newSelection);
            }
            /*###########################################################################
              # Set recid and save type
              ###########################################################################*/

            ctrlRecId.value = recid;
            ctrlSaveType.value = saveType.ToString();

            /*###########################################################################
              # Set passed in values for client and practitioner 
              ###########################################################################*/

            ctrlClientID.value = clientid;
            ctrlPracID.value = pracid;
            
            /*###########################################################################
              # Set date of service
              ###########################################################################*/

            ctrlDos.value = DateTime.Now.ToShortDateString();

            /*###########################################################################
              # Patient validation
              ###########################################################################*/
            
            if (!string.IsNullOrEmpty(patidsjson))
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                List<Dictionary<string, object>> rawList = js.Deserialize<List<Dictionary<string, object>>>(patidsjson);
                List<Dictionary<string, object>> validList = new List<Dictionary<string, object>>();

                foreach (var item in rawList)
                {
                    if (item.ContainsKey("patID") && item["patID"] != null)
                    {
                        string patID = item["patID"].ToString();
                        string id = item["id"].ToString();
                        var vPatID = Spedmon.Validate.optPatID(uInfo, patID);

                        if (vPatID != null)
                        {
                            validList.Add(new Dictionary<string, object>
                                {
                                    { "patID", long.Parse(vPatID.ToString()) },
                                    { "id", long.Parse(id.ToString()) }
                                });
                        }
                    }
                }
                ctrlPatientID.value = js.Serialize(validList);
            }
            else
            {
                ctrlPatientID.value = patidsjson;
            }


            if (saveType == Constants.SAVE_TYPE_NEW)
            {
                /*------------------------------------*/
                /* Preset other fields                */
                /*------------------------------------*/

                ctrlSelectRecurring.value = "true";
                ctrlSelectViaTeleHealth.setValue(false);

                ctrlMon.value = false;
                ctrlTue.value = false;
                ctrlWed.value = false;
                ctrlThu.value = false;
                ctrlFri.value = false;

                ctrlStartDate.value = today;
                ctrlEndDate.setValue("");
                ctrlNotes.value = "";

            }
            else if (saveType == Constants.SAVE_TYPE_EDIT)
            {
                /*------------------------------------*/
                /* Change page title                  */
                /*------------------------------------*/

                this.subTitle = PractitionerPatientGroups.SEL_LABEL_EDIT;

                /*------------------------------------*/
                /* Load previously saved record       */
                /*------------------------------------*/

                var rec = PractitionerPatientGroups.load(dbConnApp, log, uInfo, clientid, pracid, recid);

                
                try
                { 
                  var svcName = Services.viewSelTmtTcmTrans(dbConnApp, log, uInfo, clientid, pracid, rec.svcNamesListDataSourceID.ToString(), rec.startDate.ToShortDateString(), "");
                  foreach(var svc in svcName.SelRecs)
                  {                    
                    ctrlSelectService.addSelection(new NameValue(svc.label, svc.recData4));
                    if (svc.recData4 == rec.nameID.ToString())
                    {                        
                        ctrlSelectService.value = svc.recData4;
                        ctrlSelectService.name = svc.label;
                    }
                  }
                } 
                catch (Exception svcNameEx)
                {

                }

                /*------------------------------------*/
                /* Set values                         */
                /*------------------------------------*/
                
                ctrlgroupName.value = rec.groupName;
                ctrlClientID.value = rec.clientID.ToString();
                ctrlPracID.value = rec.pracID.ToString();

                ctrlSelectPlanType.value = rec.svcNamesListDataSourceID.ToString();
                ctrlSelectRecurring.value = rec.recurringYN;
                ctrlSelectViaTeleHealth.setValue(rec.viaTeleHealth);

                
                
                ctrlAltModNameID.value = rec.altModalityNameID.ToString();

                ctrlStartDate.value = rec.startDate;
                ctrlEndDate.setValue(rec.endDateYMD);
                ctrlNumMins.value = rec.numMins;
                ctrlNotes.value = rec.notes;

                ctrlMon.value = rec.mon;
                ctrlTue.value = rec.tue;
                ctrlWed.value = rec.wed;
                ctrlThu.value = rec.thu;
                ctrlFri.value = rec.fri;

                ctrlMonStartTime.setValue(rec.monStartTimeHMS);
                ctrlTueStartTime.setValue(rec.tueStartTimeHMS);
                ctrlWedStartTime.setValue(rec.wedStartTimeHMS);
                ctrlThuStartTime.setValue(rec.thuStartTimeHMS);
                ctrlFriStartTime.setValue(rec.friStartTimeHMS);
            }
            else
            {

            }
        }


    }
}