
(function($) {
  
  /*###########################################################################
    #
    # eaw.widgets.js
    #
    # Requires: eaw.common.js
    #
    ###########################################################################*/

/*#############################################################################################################################*/

  /***************************************************************************
   * eaw.searchbox */
  /**
   * Select entity
   * 
   * @param searchInputLabel         Label to use for search input field
   * @param searchInputPlaceholder   Placeholder text for search box
   * @param searchAuto               true = Search is an autocomplete
   *                                 false = User has to click a search button 
   * @param searchAutoMinLength      How many characters have to be entered before autocomplete begins
   * @param searchDataType           Datatype parameter for $.ajax()
   * @param searchDataURL            Url parameter for $.ajax()
   * @param selectMultiple           true  = Multiple selections allowed
   *                                 false = Only one selection allowed
   * @param selectDuplicates         true = Duplicate selections allowed
   *                                 false = No duplicate selections allowed
   * @param selectedLabel            Label to use for selected items list
   * @param selectedCount            Number of selected names
   * @param selectedNames            Delimited list of selected names
   * @param selectedValues           Delimited list of selected values
   * @param selectedDelimiterNames   Delimter to use for names
   * @param selectedDelimiterValues  Delimiter to use for values
   * @param duplicateWarning         true = Show warning to user if duplicate value is selected
   *                                 false = No warning to user if duplicate value is selected
   * @param unselectWarning          true = Provide confirmation to user prior to unselect
   *                                 false = Unselect silently
   * @param formInputID              Id of input field to keep loaded with selectedValues
   * @param formNameID               Name of input field to keep loaded with selectedValues
   ***************************************************************************/
		
  $.widget("eaw.searchbox", {
    options: {
              defaultElement:"<div>",
              entityName:"Name",
              headerText:"Select a Name",
			  searchInputLabel:"Select a Name",
              searchInputPlaceholder:"Enter all or part of name",                            
              searchAuto:true,
              searchAutoMinLength:1,
              searchUrl:"",
              searchDataType:"json",
			  searchMethod:"post", 
			  searchSelectFrom:"",
			  searchSelectWhat:"",
			  searchReqEntId1:"",
			  searchReqEntId2:"",
			  searchRequiredFieldIds:"",
			  searchParameterNames:"",
              searchParameterInputs:"",
              selectMultiple:false,
              selectMin:0,
              selectMax:50,
              selectDuplicates:false,
              selectedLabel:"Selected Names",
              selectedDelimiter:"|",
              selectedDelimiterNames:"|",
              selectedDelimiterValues:",",
              maxWarning:true,
              duplicateWarning:true,
              duplicateWarningTitle:"[0]<br/>Duplicate Selection",
              duplicateWarningText:"<strong>[0]</strong><br/>has already been selected",
              unselectWarning:true,
              unselectWarningTitle:"[0]<br/>Are You Sure?",
              unselectWarningText:"<strong>[0]</strong><br/>will be unselected if you click Yes",
              formInputId:"",
			  formInputSelCountId:"",
			  formInputSelNamesId:"",
			  formInputRequired:false,
			  formPartMessage:"",
			  formPartMessageClass:"",
              initSelector: "div [data-role='searchbox']"
    },
    
    
    /***************************************************************************
     * eaw.entityselect._create */
    /**
     * Creates the widget
     ***************************************************************************/
    
    _create: function() {
      
      /*============================================================
       * Grab references to widget, element, and the elements id
       *============================================================*/
      
      var $me   = this.element;
      var $this = this;     
      var meid  = $($me).attr('id');

      /*============================================================
       * If the element does not have an id, create one
       *============================================================*/

      if (typeof meid === "undefined")  
      {
        meid = this.widgetFullName + '-' + this.uuid;
        $($me).attr('id',meid);
      }
	 
	  
	 /*============================================================
       * Synch attributes 
       *============================================================*/
    
      $me.attr('data-header-text',               $this.options.headerText);
      $me.attr('data-entity-name',               $this.options.entityName);
	  $me.attr('data-search-input-label',        $this.options.searchInputLabel);
      $me.attr('data-search-input-placeholder',  $this.options.searchInputPlaceholder);
      $me.attr('data-search-auto',               $this.options.searchAuto);
      $me.attr('data-search-auto-min-length',    $this.options.searchAutoMinLength);
      $me.attr('data-search-url',                $this.options.searchUrl);
      $me.attr('data-search-select-from',        $this.options.searchSelectFrom);
	  $me.attr('data-search-select-what',        $this.options.searchSelectWhat);
      $me.attr('data-search-data-type',          $this.options.searchDataType);
      $me.attr('data-search-method',             $this.options.searchMethod);
      $me.attr('data-search-req-ent-id1',        $this.options.searchReqEntId1);
	  $me.attr('data-search-req-ent-id2',        $this.options.searchReqEntId2);	  
      $me.attr('data-select-multiple',           $this.options.selectMultiple);
      $me.attr('data-select-duplicates',         $this.options.selectDuplicates);
      $me.attr('data-select-min',                $this.options.selectMin);
      $me.attr('data-select-max',                $this.options.selectMax);
      $me.attr('data-selected-label',            $this.options.selectedLabel);
	  
      $me.attr('data-selected-delimiter-names',  $this.options.selectedDelimiterNames);
      $me.attr('data-selected-delimiter-values', $this.options.selectedDelimiterValues);
      $me.attr('data-max-warning',               $this.options.maxWarning);
      $me.attr('data-duplicate-warning',         $this.options.duplicateWarning);
      $me.attr('data-duplicate-warning-title',   $this.options.duplicateWarningTitle);
      $me.attr('data-duplicate-warning-text',    $this.options.duplicateWarningText);
      $me.attr('data-unselect-warning',          $this.options.unselectWarning);
      $me.attr('data-unselect-warning-title',    $this.options.unselectWarningTitle);
      $me.attr('data-unselect-warning-text',     $this.options.unselectWarningText);
	  
      $me.attr('data-form-input-id',             $this.options.formInputId);
	  $me.attr('data-form-input-sel-count-id',   $this.options.formInputSelCountId);
	  $me.attr('data-form-input-sel-names-id',   $this.options.formInputSelNamesId);
	  
	  $me.attr('data-form-input-required',       $this.options.formInputRequired);
	
      $me.attr('data-form-part-message',         $this.options.formPartMessage);	
	  $me.attr('data-form-part-message-class',   $this.options.formPartMessageClass);	
	  
	  /*============================================================
       * Get references
       *============================================================*/

      var $formInput           = $('#' + $this.options.formInputId);
	  var $formInputSelCount   = $('#' + $this.options.formInputSelCountId);	 
	  var $formInputSelNames   = $('#' + $this.options.formInputSelNamesId);
      var $parentForm          = $($me).closest("form");
	  
	  /*============================================================
       * Local vars to hold data
       *============================================================*/
	   
	  var $selectedCount;
      var $selectedNames;
      var $selectedValues;

	  $selectedCount  = $($formInputSelCount).val();
	  $selectedNames  = $($formInputSelNames).val();
	  $selectedValues = $($formInput).val()

	  /*============================================================
       * Add classes
       *============================================================*/

      $($me).addClass("eaw-entity-select");

      /*============================================================
       * Create ids for components
       *============================================================*/

      var searchLabelId       = meid + '-' + 'search-label';
      var searchFormId        = meid + '-' + 'search-form';
      var searchInputId       = meid + '-' + 'search-input';
      var searchButtonId      = meid + '-' + 'search-btn';
	  var selectAllButtonId   = meid + '-' + 'select-all-btn';
      var clearButtonId       = meid + '-' + 'clear-btn';
	  var searchResultsListId = meid + '-' + 'search-results-list';
      var selectedItemsListId = meid + '-' + 'selected-items-list';

      /*============================================================
       * Construct individual components
       *============================================================*/
      
      var $controlGrid        = $('<div class="ui-grid-solo ui-responsive"></div>');     
      var $controlGridColA    = $('<div class="ui-block-a"></div>');
      var $controlGridColB    = $('<div class="ui-block-a"></div>');
      var $searchForm         = $('<div id="' + searchFormId + '" class="ui-filterable"></div>');
	  
	  var $reqMessage         = '';
	  var $partMessage        = '';
	  
	  if ($this.options.formInputRequired == true)
	     $reqMessage = '<span title="This is a required field" class="required-field">*</span>';
		 
	  if ($this.options.formPartMessage != "")
	    $partMessage = '<div class="message ' + $this.options.formPartMessageClass + '">' + $this.options.formPartMessage + '</div>';
	  	  
      var $searchLabel        = $('<label class="eaw-entity-select" for="' + searchInputId +'">' + $reqMessage + $this.options.searchInputLabel + $partMessage + '</label>');	  
	  var $searchInput        = $('<input id="'  + searchInputId       + '" data-type="search" type="text" value="" autocomplete="off" placeholder="' + $this.options.searchInputPlaceholder + '"/>');	 	  
      var $searchButton       = $('<button id="' + searchButtonId      + '" type="button" class="ui-btn ui-btn-inline ui-btn-icon-left ui-mini ui-corner-all ui-icon-search">Search</button>');     
	  var $selectAllButton    = $('<button id="' + selectAllButtonId   + '" type="button" class="ui-btn ui-btn-inline ui-btn-icon-left ui-mini ui-corner-all ui-icon-arrow-d">Select All</button>'); 
	  var $clearButton        = $('<button id="' + clearButtonId       + '" type="button" class="ui-btn ui-btn-inline ui-btn-icon-left ui-mini ui-corner-all ui-icon-delete">Clear</button>'); 
	  
      var $searchResultsList  = $('<ul tabindex="-1" id="'     + searchResultsListId + '" data-role="listview" data-inset="true" data-filter="true" data-icon="plus" data-filter-reveal="true" data-input="#' + searchInputId + '"></ul>');
      var $selectedItemsList  = $('<ul tabindex="-1" id="'     + selectedItemsListId + '" data-role="listview" data-inset="true" data-filter="false" data-icon="minus"></ul>');
  	
      /*============================================================
       * Create function to synch data selected attributes
       *============================================================*/

      var fnUpdateDataInputs = function() {

        /*--------------------------------------
         * Update form inputs
         *-------------------------------------*/		
		 
		$($formInput).val($selectedValues);
		$($formInputSelCount).val($selectedCount);
		$($formInputSelNames).val($selectedNames);
		
		/*--------------------------------------
         * Show/hide selected
         *-------------------------------------*/
        
		if ($selectedCount > 0) {
          $($controlGridColB).show();
        }
        else {
          $($controlGridColB).hide();
        }
      };

      /*============================================================
       * Create function to refresh search results list
       *============================================================*/
     
      var fnRefreshSearchResultsList = function() {
        $( $searchResultsList ).listview( "refresh" );
        $( $searchResultsList ).trigger( "updatelayout");
      };

      /*============================================================
       * Create function to refresh selected items list
       *============================================================*/

      var fnRefreshSelectedItemsList = function() {
        $( $selectedItemsList ).listview( "refresh" );
        $( $selectedItemsList ).trigger( "updatelayout");
      };
           
      /*============================================================
       * Create function to update data inputs from selected items list
       *============================================================*/

      var fnUpdateDataInputsFromSelectedItemsList = function () {       

        var arrNames  = $($selectedItemsList.children('li').children('a')).map(function(idx,a) { var n = $(a).attr('data-selected-name');  return n; }).get();
        var arrValues = $($selectedItemsList.children('li').children('a')).map(function(idx,a) { var v = $(a).attr('data-selected-value'); return v; }).get();       

        $selectedCount  = $($selectedItemsList).children('li').length;
        $selectedNames  = arrNames.join($this.options.selectedDelimiterNames);
        $selectedValues = arrValues.join($this.options.selectedDelimiterValues);

        fnUpdateDataInputs();
      };

      /*============================================================
       * Create function to create a selected list item
       *============================================================*/

      var fnCreateSelectedListItem = function (name, value) {
	    var $li = $('<li tabindex="-1"><a tabindex="-1" title="Click to Unselect" class="ui-mini" href="#" data-selected-name="' + name + '" data-selected-value="' + value + '">' + name + '</a></li>');		  
		return $li;      
      };

      /*============================================================
       * Create function to update selected items list from data
       * selected attributes
       *============================================================*/

      var fnUpdateSelectedItemsListFromDataSelectedAttrs = function() {

        fnUpdateDataInputs();

        /* If we have selections that were passed in (similar to an input.value) */

        if ($selectedCount > 0) {
          
          var strNames  = $selectedNames;
          var strValues = $selectedValues;

          var arrNames  = strNames.split($this.options.selectedDelimiterNames);
          var arrValues = strValues.split($this.options.selectedDelimiterValues);

          /* Multiple selection is not allowed, only pull in first elements */

          if ($this.options.selectMultiple == false) {
            var n = arrNames[0];
            var v = arrValues[0];
            $($selectedItemsList).append(fnCreateSelectedListItem(n,v));
          }

          /* Pull in all elements */

          else {
            for (i = 0; i < $selectedCount; i++) {
              var n = arrNames[i];
              var v = arrValues[i];
              $($selectedItemsList).append(fnCreateSelectedListItem(n,v));
            }
          }
        }       
      };

      /*============================================================
       * Create function that generates a selection list item string
       *============================================================*/

      var fnCreateSelectionListItemStr = function (name, value, detail) {
        return '<li tabindex="-1"><a tabindex="-1" href="#" title="Click to Select" class="ui-mini" data-selected-name="' + name + '" data-selected-value="' + value + '"><h4>' + name + '</h4>' + '<h5>' + detail + '</h5></a></li>';
      };
   

      /*============================================================
       * Create function that clears both search results and
	   * selected items
       *============================================================*/

      var fnClear = function() {
	    $($searchInput).val('');
		$($searchResultsList).html('');
        $($selectedItemsList).html('');
        fnRefreshSearchResultsList();
        fnRefreshSelectedItemsList();
        fnUpdateDataInputsFromSelectedItemsList();
	  }

      /*============================================================
       * Create function that performs the search
       *============================================================*/

      var fnSearch = function() {
	  	   	 
        var html      = "";              
        var srchParms = {};          

		srchParms.selectfrom    = $this.options.searchSelectFrom;
        srchParms.selectwhat    = $this.options.searchSelectWhat;		
		srchParms.reqentval1    = '';
		srchParms.reqentval2    = '';
		srchParms.term          = $($searchInput).val();

		if ($this.options.searchReqEntId1 != '')
		{
		  var rp  = $('#' + $this.options.searchReqEntId1);
		  srchParms.reqentval1 = $(rp).val();
		}

		if ($this.options.searchReqEntId2 != '')
		{
		  var rp  = $('#' + $this.options.searchReqEntId2);
		  srchParms.reqentval2 = $(rp).val();
		}

		var strSrchParms = JSON.stringify(srchParms);
		
        $($searchResultsList).html('');

        fnRefreshSearchResultsList();
        
		var selCount = 0;
		
		var fnBeforeSend = function(){
		  selCount = 0;
		  //$($searchInput).textinput("disable");
		  $.mobile.loading('show');
		};
		
		var fnComplete   = function(){
		  //$($searchInput).textinput("enable");
		  $.mobile.loading('hide');
		  $('#' + searchInputId).focus();

		  /* If only one selection focus on it*/
		 
		  if (selCount == 1){
		    $($searchResultsList).find('li a').focus();
		  }
          		  
	    };
		
        var fnError      = function(){};
		
        var fnSuccess    = function(data) {

  		  html = '';
		  selCount = 0;
		  
		  if (data.d.Selections)
		  {
            
			$.each( data.d.Selections, function ( i, Selection ) {

  			  var selName   = Selection.name;
              var selValue  = Selection.value;
			  var selDetail = Selection.detail;

              html += fnCreateSelectionListItemStr(selName,selValue,selDetail);
			  selCount++;  
            });							
		  }
        
         $($searchResultsList).html(html);		 
         fnRefreshSearchResultsList(); 		 
		};
		
        var srchOptions = {};
		
		srchOptions.url         = $this.options.searchUrl;		
		srchOptions.data        = strSrchParms;
		srchOptions.contentType = "application/json;charset=UTF-8";
		srchOptions.dataType    = $this.options.searchDataType;
		srchOptions.method      = $this.options.searchMethod;
		srchOptions.beforeSend  = fnBeforeSend;
		srchOptions.success     = fnSuccess;
		srchOptions.error       = fnError;
        srchOptions.complete    = fnComplete;
		
        var jqxhr = $.ajax(srchOptions);
		
       
      };

      /*============================================================
       * Create function that searches selected items list
       *============================================================*/

      var fnSearchSelectedItemsList = function (name,value) {
        var items = $($selectedItemsList).find('[data-selected-name="'+name+'"]');
        return items;   
      };

      /*============================================================
       * Load data
       *============================================================*/

      fnUpdateSelectedItemsListFromDataSelectedAttrs();
     
      /*============================================================
       * Wire up event to handle the selection of a search result
       *============================================================*/

      $( $searchResultsList ).on("click","li a", function (selectedEvent) {
        
        /* Get name/value selected */

        var $anc       = this;        
        var n          = $($anc).attr('data-selected-name');
        var v          = $($anc).attr('data-selected-value');

        var okToAppend = true;

        /* If we are in single select mode, we dont care about duplicates or max  */

        if ($this.options.selectMultiple == false) {         
          okToAppend = true;
          $($selectedItemsList).html('');
          fnRefreshSelectedItemsList(); 
        }

        /* If we are in multiselect mode we need to check some things */

        else
        {        
   
          /* Look for max */

          if ($selectedCount == $this.options.selectMax) {
            okToAppend = false;
            if ($this.options.maxWarning == true) {
              messagePopup ("Limit Reached", '<h4 style="text-align:center">You can only select ' + $this.options.selectMax +'</h4>', function(){});
            }
          }

          /* Look for duplicate selections if we have to */

          if (($this.options.selectDuplicates == false) && (okToAppend == true))
          {
            var items = fnSearchSelectedItemsList(n,v);
            if ($(items).length > 0) {
              okToAppend = false;
              if ($this.options.duplicateWarning == true) {      
                messagePopup ("Duplicate Selection", '<h4 style="text-align:center">' + n +'</h4><h5 style="text-align:center">Has already been selected</h5>', function(){});
              }
            }
          }

        }
        
		/* Add item to selected list */
		
        if (okToAppend == true) {       
  		  $($selectedItemsList).append(fnCreateSelectedListItem(n,v));
        }
        
        $($searchInput).val('');
        $($searchResultsList).html('');
        
        fnRefreshSearchResultsList();
        fnRefreshSelectedItemsList();
        fnUpdateDataInputsFromSelectedItemsList();
        
		$($searchInput).focus();
		
		/* If no multiple selection */
		
		if (($this.options.selectMultiple == false) && (okToAppend == true)) {
		  //var $nextCtrl = $(":input:visible:tabbable:eq(" + ($(":input:tabbable:visible").index($($searchInput)) + 1) + ")");
		  var $nextCtrl = $(":tabbable:visible:eq(" + ($(":tabbable:visible").index($($searchInput)) + 1) + ")");
		  $($nextCtrl).focus();
		}				
      });


      /*============================================================
       * Wire up event to handle the removal of a selected item
       *============================================================*/

      $( $selectedItemsList ).on("click", "li a", function (unselectedEvent) {
        
        /* Get parent list item */

        var $li = $(this).parent('li');
        var n = $(this).attr('data-selected-name');
   
        /* Put remove code in a little local function */

        var fnRemove = function(){
           $($li).remove();
          fnRefreshSelectedItemsList();
          fnUpdateDataInputsFromSelectedItemsList();
        };

        if ($this.options.unselectWarning == true) {

          var cfrmTitle = $this.options.unselectWarningTitle;
          cfrmTitle = cfrmTitle.format($this.options.headerText);

          var cfrmMsg = $this.options.unselectWarningText;
          cfrmMsg = cfrmMsg.format(n);

          confirmPopup (cfrmTitle, cfrmMsg, fnRemove);
        }
        else {
          fnRemove();
        }
      });
	  	  
	  /*============================================================
       * Function to execute search
       *============================================================*/

	   var fnSearchIfInputHasValue = function() {

  	    var value = $($searchInput).val();
        
		if (value) {
	      if (value.length >= $this.options.searchAutoMinLength) {
		    fnSearch();
		  }
	    }		
	  };
	  
	  /*============================================================
       * Wire up event to handle searching and filtering of
       * possible selections
       *==========================================================*/
      
	  $( $searchResultsList ).on( "filterablebeforefilter", function ( beforeFilterEvent, data ) {

	    if ($this.options.searchAuto === true) {		
		  fnSearchIfInputHasValue();
	    }
		else {		  
		  return false;
		}
		
       });
	   
      /*============================================================
       * Wire up event to handle the clicking of the search button
       *============================================================*/

      $($searchButton).on("click",function(buttonEvent) {	 
        fnSearchIfInputHasValue();	  
	  });

      /*============================================================
       * Wire up event to handle the clicking of the select all
	   * button
       *============================================================*/
	  
	  $($selectAllButton).on("click",function(buttonEvent) {
	    $($searchInput).val(' ');
	    fnSearch();	   
	  });
	  
	  
      /*============================================================
       * Wire up event to handle the clicking of the clear
	   * button
       *============================================================*/
	  
	  $($clearButton).on("click",function(buttonEvent) {	    
	    fnClear();
	  });
	  
	  

      /*============================================================
       * Combine components
       *============================================================*/
     
      $($me).append($searchLabel);	  
	  
	  $($searchForm).append($searchInput);
      
	  $($searchForm).append($searchButton);      
      $($searchForm).append($selectAllButton);      
      $($searchForm).append($clearButton);
	  
      $($controlGridColA).append($searchForm);
      $($controlGridColA).append($searchResultsList);      
      $($controlGridColB).append($selectedItemsList);
      $($controlGrid).append($controlGridColA);
      $($controlGrid).append($controlGridColB);
      $($me).append($controlGrid);

      /*============================================================
       * Init visibility of components
       *============================================================*/

      if ($this.options.searchAuto === true) {
  	    $($searchButton).hide();
		$($selectAllButton).hide();
		$($clearButton).hide();
      }
	  
      /*============================================================
       * Hook up to form
       *============================================================*/
      
	  //$($parentForm).submit(function( event ) {} });

	  /*============================================================
       * Construct
       *============================================================*/
      
	  //var oldfilterCallback = $.mobile.filterable.prototype.options.filterCallback;
	  var newFilterCallback = function( index, searchValue ) { return false; };
	  
	  $.mobile.filterable.prototype.options.filterCallback = newFilterCallback;
      $($me).enhanceWithin();  
	  
	  //$.mobile.filterable.prototype.options.filterCallback = oldFilterCallback;
	  
      this._super();              
    }
  });

/*#############################################################################################################################*/

  /***************************************************************************
   * eaw.confirmlink */
  /**
   * Requires confirmation for the link to proceed to the destination
   * 
   * @param ajax            true  = Use JQM navigation
   *                        false = Do not use JQM navigation
   * @param confirmTitle    The title of the popup
   * @param confirmText     The text or markup of the popup text
   ***************************************************************************/

  $.widget("eaw.confirmlink", {
    options: {defaultElement:"<a>",
              ajax:true,
              confirmTitle:"Are You Sure",
              confirmText:"Are you sure you want to go to this page?",
              initSelector: "a [data-role='confirmlink']"
    },

    _create: function() {
      
      /*============================================================
       * Grab references to widget, element, and the elements id
       *============================================================*/
      
      var $me   = this.element;
      var $this = this;     
      var meid  = $($me).attr('id');

      /*============================================================
       * If the element does not have an id, create one
       *============================================================*/

      if (typeof meid === "undefined")  
      {
        meid = this.widgetFullName + '-' + this.uuid;
        $($me).attr('id',meid);
      }

      /*============================================================
       * Synch attributes
       *============================================================*/

      $me.attr('data-confirm-title',   this.options.confirmTitle);
      $me.attr('data-confirm-text',    this.options.confirmText);
      $me.attr('data-ajax',            this.options.ajax);

      /*============================================================
       * Get values of attributes/options 
       *============================================================*/

      var confirmTitle    = this.options.confirmTitle;
      var confirmText     = '<p>' + this.options.confirmText + '</p>';
      var useAjax         = this.options.ajax;
      var destURI         = $($me).attr("href");
      var confirmCallback = function(){if (useAjax === true){$.mobile.navigate(destURI);} else{window.location.assign(destURI);};};

      /*============================================================
       * Hijack link
       *============================================================*/

      $($me).on("click",function(event){
        event.preventDefault();
        confirmPopup (confirmTitle, confirmText, confirmCallback);
      });

      /*============================================================
       * Construct
       *============================================================*/

      $($me).enhanceWithin();
                 
    }
  });
})( jQuery );
