using System;
using System.Collections;
using MBA;

namespace Spedmon
{
    public class UserAllStoredFilesManage : WebUI
    {
        public UserAllStoredFilesManage() : base(
                                              "storedfilesmanagepage"
                                            , StoredFiles.SEL_LABEL_MANAGE
                                            , ""
                                            , "stored-files.js"
                                            , Constants.ROLE_ALL_PCAL_AND_CLIENT)
        { }
        public bool   isPCalStaff              = false;
        public bool   isPrac                   = false;
        public string isPcalStaffJSBoolStr     = "";

        protected void Page_Load(object sender, EventArgs e)
        {     
          isPCalStaff = uInfo.pcalStaff;
          if (uInfo.userRoleID == Constants.ROLE_LEA_PROVIDER_ID) isPrac = true;
          isPcalStaffJSBoolStr = Util.netBoolToJSBool(isPCalStaff);
        }
    }
}