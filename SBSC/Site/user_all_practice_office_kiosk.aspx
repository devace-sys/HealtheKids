<%@ Page Language="C#" CodeBehind="user_all_practice_office_kiosk.aspx.cs" Inherits="Spedmon.UserAllPracticeOfficeKiosk"%>

<%if (this.pageInitIsOK == true) { %>
<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                         Data Entry Form                                                         %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>


<%//##################################################################################################################%>
<%//#                                            Hidden Static Fields                                                 %>
<%//##################################################################################################################%>
<div class="bg-container " id="content">
<div class="bubble-container  w-100 h-100">
<div class="container-fluid content">
 <div class="row justify-content-center">
  <div class="col-12 col-md-6">
    <div class="outer-box">
      <div class="client-form">
        <%//-----------------------------------------------------------------------------%>
        <%// Practice family %>
        <%//-----------------------------------------------------------------------------%>
        <Spedmon:HiddenInput ID="groupserviceclassnameid" name="groupserviceclassnameid" title="groupserviceclassnameid" runat="server" />
        <%//-----------------------------------------------------------------------------%>
        <%// Client (visible only to pcal staff) %>
        <%//-----------------------------------------------------------------------------%>
        <Spedmon:DataEntryRowSelectClient
          ID="selectClient"
          rowLabel="Client"           
          showDataSourceSelection="false"
          saveDataSourceSelectedAsPreference="false"
          showClearSelection="true"
          showSaveSelectionAsDefault="false"
          dataEntryRowRenderAs="FIELD"
          runat="server">
        </Spedmon:DataEntryRowSelectClient>
      </div> <!-- client-form -->
    </div> <!-- outer-box -->
  </div> <!-- col -->
</div> <!-- row -->

</div>
<%//##################################################################################################################%>
<%//#                                          Check In "Form"                                                        %>
<%//##################################################################################################################%>
  
      
<div class="container-fluid">
    <div class="three-container" >

  <%//-----------------------------------------------------------------------------%>
  <%// Sub title and instructions  %>
  <%//-----------------------------------------------------------------------------%>
<div class="container-fluid content">
  <div class="row justify-content-center">
    <div class="col-10 col-md-8 col-lg-6">
      <div class="title-form">
        <div class="bubble">
          <span></span>
          <span></span>
          <span></span>
          <span></span>
          <span></span>
        </div>
        <h1>
          <%=this.subTitle%>
        </h1>
      <div class="d-flex align-items-center second-subtitle">
        <p>
          Please complete the following form.
        </p>
         <div class="col-1 position-relative">
    <div class="overlay-expand-container" >
         <Spedmon:DataEntryButton ID="buttogglefullscreen" label="Full Screen" faIcon="fa fa-expand fa-2x" iconOnly="true" assignBsCssClasses="false" onclick="MBA.ComponentCommon.fnFullScreenForPageToggle('visitcontentcontainer')" runat="server" />
    </div>
    <label class="expand-container" id="customFullscreenToggle">
        <input type="checkbox" id="toggle-checkbox">
        <svg viewBox="0 0 448 512" height="1em" xmlns="http://www.w3.org/2000/svg" class="compress">
            <path d="M32 32C14.3 32 0 46.3 0 64v96c0 17.7 14.3 32 32 32s32-14.3 32-32V96h64c17.7 0 32-14.3 32-32s-14.3-32-32-32H32zM64 352c0-17.7-14.3-32-32-32s-32 14.3-32 32v96c0 17.7 14.3 32 32 32h96c17.7 0 32-14.3 32-32s-14.3-32-32-32H64V352zM320 32c-17.7 0-32 14.3-32 32s14.3 32 32 32h64v64c0 17.7 14.3 32 32 32s32-14.3 32-32V64c0-17.7-14.3-32-32-32H320zM448 352c0-17.7-14.3-32-32-32s-32 14.3-32 32v64H320c-17.7 0-32 14.3-32 32s14.3 32 32 32h96c17.7 0 32-14.3 32-32V352z"></path>
        </svg>
        <svg viewBox="0 0 448 512" height="1em" xmlns="http://www.w3.org/2000/svg" class="expand">
            <path d="M160 64c0-17.7-14.3-32-32-32s-32 14.3-32 32v64H32c-17.7 0-32 14.3-32 32s14.3 32 32 32h96c17.7 0 32-14.3 32-32V64zM32 320c-17.7 0-32 14.3-32 32s14.3 32 32 32H96v64c0 17.7 14.3 32 32 32s32-14.3 32-32V352c0-17.7-14.3-32-32-32H32zM352 64c0-17.7-14.3-32-32-32s-32 14.3-32 32v96c0 17.7 14.3 32 32 32h96c17.7 0 32-14.3 32-32s-14.3-32-32-32H352V64zM320 320c-17.7 0-32 14.3-32 32v96c0 17.7 14.3 32 32 32s32-14.3 32-32V384h64c17.7 0 32-14.3 32-32s-14.3-32-32-32H320z"></path>
        </svg>
    </label>
    </div>
    </div> <!-- col -->
      </div>
    </div>
  </div>
</div>
 
  <%//-----------------------------------------------------------------------------%>
  <%// Student ID  %>
  <%//-----------------------------------------------------------------------------%>
<div class="container-fluid content">
  <div class="row justify-content-center">
    <div class="col-12 col-md-8 col-lg-6">
      <div class="card-form gradient-1">
        <h3>
          Please Enter Your
          <br />
          Student ID
        </h3>
        <Spedmon:DataEntryBoxText ID="studentid" name="studentid" label="Student ID"
        required="true" runat="server" />
      </div>
    </div>
  </div>
</div>

  <%//-----------------------------------------------------------------------------%>
  <%// Reason for Visit  %>
  <%//-----------------------------------------------------------------------------%>

<div class="container-fluid content">
  <div class="row justify-content-center">
    <div class="col-12 col-md-8 col-lg-6">
      <div class="card-form gradient-2">
        <h3>Please Select a <br />Reason For Your Visit</h3>
      <Spedmon:DataEntryBoxSelect id="practiceofficevisitreasonid" name="practiceofficevisitreasonid" label="Reason For Visit"  required="true" runat="server"   />
    </div> <!-- col -->
   </div> <!-- col -->
  </div> <!-- row -->  
 </div>

  <%//-----------------------------------------------------------------------------%>
  <%// Notes  %>
  <%//-----------------------------------------------------------------------------%>

<div class="container-fluid content">
  <div class="row justify-content-center">
    <div class="col-12 col-md-8 col-lg-6">
      <div class="card-form gradient-3">
        <h3>Please Enter Any <br />Additional Information <br /> (optional)</h3>
        <Spedmon:DataEntryBoxTextArea ID="practiceofficevisitreasonnotes" name="practiceofficevisitreasonnotes" label="Additional Information" required="false" runat="server" />      
     </div> <!-- col -->
  </div> <!-- row -->  
 </div>
</div>

  <%//-----------------------------------------------------------------------------%>
  <%// Check In  %>
  <%//-----------------------------------------------------------------------------%>
     
 <div class="container-fluid content mt-5  mb-5 completed-form-bottom" >
 
<div class="row ">
  <div class="col">
  </div>
  <div class="col d-flex justify-content-center mr-5 ml-5 mb-4 px-1">
    <div class="col">
    </div>
    <div id="delete-options-container">
      <div class="button-delete-wrapper">
        <button id="checkin-clear" type="button" class="button-delete">
     <div class="sign">
          <svg viewBox="0 0 448 512" class="svgIcon">
              <path d="M135.2 17.7L128 32H32C14.3 32 0 46.3 0 64S14.3 96 32 96H416c17.7 0 32-14.3 32-32s-14.3-32-32-32H320l-7.2-14.3C307.4 6.8 296.3 0 284.2 0H163.8c-12.1 0-23.2 6.8-28.6 17.7zM416 128H32L53.2 467c1.6 25.3 22.6 45 47.9 45H346.9c25.3 0 46.3-19.7 47.9-45L416 128z"></path>
            </svg>
       </div>
      <div class="text-delete">Delete</div>
        </button>
      </div>
    </div>
  </div>
  <!-- col -->
  <div class="col">
  </div>
  <div class="col d-flex justify-content-center   mr-5 ml-5 mb-4 px-1 ">
    <div id="save-options-container">
      <div class="button-save-wrapper">
        <button id="checkin-submit" type="button" class="button-save">
          <svg viewBox="0 0 16 16" class="bi bi-door-open-fill svgIcon-save" fill=""
          height="32" width="32" xmlns="http://www.w3.org/2000/svg">
            <path d="M1.5 15a.5.5 0 0 0 0 1h13a.5.5 0 0 0 0-1H13V2.5A1.5 1.5 0 0 0 11.5 1H11V.5a.5.5 0 0 0-.57-.495l-7 1A.5.5 0 0 0 3 1.5V15H1.5zM11 2h.5a.5.5 0 0 1 .5.5V15h-1V2zm-2.5 8c-.276 0-.5-.448-.5-1s.224-1 .5-1 .5.448.5 1-.224 1-.5 1z">
            </path>
          </svg>
          <span class="text-save">
            Check In
          </span>
        </button>
      </div>
    </div>
    <div class="col">
    </div>
  </div>
  <!-- col -->
  <div class="col">
  </div>
</div>

<div class="pb-5"/>

</div>
             </div>

     </div>
    <%//##################################################################################################################%>
<%//#                                           Kiosk Options                                                         %>
 <div class="kiosk-button" ></div>

    <div class="container-fluid content">
  <div class="row justify-content-center">
    <div class="col-12 col-md-6">
      <div class="title-form">
        <details id="kiosk-options-container" class="mt-1 mr-1 ml-1 mb-1">
        <summary id="kiosk-options-header" style="color:black">Kiosk Options</summary>
     
    <div id="kiosk-options-content">
  <%//-----------------------------------------------------------------------------%>
  <%// Site  %>
  <%//-----------------------------------------------------------------------------%>
   <Spedmon:DataEntryRowSelectSchoolSite
      ID                                  = "selectSchoolSite" 
      rowLabel                            = "Site" 
      showDataSourceSelection             = "false"    
      saveDataSourceSelectedAsPreference  = "false"
      showClearSelection                  = "true"
      showSaveSelectionAsDefault          = "true"
      dataEntryRowRenderAs                = "FIELD"
      runat                               = "server">
    </Spedmon:DataEntryRowSelectSchoolSite>    
    </div> <!-- kiosk options content -->
     </details> <!-- kiosk options container -->
         </div>
       </div>
    </div>
 </div>



<div id="fullscreen-alert">
    <div class="captcha-card">
        <div class="captcha-content">
            <div class="checkbox-wrapper">
                <input id="cbtest" type="checkbox">
                <label class="check-box" for="cbtest"></label>
            </div>
            <p>I'm not a robot</p>
        </div>
    </div>
</div>

</div>
<div id="widget" class="widget content">
  <div id="widget_button" class="widget_button">
    <i class="material-icons" id="widget_icon">accessibility</i>
  </div>
  <div class="widget_body">
    <div class="header">
      <h2>Accessibility Options</h2>
      <span><i class="material-icons">close</i></span>
    </div>
    <div class="accessibility-box-body">
      <div class="container-fluid">
        <div class="row">
          <div class="col-6">
            <button id="increase-text" class="accessibility-option btn btn-light d-flex flex-column align-items-center justify-content-center">
              <i class="material-icons">text_fields</i>
              <span>Bigger Text</span>
              <div id="text-size-indicator" class="indicator-container mt-2">
                <span class="indicator-dot active"></span>
                <span class="indicator-dot"></span>
                <span class="indicator-dot"></span>
              </div>
            </button>
          </div>
          <div class="col-6">
            <button id="grayscale" class="accessibility-option btn btn-light d-flex flex-column align-items-center justify-content-center">
              <i class="material-icons">palette</i>
              <span>Grayscale</span>
            </button>
          </div>
        </div>
        <div class="row mt-3">
          <div class="col-6">
            <button id="read-aloud" class="accessibility-option btn btn-light d-flex flex-column align-items-center justify-content-center">
              <i class="material-icons">volume_up</i>
              <span>Read Aloud</span>
            </button>
          </div>
          <div class="col-6">
            <button id="brightness" class="accessibility-option btn btn-light d-flex flex-column align-items-center justify-content-center">
              <i class="material-icons">brightness_6</i>
              <span>Brightness</span>
              <div id="brightness-indicator" class="indicator-container mt-2">
                <span class="indicator-dot active"></span>
                <span class="indicator-dot"></span>
                <span class="indicator-dot"></span>
              </div>
            </button>
          </div>
        </div>
        <div class="row mt-3">
          <div class="col-12">
            <button id="reset" class="accessibility-option btn btn-reset d-flex flex-column align-items-center justify-content-center">
              <i class="material-icons">refresh</i>
              <span>Reset</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>


</div>

    <%//##################################################################################################################%>

<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                         Data Management Scripts                                                 %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<script type="text/javascript">
    history.pushState(null, null, location.href);
    window.onpopstate = function () {
        history.go(1);
    };


    let fullscreen = false;
    const fsCheckbox = document.getElementById('cbtest');

    function isMobileDevice() {
        return /Mobi/i.test(navigator.userAgent) && !/iPad/i.test(navigator.userAgent);
    }

    function isTabletDevice() {
        return /iPad/i.test(navigator.userAgent) && !/Mobi/i.test(navigator.userAgent);
    }

    fsCheckbox.addEventListener('change', function () {
        if (fsCheckbox.checked) {
            if (isMobileDevice() || (!document.documentElement.requestFullscreen && !isTabletDevice())) {
                setTimeout(() => {
                    fadeOut();
                }, 500);

            } else {
                setTimeout(() => {
                    requestFullscreen();
                }, 500);
            }
        }
    });

    function requestFullscreen() {
        if (!fullscreen && document.documentElement.requestFullscreen) {
            document.documentElement.requestFullscreen()
                .then(() => {
                    fullscreen = true;
                    document.getElementById('fullscreen-alert').style.display = 'none';
                    disableZoom();
                })
                .catch((err) => {
                    fadeOut();
                });
        } else {
            fadeOut();
        }
    }

    function fadeOut() {
        document.getElementById('fullscreen-alert').style.display = 'none';
    }

    function showFullscreenAlert() {
        document.getElementById('fullscreen-alert').style.display = 'flex';
    }
    showFullscreenAlert();



    /*------------------------------------------------------------------------------------------------------------*/
    $(function () {
        let textSize = 1;
        let textSizeIncrements = 0;
        const maxTextIncrements = 2;
        let grayscaleApplied = false;
        let currentBrightnessIndex = 0;
        let brightnessLevels = [1, 0.8, 1.2];
        let currentContrastIndex = 0;
        let contrastLevels = [1, 0.8, 1.2];
        let speechToTextEnabled = false;
        let selectedVoice = null;

        function preloadVoices() {
            return new Promise((resolve) => {
                const voices = window.speechSynthesis.getVoices();
                selectedVoice = voices.find(voice => voice.name.includes('Microsoft Zira - English (United States)'));
                if (selectedVoice) {
                    resolve();
                } else {
                    window.speechSynthesis.onvoiceschanged = function () {
                        const voices = window.speechSynthesis.getVoices();
                        selectedVoice = voices.find(voice => voice.name.includes('Microsoft Zira - English (United States)'));
                        resolve();
                    };
                }
            });
        }
     

        $('#widget_button').click(function (event) {
            event.stopPropagation();
            $('#widget').toggleClass('open_widget');
        });

        $(document).click(function (event) {
            if (!$(event.target).closest('.widget, #widget_button').length) {
                if ($('#widget').hasClass('open_widget')) {
                    $('#widget').removeClass('open_widget');
                }
            }
        });

        $('.widget_body .accessibility-option').click(function (event) {
            event.stopPropagation();
        });

        $('.header .material-icons').click(function () {
            $('#widget').removeClass('open_widget');
        });

        $('#increase-text').click(function () {
            if (textSizeIncrements < maxTextIncrements) {
                textSize += 0.1;
                $('.content').css('font-size', `${textSize}em`);
                $('h2').css('font-size', `${textSize}em`);
                textSizeIncrements++;
            } else {
                textSize = 1;
                textSizeIncrements = 0;
                $('.content').css('font-size', '1em');
                $('h2').css('font-size', '1.5em');
            }
            updateTextSizeIndicator(textSizeIncrements);
            maintainWidgetPosition();
        });

        function updateTextSizeIndicator(index) {
            $('#text-size-indicator .indicator-dot').removeClass('active');
            $('#text-size-indicator .indicator-dot').eq(index).addClass('active');
        }

        $('#grayscale').click(function () {
            grayscaleApplied = !grayscaleApplied;
            applyFilters();
            maintainWidgetPosition();
        });

        $('#brightness').click(function () {
            currentBrightnessIndex = (currentBrightnessIndex + 1) % brightnessLevels.length;
            applyFilters();
            updateBrightnessIndicator(currentBrightnessIndex);
            maintainWidgetPosition();
        });

        $('#contrast').click(function () {
            currentContrastIndex = (currentContrastIndex + 1) % contrastLevels.length;
            applyFilters();
            updateContrastIndicator(currentContrastIndex);
            maintainWidgetPosition();
        });

        function applyFilters() {
            let brightnessValue = brightnessLevels[currentBrightnessIndex];
            let contrastValue = contrastLevels[currentContrastIndex];
            let filterValue = `brightness(${brightnessValue}) contrast(${contrastValue})`;
            if (grayscaleApplied) {
                filterValue += ' grayscale(100%)';
            }
            $('.content').css('filter', filterValue);
            maintainWidgetPosition();

        }


        function updateBrightnessIndicator(index) {
            $('#brightness-indicator .indicator-dot').removeClass('active');
            $('#brightness-indicator .indicator-dot').eq(index).addClass('active');
        }

        function updateContrastIndicator(index) {
            $('#contrast-indicator .indicator-dot').removeClass('active');
            $('#contrast-indicator .indicator-dot').eq(index).addClass('active');
        }

        $('#reset').click(function () {
            textSize = 1;
            textSizeIncrements = 0;
            currentBrightnessIndex = 0;
            currentContrastIndex = 0;
            grayscaleApplied = false;
            speechToTextEnabled = false;
            $('.content').css('font-size', '1em');
            $('h2').css('font-size', '1.5em');
            $('.content').css('filter', 'none');
            updateTextSizeIndicator(textSizeIncrements);
            updateBrightnessIndicator(currentBrightnessIndex);
            updateContrastIndicator(currentContrastIndex);
            maintainWidgetPosition();
            $('#read-textarea').fadeOut();
        });

        $('#read-aloud').click(function () {
            speechToTextEnabled = !speechToTextEnabled;
            if (speechToTextEnabled) {
                sayIt("Now reading any selected text aloud.", 'en-US');
                $('#read-textarea').fadeIn();
            } else {
                $('#read-textarea').fadeOut();
            }
            maintainWidgetPosition();
        });

        function sayIt(query, language, element = null) {
            if ('speechSynthesis' in window && selectedVoice) {
                window.speechSynthesis.cancel();
                if (element) {
                    $(element).css('background-color', 'yellow');
                }
                var utterance = new SpeechSynthesisUtterance(query);
                utterance.lang = language;
                utterance.voice = selectedVoice;
                utterance.rate = 1.0;

                utterance.onend = function () {
                    if (element) {
                        $(element).css('background-color', '');
                    }
                };
                window.speechSynthesis.speak(utterance);
            }
        }

        $('#practiceofficevisitreasonid').on('change', function () {
            if (speechToTextEnabled) {
                var selectedOption = $(this).find('option:selected');
                var selectedText = selectedOption.text();
                if (selectedText.trim().length > 0) {
                    sayIt(selectedText, 'en-US', selectedOption);
                }
            }
        });

        $('#practiceofficevisitreasonnotes').on('mouseup keyup', function () {
            var selectedText = window.getSelection().toString();
            if (selectedText.length > 0) {
                $('#read-textarea').show();
            } else {
                $('#read-textarea').hide();
            }
        });

        $('#read-textarea').click(function () {
            var textareaContent = window.getSelection().toString();
            if (textareaContent) {
                sayIt(textareaContent, 'en-US', '#practiceofficevisitreasonnotes');
            }
        });

   

        function interpretElement(event) {
            if (speechToTextEnabled) {
                var text = event.target.textContent;
                sayIt(text, 'en-US', event.target);
            }
        }

        function attachListeners() {
            $('h2, h3, p, h1, h4, h5, h6, span').each(function () {
                $(this).on('click', interpretElement);
            });


            $('select[id$="practiceofficevisitreasonid"]').on('change', function () {
                if (speechToTextEnabled) {
                    var selectedOption = $(this).find('option:selected');
                    var selectedText = selectedOption.text();
                    if (selectedText.trim().length > 0) {
                        sayIt(selectedText, 'en-US', selectedOption);
                    }
                }
            });

            $('textarea[id$="practiceofficevisitreasonnotes"]').on('mouseup keyup', function () {
                var selectedText = window.getSelection().toString();
                if (selectedText.length > 0) {
                    $('#read-textarea').show();
                } else {
                    $('#read-textarea').hide();
                }
            });
        }

        preloadVoices().then(() => {
            attachListeners();
            updateTextSizeIndicator(textSizeIncrements);
            updateBrightnessIndicator(currentBrightnessIndex);
            updateContrastIndicator(currentContrastIndex);
        });

        $('#read-textarea').hide();

        function maintainWidgetPosition() {
            $('#widget').css({
             
                'z-index': '9999',
                'transform': 'none'
            });
        }
        $('#increase-text, #grayscale, #brightness, #contrast, #reset, #read-aloud').click(function () {
            maintainWidgetPosition();
        });
        
    });

    /*------------------------------------------------------------------------------------------------------------*/

    document.getElementById('customFullscreenToggle').addEventListener('click', function () {
        const originalButton = document.getElementById('<%= buttogglefullscreen.ClientID %>');
          if (originalButton) {
              originalButton.click();
          }
    });

    function resetAccessibilitySettings() {
        textSize = 1;
        textSizeIncrements = 0;
        currentBrightnessIndex = 0;
        currentContrastIndex = 0;
        grayscaleApplied = false;
        speechToTextEnabled = false;
        $('.content').css('font-size', '1em');
        $('h2').css('font-size', '1.5em');
        $('.content').css('filter', 'none');
        updateTextSizeIndicator(textSizeIncrements);
        updateBrightnessIndicator(currentBrightnessIndex);
        updateContrastIndicator(currentContrastIndex);
        maintainWidgetPosition();
        $('#read-textarea').fadeOut();
    }

    function doCheckInSubmit() {
        resetAccessibilitySettings();
        MBA.PracticeOfficeKioskCommon.fnCheckIn('<%=Spedmon.PracticeOfficeCommon.BODY_ID_KIOSK%>');
    };

    /*------------------------------------------------------------------------------------------------------------*/

    function doCheckInClear() {
        resetAccessibilitySettings();
        MBA.PracticeOfficeKioskCommon.fnClearCheckInForm('<%=Spedmon.PracticeOfficeCommon.BODY_ID_KIOSK%>');
    };

    /*------------------------------------------------------------------------------------------------------------*/

    $(window).on('load', function () {

        let kioskOptsObj = {
              PARM_NAME_CLIENT_ID:'<%=Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_GROUP_SVC_CLASS_NAME_ID:'<%=Constants.PARM_GRP_SVC_CLS_NME_ID%>'
            , PARM_NAME_SITE_ID:'<%=Constants.PARM_SITE_ID%>'
            , PARM_NAME_STUDENT_ID:'<%=Constants.PARM_STUDENT_ID%>'
            , PARM_NAME_PRACTICE_OFFICE_VISIT_REASON_ID: '<%=Constants.PARM_PRACTICE_OFFICE_VISIT_REASON_ID%>'
            , PARM_NAME_PRACTICE_OFFICE_VISIT_REASON_NOTES:'<%=Constants.PARM_PRACTICE_OFFICE_VISIT_REASON_NOTES%>'
            , CTRL_ID_BUT_PRACTICE_OFFICE_CHECK_IN_CLEAR: 'checkin-clear'
            , CTRL_ID_BUT_PRACTICE_OFFICE_CHECK_IN_SUBMIT: 'checkin-submit'
            , checkInFromKioskUrl: '<%=Spedmon.PracticeOfficeVisits.URL_SVC_CHECK_IN_FROM_KIOSK_BASE()%>'
        };

        MBA.PracticeOfficeKioskCommon.fnSetup('<%=Spedmon.PracticeOfficeCommon.BODY_ID_KIOSK%>',kioskOptsObj);

        $('#checkin-clear').on('click', function () {
            doCheckInClear();
        });

        $('#checkin-submit').on('click', function () {
            doCheckInSubmit();
        });
    });

    /*------------------------------------------------------------------------------------------------------------*/

</script>

<%}%>