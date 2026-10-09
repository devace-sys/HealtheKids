<%@ Page Language="C#" CodeBehind="user_all_sites_save.aspx.cs" Inherits="Spedmon.UserAllSitesSave" %>
    
<Spedmon:DataEntryRows purpose="SAVE" useBootstrapFluid="true" dataURL="sites.asmx/save" runat="server">
      
    <%//-----------------------------------------------------------------------------%>
    <%// Select Client %>
    <%// (Practi-Cal staff only) %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRowSelectClient
      ID                    = "selectClient" 
      entityControlID       = "clientID"                
      rowLabel              = "Client"                
      runat                 = "server">
    </Spedmon:DataEntryRowSelectClient>
   
    <%//-----------------------------------------------------------------------------%>
    <%// CDS %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRow ID="selectCDS" rowLabel="Enter CDS Code<br><br><div class='text-muted'>Enter the value <strong>unknown</strong> if this site does not have a CDS code.</div>"  runat="server">
                    
      <div class="d-flex">
        <Spedmon:TextBox ID="cds7" name="cds7" title="Site's 14 digit CDS code" maxlen="20" showOK = "false" runat="server"/>
        <Spedmon:LinkExternal ID="cdedir" openNew="true" url="https://www.cde.ca.gov/SchoolDirectory/" text="CDE School Directory (CA Only)" runat="server"></Spedmon:LinkExternal>
        <Spedmon:LinkExternal ID="ncespublicdir" openNew="true" url="https://nces.ed.gov/ccd/schoolsearch/" text="NCES Public School Directory (National)" runat="server"></Spedmon:LinkExternal>
        <Spedmon:LinkExternal ID="ncesprivatedir" openNew="true" url="https://nces.ed.gov/surveys/pss/privateschoolsearch/" text="NCES Private School Directory (National)" runat="server"></Spedmon:LinkExternal>
      </div>
    
    </Spedmon:DataEntryRow>
    
   <%//-----------------------------------------------------------------------------%>
   <%// Site Name %>
   <%//-----------------------------------------------------------------------------%>
  
   <Spedmon:DataEntryRow ID="selectName" rowLabel="Site Name" runat="server">

     <Spedmon:TextBox ID="name" name="name" title="Enter Site Name" maxlen="50" showOK="false" runat="server" /> 

   </Spedmon:DataEntryRow>

    <%//-----------------------------------------------------------------------------%>
    <%// Address %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRow ID="selectAddress1" rowLabel="Address<br><br><div class='text-muted'>If an address does not have a legitimate ZIP+4 value (assigned by the USPS) please enter <strong>9998</strong> in the Zip (Last 4) field instead of leaving it blank.</div>" runat="server">
                
        <Spedmon:FieldSetUSPSAddress 
            ID              = "selectAddress"
            parmNameStreet1 = "address1"
            parmNameStreet2 = "address2"
            parmNameCity    = "city"
            parmNameState   = "state"
            parmNameZip5    = "zip5"
            parmNameZip4    = "zip4"
            includeOKButton = "false"
            includeLegend   = "false"
            runat           = "server" />
        

    </Spedmon:DataEntryRow>

    <%//-----------------------------------------------------------------------------%>
    <%// Phone %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRow ID="enterPhoneNumber" rowLabel="Phone Number" runat="server">
        <Spedmon:DataEntryBoxText ID="phonenumber" name="phonenumber" title="Enter Phone Number" runat="server" />
    </Spedmon:DataEntryRow>  
    
    <%//-----------------------------------------------------------------------------%>
    <%// District ID for Site %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRow ID="selectClientProvidedSiteUID" rowLabel="School Site Identifier<br><br><div class='text-muted'>If your Student Information System (SIS) does not use the CDS Code listed above as a site identifier, please enter what your SIS uses as a code or identifier</div>" runat="server">
      <Spedmon:TextBox ID="client_provided_site_uid" name="client_provided_site_uid" title="School District Identifier" maxlen="20" showOK="false" runat="server" /> 
    </Spedmon:DataEntryRow>   
    
    <%//-----------------------------------------------------------------------------%>
    <%// cybhiTpaApproved %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRow ID="cybhiTpaApprovedRow" rowLabel="CYBHI TPA Approved:" runat="server">
        <Spedmon:SelectYesOrNo ID="cybhitpaapproved" name="cybhitpaapproved" title="CYBHI TPA Approved" renderLabel="false" runat="server" />
    </Spedmon:DataEntryRow>  

    <%//-----------------------------------------------------------------------------%>
    <%// cybhiTpaApprovedOn %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRow ID="cybhiTpaApprovedOnRow" rowLabel="CYBHI TPA Approved On" runat="server">
        <Spedmon:DataEntryBoxDate ID="cybhitpaapprovedon" name="cybhitpaapprovedon" title="CYBHI TPA Approved On" runat="server" />
    </Spedmon:DataEntryRow>  

    <%//-----------------------------------------------------------------------------%>
    <%// Save or Edit %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRowSaveOrEdit 
        ID                               = "saveOrEdit"
        editDelManageLink                = "editdelsiteslink"
        runat                            = "server">
    </Spedmon:DataEntryRowSaveOrEdit>

</Spedmon:DataEntryRows>

<%/****************************
  * Save school sites code
  * for sbs (all)
  ****************************/%>

<script type="text/javascript">

    
</script>    
