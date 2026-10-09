<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="sbs_all_manage_sped_document_templates.aspx.cs" Inherits="Spedmon.SBSAllManageSpedDocumentTemplates" %>

<%//##################################################################################################################%>
<%//#                                         Data Management Rows   %>
<%//##################################################################################################################%>

<div class="container-fluid">

  <%//-----------------------------------------------------------------------------%>
  <%// Rest View %>
  <%//-----------------------------------------------------------------------------%>

  <div id="restViewContainerRow" class="row mt-3">
    <div class="col-12">
      <div id="restView"></div>
    </div> <!--col -->
  </div> <!--row -->

</div> <!-- container -->


<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    const DATA_ATTR_FORM_BUILDER_CTRL_NAME          = 'data-form-builder-ctrl-name';
    const DATA_ATTR_FORM_BUILDER_CTRL_NAME_OPEN_DIA = 'opendia';

    let $restViewCtrl       = null;

    function doPreviewTemplate (uiActionObj) {

        let urlViewPreview = '<%=Spedmon.SpEdDocumentTemplates.URL_SPED_DOCUMENT_OUTPUT(Spedmon.SpEdDocumentTemplates.SPED_DOCUMENT_DATA_SOURCE_DOCUMENT_TEMPLATE,@"")%>'
                           + uiActionObj.recordID;

        let windowOptionsObjViewPreviewTemplate = {};
        windowOptionsObjViewPreviewTemplate.url = urlViewPreview;
        windowOptionsObjViewPreviewTemplate.windowName = 'viewtemplatepreview' + uiActionObj.recordID;
        windowOptionsObjViewPreviewTemplate.refreshView = false;
        $($restViewCtrl).MBA_RestView('openWindow', windowOptionsObjViewPreviewTemplate);
        return uiActionObj;

    };

    function doManageFormData(taElement, readOnly) {        
        if (readOnly) {
            spedmonRenderFormFromJSON($(taElement), null, false, true);
        } else {
            spedmonRenderFormBuilderBox($(taElement));
        }
    };

    function initView() {

        let opts = {};
        opts.sessionTimeOutUrl         = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad         = true; 
        opts.enableSortControls        = true;
        opts.enableRowNumbers          = true;
        opts.enableRowControls         = true;
        opts.enableRowControlRecAddNew = true;
        opts.enableRowControlRecEdit   = true;
        opts.enableRowControlRecDelete = true;

        opts.saveModeAddNew             = 'inline';
        opts.baseUrlAddNew              = '<%=Spedmon.SpEdDocumentTemplates.URL_SAVE_INLINE()%>'; 
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit               = 'inline';
        opts.baseUrlEdit                = '<%=Spedmon.SpEdDocumentTemplates.URL_SAVE_INLINE()%>';
        opts.baseUrlEditHasParameters   = true;

        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = '<%=Spedmon.SpEdDocumentTemplates.URL_DELETE_INLINE()%>';
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView             = 'rest';
        opts.baseUrlView              = '<%=Spedmon.SpEdDocumentTemplates.URL_REST_VIEW()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder      = '<%=Spedmon.SpEdDocumentTemplate.DEFAULT_PAGING_ORDER%>';

        opts.enableReports = false;

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });

        let clientIDFieldOptions = {};
        let clientNvps = <%=clientNvpString%>;
        clientIDFieldOptions.selections = clientNvps;

        opts.fieldDefinitions.push({
            name: 'clientID'
            , label: 'Client'
            , toolTip: 'Associated client'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'selectoption'
            , dataTypeOptions: clientIDFieldOptions
            , sortUsing: 'clientName'
            , saveUsing: 'clientid'
            , showMore: false
        });

        opts.fieldDefinitions.push({
              name: 'name'
            , label: 'Document<br>Name'
            , toolTip: 'Document Name'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'name'
            , sortUsing: 'name'
        });

        opts.fieldDefinitions.push({
            name: 'description'
            , label: 'Document<br>Description'
            , toolTip: 'Description'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'text'
            , saveUsing: 'description'
            , sortUsing: 'description'
        });

        opts.fieldDefinitions.push({
            name: 'display'
            , label: 'OK To<br>Display?'
            , toolTip: 'Is is OK for users to use this document template?'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: true
            , isRecID: false
            , dataType: 'yesno'
            , saveUsing: 'display'
            , sortUsing: 'display'
        });
        
        opts.fieldDefinitions.push({
            name: 'formBuilderContentJSON'
            , label: 'Compose<br>Content'
            , toolTip: ''
            , visible: true
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'jsondata'
            , dataTypeOptions: {}
            , sortUsing: ''
            , saveUsing: 'formBuilderContentJSON'
            , showMore: false
        });

        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

        opts.additionalControlDefinitionsForBodyRows.set('viewDocumentTemplatePreview', {
            defType: 'userprovided'
            , name: 'viewDocumentTemplatePreview'
            , toolTip: 'Click here to view a preview'
            , cssClass: 'fas fa-file-pdf'
            , handlerFn: function (uiActionObj) {
                return doPreviewTemplate(uiActionObj);                
            }
            , initiallyHidden: false
        });

        /* Inject code to add form builder button */

        opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, newCellValueElem) {

            /* We are searching for a particular cell to enhance */

            if (fieldDefinition.name === 'formBuilderContentJSON') {

                let $butManageFormData = $('<button type="button"></button>');
                let $iconManageFormData1 = $('<i class="mba-rest-view fa fa-book"></i>');
                $($butManageFormData).append($iconManageFormData1);

                /* Use same class as the row controls */

                $($butManageFormData).addClass(MBA.RestViewCommon.CONST_CSS_CLASSES.ctrlButton);

                /* Add custom attribute so a generic handler set on the tbody can uniqely identify */

                $($butManageFormData).attr(DATA_ATTR_FORM_BUILDER_CTRL_NAME, DATA_ATTR_FORM_BUILDER_CTRL_NAME_OPEN_DIA);

                /* Add in required attributes to tie into edit row control mechanisms */

                $($butManageFormData).attr(MBA.RestViewCommon.ATTR_NAME_FIELD_EDIT_STATE, MBA.RestViewCommon.ATTR_VALUE_EDIT_STATE_LOCKED);
                $($butManageFormData).attr('disabled', '');
                $($butManageFormData).on('click', function (e) {
                    doManageFormData(newCellValueElem, false);
                });
                newCell.append($butManageFormData);

                let fbc = $(newCellValueElem).val();
                if (!fbc) $(newCellValueElem).val('{}');

            }

            /* Return cell new as required */

            return newCell;
        }

        /* Create the rest view */

        $($restViewCtrl).MBA_RestView(opts);

    };

    $(document).ready(function () {
        $restViewCtrl = $('#restView');
        initView();                
    });

</script>

