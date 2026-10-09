<%@Page Language="C#" CodeBehind="man_pages_private.aspx.cs" Inherits="Spedmon.ManPagesPrivate" %>

<div id="firstsection-orange" class="container-fluid">

<div class="row" id="search-splash" >
  
  <div class="d-xs-none d-sm-none d-md-none d-lg-flex col-lg-4">


  </div> <!-- col -->

  <div class="col-lg-4 col-12 align-content-center">

    <div class="h-100 d-flex flex-column justify-content-between">
    
    <div></div> <!-- placeholder -->
    
    <div class="help-box-container">     
    <div class="d-flex flex-column justify-content-center help-box help-box-info help-box-info-w-search w-100">
        
        <Spedmon:ComboBox
            ID                              = "dropdownSelectPage"
            name                            = "dropdownSelectPage"
            title                           = "Type a topic to learn more"
            afterRenderItem                 = "return renderSearchTooltip(item,$renderedli);"
            dataURL                         = "newsletter_pages.asmx/viewSel"
            selectAll                       = "false"
            singleSelectClearAfterSelection = "true"            
            runat                           = "server">
        </Spedmon:ComboBox>
 
      <div><%=needMoreHelpContactContent%></div>

      </div> <!-- search -->
      </div> <!-- help box container -->

     <%=needMoreHelpContactContent2%>

    </div> <!-- h100 -->
    </div> <!-- col -->

  <div id="col3-hex-herosplash" class="col-lg-4 col-12">

    <div class="d-lg-block d-none">

      <Spedmon:Img cssClass="big-splash" ID="bigSplash" runat="server"/>

    </div> <!-- big splash container -->

    <div class="d-lg-none d-block">

      <Spedmon:Img cssClass="cropped-splash" ID="croppedSplash" runat="server"/>

    </div> <!-- cropped splash container -->

    </div> <!-- col -->

</div> <!-- row -->

</div> <!-- container -->

<div id="secondsection-blue" class="container-fluid">
  <div class="row">
      <div id="man_page_selections_col" class="col-12 col-lg-2">
      <div id="man_page_selections"></div>
      </div> <!-- col -->

      <div id="man_page_selection_col" class="col-12 col-lg-10">
        <iframe id="man_page_selection" name="man_page_selection" src="about:blank" allowfullscreen></iframe>
      </div> <!-- col -->
  </div> <!-- row -->
</div> <!-- container -->

<script type="text/javascript" charset="utf-8">

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>    


let $IFRAME_MAN_PAGE_SELECTION = null;

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>    

function renderSearchTooltip(item, $renderedli) {    
  $renderedli = $("<li></li>")
    .data("item.autocomplete", item)
    .append("<a><span class='sellabel'>" + item.label + "</span></a>");

  $($renderedli).attr('title', item.context1);
  
  return $renderedli;
};

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>    

function firePageChangeEvent(itm) {
    
  /* Clear tab selection for resource library selection*/

  $('#man_page_selections').children('div.ui-mba-content-selection-content-list-item').children('a.ui-mba-content-selection-content-list-item').removeClass('tab-selected');

  /* If the item is a manpage then add the selected class to the appropriate tab */

  if (itm.recData1 == 'manpage')
  {
    $('#ui-mba-content-selection-content-list-item-a-data-rec-id-' + itm.recData3).addClass('tab-selected');
  }

  /* Load content */

  $($IFRAME_MAN_PAGE_SELECTION).attr('src', itm.recData2);

  /* Scroll into view */

  MBA.ComponentCommon.fnScrollElementIntoView($IFRAME_MAN_PAGE_SELECTION, true); /* Scroll into view */
  
};

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>    

$(window).on('load', function () {

$IFRAME_MAN_PAGE_SELECTION    = $('#man_page_selection');

var $tkn                      = '<%=tkn%>';
var $loadMembersActionURL     = "man_pages.asmx/viewContentSel";
var $logUserResponseActionURL = "man_pages.asmx/logUserResponse";

var $fnLoadMembersRequestData = function (wgt) {
  var reqData = '{"term":"", '+
              ' "<%=Spedmon.ManPages.PARM_USER_HAS_READ%>": "", ' +
              ' "<%=Spedmon.ManPages.PARM_WELCOME_NEW_USER%>":  "" ' +
              '}';
  return reqData;
};

var $fnLogUserResponseRequestData = function(wgt, recid, rtype) {

    var reqData = '{'
                + '"recid":"' + recid + '"'
                + ',"responsetype":"' + rtype + '"'
                + '}';
    return reqData;
};

$('#man_page_selection').contentselection({
    contentSelectionsID: 'man_page_selections'
    , logUserResponseActionURL: $logUserResponseActionURL
    , fnLogUserResponseRequestData: $fnLogUserResponseRequestData
    , tkn: $tkn
    , allowFilterList :false
});

$('#man_page_selections').contentselections({
    contentSelectionID: 'man_page_selection'
    , contentSelectionName: 'man_page_selection'
    , recid: '<%=((preSelectedAnnouncementSpecified == false) ? "" : this.recid)%>'
    , tkn: $tkn
    , loadMembersActionURL: $loadMembersActionURL
    , fnLoadMembersRequestData: $fnLoadMembersRequestData
    , allowFilterList: false
    , autoLoadFirstListItem: <%=((preSelectedAnnouncementSpecified == true) ? "false" : "true")%>
});


<%if(preSelectedAnnouncementSpecified == true) {%>
    MBA.ComponentCommon.fnScrollElementIntoView($IFRAME_MAN_PAGE_SELECTION, true); /* Scroll into view */
<%}%>
    
let $fa_searchicon = $('<span class="input-group-append"><span class="btn btn-outline-secondary" ><i class="fa fa-search"></i></span></span>');
$('#dropdownSelectPage_selection_cont').append($fa_searchicon);

$('#dropdownSelectPage').on('spedmoninputdata', function (e) {
  firePageChangeEvent(e.dataitem);        
});

});

<%/*-------------------------------------------------------------------------------------------------------------------------------*/%>    

</script>

<%/* Including for pcal staff only at this point in time 
   * Vistor object info here https://developer.tawk.to/jsapi/#SecureMode
   */%>

<% if ( this.uInfo.pcalStaff ) { %>
  <script type="text/javascript">
    window.Tawk_API = window.Tawk_API || {};
    window.Tawk_API.visitor = {
        name  : '<%= this.rd.wu.usr.name + @" – " + this.rd.wu.usr.roleName  %>'
      , email : '<%= this.rd.wu.usr.email %>'
      , hash  : '<%= MBA.Credential.getHMACSignature( Spedmon.Constants.TAWK_TO_JS_API_KEY, this.rd.wu.usr.email)  %>'
    }; 
  </script>
  <script type="text/javascript" src="js/components/tawkwidget.min.js"></script>
<% } %>