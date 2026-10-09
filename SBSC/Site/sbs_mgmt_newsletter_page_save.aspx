 <%@ Page Language="C#" CodeBehind="sbs_mgmt_newsletter_page_save.aspx.cs" Inherits="Spedmon.SBSMgmtNewsletterPageSave" %>

 <Spedmon:DataEntryRows ID="save" runat="server" dataURL="newsletter_pages.asmx/save">

    <%/************************************* Resource Library Topic **********************************/%>

    <Spedmon:DataEntryRow rowLabel="Is This Searchable In Resource Library?" runat="server">

        <Spedmon:SelectYesOrNo 
            id            = "isresourcelibrarytopic" 
            name          = "isresourcelibrarytopic" 
            title         = "isResourceLibraryTopic"
            renderLabel   = "false" 
            onSelectValue = "function(oldval,newval){ return true; }"
            runat         = "server" />

    </Spedmon:DataEntryRow>

    <%/************************************* Is Content Ready to Publish? **********************************/%>
   
    <Spedmon:DataEntryRow rowLabel="Is Content Ready To Share?" runat="server">
        <Spedmon:SelectYesOrNo 
            id="readyToSend" 
            name="readyToSend" 
            title="readyToSend" 
            renderLabel="false" 
            onSelectValue="function(oldval,newval){ return true; }"
            runat="server" />
    </Spedmon:DataEntryRow>

    <%/************************************* Is Content Ready to Publish? **********************************/%>
   
    <Spedmon:DataEntryRow rowLabel="Send As Newsletter Emails To Selected Recipients?" runat="server">
        <Spedmon:SelectYesOrNo 
            id="sendEmailSelected" 
            name="sendEmailSelected" 
            title="sendEmailSelected" 
            renderLabel="false" 
            onSelectValue="function(oldval,newval){ return true; }"
            runat="server" />
    </Spedmon:DataEntryRow>

    <%/************************************* Date Content Is Available **********************************/%>
  
    <Spedmon:DataEntryRow rowLabel="Enter a date that this content will become available for users to view" runat="server">
        <Spedmon:DateBoxHTML5 ID="startdate" name="startdate" title="Enter Start Date" runat="server" />
    </Spedmon:DataEntryRow>

    <%/************************************* Clients Selection **********************************/%>
  
    <Spedmon:DataEntryRow rowLabel="Select all of the clients that will be able to view this content" runat="server">
        <Spedmon:ComboBox 
            id                = "forclientids" 
            name              = "forclientids" 
            title             = "Select clients" 
            dataPrivate       = "true" 
            dataURL           = "clients.asmx/viewSel" 
            multiSelect       = "true"
            multiSelectShowOK = "false"
            runat             = "server" />
    </Spedmon:DataEntryRow>

    <%/************************************* Contact Roles **********************************/%>
  
    <Spedmon:DataEntryRow rowLabel="Select all of the contact roles that will be able to view this content" runat="server">
        <Spedmon:ComboBox 
            id                = "forcontactroleids" 
            name              = "forcontactroleids" 
            title             = "Select roles" 
            dataPrivate       = "true" 
            dataURL           = "client_contact_roles.asmx/viewSel" 
            multiSelect       = "true"
            multiSelectShowOK = "false"
            runat             = "server" />
    </Spedmon:DataEntryRow>

        <%/************************************* User Roles **********************************/%>
  
    <Spedmon:DataEntryRow rowLabel="Select all of the user roles that will be able to view this content" runat="server">
        <Spedmon:ComboBox 
            id                = "foruserroleids" 
            name              = "foruserroleids" 
            title             = "Select roles" 
            dataPrivate       = "true" 
            dataURL           = "man_pages.asmx/viewSelUserRoles" 
            multiSelect       = "true"
            multiSelectShowOK = "false"
            runat             = "server" />
    </Spedmon:DataEntryRow>

    <%/************************************* Title **********************************/%>
  
    <Spedmon:DataEntryRow rowLabel="Enter the title that will be used for both the content link and page title" runat="server">

        <Spedmon:TextBox 
            id      = "announcementtitle" 
            name    = "announcementtitle" 
            maxlen  = "255" 
            title   = "Enter Title"
            showOK  = "false"
            runat   = "server">
        </Spedmon:TextBox>

    </Spedmon:DataEntryRow>

    <%/************************************* Tooltip **********************************/%>

    <Spedmon:DataEntryRow rowLabel="Enter the descriptive tooltip" runat="server">

        <Spedmon:DataEntryBoxTextArea

            id      = "tooltip" 
            name    = "tooltip" 

           label  =  "Descriptive Tooltip"

           title  =  "Enter a description to be rendered on the hover tooltip"
        required  =  "false"
          maxLen  =  "1000"

         size     =  "42"

        showCharCountMeter  =  "true"
                     runat  =  "server"  />

    </Spedmon:DataEntryRow>

    <%/************************************* Content **********************************/%>
  
    <Spedmon:DataEntryRow rowLabel="Enter the content that will be displayed.  What you see is what you get." runat="server">

        <Spedmon:RichTextAreaBox 
            id    = "announcementcontent" 
            name  = "announcementcontent" 
            title = "Enter content"
            runat = "server">
        </Spedmon:RichTextAreaBox>

    </Spedmon:DataEntryRow>

    <%/************************************* Tags **********************************/%>

    <Spedmon:DataEntryRow rowLabel="Enter the space-separated tags that will be searchable" runat="server">

        <Spedmon:DataEntryBoxTextArea

           ID     =  "tags"
           name   =  "tags"
           label  =  "Search Tags"
           title  =  "Enter tag values seperated by spaces"
        required  =  "false"
          maxLen  =  "512"

         size     =  "42"

        showCharCountMeter  =  "true"
                     runat  =  "server"  />

   </Spedmon:DataEntryRow>


    <%/************************************* Save or Edit **********************************/%>

    <Spedmon:DataEntryRowSaveOrEdit 
        ID                               = "saveOrEdit"
        editDelManageLink                = ""
        runat                            = "server">

    </Spedmon:DataEntryRowSaveOrEdit>

</Spedmon:DataEntryRows>
