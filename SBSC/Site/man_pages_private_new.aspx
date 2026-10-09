<%@Page Language="C#" CodeBehind="man_pages_private_new.aspx.cs" Inherits="Spedmon.ManPagesPrivateNew" %>

<%/************************/%>
<%/* Man Pages - New      */%>
<%/************************/%>

<div class="container my-4">
 
 
</div>


<div class="container-fluid">
  
  <div class="row">

      <div class="col-12 col-lg-2 pr-0">
          <div id="man_page_selections"></div>    
      </div>

      <div class="col-12 col-lg-10 pl-0">
        <iframe id="man_page_selection" name="man_page_selection" src="about:blank" allowfullscreen></iframe>
      </div>
  </div>
</div>

<script type="text/javascript" charset="utf-8">

;(function($) {

  var $tkn = '<%=tkn%>';
  var $loadMembersActionURL = "man_pages.asmx/viewContentSel";
  var fnAllDoneGotoNextPage = function () {
      var nextPage = '<%=urlNextPage%>';
      $.spedmonWebUI.gotoURL(nextPage);
  }
  var $fnNoPendingUserResponse = function (wgt) {
      fnAllDoneGotoNextPage();
  };
  var $fnNoSelectionsReturned = function (wgt) {
      fnAllDoneGotoNextPage();
  }

  var $fnLoadMembersRequestData = function(wgt) {
        var reqData = '{"term":"", '+
                      ' "<%=Spedmon.ManPages.PARM_USER_HAS_READ%>": "N", ' +
                      ' "<%=Spedmon.ManPages.PARM_WELCOME_NEW_USER%>":  "Y" ' +
    '}';
    return reqData;
  };


  var $logUserResponseActionURL = "man_pages.asmx/logUserResponse";

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
  });

  $('#man_page_selections').contentselections({
    contentSelectionID: 'man_page_selection'
    , contentSelectionName: 'man_page_selection'
    , tkn: $tkn
    , loadMembersActionURL: $loadMembersActionURL
    , fnLoadMembersRequestData: $fnLoadMembersRequestData
    , fnNoPendingUserResponse: $fnNoPendingUserResponse
    , fnNoSelectionsReturned: $fnNoSelectionsReturned
    , allowFilterList:false
  });

})(jQuery);

</script>
