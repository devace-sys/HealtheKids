<%@ Page Language="C#" CodeBehind="user_all_pat_promised_services_save.aspx.cs" Inherits="Spedmon.UserAllPatientPromisedServicesSave" %>
 
 
<Spedmon:DataEntryRows ID="save" useBootstrapFluid="true" runat="server" dataURL="PatientPromisedServices.asmx/save" >
 
    <%/************************************* Patient Name **********************************/%>

    <div class="d-flex justify-content-center mb-3">
        <div class="font-weight-bold">
            <%=patNameDisplay%>
        </div>
    </div>
 
    <Spedmon:HiddenInput ID="patid" name="patid" title="pat id" runat="server"/>

    <div class="row mt-2"> <%-- row --%>
        
        <%/************************************* Service **********************************/%>

        <div class="col-12 col-md-4 col-xl-3">

          <label>Service</label>
          <br />
          <Spedmon:ComboBox 
             ID          = "spedservicecode" 
	         name        = "spedservicecode" 	
	         title       = "Service" 
	         dataPrivate = "true" 
	         dataURL     = "sped_services.asmx/viewSel"                       
	         runat       = "server" />      
        
        </div>
    
       <%/************************************* Provider **********************************/%>

        <div class="col-12 col-md-4 col-xl-3">
    
          <label>Provider</label>
          <br />
          <Spedmon:ComboBox 
              ID          = "spedprovidercode" 
	          name        = "spedprovidercode" 	
	          title       = "Provider" 
	          dataPrivate = "true" 
	          dataURL     = "sped_service_providers.asmx/viewSel" 
	          runat       = "server" />
       
        </div>
    
        <%/************************************* Location **********************************/%>

        <div class="col-12 col-md-4 col-xl-3">
    
          <label>Location</label>
          <br />
          <Spedmon:ComboBox 
              ID          = "spedlocationcode" 
	          name        = "spedlocationcode" 	
	          title       = "Location" 
	          dataPrivate = "true" 
	          dataURL     = "sped_service_locations.asmx/viewSel"                             
	          runat       = "server" />
    
        </div>

        
    
    </div> <%-- end of row --%>

    <div class="row mt-2"> <%-- row --%>
    
       <%/************************************* Start Date **********************************/%>

       <div class="col-12 col-md-4 col-xl-3">
         <label>Start Date</label>
         <br />
         <Spedmon:DateBoxHTML5 ID="startdate" name="startdate" title="Select or Enter Start Date" runat="server" />
  
       </div>
    
        <%/************************************* End Date **********************************/%>
 
        <div class="col-12 col-md-4 col-xl-3">
    
          <label>End Date</label>
          <br />
          <Spedmon:DateBoxHTML5 ID="enddate" name="enddate" title="Select or Enter End Date" runat="server" />
        
        </div>
        
        <%/************************************* Frequency **********************************/%>

        <div class="col-12 col-md-4 col-xl-3">
          <label>Frequency</label>
          <br />
          <Spedmon:ComboBox 
              ID          = "spedfreqcode" 
	          name        = "spedfreqcode" 	
	          title       = "Frequency" 
	          dataPrivate = "true" 
	          dataURL     = "sped_service_frequencies.asmx/viewSel" 
	          runat       = "server" />
        </div>
        
        <%/************************************* Total Minutes / Frequency **********************************/%>

        <div class="col-12 col-md-4 col-xl-3"> 
          <label>Duration</label>
          <br/>
          <Spedmon:TextBox ID="minsperfreq" name="minsperfreq" title="Duration" maxlen="50" showOK="false" runat="server" />
        </div>

    </div> <%-- end of row --%>

    <div class="row mt-2"> <%-- row --%>
    
       <%/************************************* Individual and/Or Group Delivery **********************************/%>

        <div class="col-12 col-md-6 col-xl-6">
          <Spedmon:SelectYesOrNo ID="individualdelivery" name="individualdelivery" title="Individual Delivery" renderLabel="true" runat="server" />
        </div>    
        <div class="col-12 col-md-6 col-xl-6">
          <Spedmon:SelectYesOrNo ID="groupdelivery" name="groupdelivery" title="Group Delivery" renderLabel="true" runat="server" />    
        </div>     

    </div> <%-- end of row --%>

    <%/************************************* Replacement Data Fields **********************************/%>
    
   <div id="replacementdatafields" class="row mt-5"> 
       
        <div class="col-auto">
          <Spedmon:SelectYesOrNo ID="replacementdataactive" name="replacementdataactive" title="Use Replacement Data" renderLabel="true" runat="server" />
        </div>

        <div class="col-auto">
            
          <label>Replacement Service</label>
          <br />
          <Spedmon:ComboBox 
             ID          = "replacementspedservicecode" 
	         name        = "replacementspedservicecode" 	
	         title       = "Service" 
	         dataPrivate = "true" 
	         dataURL     = "sped_services.asmx/viewSel"                       
	         runat       = "server" />      
        
        </div> <!-- col -->
        
       <div class="col-auto">
          <label>Replacement Frequency</label>
          <br />
          <Spedmon:ComboBox 
              ID          = "replacementspedfreqcode" 
	          name        = "replacementspedfreqcode" 	
	          title       = "Frequency" 
	          dataPrivate = "true" 
	          dataURL     = "sped_service_frequencies.asmx/viewSel" 
	          runat       = "server" />
        </div> <!-- col -->

        <div class="col-auto"> 
          <label>Replacement Duration</label>
          <br/>
          <Spedmon:TextBox ID="replacementminsperfreq" name="replacementminsperfreq" title="Duration" maxlen="50" showOK="false" runat="server" />
        </div>
    
   </div> <!-- row -->

   <div class="row mt-1 mb-1"> 
     <div class="col-12">
     <%if(hasSvcLinesDetails == true){%>
     <label>Additional Info</label>
     <br />
     <%}%>
     <div id="svcLinesDetails">
     </div> <!-- details -->
     </div> <!-- col -->
   </div> <!-- row -->

    <Spedmon:DataEntryRowSaveOrEdit 
        ID                               = "saveOrEdit"
        includeSaveAndProceedButton      = "true"
        editDelManageLink                = ""
        runat                            = "server">
 
    </Spedmon:DataEntryRowSaveOrEdit>
     
</Spedmon:DataEntryRows>

<script>
    $(document).ready(function () {
        <%if(showReplacementFields == false){%>
          $('#replacementdatafields').hide();
        <%}%>
        <%if(hasSvcLinesDetails == true){%>
        let svcDetailsObj = $.spedmonWebUI.generatePromisedServiceDetailsHTML('Yes', '<%=svcLinesDetailsJSON%>', true, false);
        $('#svcLinesDetails').children().remove();
        $('#svcLinesDetails').append(svcDetailsObj.svcDetailsHTML);
        <%}%>
    });
</script>