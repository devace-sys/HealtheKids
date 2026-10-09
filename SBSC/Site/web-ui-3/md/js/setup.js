;window.onload = function() {

  var elmAppBar    = document.getElementById('app-bar');
  var elmAppDrawer = document.getElementById('app-drawer');
  var elmAppContent = document.getElementById('app-content');
  var pageContent  = document.getElementById('page-content');

  var elemFilesIcon     = document.getElementById('files-icon');
  var elemFilesIconMenu = document.getElementById('files-icon-menu');
  
  var elemMyAccountIcon     = document.getElementById('my-account-icon');
  var elemMyAccountIconMenu = document.getElementById('my-account-icon-menu');
  var elemMyAccountIconMenuAvatarLi = document.getElementById('my-account-avatar-list-li');
  
  /* Menu */
  if ((elmAppBar) && (elmAppDrawer) && (pageContent)) { 
    const appBar    = new mdc.topAppBar.MDCTopAppBar(elmAppBar);
    const appDrawer = new mdc.drawer.MDCDrawer(elmAppDrawer);
   // appBar.setScrollTarget(pageContent);
    appBar.listen('MDCTopAppBar:nav', function() {
      appDrawer.open = !appDrawer.open;
    });
	 
	 pageContent.addEventListener('click', function (event) {     
	   if (appDrawer.open) appDrawer.open = false;	   
    });
  };
  
  const textFields = [].map.call(document.querySelectorAll('.mdc-text-field'), function(el) {
    return new mdc.textField.MDCTextField(el);
  });
  
  /* Files app bar menu creation and event wire up */
  
  if ((elemFilesIconMenu) && (elemFilesIcon))
  {
    const filesIconMenu = new mdc.menuSurface.MDCMenuSurface(elemFilesIconMenu);
	filesIconMenu.open = false;
	filesIconMenu.setMenuSurfaceAnchorElement(elemFilesIcon);
	elemFilesIcon.addEventListener('click', function (event) {     
	 filesIconMenu.open = !filesIconMenu.open;
    });
  }
  
  /*My account app bar menu creation and event wire up */

  if ((elemMyAccountIconMenu) && (elemMyAccountIcon) && (elemMyAccountIconMenuAvatarLi))
  {
    const myAccountIconMenu = new mdc.menuSurface.MDCMenuSurface(elemMyAccountIconMenu);
	myAccountIconMenu.open = false;
	myAccountIconMenu.setMenuSurfaceAnchorElement(elemMyAccountIcon);
	elemMyAccountIcon.addEventListener('click', function (event) {     
	 myAccountIconMenu.open = !myAccountIconMenu.open;
    });
	elemMyAccountIconMenuAvatarLi.addEventListener('click',function(event) {
	  myAccountIconMenu.open = !myAccountIconMenu.open;
	});
  }

};