/*#############################################################################################################################*/

String.prototype.format = function () {

/***************************************************************************
 * String.format()
/**
 * Courtesy of http://www.theresapatternforthat.com/2011/02/03/string-format-in-javascript/
 * 
 ***************************************************************************/

  /* Copy this, the string, to a modifiable var */
  
  var formatted = this;
 
  /* For each argument search for place holder for it */
  
  for (var i = 0; i < arguments.length; i++) {

   /* If a place holder exists, replace with the value */
   var ptrn = '\\[' + i +'\\]';
   formatted = formatted.replace(RegExp(ptrn,'g'), arguments[i]);
  }

  return formatted;
};

/*#############################################################################################################################*/
 

/***************************************************************************
 * closeWindow()
/**
 * Allows you to close a window not opened by scripting
 *
 * Use: 
 *
 * <a href="javascript:closeWindow();">Close Window</a>
 * 
 * Courtesy of 
 * http://www.yournewdesigner.com/css-experiments/javascript-window-close-firefox.html
 ***************************************************************************/
 
function closeWindow() {
  window.open('','_parent','');
  window.close();
}

/*#############################################################################################################################*/

/***************************************************************************
 * browserSupportsInputType
/**
 * Tests if browser supports input type 
 * Based on code courtesy of http://diveintohtml5.info/everything.html
 * 
 * @param  inputType     
 ***************************************************************************/

function browserSupportsInputType (inputType) {
  var i = document.createElement('input');
  i.setAttribute('type', inputType);
  return i.type !== 'text';
}

/*#############################################################################################################################*/
