
(function($) {
  
  /*###########################################################################
    #
    # Service Note Guided Answer Part 
    # Answer Selected List Item and List
    #
    ###########################################################################*/

  /***************************************************************************
   * mba.servicenoteguidedanswerpartanswerselected */
  /**
   * Selected answer list item shown in selected answer list
   ***************************************************************************/

  $.widget("mba.servicenoteguidedanswerpartanswerselected", {
    options: {defaultElement:"<li>",
              selectedSource:"all",
              selectedFor:"",
              selectedFrom:"",
              selectedName:"",
              selectedValue:"",
              selectedMarked:false,
			  selectedHasMarked:true,
              selectedMarkLabel:"Add to My Favorites",
              initSelector: "li [data-role='servicenoteguidedanswerpartanswerselected']"
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

      $me.attr('data-selected-source',     this.options.selectedSource);
      $me.attr('data-selected-for',        this.options.selectedFor);
      $me.attr('data-selected-from',       this.options.selectedFrom);
      $me.attr('data-selected-name',       this.options.selectedName);
      $me.attr('data-selected-value',      this.options.selectedValue);
      $me.attr('data-selected-has-marked', this.options.selectedHasMarked);
	  $me.attr('data-selected-marked',     this.options.selectedMarked);
      
      /*============================================================
       * Create containing grids
       *============================================================*/
     
      /*--------------------------------------
       * Main
       *-------------------------------------*/

      var $selGrid       = $('<div class="ui-grid-a ui-bar ui-bar-a"></div>');
      var $selBlock1     = $('<div class="ui-block-a"></div>');
      var $selBlock2     = $('<div class="ui-block-b"></div>');
 
      /*--------------------------------------
       * Selected item controls
       *-------------------------------------*/

      var $ctrlGrid      = $('<div class="ui-grid-a"></div>');
      var $ctrlBlock1    = $('<div class="ui-block-a"></div>');
      var $ctrlBlock2    = $('<div class="ui-block-b"></div>');
     
      /*============================================================
       * Create label
       *============================================================*/

      var $label = $('<h4 style="padding-top:.5em;padding-left:.5em;">' + this.options.selectedName + '</h4>');

      /*============================================================
       * Create bookmark control
       *============================================================*/
 
      var $ctrlMark    = $('<label>' + this.options.selectedMarkLabel + '</label>');
      var $ctrlMarkCbx = $('<input data-mini="true" type="checkbox"/>');

      /*--------------------------------------
       * Setup handler to toggle 
       * selected-mark when the bookmark
       * control is toggled and fire 
       * markItem event
       *-------------------------------------*/

      $($ctrlMark).on('vclick',function() {
        
        /* Toggle checkbox. Note: Logic is reversed */
             
        if ($($ctrlMarkCbx).is(':checked')) 
        {
          $me.attr('data-selected-marked','false'); 
          $this.options.selectedMarked = false;
        }
        else
        {
          $me.attr('data-selected-marked','true'); 
          $this.options.selectedMarked = true;
        }

        /* Create and fire markItem event */

        var e = $.Event( "markItem" );
        
        var s     = $me.attr('data-selected-source');
        var n     = $me.attr('data-selected-name');
        var v     = $me.attr('data-selected-value');
        var sfor  = $me.attr('data-selected-for');
        var sfrom = $me.attr('data-selected-from');
        var m     = $me.attr('data-selected-marked');

        e.selectedSource = s;
        e.selectedName   = n;
        e.selectedValue  = v;
        e.selectedFor    = sfor;
        e.selectedFrom   = sfrom;
        e.selectedMarked = m;

        $($me).trigger(e);

      });

      $($ctrlMark).append($ctrlMarkCbx);
      
      /*============================================================
       * Create remove control
       *============================================================*/

      var $ctrlRemove = $('<input data-mini="true" data-icon="minus" type="button" value="Unselect"/>'); 
     
      /*--------------------------------------
       * Setup handler to create and fire 
       * removeItem event when the remove
       * control is clicked
       *-------------------------------------*/

      $($ctrlRemove).on('vclick',function() {

        /* Create and fire removeItem event */

        var e     = $.Event( "removeItem" );
        var s     = $me.attr('data-selected-source');
        var n     = $me.attr('data-selected-name');
        var v     = $me.attr('data-selected-value');
        var sfor  = $me.attr('data-selected-for');
        var sfrom = $me.attr('data-selected-from');
        var m     = $me.attr('data-selected-marked');
        
        e.selectedSource = s;
        e.selectedName   = n;
        e.selectedValue  = v;
        e.selectedFor    = sfor;
        e.selectedFrom   = sfrom;
        e.selectedMarked = m;
        $($me).trigger(e);

      });

      /*============================================================
       * Populate grids
       *============================================================*/

      /*--------------------------------------
       * Controls
       *-------------------------------------*/

      if (this.options.selectedHasMarked === true)
	    $($ctrlBlock1).append($ctrlMark);
      
	  $($ctrlBlock2).append($ctrlRemove);

      $($ctrlGrid).append($ctrlBlock1);
      $($ctrlGrid).append($ctrlBlock2);
      $($selBlock2).append($ctrlGrid);

      /*--------------------------------------
       * Label
       *-------------------------------------*/
      
      $($selBlock1).append($label);
     
      /*--------------------------------------
       * Main
       *-------------------------------------*/
    
      $($selGrid).append($selBlock1);
      $($selGrid).append($selBlock2);
      
      /*============================================================
       * Construct
       *============================================================*/

      $($me).append($selGrid);
      $($me).attr('style','margin:0;padding:0');
      $($me).enhanceWithin();
                 
    }
  });

  /***************************************************************************
   * mba.servicenoteguidedanswerpartanswersselected */
  /**
   * Selected items list
   ***************************************************************************/

  $.widget("mba.servicenoteguidedanswerpartanswersselected", $.mobile.listview, {
    options: {
      defaultElement:"<ul>",
      inset:true,
	  selectedHasMarked:true,
      answersSelectedInputId:null,
      initSelector: "ul [data-role='servicenoteguidedselecteditems']"
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
       * Handle markItem events
       *============================================================*/
  
      $($me).on('markItem',function (e) {
        $this.updateListInput();
        return false;
      });

      
      /*============================================================
       * Call the base create method to complete control
       *============================================================*/
        
      this._super();
	  
	  var input = $('#' + this.options.answersSelectedInputId);

	  if (input)
	  {	    
		var json = $(input).val();
		this.setItemsStr(json);
	  }
    
    },

    /***************************************************************************
     * getItemsArr() */
    /**
     * Returns array of item objects
     ***************************************************************************/      
    
    getItemsArr : function () {

      var arr = $(this.element.children('li')).map(function(idx,li) {

      var $idx   = idx;
      var $ssrc  = $(li).attr('data-selected-source');
      var $sfor  = $(li).attr('data-selected-for');
      var $sfrom = $(li).attr('data-selected-from');
      var $snam  = $(li).attr('data-selected-name');
      var $sval  = $(li).attr('data-selected-value');          
      var $smkd  = $(li).attr('data-selected-marked');
   	  
      return {
        "selectionIdx": $idx,
        "selectionSource": $ssrc,
        "selectionFor": $sfor,	
        "selectionFrom": $sfrom,			
        "selectionName": $snam, 
        "selectionValue": $sval,
        "selectionMarked": $smkd
        };
      }).get();
	  
      return arr;
    }, 
		
    /***************************************************************************
     * getItemsStr() */
    /**
     * Returns array of item objects serialized into JSON string
     ***************************************************************************/     
	
    getItemsStr : function() {
      var arr = this.getItemsArr();
      var str = JSON.stringify(arr);
      return str;
    },		
	
	/***************************************************************************
     * updateListInput */
    /**
     * Update input control
     ***************************************************************************/  

    updateListInput: function () {
      
      var $input = $('#' + this.options.answersSelectedInputId);
      var json   = this.getItemsStr();
      $($input).val(json);
    },

    /***************************************************************************
     * findItem */
    /**
     * Find Item
     ***************************************************************************/  

    findItem: function ( name )
    {      
      var items = $(this.element).children('[data-selected-name="' + name + '"]');
      return items;	
    },

    /***************************************************************************
     * findItemByNameSource */
    /**
     * Find Item
     ***************************************************************************/  

    findItemByNameSource: function ( name, source )
    {
      var items = $(this.element).children('[data-selected-name="' + name + '"][data-selected-source="' + source +'"]');
      return items;	
    },

    /***************************************************************************
     * removeItem */
    /**
     * Remove Item
     ***************************************************************************/  

    removeItem: function(name, source)
    {
      var items = this.findItemByNameSource(name, source);

      if ((items).length > 0)
      {
        $(items).remove();
        this.refresh();
        this.updateListInput();
      }
    },

    /***************************************************************************
     * addListItem */
    /**
     * Add list item
     ***************************************************************************/  

    addItem: function( $name, $value, $source, $sfrom, $sfor, $markLabel )
    {
      var items = this.findItem($name);
      var $hasMarked = this.options.selectedHasMarked;
	  
      if ((items).length == 0) 
      {
        var $ul = $(this.element);
        var $li = $('<li></li>');
        $($li).servicenoteguidedanswerpartanswerselected({selectedName:$name, selectedValue:$value, selectedSource:$source, selectedFrom:$sfrom, selectedFor:$sfor, selectedHasMarked:$hasMarked,selectedMarkLabel:$markLabel}); 
        $($ul).append($li);
        var e = $.Event( "addItem" );
        this.refresh();
        this.updateListInput();
        return true;
      }

      return false;
    }
	,
	
	/***************************************************************************
     * setItemsStr(json) */
    /**
     * Takes json string, parses it, and loads items.
     ***************************************************************************/     
	
	setItemsStr: function(json) {
	  
	  var $this = this;
	  
	  if (json != '[]')
	  {		        
   	    var oItems = JSON.parse(json);
		
		$.each(oItems,function(i,oItem){
		  //if (oItem.selectionFor)
		  //{
		    var markLabel = "";
			if (oItem.selectionMarked == true) markLabel = "Remove From My Favorites"; else markLabel = "Add to My Favorites";
		    $this.addItem( oItem.selectionName, oItem.selectionValue, oItem.selectionSource, oItem.selectionFrom, oItem.selectionFor, markLabel );
		  //}
		});
	  }
	},
                  
  });


  /*###########################################################################
    #
    # Service Note Guided Answer Part 
    # Answer Selections 
    #
    ###########################################################################*/

  /***************************************************************************
   * mba.servicenoteguidedanswerpartanswerselections */
  /**
   * Answers to select
   ***************************************************************************/

  $.widget("mba.servicenoteguidedanswerpartanswerselections",  {
    options: {defaultElement:"<div>",
              selectionsSource:"all",
              selectionsFor:"",
              selectionsFrom:"",
              selectionsLabel:"Select Options",
              selectionsMultiple:false,
              selectionCtrlId:null,
              selectionsData:null,
			  questionLabel:"",
			  headerLabel:"",
              initSelector: "div [data-role='servicenoteguidedanswerpartanswerselections']"
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
       * Create unique ids
       *============================================================*/

      var selectionsSelectId = meid + '-' + 'selections';
      this.options.selectionCtrlId = selectionsSelectId;

      /*============================================================
       * Synch attributes
       *============================================================*/

      $me.attr('data-selections-source',           this.options.selectionsSource);
      $me.attr('data-selections-for',              this.options.selectionsFor);
      $me.attr('data-selections-from',             this.options.selectionsFrom);
      $me.attr('data-selections-label',            this.options.selectionsLabel);
      $me.attr('data-selections-multiple',         this.options.selectionsMultiple);
      $me.attr('data-selections-ctrl-id' ,         this.options.selectionCtrlId);      
      $me.attr('data-question-label',              this.options.questionLabel);
	  $me.attr('data-header-label',                this.options.headerLabel);
	  
      /*============================================================
       * Get multiselect preference and save for later
       *============================================================*/

      var multiSelect = this.options.selectionsMultiple;

      /*============================================================
       * Create selection label
       *============================================================*/
	   
      var lblTxt = this.options.selectionsLabel;
	  
	  var qLblTxt = this.options.questionLabel;
	  var hLblTxt = this.options.headerLabel;
	  
      var $lbl = $('<label for="' + selectionsSelectId + '" class="mba-servicenoteguidedanswerpartanswerselections-label">' + lblTxt + '</label>');
      	  
      /*============================================================
       * Create selection instruction
       *============================================================*/

	  var insLblTxt = "";

	  if (multiSelect === true)		  
        insLblTxt = "Select One or More Answers";
      else		  
	    insLblTxt = "Select One Answer";

      /*============================================================
       * Create selection box
       *============================================================*/

      // multiple="multiple"
	  var $selections = $('<select id="' + selectionsSelectId + '" data-native-menu="false" data-mini="true" multiple="multiple"></select>');
      
      //if (multiSelect === true) $($selections).attr('multiple','multiple');
      this.options.selectionCtrlId = selectionsSelectId;
      
      /*============================================================
       * Append answers (options) to selections
       *============================================================*/

      var answerCtr = 0;

      if ($this.options.selectionsData)
      {
        /*--------------------------------------
         * Only add answers that apply
         *-------------------------------------*/

        answerCtr = 0;

        $.each($this.options.selectionsData, function(index, answer) {
         if (answer.selectionSource == $this.options.selectionsSource)
         {
           $this._appendSelection ($selections, answer.selectionName,answer.selectionValue,answer.selectionSelected);
           answerCtr++;		   
         }
       });
	   
        /*--------------------------------------
         * Only add place-holder answer if we have
         * answers
         *-------------------------------------*/
		 
        if (answerCtr > 0)
        {		  		  
          $($selections).prepend ('<option data-placeholder="true" value="">' + insLblTxt + '</option>');          		  
        }       
      }
  
      /*============================================================
       * If there are no answers
       *============================================================*/

      if (answerCtr == 0)
      {
      }
 
      /*============================================================
       * Trigger list updates on change
       *============================================================*/
  
      $($selections).on('change',function () {
		var e = $.Event( "updateItems" );
        var s = $me.attr('data-selections-source');
        var l = $me.attr('data-selections-label');
        e.selectedSource = s;
        e.selectedLabel  = l;		
        $($me).trigger(e);
      });
      
      /*============================================================
       * Create filter 
       * Note: This is done after the select control is created
       *============================================================*/

      /*--------------------------------------
       * Generate expected ids
       *-------------------------------------*/
	  
	  var selectListViewId  = selectionsSelectId + '-menu';
      var selectListDiaId   = selectionsSelectId + '-dialog';
    
      /*--------------------------------------
       * The custom select menu plugin generates
	   * an ID for the listview by suffixing the
	   * ID of the native widget with "-menu"
	   * We can use this expected id to place
	   * an input field before the list
	   * to be used as a filter
       *-------------------------------------*/

      $.mobile.document.on( "listviewcreate", '#'+selectListViewId, function( event ) {
        		
		var input;
        var list = $( event.target );
        var form = list.jqmData( "filter-form" );
		 
        // We store the generated form in a variable attached to the popup so we avoid creating a
        // second form/input field when the listview is destroyed/rebuilt during a refresh.
        
		if ( !form ) {
			                    										
            var instrs = $('<div class="ui-body ui-selectmenu-search-instructions"></div>');
			var closelnk1 = $('<a class="ui-btn ui-btn-icon-left ui-icon-check ui-mini ui-corner-all" href="#" data-transition="pop" data-direction="reverse">Click here when you are done</a>');
            $(closelnk1).on('vclick',function(){$this.closeMenu()});						
			$(instrs).append(closelnk1);
			$(instrs).append('<h5>' + qLblTxt   + '</h5>');			
            $(instrs).append('<h4>' + hLblTxt   + '</h4>');		
            $(instrs).append('<h6>' + insLblTxt + '</h6>');					
			$(instrs).append('<h6>To filter the list of answers enter all or part of an answer below</h6>');
			
			input = $( '<input class="ui-selectmenu-search-input" data-type="search" placeholder="Enter text to filter answers by"></input>' );
            form  = $( '<form class="ui-selectmenu-search-form"></form>' ).append(instrs).append( input );

            input.textinput();
        
   		    list.before( form ).jqmData( "filter-form", form ) ;
								
            form.jqmData( "listview", list );
            
			// If this is a single select 
			
			if (multiSelect === false)
		    {			
			  $(list).on('click','li a',function () {		    			  			
				var lnk = $(this);
			    var nm  = $(lnk).text();			    
				$this.closeMenu();
				$this.unselectAllExcept(nm);
				//$this.unselectAll();			
			    //$this.toggleSelection(nm,true,true);				
			});		  
		}
		
		}

        // Instantiate a filterable widget on the newly created listview and indicate that the
        // generated input form element is to be used for the filtering.

        list.filterable({
            input: input,
            children: "> li:not(:jqmData(placeholder='true'))"
        });
		
	
      })

      // The custom select list may show up as either a popup or a dialog, depending on how much
      // vertical room there is on the screen. If it shows up as a dialog, then the form containing
      // the filter input field must be transferred to the dialog so that the user can continue to
      // use it for filtering list items.

      .on( "pagecontainerbeforeshow", function( event, data ) {
	  
        var listview, form,
            id = data.toPage && data.toPage.attr( "id" );
        
		/* If this is not a dialog get out*/
		
		if ( !( id === selectListDiaId) ) {
		  return;
        }

        listview = data.toPage.find( "ul" );
						
        form = listview.jqmData( "filter-form" );
        		
        // Attach a reference to the listview as a data item to the dialog, because during the
        // pagecontainerhide handler below the selectmenu widget will already have returned the
        // listview to the popup, so we won't be able to find it inside the dialog with a selector.

        data.toPage.jqmData( "listview", listview );

        // Place the form before the listview in the dialog.

        listview.before( form );
      })

      // After the dialog is closed, the form containing the filter input is returned to the popup.

      .on( "pagecontainerhide", function( event, data ) {

        var listview, form,
            id = data.toPage && data.toPage.attr( "id" );
			
        if ( !( id === selectListDiaId) ) { 
            return;
        }
        
		listview = data.toPage.jqmData( "listview" ),
        
		form = listview.jqmData( "filter-form" );
					
        // Put the form back in the popup. It goes ahead of the listview.
        listview.before( form );
				
      });      
            
      /*============================================================
       * Append everything
       *============================================================*/

      $($me).append($lbl);
      $($me).append($selections);

      //$($me).enhanceWithin();

     
    },

    /***************************************************************************
     * findSelected */
    /**
     * Find selected options
     ***************************************************************************/  

    findSelected: function ()
    {      
      var selections = $('#'+this.options.selectionCtrlId).find('option:selected');
      return selections;	
    },

    /***************************************************************************
     * findUnSelected */
    /**
     * Find Unselected options
     ***************************************************************************/  

    findUnSelected: function ()
    {      
      var selections = $('#'+this.options.selectionCtrlId).find('option:not(:selected)');
      return selections;	
    },

    /***************************************************************************
     * findSelection */
    /**
     * Find Selection by name
     ***************************************************************************/  

    findSelection: function ( name )
    {      
      var selections = $('#'+this.options.selectionCtrlId).children('[data-selection-name="' + name + '"]');
      return selections;	
    },
    
    /***************************************************************************
     * toggleSelection */
    /**
     * Toggle select/unselect
     ***************************************************************************/  

    toggleSelection: function ( name, selected, rfrsh )
    {
      var $opt = this.findSelection(name);
	  
	  if (!$opt) return;
	  
      if (selected === true)  
	  {
	    $($opt).attr('selected','selected');
		$($opt).attr('data-selection-selected','true');		
      }
	  
	  if (selected === false) 
	  {
		$($opt).removeAttr('selected');
		$($opt).attr('data-selection-selected','false');		
      }
	  
	  if (rfrsh === true)
	    this.refreshMenu();
	  	  
    },

    
    /***************************************************************************
     * unselectAll */
    /**
     * Unselect all
     ***************************************************************************/  
	 
	unselectAll:function()
	{
      var $selections = $('#'+this.options.selectionCtrlId);  	  
	  $($selections).children('option').removeAttr('selected').attr('data-selection-selected','false');		
	},
	
	unselectAllExcept:function(name)
	{
	  var $selections = $('#'+this.options.selectionCtrlId); 
	  $($selections).find('option:not([data-selection-name="' + name + '"])').removeAttr('selected').attr('data-selection-selected','false');	
	  this.refreshMenu();
	},
	
	changeMenu:function()
	{
	  var $selections = $('#'+this.options.selectionCtrlId);        
	  $($selections).change();
	},
	
	refreshMenu:function()
	{
      var $selections = $('#'+this.options.selectionCtrlId);        
	  $($selections).selectmenu("refresh",true);     	 
	}
	,
	
	closeMenu:function()
	{
	  var $selections = $('#'+this.options.selectionCtrlId);
	  $($selections).selectmenu("close");
	},
	
    /***************************************************************************
     * _appendSelection */
    /**
     * Appends a selection. 
     ***************************************************************************/  

    _appendSelection: function ( $selections, name, value, selected )
    {  
      var sl = false;
	  if (selected == 'true') sl = true;
	  if (selected === true)  sl = true;
	  
	  var $opt = $('<option data-selection-source="' + this.options.selectionsSource + '" data-selection-for="' + this.options.selectionsFor +'" data-selection-from="' + this.options.selectionsFrom + '" data-selection-selected="' + sl + '" data-selection-name="' + name + '" data-selection-value="'+ value +'" value="' + value +'">' + name + '</option>');
	  if (sl == true) 
	  {
	    $($opt).attr('selected','selected');     	    
	  }
      $($selections).append($opt);                           
    },

    /***************************************************************************
     * addSelection */
    /**
     * Adds a new selection (usually in response to a user adding one)
     ***************************************************************************/  

    addSelection: function ( name, value, selected )
    {      
      var selections = this.findSelection(name);
      if ((selections).length == 0)
      {
        var $selections = $('#'+this.options.selectionCtrlId);
        this._appendSelection($selections, name, value, selected);      
        $($selections).selectmenu("refresh",true);
        $($selections).trigger("change");   
      }
    }

  });

 
  /*###########################################################################
    #
    # ServiceNoteGuidedAnswerPart
    #
    ###########################################################################*/

  /***************************************************************************
   * mba.servicenoteguidedanswerpart */
  /**
   * Guided answer part
   ***************************************************************************/   

  $.widget("mba.servicenoteguidedanswerpart", {
    options: {defaultElement:"<div>",
              label:null,
              ajax:true,
              answersMultiple:true,
              answersSelectionAll: true,         
              answersSelectionBookmarks: true,
              answersSelectionNew: true,
              answersSelectionFor:"", 
              answersSelectionFrom:"",
              answers:null,
              answersSelectedInputId:null,
			  partNum:1,
			  partTot:1,
			  questionLabel:"",
			  headerLabel:"",
              initSelector: "div [data-role='servicenoteguidedanswerpart']"
    },

    _create: function() {
      
     /*============================================================
      * Grab references to the widget, element, and the elements id
      *============================================================*/
      
      var $this = this;
      var $me   = this.element;     
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
      * If an answers data list is provided use it for the data  
      * otherwise an array of answer objects is expected to be
      * in this.options.answers
      *============================================================*/

     var $answersDataList = null;

     $answersDataList = $($me).find('ul.servicenoteguidedanswersdata');

     if ($answersDataList.length != 0)

     {
       var arr = $($answersDataList.children('li')).map(function(idx,li) {

         var $ssrc  = $(li).attr('data-selection-source');
         var $snam  = $(li).attr('data-selection-name');
         var $sval  = $(li).attr('data-selection-value');          
         var $ssel  = $(li).attr('data-selection-selected');

        return {
          "selectionSource": $ssrc,
          "selectionName": $snam, 
          "selectionValue": $sval,
          "selectionSelected": $ssel
        };
      }).get();
	  
      this.options.answers = arr;
      $($answersDataList).remove();
     }

     /*============================================================
      * Create unique ids
      *============================================================*/

      var answersSelectAllId         = meid + '-' + 'answer-select-from-all';
      var answersSelectBookmarksId   = meid + '-' + 'answer-select-from-bookmarks';
      var answersSelectNewId         = meid + '-' + 'answer-select-from-new';
      var answersNewPopupId          = meid + '-' + 'answer-add-new-select';
      var answersSelectedId          = meid + '-' + 'answer-selected';

     /*============================================================
      * Value counter for new items
      *============================================================*/

     var valCtr = 1;

     /*============================================================
      * Various parts of control
      *============================================================*/

      var $answersHeader     = null;
	  var $label             = null;
	  var $step              = null;
      var $answersGrid       = null;
      var $answersBlock1     = null;
      var $answersBlock2     = null;
      var $answersBlock3     = null;
      var $answersBlock4     = null;
	  var $answersAll        = null;
      var $answersBookmarks  = null;
      var $answersNew        = null;
      var $answersNewAddCont = null;
	  var $answersControls   = null;
      var $answersSelected   = null;

      /*============================================================
       * Function for finding answer in selection
       *============================================================*/
         
      var fnFindAnswerByNameInAnswerSelection = function ($answersSelection, $name)
      {

        if ($answersSelection) {
          var $answers = $($answersSelection).servicenoteguidedanswerpartanswerselections('findSelection',$name);
          if (($answers).length > 0) return true;
        }

        return false;

      };

      /*============================================================
       * Function for finding answer in selections
       *============================================================*/

      var fnFindAnswerByNameInAnswerSelections = function($name) {

        if (fnFindAnswerByNameInAnswerSelection($answersAll,       $name) === true) return true;
        if (fnFindAnswerByNameInAnswerSelection($answersBookmarks, $name) === true) return true;
        if (fnFindAnswerByNameInAnswerSelection($answersNew,       $name) === true) return true;

        return false;

      };

      /*============================================================
       * Function for updating answers list from given selection
       *============================================================*/

      var fnUpdateAnswerList = function ($answersSelection, $selectedList, $markLabel) {
         
        if ($answersSelection) {

          var $unselectedItems = $($answersSelection).servicenoteguidedanswerpartanswerselections('findUnSelected');
          var $selectedItems   = $($answersSelection).servicenoteguidedanswerpartanswerselections('findSelected');
          		 		  
          $($unselectedItems).each(function(idx,unselectedItem){

            var snam = $(unselectedItem).attr('data-selection-name');
            var ssrc = $(unselectedItem).attr('data-selection-source');

            $($selectedList).servicenoteguidedanswerpartanswersselected('removeItem', snam, ssrc);

          });

          $($selectedItems).each(function(idx,selectedItem){
            
            var snam = $(selectedItem).attr('data-selection-name');
            var sval = $(selectedItem).attr('data-selection-value');
            var ssrc = $(selectedItem).attr('data-selection-source');
            var sfrm = $(selectedItem).attr('data-selection-from');
            var sfor = $(selectedItem).attr('data-selection-for');
            
            var aflag = $($selectedList).servicenoteguidedanswerpartanswersselected('addItem', snam, sval, ssrc, sfrm, sfor, $markLabel);

          });

        }
      };

     /*============================================================
      * Function for updating the answers selected list
      *============================================================*/
     
     var fnUpdateAnswersList = function (selSrc) {
      
       if (selSrc == 'all') fnUpdateAnswerList($answersAll,       $answersSelected,'Add to My Favorites');
       if (selSrc == 'fav') fnUpdateAnswerList($answersBookmarks, $answersSelected,'Remove from My Favorites');
       if (selSrc == 'new') fnUpdateAnswerList($answersNew,       $answersSelected,'Add to My Favorites');

     };

     /*============================================================
      * Function for updating the answer selections 	  
      *============================================================*/

     var fnUpdateAnswersSelections = function (selSrc, selName, selected) {

       if (selSrc == 'all') $($answersAll).servicenoteguidedanswerpartanswerselections('toggleSelection',selName,selected,true);
       if (selSrc == 'fav') $($answersBookmarks).servicenoteguidedanswerpartanswerselections('toggleSelection',selName,selected,true);
       if (selSrc == 'new') $($answersNew).servicenoteguidedanswerpartanswerselections('toggleSelection',selName,selected,true);
       fnUpdateAnswersList(selSrc);
     };
         
     /*============================================================
      * Create label and step
      *============================================================*/

     if (this.options.label)
     {     
       $label = $('<div class="mba-servicenoteguidedanswerpart-header-label">' + this.options.label + '</div>');
     }

	 
	 if ((this.options.partNum) && (this.options.partTot))
	 {
	   if (this.options.partTot > 1)
       {	   
	     $step = $('<div class="mba-servicenoteguidedanswerpart-header-step">' + this.options.partNum + ' of ' + this.options.partTot + '</div>');
	   }
	 }
	 
     /*============================================================
      * Create answers grid and blocks
      *============================================================*/

	 $answersHeader   = $('<div class="mba-servicenoteguidedanswerpart-header"></div>');
     // $answersControls = $('<div class="mba-servicenoteguidedanswerpart-header-controls"></div>');
     $answersGrid     = $('<div class="ui-grid-b"></div>');
     $answersBlock1   = $('<div class="ui-block-a"></div>');
     $answersBlock2   = $('<div class="ui-block-b"></div>');
     $answersBlock3   = $('<div class="ui-block-c"></div>');
     	 
     /*============================================================
      * Common options for selection controls
      *============================================================*/
      
     var $multi    = this.options.answersMultiple;
     var $selData  = this.options.answers;
     var $selFor   = this.options.answersSelectionFor;
     var $selFrom  = this.options.answersSelectionFrom;
     
	 var $questionLabel = this.options.questionLabel;
	 var $headerLabel   = this.options.headerLabel;
	 
     /*============================================================
      * Create selection for all
      * Note: We pass this.options.answers and the selection
      * control picks what answers it needs from there
      *============================================================*/

     if (this.options.answersSelectionAll === true)
     {
       $answersAll = $('<div id="' + answersSelectAllId +'"></div>');
       $($answersAll).servicenoteguidedanswerpartanswerselections({selectionsSource:"all", selectionsFor:$selFor, selectionsFrom:$selFrom, selectionsLabel:"Commonly Used Answers",selectionsMultiple:$multi,selectionsData:$selData,questionLabel:$questionLabel,headerLabel:$headerLabel});
       $($answersBlock2).append('<div>&nbsp</div>'); // TODO: Add link to manage select all
	   $($answersBlock2).append($answersAll);       
     }

     /*============================================================
      * Create selection for bookmarks
      *============================================================*/
     
	 var $hasMarked = this.options.answersSelectionBookmarks;
     if (this.options.answersSelectionBookmarks === true)
     {
       $answersBookmarks = $('<div id="' + answersSelectBookmarksId +'"></div>');
       $($answersBookmarks).servicenoteguidedanswerpartanswerselections({selectionsSource:"fav", selectionsFor:$selFor, selectionsFrom:$selFrom, selectionsLabel:"My Favorites",selectionsMultiple:$multi,selectionsData:$selData,questionLabel:$questionLabel,headerLabel:$headerLabel});       
       $($answersBlock1).append('<div>&nbsp</div>'); // TODO: Add link to manage bookmarks 
	   $($answersBlock1).append($answersBookmarks);       
     }

     /*============================================================
      * Create selection and dialog for new
      *============================================================*/

     if (this.options.answersSelectionNew === true)
     {              

       $answersNew        = $('<div id="' + answersSelectNewId +'"></div>');
       $answersNewAddCont = $('<div style="display:block;text-align:center;"></div>');

       $($answersNew).servicenoteguidedanswerpartanswerselections({selectionsSource:"new", selectionsFor:$selFor, selectionsFrom:$selFrom, selectionsLabel:"New Answers I Just Added",selectionsMultiple:$multi,questionLabel:$questionLabel,headerLabel:$headerLabel});

       var $answersNewOpen        = $('<a href="#' + answersNewPopupId + '"  data-rel="popup">Click Here to Add A New Answer</a>');
       var $answersNewPopup       = $('<div id="' + answersNewPopupId + '" data-role="popup" ><div>');

       var $answersNewHeader      = $('<div class="ui-header ui-bar-inherit"></div>');
       var $answersNewLabel       = $('<h4 class="ui-title">Add a New Answer</h4>');
       var $answersNewClose       = $('<a href="#" data-rel="back" class="ui-btn ui-corner-all ui-btn-left ui-btn-icon-notext ui-icon-delete">Close</a>');
       
       $($answersNewHeader).append($answersNewLabel);
       $($answersNewHeader).append($answersNewClose);

       var $answersNewContent     = $('<div class="ui-content"></div>');
       var $answersNewText        = $('<input type="text" data-clear-btn="true" placeholder="Enter A New Answer"/>');
       var $answersNewStatus      = $('<div></div>');

       $($answersNewContent).append($answersNewStatus);
       $($answersNewContent).append($answersNewText);

       var $answersNewFooter      = $('<fieldset data-role="controlgroup" data-mini="true" data-type="vertical"></fieldset>');
       var $answersNewAddButton   = $('<a href="#" data-rel="back" data-role="button" data-icon="plus"  data-iconpos="left">Add</a>');        
       var $answersNewCanButton   = $('<a href="#" data-rel="back" data-role="button" data-icon="minus" data-iconpos="left">Cancel</a>');        
      
	   // TODO: Trap enter here
	   //$($answersNewText).on

 	   $($answersNewFooter).append($answersNewAddButton);
       $($answersNewFooter).append($answersNewCanButton);

       $($answersNewPopup).append($answersNewHeader);
       $($answersNewPopup).append($answersNewContent);   
       $($answersNewPopup).append($answersNewFooter);

       $($answersNewCanButton).on('vclick',function(){
         $($answersNewStatus).html('');
         $($answersNewText).val('');
       });

       $($answersNewAddButton).on('vclick',function(){
         var newname = $($answersNewText).val();
         if (newname)
         {
           if (fnFindAnswerByNameInAnswerSelections (newname) === true) 
           {                          
             $($answersNewStatus).html(newname + ' already exists');
             return false;
           }
           else
           {
             $($answersNew).servicenoteguidedanswerpartanswerselections('addSelection',newname,valCtr,true);            
             valCtr++;
           }
           $($answersNewStatus).html('');
           $($answersNewText).val('');
         }
         else
         {
           $($answersNewStatus).html('');
         }

       });

       $($answersNewAddCont).append($answersNewOpen);
       $($answersNewAddCont).append($answersNewPopup);

       $($answersBlock3).append($answersNewAddCont);
	   $($answersBlock3).append($answersNew);
	   
	  // $($answersControls).append($answersNewAddCont);
	          
     }

     $($answersGrid).append($answersBlock1);
     $($answersGrid).append($answersBlock2);
     $($answersGrid).append($answersBlock3);
     
     /*============================================================
      * Create selected list 
      *============================================================*/

     $answersSelected = $('<ul id="' + answersSelectedId + '"></ul>');
     var $inputID = this.options.answersSelectedInputId;
	 	  
     $($answersSelected).servicenoteguidedanswerpartanswersselected({answersSelectedInputId:$inputID,selectedHasMarked:$hasMarked});

     /*============================================================
      * Handle removeItem event triggered from selected list
      *============================================================*/

      $($me).on( "removeItem", function(e) 
      {
        var selSrc  = e.selectedSource;       
        var selName = e.selectedName;
        fnUpdateAnswersSelections(selSrc,selName,false);
      });

     /*============================================================
      * Handle selections change event triggered from selections
      * list
      *============================================================*/

      $($me).on( "updateItems", function(e) 
      {
		var selSrc = e.selectedSource;        
        fnUpdateAnswersList(selSrc);
      });

     //$($answersControls).prepend('Select an answer from a list below ');
	 
	 /*============================================================
      * Construct control 
      *============================================================*/
     
	 if ($step)  $answersHeader.append($step);
	 if ($label) $answersHeader.append($label);
	 //$answersHeader.append($answersControls);
	 
     $me.append($answersHeader);
	 $me.append($answersGrid);     
     $me.append($answersSelected);
		 
     /*============================================================
      * Done
      *============================================================*/
      
     $($me).enhanceWithin();
	 
               
    }
  });
       
})( jQuery );
