<%@ Page Language="C#" CodeBehind="sbs_mgmt_newsletter_pages_manage.aspx.cs" Inherits="Spedmon.SBSMgmtNewsletterPagesManage" %>


<Spedmon:Steps ID="editdelete" runat="server" autoHeight="false" autoScroll="true" dataURL="newsletter_pages.ashx">
   
   <%/*************************************[ Step 1 ]************************************/%>

   <Spedmon:StepRecordsAddNewEditDeleteView   
      ID                          = "step1" 
      addNewIsSubPage             = "true"
      editIsSubPage               = "true"    
      addNewUrl                   = "sbs_mgmt_newsletter_page_save.aspx"
      editURL                     = "sbs_mgmt_newsletter_page_save.aspx" 
      deleteURL                   = "newsletter_pages.asmx/delete"
      title                       = "Select newsletter to Edit, Republish, or Delete"
      instructions                = "Select the newsletter you wish to edit, resend, or delete from the list below"
      recIDPos                    = "2" 
      activeFlag                  = "true"
      displayGenHTM               = "false"
      displayGenXLS               = "false"
      runat                       = "server">     


     <Spedmon:RecordOpButton 
       ID        = "resendNotif"   
       saveType  = "EDIT" 
       text      = "Republish and Reset"
       icon      = "ui-icon-arrowrefresh-1-e"
       opUrl     = "newsletter_pages.asmx/resetandrepublish"
       opIsMulti = "false"
       opFn      = "doResetAndRepublishManPage(opURL, recID, $st)"
       runat     = "server"/>  

     <Spedmon:RecordOpButton 
       ID        = "emailIndividual"   
       saveType  = "EDIT" 
       text      = "Send to Individual"
       icon      = "ui-icon-mail-closed"
       opUrl     = "newsletter_pages.asmx/addindivrecipemailaddy"
       opIsMulti = "false"
       opFn      = "doPromptEmailIndividual(opURL, recID, $st)"
       runat     = "server"/>


     <Spedmon:RecordOpButton 
       ID        = "downloadReportPerNewsletter"   
       text      = "Download Report - All Recipients For Selected Item"
       icon      = "ui-icon-calculator"
       opUrl     = "newsletter_pages.ashx"
       opIsMulti = "false"
       opFn      = "doDownloadRecipientsRpt(opURL, recID, $st)"
       runat     = "server"/>  

       
  </Spedmon:StepRecordsAddNewEditDeleteView>
    
</Spedmon:Steps>


<Spedmon:Script runat="server">                  

 /*

 $(
   function() {
     $('#genhtml .ui-button-text').text('OLD - View All Recipients');

     $('#genxls .ui-button-text').text('OLD - Download Report - All Recipients (Excel)');
   }
 );

 */

 function doDownloadRecipientsRpt(opURL, recID, $st) { 
   var download_url
         = opURL +
           '&recid=' + recID +
           '&' + '<%= MBA.Constants.PARM_REP_FORM %>' +
               '=' + '<%= MBA.Constants.REPT_FORMAT_XLS %>' +
           '&' + '<%= MBA.Constants.PARM_REP_NUMBER %>' +
               '=' + '<%= Spedmon.NewsletterPagesHandler.REPT_NUM_REVIEW_RECIPIENTS %>'
    ;

    $.spedmonWebUI.downloadDynamicURL( download_url );

 }

 function doResetAndRepublishManPage (opURL, recID, $st)
 <%
 // TODO: idk what the $st param does... figure it out
 %>
 {
    var fnDoYes = function () {      
      $.spedmonWebUI.ajax(null,opURL,'{recid: ' + recID + '}',null,null,null,null,$st,1,function(){
        $($st).spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.INFO,'Notifications will be sent to all recipients for this announcement',0);
      }); 
    };


    $.spedmonWebUI.dialogConfirm( 'Republish and Reset MultiMedia Newsletter?'
                                ,'Are you sure you want to republish this multimedia newsletter?  All intended recipients will receive a new email message containing the most recent revision of this content.  This operation cannot be undone!  Click on Yes if you are absolutely sure you want to do this.'
                                , fnDoYes
                                , null);


  }


  function doPromptEmailIndividual(opURL, mm_recID, $st) {

    let $SENDEMAIL_DIALOG_CONT = $('<div></div>'); 

    function _saveIndivRecipEmailAddress(email_address, msg_body) {  // rename and refactor
      var reqData = JSON.stringify(
      {
          "mm_recid"         : mm_recID
        , "email_address"    : email_address
        , "custom_msgbody"   : msg_body
      });

      $('#airplane-send-btn').addClass('disabled');

      MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(opURL, reqData, null)
      .then(responseData => {

        var close_it_up = false;
        if (responseData.rawData.recordID == 0

            <%
            // TODO: change this to recordID != 0
            //       if we later on save a database log of indiv emails sent
            %>

            && responseData.message == "Success"
            && responseData.rawData.message  == "Success") {

            close_it_up = true;

        }

        $.spedmonWebUI.dialogMessage(
          responseData.message, responseData.message, null, 400, 200,

          function() {

            $('#airplane-send-btn').removeClass('disabled');

            if ( close_it_up )
              $SENDEMAIL_DIALOG_CONT.html('').dialog('close');
          },

          null, null
        );

      })
      .catch(responseData => {
        $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
      });

    }
   

    <% /* NOTE: this naming convention is all wrong;
          I thought I was going to have to save these emails in the database
          and add them to the queue for the service; instead I'm calling the Email.send()
          method pretty much directly 

          I should eventually rename the methods addRecip() and saveRecip() etc all the way
          up and down the call stack, both in JS and C# */
    %>

    function saveIndivRecipEmailAddress() {

        var $this_ = $(this);

        //debugger;

        if ( $this_.hasClass('disabled') )
          return;

        _saveIndivRecipEmailAddress(
            $('#recipientEmailAddyText').val(),
            $('#MessageBodyText').val()
        );
    
    }
    
    
    let $indivRecipDialogContent = $(
      '<div class="ui-spedmon-data-entry-rows container">'

    + '<div class="ui-spedmon-data-entry-row row">'
    + '<div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-label col-xs-12 col-sm-12 col-md-3">Recipient Email Address(es)</div>'    
    + '<input type="email" id="recipientEmailAddyText" class="mba-web-ui-field-data-text-area mba-web-ui-field-simple mba-web-ui-field-data-entry-primary ui-spedmon-box ui-widget-content ui-corner-all ui-spedmon-noteareabox" placeholder="username@example.edu; user2@example.edu"></input>'
    + '</div>' 


    + '<div class="ui-spedmon-data-entry-row row">'

        + '<div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-label col-xs-12 col-sm-12 col-md-3">Message Body</div>'

        + '<div class="col-xs-12 col-sm-12 col-md-8 mx-0 px-0">'
          + '<textarea style="height:5em" id="MessageBodyText" class="mba-web-ui-field-data-text-area mba-web-ui-field-simple mba-web-ui-field-data-entry-primary ui-spedmon-box ui-widget-content ui-corner-all ui-spedmon-noteareabox" placeholder="Type message for recipient"></textarea>'

        + '</div>'

    + '</div>' 

    + '<div id="saveCtrlButtons" class="ui-spedmon-data-entry-row row">' 
    + '<div id="saveCtrlButtonsRight" class="text-right col-12 ui-spedmon-data-entry-col ui-spedmon-data-entry-col-entry">'
    + '</div>'
    + '</div>'         
    + '</div>'
    );

    
    $indivRecipDialogContent.find(
        '#saveCtrlButtonsRight'
      ).append(
         $.spedmonWebUI.generateButtonElem(
           'Send',
           'mt-2 btn btn-link text-success',
           'fas fa-paper-plane fa-2x',
            saveIndivRecipEmailAddress
         ).attr('id', 'airplane-send-btn')
    );


    $SENDEMAIL_DIALOG_CONT.html('').append($indivRecipDialogContent).show().dialog(
    {
        width: 550
        , height: 280
        , title: "Send To Individual"
        , show: {
            effect: 'slide',
            complete: function () {
                
            }
        }
        , hide: {
            effect: 'slide'
            , direction: 'left'
        }
    });

    return true ; 

  }

</Spedmon:Script>