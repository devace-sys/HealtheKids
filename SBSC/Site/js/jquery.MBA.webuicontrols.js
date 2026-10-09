/***************************************************************************
 * jquery.MBA.webuicontrols.js */
/**
 * Client side code for MBA.WebUIControls
 ***************************************************************************/

  /***************************************************************************
   * spedmon.Input */
  /**
   * A replacement for a text input.  Transforms an <input/> into an
   * textbox with a watermark that displays the controls title when
   * no value has been provided.
   *
   * This also functions as a base class for other controls we have.
   *
   * The watermark label option was based on Glen Lipka's watermark control
   * http://www.commadot.com/jquery/experiments/shunra/
   ***************************************************************************/

  ;(function($){

    $.fn.spedmonInput = function(options){

      /*-------------------------------
       * Merge passed in options with
       * controls defaults and create
       * an options object that is a
       * combination of the two
       *------------------------------*/

      var $opts;
      $opts = $.extend({},$.fn.spedmonInput.defaults,options);

      /*-------------------------------
       * Tie into return chain
       *------------------------------*/

	  return this.each(function() {

        var $me;           // This control (input)
        var meid;          // This controls id
	    var $mecont;       // Container for this control
        var $label;        // Label to hold controls title.  The label is placed on top of the input control
		var mestyle;       // Controls original inline style passed in from server
		var mevalue;       // Controls original value passed in from server
		var medefault;     // Default value passed in from server

		/*-------------------------------
         * Setup dom references and
	     * add additional html
         *------------------------------*/

	    // Base input

	    $me       = $(this);
	    meid      = $me.attr('id');
        mestyle   = $me.attr('style');

        if (!mestyle) mestyle = ""; /* If style is not defined, set it to "" */

        mevalue   = $me.val();
        medefault = '';

        /*-------------------------------
         * Add class to indicate this 
	     * control is for data entry
		 * primary tasks.
         *------------------------------*/

		 $($me).addClass($.spedmonWebUI.field.DATA_ENTRY_PRIMARY);
		
        // Tag this so subclasses can tell if they are based on this control

        $(this).addClass($.spedmonWebUI.field.INPUT_BASE);

        // Default value (passed using an HTML 5 data-? attribute

        if ($(this).hasClass($.spedmonWebUI.field.HAS_DEFAULT) == true) {
		  medefault = $me.attr('data-default-value');
        }

		// Create container

        $me.wrap("<span id='" + meid + "_cont'></span>");
        $mecont = $me.parent();

        // Create border if applicable

        if ($opts.useBorder)
        {
          $mecont.addClass("ui-spedmon-box-container ui-widget ui-widget-container");
          $me.addClass("ui-spedmon-box ui-widget-content ui-corner-all");
        }

        // Create watermark label if applicable

        if ($opts.useLabel)
        {
          var ph = $me.attr('title');
		  $me.attr('placeholder',ph);
		  //$me.attr('placeholder',$me.attr('title'));
		  //$label = $("<label id='" + meid + "_label'>" + $me.attr('title') + "</label>").insertBefore($me);
          //$label.addClass("ui-spedmon-box-label ui-widget ui-widget-container");
	      //$label.css({left:5,top:3});
        }

		/*-------------------------------
         * Dynamic styling.  This will
	     * adjust our style to any styles
	     * the user has added.
         *------------------------------*/

        function _meSetStyle(newstyle)
		{
		  var ns = mestyle + ';' + newstyle;
		  $me.attr("style",ns);
		}

		/*-------------------------------
         * Hide label if control is hidden
	     * or the value is present on
	     * load
         *------------------------------*/

		/*
		if ($opts.useLabel)
        {
          if (!$me.is(":visible")){$label.hide();}
		  if ($me.val()){$label.hide();}
        }
        */

		/*-------------------------------
         * Max length setup/cleanup
         *
         * Some browsers provide a large
         * number if max length is not
         * provided.  This helps
         * standardize this.
         *------------------------------*/

        maxLen = 0;

        if ($me.attr('maxlength') == undefined)
          maxLen = 0;
        else
          maxLen = $me.attr('maxlength');

        if ((maxLen <= 0) || (maxLen >= 1000)) maxLen = 0;

        /*-------------------------------
         * Event triggers and bindings
         *------------------------------*/

        var doHover  = true;
        var oldValue = $me.val();
        var newValue = $me.val();

	    $me.focus (function(){

          /*-------------------------------
           * Focus
           * User entering control
           *-----------------------------*/

          oldValue = $me.val();

          if ($opts.useHover){
            doHover = false;
            $me.removeClass("ui-state-highlight");
		    $me.addClass("ui-spedmon-box-focus");
		    _meSetStyle("border:1px solid #000;");
		  }

          // Fade the label out (if it is being used) when we focus on the control

		  /*
          if ($opts.useLabel) $label.fadeOut("fast");
          */
        })
        .blur(function(){

          /*-------------------------------
           * Blur
           * User exiting control
           *------------------------------*/

          // Get the new value

          newValue = $me.val();

          // Test for no value, no value means value is now empty

          var noValue    = ((!this.value) || (this.value == '') || ($me.val() == ''));

          // Test for new value, new value means the old value was empty and the new value is not

          var newValue   = ((!noValue) && (oldValue == ''))

          // Test for cleared values.  Cleared value means the old value was not empty and the new value is now empty

          var clearValue = ((oldValue != '') && (noValue))

          // Test for different values.  If the old value and new values are non blank and different we have a value change

          var diffValue = ((newValue != oldValue) && (!newValue) && (!noValue));

          // Various delegate calls

          var $dStatus = 0;

          if (noValue) {
            $dStatus = $.spedmonWebUI.inputstatus.novalue;
            $opts.noValueEntered();
          }

          if (clearValue){
            $dStatus = $.spedmonWebUI.inputstatus.clearvalue;
            $opts.blankValueEntered();
          }

          if (newValue) {
            $dStatus = $.spedmonWebUI.inputstatus.newvalue;
            $opts.newValueEntered();
          }

          if (diffValue){
            $dStatus = $.spedmonWebUI.inputstatus.diffvalue;
            $opts.differentValueEntered();
          }

          if ($opts.useHover)
          {
            doHover = true;
		    _meSetStyle("");
		  }

          // When bluring if the value is not set, fade the label back in

          /*
		  if ((noValue) && ($opts.useLabel)){
            $label.fadeIn ("fast");
          }
          */

          /*-------------------------------
           * Fire data events
           *------------------------------*/

          // data input

          jQuery.spedmonWebUI.fireDataInput($me,{id:$me.attr('id'),label:$me.val(),value:$me.val(),dataStatus:$dStatus});

          if ($opts.onBlurDataSelect)
          {

            // data selected

            if (!$opts.privateEntry)
              jQuery.spedmonWebUI.fireDataSelected($me,{id:$me.attr('id'),label:$me.val(),value:$me.val()});
            else
              jQuery.spedmonWebUI.fireDataSelected($me,{id:$me.attr('id'),label:$opts.privateLabel,value:$me.val()});
          }

          return;

        })
        .hover(function(){

          /*-------------------------------
           * Hover
           * User hovering over control with
           * mouse
           *------------------------------*/

  	       if ((doHover) && ($opts.useHover)){
             $me.addClass("ui-state-highlight");
             _meSetStyle("border:1px solid #000;");
           }},
           function(){
             if ((doHover) && ($opts.useHover)){
               $me.removeClass("ui-state-highlight");
               _meSetStyle("");
            }}
         );

        $me.keypress(function(e){

          /*-------------------------------
           * Keypress
           * Data is entered by user
           * into control via keyboard
           *------------------------------*/

		  var kc =  $.spedmonWebUI.whatKeycode(e);

          // Enter

          if (kc==13)
          {
            // Fire data input event

            if ($opts.onEnterDataSelect)
            {

              if ($opts.onBlurDataSelect){
                this.blur();
                return;
              }

              if (!$opts.privateEntry)
                jQuery.spedmonWebUI.fireDataSelected($me,{id:$me.attr('id'),label:$me.val(),value:$me.val()});
              else
                jQuery.spedmonWebUI.fireDataSelected($me,{id:$me.attr('id'),label:$opts.privateLabel,value:$me.val()});
              return;
            }
          }

          // Double quotes (")

          if (kc==34)
		  {
	        return false;  // Dont allow
			// TODO: Replace with single quote
	      }

        });

        // Save references for descendant controls

	    var input = {};

	    input.meid         = meid;
	    input.meCont       = $mecont;
        input.useLabel     = $opts.useLabel
	    input.meLabel      = $label;
		input.maxLen       = maxLen;
        input.onValueSet   = $opts.onValueSet;
        input.onValueClear = $opts.onValueClear;

	    $.data(this, 'spedmonInput', input);

        });
    };

    /*-------------------------------
     * Set Value
     *------------------------------*/

    $.fn.spedmonInput_setValue = function (value){
      return this.each(function() {
        var $me        = $(this);
	    var ctrl       = $($me).data('spedmonInput');
        var $label     = ctrl.meLabel;
        var useLabel   = ctrl.useLabel;
        var onValueSet = ctrl.onValueSet;
        $($me).val(value);
        //if (useLabel) $($label).hide();
        onValueSet();
      });
    };

    /*-------------------------------
     * Clear Value
     *------------------------------*/

    $.fn.spedmonInput_clearValue = function () {
      return this.each(function() {

        var $me = $(this);

        /* Get this instances data */

        var ctrl         = $($me).data('spedmonInput');
        var $label       = ctrl.meLabel;
        var useLabel     = ctrl.useLabel;
        var onValueClear = ctrl.onValueClear;

        /* If value clear has not been overriden */

        if (valueClear() == true)
        {
          /* Clear value is normally blank */

          var clsVal = '';

          /* If this control has a default value, use it for the clear value */

          if ($($me).hasClass($.spedmonWebUI.field.HAS_DEFAULT))
            clsVal = $(simplefield).attr('data-default-value');

          /* Set controls value to clear value */

          $($me).val(clsVal);

          /* If we are using labels, show the control label if applicable */

          /*if (useLabel)
          {
            if ((newVal) == '')
              $($label).show();
            else
              $($label).hide();
          }
		  */
        }

        /* Call clear delegate */

        onValueClear();

      });
    };

   /*-------------------------------
    * Option defaults
    *------------------------------*/

   $.fn.spedmonInput.defaults = {
     useLabel:true,
     useHover:true,
     useBorder:true,
     privateEntry:false,
     onEnterDataSelect:true,
     onBlurDataSelect:false,
     valueClear:function(){return true;},
     onValueSet:function(){},
     onValueClear:function(){},
     privateLabel:'Value Entered',
     noValueEntered:function(){},
     newValueEntered:function(){},
     differentValueEntered:function(){},
     blankValueEntered:function(){}
   };

})(jQuery);

  /***************************************************************************
   * spedmon.Textbox */
  /**
   * A replacement for a text input.  Transforms an <input/> into an
   * textbox with a watermark that displays the controls title when
   * no value has been provided.  This also functions as a base class for a
   * other controls we have.
   ***************************************************************************/

  ;(function($){

    $.fn.spedmonTextbox = function(options){


     /*-------------------------------
      * Merge passed in options with
      * controls defaults and create
      * an options object that is a
      * combination of the two
      *------------------------------*/

      var $opts;
      $opts = $.extend({},$.fn.spedmonTextbox.defaults,options);

      /*-------------------------------
       * Tie into return chain
       *------------------------------*/

	  return this.each(function() {

        var $me;           // This control (input)
		var meid;          // This controls id

        // Base input

        $me = $(this);
	    meid = $me.attr('id');

		// Create input using textbox options

        $(this).spedmonInput(options);
		
		// Get references from input

	    var input   = $($me).data('spedmonInput');
		var $mecont = input.meCont;
	    var $label  = input.meLabel;
	    var maxLen  = input.maxLen;
		
		// Build on input conrol

        var $meentrytype;
        var $meentrytypeicon;

        var $mestatus;     // Status (max character count reached, field required, invalid data, etc)
        var $mestatusicon; // Status icon
        var $buttonOK;     // Select the value

		/*-------------------------------
         * Setup dom references and
	     * add additional html
         *------------------------------*/

	    // Entry type

        $meentrytypeicon = $("<span id='" + meid + "_entrytypeicon'></span>").insertAfter($me);
        $meentrytypeicon.addClass("ui-icon");
        $meentrytypeicon.wrap("<span id='" + meid + "_entrytype'></span>");
        $meentrytype = $meentrytypeicon.parent();

        if ($opts.useBorder)
        {
          $meentrytype.addClass("ui-spedmon-box-status ui-widget ui-widget-container");
        }

        $meentrytype.hide();

        if ($opts.privateEntry)
        {
          $meentrytypeicon.addClass("ui-icon-locked");
          $meentrytypeicon.attr('title',"Private Entry");
          $meentrytype.show();
        }

        // Status

        $mestatusicon = $("<span id='" + meid + "_statusicon'></span>").insertAfter($meentrytype);
        $mestatusicon.addClass("ui-icon");
        $mestatusicon.wrap("<span id='" + meid + "_status'></span>");
        $mestatus = $mestatusicon.parent();

        if ($opts.useBorder)
        {
          $mestatus.addClass("ui-spedmon-box-status ui-widget ui-widget-container");
        }

        $mestatus.hide();

        // OK button

        if ($opts.useOK)
        {
          $buttonOK = $("<button class='ui-spedmon-box-inline-ctrl' id='"+ meid + "_but_ok' type='button'>OK</button>").insertAfter($mestatus)
            .css({height:parseInt($me.outerHeight())})
            .button()
            .hover (function() {$me.addClass("ui-state-highlight")}, function(){$me.removeClass("ui-state-highlight");});
          if (!$opts.showOK) $buttonOK.hide();
        }

		/*-------------------------------
         * Dynamic styling.  This will
	     * adjust our style to any styles
	     * the user has added.
         *------------------------------*/

        if ($opts.useBorder)
        {
          $meentrytype.css({left: parseInt($me.outerWidth()-20),top:0});  // Place our entry type on the right side
          if (!$meentrytype.is(":visible"))
            $mestatus.css({left: parseInt($me.outerWidth()-20),top:0});   // Place our status icon on the right side if entry type is not provided
          else
           $mestatus.css({left: parseInt($me.outerWidth()-30),top:0});    // Place our status icon next to entry type
        }

        /*-------------------------------
         * Event triggers and bindings
         *------------------------------*/

	    if ($opts.useOK)
        {
          $buttonOK.click(function(){
            if (!$opts.privateEntry)
             jQuery.spedmonWebUI.fireDataSelected($me,{id:$me.attr('id'),label:$me.val(),value:$me.val()})
           else
             jQuery.spedmonWebUI.fireDataSelected($me,{id:$me.attr('id'),label:$opts.privateLabel,value:$me.val()});
          });
        }

        $me.keypress(function(e){
		  if (maxLen != 0)
		  {
		    var keyCount = $me.val().length;
			var charLeft = maxLen - keyCount;
			if (charLeft == 0)
			{
              $mestatusicon.addClass("ui-icon-info");
              $mestatusicon.attr('title',maxLen + " character limit reached");
		      $mestatus.show();
			}
		    else
            {
			  $mestatusicon.removeClass("ui-icon-info");
              $mestatusicon.attr('title','');
			  $mestatus.hide();
			}
	      }
        });

		// Save references for descendant controls

	    var textBox = {};

	    textBox.meid         = meid;
		textBox.buttonOK     = $buttonOK;
	    textBox.meCont       = $mecont;
	    textBox.meLabel      = $label;
	    textBox.meStatus     = $mestatus;
	    textBox.meStatusIcon = $mestatusicon;
	    $.data(this, 'spedmonTextbox', textBox);
		});
    };

  /*-------------------------------
   * Option defaults
   *------------------------------*/

  $.fn.spedmonTextbox.defaults = {
      useBorder:true
    , useOK:true
    , showOK:true
    , showControls:true
  };

})(jQuery);

  /***************************************************************************
   * spedmon.TextAreaBox*/
  /**
   * Transforms a textarea box into an enhanced textarea box.
   ***************************************************************************/

  ;(function($){
    $.fn.spedmonTextAreaBox = function(options){

      var $opts; // Control options

     /*-------------------------------
      * Merge passed in options with
      * controls defaults and create
      * an options object that is a
      * combination of the two
      *------------------------------*/

      $opts = $.extend({},$.fn.spedmonTextAreaBox.defaults,options);

      /*-------------------------------
       * Tie into return chain
       *------------------------------*/

       return this.each(function() {

        var $me;            // This control (textarea)
		var meid;           // This controls id
        var $meCont;        // Container
        var $buttonOK;      // OK button
        var $meControl;     // Control section
        var maxLen = 0;     // Max # of characters allowed


//        if ($opts.maxLen) maxLen = $opts.maxLen;

       /*-------------------------------
        * Grab reference to control
        *------------------------------*/

       $me  = $(this);
       meid = $me.attr('id');

       /*-------------------------------
        * Wrap textarea in a div
        *------------------------------*/

        $me.wrap("<div id='" + meid + "_cont'></div>");
        $meCont = $me.parent();

		/*-------------------------------
         * Add class to indicate this 
	     * control is for data entry
		 * primary tasks.
         *------------------------------*/

		$($me).addClass($.spedmonWebUI.field.DATA_ENTRY_PRIMARY);
       
	   /*-------------------------------
        * Style text area and its
        * container
        *------------------------------*/

        $meCont.addClass("ui-spedmon-box-container ui-widget ui-widget-container");
        $me.addClass("ui-spedmon-box ui-widget-content ui-corner-all ui-spedmon-textareabox");
 
        // Note: For some reason the font-family style from ui-spedmon-textareabox is not being applied
        // so we have to force it.

        $me.css('font-family','"Courier New",Courier,monospace');

       /*-------------------------------
        * Create control section below
        * text area
        *------------------------------*/

        $meControl = $("<div></div>").insertAfter($meCont);

       /*-------------------------------
        * Create OK button and insert
        * inside our control section
        *------------------------------*/

        $buttonOK = $("<button id='"+ meid + "_but_ok' type='button'>OK</button>")
          .button();
        $meControl.html($buttonOK);


       /*-------------------------------
        * Attach handlers for key events
        *------------------------------*/

        $buttonOK.click(function(e){

          // Create label

          var $txt = $me.val();
          var ln   = $txt.length;


          if (ln > 50) ln = 50;
            $txt = $txt.substring(0,ln);
          if (ln == 50)
            $txt = $txt + '...';

          // Fire data selected

          jQuery.spedmonWebUI.fireDataSelected($me,{id:$me.attr('id'),label:$txt,value:$me.val()});

        });

        $me.keypress(function(e){

          var kc   = $.spedmonWebUI.whatKeycode(e);
          var text = $me.val();
          var len  = text.length;

          // Handle max length

          if (maxLen != 0)
          {
            if (len > maxLen)
            {
              text = text.substring(0,maxLen);
              $me.val(text);
              text = $me.val();
              len  = text.length;
            }
          }

          return true;
          });

		});
    };

  /*-------------------------------
   * Option defaults
   *------------------------------*/
  $.fn.spedmonTextAreaBox.defaults = {
  };

})(jQuery);

/***************************************************************************
 * spedmon.RichTextAreaBox*/
/**
 * Transforms a textarea box into an enhanced textarea box.
 ***************************************************************************/


;(function($){

  /*----------------------------------------------------------------------
   * Object Definition
   *---------------------------------------------------------------------*/

  var spedmonRichTextAreaBox = function (element, options)
  {


    var $opts    = $.extend({},$.fn.spedmonRichTextAreaBox.defaults,options);
    var $me      = $(element);
    var obj      = this;
    var meid     = $($me).attr('id');
    var $meid    = meid;
    var $meidSel = '#' + meid;

    var _mceObjOpts = {

          selector: $meidSel
        , height: 300
		, resize: false
        , theme: 'modern'
        , browser_spellcheck: true
        , plugins: [
            'advlist autolink link image lists charmap preview hr anchor toc'
          , 'searchreplace wordcount visualblocks visualchars code fullscreen insertdatetime media nonbreaking'
          , 'table directionality emoticons textcolor paste colorpicker textpattern'
        ]
        , menubar:  'edit insert view format table tools'
        , toolbar1: 'bold italic underline strikethrough subscript superscript | alignleft aligncenter alignright alignjustify | outdent indent blockquote | forecolor backcolor | formatselect fontselect fontsizeselect'
        , toolbar2: 'bullist numlist table hr | link unlink anchor | image media charmap nonbreaking | undo redo | cut copy paste searchreplace removeformat | preview fullscreen'
        , toolbar_items_size: 'small'
        , image_title: true
        , paste_data_images: true
        , file_picker_types: 'image'
        , images_dataimg_filter: function(img) {
            return img.hasAttribute('internal-blob');
        }
        , file_picker_callback: function(cb, value, meta) {
            if (meta.filetype == 'image') {
              var input = document.createElement('input');
              input.setAttribute('type', 'file');
              input.setAttribute('accept', 'image/*');
              input.onchange = function() {
                var file = this.files[0];
                var fileReader = new FileReader();
                var fileData = null;
                fileReader.onload = function(fileLoadedEvent) {
                  fileData = fileLoadedEvent.target.result;
                  cb(fileData, { title: file.name });
                };
              fileReader.readAsDataURL(file);
              }
              input.click();
            };
         }
		 , setup: function(editor) {
           editor.on('init', function(e) {
             editor.load();
           });
		   editor.on('blur',function(e) {
		     editor.save();
		   });
        }
      };

      var _mceFnInit  = function() { tinymce.init(_mceObjOpts); };
      var _mceFnSave  = function() { tinymce.get(meid).save();  };
      var _mceFnLoad  = function() { tinymce.get(meid).load();  };
      var _mceFnClear = function() { $($me).val(''); _mceFnLoad(); };

      var fnSave = function(fds) {
        _mceFnSave();
        if (fds==true) jQuery.spedmonWebUI.fireDataSelected($me,{id:$meid,label:'',value:''});
      };

      var fnClear = function(cfrm) {
        if (cfrm == true) {
		  tinymce.get(meid).windowManager.confirm("Are you sure you want to clear this content?", function(s) {
            if (s)
		      _mceFnClear();
            else
              return;
          });
		}
		else {
		  _mceFnClear();
		};
      };

      var fnInit = function () {
        _mceFnInit();
      }

      $me.wrap('<div class="ui-spedmon-box-container ui-widget ui-widget-container"></div>');

      var $meCont     = $me.parent();

      var $meControls = $('<div></div>')
                      .insertAfter($meCont);

      var $buttonOK   = $('<button type="button">OK</button>')
                     .button({icons: {primary: "ui-icon ui-icon-arrowreturnthick-1-e"}, text: true})
                     .click(function(e){fnSave(true);});

      var $buttonClear = $('<button type="button">Clear</button>')
                      .button({text: true})
                      .click(function(e){fnClear(true);});

      $($meControls).append($buttonClear);
	  $($meControls).append($buttonOK);

	  
      fnInit();

      /* Public methods */

      this.init  = function() { fnInit(); }
      this.clear = function() { fnClear(false); }

       if ($opts.showControls == false){
	     $($meControls).hide();
	   }
	};

   /*----------------------------------------------------------------------
    * jQuery constructor and linkage
    *---------------------------------------------------------------------*/

   $.fn.spedmonRichTextAreaBox = function (options) {

     /*-------------------------------------------------------------------
      * If the selector returns elements work with them.
      *-------------------------------------------------------------------*/

     return this.each(function()
     {
       var $me = $(this);                                                       /* Grab reference to textarea */
       if ($me.data('spedmonrichtextareabox')) return;                          /* Return early if this textarea already has a rich ta instance*/
       var spedmonrichtextareabox = new spedmonRichTextAreaBox (this, options); /* Create rich ta object and pass options in*/
	  
 	  /*-------------------------------
         * Add class to indicate this 
	     * control is for data entry
		 * primary tasks.
         *------------------------------*/

	  //$($me).addClass($.spedmonWebUI.field.DATA_ENTRY_PRIMARY);
       
       $me.data('spedmonrichtextareabox', spedmonrichtextareabox);              /* Store rich ta object in textarea data */
     });
   };

   /*-------------------------------
    * Option defaults
    *------------------------------*/

   $.fn.spedmonRichTextAreaBox.defaults = {
     showControls:true
   };

})(jQuery);


 /***************************************************************************
  * spedmon.NoteAreaBox*/
 /**
  * Transforms a textarea box into an enhanced textarea box.
  ***************************************************************************/

  ;(function($){
    $.fn.spedmonNoteAreaBox = function(options){

      var $opts; // Control options

     /*-------------------------------
      * Merge passed in options with
      * controls defaults and create
      * an options object that is a
      * combination of the two
      *------------------------------*/

      $opts = $.extend({},$.fn.spedmonNoteAreaBox.defaults,options);

      /*-------------------------------
       * Tie into return chain
       *------------------------------*/

       return this.each(function() {

        var $me;            // This control (textarea)
		var meid;           // This controls id
        var $meCont;        // Container
        var $buttonOK;      // OK button
        var $meControl;     // Control section
        var maxLen = 0;     // Max # of characters allowed

       /*-------------------------------
        * Grab reference to control
        *------------------------------*/

       $me  = $(this);
       meid = $me.attr('id');

       /*-------------------------------
        * Wrap textarea in a div
        *------------------------------*/

        $me.wrap("<div id='" + meid + "_cont'></div>");
        $meCont = $me.parent();

       /*-------------------------------
         * Add class to indicate this 
	     * control is for data entry
		 * primary tasks.
         *------------------------------*/

		$($me).addClass($.spedmonWebUI.field.DATA_ENTRY_PRIMARY);
		
	   /*-------------------------------
        * Style text area and its
        * container
        *------------------------------*/

        $meCont.addClass("ui-spedmon-box-container ui-widget ui-widget-container");
	    
        $me.addClass("ui-spedmon-box ui-widget-content ui-corner-all ui-spedmon-noteareabox");
      
	   /*-------------------------------
        * Create control section below
        * text area
        *------------------------------*/

        $meControl = $("<div></div>").insertAfter($meCont);

       /*-------------------------------
        * Use autosize plugin if 
        * specified
        *------------------------------*/

	   if ($opts.autoSize == true)
	   {
	      $($me).autosize();
		 
         /* Give enough time for the paste event to complete http://stackoverflow.com/a/2242485 */
	
        $($me).on("change focus blur", function(){	
	       setTimeout(function() { 
		     $($me).trigger('autosize.resize');
		   }, 100);
	     });
		
	   }
	   
	   /*-------------------------------
        * Create OK button and insert
        * inside our control section
        *------------------------------*/
		
        if ($opts.showOKButton == true)
		{
          $buttonOK = $("<button id='"+ meid + "_but_ok' type='button'>OK</button>").button();
          $meControl.html($buttonOK);
        
          $buttonOK.click(function(e){

            // Create label

            var $txt = $me.val();
            var ln   = $txt.length;

            if (ln > 50) ln = 50;
              $txt = $txt.substring(0,ln);
            if (ln == 50)
              $txt = $txt + '...';

            // Fire data selected

            jQuery.spedmonWebUI.fireDataSelected($me,{id:$me.attr('id'),label:$txt,value:$me.val()});
          });
         }
      });
    };

  /*-------------------------------
   * Option defaults
   *------------------------------*/

  $.fn.spedmonNoteAreaBox.defaults = {
      showOKButton:true
	, autoSize:true
  };

})(jQuery);


/***************************************************************************
 * spedmon.Numberbox */
/**
 * A replacement for a text input.  Transforms an <input/> into an
 * textbox with a watermark that displays the controls title when
 * no value has been provided.
 ***************************************************************************/

;(function($){
  $.fn.spedmonNumberbox = function(options){

   var $opts;         // Control options

   /*-------------------------------
    * Grab options
    *------------------------------*/

	$opts = $.extend({},$.fn.spedmonNumberbox.defaults,options);

	/*-------------------------------
     * Tie into return chain
     *------------------------------*/

    return this.each(function() {

	  // Create textbox

	  var $me = $(this);
	  $(this).spedmonTextbox(options);

	  // Get references from textBox

	  var textBox       = $($me).data('spedmonTextbox');
	  var $buttonOK     = textBox.buttonOK;
	  var $mecont       = textBox.meCont;
	  //var $label        = textBox.meLabel;
	  var $mestatus     = textBox.meStatus;
	  var $mestatusicon = textBox.meStatusIcon;
	  var meid          = textBox.meid;

	  // Customize for numberbox

	  var $buttonAdd1;   // Add 1
      var $buttonSub1;   // Sub 1

      /*-------------------------------
       * Adds 1 to whatever value is
       * currently in the control
       *------------------------------*/

       function add1()
       {
         if ($me.val() == ''){
           $me.val(parseInt(1));
         }else{
           $me.val(parseInt($me.val())+1);
         };
         //$label.hide();
       };

       /*-------------------------------
        * Subtracts 1 from whatever
        * value is currently in the control
        *------------------------------*/

       function sub1()
       {
         if ($me.val() != ''){
           if (parseInt($me.val()) > 1){
             $me.val(parseInt($me.val())-1);
             //$label.hide();
          }
        }
       };

	   // Create up/down buttons
       // Note: The &nbsp is to appease Safari

       if ($opts.numIncDecButtons)
       {
         $buttonSub1 = $("<button class='ui-spedmon-box-inline-ctrl' id='"+ meid + "_but_sub_1' type='button'>&nbsp</button>").insertBefore($buttonOK)
           .css({height:parseInt($me.outerHeight())})
           .button({icons: {primary: "ui-icon-minus"}, text: false})
           .hover (function() {$me.addClass("ui-state-highlight")}, function(){$me.removeClass("ui-state-highlight");});

         $buttonSub1.attr('title','Click to decrement');

         $buttonAdd1 = $("<button class='ui-spedmon-box-inline-ctrl' id='"+ meid + "_but_add_1' type='button'>&nbsp</button>").insertAfter($buttonSub1)
           .css({height:parseInt($me.outerHeight())})
           .button({icons: {primary: "ui-icon-plus"}, text: false})
           .hover (function() {$me.addClass("ui-state-highlight")}, function(){$me.removeClass("ui-state-highlight");});

         $buttonAdd1.attr('title','Click to increment');
       }

       if ((!$opts.showControls) && ($opts.numIncDecButtons))
       {
          $buttonSub1.hide();
          $buttonAdd1.hide();
       }

        // Bindings

        /* Increment/decrement number on mouse wheel  */

        if ($opts.numIncDecMouseWheel)
        {
          $me.bind('mousewheel',function(event,delta){
            var dir = delta > 0 ? 'u' : 'd';
            vel = Math.abs(delta);
            if (dir == 'u') add1();
            if (dir == 'd') sub1();
            return false;});
        }

        // Setup click and hold to increment/decrement numbers

        if ($opts.numIncDecButtons)
        {
          $buttonAdd1.mousehold(50,function(){add1()});
          $buttonSub1.mousehold(50,function(){sub1()});
        }

        // Keypress handler takes care of only allowing numbers and certain other keys

       $me
          .keypress(function(e){
		    var kc = $.spedmonWebUI.whatKeycode(e);

            /* Increment decrement numbers on up/down arrows */

            if ($opts.numIncDecUpDownArrow)
            {
              if (kc == 38) {add1();return false;}
			  if (kc == 40) {sub1();return false;}
			}

            if ($.spedmonWebUI.keycodeIsNumber(kc) == false)
            {
              $mestatusicon.addClass("ui-icon-info");
              $mestatusicon.attr('title','Numbers only please');
		      $mestatus.show();
			  return false;
			}
            else
            {
              $mestatusicon.removeClass("ui-icon-info");
              $mestatusicon.attr('title','');
		      $mestatus.hide();
			  return true;
			}
          });
      });
   }

  /*-------------------------------
   * Option defaults
   *------------------------------*/

  $.fn.spedmonNumberbox.defaults = {
      showControls:true
    , showOK:true
    , numIncDecButtons:true
    , numIncDecUpDownArrow:true
    , numIncDecMouseWheel:true
  };

})(jQuery);

/***************************************************************************
 * spedmon.Datebox */
/**
 * A replacement for a text input.  Transforms an <input/> into an
 * datebox with a watermark that displays the controls title when
 * no value has been provided.
 ***************************************************************************/

  ;(function($){
  $.fn.spedmonDatebox = function(options){

   var $opts; // Control options

   /*-------------------------------
    * Grab options
    *------------------------------*/

	$opts = $.extend({},$.fn.spedmonDatebox.defaults,options);

	/*-------------------------------
     * Tie into return chain
     *------------------------------*/

    return this.each(function() {

      var $me = $(this);

     /*-------------------------------
      * If this control is already
      * visible, get out.
      *
      * Note: This is a workaround for
      * if we have both a visible and
      * a hidden control.
      *------------------------------*/
	  if ($opts.useVisibleWorkaround == true)
	  {
        if (!$me.is(":visible")) return;
	  }
      
     /*-------------------------------
      * Create a textbox control
      *------------------------------*/

      $(this).spedmonTextbox(options);

     /*-------------------------------
      * Get references from textbox
      *------------------------------*/

      var textBox       = $($me).data('spedmonTextbox');
	  var $buttonOK     = textBox.buttonOK;
	  var $mecont       = textBox.meCont;
	 // var $label        = textBox.meLabel;
	  var $mestatus     = textBox.meStatus;
	  var $mestatusicon = textBox.meStatusIcon;
	  var meid          = textBox.meid;

      /*-------------------------------
       * Hide watermark if date value
       * is present on load and provide
       * the OK button with a bit more
       * space.
       *------------------------------*/

      $me.val(options.dateText);
      //if ($me.val()){$label.hide();}
      $($buttonOK).addClass('mba-web-ui-control-option-button');	   


     var $altField;

     if (options.altField)
     {
       var altfldid = "#" + options.altField;
       $altField = $(altfldid);
     }

     /*-------------------------------
      * Create datebox control
      *------------------------------*/

      if (!$opts.multidate)
	  {
      /*-------------------------------
        * If this is a single date
        * selection use the jquery
        * ui datepicker.
        *------------------------------*/

        $me.datepicker({onClose:function(dateText,inst){
                         $opts.onDateSelectSingle(dateText, inst);
                         if (dateText != ''){
                           //$label.hide();
                           jQuery.spedmonWebUI.fireDataSelected($me,{id:$me.val(),label:$me.val(),value:$me.val()});
                         }
                         else
                         {
                          // $label.show();
                         }
                       },
                       changeMonth: true,
                       changeYear: true,
                       showOn: 'button',
                       numberOfMonths:options.numMonths,
                       buttonImageOnly: false,
                       buttonImage:'images/calendar.jpg',
                       buttonText : 'Select a Date',
                       dateFormat:options.dateFormat,
                       /*defaultDate: options.defaultDate,*/
                       minDate:options.minDate,
                       maxDate:options.maxDate});


	   }
       else
       {

         /*-------------------------------
          * If this is a multi date
          * selection use Keith Wood's
          * http://keith-wood.name/datepick.html
          * jquery datepick control
          *------------------------------*/

          /*-------------------------------
           * Keep its value updated with
           * the values in the textbox
           * and visa versa
           *------------------------------*/

          $mecont.bind('spedmoninputdata',function(){

            /*-------------------------------
             * Get the dates from the textbox
             * The dates will either have been
             * entered via the control or
             * entered by the user
             *------------------------------*/

            var datesStr = $me.val();

            /*-------------------------------
             * Parse the dates into
             * an array of strings
             *------------------------------*/

            var datesArrStr = datesStr.split(',');

            /*-------------------------------
             * And now create an array of
             * dates
             *------------------------------*/

            var datesArrVal = [];
            $.each(datesArrStr,function(key,value){
              var dv = new Date();
              dv = Date.parse(value);
              datesArrVal[key] = dv;
            });

            /*-------------------------------
             * Reset date control values to
             * contents of date array.
             * This will ensure we keep in
             * in synch
             *------------------------------*/

            $me.datepick ('setDate', datesArrVal);

            /*-------------------------------
             * If we are maintaining an alt
             * field, update it.
             *
             * Note: This is NOT the alt field
             * that the picker uses.
             *------------------------------*/

            if ($altField)
            {

              $altField.val('');
              var datesSel = $me.datepick('getDate');

              if (datesSel)
              {
                var dsl = datesSel.length;
				if (dsl > 0)
                {
                  var firstDate = $.datepick.formatDate(datesSel[0]);
				  var lastDate  = $.datepick.formatDate(datesSel[dsl-1]);
                  if ($opts.multiDateAltFieldUseFirstOrLastSelected == 'first') $altField.val(firstDate);
				  if ($opts.multiDateAltFieldUseFirstOrLastSelected == 'last')  $altField.val(lastDate);
                }
              }
            }
         });


         /*-------------------------------
          * Generate control
          *
          * Note: The datepick control
          * has support for jQuery UI
          * themeroller themes, but it is
          * incompatible with the latest
          * version of UI.  Therefore we
          * are not currently using this
          * option.
          *------------------------------*/

          $me.datepick({multiSelect: 999,
                        monthsToShow: options.numMonths,
                        monthsOffset: options.monthsOffset,
                        defaultDate: options.defaultDate,
                        showOnFocus: false,
                        minDate:options.minDate,
                        maxDate: options.maxDate,
                        dateFormat:options.dateFormat,
                        onClose:function(dates){$opts.onDateSelectMulti(dates);},
                        onSelect: function(dates){if (dates.length > 0) {/*$label.hide();*/} else {/*$label.show();*/}},
                        showTrigger: '<button type="button" class="trigger"><img src="images/calendar.gif" alt="Popup"></button>'});

         /*-------------------------------
          * Generate clear button
          *------------------------------*/

         var $buttonClr;

         $buttonClr = $("<button class='ui-spedmon-box-inline-ctrl mba-web-ui-control-option-button' id='"+ meid + "_but_clear' type='button'>Clear Date(s)</button>").insertBefore($buttonOK)
           .css({height:parseInt($me.outerHeight())})
           .button()
           .click(function(){$me.datepick('setDate',[]);$me.val('');/*$label.show();*/ if ($altField) $altField.val(''); $opts.onDateClear();})
           .hover (function() {$me.addClass("ui-state-highlight")}, function(){$me.removeClass("ui-state-highlight");});
         $buttonClr.css('margin-left','.5em');

      }
   });
 };

  /*-------------------------------
   * Option defaults
   *------------------------------*/

  $.fn.spedmonDatebox.defaults = {
      useVisibleWorkaround:true
	, multidate:false
    , showOK:true
    , altField:''
    , multiDateAltFieldUseFirstOrLastSelected:'first'
	, dateFormat:'mm/dd/yy'
    , defaultDate:'+0'
    , minDate: ''
    , maxDate: '+0'
	, numMonths:3
    , onDateSelectSingle:function(dateText, inst){}
    , onDateSelectMulti:function(dates){}
    , onDateClear:function(){}
  };

})(jQuery);

/***************************************************************************
 * spedmon.DateRangeBox */
/**
 * A replacement for a text input.  Transforms an <input/> into an
 * date range box with a watermark that displays the controls title when
 * no value has been provided.
 *
 * Note: The underlying jQuery UI plugin daterangepicker is a little buggy
 * The following limitations have been reported:
 *   - You cannot have more than one instance per page
 ***************************************************************************/

;(function($){
  $.fn.spedmonDateRangeBox = function(options){

   var $opts;         // Control options

   /*-------------------------------
    * Grab options
    *------------------------------*/

    $opts = $.extend({},$.fn.spedmonDateRangeBox.defaults,options);
    $opts.useHover = false; // Remove default styling

	/*-------------------------------
     * Tie into return chain
     *------------------------------*/

    return this.each(function() {

	  /*-------------------------------
       * Create textbox
       *------------------------------*/

      var $me = $(this);
	  $(this).spedmonTextbox($opts);

	  /*-------------------------------
       * Get references from textbox
       *------------------------------*/

      var textBox       = $($me).data('spedmonTextbox');
	  var $buttonOK     = textBox.buttonOK;
	  var $mecont       = textBox.meCont;
	 // var $label        = textBox.meLabel;
	  var $mestatus     = textBox.meStatus;
	  var $mestatusicon = textBox.meStatusIcon;
	  var meid          = textBox.meid;

      /*-------------------------------
       * Add css class for styling
       *------------------------------*/

      $($mecont).addClass($opts.dateRangeCssClass);

      /*-------------------------------
       * Hide watermark if value is
       * present on load
       *------------------------------*/

      //$me.val(options.dateText);
      //if ($me.val()){$label.hide();}


      /*-------------------------------
       * Create range picker
       *------------------------------*/


      //
      var nestedDateRangePickerOpts =  {
        onClose:function(){
          //if ($me.val()) $label.hide() ; else $label.show();
        },

        onChange: function () {
            /* EAW: Fire dataselected event with proper payload*/ 
            var _drv = $($me).val();
            var _dItemObj = {};
            _dItemObj.id = meid;
            _dItemObj.label = _drv;
            _dItemObj.value = _drv;
            _dItemObj.advanceStep = true;
            $.spedmonWebUI.fireDataSelected($me, _dItemObj);
          
        },

        //
        earliestDate:Date.parse('1/1/1990'),

        datepickerOptions:{
		          changeMonth: true,
		          changeYear: true
		          }
          }

          if (!( $opts.allowFutureDateSelection )) {

             nestedDateRangePickerOpts.datepickerOptions.maxDate =   '+0';
             nestedDateRangePickerOpts.latestDate = 'Today';
          }

          $me.daterangepicker( nestedDateRangePickerOpts );

      });
  };

  /*-------------------------------
   * Option defaults
   *------------------------------*/

  $.fn.spedmonDateRangeBox.defaults = {
      showControls:true
	  ,showOK:true
      ,dateRangeCssClass:'ui-spedmon-date-range-cont'
  };

})(jQuery);

/***************************************************************************
 * spedmon.Timebox */
/**
 * A replacement for a text input.  Transforms an <input/> into an
 * timebox with a watermark that displays the controls title when
 * no value has been provided.
 ***************************************************************************/

  ;(function($){
  $.fn.spedmonTimebox = function(options){

   var $opts; // Control options

   /*-------------------------------
    * Grab options
    *------------------------------*/

	$opts = $.extend({},$.fn.spedmonTimebox.defaults,options);

	/*-------------------------------
     * Tie into return chain
     *------------------------------*/

    return this.each(function() {

      var $me = $(this);

     /*-------------------------------
      * If this control is already
      * visible, get out.
      *
      * Note: This is a workaround for
      * if we have both a visible and
      * a hidden control.
      *------------------------------*/

     if ($opts.dontCreateIfHidden == true) {
	   if (!$me.is(":visible")) return;
	 }

     /*-------------------------------
      * Create a textbox control
      *------------------------------*/
      $(this).spedmonTextbox(options);

     /*-------------------------------
      * Get references from textbox
      *------------------------------*/

      var textBox       = $($me).data('spedmonTextbox');
	  var $buttonOK     = textBox.buttonOK;
	  var $mecont       = textBox.meCont;
	  //var $label        = textBox.meLabel;
	  var $mestatus     = textBox.meStatus;
	  var $mestatusicon = textBox.meStatusIcon;
	  var meid          = textBox.meid;


     /*-------------------------------
      * Function to finds and style open
	  * button
      *------------------------------*/

     var fnFormatButton = function(){
	   var $buttonOpen = $me.siblings('button.ui-datepicker-trigger');
       $buttonOpen.button({icons:{primary: "ui-icon-clock"},text:false});
       $buttonOpen.css('margin-left','2px');
	 }

     /*-------------------------------
      * Create timebox control
      *------------------------------*/

     $me.timepicker( {  showOn: "button"
	                  , buttonImageOnly: false
		  			  , buttonText: "Select Time"
		 			  , timeOnlyTitle: "Select A Time"
					  , controlType:'select'
					  , timeFormat:'h:mm tt'
					  , minTime:$opts.minTime
					  , maxTime:$opts.maxTime
					  , onSelect:function(datetimeText,inst){ /*$label.hide();*/}
					  , afterInject:function(){fnFormatButton();}
					  , onClose:function(timeText, inst){
                       if (timeText != ''){
                         /*$label.hide();*/
                         jQuery.spedmonWebUI.fireDataSelected($me,{id:$me.val(),label:$me.val(),value:$me.val()});
                       }
                       else
                       {
                         /*$label.show();*/
                       }
                     }
                   });

	/*-------------------------------
     * Initial open button style
     *------------------------------*/

    fnFormatButton();

   });
 };

  /*-------------------------------
   * Option defaults
   *------------------------------*/

  $.fn.spedmonTimebox.defaults = {
    dontCreateIfHidden:true
  };
})(jQuery);

/***************************************************************************
 * spedmon.Calendarbox */
/**
 * A replacement for a text input.  Transforms an <div/> into a 12 month
 * calendar.
 ***************************************************************************/

 ;(function($){
 $.fn.spedmonCalendarbox = function(options){

   /*============================================================
    * Merge options
    *============================================================*/

   var $opts;
   $opts = $.extend({},$.fn.spedmonCalendarbox.defaults,options);

   /*============================================================
    * Tie into return (method) chain
    *============================================================*/

   return this.each(function() {

     /*============================================================
      * Get a reference to the original element we are enhancing.
      *============================================================*/

     var $me = $(this);

     /*============================================================
      * Enhance the original element into a textbox.
      * We will use this textbox to store a delimited string
      * of selected (or typed in) dates
      *============================================================*/

     $(this).spedmonTextbox(options);

     /*============================================================
      * Get references to parts of the new textbox.
      * We will use this to further enhance it.
      *============================================================*/

     var textBox       = $($me).data('spedmonTextbox');
	 var $buttonOK     = textBox.buttonOK;
	 var $mecont       = textBox.meCont;
	 //var $label        = textBox.meLabel;
	 var $mestatus     = textBox.meStatus;
	 var $mestatusicon = textBox.meStatusIcon;
	 var meid          = textBox.meid;

     /*============================================================
      * Create a container for everything
      *============================================================*/

     $mecont.wrap("<div id='" + meid + "_all_cont'></div>");

     /*============================================================
      * Add indentifying class
      *============================================================*/

     $me.addClass($.spedmonWebUI.field.CTRL_TYPE_CALENDAR_BOX);

     /*===========================================================
      * Create markup to hold our calendar
      *============================================================*/

     /*-------------------------------
      * Containing div
      *------------------------------*/

     var $calCont = $("<div id='" + meid + "_cal_cont' style='width:100%;margin-top:2em;'></div>").insertAfter($mecont);

     /*-------------------------------
      * Div to hold inline calendar
      *------------------------------*/

     var $cal = $("<div id='" + meid + "_cal' style='width:100%'></div>").appendTo($calCont);

     /*============================================================
      * Define ondate handler.
      *
      * The function is called for each date displayed and
      * receives the date as a parameter along with a bool
      * indicating whether the date is in the main month being shown.
      *
      * It needs to return an object with the following
      * attributes (all optional):
      *
      * - selectable (boolean) true  = date is selectable
      *                        false = not selectable
      * - dateClass  (string)  any CSS class(es) to apply to this date
      * - title      (string)  a tooltip for this date
      * - content    (string)  content for this date to replace the
      *                        basic day number
      *============================================================*/

     var ondate = function(date,inMonthShown) {

       var day = {selectable:true};

       /*-------------------------------
        * Are we allowed to display
        * weekends?
        *------------------------------*/

       if ($opts.noWeekends)
       {
         var nw =  $.datepick.noWeekends(date);
         day.selectable = nw.selectable;
       }

       /*-------------------------------
        * Are any of the dates on
        * the unavailable dates list?
        *------------------------------*/

       var dateStr = $.datepick.formatDate($opts.dateFormat, date); /* Use datepick function */

       if ($.inArray(dateStr, $opts.unavailableDates) != -1)
       {
         day.selectable = false;
       }

       if (day.selectable == true)
         day.dateClass = 'ui-calendar-box-can-select';
       else
         day.dateClass = 'ui-calendar-box-no-select';

       /*-------------------------------
        * Return object that determines
        * if day is selectable
        *------------------------------*/

        return day;
     };

     /*============================================================
      * Define onshow handler.
      *
      * This is called just before the datepicker is shown and
      * receives the completed datepicker division as a jQuery
      * object and the current instance settings as parameters.
      *============================================================*/

     var onshow = function(picker,inst){

       if ($opts.displayWorkaround)
       {
         /* Tweak style to better fit our layouts */

         picker.attr('style','width:92%;margin:0 auto;');
         picker.find('div.ui-datepick-group').attr('style','margin-left:1.5em;margin-top:1.5em;');

         /* Remove highlight for todays date to correct issue with selection */

         picker.find('table.ui-datepick-calendar tbody tr td a.ui-state-highlight').removeClass('ui-state-highlight');
         picker.find('table.ui-datepick-calendar tbody tr td span.ui-state-highlight').removeClass('ui-state-highlight');

         /* Hide dates we do not want selected */

         picker.find('td span.ui-calendar-box-no-select').removeClass('ui-state-hover').addClass('ui-state-disabled');//.hide();
         picker.find('td a.ui-calendar-box-no-select').removeClass('ui-state-hover').addClass('ui-state-disabled');//.hide();

         /* Show dates we do want selected */

         picker.find('td span.ui-calendar-box-can-select').removeClass('ui-state-hover').removeClass('ui-state-disabled');//.show();
         picker.find('td a.ui-calendar-box-can-select').removeClass('ui-state-hover').removeClass('ui-state-disabled');//show();
       }

     };

     /*============================================================
      * Define onsel handler.
      *
      * This function is called when each date is selected and
      * receives the currently selected dates (Date[])
      *============================================================*/

     var onsel = function(dates){

       /*-------------------------------
        * If we have dates selected
        * hide the placeholder text
        * in our textbox
        *------------------------------*/

       //if (dates.length > 0) $label.hide(); else $label.show();

     };

     /*============================================================
      * Create 'refresh' command extension
      *============================================================*/

     var newCommands = $.extend({}, $.datepick.commands);

     newCommands.refresh = {
       text: 'updateText', status: 'updateStatus',
       keystroke: {keyCode: 82, altKey:true}, /* alt-R */
       enabled: function(inst) { return true; },
       date: function(inst) { return null;},
       action: function(inst) { $.datepick._update(inst, false);}
     };

     /*============================================================
      * Create the calendar itself
      *
      * We are using Keith Wood's datepick plugin
      * http://keith-wood.name/datepickRef.html
      *============================================================*/

     $cal.datepick({renderer:$.datepick.themeRollerRenderer,
                    altField:$me,
                    useMouseWheel:false,
                    multiSeparator:$opts.multiSeparator,
                    multiSelect:$opts.multiSelect,
                    monthsToShow:$opts.monthsToShow,
                    defaultDate:$opts.defaultDate,
                    minDate:$opts.minDate,
                    maxDate:$opts.maxDate,
                    fixedWeeks:true,
                    dateFormat:$opts.dateFormat,
                    onDate:ondate,
                    onShow:onshow,
                    onSelect:onsel,
                    commands:newCommands
                  });

     /*============================================================
      * Capture events such as someone entering dates in the text
      * box control.  This keeps the calendar control in synch with
      * the text box.
      *============================================================*/

     $mecont.bind('spedmoninputdata',function(){

       /*-------------------------------
        * Get the dates from the textbox
        * the dates will either have been
        * entered via the control or
        * entered by the user
        *------------------------------*/

       var datesStr = $me.val();

       /*-------------------------------
        * Parse the dates into
        * an array of strings
        *------------------------------*/

       var datesArrStr = datesStr.split(',');

        /*-------------------------------
         * And now create an array of
         * dates
         *------------------------------*/

        var datesArrVal = [];
        $.each(datesArrStr,function(key,value){
          var dv = new Date();
          dv = Date.parse(value);
          datesArrVal[key] = dv;
        });

        /*-------------------------------
         * Reset date control values to
         * contents of date array.
         * This will ensure we keep in
         * in synch
         *------------------------------*/

        $cal.datepick('setDate', datesArrVal);

      });


     /*============================================================
      * Create function to help solve issues with selections
      *============================================================*/

     var selectionWorkarounds = function()
     {

       $cal.find('td a.ui-state-active').removeClass('ui-state-active');
       $cal.find('td span.ui-state-active').removeClass('ui-state-active');

       $cal.find('td a.ui-state-hover').removeClass('ui-state-hover');
       $cal.find('td span.ui-state-hover').removeClass('ui-state-hover');

       $cal.find('td a.ui-state-highlight').removeClass('ui-state-highlight');
       $cal.find('td span.ui-state-highlight').removeClass('ui-state-highlight');

       $cal.find('td span.ui-calendar-box-no-select').removeClass('ui-state-hover').addClass('ui-state-disabled'); //.hide();
       $cal.find('td a.ui-calendar-box-no-select').removeClass('ui-state-hover').addClass('ui-state-disabled'); //.hide();

       $cal.find('td span.ui-calendar-box-can-select').removeClass('ui-state-hover').removeClass('ui-state-disabled');//.show();
       $cal.find('td a.ui-calendar-box-can-select').removeClass('ui-state-hover').removeClass('ui-state-disabled');//.show();

     }

     /*============================================================
      * Create function to clear dates selected
      *============================================================*/

      var cls = function(){

       /*-------------------------------
        * Call native clear
        *------------------------------*/

       $cal.datepick('performAction','clear');

       /*-------------------------------
        * Display placeholder text
        *------------------------------*/

       //$label.show();

       /*-------------------------------
        * Themeroller style workaround
        *------------------------------*/

       if ($opts.displayWorkaround) selectionWorkarounds();

     };

     /*============================================================
      * Create function to reset unavailable dates
      *============================================================*/

     var setUnDates = function(newUnDates){
       cls();
       $opts.unavailableDates = newUnDates;
       $cal.datepick('performAction','refresh');
     };

     /*============================================================
      * Create function to set min and max dates
      *============================================================*/

     var setMinMaxDates = function(minDate,maxDate){

       cls();
       var $newOpts = {};
       $newOpts.minDate     = minDate;
       $newOpts.maxDate     = maxDate;
       $newOpts.defaultDate = minDate;
       $cal.datepick('option', $newOpts);
       $cal.datepick('performAction','refresh');
     };

     /*============================================================
      * Create our clear button.
      *============================================================*/

     var $buttonClear;

     $buttonClear = $("<button id='"+ meid + "_but_clear' type='button' style='height: 31px;'>Clear</button>")
       .insertBefore($buttonOK)
       .button({icons:{primary: "ui-icon ui-icon-trash"}})
       .hover (function() {$me.addClass("ui-state-highlight")}, function(){$me.removeClass("ui-state-highlight");})
       .css('margin-left','.5em')
       .click(function(){cls();});

     /*============================================================
      * Pass in date values from input (if they exist)
      *============================================================*/

     var aDates = $me.val().split($opts.multiSeparator);
     if (aDates)
       $cal.datepick('setDate', aDates);

     /*============================================================
      * Create references for helper functions to use
      *============================================================*/

	 var calCtrl = {};
     calCtrl.meid                = meid;
     calCtrl.cal                 = $cal;
     calCtrl.setUnavailableDates = setUnDates;
     calCtrl.setMinMaxDates      = setMinMaxDates;
     calCtrl.clear               = cls;

	 $.data(this, 'spedmonCalendarbox', calCtrl);

   });
 };

  /*============================================================
   * Parameter Defaults
   *============================================================*/

  $.fn.spedmonCalendarbox.defaults = {
    dateFormat:'mm/dd/yyyy',
    defaultDate:'-1y',
    minDate: '-1y',
    maxDate: '+0',
    multiSeparator:',',
    multiSelect: 365,
    monthsToShow:[4,3],
    unavailableDates:[],
    noWeekends:true,
    displayWorkaround:true,
    onDateClearBefore:function(){},
    onDateClearAfter:function(){},
    onDateSelectBefore:function(date,inMonth){},
    onDateSelectAfter:function(date,inMonth){}
  };

  /*============================================================
   * Helper functions
   *============================================================*/

  /*-------------------------------
   * Change min and max dates
   *------------------------------*/

  $.fn.spedmonCalendarbox_setMinMaxDates = function(minDate,maxDate){
    return this.each(function() {
      var $me      = $(this);
      var $calCtrl = $($me).data('spedmonCalendarbox');
      $calCtrl.setMinMaxDates(minDate,maxDate);
    });
  };

  /*-------------------------------
   * Change unavailable dates
   *------------------------------*/

  $.fn.spedmonCalendarbox_setUnavailableDates = function(dates){
    return this.each(function() {
      var $me      = $(this);
      var $calCtrl = $($me).data('spedmonCalendarbox');
      $calCtrl.setUnavailableDates(dates);
    });
  };

  /*-------------------------------
   * Clear
   *------------------------------*/

  $.fn.spedmonCalendarbox_clear = function(dates){
    return this.each(function() {
      var $me      = $(this);
      var $calCtrl = $($me).data('spedmonCalendarbox');
      $calCtrl.clear();
    });
  };


})(jQuery);


/***************************************************************************
 * spedmon.link */
/**
 * Link control
 ***************************************************************************/

;(function($){
  $.fn.spedmonLink = function(options){

   /*-------------------------------
    * Grab options
    *------------------------------*/

    var $opts;
    $opts = $.extend({},$.fn.spedmonLink.defaults,options);

   /*-------------------------------
    * Tie into return chain
    *------------------------------*/

    return this.each(function() {

      var $link      = $(this);
	  var url        = $link.attr('href');
      var linkmode   = $opts.linkmode;
      var beforeOpen = $opts.beforeOpen;

      $link.click(function() {
        beforeOpen();
	    if (linkmode == 1) $.spedmonWebUI.openURL(url);
        if (linkmode == 2) $.spedmonWebUI.gotoURL(url);
        return false;
	  });

	});
  };

  /*-------------------------------
   * Option defaults
   *------------------------------*/

  $.fn.spedmonLink.defaults = {
    linkmode:1,
    beforeOpen:function(){}
  };
})(jQuery);


/***************************************************************************
 * spedmon.ButtonMenuItemLink */
/**
 * Renders a button to click on a menu link if the link exists.
 * If the link does not exist, nothing is shown.
 *
 * The intended application of this control is to only display buttons
 * that users have access to.
 *
 * Please note: The "main menu" must be present in order for this to work
 *
 ***************************************************************************/

;(function($){
  $.fn.spedmonButtonMenuItemLink = function(options){

   /*-------------------------------
    * Grab options
    *------------------------------*/

    var $opts;
    $opts = $.extend({},$.fn.spedmonButtonMenuItemLink.defaults,options);

   /*-------------------------------
    * Tie into return chain
    *------------------------------*/

    return this.each(function() {

      var $link = $(this);

      /*-------------------------------
       * Get menu item id and test if
       * the menu item exists on screen
       *------------------------------*/

      var menuitemid     = $opts.menuitemid;
      var lnk            = '#' + menuitemid;
      var lnktype        = $opts.menuitemlinktype;
      var useJqueryUI    = $opts.useJqueryUI;
      var menuitemexists = false;
      
      if ($(lnk).length > 0)
        menuitemexists = true;

      /*-------------------------------
       * If it does exist carry on
       *------------------------------*/

      if (menuitemexists)
      {

	    /*-------------------------------
         * Render button and then set
         * onclick action depending
         * on link type
         *------------------------------*/

       if (useJqueryUI) {
		
          var butopts = {};
          butopts.icons = $opts.icons;
          $link.button(butopts);
          $link.addClass('ui-spedmon-menu-option-link');
		};
		
        $link.click(function() {
                 if (lnktype == 1) $.spedmonWebUI.clickMenuLink(menuitemid);          /* Triger click event on item */
            else if (lnktype == 2) $(lnk).click();                                    /* Trigger click event to open dialog */
            else if (lnktype == 3) $.spedmonWebUI.openMenuLink(menuitemid);           /* Extract url and open in new window */
            else if (lnktype == 4) $.spedmonWebUI.openMenuLinkAmdSubMode(menuitemid); /* Extract url and open in new window in app mode sub */
            else if (lnktype == 5) $.spedmonWebUI.gotoMenuLinkAmdSubMode(menuitemid); /* Extract url and open in same window using app mode sub */
            else    {}
          return false;
	    });

      }

      /*-------------------------------
       * If it does not exist
       * remove the link button from
       * the screen.
       *------------------------------*/

      else
      {		
		if ($opts.noLinkInMenuThenRemoveParentLi == true) 
		{
	  	  $($link).parent('li').remove();
		}
		
		$link.remove();		
      }
	});
  };

  /*-------------------------------
   * Option defaults
   *------------------------------*/

  $.fn.spedmonButtonMenuItemLink.defaults = { 
    noLinkInMenuThenRemoveParentLi:false
	,useJqueryUI:true
  };

 })(jQuery);



/***************************************************************************
 * spedmon.detail */
/**
 * Detail list item
 ***************************************************************************/

;(function($){

   /*-------------------------------
    * Enhances the following markup
    * <li class="detail">
    *   <a class="detail" href="">
    *     <img class="detail" src=""/>
    *     <span class="detail">
            Message
          </span>
    *   </a>
    * </li>
    *------------------------------*/

  $.fn.spedmonDetail = function(options){

   /*-------------------------------
    * Grab options
    *------------------------------*/

    var $opts;
    $opts = $.extend({},$.fn.spedmonDetail.defaults,options);

   /*-------------------------------
    * Tie into return chain
    *------------------------------*/

    return this.each(function() {



	  });
    };

  /*-------------------------------
   * Option defaults
   *------------------------------*/

  $.fn.spedmonLink.defaults = {
  };

})(jQuery);

/***************************************************************************
 * spedmon.CheckBox */
/**
 * Checkbox control.
 ***************************************************************************/

;(function($){

  $.fn.spedmonCheckBox = function(options){

   /*-------------------------------
    * Grab options
    *------------------------------*/

    var $opts;
    $opts = $.extend({},$.fn.spedmonCheckBox.defaults,options);

   /*-------------------------------
    * Tie into return chain
    *------------------------------*/

    return this.each(function() {

	  var $me;            // This control (input)
      var meid;           // This controls id
      var meval;          // This controls value (initial)
      var checkboxCtrl;   // New check box control
      var meid_checkbox;  // New checkbox control id

      /*-------------------------------
       * Get id and value from original
       * input
       *------------------------------*/

      $me   = $(this);
	  meid  = $me.attr('id');
      meval = $(this).val();

      /*-------------------------------
       * Enhance original input into
       * spedmonInput.
       *
       * Note:  We place a call
       * to toggleValue() in the
       * onValueSet delegate.
       *
       * This should take care of
       * properly reseting the
       * checkbox control to the
       * original inputs default value.
       *------------------------------*/

      var iopts = {useLabel:false,
                   useHover:false,
                   useBorder:false,
                   privateEntry:false,
                   onEnterDataSelect:false,
                   onBlurDataSelect:false,
                   onValueSet:function(){var nv = $('#' + meid).val(); toggleValue(nv);}
      };

      $(this).spedmonInput(iopts);
      $(this).hide();

      /*-------------------------------
       * Create HTML checkbox control
       *------------------------------*/

      meid_checkbox = meid + '_checkbox_ctrl';
      $checkboxCtrl = $('<input id="' + meid_checkbox + '" type="checkbox" class="' + $.spedmonWebUI.field.CTRL_TYPE_DATA_CHECK_BOX + ' ' + $.spedmonWebUI.field.NO_SUBMIT + '"></input>').insertAfter($me);
      
	  /*------------------------------
        * Add class to indicate this 
	    * control is for data entry
		* primary tasks.
        *------------------------------*/

	  $($checkboxCtrl).addClass($.spedmonWebUI.field.DATA_ENTRY_PRIMARY);
       
      /*-------------------------------
       * Wire up click event to toggle
       * value
       *------------------------------*/

      $('#' + meid_checkbox).click(function(){
        var isChecked = $('#' + meid_checkbox).is(':checked');
        toggleValue(isChecked);
      });

      /*-------------------------------
       * Wire up change event to toggle
       * value
       *------------------------------*/

      $('#' + meid_checkbox).change(function(){
        var isChecked = $('#' + meid_checkbox).is(':checked');
        toggleValue(isChecked);
      });

      /*-------------------------------
       * Call toggle to synch values for
       * initial creation.
       *------------------------------*/

      toggleValue(meval);

     /*-------------------------------
      * Helper functions
      *------------------------------*/

      function toggleValue(newvalue)
      {

        /*-------------------------------
         * Sets original input and
         * checkbox control values to
         * newvalue.
         *------------------------------*/

        var nvb = $.spedmonWebUI.evaluateFlag(newvalue);

        // Toggle input

        if (nvb)
          $('#' + meid).val('true');
        else
          $('#' + meid).val('false');

        // Toggle checkbox

        $('#' + meid_checkbox).prop("checked", nvb);

        // Fire data selected

        if ($opts.fireDataSelected == true)
        {
          if (nvb)
            jQuery.spedmonWebUI.fireDataSelected($me,{id:meid,label:"Yes",value:$me.val()});
          else
            jQuery.spedmonWebUI.fireDataSelected($me,{id:meid,label:"No",value:$me.val()});
        }
      }

    });
  };

  /*-------------------------------
   * Option defaults
   *------------------------------*/

  $.fn.spedmonCheckBox.defaults = {
    fireDataSelected:true
  };

})(jQuery);

/***************************************************************************
 * spedmon.RadioBox */
/**
 * Radio box
 ***************************************************************************/

;(function($){

  $.fn.spedmonRadioBox = function(options){

   /*-------------------------------
    * Grab options
    *------------------------------*/

    var $opts;
    $opts = $.extend({},$.fn.spedmonRadioBox.defaults,options);

   /*-------------------------------
    * Tie into return chain
    *------------------------------*/

    return this.each(function() {

	  var $me;            // This control (input)
      var meid;           // This controls id
      var meval;          // This controls value (initial)

      /*-------------------------------
       * Get id and value from original
       * input
       *------------------------------*/

      $me   = $(this);
	  meid  = $me.attr('id');
      meval = $(this).val();

      /*-------------------------------
       * Hide original input
       *------------------------------*/

      $(this).hide();

      /*-------------------------------
       * Create jQuery UI buttonset
       *------------------------------*/

      var meid_radiobox_cont = meid + '_radiobox_cont';   // Generate contextual id for container
      var meid_radiobox_ctrl = meid + '_radiobox_ctrl';   // Generate contextual id for control
      var meid_radiobox_name = meid + '_radiobox_name';   // Generate contextual name

      // Open container

      var rboxmrkup = '<div class="ui-spedmon-box-radio-box-container ' + $opts.additionalCssClassNameForContainer + '" id="' + meid_radiobox_cont + '">';

      // Add Title

      if ($opts.renderLabel)
	  {
	    if ($opts.labelIsSpan == true)
	    {
	      /* Backwards compatible with previous code that may be expecting title to be in a span */
		  rboxmrkup = rboxmrkup + '<span class="ui-spedmon-box-radio-box-label">' + $me.attr('title') + ': </span>';
        }
	    else
	    {
	      rboxmrkup = rboxmrkup + '<label class="mba-web-ui mba-web-ui-inline ui-spedmon-box-radio-box-label">' + $me.attr('title') + ': </label>';
        }
      }
	  
	  var rboxcss = 'ui-spedmon-box-radio-box-options-container';
	  
	  if ($opts.displaySelectionsVertical == true) {
	    rboxcss = rboxcss + ' ui-spedmon-box-radio-box-options-container-display-selections-vertical';
	  }
	  
	  // Open radio
    
      rboxmrkup = rboxmrkup + '<div id="' + meid_radiobox_ctrl + '" class="' + rboxcss +'">';
      
	  // Radio buttons

      $.each($opts.valueSelections, function(index, value){

        var radiobox_opt_id       = meid + '_radiobox_opt_' + index;  // Generate contextual id
        var radiobox_opt_value    = value.value;                      // Get value
        var radiobox_opt_label    = value.label;                      // Get label
        var radiobox_opt_selected = "";
        var first_opt_class = '';
		
        if (value.selected == true)
          radiobox_opt_selected = ' checked="checked"';
		
		/* Set our class for indicating what is the primary data entry control that we should focus on */
		
		if (index == 0)
		  first_opt_class = $.spedmonWebUI.field.DATA_ENTRY_PRIMARY + ' ' ;
		 else
		   first_opt_class = '';
		   
        var rboxoptmrkup = '<input type="radio" id="' + radiobox_opt_id  +
                           '" name="'  + meid_radiobox_name +
                           '" value="' + radiobox_opt_value +
						   '" title="' + radiobox_opt_label +
                           '" class="' + first_opt_class + $.spedmonWebUI.field.NO_SUBMIT + ' ' + $.spedmonWebUI.field.NO_CLEAR + ' ui-spedmon-box-radio-box-option-input "' +
                           radiobox_opt_selected  
						   + '/>'
                           + '<label class="ui-spedmon-box-radio-box-option-label" data-spedmon-radio-box-opt-label="' + radiobox_opt_label +'" data-spedmon-radio-box-opt-value="' + radiobox_opt_value +'" for="' + radiobox_opt_id  + '">' + radiobox_opt_label + '</label>';
        rboxmrkup = rboxmrkup + rboxoptmrkup;
      });

      // Close radio and control

      rboxmrkup = rboxmrkup + '</div></div>';

      // Add to document and render buttonset

      var radioboxCtrl = $(rboxmrkup).insertAfter($me).buttonset();

      /*-------------------------------
       * Internal Helper functions
       *------------------------------*/

      function selectValue(newvalue, newlabel) {

        var oldvalue = $me.val();
        $me.val(newvalue);
        $me.attr('data-selected-label', newlabel);
        $opts.onSelectValue(oldvalue, newvalue);

        // Fire data selected

        if ($opts.fireDataSelected == true) {
          jQuery.spedmonWebUI.fireDataSelected($me, { id: meid, label: newlabel, value: $me.val() });
        }
      }

      /*-------------------------------
       * Get references to child inputs
       * that were added to doc
       *------------------------------*/

      var $childCtrlInputs = $('#' + meid_radiobox_ctrl + ' input')

      /*-------------------------------
       * Wire up click event to child
       * input values to ensure we
       * get the value selected
       *------------------------------*/

      $($childCtrlInputs).click(function(){        
        var selval = $(this).val();
		var sellbl = $(this).attr('title');
		selectValue(selval,sellbl);
      });

      /*-------------------------------
       * Call select to synch values for
       * initial creation.
       *------------------------------*/

      selectValue(meval,'Value Selected');

      /*-------------------------------
       * Save references for later use
       * by helper functions and like
       *------------------------------*/

      var dataObj = {};
      dataObj.contRef            = $('#' + meid_radiobox_cont);
      dataObj.ctrlRef            = $('#' + meid_radiobox_ctrl);
      dataObj.childCtrlInputsRef = $childCtrlInputs;
      $($me).data('spedmonRadioBox', dataObj);
    });
  };

  /*-------------------------------
   * Option defaults
   *------------------------------*/

  $.fn.spedmonRadioBox.defaults = {
    onSelectValue:function(oldval,newval){return true;},
    fireDataSelected:true,
	labelIsSpan:true,
	renderLabel:true,
	displaySelectionsVertical:false,
	additionalCssClassNameForContainer:''
  };

  /***************************************************************************
   * spedmon.RadioBox_Disable */
  /**
   * Disable child inputs
   ***************************************************************************/

  $.fn.spedmonRadioBox_Disable = function () {
    return this.each(function () {
      var $me = $(this);
      var dataObj = $($me).data('spedmonRadioBox');      
        $(dataObj.childCtrlInputsRef).each(function (idx) {
            var _cinpopt = dataObj.childCtrlInputsRef[idx];
            $(_cinpopt).button('disable');
        });
    });
  };

  /***************************************************************************
   * spedmon.RadioBox_Enable */
  /**
   * Enable child inputs
   ***************************************************************************/

  $.fn.spedmonRadioBox_Enable = function () {
    return this.each(function () {
      var $me = $(this);
      var dataObj = $($me).data('spedmonRadioBox');      
        $(dataObj.childCtrlInputsRef).each(function (idx) {
            var _cinpopt = dataObj.childCtrlInputsRef[idx];
            $(_cinpopt).button('enable');            
        });
    });
  };

})(jQuery);

/***************************************************************************
 * spedmon.YesNo */
/**
 * Yes no button control
 ***************************************************************************/

;(function($){
  $.fn.spedmonYesNo = function(options){

   /*-------------------------------
    * Grab options
    *------------------------------*/

    var $opts;
    $opts = $.extend({},$.fn.spedmonYesNo.defaults,options);

   /*-------------------------------
    * Tie into return chain
    *------------------------------*/

    return this.each(function() {

	  var $me;           // This control (input)
      var meid;          // This controls id

      // Base input

      $me = $(this);
	  meid = $me.attr('id');

	  $($me).spedmonInput(options);

	  // Get references from new input

	  var input   = $($me).data('spedmonInput');
      var $mecont = input.meCont;
	  //var $label  = input.meLabel;

      var $buttonyes;
      var $buttonno;

      // Create yes/no buttons

      $buttonyes = $("<button class='ui-spedmon-box-inline-ctrl' id='"+ meid + "_but_yes' type='button' value='1'>Yes</button>").insertAfter($me).css({height:parseInt($me.outerHeight())});
      $buttonno  = $("<button class='ui-spedmon-box-inline-ctrl' id='"+ meid + "_but_no' type='button' value='0'>No</button>").insertAfter($buttonyes).css({height:parseInt($me.outerHeight())});
      
	  $($buttonyes).addClass($.spedmonWebUI.field.DATA_ENTRY_PRIMARY);
	  
	  $buttonyes.button();
	  $buttonno.button();

      // Assign bindings

      $buttonyes.bind ("click",    function(){$me.val('Yes');jQuery.spedmonWebUI.fireDataSelected($me,{id:meid,label:"Yes",value:$me.val()});});
      $buttonno.bind  ("click",    function(){$me.val('No');jQuery.spedmonWebUI.fireDataSelected($me,{id:meid,label:"No",value:$me.val()});});
      $mecont.bind    ("keypress", function(e){
	    var kc = $.spedmonWebUI.whatKeycode(e);
        // yes
        if ((kc==89) | (kc==121)){$buttonyes.click();return false;}
        // no
        if ((kc==78) | (kc==110)){$buttonno.click();return false;}
	    return false;
		});
    });
  };

  /*-------------------------------
   * Option defaults
   *------------------------------*/

  $.fn.spedmonYesNo.defaults = {
  };
})(jQuery);

/***************************************************************************
 * spedmon.YesNoUnknown */
/**
 * Yes, no, I don't know button control
 ***************************************************************************/

;(function($){
  $.fn.spedmonYesNoUnknown = function(options){

   /*-------------------------------
    * Grab options
    *------------------------------*/

    var $opts;
    $opts = $.extend({},$.fn.spedmonYesNoUnknown.defaults,options);

   /*-------------------------------
    * Tie into return chain
    *------------------------------*/

    return this.each(function() {

    var $me;           // This control (input)
      var meid;          // This controls id

      // Base input

      $me = $(this);
    meid = $me.attr('id');

    $($me).spedmonInput(options);

    // Get references from new input

    var input   = $($me).data('spedmonInput');
      var $mecont = input.meCont;
    //var $label  = input.meLabel;

      var $buttonyes;
      var $buttonno;
      var $buttonunknown;

      // Create yes/no buttons

      $buttonyes      = $("<button class='ui-spedmon-box-inline-ctrl' id='"+ meid + "_but_yes' type='button' value='1'>Yes</button>").insertAfter($me).css({height:parseInt($me.outerHeight())});
      $buttonno       = $("<button class='ui-spedmon-box-inline-ctrl' id='"+ meid + "_but_no' type='button' value='0'>No</button>").insertAfter($buttonyes).css({height:parseInt($me.outerHeight())});
      $buttonunknown  = $("<button class='ui-spedmon-box-inline-ctrl' id='"+ meid + "_but_unknown' type='button' value='Unknown'>I Don't Know</button>").insertAfter($buttonno).css({height:parseInt($me.outerHeight())});

	  $($buttonyes).addClass($.spedmonWebUI.field.DATA_ENTRY_PRIMARY);
		
      $buttonyes.button();
      $buttonno.button();
      $buttonunknown.button();

      // Assign bindings

      $buttonyes.bind ("click",    function(){$me.val('Yes');jQuery.spedmonWebUI.fireDataSelected($me,{id:meid,label:"Yes",value:$me.val()});});
      $buttonno.bind  ("click",    function(){$me.val('No');jQuery.spedmonWebUI.fireDataSelected($me,{id:meid,label:"No",value:$me.val()});});
      $buttonunknown.bind  ("click",    function(){$me.val("Unknown");jQuery.spedmonWebUI.fireDataSelected($me,{id:meid,label:"Unknown",value:$me.val()});});
      $mecont.bind    ("keypress", function(e){
      var kc = $.spedmonWebUI.whatKeycode(e);
        // yes
        if ((kc==89) | (kc==121)){$buttonyes.click();return false;}
        // no
        if ((kc==78) | (kc==110)){$buttonno.click();return false;}
      return false;
    });
    });
  };

  /*-------------------------------
   * Option defaults
   *------------------------------*/

  $.fn.spedmonYesNoUnknown.defaults = {
  };
})(jQuery);

/***************************************************************************
 * spedmon.MaleFemale*/
/**
 * Male/female button control
 ***************************************************************************/

;(function($){
  $.fn.spedmonMaleFemale = function(options){

   /*-------------------------------
    * Grab options
    *------------------------------*/
    var $opts;
    $opts = $.extend({},$.fn.spedmonMaleFemale.defaults,options);

   /*-------------------------------
    * Tie into return chain
    *------------------------------*/
    return this.each(function() {

	  var $me;           // This control (input)
      var meid;          // This controls id

      // Base input
	  $me = $(this);
	  meid = $me.attr('id');

	  $($me).spedmonInput(options);
      //$me.hide();

	  // Get references from new input
	  var input   = $($me).data('spedmonInput');
      var $mecont = input.meCont;
	  //var $label  = input.meLabel;

      var $buttonMale;
      var $buttonFemale;
      var $buttonUnknown;

      // Create male/female buttons

      $buttonMale =   $("<button class='ui-spedmon-box-inline-ctrl' id='"+ meid + "_but_yes' type='button' value='m'>Male</button>").insertAfter($me).css({height:parseInt($me.outerHeight())});
      $buttonFemale = $("<button class='ui-spedmon-box-inline-ctrl' id='"+ meid + "_but_no' type='button' value='f'>Female</button>").insertAfter($buttonMale).css({height:parseInt($me.outerHeight())});
      $buttonUnknown = $("<button class='ui-spedmon-box-inline-ctrl' id='" + meid + "_but_un' type='button' value='u'>Unknown</button>").insertAfter($buttonFemale).css({ height: parseInt($me.outerHeight()) });

	  $($buttonMale).addClass($.spedmonWebUI.field.DATA_ENTRY_PRIMARY);
	  
      $buttonMale.button();
	  $buttonFemale.button();
      $buttonUnknown.button();

      // Assign bindings

      $buttonMale.bind     ("click",  function(){$me.val('Male');jQuery.spedmonWebUI.fireDataSelected($me,{id:meid,label:"Male",value:$me.val()});});
      $buttonFemale.bind   ("click",  function(){$me.val('Female');jQuery.spedmonWebUI.fireDataSelected($me,{id:meid,label:"Female",value:$me.val()});});
      $buttonUnknown.bind  ("click", function(){$me.val('Unknown');jQuery.spedmonWebUI.fireDataSelected($me,{id:meid,label:"Unknown",value:$me.val()});});

        $mecont.bind("keypress", function (e) {
	    var kc = $.spedmonWebUI.whatKeycode(e);
        // yes
        if ((kc==77) | (kc==109)){$buttonMale.click();return false;}
        // no
        if ((kc==70) | (kc==102)){$buttonFemale.click();return false;}
        // unknown
        if ((kc == 85) | (kc == 117)) { $buttonUnknown.click(); return false; }
        return false;
		});
    });
  };

  /*-------------------------------
   * Option defaults
   *------------------------------*/

  $.fn.spedmonMaleFemale.defaults = {
  };
})(jQuery);


/***************************************************************************
 * spedmon.SelectBox */
/**
 * Transforms an <input/> into an
 * autocompleting search or combobox with a watermark that displays the
 * controls title when no value has been selected.
 * Please note that this control should only be used for datasets that
 * have a maximum of 50-100 elements.
 ***************************************************************************/

 ;(function($){

 $.fn.spedmonSelectBox = function(options) {

   /*============================================================
    * Merge options
    *============================================================*/

   var $opts;
   $opts = $.extend({},$.fn.spedmonSelectBox.defaults,options);

   /*============================================================
    * Tie into return (method) chain
    *============================================================*/

   return this.each(function() {

     /*============================================================
      * Get a reference to the original element we are enhancing.
      *============================================================*/

     var $me = $(this);

     /*============================================================
      * Placeholder reference for new input control
      *============================================================*/

     var $input = null;

     /*============================================================
      * Add indentifying class
      *============================================================*/

     $me.addClass($.spedmonWebUI.field.CTRL_TYPE_SELECT_BOX);

     /*============================================================
      * Get key attribute values
      *============================================================*/

     var meid    = $me.attr('id');
     var menm    = $me.attr('name');
     var metitle = $me.attr('title');
     var meval   = $me.val();

     /*============================================================
      * Key vars for holding name/value pairs for external ref
      *============================================================*/

     var meNames  = [];
     var meValues = [];
     var meContextLabels = [];

     /*============================================================
      * Key vars for multi select
      *============================================================*/

     var multiSelListNamesValues = [];
     var $multiSelListCont;
     var $multiSelList;
     var $multiSelCtrlsCont;
     var $multiSelCtrlOK;
     var $melbl;
     var fnUpdateMultipleSelections;
     var fnFireDataSelected;
     var fnClearData;

     var multisellistcontid    = meid + '_multi_sel_list_cont';
     var multisellistid        = meid + '_multi_sel_list';
     var multiselctrlscontid   = meid + '_multi_sel_ctrls_cont';
     var multiselctrlok        = meid + '_multi_sel_ctrl_ok_but';
     var fnLoadItem;
     var fnLoadItems;

     /*============================================================
      * Create a container for everything
      *
      * Note: For some reason we have to get a reference to the
      * control after it has been wrapped around
      *============================================================*/

     var mecontid = meid + "_all_cont";
     var meContInlineStyle = '';	 
	 var contClasses       = 'ui-spedmon-box-select-box-container';
	 
	 if ($opts.displayInline == true) 
	   contClasses = contClasses + ' ui-spedmon-box-select-box-container-disp-inline';
	 
	 if ($opts.multiSelect   == true) 
	   contClasses = contClasses + ' ui-spedmon-box-select-box-container-multi-select';
	 else 
	   contClasses = contClasses + ' ui-spedmon-box-select-box-container-single-select';

	 $($me).wrap('<div id="' + mecontid + '" class="' + contClasses + '" style="' + meContInlineStyle +'"></div>');

	 var $mecont = $("#" + mecontid);

     
	 
	 /*============================================================
      * Common functions
      *============================================================*/

     var fnGetNames         = function() { return meNames;  }
     var fnGetValues        = function() { return meValues; }
     var fnGetContextLabels = function() { return meContextLabels; }

     /*============================================================
      * Multi select functions
      *============================================================*/

     if ($opts.multiSelect == true)
     {

       fnUpdateMultipleSelections = function () {

       // Rebuild on screen labels

       $multiSelList.empty();

       // Rebuild names and values array

       meNames  = [];
       meValues = [];
       meContextLabels = [];

       var selCount = 0;

       $.each( multiSelListNamesValues, function( key, val ) {

         meNames.push(val.name);
         meValues.push(val.value);
         meContextLabels.push(val.contextlabel);

         var $newSelListItem    = $("<li class='ui-spedmon-box-select-box-multi-selection-list-item' style=''></li>");

         var $newSelName = $("<span class='sellabel ui-spedmon-box-select-box-multi-selection-list-item-selection-label'>" + val.name + "</span>").appendTo($newSelListItem);

         if ($opts.multiSelectDisplayContextLabels == true)
         {
           var $newContextLabel = $("<br/><span class='selcontext ui-spedmon-box-select-box-multi-selection-list-item-selection-context'>" + val.contextlabel + "</span>").appendTo($newSelListItem);
         }

         var $newSelListItemBut = $("<button type='button' class='ui-spedmon-box-select-box-multi-selection-list-item-remove' style=''></button>")
           .append("<i class='fas fa-minus-circle' title='Remove'>")
           .click(function(){multiSelListNamesValues.splice(key,1);fnUpdateMultipleSelections();$opts.multiSelectOnRemove(val);})
		   .appendTo($newSelListItem);

         if ($opts.multiSelectDisplayContextLabels == false) $($newSelListItemBut).addClass('ui-spedmon-box-select-box-multi-selection-list-item-remove-adjust-1');
		 if ($opts.multiSelectDisplayContextLabels == true)  $($newSelListItemBut).addClass('ui-spedmon-box-select-box-multi-selection-list-item-remove-adjust-2');
		 		 
		 $multiSelList.append($newSelListItem);
         selCount++;
       });

       if (selCount == 0)
       {
         $multiSelList.append("<li class='ui-spedmon-box-select-box-multi-selection-list-item ui-spedmon-box-select-box-multi-selection-list-item-no-items-placeholder'><span class='class='sellabel ui-spedmon-box-select-box-multi-selection-list-item-selection-label'>No selections made</span></li>");
       }
         // Update original input and trigger change event

         $me.val(meValues.join(",")).change();
         $melbl = meNames.join("|");


       };

       fnFireDataSelected = function ()
       {
         fnUpdateMultipleSelections();
         jQuery.spedmonWebUI.fireDataSelected($me,{id:$me.attr('id'),label:$melbl,value:$me.val()});
       };


       fnClearData = function ()
       {
         $me.val('');
         meNames  = [];
         meValues = [];
         meContextLabels = [];
         $($input).val('');
         var l = multiSelListNamesValues.length;
         multiSelListNamesValues.splice(0, l);
         fnUpdateMultipleSelections();
       }

       fnLoadItem = function(name,value,contextlabel)
       {
         // Create new name/value pair

         var newMultiSelListNameValue          = {};
         newMultiSelListNameValue.name         = name;         // ui.item.label;
         newMultiSelListNameValue.value        = value;        // ui.item.id;
         newMultiSelListNameValue.contextlabel = contextlabel; // ui.item.context1

        // Search the array of existing values and see if this value already exists

        var numExisting = multiSelListNamesValues.length;
        var alreadySelected = false;

        for (var i = 0; i < numExisting; i++)
        {
          var existingMultiSelListNameValue = multiSelListNamesValues[i];
          if (existingMultiSelListNameValue.value == newMultiSelListNameValue.value)
          {
            alreadySelected = true;
            break;
          }
        }

        // If not already selected push it on to the array of existing values

        if (!alreadySelected)
          multiSelListNamesValues.push(newMultiSelListNameValue);

        // Rebuild on screen list

        fnUpdateMultipleSelections();

        if (!alreadySelected)
          return newMultiSelListNameValue;
        else
          return null;
       }

       fnLoadItems = function (names, values, contextlabels)
       {
         var newNames         = names.split('|');
         var newVals          = values.split(',');
         var newContextLabels = null;
         var useContext       = false;

         if (contextlabels != 'null')
           newContextLabels = contextlabels.split('|');

         if ($.isArray(newContextLabels) == true)
           useContext = true;

         var patCnt = 0;
         patCnt = newVals.length;

         for (var i = 0; i < patCnt; i++)
         {
           if (useContext == true)
             fnLoadItem (newNames[i],newVals[i],newContextLabels[i]);
           else
             fnLoadItem (newNames[i],newVals[i],'');
         }
       }

     }
     else
     {
       fnClearData = function ()
       {
         $me.val('');
         $($input).val('');
         meNames  = [];
         meValues = [];
         meContextLabels = [];
       }	   
     }

     /*============================================================
      * Create new input that will be used for the search control
      * values will be stored in the original input
      *============================================================*/

     var $input_opts = {}; // New input options
     $input_opts.useHover = false; // Remove default styling

    /*-------------------------------
     * Handle blanks and clears
	 * also put in selected name
	 * for single select
     *------------------------------*/
     
	 var singleSelectedName = '';
	 
     if ($opts.multiSelect == false)
     {
       $input_opts.blankValueEntered = function(){$me.val('');jQuery.spedmonWebUI.fireDataSelected($me,{id:$me.attr('id'),label:$me.val(),value:$me.val()});};
	   singleSelectedName = $opts.singleSelectName;
     }

     $input = $("<input id='" + meid + "_selection' name='" + menm + "_selection' value='" + singleSelectedName + "' title='" + metitle +"' class='" + $.spedmonWebUI.field.NO_SUBMIT + " ' type='text'/>")
       .insertAfter($me)
       .spedmonInput($input_opts);

	 
	 // Get references from new input

	 var inputData   = $($input).data('spedmonInput');
     var $inputCont  = inputData.meCont;
	 //var $label      = inputData.meLabel;
	 var maxLen      = inputData.maxLen;

    /*============================================================
     * Multi select elements
     *============================================================*/

    if ($opts.multiSelect == true)
    {

     /*-------------------------------
      * Selections list container
      * title and list
      *------------------------------*/

     $("<div id='" + multisellistcontid + "' class='ui-widget ui-spedmon-box-select-box-multi-selection-container' style=''><h3 class='ui-spedmon-box-select-box-multi-selection-title' style=''>" + $opts.multiSelectListTitle + "</h3><ul id='" + multisellistid + "' class='ui-widget-content ui-spedmon-box-select-box-multi-selection-list' style=''></ul></div>")
     .appendTo($mecont);

     $multiSelListCont  = $("#" + multisellistcontid);
     $multiSelList      = $("#" + multisellistid);

     /*-------------------------------
      * Selections controls
      *------------------------------*/
	  
     if ($opts.multiSelectShowOK == true)
     {
	   $("<div id='" + multiselctrlscontid + "' class='ui-widget-header ui-spedmon-box-select-box-multi-selection-controls' style=''></div>")
       .appendTo($multiSelListCont);

       $multiSelCtrlsCont = $("#" + multiselctrlscontid);

       $multiSelCtrlOK = $("<button id='" + multiselctrlok + "' type='button'>OK</button>").button({icons: {primary: "ui-icon-circle-check"}})
         .click(function(){fnFireDataSelected();})
         .appendTo($multiSelCtrlsCont);
      }
    }

    /*============================================================
     * Hide original
     *============================================================*/

    $me.hide();

    
	/*============================================================
     * Inline label (optional)
     *============================================================*/
    
	if ($opts.showSelectControlLabel == true)
	{
      $('<label class="mba-web-ui mba-web-ui-inline ui-spedmon-box-select-box-select-ctrl-label">' + $opts.selectControlLabel + '</label>').insertBefore($input);
	}
	 	
	/*============================================================
     * Set specific options and create action button based on
     * select type
     *============================================================*/
	 
    /*-------------------------------
     * Create action button element
     *------------------------------*/

    var $button = $("<button class='ui-spedmon-box-inline-ctrl ui-spedmon-box-select-box-select-action' id='" + meid + "_button' type='button'></button>")	
                .attr("tabindex", -1);

    /*-------------------------------
     * Search box specific
     *------------------------------*/

    if ($opts.selectType == $.fn.spedmonSelectBox.constants.SELECT_TYPE_SEARCH_BOX)
    {
      $opts.delay = 0; // No delay needed
      //$opts.minLength = 0;
      $($button).append('<i class="fas fa-search"></i>')
                .attr("title","Click here to begin search");
    }

    /*-------------------------------
     * Combo box specific
     *------------------------------*/

    else if ($opts.selectType == $.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX)
    {
      $($button).append('<i class="fas fa-chevron-down"></i>')
                .attr("title","Click here to select from a list");

      if (!$opts.selectAll)
        $($button).hide();

    }

    /*-------------------------------
     * Unknown
     *------------------------------*/

    else
    {
    }

    /*-------------------------------
     * Render action button
     *------------------------------*/

    $($button).css({height:parseInt($input.outerHeight())})
              .insertAfter($input);

    /*============================================================
     * Create inline status and render it
     *============================================================*/

    var $status = $("<ul id='" + meid + "_status' class='ui-spedmon-box-select-box-inline-search-status'></ul>")
	    .addClass('details-inline')
        .insertAfter($button);

    /*============================================================
     * Setup autocomplete plugin source of data
     *============================================================*/

    if ($opts.sourceIsLocalData == false)
    {

       var $xhr;

       $opts.source = function(request,response) {

         // See http://jqueryui.com/demos/autocomplete/#option-source

         /*-------------------------------
          * Autocomplete plugin source
          * function.
          *
          *   receives: request containing
          *   text of what user typed in
          *
          *   returns: response containing
          *   array of items to display
          *
          * This function uses the
          * jQuery ajax method to
          * send/receive data from the
          * server and it expects the
          * data to be encoded in json
          *------------------------------*/

         var ajaxopts = {};

	     /*-------------------------------
          * Populates ajax.url with
          * the url to post a request to
          * the url is specified in our
          * options object. Also setup
          * the requst method (post) and
          * content/data type (json)
          *------------------------------*/

         ajaxopts.url = $opts.ajaxopts.url;

         /*-------------------------------
          * Populates ajax.data with
          * request term from the user
		  * ajax.data contains other name
		  * value parameters that we post
		  * posted to the server as part of
          * the request.
          *------------------------------*/

         ajaxopts.data = '{term:"' + request.term + '"';

         /*-------------------------------
          * Populates ajax.data with
          * any additional parameters
          * specified in our form data option
          * ajaxopts.data. (Note ajaxopts.data
		  * is NOT ajax.data)
		  *
		  * The data option expects an array
		  * of one or more ids objects that
		  * contain the unique ids of html
		  * inputs.
		  *
          * The parameter name and values are
		  * extracted from the name and value
		  * attributes of these elements
		  * every time the select request is
		  * executed.
          *
		  * IF the element is not found then
		  * a name/value pair is created using
		  * the id as the name and a '' as the
		  * value
		  *
		  * This allows for dynamic names and
		  * values but the name/value data must
          *	be stored in html input elements
          * The ids of the elements themselves
		  * are static and set only once.
          *------------------------------*/

		$.each($opts.ajaxopts.data,function(idx,val){

           var prmid = "#" + val.id;
           var prm   = $(prmid);

           // If the parameter is found use it, otherwise create a blank parameter assuming the id will be the name

           if (prm.length > 0)
             ajaxopts.data = ajaxopts.data + "," + prm.attr("name") + ":'" + prm.attr("value") + "'";
           else
             ajaxopts.data = ajaxopts.data + "," + val.id + ":''";
         });

         /*-------------------------------
          * Populates ajax.data with
          * any additional parameters
          * specified in our namevalues option
		  * The namevalues option expects an array of
		  * one or more name value objects.
          * These name values are static and set
		  * only once.
          *------------------------------*/

		 if ($opts.ajaxopts.namevalues) {
		   $.each($opts.ajaxopts.namevalues,function(idx,namevalue){
             ajaxopts.data = ajaxopts.data + "," + namevalue.name + ":'" + namevalue.value + "'";
           });
		 }

         /*-------------------------------
          * Populates ajax.data with
          * any additional parameters
		  * returned by our getnamevaluesfn
		  * delegate.  The delegate is expected
		  * to return an array of one or more
		  * more name value objects.
          * This delegate is called every time
		  * a request is made
          *------------------------------*/

		 var newnamevaluesFn = null;
		 newnamevaluesFn = $opts.ajaxopts.getnamevaluesfn;
		 if (newnamevaluesFn){
		   var newnamevalues = newnamevaluesFn();
		   $.each(newnamevalues,function(idx,namevalue){
             ajaxopts.data = ajaxopts.data + "," + namevalue.name + ":'" + namevalue.value + "'";
           });
		 }

		 ajaxopts.data = ajaxopts.data + "}";


	    /*-------------------------------
         * Setup handler to process
         * a succesful response
         *------------------------------*/

        ajaxopts.success = function(rd) {

          if (rd.status == 0)
          {
            if (rd.data.SelRecs != null)
            {
              // If we have records return them in response

	          //$status.spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.GOOD, rd.data.SelRecs.length + " Records",2);
	          response(rd.data.SelRecs);

            }
            else
            {
              // We have no records.  Inform the user and return an empty response
	          //$status.spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.INFO,"No Records",2);
              response({});
            }
          }
          else
          {
            // There was a problem.  Inform the user and return an empty response
            response({});
          }

        };

	    /*-------------------------------
         * Setup handler to process
         * any pre request tasks
         *------------------------------*/

         ajaxopts.beforesend = function() {
          // Hide our watermark.

          //$label.hide();

          // Close last results list if it is open

          if ($input.autocomplete("widget").is(":visible")){$input.autocomplete("close");return;};
          };

         /*-------------------------------
          * Setup handler to process
          * any post request tasks
          *------------------------------*/

         ajaxopts.complete = function() {

          /*-------------------------------
           * If this is a combo box
           *------------------------------*/

          if ($opts.selectType == $.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX)
          {

            /*-------------------------------
             * If this was a select all
             * via select all button
             * restore autocomplete options
             *------------------------------*/

            if ($opts.selectAll)
            {
              $input.focus();
              $input.autocomplete("option","minLength",1);
              $input.autocomplete("option","delay",600);
              $input.autocomplete("option","selectFirst",true);
            }
           }
         };

         /*-------------------------------
          * Setup handler to process
          * any request/response errors
          *------------------------------*/

         ajaxopts.error = function() {

           // There was a problem.  Return an empty response

           response({});
         };

        // If an existing search is in progress, abort it

        if ($xhr) $xhr.abort();

        // Execute search

        $xhr = $.spedmonWebUI.ajax($input,$opts.ajaxopts.url,ajaxopts.data,'json',ajaxopts.beforesend,ajaxopts.success,ajaxopts.error,$status,true,null,ajaxopts.complete);

      };
    };


    /*============================================================
     * When value is selected, store in $me
     *============================================================*/

    $opts.select = function (event, ui) {

      if ($opts.multiSelect == true)
      {
		var selObj = fnLoadItem (ui.item.label,ui.item.id,ui.item.context1);
        $opts.multiSelectOnAdd(selObj);
        // Cancel autocomplete select to prevent the value from being placed in $input
        $(this).val('');        
        return false;
      }
      else
      {
        $opts.onSelect(event,ui);
        $me.val(ui.item.id);
        //$label.hide();
        /* Save single name/value */
        meValues = [];
        meValues.push(ui.item.id);
        meNames = [];
        meNames.push(ui.item.label);
        meContextLabels = [];
        meContextLabels.push(ui.item.context1);
	    jQuery.spedmonWebUI.fireDataSelected($me,ui.item);
		if ($opts.singleSelectClearAfterSelection === true) {
		  // Cancel autocomplete select to prevent the value from being placed in $input
          $(this).val('');        
          return false;
		}
      }

    };

    /*============================================================
     * Create autocomplete and override its _render item
     *============================================================*/

    $input.autocomplete($opts).data("autocomplete")._renderItem = function ($ul, item) {      
        
        var $renderedli = $("<li></li>")
            .data("item.autocomplete", item)
            .append("<a><span class='sellabel'>" + item.label + "</span><br/><span class='selcontext'>" + ((item.context1 != null) ? item.context1 : '') + "</span></a>");
        $renderedli = $opts.afterRenderItem(item, $renderedli);
        $($renderedli).appendTo($ul);
        return $renderedli;
    };

	/*============================================================
     * Get menu list (ul) created by plugin and add a class to it
     *============================================================*/

	var $acObjList = $($input).autocomplete( "widget" );
    var $acObj = $acObjList[0];
	$($acObj).addClass('ui-spedmon-box-select-box-search-results-list-items');
		
    /*-------------------------------
     * Fix formatting screwed up
     * by autocomplete
     *------------------------------*/

    $status.css({top:0});
    $button.css({top:0});

    /*============================================================
     * Setup action button events based on select type
     *============================================================*/

    /*-------------------------------
     * This is a search box
     *------------------------------*/

    if ($opts.selectType == $.fn.spedmonSelectBox.constants.SELECT_TYPE_SEARCH_BOX)
    {
      $button.click(function(){

        /*-------------------------------
         * Starts search by calling
         * the autocomplete search
         * method.  Note in order to ensure
         * that only clicking on this button
         * starts the search, we are using
         * the autocomplete delay option
         * as a flag.
         *------------------------------*/

        if ($input.autocomplete("widget").is(":visible"))
        {
          $input.autocomplete("close");
          $input.autocomplete("option","delay",0);
          return false;
        };

        $input.autocomplete("option","delay",9999);
        $input.autocomplete("search");
        $input.focus();
        return;
        });

        $input.bind("spedmoninputdata",function(event) {
          $button.click();
          return false;
        });

        $input.bind("autocompletesearch", function(event,ui) {

          if ($input.autocomplete("widget").is(":visible"))
            $input.autocomplete("close");

          if ($input.autocomplete("option","delay") == 0)
            return false;

          if ($input.autocomplete("option","delay") == 9999)
            $input.autocomplete("option","delay",0);
        });

      }

     /*-------------------------------
      * This is a combo box
      *------------------------------*/

      else if ($opts.selectType == $.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX)
      {

        $button.click(function(){

          /*-------------------------------
           * If the results list is visible
           * hide it and return.  This allows
           * us to toggle showing and hiding
           * all results by toggling the
           * show all button
           *------------------------------*/

          if ($input.autocomplete("widget").is(":visible")){$input.autocomplete("close");return;};

          if ($opts.selectAll)
          {
            /*-------------------------------
             * Reset autocomplete options to
             * values that are required for
             * displaying all values.
             *
             * min entry length = 0
             * search delay     = 0
             * search terms     = ''
             *
             * This will trick the autocomplete
             * into starting its search right away
             *------------------------------*/

            $input.autocomplete("option","minLength",0);
            $input.autocomplete("option","delay",0);
            $input.autocomplete("option","selectFirst",false);
          }

          /*-------------------------------
           * Execute search
           * Note: Options are restored
           * in the ajax complete
           *------------------------------*/

          $input.autocomplete("search","");

          return;});
      }

      /*============================================================
       * Init
       *============================================================*/

       if ($opts.multiSelect == true) {
           if ($opts.multiSelectLoad == true) {
               fnLoadItems($opts.multiSelectNames, $opts.multiSelectValues, $opts.multiSelectContextLabels);
           }
           fnUpdateMultipleSelections();
       }
       else
       {
           /* Add single select value/name to values collection */    
           meValues.push($opts.singleSelectValue);
           meNames.push($opts.singleSelectName);
           meContextLabels.push("");
       }

	  /* Set items */

	  var fnSetValues = function (multiSelectNames, multiSelectValues, multiSelectContextLabels) {
	    if ($opts.multiSelect == true) {
          $opts.multiSelectNames = multiSelectNames;
		  $opts.multiSelectValues = multiSelectValues;
		  $opts.multiSelectContextLabels = multiSelectContextLabels;
		  fnLoadItems ($opts.multiSelectNames,$opts.multiSelectValues,$opts.multiSelectContextLabels);
		};
		fnUpdateMultipleSelections();
	  };

      /*============================================================
       * Create references for helper functions to use
       *============================================================*/

      var selBoxCtrl = {};

      selBoxCtrl.meid                = meid;
      selBoxCtrl.inputData           = inputData; /* New inputs data */
      selBoxCtrl.clear               = fnClearData;
      selBoxCtrl.names               = fnGetNames;
      selBoxCtrl.values              = fnGetValues;
      selBoxCtrl.contextLabels       = fnGetContextLabels;
      selBoxCtrl.setValues           = fnSetValues;
      selBoxCtrl.ctrlRefMe           = $me;
      selBoxCtrl.ctrlRefNewInp       = $input;
      selBoxCtrl.ctrlRefSelectButton = $button;
      $.data(this, 'spedmonSelectBox', selBoxCtrl);

   });
 };

  /*============================================================
   * Constants
   *============================================================*/

  $.fn.spedmonSelectBox.constants = {
    SELECT_TYPE_SEARCH_BOX:0,
    SELECT_TYPE_COMBO_BOX:1
  };

  /*============================================================
   * Parameter Defaults
   *============================================================*/

  $.fn.spedmonSelectBox.defaults = {
    displayInline:false,
	showSelectControlLabel:false,
	selectControlLabel:'Select',	
	multiSelect:false,
    multiSelectListTitle:'Selected Records',
    multiSelectLoad:false,
    multiSelectNames:'',
    multiSelectValues:'',
    multiSelectContextLabels:'null',
    multiSelectDisplayContextLabels:false,
    multiSelectOnAdd:function(selObj){},
    multiSelectOnRemove:function(selObj){},
	multiSelectShowOK:true,
	minLength:1,
    delay:600,
	singleSelectName:'',
    singleSelectValue:'',
	selectType:$.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX,
    selectAll:true,
    selectFirst:true,
    onSelect:function(event,ui){},
    sourceIsLocalData:false,
    ajaxopts:{},
    source:function(request,response){},
    search: function(event,ui){},
    response: function(event,ui){},
    select: function (event,ui){},
    singleSelectClearAfterSelection: false,
    afterRenderItem: function (item, $renderedli) { return $renderedli; }
  };


  /*============================================================
   * Helper functions
   *============================================================*/

  /*-------------------------------
   * Clear value
   *------------------------------*/

  $.fn.spedmonSelectBox_clear = function(){
    return this.each(function() {

      // Get this instances data

      var $me   = $(this);
      var $ctrl = $($me).data('spedmonSelectBox');
      $ctrl.clear();
	  
	  // Clear input component
	  
	  var $sbInputData = $ctrl.inputData;
	  var $sbInput = $('#' + $sbInputData.meid);
	  $($sbInput).val('');
	  
    });
  };

  $.fn.spedmonSelectBox_disable = function () {
         return this.each(function () {

             // Get this instances data

             var $me = $(this);
             var $ctrl = $($me).data('spedmonSelectBox');

             /* Disable input and select buttons */
             MBA.ComponentCommon.fnDisableElement($ctrl.ctrlRefNewInp);
             MBA.ComponentCommon.fnDisableElement($ctrl.ctrlRefSelectButton);
         });
  };

  $.fn.spedmonSelectBox_enable = function () {
         return this.each(function () {

             // Get this instances data

             var $me = $(this);
             var $ctrl = $($me).data('spedmonSelectBox');

             /* Enable input and select buttons */
             MBA.ComponentCommon.fnEnableElement($ctrl.ctrlRefNewInp);
             MBA.ComponentCommon.fnEnableElement($ctrl.ctrlRefSelectButton);
         });
  };
})(jQuery);


/******************************************************************************
 * spedmon.DataGrid */
/**
 * The datagrid control is for inputing or editing tabular data.
 *
 * Transforms an <input/> into a datagrid
 * The input holds the datagrid data in json form
 *
 * This plugins structure is based on design patterns courtesey of:
 *
 * - Hector Virgen
 *   http://www.virgentech.com/blog/2009/10/building-object-oriented-jquery-plugin.html
 * - Alex Sexton
 *   http://alexsexton.com/?p=51
 *****************************************************************************/

;(function($){

  /*----------------------------------------------------------------------
   * Object Definition
   *---------------------------------------------------------------------*/

  var spedmonDataGrid = function (element, options)
  {
    /*-------------------------------
     * Grab references for the input
     * tag we are enhancing and this
     * new object itself.
     *------------------------------*/

    var $me  = $(element);  /* Original input */
    var obj  = this;        /* This object */

    /*-------------------------------
     * Merge options with defaults
     *------------------------------*/

    var $opts = $.extend({},$.fn.spedmonDataGrid.defaults,options);

    /*-------------------------------
     * Define and init counters
     *------------------------------*/

    var numcols      = 0;   /* Current number of columns */
    var numkeys      = 0;   /* Current number of keys (1 required) */
    var numrows      = 0;   /* Current number of rows */
    var rowidentity  = 0;   /* Unique row identity */

    /*-------------------------------
     * Extract atrributes from
     * original input and hide it
     *------------------------------*/

    var id    = $me.attr('id');      /* Grab inputs id */
    var name  = $me.attr('name');    /* Grabs inputs name */
    var value = $me.attr('value');   /* Grabs input value */

    $me.hide();                      /* Hide the input */

    /*-------------------------------
     * Create unique ids.  Each
     * unique id is based on the
     * original inputs id.
     *------------------------------*/

    var id_cont       = id        + '_cont';     /* Create container id */
    var id_tbl_info   = id        + '_tbl_info'; /* Optional info about whats in grid*/
	var id_tbl        = id        + '_tbl';      /* Create table id*/
    var id_tbl_head   = id_tbl    + '_head';     /* Create table head id */
    var id_tbl_body   = id_tbl    + '_body';     /* Create table body id */
    var id_ctrls      = id        + '_ctrls';    /* Control bar */
    var id_ctrl_clear = id_ctrls  + '_clear';    /* Clear button */
    var id_ctrl_ok    = id_ctrls  + '_ok';       /* OK button */

    /*-------------------------------
     * Create id placeholders
     *------------------------------*/

    var id_trow_ph                = '{0}';                               /* Row id placeholder.  Will be assiged at row creation time */
    var id_tbl_head_col_copy_val  = id_tbl_head + '_col_{0}_copy_val';

    /*-------------------------------
     * Create initial structure
     *------------------------------*/

    $me.wrap('<div id="' + id_cont + '"/>');   /* Wrap original input in a container */
    var $me_cont = $('#' + id_cont);           /* Grab reference to this container */
	
	/*-------------------------------
     * Create header and row template
     * including extra td for #?
     *------------------------------*/

     var theadgrps   = '<tr class="ui-widget-header"><th class="ui-widget-header ui-state-default"></th>';
     var thead       = '<tr class="ui-widget-header"><th class="ui-widget-header ui-state-default"></th>';                                                  /* Start table header */
     var theadvals   = '<tr class="ui-widget-header dg-cols-new-values"><th class="ui-widget-header ui-state-default"></th>';                               /* Col new values */
     var theadctrls  = '<tr class="ui-widget-header dg-cols-ctrls"><th class="ui-widget-header ui-state-default"></th>';                                    /* Col controls */
     var trowtpl     = '<tr id="' + id_trow_ph + '" class="ui-widget-content">'
	                 + '<td class="dg-row-number ui-widget-header ui-state-default"></td>';   /* Start row template */
     
	 var id_trow_tpl = id_tbl_body + '_{0}_r_{1}';

     /* For each column definition passed in */

     $.each($opts.aCols, function(i, val) {

       /* Update column count */

       numcols++;

       /* Create unique ids for table body columns and fields */

       var colid           = id_trow_ph + '_c_'  + numcols;     /* Column id */
       var fldid           = colid      + '_f_'  + numcols;     /* Field id  */
       var colnewvalid     = 'dg-col-new-value_' + numcols;     /* New value */
       var colctrlcopybut  = 'dg-col-ctrl-copy_' + numcols;     /* Header copy control */

       var colgroup      = (val.group !='') ? val.group : "";

       /* Add column headings to header */

       var colsection    = (val.section != '') ? " " + val.section : "";            /* Section? */
       var coldisplay    = (val.ishidden) ? " dg-hidden" : "";                      /* Hidden? */

       var fldDataAttrCopyValueRight = (val.copyvalueright) ? ' data-copy-value-right="data-copy-value-right"' : ' '; /* Copy value across to right */

       var colhdrclass   = "ui-widget-header ui-state-default" + colsection + coldisplay;

       /* Add column copy new value to header */

       var colval   = "";
       var colwidth = "width:" + val.width + "px;";

       var needval = ((val.ctrlcopy) && (!val.islabel));


       if (needval)
       {
         /* Use text area*/
		 if (val.ismultiline == true)
         {
		   colval = '<textarea id="' + colnewvalid + '" name="' + colnewvalid + '" class="dg-col-new-value ' + val.clienttype + ' ' + $.spedmonWebUI.field.NO_SUBMIT +'" rows="1" style="height:1em;' + colwidth + '"></textarea>';
         }
		 /* Use input */
         else
         {
           colval = '<input id="' + colnewvalid + '" name="' + colnewvalid + '" value="" class="dg-col-new-value ' + val.clienttype + ' ' + $.spedmonWebUI.field.NO_SUBMIT +'" type="text" style="' + colwidth + '"/>';
         }
       }

       /* Add column controls to header */

       var colctrls = "";

       /* Copy control */

       if (val.ctrlcopy == true)
         colctrls = colctrls + '<button id="' + colctrlcopybut +'" type="button" class="dg-col-ctrl-copy">Copy</button>'

       /* Build column header cells */

       theadgrps  = theadgrps  + '<th class="' + colhdrclass + '" style="padding:.25em;' + colwidth + '">' + colgroup  + '</th>';
       thead      = thead      + '<th class="' + colhdrclass + '" style="padding:.25em;' + colwidth + '">' + val.title + '</th>';
       theadvals  = theadvals  + '<th class="' + colhdrclass + '" style="' + colwidth + '">' + colval    + '</th>';
       theadctrls = theadctrls + '<th class="' + colhdrclass + '" style="' + colwidth + '">' + colctrls  + '</th>';

       /* Create row cell */

       var fld           = "";
       var fldvalplace   = "{" + numcols + "}";
       var fldclass      =  $.spedmonWebUI.field.NO_SUBMIT;        /* Tell ui that this field should not be submitted as part of a form */
       var colclass      = "";
       var cellDataAttrs = "";

       /* The field is a key value.  Note: Key values must be labels */

       if (val.iskey == true)
       {
         fldclass = fldclass + " dg-key";
         if (val.islabel == false) alert('A key value must be a label');
         numkeys++;
       }

       /* The field is a label.  Labels are non editable */

       if (val.islabel == true)
       {
         fldclass = fldclass + ' label ' + val.clienttype;
         colclass = colclass + ' ui-widget-content ui-state-default ';
         fld = '<span id="'  + fldid + '" class="'  + fldclass + '">' + fldvalplace + '</span>';
       }

       /* The field is some text area or input value.  These are editable*/

       else
       {
		 fldclass      = fldclass + ' dg-data ui-widget-content ' + val.clienttype;
         colclass      = colclass + ' ui-widget-content ';
         cellDataAttrs = fldDataAttrCopyValueRight;

		 if (val.ismultiline == true)
         {
		   fld = '<textarea id="' + fldid + '" name="'+ fldid +'" class="' + fldclass +'" rows="1" style="height:1em;' + colwidth + '"></textarea>';
		 }
         else
		 {
		   fld = '<input id="' + fldid + '" name="'+ fldid +'" value="' + fldvalplace + '" class="' + fldclass +'" type="text" style="' + colwidth + '"/>';
		 }
       }

       trowtpl  = trowtpl  + '<td id="' + colid + '" '+ cellDataAttrs + ' class="dg-cell ' + colclass + colsection + coldisplay + '">' + fld + '</td>';

     }); /* End of loop */

     theadgrps  = theadgrps  + '</tr>';
     thead      = thead      + '</tr>';
     theadvals  = theadvals  + '</tr>';
     theadctrls = theadctrls + '</tr>';
     trowtpl    = trowtpl    + '</tr>';

     /*-------------------------------
      * Build optional info section
      *------------------------------*/

	 $me_cont.append('<div id="' + id_tbl_info + '" class="ui-spedmon-datagrid-table-info"></div>');

	 /*-------------------------------
      * Build initial table
      *------------------------------*/

     $me_cont.append('<table id="' + id_tbl + '" class="ui-widget ui-spedmon-datagrid"><thead id="' + id_tbl_head + '" class="ui-widget-header">' + theadgrps + thead + theadvals + theadctrls + '</thead><tbody id="' + id_tbl_body + '" class="ui-widget-content"></tbody></table>');

     /*-------------------------------
      * Grab references to table and
      * table head and table body
      *------------------------------*/

     var $tbl      = $('#' + id_tbl);
     var $tbl_head = $('#' + id_tbl_head);
     var $tbl_body = $('#' + id_tbl_body);

     /*-------------------------------
      * Hide columns that should be
      * hidden
      *------------------------------*/

     $tbl.find('.dg-hidden').hide();

     /*-------------------------------
      * Surpress spedmon input data
      * event firings from col value
      * controls
      *------------------------------*/

     $tbl_head.bind("spedmoninputdata",function(e){return false;});

     /*-------------------------------
      * Setup column header new value
      * inputs
      *------------------------------*/

     var colnewvalues = $tbl_head.find(".dg-col-new-value");

     $.each(colnewvalues, function(c,newvalue){

       var sa = $(newvalue).attr('style');
       sa = sa + 'padding:4px;font-weight:bold;border:1px solid white;';

       /* Numbers will use the numberbox control */

       if ($(newvalue).hasClass($.spedmonWebUI.field.DATA_NUMBER))
       {
		 $(newvalue).attr('style', sa);
         $(newvalue).attr('maxlength','7');
         $(newvalue).spedmonNumberbox({useLabel:false,useHover:false,useBorder:false,useOK:false,showControls:false,showOK:false,numIncDecButtons:false,numIncDecUpDownArrow:false,numIncDecMouseWheel:false});
       }

       /* Text will use the textbox control */

       if ($(newvalue).hasClass($.spedmonWebUI.field.DATA_TEXT))
       {
         $(newvalue).attr('style', sa);
         $(newvalue).spedmonTextbox({useLabel:false,useHover:false,useBorder:false,useOK:false,showControls:false,showOK:false});
       }

	   /* Multline text will use the textbox control */

       if ($(newvalue).hasClass($.spedmonWebUI.field.DATA_TEXT_AREA))
       {
		 // TODO: We are using autosize for now, refactor to use a textarea control
	     $(newvalue).autosize();
       }

       /* Flags will use the checkbox control */

       if ($(newvalue).hasClass($.spedmonWebUI.field.DATA_FLAG))
       {
         $(newvalue).attr('style', sa);
         $(newvalue).spedmonCheckBox({useLabel:false,useHover:false,useBorder:false,useOK:false,showControls:false,showOK:false});
       }

       /* Dates will use a date control */

       if ($(newvalue).hasClass($.spedmonWebUI.field.DATA_DATE))
       {
         //TODO: Implement
       }

     });

     /*-------------------------------
      * Setup column header controls
      * starting with the copy button
      *------------------------------*/

     /* For each copy control button */

     var copyctrls = $tbl_head.find("button.dg-col-ctrl-copy");

     $.each(copyctrls, function (l,copyctrl) {

       /* Create button and assign click handler */

       $(copyctrl).button({icons:{primary:'ui-icon ui-icon-arrowthick-1-s'}}).addClass('ui-spedmon-button-small').click(function(e){

         /* Find all visible copy control buttons in the header control row */

         var buttons = $(copyctrl).parents('table thead').find('tr.dg-cols-ctrls button:visible');

         /* Find all visible new entry fields in the header new value row.  We are just looking for input and textareas */

         var inputs =  $(copyctrl).parents('table thead').find('tr.dg-cols-new-values input:visible,tr.dg-cols-new-values textarea:visible');

		 // Copy buttons and visible entry fields must be lined up.  If not raise warning.

         if ((buttons.length != inputs.length)) alert('Error in datagrid configuration');

         if ((buttons.length > 0) && (inputs.length > 0))
         {
           /* Get reference to cell to copy from  */

           var indexbut = buttons.index(copyctrl);
           var copycell = $(inputs[indexbut]);

		   /* Grab cell value to copy */
		   /* TODO: val() will work for text, number, date.... works for textarea (for now).. need workaround for checkbox */

		   var copyval = $(copycell).val();

           /* Find our position */

           var cp = $.spedmonWebUI.tblCellPosition (copycell);
           var indexcell = cp.colidx;

           /* Get table rows */

           var torows   = $tbl_body.find('tr');

           /* For each row */

           $.each(torows, function (r,row) {

			 /* Get all cols in row */
             var tocols  = $(row).find('td');

             /* Find specific col we need to copy to */
             var tocol  = $(tocols[indexcell]);

			 /* Find the input or textarea */
			 var tocell = $(tocol).find('input:visible, textarea:visible');

			 /* Set value */

             tocell.val(copyval);

		   });
         }

         /* Cancel click event */

         return false;
       });
     });

     /*-------------------------------
      * Combine column groups
      *------------------------------*/

     $($tbl_head).find('tr:first').each(function(i,tr)
     {

       var newSpanCtr   = 1;
       var lastColText  = '';

       /* For each column that has text */

       $('th',tr).not(':empty').each(function(j, td)
       {

         /* If it is equal to the last */

         if ($(td).text() == lastColText)
         {
           newSpanCtr++;                                /* Increment new span counter */
           var newColSpanStr = parseInt(newSpanCtr,10); /* Create a colspan string (base 10) */

           /* Set the previous column span and style*/
           $(td).prev().attr('colSpan', newColSpanStr).css({textAlign : 'center',height:'3em'});

           $(td).remove();                              /* Remove redudant column */
          }

          /* If it is not equal to the last, preserve it as is */

          else
          {
            newSpanCtr = 1;                              /* Reset span counter */
          }

          lastColText = $(td).text();                    /* Save the current value for the next iteration for comparison */

        }); /* Col loop */
      }); /* Row loop */

     /*-------------------------------
      * Build control bar and grab
      * reference to it
      *------------------------------*/

     $me_cont.append('<div id="' + id_ctrls + '" class="ui-spedmon-datagrid-ctrls"></div>');
     var $ctrls = $('#' + id_ctrls);

     /*-------------------------------
      * Build clear button, grab reference
      * to it, and attach event handler
	  * and hide if requested
      *------------------------------*/


	 $ctrls.append('<button id="' + id_ctrl_clear +'" type="button">Clear</button>');
     var $ctrls_button_clear = $('#' + id_ctrl_clear);
     $ctrls_button_clear.button();

     /* Handle click */

	 var fnYesClear = function () {
	   clearValues();
	   $opts.onClearButtonClick();
	 };

	 $ctrls_button_clear.click(function() {

	   $.spedmonWebUI.dialogConfirm('Are You Sure?', 'Are you sure you want to clear?  All data you have entered will lost!', fnYesClear, null);
	 });

	 if (!$opts.showClear) {
	   $ctrls_button_clear.hide();
     }

     /*-------------------------------
      * Build OK button, grab reference
      * to it, attach event handler
	  * and hide if requested
      *------------------------------*/

     $ctrls.append('<button id="' + id_ctrl_ok +'" type="button">OK</button>');
     var $ctrls_button = $('#' + id_ctrl_ok);
     $ctrls_button.button();
     $ctrls_button.click(function(){fireDataSelected();});

	 if (!$opts.showOK) {
	   $ctrls_button.hide();
     }

     /*-------------------------------
      * Hide control bar if requested
      *------------------------------*/

	 if (!$opts.showControls){
	   $ctrls.hide();
	 }
	 
	 /*-------------------------------
      * Attach handlers to table and
      * table body
      *------------------------------*/

     $tbl.blur(function(){updateRowData();});
     $tbl_body.blur(function(){updateRowData();});

     /* Note: onRowFocusIn(e) and onRowFocusOut(e) can capture focus in/out events from children of the row as well */

     /*-------------------------------
      * Row
      *------------------------------*/

     $tbl_body.on("focusin", "tr",  function(e){$(this).addClass('ui-spedmon-datagrid-current-row');$opts.onRowFocusIn(e)});
     $tbl_body.on("focusout","tr",  function(e){$(this).removeClass('ui-spedmon-datagrid-current-row');$opts.onRowFocusOut(e)});

     /*-------------------------------
      * Cell
      *------------------------------*/

     $tbl_body.on("click", "tr td",function(e){
       var flds = $(this).find('input:visible');
       $(flds).first().focus();
     });

     $tbl_body.on("focusin", "tr td input:visible",function(e){$(this).parents('td').addClass('ui-state-hover');$opts.onCellFocusIn(e);});
     $tbl_body.on("focusout", "tr td input:visible",function(e){$(this).parents('td').removeClass('ui-state-hover');$opts.onCellFocusOut(e);});


     /*----------------------------------------------------------------------
      * Public methods
      *
      * Call by using the following script pattern
      *
      * $('#element').spedmonDataGrid();
      * var dg = $('#element').data('spedmondatagrid');
      * dg.publicMethod();
      *---------------------------------------------------------------------*/

     /***************************************************************************
      * spedmon.DataGrid.setTableInfoHtml () */
     /**
      * Set html content for optional table info
      ***************************************************************************/

	 this.setTableInfoHtml = function (tblInfo) {
	   $('#' + id_tbl_info).html(tblInfo);
	   return;
	 };

	 /***************************************************************************
      * spedmon.DataGrid.getTableInfoHtml () */
     /**
      * Return html content for optional table info
      ***************************************************************************/

	 this.getTableInfoHtml = function () {
	   return $('#' + id_tbl_info).html();
	 };

	 /***************************************************************************
      * spedmon.DataGrid.getPartIds() */
     /**
      * Return various grid part element ids
      ***************************************************************************/


	 this.getPartIds = function () {

	 var partids = {};

	 partids.meid        = id;
	 partids.id_cont     = id_cont;
     partids.id_tbl      = id_tbl;
	 partids.id_tbl_head = id_tbl_head;
     partids.id_tbl_body = id_tbl_body;

	 return partids;

	 }

	 /***************************************************************************
      * spedmon.DataGrid.setData() */
     /**
      * Takes data stored in underlying input as a JSON string and populates grid
      *
      ***************************************************************************/

     this.setData = function()
	 {
	   return setData();
	 }

	 /***************************************************************************
      * spedmon.DataGrid.getData() */
     /**
      * Return data stored in grid as an object.  This is the same data that is
      * stored in the underlying input as a JSON string.
      ***************************************************************************/

     this.getData = function ()
     {
       return getData();
     }

     /***************************************************************************
      * spedmon.DataGrid.hasData() */
     /**
      * Returns true if the grid has data rows
      ***************************************************************************/

     this.hasData = function ()
     {
       return hasData();
     }

     /***************************************************************************
      * spedmon.DataGrid.updateRowData() */
     /**
      * Updates our input with data
      ***************************************************************************/

     this.updateRowData = function ()
     {
       sortTable();                                         /* Resort the table */
       updateRowData();                                     /* Update our input with new data */
     }

     /***************************************************************************
      * spedmon.DataGrid.addRowNoUpdate() */
     /**
      * Adds a new row without calling sort or update.
      *
      * @param  arguments    Row values, if any
      ***************************************************************************/

     this.addRowNoUpdate = function ()
     {
       var nrid;                                            /* Holds our new row id*/
       nrid = addRow.apply(this, arguments);                /* Add the row by calling private method and passing arguments to it*/
       return nrid;
     }

     /***************************************************************************
      * spedmon.DataGrid.addRow() */
     /**
      * Adds a new row.
      *
      * @param  arguments    Row values, if any
      ***************************************************************************/

     this.addRow = function ()
     {
       var nrid;                                            /* Holds our new row id*/
       nrid = addRow.apply(this, arguments);                /* Add the row by calling private method and passing arguments to it*/
       sortTable();                                         /* Resort the table */
       updateRowData();                                     /* Update our input with new data */
       return nrid;
     }

     /***************************************************************************
      * spedmon.DataGrid.getRow() */
     /**
      * Gets row at index rownumber
      *
      * @param  rownumber   Index of row
      ***************************************************************************/

     this.getRow = function (rownumber)
     {
       return getRow(rownumber);
     }

     /***************************************************************************
      * spedmon.DataGrid.getCol() */
     /**
      * Gets cells (col) at index colnumber in table body
      *
      * @param  colnumber   Index of column
      ***************************************************************************/

     this.getCol = function (colnumber)
     {
       return getCol(colnumber);
     }

	 /***************************************************************************
      * spedmon.DataGrid.getColHead () */
     /**
      * Gets cells (col) at index colnumber in table head
      *
      * @param  colnumber   Index of column
      ***************************************************************************/

	 this.getColHead = function (colnumber)
	 {
	   return getColHead(colnumber);
	 }

     /***************************************************************************
      * spedmon.DataGrid.getCell() */
     /**
      * Gets cell at index rownumber,colnumber
      *
      * @param  rownumber   Index of row
      * @param  colnumber   Index of column
      ***************************************************************************/

     this.getCell = function (rownumber,colnumber)
     {
       return getCell(rownumber,colnumber);
     }

     /***************************************************************************
      * spedmon.DataGrid.findRow() */
     /**
      * Find row by given row id (rowid)
      *
      * @param  rid  Row id
      ***************************************************************************/

     this.findRow = function (rowid)
     {
       return findRow(rowid);
     }

     /***************************************************************************
      * spedmon.DataGrid.removeRow() */
     /**
      * Removes row that has the given row id (rowid
      *
      * @param  rid  Row id
      ***************************************************************************/

     this.removeRow = function (rowid)
     {
       removeRow(rowid);             /* Remove the row */
       sortTable();                  /* Resort the table */
       updateRowData();              /* Update our input with new data */
     }

     /***************************************************************************
      * spedmon.DataGrid.findRowByKey() */
     /**
      * Returns row object matching given key
      *
      * @param  key    Key value
      ***************************************************************************/

     this.findRowByKey = function (key)
     {
       var ofld   = $tbl_body.contents().find('td:contains("' + key + '")');                        /* Look for tds containing key*/
       var keylc = key.toLowerCase();                                                               /* Lowercase key */
       var oflt = ofld.filter(function(){return $(this).text().toLowerCase().indexOf(keylc) != -1;});  /* Further filter results */
       var orow = oflt.parent();                                                                       /* Get row */
       return orow;
     }

     /***************************************************************************
      * spedmon.DataGrid.addRowByKey() */
     /**
      * Adds a new empty row with the given key value.  If a row already exists with
      * the given key value, no row is added.
      *
      * @param  key    Key value
      ***************************************************************************/

     this.addRowByKey = function (key)
     {
       if (key)
       {
         var orow = this.findRowByKey(key);  /* See if row has already been added */
         if (orow.length == 0)               /* If it has not add it */
         {
           this.addRow(key);
         }
       }
     };

     /***************************************************************************
      * spedmon.DataGrid.addRowByKeyWithValues () */
     /**
      * Adds a new empty row with the given key and populates it with the values
      * provided.  If a row already exists with the given key, no row is added.
      *
      * @param  key     Key value
      * @param  values  Values array
      ***************************************************************************/

     this.addRowByKeyWithValues = function (key,values)
     {
       if (key)
       {
         if (values)
         {
           var orow = this.findRowByKey(key);  /* See if row has already been added */
           if (orow.length == 0)               /* If it has not add it */
           {
             var newcols = [];
             newcols.push(key);
             newcols = newcols.concat(values);
             this.addRow.apply(undefined, newcols);
           }
         }
       }
     };

    /***************************************************************************
     * spedmon.DataGrid.addRowsByKeys() */
    /**
     * Adds new empty rows with the given key values.
     *
     * @param  keys    Array of key values
     ***************************************************************************/

    this.addRowsByKeys = function (keys)
    {
      /* If there are keys add them in bulk */

      if (keys.length > 0)
      {
        /* Add each new row by key.  If a row with the given key already exists, no row is added */

        var o = this;

        $.each(keys, function (i, key) {
          o.addRowByKey(key);
        });

        // Get the current list of all keys

        var curkeys = getCurrentKeys();

        /* For each key check to see if it exists in the new list of keys.  If it does not exist remove it */

        $.each(curkeys, function (i, key)
        {
          if ($.inArray(key,keys) == -1) o.removeRowByKey(key);
        });

        /* Then update table display and data */

        sortTable();                      /* Resort table */
        updateRowData();                  /* Update our inputs data */
       }
     }

    /***************************************************************************
     * spedmon.DataGrid.addRowsByKeysWithValues() */
    /**
     * Adds new empty rows with the given key values.
     *
     * @param  keys       Array of key values
     * @param  valuesArr  Array of value arrays
     ***************************************************************************/

    this.addRowsByKeysWithValues = function (keys,valuesArr)
    {
      /* If there are keys add them in bulk */

      if (keys.length > 0)
      {
        /* Add each new row by key.  If a row with the given key already exists, no row is added */

        var o = this;

        $.each(keys, function (i, key) {
          var values = valuesArr[i]; /* Get values array from array of values*/
          o.addRowByKeyWithValues(key,values);
        });

        // Get the current list of all keys

        var curkeys = getCurrentKeys();

        /* For each key check to see if it exists in the new list of keys.  If it does not exist remove it */

        $.each(curkeys, function (i, key)
        {
          if ($.inArray(key,keys) == -1) o.removeRowByKey(key);
        });

        /* Then update table display and data */

        sortTable();                      /* Resort table */
        updateRowData();                  /* Update our inputs data */
       }
     }

     /***************************************************************************
      * spedmon.DataGrid.removeRowByKey() */
     /**
      * Removes an existing row that has the given key value (if any).
      *
      * @param  key    Key value
      ***************************************************************************/

     this.removeRowByKey = function (key)
     {
       var orow = this.findRowByKey(key);  /* Find the row if it exists */
       if (orow.length > 0)
       {
         var rowid = orow.attr('id');
         this.removeRow(rowid);
       }
     };

     /***************************************************************************
      * spedmon.DataGrid.showSection() */
     /**
      * Show the given section
      *
      * @param  section  a section of one or more columns
      ***************************************************************************/

     this.showSection = function (section)
     {
       showSection(section);
     }

     /***************************************************************************
      * spedmon.DataGrid.hideSection() */
     /**
      * Hides the given section
      *
      * @param  section  a section of one or more columns
      ***************************************************************************/

     this.hideSection = function(section)
     {
       hideSection(section);
     }

     /***************************************************************************
      * spedmon.DataGrid.clear() */
     /**
      * Clears all data and removes all rows leaving an empty table.
      ***************************************************************************/

     this.clear = function ()
     {
       $('#' + id_tbl_info).html('');
	   clearTable();
     }

     /***************************************************************************
      * spedmon.DataGrid.clearValues() */
     /**
      * Clears all data but leaves rows intact.
      ***************************************************************************/

     this.clearValues = function (section)
     {
       clearValues(section);
     }

     /*----------------------------------------------------------------------
      * Private methods
      *
      * this.methodName
      *---------------------------------------------------------------------*/

     /***************************************************************************
      * getData() */
     /**
      * Gets data stored in $me and returns as an object
      ***************************************************************************/

     var getData = function()
     {
       var rowDataValObj = null;

       updateRowData();

       var rowDataValStr = $me.val();

       if (rowDataValStr)
       {
         rowDataValObj =  jQuery.parseJSON(rowDataValStr);
       }

       return rowDataValObj;
     }

     /***************************************************************************
      * hasData() */
     /**
      * Returns a true if the grid has data
      ***************************************************************************/

     var hasData = function()
     {
       var rowDataValObj = getData();
       var dflag         = false;
       if (rowDataValObj)
       {
        $.each(rowDataValObj, function(i, details) {
          $.each(details, function(j,detail){
            dflag = true;
          });
        });
       }
       return dflag;
     }

     /***************************************************************************
      * getRow() */
     /**
      * Returns tr
      ***************************************************************************/

     var getRow  = function (rowNumber)
     {
       var r = null;

       if (rowNumber)
       {
         var rowSel = 'tr:nth-child(' + rowNumber + ')';
         r = $tbl_body.find(rowSel);
       }

       return r;
     }

     /***************************************************************************
      * getCol() */
     /**
      * Returns td[]
      ***************************************************************************/

     var getCol = function (colNumber)
     {
       var cells = null;

       if (colNumber)
       {
         var colSel = 'tr > td:nth-child(' + colNumber + ')';
         cells  = $tbl_body.find(colSel);
       }

       return cells;
     }

	 /***************************************************************************
      * getColHead() */
     /**
      * Returns td[]
      ***************************************************************************/

	 var getColHead = function (colNumber)
	 {
	   var cells = null;

       if (colNumber)
       {
         var colSel = 'tr.dg-cols-new-values > th:nth-child(' + colNumber + ')';
         cells  = $tbl_head.find(colSel);
       }

       return cells;
	 }

     /***************************************************************************
      * getCell() */
     /**
      * Returns td
      ***************************************************************************/

     var getCell = function(rowNumber,colNumber)
     {
       var c = null;

       if ((rowNumber) && (colNumber))
       {
         var r = getRow(rowNumber);
         if (r)
         {
           var cellSel = 'td:nth-child(' + colNumber + ')';
           c = $(r).find(cellSel);
         }
       }

       return c;
     }

     /***************************************************************************
      * copyCellValue() */
     /**
      * Copies cell value
      ***************************************************************************/

     var copyCellValue = function (lastField)
     {

       var lastCell  = $(lastField).closest('td');

       if ($(lastCell).attr("data-copy-value-right"))
       {
          var lastType     = $(lastField).attr('type');
          var lastClsNoSub = $(lastField).hasClass('mba-web-ui-field-no-submit');
          var nextCells    = $(lastCell).nextAll();

          var lastTextVal   = $(lastField).val();
          var lastCheckVal  = $(lastField).attr('checked');

          $.each(nextCells, function(i,nextCell)
          {
            var nextField    = $(nextCell).find('input:visible');
            var nextClsNoSub = $(nextField).hasClass('mba-web-ui-field-no-submit');
            var nextType     = $(nextField).attr('type');

            if ((nextType == lastType) && (nextClsNoSub))
            {
              if (lastType == 'text') $(nextField).val(lastTextVal);
              if (lastType == 'checkbox')
              {
                  if (lastCheckVal)
                  {
                    $(nextField).attr('checked','checked');
                    $(nextField).change();
                  }
                  else
                  {
                    $(nextField).removeAttr('checked');
                    $(nextField).change();
                  }
              }
            }
          });

       }
     }

     /***************************************************************************
      * addRow() */
     /**
      * Adds a new row
      ***************************************************************************/

     var addRow = function ()
     {
       /*------------------------------
        * Construct row
        *------------------------------*/

       rowidentity++;                                        /* Update our unique row identity */
       numrows++;                                            /* Update our row counter */

       /* Create row id template. {0} Will be replaced with rowidenity {1} will be replaced with numrows */

       var id_trow_tpl  = id_tbl_body + '_rin_{0}_row_{1}';
       var rowid = $.spedmonWebUI.stringFormat(id_trow_tpl,numrows,rowidentity);

       /* Extract row values from this functions argument object (if any) */

       var args = Array.prototype.slice.apply(arguments);

       /* Create new row and add it to the end of the table */

       var rvls = []; /* Create arg array */
    
	   rvls.push(rowid); /* Add row id to arg array*/
	   
	   /* Add arguments to arg array */

       $.each(arguments, function(key, value) {
         rvls.push(value);
       });

       var row = $.spedmonWebUI.stringCreate(trowtpl,rvls);

       $tbl_body.append(row);

       var nrid = '#' + rowid

       var $nr = $(nrid);

       /* Assign event handlers to new row */

       $nr.bind("spedmoninputdata",function(e){updateRowData();return false;});

       /*-------------------------------
        * Enhance cells
        *------------------------------*/

       /* Numbers will use the numberbox control */

       var ptrn = 'input.' + $.spedmonWebUI.field.DATA_NUMBER;
       var $nf  = $nr.contents().find(ptrn);

       $.each($nf, function(l, val) {

         var sa = $(val).attr('style');
         sa = sa + 'padding:4px;font-weight:bold;border:1px solid white;';
         $(val).attr('style', sa);
         $(val).attr('maxlength','7');
         $(val).spedmonNumberbox({useLabel:false,useHover:false,useBorder:false,useOK:false,showControls:false,showOK:false,numIncDecButtons:false,numIncDecUpDownArrow:false,numIncDecMouseWheel:false});
       });

       /* Text will use the textbox control */

       ptrn = 'input.' + $.spedmonWebUI.field.DATA_TEXT;
       $nf  = $nr.contents().find(ptrn);

       $.each($nf, function(l, val) {

         var sa = $(val).attr('style');
         sa = sa + 'padding:4px;font-weight:bold;border:1px solid white;';

         $(val).attr('style', sa);
         $(val).spedmonTextbox({useLabel:false,useHover:false,useBorder:false,useOK:false,showControls:false,showOK:false});
       });

	   /* TODO: Text area should use something */

       ptrn = 'textarea.' + $.spedmonWebUI.field.DATA_TEXT_AREA;
       $nf  = $nr.contents().find(ptrn);

       $.each($nf, function(l, val) {

         var sa = $(val).attr('style');
         sa = sa + 'padding:1px;font-weight:bold;border:1px solid white;display:inline-block;';
         $(val).attr('style', sa);
         //$(val).autosize();
       });

       /* Flags will use the checkbox control */

       ptrn = 'input.' + $.spedmonWebUI.field.DATA_FLAG;
       $nf  = $nr.contents().find(ptrn);

       $.each($nf, function(l, val) {

         var sa = $(val).attr('style');
         sa = sa + 'padding:4px;font-weight:bold;border:1px solid white;';

         $(val).attr('style', sa);
         $(val).spedmonCheckBox({useLabel:false,useHover:false,useBorder:false,useOK:false,showControls:false,showOK:false});
       });

	   /* Dates will use the datebox control */

       // TODO:Implement

       /*-------------------------------
        * Assign mouse and keyboard
        * events
        *------------------------------*/

       var $ni = $nr.contents().find('input');

       $.each($ni, function(l, val) {

         /* Field borders */

         /* Note: we can get away with using val in the function w/o passing it because of var capturing */

         $(val).focusin  (function() {$(val).css('outline','1px solid black');});

         $(val).focusout (function() {$(val).css('outline','none');copyCellValue(val);updateRowData();});

         // was focus
         // was blur


         /* Keyboard events */

         $(val).keydown(function(e){

           var inputs, index, delta = null;

           var cellCount = $(val).parents('tr').find('input:visible').length;

           /* Identify keycode */

           var kcde      = $.spedmonWebUI.whatKeycode(e);

           /* Take action based on keycode */

           switch (kcde)
           {
             case 13: // down
               delta = cellCount;
               break;
             case 37: // left
               if ($(val).attr('type') == 'checkbox')
               {
                 delta = -1;
               }
               else
               {
                 if ($(val).val() == '') delta = -1;
               }
               break;
             case 38: // up
               delta = -cellCount;
               break;
             case 39: // right
               if ($(val).attr('type') == 'checkbox')
               {
                 delta = 1;
               }
               else
               {
                 if ($(val).val() == '') delta = 1;
               }
               break;
             case 40: // enter
               delta = cellCount;
           }

           if (delta != null)
           {
             e.preventDefault();
             inputs = $(val).parents('table tbody').find('input:visible');
             index = inputs.index(val);
             if (inputs[index + delta] != null)
             {
               var next = inputs[index + delta];
               $(val).removeClass('ui-state-highlight');$(this).css('border','1px solid white');
               $(next).focus();
             }
           }
         });
       });

       /* Call handler*/

       $opts.onRowAdd($me,$nr);

       return nrid;
     };

     /***************************************************************************
      * spedmon.DataGrid.findRow() */
     /**
      * Find row by given row id (rowid)
      *
      * @param  rid  Row id
      ***************************************************************************/

     var findRow = function (rowid)
     {
       var rid = '#' + rowid;
       var $row = $(rid);
       return $row;
     }

     /***************************************************************************
      * removeRow() */
     /**
      * Removes row that has the given row id (rowid)
      *
      * @param  rid  Row id
      ***************************************************************************/

      var removeRow = function (rowid)
      {
        var $row = findRow(rowid);
        if ($row.length > 0)
        {
          $row.remove();
          numrows--;
          $opts.onRowRemove($me,$row);
        }
      }

     /***************************************************************************
      * showSection() */
     /**
      * Shows the given section
      *
      * @param  section  a section of one or more columns
      ***************************************************************************/

      var showSection = function (section)
      {
        var sec = '.' + section;
        $tbl.find(sec).show();
      }

     /***************************************************************************
      * hideSection() */
     /**
      * Hides the given section
      *
      * @param  section  a section of one or more columns
      ***************************************************************************/

     var hideSection = function (section)
     {
       var sec = '.' + section;
       $tbl.find(sec).hide();
      }

     /***************************************************************************
      * clearTable() */
     /**
      * Removes all rows and resets row counter
      ***************************************************************************/

     var clearTable = function ()
     {
       numrows = 0;
       $tbl_body.html('');
       updateRowData();                                    /* Update our row data */
     }

     /***************************************************************************
      * clearValues() */
     /**
      * Clears all values but leaves rows intact.
      ***************************************************************************/

     var clearValues = function (section)
     {


	   var ptrn  = 'input, textarea';
       var ptrn2 = 'input, textarea';

       if (section)
       {
         ptrn  = 'td.' + section + ' ' + 'input' + ', ' + 'td.' + section + ' ' + 'textarea';
         ptrn2 = 'th.' + section + ' ' + 'input' + ', ' + 'th.' + section + ' ' + 'textarea';
       }

	   /* Clear body */

       var cells = $tbl_body.find(ptrn);
       $.each(cells, function (i,cell) {
         $(cell).val('');
         // Workaround for checkboxes.  TODO: Refactor in clear
         if ($(cell).is(':checked')) $(cell).attr('checked', false);
       });

       /* Clear head */
	   var cells2 = $tbl_head.find(ptrn2);
       $.each(cells2, function (i,cell) {
         $(cell).val('');
         // Workaround for checkboxes.  TODO: Refactor in clear
         if ($(cell).is(':checked')) $(cell).attr('checked', false);
       });

       updateRowData();
     }

     /***************************************************************************
      * getCurrentKeys() */
     /**
      * Gets the current key values
      ***************************************************************************/

     var getCurrentKeys = function ()
     {
       var keyvalues = $tbl_body.find('tr td .dg-key');
       keyvalues = $.map(keyvalues, function (value, i) {
         return $(value).text();
       });
       return keyvalues;
     }

     /***************************************************************************
      * sortTable() */
     /**
      * Sorts the table by key
      ***************************************************************************/

     var sortTable = function ()
     {

       /* Extract table rows into array */

       var rows = $tbl_body.find('tr').get();

       /* If the options say to not sort then skip the sorting  */

       if ($opts.sortRowsByKey == true)
       {


       /* Compute sort key */

       $.each(rows, function(i, row) {

         /* Get key cell */

         var sk = $(row).children('td').children('.dg-key');

         if ($(sk).hasClass('mba-web-ui-field-data-date'))
         {
           /* Sort key is a date, convert the cell text to a date */
           row.sortKey = Date.parse($(sk).text());
         }
         else if ($(sk).hasClass('mba-web-ui-field-data-number'))
         {
           /* Sort key is a number, convert the cell text to a number */
           row.sortKey = parseFloat($(sk).text());
         }
         else
         {
           /* Sort key is text, convert the cell text to lowercase */
           row.sortKey = $(sk).text().toLowerCase();
         }
       });

       /* Perform sort using array object sort */

       rows.sort(function (rowA,rowB) {
         var keyA = rowA.sortKey;
         var keyB = rowB.sortKey;
         if (keyA < keyB) return -1;
         if (keyA > keyB) return 1;
         return 0;
       });
       }

       /* Renum  */

       $.each(rows,function (i,row) {
	   
         /* Replace row number with proper number*/
         var rnmbr = i + 1;
		
		 if ($opts.addRemoveButtonForEachBodyRow == true) {   
		   var dgrntd = $(row).find('td.dg-row-number');		   
		 
		   /* TODO: Button icons dont appear to work.  Find out why */

		   var butRemRow = $('<button type="button" class="dg-row-control-remove">&#x2716;</button>')
		                 .button() 
						 .click(function(){var remWhatRowID = $(row).attr('id');obj.removeRow(remWhatRowID);});
           
		   $(dgrntd).html('');
		   $(dgrntd).text(rnmbr);         		 		   
		   $(dgrntd).prepend(butRemRow);		 
		 }
		 else {
		   $(row).find('td.dg-row-number').text(rnmbr); /* Previous functionality for backwards compatibility and forwards compatibility*/         		 
		 }		          
		 
		 $tbl_body.append(row);  /* Append removes the item first then adds it */
         row.sortKey = null;     /* Clean up the sorting key */
       });
     }

    /***************************************************************************
     * fireDataSelected() */
    /**
     * Indicates data entry is complete
     ***************************************************************************/

     var fireDataSelected = function ()
     {
       updateRowData();
       var $lbl = $opts.labelGenerate();
       jQuery.spedmonWebUI.fireDataSelected($me,{id:$me.attr('id'),label:$lbl,value:$me.val()});
     }

     /***************************************************************************
      * updateRowData() */
     /**
      * Updates our input with the row data.
      * The row data is stored as json in the following form.
      * {name:[{row},{row},{row}]}
      *
      * Note: This function is called by just about everything after every action
      * so it is a good place to handle change events.
      ***************************************************************************/

     var updateRowData = function ()
     {

       /*-------------------------------
        * Hide columns that should be
        * hidden
        *------------------------------*/

       $tbl.find('.dg-hidden').hide();

       /*-------------------------------
        * Show or hide col controls and
        * col values based on number of
        * rows
        *------------------------------*/

       if (numrows > 1)
       {
         $tbl_head.find('tr.dg-cols-new-values').show();
         $tbl_head.find('tr.dg-cols-ctrls').show();
       }
       else
       {
         $tbl_head.find('tr.dg-cols-new-values').hide();
         $tbl_head.find('tr.dg-cols-ctrls').hide();
       }

       /*-------------------------------
        * Get table rows and start our
        * json string
        *------------------------------*/

       var oRows = $tbl_body.contents();
       var valStr = '{"' + name +'":[';

       /*-------------------------------
        * For each row
        *------------------------------*/

       $.each(oRows, function(i, vrow) {

         /*-------------------------------
          * Open first object definition or
          * append (with comma)
          *------------------------------*/

         var fldsStr = "";
         if (i)
           fldsStr =  fldsStr + ',{';
         else
           fldsStr = fldsStr + '{';

         /*-------------------------------
          * Extract columns
          *
          * Note: We are only looking for
          * columns that have the class
          * dg-cell.
          *------------------------------*/

         var oCols = $(vrow).children('.dg-cell');

         $.each(oCols, function(j, vcol) {


         /*-------------------------------
          * Determine if column contains
          * dg-data or a label
          *------------------------------*/

           eInput = $(vcol).find('input.dg-data');
		   eTa    = $(vcol).find('textarea.dg-data');
           eSpan  = $(vcol).find('span.label');

           var cVal = "";

           var cValReqQuotes = false;

           if (eInput.length > 0)
           {
             var v = $(eInput).val();
			 cVal = $.spedmonWebUI.jsonStringEscape(v);
           }

		   if (eTa.length > 0)
		   {
		     var v = $(eTa).val();
			 cVal = $.spedmonWebUI.jsonStringEscape(v);
		   }

           if (eSpan.length  > 0)
           {
             var v = $(eSpan).text();
			 cVal = $.spedmonWebUI.jsonStringEscape(v);
           }

           //if ((!cValReqQuotes) && (cVal.length == 0))
            // cVal = null;

           var qt = (cValReqQuotes) ? '"' : '';

           /*-------------------------------
            * Lookup name to use for cell
            * name/value pair from column
            * definitions in options
            *------------------------------*/

           if (j)
             fldsStr = fldsStr + ',"' + $opts.aCols[j].name + '":' + qt + cVal + qt;
           else
             fldsStr = fldsStr + '"' + $opts.aCols[j].name + '":' + qt + cVal + qt;
         });
         valStr = valStr + fldsStr + '}';
       });
       valStr = valStr + ']}';
       $me.val(valStr);
     }

	 /***************************************************************************
      * setData() */
     /**
      * Sets data
      ***************************************************************************/

     var setData = function()
     {

	   clearTable();

	   /*----------------------------------------------------------------------
        * Load data if it is passed in
        *---------------------------------------------------------------------*/

       var valueIn = $($me).prop("defaultValue");
       if (valueIn)
       {
         /*------------------------------
          * Convert JSON to object
          *------------------------------*/

         var rowDataValObj = jQuery.parseJSON(valueIn);

         /*------------------------------
          * We expect the rows to be
          * children of the first child
          *------------------------------*/

         jQuery.each(rowDataValObj,function(i,rowsData){
           jQuery.each(rowsData,function(j,rowData){

             /*------------------------------
              * Create values array
              *------------------------------*/

             var keyVal  = null;
             var rowVals = [];

             jQuery.each($opts.aCols,function(k,colData){

               var fldVal = rowData[colData.name];
               if (colData.iskey == true)
               {
                 keyVal = fldVal;
               }
               else
               {
                 rowVals.push(fldVal);
               }
             });

             if (keyVal)
             {
               obj.addRowByKeyWithValues(keyVal,rowVals);
             }
             else
             {
               addRow.apply(undefined, rowVals)
             }
             // TODO: Delegate for after row added
           });
         });
       }
	   updateRowData();
	 }

	 /*----------------------------------------------------------------------
      * Load if there is data in the underlying input
      *---------------------------------------------------------------------*/

	 setData();

  };

  /*----------------------------------------------------------------------
   * jQuery constructor and linkage
   *---------------------------------------------------------------------*/

  $.fn.spedmonDataGrid = function (options)
  {
    /*-------------------------------
     * Tie into jQuery chain and
     * instantiate datagrid(s)
     *------------------------------*/

    /*-------------------------------------------------------------------
     * If the selector returns elements work with them.
     *-------------------------------------------------------------------*/

    return this.each(function()
    {
      var $me = $(this);                                         /* Grab reference to input*/
      if ($me.data('spedmondatagrid')) return;                   /* Return early if this input already has a datagrid instance*/
      var spedmondatagrid = new spedmonDataGrid(this, options);  /* Create datagrid object and pass options in*/
      $me.data('spedmondatagrid', spedmondatagrid);              /* Store datagrid object in inputs data */
    });
  };

  /*----------------------------------------------------------------------
   * Option defaults
   *---------------------------------------------------------------------*/

  $.fn.spedmonDataGrid.defaults = {
    aCols:{},
    labelGenerate:function(){return 'Details Entered or Updated';},
    showControls:true,
    showColControls:true,
    showRowControls:true,
    showOK:true,
    showClear:true,
    sortRowsByKey:true,
    onRowFocusIn:function(e){},
    onRowFocusOut:function(e){},
    onCellFocusIn:function(e){},
    onCellFocusOut:function(e){},
    onRowAdd:function(dgObj,rowObj){},
    onRowRemove:function(dgObj,rowObj){},
	onClearButtonClick:function(){},
	addRemoveButtonForEachBodyRow:false
  };
})(jQuery); /* Datagrid */

/***************************************************************************
 * detailListAddRemoveItem*/
/**
 * Adds a detail list item
 *
 * @param  $()        list id
 * @param  code       status code
 * @param  value      message to display
 * @param  addRemove  0=add, 1=remove, 2=add with auto remove
 ***************************************************************************/

;(function($){
   $.fn.spedmonDetailListAddRemoveItem = function(code,value,addRemove,onClick){
      return this.each(function(){

        if (!addRemove) addRemove = 0;

        var detailCls  = $.spedmonWebUI.ret.CSS_DETAIL_GOOD;
        var detailImg  = $.spedmonWebUI.ret.IMG_GOOD_16;
        var moreDetail = false;

        var $detail = $('<li class="' + detailCls +'"><a href="#">' + value + '</a></li>');

        if (code == $.spedmonWebUI.ret.WAIT){
          detailCls = $.spedmonWebUI.ret.CSS_DETAIL_WAIT;
          detailImg = $.spedmonWebUI.ret.IMG_WAIT_16;
          }

        if ((code == $.spedmonWebUI.ret.CRITICAL) || (code == $.spedmonWebUI.ret.ERROR)){
          detailCls = $.spedmonWebUI.ret.CSS_DETAIL_CRIT;
          detailImg = $.spedmonWebUI.ret.IMG_ERROR_16;}

        if ((code == $.spedmonWebUI.ret.WARNING) || (code == $.spedmonWebUI.ret.DUP_RECORD)){
          detailCls = $.spedmonWebUI.ret.CSS_DETAIL_WARN;
          detailImg = $.spedmonWebUI.ret.IMG_ALERT_16;}

        if (code == $.spedmonWebUI.ret.INFO){
          detailCls = $.spedmonWebUI.ret.CSS_DETAIL_INFO;
          detailImg = $.spedmonWebUI.ret.IMG_INFO_16;}

        if (code == $.spedmonWebUI.ret.SUCCESS){
          detailCls = $.spedmonWebUI.ret.CSS_DETAIL_GOOD;
          detailImg = $.spedmonWebUI.ret.IMG_GOOD_16;}

      $detail = $('<li class="'+ detailCls +'"><a class="' + detailCls + '"><img class="detail" src="' + detailImg +'"/><span class="' + detailCls + '">' + value + '</span></a></li>');

      // Look for an existing detail with the same value and if one exists remove it

      var srcStr = "li:contains('" + value + "')";
      $(this).children().remove(srcStr);

      // Finally add our item if this is an add

      if (addRemove==0)
      {
        // If on click option is specified wire it up
        if (onClick)
        {
          $detail.click(function(e){onClick(e);});
        }
        $(this).append($detail);
      }

      if (addRemove==2)
      {
        var $dl = $(this).append($detail);
        $dl.oneTime(5000,function(){$dl.children().remove(srcStr);});
      }

    });
  };
})(jQuery);

/***************************************************************************
 * detailListAddRemoveWait*/
/**
 * Adds/removes wait icon
 *
 * @param $()       list id
 * @param addRemove 0=add, 1=remove
 ***************************************************************************/

;(function($){
   $.fn.spedmonDetailListAddRemoveWait = function(addRemove,onClick){
      return this.each(function(){
        $(this).spedmonDetailListAddRemoveItem($.spedmonWebUI.ret.WAIT,"Please Wait",addRemove,onClick);
    });
  };
})(jQuery);


/***************************************************************************
 * detailListClear*/
/**
 * Clear given detail list
 *
 * @param $()     list id
 ***************************************************************************/

;(function($){
   $.fn.spedmonDetailListClear = function(){
      return this.each(function(){
      $(this).html('');
    });
  };
})(jQuery);

/***************************************************************************
 * spedmon.dataTable */
/**
 * Datatable for record preview and record selection
 ***************************************************************************/

;(function($){
  $.fn.spedmonDataTable = function(options){

	/*###########################################################################
      # Load options and merge defaults
      ###########################################################################*/    

    var $opts = $.extend({},$.fn.spedmonDataTable.defaults,options);

    /*###########################################################################
      # Tie into return chain
      ###########################################################################*/    

    return this.each(function() {

      var $me      = $(this);              // This control
      var meid     = $me.attr('id');       // This controls id
      var tblWidth = $me.width();        // Width of the  table

      var $tbl;             // Our table
      var tblid;            // Our tables id
      var tblwrap;          // Wrapper div for table
      var tblbodysel;       // Tables body
      var frmid;            // Our form id
      var $frm;             // Our form
      var statusidsel;      // Status id
      var $status;          // Our status control
      var recSelect;
      var recSelectMax;
      var recFlagSelected;          
      var listHandlerURL;
      var fvTablePaginateID = tblid + '_paginate';
	  var fvTableInfoID     = tblid + '_info';
      var rowClicks = 0
      var rowClickTimer = null;
      
      tblid              = $opts.sTblID;
      tblwrap            = '#' + tblid + '_wrapper';
      tblbodysel         = '#' + tblid + ' tbody';
      frmid              = $opts.sFormID;
      $frm               = $(frmid);
      statusidsel        = $opts.sStatusIDSel;
      $status            = $(statusidsel);
      recSelect          = $opts.bRecordSelect;
      recSelectMax       = $opts.iRecordSelectMax;
      fnRecordSelected   = $opts.fnRecordSelected;
      recFlagSelected    = $opts.bRecordFlagSelected;
      listHandlerURL     = $frm.attr('action');
      
      $me.html('');
           

	/*###########################################################################
      # Datatable object
      ###########################################################################*/    

    var $fvDtObj = null;

	/*###########################################################################
      # Datatable handlers
      ###########################################################################*/    

    var fnDtDraw = function (oSettings) 
    {
	  /* If record selection is enabled */
      if (recSelect == 1)
      {	
	    $('#' + tblid + ' tbody tr').hover(function(){$(this).addClass('hover_over')},function(){$(this).removeClass('hover_over')});
      }            
	};
		
    var fnDtInitComplete = function (oSettings, json)
    {	
      if (recSelect == 1)
      {	             
        $('#' + tblid + ' tbody').on("click", function (event) { 
          $.spedmonWebUI.fireDataTableClicked($tbl);
          rowClicks++;  //count clicks

          if(rowClicks === 1) 
          {
              rowClickTimer = setTimeout(function() { 
              $(event.target.parentNode).removeClass('hover_over');
              if ($(event.target.parentNode).hasClass('selected'))
              {
                $(event.target.parentNode).removeClass('selected').removeClass('selected_flagged');
                $.spedmonWebUI.fireDataTableRecUnselected($tbl);
              }
              else
              {
                /* If only one selection allowed at a time clear previous selections */
                if (recSelectMax == 1) $($fvDtObj.fnSettings().aoData).each(function (){$(this.nTr).removeClass('selected').removeClass('selected_flagged');});
                $(event.target.parentNode).addClass('selected');
                $.spedmonWebUI.fireDataTableRecSelected($tbl);
                fnRecordSelected();
              }
              rowClicks = 0;             //after action performed, reset counter
              }, 200);
          } 
          else 
          {
            clearTimeout(rowClickTimer);    //prevent single-click action
            // dbl click action
            if (recSelectMax > 1)
            {
              if (recFlagSelected == 1)
              {                                
                if ($(event.target.parentNode).hasClass('selected'))
                {
                  $(event.target.parentNode).removeClass('hover_over');
                  if ($(event.target.parentNode).hasClass('selected_flagged'))
                  {
                    $(event.target.parentNode).removeClass('selected_flagged');
                  }
                  else
                  {                
                    $($fvDtObj.fnSettings().aoData).each(function (){$(this.nTr).removeClass('selected_flagged');});
                    $(event.target.parentNode).addClass('selected_flagged');
                  }
                  $.spedmonWebUI.fireDataTableRecSelectedToggleFlagged($tbl);
                }
                
              }
            }
            rowClicks = 0;             //after action performed, reset counter
          }

        })
        .on("dblclick", function(event){event.preventDefault();});
      }
	   

	  	    
    };
	
	var fnDtHdrCb = function( nHead, aData, iStart, iEnd, aiDisplay ) 
    {      
          /* Restyle head */
	  $('th', nHead).css('font-size','.90em').css('font-weight','bold');
	}
	
	var fnDtRowCb = function( nRow, aData, iDisplayIndex, iDisplayIndexFull) 
    {
	  /* Restyle row */	  
	  $('td', nRow).css('font-size','.90em');
	  return nRow;
	};
	
	var fnDtInfoCb = function ( oSettings, iStart, iEnd, iMax, iTotal, sPre ) 
    {
      /* Handles dt info */
	  return 'Displaying ' + iStart + ' to ' + iEnd + ' of ' + iTotal + ' records.';
	};
	
	var fnDtPageChange = function (whatPage) {
      /* Change page to "first", "previous", "next" or "last" */
	  $fvDtObj.fnPageChange( whatPage );
	};
			
	var fnDtServerData = function (sSource, aoData, fnCallBack) 
    {    
	  $.spedmonWebUI.ajaxRpt ($frm, aoData, sSource, fnCallBack, 0, null, null);
	  return;
      
     
	};			
			
	/*###########################################################################
      # Datatable Options
      ###########################################################################*/  
    
	var dtOpts = {    
                      "bDestroy"         : $opts.bDestroy
                    , "bPaginate"        : $opts.bPaginate
	                , "bFilter"          : $opts.bFilter
                    , "bJQueryUI"        : $opts.bJQueryUI
                    , "bAutoWidth"       : $opts.bAutoWidth
	                , "bLengthChange"    : $opts.bLengthChange		            
					, "bSort"            : $opts.bSort
                    , "bSortClasses"     : $opts.bSortClasses
					, "bInfo"            : true
					, "bProcessing"      : $opts.bProcessing
					, "bServerSide"      : $opts.bServerSide
	                , "bDeferRender"     : true
					, "iDisplayLength"   : $opts.iDisplayLength
					, "bScrollCollapse"  : $opts.bScrollCollapse
                    , "sScrollX"         : $opts.sScrollX
    				, "sScrollY"         : $opts.sScrollY
	                //, "sScrollXInner"    : $opts.sScrollXInner
					, "sAjaxSource"      : listHandlerURL
					, "fnServerData"     : fnDtServerData
					, "fnDrawCallback"   : fnDtDraw
					, "fnInitComplete"   : fnDtInitComplete
					, "fnInfoCallback"   : fnDtInfoCb
					, "fnHeaderCallback" : fnDtHdrCb
                    , "fnRowCallback"    : fnDtRowCb	
				 };
	
	
	var respHasRecs = false;
	
	var fnDataInitProcResp = function ($resp) {
	  
	  if (($resp.status == $.spedmonWebUI.ret.SUCCESS) && ($resp.data.hasRecords))
      { 					
		respHasRecs = true;
		$me.html('<table id="' + tblid + '"><thead><tr></tr></thead><tbody><tr></tr></tbody></table>');
        $tbl = $('#' + tblid);        
        var $aoCols = $resp.data.aoColumns;
        
		/* Add a class specific to this control to each column */
        $.each($aoCols,function(i,$col) {
		  $col.sClass = "dt-col " + $col.sClass;
		});
		       
		/* Pass data to options */
		
		dtOpts.aoColumns      = $aoCols;	
        dtOpts.bPaginate      = $resp.data.recordsPaged;
        dtOpts.iDisplayLength = $resp.data.iRecordPageSize;	    
     
      }
      else
      {
        respHasRecs = false;
        $me.html('No Records');
      }	  	 	

    };
    	
	var fnDataInitProcComplete = function () {	    
		if (respHasRecs == true)
		{
		
          $('#reptform').val(1);
          $('#reptcolsonly').val(0);
          $('#reptpaging').val(1);

          /* Create data table */
	  
	      $fvDtObj = $($tbl).dataTable(dtOpts);
	  
	      /* Change style of info */
	  
	      $('#' + fvTableInfoID).show();
	      $('#' + fvTableInfoID).css('text-align','center');
	      $('#' + fvTableInfoID).css('font-weight','bold');	  	  	     
	    }
	};
	
	
	/*###########################################################################
      # Inital Contact server 
      ###########################################################################*/  
	
     $('#reptform').val(1);
     $('#reptcolsonly').val(1);
     $('#reptpaging').val(1);
  
	var frmData = $($frm).serialize();
	
	$.spedmonWebUI.ajax (  $frm
	                     , listHandlerURL
						 , frmData
						 , 'nvp_json'
						 , null
						 , fnDataInitProcResp
						 , null
						 , null
						 , true
						 , null
						 , fnDataInitProcComplete
						 , null);

      });

  };

  /*-------------------------------
   * Option defaults
   *------------------------------*/

  $.fn.spedmonDataTable.defaults = {
    "bDestroy":false,
    "bFilter":false,
    "bJQueryUI": true,
    "sScrollX":"100%",
    "sScrollXInner": "150%",
    "bScrollCollapse": true,
    "sScrollY": "300px",
    "bPaginate":true,
    "iDisplayLength":50,
    "bLengthChange": false,
    "bAutoWidth": false,
    "bSort":false,
    "bSortClasses": false,
    "bServerSide": true,
    "bProcessing": false,
    "sStatusIDSel":"",
    "sFormID":"",
    "sTblID:":"",
    "bRecordSelect":true,
    "iRecordSelectMax":1,
    "fnRecordSelected":function(){},
    "bRecordFlagSelected":false
  };

})(jQuery);


/***************************************************************************
 * spedmonDataViewRecordsView */
/**
 * Datatable for record preview and record selection
 *
 * Requires:
 *
 ***************************************************************************/

;(function($){

  $.fn.spedmonDataViewRecordsView = function(options) {

	/*###########################################################################
      # Load options and merge defaults
      ###########################################################################*/    

    var $opts = $.extend({},$.fn.spedmonDataViewRecordsView.defaults,options);

	
	/*###########################################################################
      # Tie into return chain
      ###########################################################################*/    

    return this.each(function() {

      /*###########################################################################
        # Get references and create additional markup
        ###########################################################################*/    
	
      var $me            = $(this);              // This control
      var meid           = $me.attr('id');       // This controls id	  	  	 
	  var $dtForm        = $('#' + $opts.dataViewRequestFormCtrlID);
	  var listHandlerURL = $($dtForm).attr('action');
	  var recIDPos       = $opts.recIDPos;
	  var fnOnSelect     = $opts.onSelect;
	  var dtTableID      = meid  + '-dtbl-records';
	  var dtContainerID  = meid  + '-dtbl-container';
	  var $dtContainer = $('<div id="' + dtContainerID + '"></div>');
	  var $dtTable  = null;	  	 
      var $dtObj = null;
	  	  
	  /*###########################################################################
        # Add mkup
        ###########################################################################*/    

	  $($me).append($dtContainer);

	  /*###########################################################################
        # Datatable handlers
        ###########################################################################*/    
    		  		  	
	  var fnDtGetSelected = function () {
	 
	   var $oSelRowData = {};
	   $oSelRowData.hasRows = null;
	   $oSelRowData.hasSel  = null;
	   $oSelRowData.recID   = null;
	   $oSelRowData.rowIdx  = null;
	 
	   var $oRows = $dtObj.fnGetNodes();
     
	   if (!$oRows) {
	     $oSelRowData.hasRows = false;
	     $oSelRowData.hasSel = false;
	     return $oSelRowData;
	   };
	 
	   $oSelRowData.hasRows = true;
	 
       for (var i=0; i < $oRows.length; i++) {
       if ($($oRows[i]).hasClass('selected')) {                   
            $oSelRowData.recID  = $dtObj.fnGetData(i)[recIDPos];         
            $oSelRowData.rowIdx = i;
			$oSelRowData.hasSel = true;
		  	return $oSelRowData;
	     }
	   }
	  
	    $oSelRowData.hasSel = false;
	    return $oSelRowData;
	  };
	
	  var fnDtDraw = function (oSettings) {
	    /* Handle hover over row */
	    $('#' + dtTableID + ' tbody tr').hover(function(){$(this).addClass('hover_over')},function(){$(this).removeClass('hover_over')});		
	  };
	  
	  var handleRowClick = function (selRow) {
	      if (!selRow) return;
		  $($dtObj.fnSettings().aoData).each(function (){$(this.nTr).removeClass('selected');});
          
		  $(selRow).removeClass('hover_over');
          $(selRow).addClass('selected');
		  var oSelRowData = fnDtGetSelected();
		  fnOnSelect(oSelRowData);
	  };
	  
	  var fnDtInitComplete = function (oSettings, json) {
	
	    /* Add ability to select a row */
	  
	    $('#' + dtTableID + ' tbody').click( function (event) { 
          var $selectedRow =  $(event.target.parentNode);
		  handleRowClick($selectedRow);		  
	    });	
        
		/* Auto select first row */		
		
        var $firstRow = $dtObj.fnGetNodes(0);
		handleRowClick($firstRow);		  
	  
	    /* Workaround for paging issue */
		
		$('#' + dtTableID + '_previous').html('<span class="dt-page-but dt-prev-page-but">&#9664; Previous</span');
		$('#' + dtTableID + '_next').html('<span class="dt-page-but dt-next-page-but">Next &#9654</span>');
				
	  };
	
	  var fnDtHdrCb = function( nHead, aData, iStart, iEnd, aiDisplay ) {      
        /* Restyle head */
	    //$('th', nHead).css('font-size','.75em').css('font-weight','bold');
	    return nHead;
	  }
	
	  var fnDtRowCb = function( nRow, aData, iDisplayIndex, iDisplayIndexFull) {
	    /* Restyle row */	  
	    //$('td', nRow).css('font-size','.75em');
	    return nRow;
	  };
	
	  var fnDtInfoCb = function ( oSettings, iStart, iEnd, iMax, iTotal, sPre ) {
        /* Handles dt info */		
		return '<p>Displaying ' + iStart + ' to ' + iEnd + ' of ' + iTotal + ' rows. Click on a row to select.</p>';
	  };
		 	 
	  var fnDtServerData = function (sSource, aoData, fnCallBack) {		
	    $.spedmonWebUI.ajaxRpt ($dtForm , aoData, sSource, fnCallBack, 0, null, null);
	    return;
	  };			
			
	  /* TODO: For some reason passing iDisplayLength from the options to the datatable plugin options breaks. So its set to 50 for now.*/
	  
	  var dtOpts = {    "bPaginate"        : true
	                  , "bAutoWidth"       : true
					  , "bDestroy"         : true
					  , "bLengthChange"    : false
					  , "bJQueryUI"        : $opts.bJQueryUI
		              , "bFilter"          : false
			    	  , "bSort"            : false
					  , "bInfo"            : true
					  , "bProcessing"      : false						
					  , "bServerSide"      : true
	                  , "bDeferRender"     : true					  
					  , "iDisplayLength"   : 50
					  , "sPaginationType"  : "two_button"
                      , "sScrollX"         : $opts.sScrollX
					  , "sScrollY"         : $opts.sScrollY
					  , "bScrollCollapse"  : false
					  , "bSortClasses"     : false
					  , "sAjaxSource"      : listHandlerURL					
					  , "fnServerData"     : fnDtServerData
					  , "fnDrawCallback"   : fnDtDraw
					  , "fnInitComplete"   : fnDtInitComplete
					  , "fnInfoCallback"   : fnDtInfoCb
					  , "fnHeaderCallback" : fnDtHdrCb
                      , "fnRowCallback"    : fnDtRowCb	
				   };
	
	
	  var respHasRecs = false;
	
	  var fnDataInitProcResp = function ($resp) {
	
	    if (($resp.status == $.spedmonWebUI.ret.SUCCESS) && ($resp.data.hasRecords))
        { 						
		  respHasRecs = true;
		
		  var $aoCols = $resp.data.aoColumns;
		  
		  $.each($aoCols,function(i,$col) {
            $col.sClass = "";
		    $col.sWidth = null;
		  });		
		  
		  /* Pass column data to options */
		
		  dtOpts.aoColumns = $aoCols;
		  		
	    }
        else
        {
          respHasRecs = false;
        }	  
      };
    
	var fnSetReptParms = function (reptform,reptcolsonly,reptpaging) {
	  $($dtForm).children('input[name="reptform"]').val(reptform);
	  $($dtForm).children('input[name="reptcolsonly"]').val(reptcolsonly);
	  $($dtForm).children('input[name="reptpaging"]').val(reptpaging);
	};
	
   	  var fnDataInitProcComplete = function () {	   
		$($dtContainer).html('');
		fnSetReptParms(1,0,1);
		if (respHasRecs == true) {
  	      $dtTable = $('<table id="' + dtTableID +'"></table>');
	      $($dtContainer).append($dtTable);
		  $dtObj = $('#' + dtTableID).dataTable(dtOpts);
		}		
	  };
	      
	  var fnInit = function () {
	   	
  	    respHasRecs = false;
	    fnSetReptParms(1,1,1);
		var frmData = $($dtForm).serialize();
	  
	    $.spedmonWebUI.ajax (  $dtForm 
	                         , listHandlerURL
		    		 		 , frmData
						     , 'nvp_json'
						     , null
						     , fnDataInitProcResp
						     , null
						     , null
						     , true
						     , null
						     , fnDataInitProcComplete
						     , null);

	  };
	 
	 var fnRefresh = function() {
	  fnInit();
	 };
	 
	/*###########################################################################
      # Initial Server Contact
      ###########################################################################*/  
	
	fnInit();
	 
    /*###########################################################################
      # Create references for external functions to use
      ###########################################################################*/  

	var ctrlData = {};
	ctrlData.dtObj         = $dtObj;
	ctrlData.fnRefresh     = fnRefresh;
    ctrlData.fnGetSelected = fnDtGetSelected;
	$.data(this, 'spedmonDataViewRecordsView', ctrlData);	   
	});
  
  };
  
 /*###########################################################################
   # Option defaults
   ###########################################################################*/  
	
  $.fn.spedmonDataViewRecordsView.defaults = {
      "dataViewRequestFormCtrlID":null
    , "recIDPos":2
	, "onSelect":function(oSelRowData){}
    , "sScrollX" : "100%"
	, "sScrollY" : "100%"
	, "bJQueryUI" : false
	, "iDisplayLength" : 50
  };
  /* TODO: For some reason passing iDisplayLength to the datatable plugin options breaks.*/
})(jQuery);
      


/***************************************************************************
 * spedmonDataViewRequestForm */
/**
 * Used for filtering .  Requires
 ***************************************************************************/

;(function($){

  $.fn.spedmonDataViewRequestForm = function(options) {

	/*###########################################################################
      # Load options and merge defaults
      ###########################################################################*/    

    var $opts = $.extend({},$.fn.spedmonDataViewRequestForm.defaults,options);

    /*###########################################################################
      # Tie into return chain
      ###########################################################################*/    

    return this.each(function() {

      /*###########################################################################
        # Get references
        ###########################################################################*/    
	
      var $me            = $(this);              // This control
      var meid           = $me.attr('id');       // This controls id	  	  
      var fnOnSpedmonInputData = $opts.onSpedmonInputData;
      
      var fnTrapEnter = function(e) {
        var kp = $.spedmonWebUI.whatKeycode(e);
        if (kp == 13) return false;
      };
      
      var fnRefreshDt = function(e) {        
		var $dataViewRecordsViewCtrlData = $('#' + $opts.dataViewRecordsViewCtrlID).data('spedmonDataViewRecordsView');
        $dataViewRecordsViewCtrlData.fnRefresh();
        e.stopPropagation();
        return false;
      };
	  
      var spedmonInputDataHdlr = function (e) {
	    fnOnSpedmonInputData(e);
	    fnRefreshDt(e);
	  };
	  
      $($me).on('keypress',fnTrapEnter);
      $($me).on('spedmoninputdata',spedmonInputDataHdlr);
      
	 	   
	  
    });
  
  };
 /*###########################################################################
   # Option defaults
   ###########################################################################*/  
	
  $.fn.spedmonDataViewRequestForm.defaults = {
      "dataViewRecordsViewCtrlID":null	
	 ,"onSpedmonInputData":function(e){}
  };

})(jQuery);


/***************************************************************************
 * spedmon.Step */
/**
 * Step control
 ***************************************************************************/

 ;(function($){

  /*-------------------------------
   * Create
   *------------------------------*/

  $.fn.spedmonStep = function(options){

   var $opts;         // Control options

  /*-------------------------------
    * Grab options
    *------------------------------*/

	$opts = $.extend({},$.fn.spedmonStep.defaults,options);

    /*-------------------------------
    * Tie into return chain
    *------------------------------*/

    return this.each(function() {

      /*-------------------------------
       * To save time create references
       * to the various parts of this
       * control
       *------------------------------*/

      var $me            = $(this);
      var $label         = $($opts.id_label);
      var $stepnum       = $($opts.id_stepnum);
	  var $steps         = $($opts.id_steps);
      var stepnum        = parseInt($stepnum.text());;
      var $stepnumcont   = $stepnum.parent();
      var $ntc_cont      = $($opts.id_ntc_cont);
      var $content       = $($opts.id_content);
      var $header        = $($opts.id_header);
      var $selopts       = $($opts.id_sel_opts);
      var $optional      = $($opts.id_optional);
      var $stepopts      = $($opts.id_step_opts);
      var $stepinst      = $($opts.id_stepinst);
	  var $steptitle     = $($opts.id_title);
      var $startsection  = $opts.id_start_sec;

     /*-------------------------------
      * Apply styles
      *------------------------------*/

	  $ntc_cont.addClass("ui-spedmon-step-ntc-cont");
      $stepnum.addClass("ui-spedmon-step-number");
      $label.addClass("ui-spedmon-step-label");
      $steptitle.addClass("ui-spedmon-step-title");

      // Step options

      $stepopts.children().each(function(){$(this).addClass("ui-spedmon-step-opt");});

      // Post selection options

      $selopts.addClass("ui-spedmon-step-sel-opts-cont");
      $selopts.children().each(function(){$(this).addClass("ui-spedmon-step-sel-opt");});
      if ($label.text().length == 0) $selopts.hide();

	  // Save references for other methods

	  var step = {};
      step.me           = $me;
      step.label        = $label;
      step.$stepnum     = $stepnum;
	  step.steps        = $steps;
      step.stepnum      = stepnum;
      step.stepnumcont  = $stepnumcont;
	  step.content      = $content;
	  step.header       = $header;
	  step.optional     = $optional;
	  step.stepinst     = $stepinst;
	  step.steptitle    = $steptitle;
	  step.startsection = $startsection;
      step.selopts      = $selopts;
	  $.data(this, 'spedmonStep', step);

	 /*-------------------------------
      * Activate start section if
	  * there is one
      *------------------------------*/

	  $($me).spedmonStep_switchSection($startsection);

	 /*-------------------------------
      * Highlight step if the highlight
      * class is present.  This would
      * happen in cases where the
      * higlight step function was called
      * and the step has not been
      * completely rendered yet
      *------------------------------*/

     if ($me.hasClass('ui-state-highlight'))
     {
       $($me).spedmonStep_highlight(true);
     }
     else
     {
      $($me).spedmonStep_highlight(false);
     }

	});
  };

  /*-------------------------------
   * Option defaults
   *------------------------------*/

  $.fn.spedmonStep.defaults = {
    showControls:false
  };

  /*-------------------------------
   * Switch Section
   *------------------------------*/

  $.fn.spedmonStep_switchSection = function (sec_id) {

    return this.each(function() {

      var $me          = $(this);        // Parent step
	  var $stepsection = $(sec_id);      // Section

      if ($stepsection.length)
	  {
		var titleid      = sec_id + '_title';
	    var instrid      = sec_id + '_instr';
		var title        = $(titleid).html();
	    var instr        = $(instrid).html();
	    $stepsection.show();                                  // Show active step section
 	    $stepsection.siblings().hide();
	    $($me).spedmonStep_setTitle(title);                   // Set step title
	    $($me).spedmonStep_setInstructions(instr);            // Set step instructions
	  }
	});
  };

  /*-------------------------------
   * Highlight step
   *------------------------------*/

  $.fn.spedmonStep_highlight = function(tgl){
    return this.each(function() {

      var $me  = $(this);
      var $ntc = $me.find('div.ui-spedmon-step-ntc-cont');
      var $lbl = $me.find('div.ui-spedmon-step-label');

      if (tgl == true)
      {
        $me.addClass('ui-state-highlight');
        $ntc.addClass('ui-state-highlight');
        $lbl.addClass('ui-state-highlight');
        $ntc.addClass('ui-spedmon-step-highlight');
        $lbl.addClass('ui-spedmon-step-highlight');
      }
      else
      {
        $me.removeClass('ui-state-highlight');
        $ntc.removeClass('ui-state-highlight');
        $lbl.removeClass('ui-state-highlight');
        $ntc.removeClass('ui-spedmon-step-highlight');
        $lbl.removeClass('ui-spedmon-step-highlight');
      }

    });
  };

  /*-------------------------------
   * Set Title
   *------------------------------*/

  $.fn.spedmonStep_setTitle = function(title){
    return this.each(function() {
      var $me  = $(this);
	  var step = $($me).data('spedmonStep');
	  var $steptitle = step.steptitle;
      $($steptitle).text(title);
      $($steptitle).show();
    });
  };

  /*-------------------------------
   * Set Instructions
   *------------------------------*/

  $.fn.spedmonStep_setInstructions = function(instructions){
    return this.each(function() {
      var $me  = $(this);
	  var step = $($me).data('spedmonStep');
	  var $stepinst = step.stepinst;
      $($stepinst).html(instructions);
      $($stepinst).show();
    });
  };


  /*-------------------------------
   * Set Label
   *------------------------------*/

  $.fn.spedmonStep_setLabel = function(label){
    return this.each(function() {
      var $me    = $(this);
	  var step   = $($me).data('spedmonStep');
      var $label = step.label;
	  $($label).text(label);
    });
  };

  /*-------------------------------
   * Clear
   *------------------------------*/

  $.fn.spedmonStep_clear = function() {

    return this.each(function() {

	  var $me           = $(this);
	  var step          = $($me).data('spedmonStep');
	  var $label        = step.label;
      var $stepnum      = step.$stepnum;
	  var $steps        = step.steps;
      var stepnum       = step.stepnum;
      var $stepnumcont  = step.stepnumcont;
      var $content      = step.content;
      var $header       = step.header;
	  var $startsection = step.startsection;
      var $selopts      = step.selopts;

      // Remove highlight

      $($me).spedmonStep_highlight(false);


      // Hide select options

      $selopts.hide();

	  // Clear step label

      $label.text('');

     /*-------------------------------
      * Look for and clear the value
	  * attribute in all input controls
      * contained within this steps
      * content excluding those controls
      * that have a no-clear class.
      *------------------------------*/

      var simplefields = $content.find('input').not('.' + $.spedmonWebUI.field.NO_CLEAR);

      $.each(simplefields, function(i, simplefield){

        /*-------------------------------
         * If the control has a default
	     * value "clear" the field by
         * replacing its current value
         * with the default.  Otherwise
         * set the value to ''
         *------------------------------*/

        if ($(simplefield).hasClass($.spedmonWebUI.field.HAS_DEFAULT))
        {

          /*-------------------------------
           * Handle dates
           *------------------------------*/

          if ($(simplefield).hasClass($.spedmonWebUI.field.DATA_DATE))
          {
            // We have to do a bit more work to properly clear a date control to its default

            if ($(simplefield).hasClass('hasDatepicker'))
            {
              // Date control is jquery ui datepicker
              // TODO: Fix.  Setting value to blank for now

              $(simplefield).val('');

              /*var dvalue = $(simplefield).attr('data-default-value');
              var dd = $(simplefield).datepicker( "option", "defaultDate");
              $(simplefield).datepicker("setDate", dd);*/
            }
            else if ($(simplefield).hasClass('hasDatepick'))
            {
              // Date control is Keith Luck's datepick
              // TODO: Default is not supported yet, just clear the value
              $(simplefield).val('');
            }
          }

          /*-------------------------------
           * Handle everything else
           *------------------------------*/

          else
          {
            var dvalue = $(simplefield).attr('data-default-value');

            /*-------------------------------
             * Handle flags (y/n controls, etc)
             *------------------------------*/

            if ($(simplefield).hasClass($.spedmonWebUI.field.DATA_FLAG))
            {
              $(simplefield).spedmonInput_setValue(dvalue);
            }

            /*-------------------------------
             * Everything else
             *------------------------------*/

            else
            {
              $(simplefield).val(dvalue);
            }

          }
         // Set the steps label with the default value
         //$label.text(dvalue);
       }

       // Set to blank AND fire the change event

       else
       {
         if ($(simplefield).hasClass($.spedmonWebUI.field.CTRL_TYPE_SELECT_BOX))   $(simplefield).spedmonSelectBox_clear();
         if ($(simplefield).hasClass($.spedmonWebUI.field.CTRL_TYPE_CALENDAR_BOX)) $(simplefield).spedmonCalendarbox_clear();
         $(simplefield).val('');
       }

     });

     /*-------------------------------
      * Look for and call the clear
      * method for all complex
      * input controls excluding those
      * controls that have a
      * no-clear class.
      *------------------------------*/

      var ptrn       = 'input.' + $.spedmonWebUI.field.COMPLEX;
      var cplxfields = $content.find(ptrn).not('.' + $.spedmonWebUI.field.NO_CLEAR);

      $.each(cplxfields, function(i, cplxfield){
        var obj = $(cplxfield).data('spedmondatagrid');
        if (obj) obj.clear();
      });

	  /*-------------------------------
       * Look for and call the clear
       * method for all complex
       * textarea controls excluding those
       * controls that have a
       * no-clear class.
       *------------------------------*/

	  ptrn       = 'textarea.' + $.spedmonWebUI.field.COMPLEX;
      cplxfields = $content.find(ptrn).not('.' + $.spedmonWebUI.field.NO_CLEAR);

      $.each(cplxfields, function(i, cplxfield){
        var obj = $(cplxfield).data('spedmonrichtextareabox');
        if (obj) obj.clear();
      });

     /*-------------------------------
      * Activate start section if
	  * there is one
      *------------------------------*/

	  $($me).spedmonStep_switchSection($startsection);

	});
  };

})(jQuery); 