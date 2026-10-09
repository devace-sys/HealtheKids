<%@ Page Language="C#" CodeBehind="client_prov_service_journals_journal_close.aspx.cs" Inherits="Spedmon.client_prov_service_journals_journal_close"%>

<%/****************************
   * Close Service Journal
   * for Prac (all)
   ****************************/%>
  
<%=journalEntriesTable%>

<%=journalWarningsProblemsTable%>

<%/****************************
   * Steps
   ****************************/%>

<Spedmon:Steps ID="save" animated="false" autoScroll="true" runat="server" dataURL="servicejournalsjournals.asmx/close">
      

  <%/*************************************[ Step 1 ] ************************************/%>
  
  <Spedmon:Step 
    ID        = "step1" 
    title     = "Review Messages and Save IF CORRECT - Fix, clear or cancel IF NOT CORRECT" 
    onactive  = "doValidateOrAutoSaveAndExit()"
    runat     = "server">

  
    <div class="practitioner-attest-statement">
    <%=Messages.ATTEST_STATEMENT%>
    </div>
    
    <Spedmon:HiddenInput ID="clientid"     name="clientid"     title="Client id" noClear="true" runat="server"/>
    <Spedmon:HiddenInput ID="pracid"       name="pracid"       title="Prac id"   noClear="true" runat="server"/>
    <Spedmon:HiddenInput ID="patid"        name="patid"        title="patid"     noClear="true" runat="server" />
    
    
    <%/****************************
       * The following inputs
       * are required to be passed
       * to the save form but are
       * not used
       ****************************/%>
    
    <input id="validaterec"   type="text"   name="validaterec"   value="1" style="display:none" />
    <input id="editDelReason" type="text"   name="editDelReason" value=""  style="display:none" />

  <%/****************************
    * The following inputs
    * are used to determine
    * if the save is an edit or
    * delete and if validation
    * is to be performed.  They
    * are preset on page load
    ****************************/%>
    
    <Spedmon:HiddenInput ID="savetype"  name="savetype"    title="save type" runat="server"/>
    <Spedmon:HiddenInput ID="recid"     name="recid"       title="record id" runat="server"/>

  <%/****************************
     * Status control for save
     ****************************/%>    
    
    <Spedmon:DetailList ID="validatelist" runat="server"></Spedmon:DetailList>
    
  <%/****************************
     * Options
     ****************************/%>   
    
  <Spedmon:Button ID="savereturn"   icon="ui-icon-pencil"               onclick="doSaveAndReturn()" runat="server">Close Journal & Proceed</Spedmon:Button>
  <Spedmon:Button ID="cancelgohome" icon="ui-icon-arrowreturnthick-1-w" onclick="doGoHome()"        runat="server">Cancel & Exit</Spedmon:Button>    
  
  </Spedmon:Step>
</Spedmon:Steps>

<%/****************************
  * Scripts for options
  ****************************/%>
  
<Spedmon:Script runat="server">
                                
function doSave(saveType,fnSuccess)
{
  $('#validaterec').val('0');
  $('#savetype').val(saveType);
  var $sn = $("#save");   
  var $st = $('#validatelist');
  $.spedmonWebUI.ajaxFrm($sn,null,'json_synch',null,$st,fnSuccess);
}

function doGoHome() { 
    <% if(!String.IsNullOrEmpty(MBA.HttpApplication.getParameter(Constants.PARM_APP_MODE))) { %>
        window.open('','_self').close();
    <%} else { %>
        $.spedmonWebUI.gotoMenuLink('homePageLink');
    <%}%>
}

function doSaveAndReturn  () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){doGoHome();});}
function doSaveAndExit    () {doSave($.spedmonWebUI.RECORD_SAVE_TYPE_NEW, function(){doGoHome();});}

function doValidate()
{  
  $('#savetype').val('<%=saveType%>');
  $('#validaterec').val('1');
  var $sn = $("#save");   
  var $st = $('#validatelist');
  $.spedmonWebUI.ajaxFrm($sn,null,'json_synch',null,$st,function(){$st.spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.INFO,'Your record is ready to save. Please SELECT AN OPTION BELOW.',0)});
}

function doValidateOrAutoSaveAndExit(){
  <%if (vDoAutoCloseExit == true) {%>
    doSaveAndExit();
  <%} else {%>
    doValidate();
  <%}%>
}

</Spedmon:Script>
