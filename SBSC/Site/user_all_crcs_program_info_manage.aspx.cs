using System;
using MBA;

namespace Spedmon
{
    public class userAllCRCSProgramInfoManage : WebUI
    {
        public int ParmClientID     { get; set; }
        public int ParmFiscalYearID { get; set; }

        public string providerNameDisplay               = @"";
        public string providerAddress1Display           = @"";
        public string providerAddress2Display           = @"";
        public string providerCityDisplay               = @"";
        public string providerStateZipDisplay           = @"";
        public string providerNPIDisplay                = @"";
        public string providerCDSDisplay                = @"";
        public string oneWayTripsMedicalStudentsDisplay = @"";
        public string oneWayTripsAllStudentsDisplay     = @"";
        public userAllCRCSProgramInfoManage() : base(""
                                            , ""
                                            , "user_all_crcs_program_info_manage.css"
                                            , ""
                                            , Constants.ROLE_CRCS_ADMIN)
        { }
        protected void Page_Load(object sender, EventArgs e)
        {

            var ctrlSaveOrEdit      = findControlRecu(this.Page, "saveOrEdit")       as DataEntryRowSaveOrEdit; 
            var ctrlClientID        = findControlRecu(this.Page, "selectClient")     as MBA.DataEntryRowSelectClient;
            var ctrlFYID            = findControlRecu(this.Page, "selectFiscalYear") as MBA.DataEntryRowSelectFiscalYear;

            var ctrlProviderPhone   = findControlRecu(this.Page, "providerphone")    as MBA.DataEntryBoxPhone;
            var ctrlProviderFax     = findControlRecu(this.Page, "providerfax")      as MBA.DataEntryBoxPhone;
            var ctrlSmaa            = findControlRecu(this.Page, "smaa")             as MBA.SelectYesOrNo;

            var ctrlIndirectcostrate                = findControlRecu(this.Page, "indirectcostrate")                as MBA.DataEntryBoxText;
            var ctrlStudentcensuspopulation         = findControlRecu(this.Page, "studentcensuspopulation")         as MBA.DataEntryBoxNumber;
            var ctrlMedicaleligiblestudents         = findControlRecu(this.Page, "medicaleligiblestudents")         as MBA.DataEntryBoxNumber;
            var ctrlMer                             = findControlRecu(this.Page, "mer")                             as MBA.DataEntryBoxText;
            var ctrlFmaptitlexix                    = findControlRecu(this.Page, "fmaptitlexix")                    as MBA.DataEntryBoxText;
            var ctrlFmaptitlexixenhanced            = findControlRecu(this.Page, "fmaptitlexixenhanced")            as MBA.DataEntryBoxText;
            var ctrlFmaptitlexxi                    = findControlRecu(this.Page, "fmaptitlexxi")                    as MBA.DataEntryBoxText;
            var ctrlFmaptitlexxienhanced            = findControlRecu(this.Page, "fmaptitlexxienhanced")            as MBA.DataEntryBoxText;
            var ctrlRmtscode2apercentage            = findControlRecu(this.Page, "rmtscode2apercentage")            as MBA.DataEntryBoxText;
            var ctrlSelectContactName               = findControlRecu(this.Page, "selectContactName")               as MBA.DataEntryRowSelectClientContact;
            var ctrlContacttitle                    = findControlRecu(this.Page, "contacttitle")                    as MBA.DataEntryBoxText;
            var ctrlContactemail                    = findControlRecu(this.Page, "contactemail")                    as MBA.DataEntryBoxEmail;
            var ctrlPracswithzeroreimbursementcosts = findControlRecu(this.Page, "pracswithzeroreimbursementcosts") as MBA.SelectYesOrNo;
            var ctrlSelectCrcsBusinessOfficial      = findControlRecu(this.Page, "selectCrcsBusinessOfficial")      as MBA.DataEntryRowSelectClientContact;
            var ctrlCrcsbusinessofficialtitle       = findControlRecu(this.Page, "crcsbusinessofficialtitle")       as MBA.DataEntryBoxText;
            var ctrlLeabopconsortium                = findControlRecu(this.Page, "leabopconsortium")                as MBA.DataGrid;
            var ctrlContactinfoverified             = findControlRecu(this.Page, "contactinfoverified")             as MBA.CheckBox;
            var ctrlPersonsigninginfoverified       = findControlRecu(this.Page, "personsigninginfoverified")       as MBA.CheckBox;
            var ctrlConsortiumbillinginfoverified   = findControlRecu(this.Page, "consortiumbillinginfoverified")   as MBA.CheckBox;
            var ctrlPrograminfoverified             = findControlRecu(this.Page, "programinfoverified")             as MBA.CheckBox;
            var ctrlSelectLecOrLga                  = findControlRecu(this.Page, "selectLecOrLga")                  as MBA.DataEntryRowSelectLecOrLga;


            string clientIDStr = MBA.HttpApplication.getParameter(Constants.PARM_CLIENT_ID)
                 , fiscalYearIDStr = MBA.HttpApplication.getParameter(Constants.PARM_FISCAL_YEAR_ID);

            ParmClientID = int.Parse(clientIDStr);
            ParmFiscalYearID = int.Parse(fiscalYearIDStr);

            // if values provided, hide controls
            if (ParmClientID != 0)
            {
                ctrlClientID.selectValue = ParmClientID.ToString();
                ctrlClientID.entryInitiallyHidden = true;
                ctrlClientID.entryAllowed = false;
            }

            if (ParmFiscalYearID != 0)
            {
                ctrlFYID.selectValue = ParmFiscalYearID.ToString();
                ctrlFYID.entryInitiallyHidden = true;
                ctrlFYID.entryAllowed = false;
            }

            // preload client data
            Client c = Clients.load(dbConnApp, log, uInfo, clientIDStr);
            providerNameDisplay     = c.name;
            providerAddress1Display = c.address1;
            providerAddress2Display = c.address2;
            providerCityDisplay     = c.city;
            providerStateZipDisplay = c.state + ", " + c.zip;
            providerNPIDisplay      = c.NPI;
            providerCDSDisplay      = c.CDS;
            ctrlProviderPhone.value = c.contactPhone;
            ctrlProviderFax.value   = c.contactFax;
            ctrlSmaa.value          = Util.boolToYesNo(c.MAA);

            // preload service record data
            ReturnCrcsProgramInfoOneWayTrips onewayTrips = CrcsProgramInfo.getNumOneWayTrips(dbConnApp, log, uInfo, clientIDStr, fiscalYearIDStr);
            oneWayTripsMedicalStudentsDisplay = onewayTrips.crcsProgramInfoOneWayTrips.mcalPats.ToString();
            oneWayTripsAllStudentsDisplay     = onewayTrips.crcsProgramInfoOneWayTrips.allPats.ToString();

            // load the rest of the data based on the passed in client and fiscal year
            // Note: recid and savetype are not passed, so we determine those values
            //  based on if a record exists in the database

            try
            {
                CrcsProgramInfoRec p = CrcsProgramInfo.load(dbConnApp, log, uInfo, clientIDStr, fiscalYearIDStr);

                // set saveType and recID
                ctrlSaveOrEdit.saveType                    = 2;
                ctrlSaveOrEdit.recID                       = p.id.ToString();

                ctrlIndirectcostrate.value                 = p.indirectCostRate.ToString();
                ctrlStudentcensuspopulation.value          = p.studentCensusPopulation;
                ctrlMedicaleligiblestudents.value          = p.mediCalEligibleStudents;
                ctrlMer.value                              = p.MER.ToString();
                ctrlFmaptitlexix.value                     = p.fmapTitleXIX;
                ctrlFmaptitlexixenhanced.value             = p.fmapTitleXIXEnhanced;
                ctrlFmaptitlexxi.value                     = p.fmapTitleXXI;
                ctrlFmaptitlexxienhanced.value             = p.fmapTitleXXIEnhanced;
                ctrlRmtscode2apercentage.value             = p.rmtsCode2APercentage.ToString();
                ctrlSelectContactName.selectValue          = p.contactID.ToString();
                ctrlSelectContactName.selectName           = p.contactName;
                ctrlContacttitle.value                     = p.contactTitle;
                ctrlContactemail.value                     = p.contactEmail;
                ctrlPracswithzeroreimbursementcosts.value  = Util.boolToYesNo(p.pracsWithZeroReimbursementCosts);
                ctrlSelectCrcsBusinessOfficial.selectValue = p.crcsBusinessOfficialID.ToString();
                ctrlSelectCrcsBusinessOfficial.selectName  = p.crcsBusinessOfficialName;
                ctrlCrcsbusinessofficialtitle.value        = p.crcsBusinessOfficialTitle;
                ctrlLeabopconsortium.singleQuoteValueAttribute = true;
                ctrlLeabopconsortium.value                 = p.leaBOPConsortium;
                ctrlContactinfoverified.value              = p.contactInfoVerified;
                ctrlPersonsigninginfoverified.value        = p.personSigningInfoVerified;
                ctrlConsortiumbillinginfoverified.value    = p.consortiumBillingInfoVerified;
                ctrlPrograminfoverified.value              = p.programInfoVerified;
                ctrlSelectLecOrLga.selectValue             = p.lecOrLgaID.ToString();
                ctrlSelectLecOrLga.selectName              = p.lecOrLgaName.ToString();

            }
            catch {
            }
        }
    }
}