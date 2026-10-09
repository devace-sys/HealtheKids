<%@ Page Language="C#" CodeBehind="sbs_all_orp_document_standard_selection_names_save.aspx.cs" Inherits="Spedmon.sbs_all_orp_document_standard_selection_names_save"%>

<Spedmon:DataEntryRows ID="save" runat="server" dataURL="orp_documents_standard_selection_names.asmx/save">

    <%/************************************* Client **********************************/%>
  
    <Spedmon:DataEntryRow rowLabel="For Client (if custom) and Practitioner Groups" runat="server">
        <div class="d-flex">
        <Spedmon:ComboBox ID="clientid" name="clientid" title="Select Client" dataPrivate="true" dataURL="clients.asmx/viewSel" runat="server"/>         
        <Spedmon:ComboBox ID="groupserviceclassnameid" name="groupserviceclassnameid" title="Select Discipline Family" dataPrivate="true" dataURL ="groups_service_classes.asmx/viewSelForOrpDocs" dataParms="[{}]" runat="server" /> 
      </div>
    </Spedmon:DataEntryRow>

    <%/************************************* Standard Selection **********************************/%>
  
    <Spedmon:DataEntryRow rowLabel="Service Selection" runat="server">

      <div class="d-flex">

        <Spedmon:DataEntryBoxText 
            ID                  = "name" 
            name                = "name" 
            maxlen              = "255" 
            size                = "25" 
            title               = "Enter name of service" 
            label               = "What is the name of the standard selection?"             
            runat               = "server" />

         <Spedmon:DataEntryBoxTextArea
            ID                 = "notes" 
            name               = "notes" 
            title              = "Enter key words separated by spaces" 
            label              = "What key words should be associated with this selection?"
            maxlen             = "512"
            size               = "25"
            showCharCountMeter = "true"
            runat              = "server" /> 
      </div>

    </Spedmon:DataEntryRow>

    <%/************************************* Template Text **********************************/%>
  
    <Spedmon:DataEntryRow rowLabel="Order Options" runat="server">

      <div class="d-flex">
      
        <Spedmon:DataEntryRowFormBuilderBox ID="formBuilderContentJSON" name="formBuilderContentJSON" showFormBuilderBtnText="Build/Edit Form for Orders" runat="server"></Spedmon:DataEntryRowFormBuilderBox>

        <Spedmon:DataEntryBoxTextArea
          ID                 = "svcdesctemplatetext" 
          name               = "svcdesctemplatetext" 
          title              = "Enter template text" 
          label              = "Template text"
          size               = "40"
          maxlen             = "7000"
          showCharCountMeter = "true"
          runat              = "server" />
        </div>
        
        <div class="d-flex">
        
        <Spedmon:SelectYesOrNo
            ID              = "allowmultipleorders" 
            name            = "allowmultipleorders" 
            title           = "Allow multiple orders or profiles to be created for this service?"
            runat           = "server" />

    
        <Spedmon:DataEntryBoxText
          ID                 = "ordercontextfieldname" 
          name               = "ordercontextfieldname" 
          title              = "Enter context field name" 
          label              = "Enter context field name for multiple orders"
          maxlen             = "500"
          size               = "20"          
          runat              = "server" />
        </div>

    </Spedmon:DataEntryRow>

    <%/************************************* For health services **********************************/%>

    <Spedmon:DataEntryRow id="healthServicesOptions" rowLabel="Health Services Options" runat="server">


        <Spedmon:RadioBox ID="serviceJournalAssociatedEventTypeID" name="serviceJournalAssociatedEventTypeID" title="Service Journal Entry Associated Event Type" additionalCssClassNameForContainer="modern2021" runat="server"></Spedmon:RadioBox>
        
        <Spedmon:DataEntryRowFormBuilderBox ID="formBuilderContentForServiceJournalEntryNotesJSON" name="formBuilderContentForServiceJournalEntryNotesJSON" showFormBuilderBtnText="Build/Edit Form for Service Journal Entries" runat="server"></Spedmon:DataEntryRowFormBuilderBox>
                
        <Spedmon:DataEntryBoxText
            ID                 = "notecrit1templatetext" 
            name               = "notecrit1templatetext" 
            label              = "Enter Note Criteria 1 for Service Journal Entry (Free Form Text Answer)"
            title              = "Enter template text" 
            size               = "50"
            maxlen             = "500"
            showCharCountMeter = "true"
            runat              = "server" /> 

        
        <Spedmon:DataEntryBoxText
            ID                 = "notecrit2templatetext" 
            name               = "notecrit2templatetext" 
            title              = "Enter template text" 
            label              = "Enter Note Criteria 2 for Service Journal Entry (Free Form Text Answer)"
            size               = "50"
            maxlen             = "500"
            showCharCountMeter = "true"
            runat              = "server" /> 

        <Spedmon:DataEntryBoxText
            ID                 = "notecrit3templatetext" 
            name               = "notecrit3templatetext" 
            title              = "Enter template text" 
            label              = "Enter Note Criteria 3 for Service Journal Entry (Free Form Text Answer)"            
            size               = "50"
            maxlen             = "500"          
            showCharCountMeter = "true"
            runat              = "server" />
 
        <Spedmon:DataEntryBoxText
            ID                 = "notecrit4templatetext" 
            name               = "notecrit4templatetext" 
            title              = "Enter template text" 
            label              = "Enter Note Criteria 4 for Service Journal Entry (Free Form Text Answer)"
            size               = "50"
            maxlen             = "500"
            showCharCountMeter = "true"
            runat              = "server" />
    
        <Spedmon:DataEntryBoxText
            ID                 = "notecrit5templatetext" 
            name               = "notecrit5templatetext" 
            title              = "Enter template text" 
            label              = "Enter Note Criteria 5 for Service Journal Entry (Yes/No Answer)"
            size               = "50"
            maxlen             = "500"
            showCharCountMeter = "true"
            runat              = "server" />

        <Spedmon:DataEntryBoxText
            ID                 = "notecrit6templatetext" 
            name               = "notecrit6templatetext" 
            title              = "Enter template text" 
            label              = "Enter Note Criteria 6 for Service Journal Entry (Yes/No Answer)"
            size               = "50"
            maxlen             = "500"
            showCharCountMeter = "true"
            runat              = "server" />

        <Spedmon:DataEntryBoxText
            ID                 = "notecrit7templatetext" 
            name               = "notecrit7templatetext" 
            title              = "Enter template text" 
            label              = "Enter Note Criteria 7 for Service Journal Entry (Yes/No Answer)"
            size               = "50"
            maxlen             = "500"
            showCharCountMeter = "true"
            runat              = "server" />

        <Spedmon:DataEntryBoxText
            ID                 = "notecrit8templatetext" 
            name               = "notecrit8templatetext" 
            title              = "Enter template text" 
            label              = "Enter Note Criteria 8 for Service Journal Entry (Numeric Answer)"
            maxlen             = "500"
            size               = "50"
            showCharCountMeter = "true"
            runat              = "server" />

        <Spedmon:DataEntryBoxText
            ID                 = "notecrit9templatetext" 
            name               = "notecrit9templatetext" 
            title              = "Enter template text" 
            label              = "Enter Note Criteria 9 for Service Journal Entry (Numeric Answer)"
            maxlen             = "500"
            size               = "50"
            showCharCountMeter = "true"
            runat              = "server" />
  
        <Spedmon:DataEntryBoxText
            ID                 = "notecrit10templatetext" 
            name               = "notecrit10templatetext" 
            title              = "Enter template text" 
            label              = "Enter Note Criteria 10 for Service Journal Entry (Numeric Answer)"
            maxlen             = "500"
            size               = "50"
            showCharCountMeter = "true"
            runat              = "server" />
      
    </Spedmon:DataEntryRow>

    <%/************************************* Save or Edit **********************************/%>

    <Spedmon:DataEntryRowSaveOrEdit 
        ID                               = "saveOrEdit"
        editDelManageLink                = ""
        runat                            = "server">

    </Spedmon:DataEntryRowSaveOrEdit>

</Spedmon:DataEntryRows>
