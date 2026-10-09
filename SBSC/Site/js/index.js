/***************************************************************************
* index */
/**
* Script specific to the public home page (index).
* This script sets up the login form, title, etc.
* This is included as part of the pages constructor.
* Most of this script was part of the practi-cal static site.
***************************************************************************/
$(function() {

    // Typography for index

    Cufon.replace('#index h2', { fontFamily: "EraserDust" })('.secondary h2', { fontFamily: "Gotham" })('#index h3', { fontFamily: "Gotham" })('#index h4', { fontFamily: "Gotham" });
        
    // Setup login form	

    $('#uid').defaultValue({ value: "Username" });
    $('#pwd').after('<input type="text" id="pwd-text" class="password" name="pwd-text" />').hide();
    $('#pwd-text').show();
    $('#pwd-text').val('Password');
    $('#pwd-text').focus(function() {
        $('#pwd-text').hide();
        $('#pwd').show();
        $('#pwd').focus();
    });

    $('#pwd').blur(function() {
        if ($('#pwd').val() == '') {
            $('#pwd-text').show();
            $('#pwd').hide();
        }
    });
    
});