<%@ Page Language="C#" CodeBehind="user_all_view_patient_persons.aspx.cs" Inherits="Spedmon.UserAllViewPatientPersons" %>

<%//#######################################################################################################################%>
<%//#                                               Markup %>
<%//#######################################################################################################################%>

<div id="datamanagerows" class="container-fluid">    

  <div class="row">
    
    <div class="col-12">

      <Spedmon:DataEntryBoxSearch
                 ID               = "term"
                 name             = "term"
                 label            = "Search Patient Contacts By Name or Email"
                 fireSpedmonInput = "false"
                 title            = "Enter search term then click search icon"
                 size             = "20"
                 runat            = "server" />

      <Spedmon:DataEntryButton
                 ID="butdosearch"
                 title="Click here to search"
                 iconOnly="true"
                 faIcon="fa fa-search text-success fa-2x"
                 assignBsCssClasses="false"
                 onclick="doSearch()"
                 runat="server"   />

      <Spedmon:DataEntryButton
                 ID="butclearsearchterm"
                 title="Click here to clear search"
                 iconOnly="true"
                 faIcon="fa fa-times-circle text-danger fa-2x"
                 assignBsCssClasses="false"
                 onclick="clearSearchTerm(e)"
                 runat="server" />

    </div> <!-- col -->

    
  </div> <!-- row -->

  <div class="row mt-3">
    <div class="col-12">
      <div id="restview"></div>
    </div> <!-- col -->
  </div> <!-- row  -->
</div> <!-- container -->

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    let $restView = null;

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function doSearch() {
      MBA.PatientPersonsCommon.fnUpdateAdditionalViewParameterValuesAndRequestViewFromServer($restView);
    };

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function clearSearchTerm(e) {
      $('#term').MBA_DataEntryBox('clearValue');      
      doSearch();
    };
  
    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function initPatientPersonsView() {

        let optsObj = {
              PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
            , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
            , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
            , PARM_PERSON_ROLE_ID: '<%=Spedmon.Constants.PARM_PERSON_ROLE_ID%>'
            , PARM_NAME_TERM: '<%=Spedmon.Constants.PARM_SEARCH_TERM%>'
            , containerCtrlID: 'datamanagerows'
            , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlView: '<%=Spedmon.PatientPersons.URL_REST_VIEW_BASE()%>'
            , defaultPageRowOrder: '<%=Spedmon.PatientPerson.DEFAULT_PAGING_ORDER%>'
            , baseUrlAddNew: '<%=Spedmon.PatientPersons.URL_SAVE_INLINE_BASE()%>'
            , baseUrlEdit: '<%=Spedmon.PatientPersons.URL_SAVE_INLINE_BASE()%>'
            , baseUrlDelete: '<%=Spedmon.PatientPersons.URL_DELETE_INLINE_BASE()%>'
            , baseUrlReport: ''
            , defaultReportNumber: '1'
            , autoHidePageControls: false
            , enableScrollView: false
            , scrollViewUseCustomHeight: false
            , scrollViewCustomHeight: '20em'
            , fnOnResponseViewFromServer: function (elem, responseData, $me, dataObj) {
                return;
            }
            , fnCreateNewCellAfter: function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, newCellValueElem, addCellValRefs, addCellValRefsMap) {
                if (fieldDefinition.name === 'patientName') {                    
                  $(newCellValueElem).attr('title', 'Edit Patient Profile');
                  $(newCellValueElem).wrap('<a href="#" class="mba-rest-view-drill-down"></a>');
                  $(newCellValueElem).append($('<i class="fa fa-pencil-alt fa-sm ml-1"></i>'));
                  $(newCellValueElem).closest('a').on('click', function () {
                     let _reqUrl = '<%=urlEditPatient%>' + rowData.patientID;
                     return MBA.ComponentCommon.fnOpenWindow(_reqUrl, null);
                  });
                }
                return newCell; /* as required*/
            }
            , requestViewAfterInit: true
            , viewOnly: true
            , useSearchTermParameter: true
            , useClientIDParameter: false
            , usePatientIDParameter: false
            , isPcalStaff:<%=isPcalStaffJSBoolStr%>
            , currentPage: 1
         };

        $restView = MBA.PatientPersonsCommon.fnSetup('restview', optsObj);
    
        return;
    };

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    $(document).ready(function () {              
        initPatientPersonsView();       
    });

</script>