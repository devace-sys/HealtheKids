$(document).ready(function() {
  if ($.spedmonWebUI.pageIsInAFrame == true) {
    if ($.spedmonWebUI.clientMessageCode == $.spedmonWebUI.ret.WAIT) { return; }
    if ($.spedmonWebUI.clientMessageCode == $.spedmonWebUI.ret.SESSION_EXPIRE) { window.top.location = $.spedmonWebUI.home_public; }
  }
});
