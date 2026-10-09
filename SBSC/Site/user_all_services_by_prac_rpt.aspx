<%@ Page Language="C#" CodeBehind="user_all_services_by_prac_rpt.aspx.cs" Inherits="Spedmon.UserAllServicesByPracRpt" %>

<div id="dataManagementRows" class="container-fluid"> 
    
    <div class="row">
        <div class="col-12">
            <div class="alert alert-info">
            Please Note: For all reports blank cells indicate that the column is Non Applicable.  When viewing the "Minutes" report there may be rows with blanks cells.  Certain assessments are "encounter-based" and will not show minutes, when services were provided. Use the "Number of Services" view to see how many assessments were recorded.
            </div>
        </div>
    </div>

    <div class="row mt-3">
        <div class="col-auto">
            <Spedmon:DataEntryRowSelectClient
                ID              = "selectClient" 
                entityControlID = "clientid"                
                rowLabel        = "Client"
                dataEntryRowRenderAs = "FIELD"
                runat           = "server">
            </Spedmon:DataEntryRowSelectClient>
        </div> <!-- col -->
    
        <div class="col-auto">

            <Spedmon:ComboBox 
                ID            = "rptgroupid" 
                name          = "rptgroupid" 
                title         = "Select Reporting Group"
                displayInline = "true"
                dataPrivate   = "true" 
                dataURL       = "groups.asmx/viewSelRept" 
                dataParms     = "[{id:'clientid'}]" 
                runat         = "server" />
       </div> <!-- col -->
    
        <div class="col-auto">

                       <%-- Fields required for practitioners dropdown --%>
            <Spedmon:HiddenInput ID="patid"                   name="patid"                   title="patid"                   runat="server"></Spedmon:HiddenInput>
            <Spedmon:HiddenInput ID="dos"                     name="dos"                     title="dos"                     runat="server"></Spedmon:HiddenInput>
            <Spedmon:HiddenInput ID="groupserviceclassnameid" name="groupserviceclassnameid" title="groupserviceclassnameid" runat="server"></Spedmon:HiddenInput>
            <Spedmon:HiddenInput ID="pracdatasource"          name="pracdatasource"          title="pracdatasource"          runat="server"></Spedmon:HiddenInput>
            <Spedmon:ComboBox 
                ID            = "pracid" 
                name          = "pracid" 
                title         = "Select Practitioner"
                displayInline = "true"
                dataPrivate   = "true" 
                dataURL       = "practitioners.asmx/viewSel2" 
                dataParms     = "[{id:'clientid'},{id:'patid'},{id:'dos'},{id:'groupserviceclassnameid'},{id:'pracdatasource'}]" 
                runat         = "server" />
                       
         </div> <!-- col -->
          
      </div> <!-- row -->
    
      <div class="row mt-3">

        <div class="col-auto">
          <Spedmon:RadioBox ID="reptnumber" name="reptnumber" title="Report Type" renderLabel="false" additionalCssClassNameForContainer="modern2021" runat="server" />
        </div>
        
        <div class="col-auto">
          <Spedmon:DataEntryBoxDate ID="enddate" name="enddate" title="As of Date" label="As of Date" runat="server" />
        </div>
        
        <div class="col-auto">
           <button type="button" id="downloadXlsBtn" class="btn btn-info mr-2" onclick="downloadServicesByPracRptXls();">Download</button>
        </div>
    </div> <!-- row -->
    
</div> <!-- container -->


<script>

    
    function getNameValueObjects() {
        let reqData = [
            MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_CLIENT_ID%>", $("#<%=Constants.PARM_CLIENT_ID%>").val()),
            MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_RPT_GROUP_ID%>", $("#<%=Constants.PARM_RPT_GROUP_ID%>"   ).val() ),
            MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_PRACTITIONER_ID%>", $("#<%=Constants.PARM_PRACTITIONER_ID%>").val() ),
            MBA.ComponentCommon.fnCreateNameValueObject("<%=Constants.PARM_END_DATE%>", $("#<%=Constants.PARM_END_DATE%>").val())
        ];
        return reqData;
    };

    function downloadServicesByPracRptXls() {
        let $waitingIcon = $('<i class="fa fa-spinner fa-pulse fa-fw m-auto"></i>');
        $waitingIcon.insertAfter('#downloadXlsBtn');

        let reqUrl = '<%=Spedmon.ServicesByPracRpt.URL_ASHX_BASE()%>';
        let rptNum = $("#<%=Constants.PARM_REP_NUMBER%>").val();
        let reqData = getNameValueObjects();
        MBA.ComponentCommon.fnRequestDownloadWebReportDocument(reqUrl, 3, rptNum, 'Services_By_Practitioners_Rpt', reqData
            , function () { $waitingIcon.remove(); }
            , function () { $waitingIcon.remove(); });
    }

    function hideRptGrpSelectionIfValuePreloaded() {
        <%if (rptGrpIsPreloaded) {%>
            $('#rptgroupid_all_cont').hide();
        <%}%>
    }



    $(document).ready(function () {

        hideRptGrpSelectionIfValuePreloaded();

    });
</script>