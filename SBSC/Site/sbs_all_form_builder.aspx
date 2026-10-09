<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="sbs_all_form_builder.aspx.cs" Inherits="Spedmon.SbsAllFormBuilder" %>

<%//##################################################################################################################%>
<%//#                                         Data Entry Form   %>
<%//##################################################################################################################%>
<style>
    #form-builder-editor {
        display: contents;
        padding-left: 15px;
        width: 100%;
    }
</style>

<Spedmon:DataEntryRows purpose="SAVE" dataURL="servicerecords.asmx/savesvcrecsondos" runat="server">
    <spedmon:DataEntryRowFormBuilderRenderBox id="somestuff" name="someStuff" showFormBuilderBtnText="Some text" formBuilderQuestionsJSON="[{'type':'radio-group','required':false,'label':'Radio Group','inline':false,'name':'radio-group-1612392640559','access':false,'other':false,'values':[{'label':'Option 1','value':'option-1','selected':false},{'label':'Option 2','value':'option-2','selected':false},{'label':'Option 3','value':'option-3','selected':false}]},{'type':'text','required':false,'label':'Text Field','className':'form-control','name':'text-1612392647792','access':false,'subtype':'text'}]" runat="server">

    </spedmon:DataEntryRowFormBuilderRenderBox>


        

<%--    <Spedmon:DataEntryRow   
       ID                              = "selectGroup"  
       rowLabel                        = ""
       useBootstrapGrid                = "false"
       runat                           = "server">--%>

    
    <%--<div id="form-builder-editor"></div>
    <div id="fb-render"></div>

    <script>
        jQuery(function ($) {
            // https://formbuilder.readthedocs.io/en/latest/formBuilder/options/templates/
            var fields = [{
                label: 'Barrier',
                attrs: {
                    type: 'barrier'
                },
                icon: '---'
            }];

            var templates = {
                barrier: function (fieldData) {
                    return {
                        field: '<hr style="background-color: black;" />',
                        onRender: function () { }
                    };
                }
            };

            var options = {disabledActionButtons: ['data', 'save'], fields: fields, templates: templates };

            const formBuilder = $('#form-builder-editor').formBuilder(options);

            $(document).ready(function () {
                $("#save-btn").on("click", (data) => {
                    var x = formBuilder.actions.getData();

                    $("#fb-render").formRender({
                        dataType: 'json',
                        formData: x
                    });

                });
            });
        });
    </script>--%>




<%//-----------------------------------------------------------------------------%>
<%// Required Hidden Params %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:HiddenInput ID="clientid"            name="clientid"      title = "Client id"          noClear ="true" runat="server"/>

<%//-----------------------------------------------------------------------------%>
<%// Save or Edit %>
<%//-----------------------------------------------------------------------------%>

<Spedmon:DataEntryRowSaveOrEdit  
    ID                                      = "saveOrEdit" 
    editDelManageLink                       = "pracdirectsupmanagelink"
    runat                                   = "server">

</Spedmon:DataEntryRowSaveOrEdit>

</Spedmon:DataEntryRows>


<%//##################################################################################################################%>
<%//#                                         Data Entry Scripts  %>
<%//##################################################################################################################%>

<script type="text/javascript">
  
  
</script>