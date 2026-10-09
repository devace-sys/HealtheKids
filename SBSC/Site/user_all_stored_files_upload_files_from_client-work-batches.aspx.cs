using System;
using System.Collections;
using MBA;

namespace Spedmon
{
    public class UserAllStoredFilesUploadFilesFromClientWorkBatches : WebUI
    {
        public UserAllStoredFilesUploadFilesFromClientWorkBatches() : base(
                                              "storedfilesuploadfilesfromclientworkbatches"
                                            , StoredFiles.SEL_LABEL_UPLOAD_WORK_BATCHES
                                            , "user_all_stored_files_upload_files_from_client-work-batches.css"
                                            , ""
                                            , Constants.ROLE_ALL_PCAL_AND_CLIENT)
        { }
        public string TYPES_OF_WORK_OPTIONS_HTML = @"";
        public string MIN_OLDEST_DOS         = @"";
        public string MAX_OLDEST_DOS         = @"";

        protected void Page_Load(object sender, EventArgs e)
        {     
       
          TYPES_OF_WORK_OPTIONS_HTML = FileUploads.generateSelectOptionsMarkupForUploadFileTypes(dbConnApp,log,uInfo,"Y","Y","1");
          MIN_OLDEST_DOS             = "2000-01-01";
          MAX_OLDEST_DOS             = DateTime.Today.ToHTML5DateString();

         
          /*var ctrlTypesOfWork = findControlRecu(this.Page, "typeofwork") as MBA.DataEntryBoxSelect;         
          var typesOfWork     = FileUploads.viewUploadFileTypesList(dbConnApp,log,uInfo,"Y","Y","1","");
          
          ctrlTypesOfWork.addSelectOneSelection = true;

          foreach(var typeOfWork in typesOfWork) { 
            ctrlTypesOfWork.addSelection(new NameValue(typeOfWork.fileTypeName, typeOfWork.fileTypeValue,""));
          }
          */

        }
    }
}