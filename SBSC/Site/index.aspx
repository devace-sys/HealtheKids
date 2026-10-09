<%@Page Language="C#" AutoEventWireup="true" 
CodeBehind="index.aspx.cs" 
Inherits="Spedmon.index" 
subTitle="Login"%>

<%if(displayTransitionMessage == true){ /* Set to false to test */%>
<div class="alert alert-light alert-dismissible fade show mt-0">
<h4 class="alert-heading text-center" style="color:#1a2a55">
UPDATE: SpEdCare is now Health e Kids
<button type="button" class="close" data-dismiss="alert" aria-label="Close" style="color:#1a2a55"><span aria-hidden="true" style="color:#1a2a55">&times;</span></button>
</h4>
<p class="text-center" style="color:#1a2a55">
Our EHR login address has changed to <a class="alert-link" style="color:#1a2a55" href="https://www.healthekids.com">www.healthekids.com</a> Please update your bookmarks and saved links. Your existing username, password, and data remain unchanged.
</p>
</div> <!-- alert -->
<%}%>

<div id="pg-content"> <!-- pg-content -->
        <div id="pg-content-left">                    
                 <div id="loginformcont">               

                   <div class="login-card-header">
                     <svg class="login-card-header-hex" viewBox="0 0 400 108" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">
                       <g fill="none" stroke="rgba(255,255,255,0.09)" stroke-width="1.4">
                         <polygon points="90,74 75,48 45,48 30,74 45,100 75,100"/>
                         <polygon points="390,10 375,-16 345,-16 330,10 345,36 375,36"/>
                         <polygon points="358,80 347,61 325,61 314,80 325,99 347,99"/>
                       </g>
                     </svg>
                     <img class="login-card-logo" src="web-ui-3/custom/css/enhancedImages/healthe-kids-logo.svg" alt="HealtheKids" />
                   </div>

                   <div class="login-card-badge">
                     <div class="login-card-badge-inner"></div>
                   </div>

                   <div id="heading">
                    Welcome <wbr>to <wbr><span id="pg-app-name"><%=Spedmon.Constants.APPLICATION_NAME %></span>
                  </div>                 
                 
                     <form id="loginform" action="<%=loginLink%>" method="post">
                        <input type="hidden" id="<%=MBA.Constants.PARM_GOTO_PAGE%>" name="<%=MBA.Constants.PARM_GOTO_PAGE%>" value="<%=gotoPage%>"/>
                        <div class="field input input-field">
                            <svg viewBox="0 0 16 16" fill="currentColor" height="16" width="16" xmlns="http://www.w3.org/2000/svg" class="input-icon">
                                <path d="M13.106 7.222c0-2.967-2.249-5.032-5.482-5.032-3.35 0-5.646 2.318-5.646 5.702 0 3.493 2.235 5.708 5.762 5.708.862 0 1.689-.123 2.304-.335v-.862c-.43.199-1.354.328-2.29.328-2.926 0-4.813-1.88-4.813-4.798 0-2.844 1.921-4.881 4.594-4.881 2.735 0 4.608 1.688 4.608 4.156 0 1.682-.554 2.769-1.416 2.769-.492 0-.772-.28-.772-.76V5.206H8.923v.834h-.11c-.266-.595-.881-.964-1.6-.964-1.4 0-2.378 1.162-2.378 2.823 0 1.737.957 2.906 2.379 2.906.8 0 1.415-.39 1.709-1.087h.11c.081.67.703 1.148 1.503 1.148 1.572 0 2.57-1.415 2.57-3.643zm-7.177.704c0-1.197.54-1.907 1.456-1.907.93 0 1.524.738 1.524 1.907S8.308 9.84 7.371 9.84c-.895 0-1.442-.725-1.442-1.914z"></path>
                            </svg>
                            <MBAWU3:TextBox ID="uid" Name="uid" Title="Enter your user name" LabelText="User Name" Required="true" Autofocus="true" Autocomplete="on" runat="server" />
                        </div>
                        <div class="field input input-field">
                            <svg viewBox="0 0 16 16" fill="currentColor" height="16" width="16" xmlns="http://www.w3.org/2000/svg" class="input-icon">
                                <path d="M8 1a2 2 0 0 1 2 2v4H6V3a2 2 0 0 1 2-2zm3 6V3a3 3 0 0 0-6 0v4a2 2 0 0 0-2 2v5a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2z"></path>
                            </svg>
                            <MBAWU3:PasswordBox ID="pwd" Name="pwd" Title="Enter your password" LabelText="Password" Required="true" Autocomplete="off" runat="server" />
                        </div>
                        <button type="submit" class="button-signin">
                            <span class="text-button">Sign in</span>
                        </button>
                    </form>

                    <div id="otheroptionscont">
                      <a href="<%=forgotMyPasswordLink%>" class="other-option-button">Password Reset</a>
                      <a href="<%=requestAccountLink%>" class="other-option-button">Request Account</a>
                    </div>

                </div>            
        </div> <!-- pg-content-left-->
        <div id="pg-content-right"> <!-- pg-content-right-->
            <div class="grid">
                <ul id="hexGrid">
                    <li class="hex">
                        <div class="hexIn">
                            <a class="hexLink" href="#">
                                <div class="linkWrapper">
                                    <div class='imgtwo' style='background-image:url("web-ui-3/custom/css/enhancedImages/girls-smiling.png");'></div>
                                    <div class='imgtwo login-imgtwo-4k' style='background-color: #f29a29; background-image:url("web-ui-3/custom/css/enhancedImages/boy-with-glasses-orange-bg.png");'></div>
                                    <h1 class="demo1"></h1>
                                    <p class="demo2"></p>
                                </div>
                            </a>
                        </div>
                    </li>
                    <li class="hex">
                        <div class="hexIn">
                            <a class="hexLink" href="#">
                                <div class="linkWrapper">
                                    <div class='imgtwo' style='background: rgb(233,117,0);
background-image: url("web-ui-3/custom/css/enhancedImages/healthe-kids-mark-orange-bg.svg"), linear-gradient(110deg, rgba(233,117,0,1) 8%, rgba(252,139,1,1) 16%, rgba(242,154,41,1) 32%, rgba(237,133,15,1) 39%, rgba(238,123,0,1) 64%, rgba(241,188,118,1) 100%);  background-repeat: no-repeat; background-position: center, 0% 45%; background-size: 45% auto, contain '></div>
                                    <h1 class="demo1"></h1>
                                    <p class="demo2"></p>
                                </div>
                            </a>
                        </div>
                    </li>
                    <li class="hex">
                        <div class="hexIn">
                            <a class="hexLink" href="#">
                                <div class="linkWrapper">
                                    <div class='imgtwo' style='background-image:url("web-ui-3/custom/css/enhancedImages/laptop.png");'></div>
                                    <h1 class="demo1"></h1>
                                    <p class="demo2">  </p>
                                </div>
                            </a>
                        </div>
                    </li>
                    <li class="hex">
                        <div class="hexIn">
                            <a class="hexLink" href="#">
                                <div class="linkWrapper">
                                    <div class='imgtwo' style='background-color: #f29a29; background-image:url("web-ui-3/custom/css/enhancedImages/boy-with-glasses-orange-bg.png");'></div>
                                    <div class='imgtwo login-imgtwo-4k' style='background-image:url("web-ui-3/custom/css/enhancedImages/girls-smiling.png");'></div>
                                    <h1 class="demo1"></h1>
                                    <p class="demo2"></p>
                                </div>
                            </a>
                        </div>
                    </li>
                    <li class="hex">
                        <div class="hexIn">
                            <a class="hexLink" href="#">
                                <div class="linkWrapper">
                                    <div class='imgtwo' style='background-color: #1a2a55; background-image:url("web-ui-3/custom/css/enhancedImages/healthe-kids-logo.svg"); background-repeat: no-repeat; background-position: center; background-size: 85%;'></div>
                                    <h1 class="demo1"></h1>
                                    <p class="demo2">  </p>
                                </div>
                            </a>
                        </div>
                    </li>
                </ul>
            </div>
        </div>
        <div class="login-deco-hex login-deco-hex-1"></div>
        <div class="login-deco-hex login-deco-hex-2"></div>
        <div class="login-deco-hex login-deco-hex-3"></div>
        <div class="login-deco-hex login-deco-hex-4"></div>
        <div class="login-deco-hex login-deco-hex-5"></div>
        <div class="login-deco-hex login-deco-hex-6"></div>
        <div class="login-edge-hex login-edge-hex-mob login-edge-hex-mob-1"></div>
        <div class="login-edge-hex login-edge-hex-mob login-edge-hex-mob-2"></div>
        <div class="login-edge-hex login-edge-hex-mob login-edge-hex-mob-3"></div>
        <div class="login-edge-hex login-edge-hex-mob login-edge-hex-mob-4"></div>
        <!--
        <a class="login-help-hex" href="#">
          <div class="login-help-hex-inner">
            <div>
              <div class="login-help-hex-title">Need help?</div>
              <div class="login-help-hex-sub">Contact support</div>
            </div>
            <svg class="login-help-hex-icon" viewBox="0 0 24 24" fill="none" stroke="#ffffff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg">
              <path d="M4 14 v-2 a8 8 0 0 1 16 0 v2"/>
              <path d="M18 19 a2 2 0 0 1 -2 2 h-3"/>
              <rect x="2" y="14" width="4" height="6" rx="1"/>
              <rect x="18" y="14" width="4" height="6" rx="1"/>
            </svg>
          </div>
        </a>
        -->
</div> <!-- container -->