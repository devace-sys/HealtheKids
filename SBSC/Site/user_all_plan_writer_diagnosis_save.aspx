<%@ Page Language="C#" CodeBehind="user_all_plan_writer_diagnosis_save.aspx.cs" Inherits="Spedmon.UserAllPlanWriterDiagnosis" %>

<%/****************************
  * Save Diagnosis Record
  * for user (all)
  ****************************/%>

<Spedmon:DataEntryRows ID="save" runat="server" dataURL="plan_writer_diagnoses.asmx/saveDiagnosis" >

    <Spedmon:HiddenInput ID="clientid" name="clientid" title="record id" runat="server"/>
    <Spedmon:HiddenInput ID="groupserviceclassnameid" name="groupserviceclassnameid" title="groupserviceclassnameid" runat="server"/>
    <Spedmon:HiddenInput ID="templatetype" name="templatetype" title="templatetype" runat="server"/>


    <%/************************************* Diagnosis Name **********************************/%>
  
    <Spedmon:DataEntryRow rowLabel="Diagnosis Name" runat="server">
        <Spedmon:Input ID="diagnosisName" name="diagnosisName" title="Diagnosis Name" runat="server" />
    </Spedmon:DataEntryRow>
  
    <%/************************************* Diagnosis Description ****************************/%>
  
    <Spedmon:DataEntryRow rowLabel="Description" runat="server">
        <Spedmon:RichTextAreaBox 
            id           = "diagnosisDescription" 
            name         = "diagnosisDescription" 
            title        = "Diagnosis Description"
            showControls = "false"
            runat        = "server">
          </Spedmon:RichTextAreaBox> 
    </Spedmon:DataEntryRow>
  

    <Spedmon:DataEntryRowSaveOrEdit 
        ID                               = "saveOrEdit"
        includeSaveAndProceedButton      = "true"
        editDelManageLink                = ""
        runat                            = "server">

    </Spedmon:DataEntryRowSaveOrEdit>

</Spedmon:DataEntryRows>


<%/****************************
  * Scripts for options
  ****************************/%>
<script type="text/javascript">

    $(function () {
        // remove the 'OK' button from the TextAreaBox
        $('#diagnosisDescription_but_ok').remove();
    });

</script>