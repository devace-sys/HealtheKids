/* Requires jquery, mba-action-dialogs */

var MBA = (MBA || {});

MBA.storedFile = (function ($) {

'use strict';

    
  /***************************************************************************
   * _upload*/
  /**
   * 
   * 
   ***************************************************************************/

  var _upload = function (storedFileUploadUrlAndValidationParms, dialogTitle, acceptTypes, fnOnStart, fnOnCancel, fnOnDone, fnOnFail, fileClass, fileSubClass, fileAdditionalData, fileNameSpace, fileSource)
  {

      /*============================================================
       * Set defaults
       *============================================================*/

      if (!dialogTitle)        dialogTitle        = 'Select a File to Upload';
      if (!acceptTypes)        acceptTypes        = '';
      if (!fnOnStart)          fnOnStart          = function () { };
      if (!fnOnCancel)         fnOnCancel         = function () { };
      if (!fnOnDone)           fnOnDone           = function () { };
      if (!fnOnFail)           fnOnFail           = function () { };
      if (!fileClass)          fileClass          = '';
      if (!fileSubClass)       fileSubClass       = '';
      if (!fileAdditionalData) fileAdditionalData = '{}';
      if (!fileNameSpace)      fileNameSpace      = '';
      if (!fileSource)         fileSource         = '';

      /*============================================================
       * Create unique one time ids for the caller of this method
       *============================================================*/

      let _uploadDiaID           = MBA.util.createNewUUID();
      let _uploadFrmID           = MBA.util.createNewUUID();
      let _uploadFrmSelector     = '#' + _uploadFrmID;
      let _uploadInpFileID       = MBA.util.createNewUUID();
      let _uploadInpFileSelector = '#' + _uploadInpFileID;

      let _uploadFrmData;

      /*============================================================
       * Create our dialog buttons
       *============================================================*/

      let _diaButtons = [
          { text: 'Cancel', click: function () { 
              fnOnCancel();
              MBA.responsizeDialog.close(_uploadDiaID);
          }
          }
        
          , { text: 'Upload File', click: function () {

            /* Test for no files selected.  If none exit. */

            let _numUploads = $(_uploadInpFileSelector)[0].files.length;
            if (_numUploads != 1) return;

            fnOnStart();

             /* Extract form data */

            _uploadFrmData = new FormData($(_uploadFrmSelector)[0]);

            /* Close dialog */

            MBA.responsizeDialog.close(_uploadDiaID);  

            /* Upload */

            $.ajax({
                  url: storedFileUploadUrlAndValidationParms
                  , type: 'POST'
                  , data: _uploadFrmData
                  , processData: false
                  , contentType: false
            }).done(function (rd) {
                fnOnDone(rd);
            }).fail(function () {
                  fnOnFail();
            }).always(function () {
              MBA.responsizeDialog.close(_uploadDiaID);
            });
            
          }
          }
      ];

     /*============================================================
      * Create a form to collect the data
      *============================================================*/

      let _content = '<form id="' + _uploadFrmID + '" enctype="multipart/form-data">'             
         + '<input id= "' + _uploadInpFileID + '" class="stored-file-upload" type="file" accept="' + acceptTypes +'" name="file" required/>'
         + '<input name="filedesc" type="text" class="stored-file-upload" placeholder="Enter an optional description of this file"/>'
         + '<br>'
         + '<p class="stored-file-upload-processing-notice">Please note that all uploads are automatically scanned for viruses and other threats prior to being released for use.</p>'
         + '<p class="stored-file-upload-processing-notice">If threats are detected the file will be deleted from our servers and the user who uploaded the file will be notified via email.</p>'
         + '<input name="fileclass" type="hidden" value="' + fileClass + '"/>'
         + '<input name="filesubclass" type="hidden" value="' + fileSubClass + '"/>'
         + '<input name="fileadditionaldata" type="hidden" value="' + fileAdditionalData + '"/>'
         + '<input name="filenamespace" type="hidden" value="' + fileNameSpace + '"/>'
         + '<input name="filesource" type="hidden" value="' + fileSource + '"/>'        
         + '</form>';

     /*============================================================
      * Open dialog
      *============================================================*/

      MBA.responsizeDialog.createNew (
            _uploadDiaID
            , dialogTitle
            , _content
            , 50
            , 50
            , 1
            , 0
            , 1
            , null
            , null
            , null
            , _diaButtons);
};
 
return {
    upload: _upload
};

})(jQuery);
