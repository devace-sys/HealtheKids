$(document).ready(function() {
  if ($.spedmonWebUI3.pageIsInAFrame == true) {
    if ($.spedmonWebUI3.clientMessageCode == $.spedmonWebUI3.ret.WAIT) { return; }
    if ($.spedmonWebUI3.clientMessageCode == $.spedmonWebUI3.ret.SESSION_EXPIRE) { window.top.location = $.spedmonWebUI3.home_public; }
  };
});
