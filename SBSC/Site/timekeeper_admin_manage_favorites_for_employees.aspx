<%@ Page Language="C#" CodeBehind="timekeeper_admin_manage_favorites_for_employees.aspx.cs" Inherits="Spedmon.TimekeeperAdminManageFavoritesForEmployees" %>

<div class="row">

 <div class="col-12 col-lg-2">

  <div id="man_page_selections-container" class="ui-mba-content-selection-container">
      <div id="man_page_selections-header" class="ui-mba-content-selection-header">
          <div class="ui-mba-content-selection-header-r1">
              <span id="man_page_selections-title" class="ui-mba-content-selection-header-r1-title"></span>
              <span class="ui-mba-content-selection-header-r1-controls mb-3">
                  <button title="Toggle Open" class="ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only ui-mba-content-selection-header-r1-control header-r1-controls-btn-toggle-open d-lg-none"
                      role="button" aria-disabled="false">
                      <span class="ui-button-icon-primary ui-icon ui-icon-arrow"></span>
                      <span class="ui-button-text">Toggle Open</span>

                  </button>

              </span>

          </div>

      </div>
      <div id="man_page_selections-content" class="ui-mba-content-selection-content">
          <div id="man_page_selections" class="ui-mba-content-selection-content-list slick-slider slick-vertical">
              <% foreach (MBA.Record r in r_db_1.records) { %>
              
                  <div class="ui-mba-content-selection-content-list-item slick-slide slick-current slick-active" data-slick-index="0" aria-hidden="false" tabindex="0" style="width: 240px;">
                      <a
                          href="#"
                          class="ui-mba-content-selection-content-list-item ui-button ui-widget ui-corner-all ui-button-text-only"
                          role="button" aria-disabled="false" tabindex="0">
                          <span class="ui-button-text"><p><%= r.fields[1].value %></p></span>

                      </a>

                  </div>
              <% } %>   


          </div></div></div></div>

<script type="text/javascript">




  $('#man_page_selections').slick(
        {
            vertical: true, slidesToShow: 9.5, slidesToScroll: 9,
            infinite: false, draggable: false, touchMove: false, swipe: false, swipeToSlide: false,
            cssEase: 'linear', useTransform: false,
            prevArrow: '<button class="slick-prev slick-arrow rounded-circle slick-disabled" type="button"' +
                'style = "display: inline-block;" ><i class="fa-2x fa fa-caret-up"></i></button>',
            nextArrow: '<button class="slick-next slick-arrow rounded-circle slick-disabled" type="button"' +
                'style = "display: inline-block;" ><i class="fa-2x fa fa-caret-down"></i></button>'
        }
  );

  $('.ui-mba-content-selection-content-list-item a').click(function() {
    $('iframe')[0].contentWindow.$('#groups-search-term').val( $('.ui-button-text', $(this) ).text() ).trigger('keyup');
    $('.ui-mba-content-selection-content-list-item a').removeClass('tab-selected');
    $(this).addClass('tab-selected');
  });



</script>

 <div id="iframe-container" class="col-12 col-lg-10">

<span style="width:100%;display:inline-block;text-align:end;padding-right:12px;">
<button class="ui-spedmon-box-inline-ctrl ui-button ui-state-default ui-corner-all ui-button-text-only" id="toggle_manage_tasks" type="button" role="button" aria-disabled="false"><span class="ui-button-text">Tasks</span></button>
<button class="ui-spedmon-box-inline-ctrl ui-button ui-state-default ui-corner-all ui-button-text-only" id="toggle_manage_clients" type="button" role="button" aria-disabled="false"><span class="ui-button-text">Clients</span></button>

<script type="text/javascript">

  $('#toggle_manage_tasks').click(function() {
        $('iframe').remove();
        $('#iframe-container').append('<iframe style="margin: 4px; height:100%; width:100%" ' +
          'src="partial_timekeeper_admin_manage_favorite_tasks_for_employees_dragdrop.aspx?tkn=<%=tkn%>" />'
        );
  });

  $('#toggle_manage_clients').click(function() {
        $('iframe').remove();
        $('#iframe-container').append('<iframe style="margin: 4px; height:100%; width:100%" ' +
          'src="partial_timekeeper_admin_manage_favorite_clients_for_employees_dragdrop.aspx?tkn=<%=tkn%>" />'
        );
  });

</script>
</span>
  
  <iframe style="margin: 4px; height:100%; width:100%" src="partial_timekeeper_admin_manage_favorite_tasks_for_employees_dragdrop.aspx?tkn=<%=tkn%>" />
 </div>

</div>

