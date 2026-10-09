$(document).ready(function() {
  
  /* Resets on open and close */
  
  $('#app-bar-nav-toggle').click(function(){
    $('ul.navigation-sub').hide();
  });
    
  /* Find all of our sub menu anchors */
  
  $('ul.navigation-sub').prev('a').addClass('navigation-sub-toggle');
  
  /* Define show/hide */
    
  $('a.navigation-sub-toggle').click(function( event ) {
	event.preventDefault();
    var $ulSub         = $(this).next('ul.navigation-sub');
	var $ulSubParentLi = $($ulSub).parent('li');
	$($ulSubParentLi).siblings('li').children('ul.navigation-sub').slideUp();
	$($ulSub).slideToggle();	
   });

});
