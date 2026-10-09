;var MBA = (MBA || {});

/*#############################################################################################################################################################*/

/**
 * @namespace    MBA.PdfCommon
 * @memberof     MBA
 * @summary      Static methods used on a screen 
 * @description  Static methods used on a screen
 * @requires     jQuery, jQueryUI, html2Canvas, purify, jsPDF, PDF-Lib, fontkit
 */

MBA.PdfCommon = (function ($)
{

'use strict';

const { jsPDF }                                 = window.jspdf;                          /* For convienence */

const CSS_CLASS_HTML_TO_PDF_ELEMENT_REPLACEMENT = 'html-to-pdf-element-replacement';

const FONT_NAME_ABEL_REGULAR                    = 'abelRegular';
const FONT_URL_ABEL_REGULAR                     = 'css/Abel-Regular-400.ttf';

const FONT_NAME_ROBOTO_CONDENSED_REGULAR        = 'robotoCondensedRegular';
const FONT_URL_ROBOTO_CONDENSED_REGULAR         = 'css/roboto-condensed-regular.ttf';

const FONT_NAME_ROBOTO_CONDENSED_BOLD           = 'robotoCondensedBold';
const FONT_URL_ROBOTO_CONDENSED_BOLD            = 'css/roboto-condensed-bold.ttf';

const FONT_NAME_ROBOTO_CONDENSED_ITALIC         = 'robotoCondensedItalic';
const FONT_URL_ROBOTO_CONDENSED_ITALIC          = 'css/roboto-condensed-italic.ttf';

const FONT_NAME_ROBOTO_CONDENSED_BOLD_ITALIC    = 'robotoCondensedBoldItalic';
const FONT_URL_ROBOTO_CONDENSED_BOLD_ITALIC     = 'css/roboto-condensed-bold-italic.ttf';

const FONT_STYLE_NORMAL      = 'normal';
const FONT_STYLE_BOLD        = 'bold';
const FONT_STYLE_ITALIC      = 'italic';
const FONT_STYLE_BOLD_ITALIC = 'bolditalic';

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCreateJsPdfDoc
 * @private
 * @summary      Creates instance of jsPDF document and embeds our standard fonts
 * @description  Creates instance of jsPDF document and embeds our standard fonts
 */

let _fnCreateJsPdfDoc = function () {    

    var doc = new jsPDF('p', 'mm', 'letter');

    doc.addFont(FONT_URL_ROBOTO_CONDENSED_REGULAR,     FONT_NAME_ROBOTO_CONDENSED_REGULAR,     FONT_STYLE_NORMAL);
    doc.addFont(FONT_URL_ROBOTO_CONDENSED_BOLD,        FONT_NAME_ROBOTO_CONDENSED_BOLD,        FONT_STYLE_BOLD);
    doc.addFont(FONT_URL_ROBOTO_CONDENSED_ITALIC,      FONT_NAME_ROBOTO_CONDENSED_ITALIC,      FONT_STYLE_ITALIC);
    doc.addFont(FONT_URL_ROBOTO_CONDENSED_BOLD_ITALIC, FONT_NAME_ROBOTO_CONDENSED_BOLD_ITALIC, FONT_STYLE_BOLD_ITALIC);

	return doc;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnCreatePdfLibDocObjAndSupportingObjs
 * @private
 * @summary      Creates instance of PDFLib document, embeds our standard fonts, and returns refs to doc and fonts.
 * @description  Creates instance of PDFLib document, embeds our standard fonts, and returns refs to doc and fonts.
 */

let _fnCreatePdfLibDocObjAndSupportingObjs = async function () {
  let pdfDoc = await PDFLib.PDFDocument.create();
  pdfDoc.registerFontkit(fontkit);

  const robotoCondensedRegularFontBytes = await fetch(FONT_URL_ROBOTO_CONDENSED_REGULAR).then((res) => res.arrayBuffer())
  let robotoCondensedRegularFont = await pdfDoc.embedFont(robotoCondensedRegularFontBytes, { 'customName': FONT_NAME_ROBOTO_CONDENSED_REGULAR });

  const robotoCondensedBoldFontBytes = await fetch(FONT_URL_ROBOTO_CONDENSED_BOLD).then((res) => res.arrayBuffer())
  let robotoCondensedBoldFont = await pdfDoc.embedFont(robotoCondensedBoldFontBytes, { 'customName': FONT_NAME_ROBOTO_CONDENSED_BOLD });

  const robotoCondensedItalicFontBytes = await fetch(FONT_URL_ROBOTO_CONDENSED_ITALIC).then((res) => res.arrayBuffer())
  let robotoCondensedItalicFont = await pdfDoc.embedFont(robotoCondensedItalicFontBytes, { 'customName': FONT_NAME_ROBOTO_CONDENSED_ITALIC });

  const robotoCondensedBoldItalicFontBytes = await fetch(FONT_URL_ROBOTO_CONDENSED_BOLD_ITALIC).then((res) => res.arrayBuffer())
  let robotoCondensedBoldItalicFont = await pdfDoc.embedFont(robotoCondensedBoldItalicFontBytes, { 'customName': FONT_NAME_ROBOTO_CONDENSED_BOLD_ITALIC });

  pdfDoc.setCreator('SpEdCare (www.spedcare.com)');

  let pdfLibObjs = {};
  pdfLibObjs.pdfDoc = pdfDoc;

  pdfLibObjs.robotoCondensedRegularFont    = robotoCondensedRegularFont;
  pdfLibObjs.robotoCondensedBoldFont       = robotoCondensedBoldFont;
  pdfLibObjs.robotoCondensedItalicFont     = robotoCondensedItalicFont;
  pdfLibObjs.robotoCondensedBoldItalicFont = robotoCondensedBoldItalicFont;


  return pdfLibObjs;  
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function    _fnMergeDocuments
 * @summary      Merges each document (stored as a byte array) in pdfLibObjs
 * @param  {Array}  documents  Array of ArrayBuffers (byte arrays)
 * @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer
 */

let _fnMergeDocuments = async function (documents) {
  let pdfLibObjs = await _fnCreatePdfLibDocObjAndSupportingObjs();
  for (let document of documents) {
    let pdfDoc = await PDFLib.PDFDocument.load(document);
    let copiedPages = await pdfLibObjs.pdfDoc.copyPages(pdfDoc, pdfDoc.getPageIndices());
    copiedPages.forEach((page) => pdfLibObjs.pdfDoc.addPage(page));
  };   
  return pdfLibObjs;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAddTextToEachPage
 * @private
 * @summary      Adds additional text to each page 
 * @description  Adds additional text to each page
 * @param  {Object}    pdfLibObjs                   Object containing PDF-Lib document instance and refs to our fonts
 * @param  {Function}  fnGetTextAndCoordinates      Function returning object with text, x,y, and size.
 */

let _fnAddTextToEachPage = function (pdfLibObjs, fnGetTextAndCoordinates) {
    if (!fnGetTextAndCoordinates) {
        fnGetTextAndCoordinates = function (pageSize, pageCtr, totalPages) {
            let textAndCoordinatesObj = {};
            textAndCoordinatesObj.text = '';
            textAndCoordinatesObj.x = 0;
            textAndCoordinatesObj.y = 0;
            textAndCoordinatesObj.size = 10;
            return textAndCoordinatesObj;
        };
    };
    const totalPages = pdfLibObjs.pdfDoc.getPageCount();
    const pages      = pdfLibObjs.pdfDoc.getPages();
    let pageCtr = 1;
    for (let page of pages) {
        let pageSize = page.getSize();
        let textAndCoordinatesObj = fnGetTextAndCoordinates(pageSize, pageCtr, totalPages);
        page.drawText(textAndCoordinatesObj.text, {
              x: (textAndCoordinatesObj.x)
            , y: (textAndCoordinatesObj.y)
            , size: (textAndCoordinatesObj.size)
            , font: pdfLibObjs.robotoCondensedRegularFont
        });    
        pageCtr++;        
    };
    return pdfLibObjs;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAddPageNumberToEachPage
 * @private
 * @summary      Adds page number to each page
 * @description  Adds page number to each page
 * @param  {Object}    pdfLibObjs                   Object containing PDF-Lib document instance and refs to our fonts
 */

let _fnAddPageNumberToEachPage = function (pdfLibObjs) {
    let _fnGetTextAndCoordinates = function (pageSize, pageCtr, totalPages) {
        let textAndCoordinatesObj = {};
        let text = 'Page ' + pageCtr + ' of ' + totalPages;
        const textLen = pdfLibObjs.robotoCondensedRegularFont.widthOfTextAtSize(text, 8);
        const textHgt = pdfLibObjs.robotoCondensedRegularFont.heightAtSize(8);
        textAndCoordinatesObj.text = text;
        textAndCoordinatesObj.x = (pageSize.width - textLen);
        textAndCoordinatesObj.y = textHgt;
        textAndCoordinatesObj.size = 8;
        return textAndCoordinatesObj;
    };
    return _fnAddTextToEachPage(pdfLibObjs, _fnGetTextAndCoordinates);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAddTextToTopRightEachPage
 * @private
 * @summary      Adds text to top right of each page
 * @description  Adds text to top right of each page
 * @param  {Object}    pdfLibObjs                   Object containing PDF-Lib document instance and refs to our fonts
 * @param  {String}    text                         Text to add
 */

let _fnAddTextToTopRightEachPage = function (pdfLibObjs,text) {
    let _fnGetTextAndCoordinates = function (pageSize, pageCtr, totalPages) {
        let textAndCoordinatesObj = {};        
        textAndCoordinatesObj.text = text;
        const textLen = pdfLibObjs.robotoCondensedRegularFont.widthOfTextAtSize(text, 8);
        const textHgt = pdfLibObjs.robotoCondensedRegularFont.heightAtSize(8);
        textAndCoordinatesObj.x = (pageSize.width - textLen);
        textAndCoordinatesObj.y = (pageSize.height - textHgt);
        textAndCoordinatesObj.size = 8;
        return textAndCoordinatesObj;
    };
    return _fnAddTextToEachPage(pdfLibObjs, _fnGetTextAndCoordinates);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAddTextToTopCenterEachPage
 * @private
 * @summary      Adds text to top center of each page
 * @description  Adds text to top center of each page
 * @param  {Object}    pdfLibObjs                   Object containing PDF-Lib document instance and refs to our fonts
 * @param  {String}    text                         Text to add
 */

let _fnAddTextToTopCenterEachPage = function (pdfLibObjs,text) {
    let _fnGetTextAndCoordinates = function (pageSize, pageCtr, totalPages) {
        let textAndCoordinatesObj = {};        
        textAndCoordinatesObj.text = text;
        const textLen = pdfLibObjs.robotoCondensedRegularFont.widthOfTextAtSize(text, 8);
        const textHgt = pdfLibObjs.robotoCondensedRegularFont.heightAtSize(8);
        const centerPos = ((pageSize.width / 2) - (textLen / 2));
        textAndCoordinatesObj.x = (centerPos);
        textAndCoordinatesObj.y = (pageSize.height - textHgt);
        textAndCoordinatesObj.size = 8;
        return textAndCoordinatesObj;
    };
    return _fnAddTextToEachPage(pdfLibObjs, _fnGetTextAndCoordinates);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAddTextToBottomLeftEachPage
 * @private
 * @summary      Adds text to bottom left of each page
 * @description  Adds text to bottom left of each page
 * @param  {Object}    pdfLibObjs                   Object containing PDF-Lib document instance and refs to our fonts
 * @param  {String}    text                         Text to add
 */

let _fnAddTextToBottomLeftEachPage = function (pdfLibObjs,text) {
    let _fnGetTextAndCoordinates = function (pageSize, pageCtr, totalPages) {
        let textAndCoordinatesObj = {};        
        textAndCoordinatesObj.text = text;
        const textLen = pdfLibObjs.robotoCondensedRegularFont.widthOfTextAtSize(text, 8);
        const textHgt = pdfLibObjs.robotoCondensedRegularFont.heightAtSize(8);
        textAndCoordinatesObj.x = 1;
        textAndCoordinatesObj.y = textHgt;
        textAndCoordinatesObj.size = 8;
        return textAndCoordinatesObj;
    };
    return _fnAddTextToEachPage(pdfLibObjs, _fnGetTextAndCoordinates);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAddTextToBottomCenterEachPage
 * @private
 * @summary      Adds text to bottom center of each page
 * @description  Adds text to bottom center of each page
 * @param  {Object}    pdfLibObjs                   Object containing PDF-Lib document instance and refs to our fonts
 * @param  {String}    text                         Text to add
 */

let _fnAddTextToBottomCenterEachPage = function (pdfLibObjs,text) {
    let _fnGetTextAndCoordinates = function (pageSize, pageCtr, totalPages) {
        let textAndCoordinatesObj = {};        
        textAndCoordinatesObj.text = text;
        const textLen = pdfLibObjs.robotoCondensedRegularFont.widthOfTextAtSize(text, 8);
        const textHgt = pdfLibObjs.robotoCondensedRegularFont.heightAtSize(8);
        const centerPos = ((pageSize.width / 2) - (textLen / 2));
        textAndCoordinatesObj.x = (centerPos);
        textAndCoordinatesObj.y = textHgt;
        textAndCoordinatesObj.size = 8;
        return textAndCoordinatesObj;
    };
    return _fnAddTextToEachPage(pdfLibObjs, _fnGetTextAndCoordinates);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnAddTextToTopLeftEachPage
 * @private
 * @summary      Adds text to top left of each page
 * @description  Adds text to top left of each page
 * @param  {Object}    pdfLibObjs                   Object containing PDF-Lib document instance and refs to our fonts
 * @param  {String}    text                         Text to add
 */

let _fnAddTextToTopLeftEachPage = function (pdfLibObjs,text) {
    let _fnGetTextAndCoordinates = function (pageSize, pageCtr, totalPages) {
        let textAndCoordinatesObj = {};        
        textAndCoordinatesObj.text = text;
        const textLen = pdfLibObjs.robotoCondensedRegularFont.widthOfTextAtSize(text, 8);
        const textHgt = pdfLibObjs.robotoCondensedRegularFont.heightAtSize(8);
        textAndCoordinatesObj.x = 1;
        textAndCoordinatesObj.y = (pageSize.height - textHgt);
        textAndCoordinatesObj.size = 8;
        return textAndCoordinatesObj;
    };
    return _fnAddTextToEachPage(pdfLibObjs, _fnGetTextAndCoordinates);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGeneratePdfJsDocFromHtmlWithCB
 * @private
 * @summary      Generates pdf from either elementid or html text
 * @description  Generates pdf from either elementid or html text
 * @param  {object}  doc                   pdfJs document 
 * @param  {object}  elementRefOrHtmlText  Element ref or HTML text
 * @param  {string}  documentTitle         Title of document
 * @param  {number}  width                 width of ?
 * @param  {number}  winWidth              Increase to zoom out, decrease to zoom in
 * @param  {object}  fnCallBack            Callback function  
 */

let _fnGeneratePdfJsDocFromHtmlWithCB = function (doc, elementRefOrHtmlText, docTitle, x, y, margin, width, winWidth, fnCallBack) {

    if (!fnCallBack) fnCallBack = function (_doc, _docTitle) {
        _doc.save(docTitle);
    };

    let _fnCallBackWrapper = function (_doc, _docTitle) {
        fnCallBack(_doc, _docTitle);
    };

    let _opts = {
        x: (x)
        , y: (y)
        , margin: (margin)
        , autoPaging: 'text'
        , width: (width)
        , windowWidth: (winWidth)
        , html2canvas: { allowTaint: true, logging: false, imageTimeout:0 }
        , callback: function (doc) { _fnCallBackWrapper(doc, docTitle); }
    };

    
    return doc.html(elementRefOrHtmlText, _opts);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

function _fnGeneratePdfSection (elementRef, sectionIdx) {
  const REJECT_MESSAGE = 'Issue generating PDF section';
  return new Promise((resolve, reject) => {
      try {
          let doc = _fnCreateJsPdfDoc();
          let winWidth = elementRef.offsetWidth;
          let fnPdfGenCB = function (doc) {
              try {
                  let pdfData = {};
                  pdfData.sectionIdx = sectionIdx;
                  pdfData.fileBytes = doc.output('arraybuffer');
                  resolve(pdfData);
              }
              catch {
                  reject(REJECT_MESSAGE);
              }
          };          
          _fnGeneratePdfJsDocFromHtmlWithCB (doc, elementRef, '', 1, 1, 10, 195, winWidth, fnPdfGenCB);
      }
      catch {
          reject(REJECT_MESSAGE);
      }
    });
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

async function _fnGeneratePdfSections (sectionRefs) {
    let sections = new Array();
    let sectionIdx = 0;
    for (let sectionRef of sectionRefs) {
      let pdfData = await _fnGeneratePdfSection(sectionRef, sectionIdx);
      sections[pdfData.sectionIdx] = pdfData.fileBytes;
      sectionIdx++;
   };
   return sections;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGeneratePdfFromHtmlSections
 * @private
 * @summary      Renders the content inside elementID into a PDF
 * @description  Renders the content inside elementID into a PDF
 * @param  {string}  elementID  Element id 
 */

async function _fnGeneratePdfFromHtmlSections (sectionsSelector) {
   let sectionRefs = new Array();
   $(sectionsSelector).each(function (sectionIdx) {
      let elementRef = $(this).get(0);
      sectionRefs[sectionIdx] = elementRef;
   });
  let documents  = await _fnGeneratePdfSections(sectionRefs);
  let pdfLibObjs = await _fnMergeDocuments(documents);
  return pdfLibObjs;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGeneratePdfFromHtmlElement
 * @private
 * @summary      Renders the content inside elementID into a PDF
 * @description  Renders the content inside elementID into a PDF
 * @param  {string}  elementID  Element id 
 */

 let _fnGeneratePdfFromHtmlElement = async function (elementID) {
    let elementRef = document.getElementById(elementID);
    let sectionIdx = 0;
    let pdfData = await _fnGeneratePdfSection(elementRef, sectionIdx);
    let sections = new Array();
    sections[pdfData.sectionIdx] = pdfData.fileBytes;
    let pdfLibObjs = await _fnMergeDocuments(sections);
    return pdfLibObjs;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnSavePDFAsDataUri
 * @private
 * @summary      Takes PDF-Lib document instance in pdfLibsObj and returns a Data Uri
 * @description  Takes PDF-Lib document instance in pdfLibsObj and returns a Data Uri
 * @param  {Object}  pdfLibsObjs  Object containing PDF-Lib document instance and refs to our fonts
 */

let _fnSavePDFAsDataUri = async function (pdfLibObjs) {
  let base64DataUri = await pdfLibObjs.pdfDoc.saveAsBase64({ dataUri: true });
  return base64DataUri;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnSavePDF
 * @private
 * @summary      Takes PDF-Lib document instance in pdfLibsObj and saves/opens PDF in browser
 * @description  Takes PDF-Lib document instance in pdfLibsObj and saves/opens PDF in browser
 * @param  {Object}  pdfLibsObjs  Object containing PDF-Lib document instance and refs to our fonts
 * @param  {String}  docFileName  Document file name
 */

let _fnSavePDF = async function (pdfLibObjs, docFileName) {
  const base64DataUri = await pdfLibObjs.pdfDoc.saveAsBase64({ dataUri: true });
  var link = document.createElement('a');
  link.href = base64DataUri;
  link.download = docFileName;
  link.target = "blank";
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGeneratePdfFromHtmlElementAndSave
 * @private
 * @summary      Generates pdf from content in elementID and saves/opens PDF in browser
 * @description  Generates pdf from content in elementID and saves/opens PDF in browser
 * @param  {string}  elementID  Element id
 * @param  {String}  docFileName  Document file name
 */

let _fnGeneratePdfFromHtmlElementAndSave = async function (elementID, docFileName) {
    let pdfLibObjs = await _fnGeneratePdfFromHtmlElement(elementID);
    await _fnSavePDF(pdfLibObjs, docFileName);
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGeneratePdfFromHtmlElementAndReturnDataUri
 * @private
 * @summary      Generates pdf from content in elementID and returns dataUri
 * @description  Generates pdf from content in elementID and returns dataUri
 * @param  {string}  elementID  Element id
 */

let _fnGeneratePdfFromHtmlElementAndReturnDataUri = async function (elementID) {
    let pdfLibObjs = await _fnGeneratePdfFromHtmlElement(elementID);
    let dataURI    = await _fnSavePDFAsDataUri(pdfLibObjs);
    return dataURI;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetFontToUse
 * @private
 * @summary      Based on computed style of $elem return a font to use 
 * @description  Based on computed style of $elem return a font to use
 * @param  {object}  $elem  jQuery ref
 */

let _fnGetFontToUse = function ($elem) {

  let elem       = $($elem).get(0);                      /* Convert jQuery ref to js ref */
  let cssObj     = window.getComputedStyle(elem, null);
  let fontStyle  = cssObj.getPropertyValue('font-style');
  let fontWeight = cssObj.getPropertyValue('font-weight');
  let italic = 0;
  let bold   = 0;

  /* Test for italic */

  if      (fontStyle == 'normal')  { italic = 0; }
  else if (fontStyle == 'italic')  { italic = 1; }
  else if (fontStyle == 'oblique') { italic = 1; }
  else { italic = 0; }

  /* Test for bold */
  /* 400 is the same as normal, and 700 is the same as bold */

  if      (fontWeight == '100')    { bold = 0; }
  else if (fontWeight == '200')    { bold = 0; }
  else if (fontWeight == '300')    { bold = 0; }
  else if (fontWeight == '400')    { bold = 0; }
  else if (fontWeight == 'normal') { bold = 0; }
  else if (fontWeight == '500')    { bold = 0; }
  else if (fontWeight == '600')    { bold = 0; }
  else if (fontWeight == '700')    { bold = 1; }
  else if (fontWeight == '800')    { bold = 1; }
  else if (fontWeight == '900')    { bold = 1; }
  else if (fontWeight == 'bold')   { bold = 1; }
  else if (fontWeight == 'bolder') { bold = 1; }
  else { bold = 0; }

  /* Determine if we use regular, bold, italic, or bold italic font */

  if      ((italic == 0) && (bold == 0)) { return FONT_NAME_ROBOTO_CONDENSED_REGULAR; }
  else if ((italic == 0) && (bold == 1)) { return FONT_NAME_ROBOTO_CONDENSED_BOLD; }
  else if ((italic == 1) && (bold == 0)) { return FONT_NAME_ROBOTO_CONDENSED_ITALIC; }
  else if ((italic == 1) && (bold == 1)) { return FONT_NAME_ROBOTO_CONDENSED_BOLD_ITALIC; }
  else                                   { return FONT_NAME_ROBOTO_CONDENSED_REGULAR; }

  return FONT_NAME_ROBOTO_CONDENSED_REGULAR;
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnGetTinyMceFontSizeToUse
 * @private
 * @summary      Based on computed style of $elem return a font size to use
 * @description  Based on computed style of $elem return a font size to use
 * @param  {object}  $elem  jQuery ref
 */

let _fnGetTinyMceFontSizeToUse = function ($elem) {     
  let elem = $($elem).get(0);                      /* Convert jQuery ref to js ref */    
  let nodeName = elem.nodeName;

  if (nodeName == 'SPAN')   return '12pt';
  if (nodeName == 'DIV')    return '12pt';
  if (nodeName == 'P')      return '12pt';

  if (nodeName == 'H1')     return '24pt';
  if (nodeName == 'H2')     return '18pt';
  if (nodeName == 'H3')     return '14pt';
  if (nodeName == 'H4')     return '12pt';
  if (nodeName == 'H5')     return '10pt';
  if (nodeName == 'H6')     return '8pt';
  if (nodeName == 'SUB')    return '10pt';
  if (nodeName == 'SUP')    return '10pt';
  if (nodeName == 'EM')     return '12pt';
  if (nodeName == 'STRONG') return '12pt';
  return '';
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnDetermineFontSizeToUse
 * @private
 * @summary      Based on computed style of $elem return a font size to use
 * @description  Based on computed style of $elem return a font size to use
 * @param  {object}  $elem  jQuery ref
 */

let _fnDetermineFontSizeToUse = function ($elem) {
  let elem = $($elem).get(0);                      /* Convert jQuery ref to js ref */    
  let nodeName = elem.nodeName;

  if (nodeName == 'SPAN')   return '12pt';
  if (nodeName == 'DIV')    return '12pt';
  if (nodeName == 'P')      return '12pt';

  if (nodeName == 'H1')     return '24pt';
  if (nodeName == 'H2')     return '18pt';
  if (nodeName == 'H3')     return '14pt';
  if (nodeName == 'H4')     return '12pt';
  if (nodeName == 'H5')     return '10pt';
  if (nodeName == 'H6')     return '8pt';
  if (nodeName == 'SUB')    return '10pt';
  if (nodeName == 'SUP')    return '10pt';
  if (nodeName == 'EM')     return '12pt';
  if (nodeName == 'STRONG') return '12pt';
  if (nodeName == 'A')      return '12pt';
  if (nodeName == 'LI')     return '12pt';
  return '12pt';
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnApplyPdfFonts
 * @private
 * @summary      Replaces font family with font family we embed in pdf
 * @description  Replaces font family with font family we embed in pdf
 * @param  {string}  elementSelector  selector
 */

let _fnApplyPdfFonts = function (elementSelector) {
   $(elementSelector).find('*').each(function () {
     let $elem = this;
     let fontFamily = _fnGetFontToUse($elem);
     $($elem).css('font-family', fontFamily);
   });
 };

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnApplyPdfFontSizes
 * @private
 * @summary      Replaces font size with smaller standardized sizes 
 * @description  Replaces font size with smaller standardized sizes based on the type of elements
 * @param  {string}  elementSelector  selector
 */

let _fnApplyPdfFontSizes = function (elementSelector) {
   $(elementSelector).find('*').each(function () {
       let $elem = this;
       let fontSize = _fnDetermineFontSizeToUse($elem);
       $($elem).css('font-size', fontSize);
   });
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnReformatTinyMceContent
 * @private
 * @summary      Reformats tiny MCE generated content into JSPDF friendly content
 * @description  Reformats tiny MCE generated content into JSPDF friendly content
 * @param  {string}  elementSelector  selector
 */

let _fnReformatTinyMceContent = function (elementSelector) {

  /* Find all text elements without a suitable containing element and wrap these in spans */

  $(elementSelector).find('*').contents().each(function () {
      let $elem = this;
      if ($elem.nodeType === 3) {
          let $parentElem = $($elem).parent()[0];          
          if (   ($parentElem.nodeName == 'P')
              || ($parentElem.nodeName == 'LI')
          ) {
              $($elem).wrap('<span></span>');
          }
      }
  });

  /* Set font sizes */

  $(elementSelector).find('*').each(function () {
      let $elem = this;
      let styleVal = $($elem).attr('style');
      if (!styleVal) {
      /* If there are no existing inline css rules reset font size. */
      let fontSize = _fnGetTinyMceFontSizeToUse($elem);
      if (fontSize == '') return;
      $($elem).css('font-size', fontSize);        
      }
  });
};

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @function     _fnConvertToPrintableContent
 * @private
 * @summary      Replaces some elements inside elementSelector with jspdf friendly content
 * @description  Replaces some elements inside elementSelector with jspdf friendly content
 * @param  {string}  elementSelector  selector
 */

let _fnConvertToPrintableContent = function (elementSelector) {
   
  /* Replace textarea with pre with contenteditable enabled */
  
  $(elementSelector).find('textarea:not([hidden])').each(function () {
      let $ta = this;
      /* Note: Add an option later to add contenteditable="true"*/
      let $pre = $('<pre></pre>');
      $($pre).addClass(CSS_CLASS_HTML_TO_PDF_ELEMENT_REPLACEMENT);
      $($pre).text($($ta).val());
      $($ta).replaceWith($pre);      
  });

  /* Replace input[type="date"] with input[type="text"] and reformat the date value */
  
  $(elementSelector).find('input[type="date"]:not([hidden])').each(function () {
      let $inp = this;
      let dateStrIn  = $($inp).val();
      let dateStrOut = '';
      if (dateStrIn != '') {
          try {
              let dateVal = new Date(dateStrIn);
              dateStrOut = (dateVal.getMonth() + 1) + '/' + dateVal.getDate() + '/' + dateVal.getFullYear();
          } catch (e) {
              dateStrOut = '';
          }
      }
      $($inp).attr('type', 'text');
      $($inp).val(dateStrOut);
    });
};


/*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/

return {
      fnGeneratePdfJsDocFromHtmlWithCB: _fnGeneratePdfJsDocFromHtmlWithCB
    , fnMergeDocuments: _fnMergeDocuments
    , fnAddTextToEachPage: _fnAddTextToEachPage
    , fnAddPageNumberToEachPage: _fnAddPageNumberToEachPage
    , fnAddTextToBottomLeftEachPage: _fnAddTextToBottomLeftEachPage
    , fnAddTextToBottomCenterEachPage: _fnAddTextToBottomCenterEachPage
    , fnAddTextToTopLeftEachPage: _fnAddTextToTopLeftEachPage
    , fnAddTextToTopCenterEachPage: _fnAddTextToTopCenterEachPage
    , fnAddTextToTopRightEachPage: _fnAddTextToTopRightEachPage
    , fnGeneratePdfFromHtmlSections: _fnGeneratePdfFromHtmlSections
    , fnGeneratePdfFromHtmlElement: _fnGeneratePdfFromHtmlElement
    , fnSavePDF: _fnSavePDF    
    , fnConvertToPrintableContent: _fnConvertToPrintableContent
    , fnApplyPdfFonts: _fnApplyPdfFonts
    , fnReformatTinyMceContent: _fnReformatTinyMceContent
    , fnGeneratePdfFromHtmlElementAndSave: _fnGeneratePdfFromHtmlElementAndSave
    , fnSavePDFAsDataUri : _fnSavePDFAsDataUri
    , fnGeneratePdfFromHtmlElementAndReturnDataUri: _fnGeneratePdfFromHtmlElementAndReturnDataUri
    , fnApplyPdfFontSizes: _fnApplyPdfFontSizes
};

})(jQuery);