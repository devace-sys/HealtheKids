$(document).ready(function() {
  
  $('button.app-notification-dismiss').click (function(event) {
    event.preventDefault();
	var $parentLi = $(this).parent('li.app-notification');
	$($parentLi).hide();
  });

});
