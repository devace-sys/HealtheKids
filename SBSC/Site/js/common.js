/***************************************************************************
 * common */
/**
 * Javascript used on every WebUI page 
 ***************************************************************************/
  
$(function(){	

// Navigation

$('#navigation li').hover(function(){$(this).addClass('hover');}, function() {$(this).removeClass('hover');});	

// Contact Us Link

$('#dialogContactLink').click(function(){$.spedmonWebUI.msgContactUs();return false;});

// Setup help link

//$('#dialogHelpLink').click(function(){$.spedmonWebUI.msgContactUs();return false;});

});



