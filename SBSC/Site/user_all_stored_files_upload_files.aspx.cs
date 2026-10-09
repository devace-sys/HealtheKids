using System;
using System.Collections;
using MBA;

namespace Spedmon
{
    public class UserAllStoredFilesUploadFiles : WebUI
    {
        public UserAllStoredFilesUploadFiles() : base(
                                              "storedfilesuploadfiles"
                                            , "Send Us Files"
                                            , ""
                                            , ""
                                            , Constants.ROLE_ALL_PCAL_AND_CLIENT)
        { }

        public bool showLegacyUploadOption = false;
        protected void Page_Load(object sender, EventArgs e)
        {     
              if (uInfo.pcalStaff == true) showLegacyUploadOption = true;
        }
    }
}