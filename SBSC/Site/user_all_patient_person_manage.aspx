<%@ Page Language="C#" CodeBehind="user_all_patient_person_manage.aspx.cs" Inherits="Spedmon.UserAllPatientPersonManage" %>

 <Spedmon:Steps 
   ID         = "editdelete" 
   autoHeight = "false" 
   autoScroll = "true" 
   dataURL    = "patient_persons.ashx"
   runat      = "server">
   

  <%/************************************* [ Step 1 ] ************************************/%>
  
  <Spedmon:StepRecordsAddNewEditDeleteView     
    ID                          = "step1" 
    addNewIsSubPage             = "true"
    editIsSubPage               = "true"    
    addNewUrl                   = "user_all_patient_persons_save.aspx"
    editURL                     = "user_all_patient_persons_save.aspx" 
    deleteURL                   = ""
    addParmsToActionURLFnAddNew = "addParmsToNewEdit"
    addParmsToActionURLFnEdit   = "addParmsToNewEdit"
    title                       = "Add A New Person or Select One"
    instructions                = "Select the person you wish to edit or remove from list"
    recIDPos                    = "2" 
    runat                       = "server">     
      
   <Spedmon:HiddenInput ID="clientid"  name="clientid"      title="clientid"    noClear="true" runat="server"/>
   <Spedmon:HiddenInput ID="patid"     name="patid"     title="patid"   noClear="true" runat="server"/>    

    </Spedmon:StepRecordsAddNewEditDeleteView>

</Spedmon:Steps>


<Spedmon:Script ID="preOptions" runat="server">


function addParmsToNewEdit()
{ 
  var prmsOut = ''; 
  
  var cltid  = $('#clientid').val();  
  var patid  = $('#patid').val();
  
  /* Persons save requires */
  
  if (cltid) prmsOut = prmsOut + '&clientid='  + cltid;   
  if (patid) prmsOut = prmsOut + '&patientid=' + patid;           
    
  return prmsOut;
}




</Spedmon:Script>
