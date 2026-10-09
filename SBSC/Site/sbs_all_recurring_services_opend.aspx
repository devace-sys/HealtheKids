<%@ Page Language="C#" CodeBehind="sbs_all_recurring_services_opend.aspx.cs" Inherits="Spedmon.SBSAllRecurringServicesOpEnd" %>

<%/****************************
   * Delete Recurring Services
   * Record for sbs (all)
   ****************************/%>
  
<Spedmon:Steps ID="save" animated="false" autoScroll="true" runat="server" dataURL="recurringservices.asmx/opend"> 
  
  <%/*************************************[ Step 1 ]************************************/%>

  <Spedmon:Step 
    ID="step1" 
    title="Enter End Date"
    instructions="Select or enter the last date services were provided or the date you wish to end this record on" 
    runat="server">

     <Spedmon:DateBox ID="effectivedate" name="effectivedate" title="Select or Enter End Date" numMonths="1" maxDate="" runat="server" />
    
  </Spedmon:Step>

  <%/*************************************[ Step 2 ]************************************/%>

  <Spedmon:Step 
    ID="step2" 
    title="Enter Reason"
    optional="true"
    instructions="Enter the reason for the change" 
    runat="server">

    <Spedmon:TextBox ID="editDelReason" name="editDelReason" title="edit delete" value="" runat="server" />

  </Spedmon:Step>


  <%/*************************************[ Step 3 ]************************************/%>
  
  <Spedmon:Step 
    ID                = "step3" 
    title             = "Select an Option" 
    onactive          = "doValidate()"
    runat             = "server">
           
  <%/****************************
    * The following inputs
    * are used to determine
    * if the save is an edit or
    * delete and if validation
    * is to be performed.  They
    * are preset on page load
    ****************************/%>
    
    <Spedmon:HiddenInput ID="validaterec"   name="validaterec"   title="validate rec"            runat="server" />
    <Spedmon:HiddenInput ID="savetype"      name="savetype"      title="save type"               runat="server"/>
    <Spedmon:HiddenInput ID="recid"         name="recid"         title="record id"               runat="server"/>
    <Spedmon:HiddenInput ID="active"        name="active"        title="active"       value="0"  runat="server"/>
    <Spedmon:HiddenInput ID="actionurl"     name="actionurl"     title="action url"              runat="server"/>
    
    
    <%/****************************
       * Status control for save
       ****************************/%>    
    
    <Spedmon:DetailList 
      ID="validatelist" 
      runat="server">
    </Spedmon:DetailList>

  
    <%/****************************
       * Options
       ****************************/%>   
    
    <%if (saveType == Constants.SAVE_TYPE_COPY)       {%>       

     <Spedmon:Button ID="endandcopynew" icon="ui-icon-clipboard" onclick="doEndAndCopy()" runat="server">End and Copy Into New</Spedmon:Button>

   <%}else if (saveType == Constants.SAVE_TYPE_DEACTIVATE) {%>
      
     <Spedmon:Button ID="endandquit" icon="ui-icon-arrowthickstop-1-e" onclick="doEndAndQuit()" runat="server">End and Exit</Spedmon:Button>
      
   <%}%>   
   
   <Spedmon:Button  ID="cancelgolist"  icon="ui-icon-arrowreturnthick-1-w" onclick="doGoList()" runat="server">Cancel and Exit</Spedmon:Button>   

  </Spedmon:Step>
</Spedmon:Steps>
