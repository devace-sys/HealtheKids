<%@ Page Language="C#" CodeBehind="sbs_mgmt_man_page_rpt_user_resp_review.aspx.cs" Inherits="Spedmon.SBSMgmtManPageRptUserRespReview" %>

<%/****************************
   * Review User Responses
   ****************************/%>

 <Spedmon:Steps ID="viewexisting" runat="server" autoHeight="false" autoScroll="true" dataURL="man_pages.ashx">

      
   <%/*************************************[ Step 1 ]************************************/%>
  
   <Spedmon:Step 
    
     ID             = "step1" 
     title          = "Who is the Client?"
     instructions   = "Start typing the client name or click on the down arrow for a list" 
     optional       = "true"
     runat          = "server">
    
    
     <Spedmon:ComboBox 
       ID          = "clientid" 
       name        = "clientid" 
       title       = "Select Client" 
       dataPrivate = "true" 
       dataURL     = "clients.asmx/viewSelWithPcal" 
       runat       = "server" /> 
   
   </Spedmon:Step>
 
   <%/*************************************[ Step 2 ]************************************/%>
  
   <Spedmon:Step 
    
     ID             = "step2" 
     title          = "Title of content?"
     instructions   = "Start typing the title or click on the down arrow for a list" 
     optional       = "true"
     runat          = "server">
    
    
     <Spedmon:ComboBox 
       ID          = "pageID" 
       name        = "pageID" 
       title       = "Select Title" 
       dataPrivate = "true" 
       dataURL     = "man_pages.asmx/viewSel" 
       runat       = "server" /> 
   
   </Spedmon:Step>
  
   <%/*************************************[ Step 3 ]************************************/%>
  
   <Spedmon:Step 
  
    ID           = "step3" 
    title        = "Notice Of New Content Was Emailed?"
    instructions = "Select Yes to just show data for users who have had a notice of new content sent to their email we have on file?" 
    optional     = "true"
    runat        = "server">
    
     <Spedmon:YesNo ID="userHasBeenEmailedNoticeOfContent" name="userHasBeenEmailedNoticeOfContent" title="User Has Been Emailed Notice of New Content?" runat="server" />
 
  </Spedmon:Step>
 
  <%/*************************************[ Step 4 ]************************************/%>
  
  <Spedmon:Step 
  
    ID           = "step4" 
    title        = "User Has Seen Content?"
    instructions = "Select Yes to just show data for users who have opened (seen) content?" 
    optional     = "true"
    runat        = "server">
    
     <Spedmon:YesNo ID="userHasSeenContent" name="userHasSeenContent" title="User Has Seen Content?" runat="server" />
 
  </Spedmon:Step>

  <%/*************************************[ Step 5 ]************************************/%>
  
  <Spedmon:Step 
  
    ID           = "step5" 
    title        = "User Will Read Content Later?"
    instructions = "Select Yes to just show data for users who have indicated that they will read content later?" 
    optional     = "true"
    runat        = "server">
    
     <Spedmon:YesNo ID="userWillReadContentLater" name="userWillReadContentLater" title="User Will Read Content Later?" runat="server" />
 
  </Spedmon:Step>

  <%/*************************************[ Step 6 ]************************************/%>
 
  <Spedmon:Step 
  
    ID           = "step6" 
    title        = "User Has Read Content?"
    instructions = "Select Yes to just show data for users who have indicated they have read content?" 
    optional     = "true"
    runat        = "server">
    
     <Spedmon:YesNo ID="userHasReadContent" name="userHasReadContent" title="User Has Read Content?" runat="server" />
 
  </Spedmon:Step>
 
  <%/*************************************[ Step 7 ]************************************/%>
  
  <Spedmon:StepView
   
    ID           = "step7" 
    reportNumber = "2" 
    runat        = "server">
  
  </Spedmon:StepView>
    
</Spedmon:Steps>