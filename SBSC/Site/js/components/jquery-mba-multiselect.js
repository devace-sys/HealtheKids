; (function ($) {

    $.fn.spedmonSelectBoxMultiSelect = function (options) {

        /*-------------------------------------------------------------------------
         * merge options
         *-------------------------------------------------------------------------*/

        var $opts;
        $opts = $.extend({}, $.fn.spedmonSelectBoxMultiSelect.defaults, options);

        /*-------------------------------------------------------------------------
         * tie into return (method) chain
         *-------------------------------------------------------------------------*/

        return this.each(function () {

            /*-----------------------------------------------------------------------
             * get a reference to the original element we are enhancing
             *-----------------------------------------------------------------------*/

            var $me    = $(this);
            var $input = null;

            /*-----------------------------------------------------------------------
             * add identifying class
             *-----------------------------------------------------------------------*/

            $me.addClass($.spedmonWebUI.field.CTRL_TYPE_SELECT_BOX);
            $me.addClass('ui-spedmon-multiselect-original');

            /*-----------------------------------------------------------------------
             * get key attribute values
             *-----------------------------------------------------------------------*/

            var meid    = $me.attr('id');
            var menm    = $me.attr('name');
            var metitle = $me.attr('title');

            /*-----------------------------------------------------------------------
             * key vars for holding name/value pairs for external ref
             *-----------------------------------------------------------------------*/

            var meNames         = [];
            var meValues        = [];
            var meContextLabels = [];

            /*-----------------------------------------------------------------------
             * key vars for multi select
             *-----------------------------------------------------------------------*/

            var multiSelListNamesValues = [];
            var $melbl;
            var dropdownOpen            = false;

            /*-----------------------------------------------------------------------
             * create a container for everything
             *-----------------------------------------------------------------------*/

            var mecontid    = meid + "_multiselect_cont";
            var contClasses = 'ui-spedmon-multiselect-container';

            if ($opts.displayInline == true)
                contClasses = contClasses + ' ui-spedmon-multiselect-container-inline';

            $($me).wrap('<div id="' + mecontid + '" class="' + contClasses + '"></div>');

            var $mecont = $("#" + mecontid);

            /*-----------------------------------------------------------------------
             * common functions
             *-----------------------------------------------------------------------*/

            var fnGetNames         = function () { return meNames; }
            var fnGetValues        = function () { return meValues; }
            var fnGetContextLabels = function () { return meContextLabels; }

            /*-----------------------------------------------------------------------
             * create input wrapper for tags and button
             *-----------------------------------------------------------------------*/

            var wrapperid     = meid + "_input_wrapper";
            var $inputWrapper = $('<div id="' + wrapperid + '" class="ui-spedmon-multiselect-input-wrapper"></div>');
            $inputWrapper.insertAfter($me);

            /*-----------------------------------------------------------------------
             * create expand button (four arrows icon) - on left side
             *-----------------------------------------------------------------------*/

            var expandIconSvg = '<svg class="ui-spedmon-multiselect-expand-icon" viewBox="0 0 16 16">' +
                '<path d="M1 6V1h5M15 6V1h-5M1 10v5h5M15 10v5h-5"/>' +
                '</svg>';

            var $expandButton = $("<button class='ui-spedmon-multiselect-expand-btn' id='" + meid + "_expand' type='button' title='" + $opts.expandButtonTitle + "'></button>")
                .attr("tabindex", -1)
                .html(expandIconSvg);

            $expandButton.appendTo($inputWrapper);

            /*-----------------------------------------------------------------------
             * create tags container
             *-----------------------------------------------------------------------*/

            var tagsid          = meid + "_tags";
            var $tagsContainer  = $('<div id="' + tagsid + '" class="ui-spedmon-multiselect-tags"></div>');
            $tagsContainer.appendTo($inputWrapper);

            /*-----------------------------------------------------------------------
             * create modal overlay and window
             *-----------------------------------------------------------------------*/

            var modalid       = meid + "_modal";
            var $modalOverlay = $('<div id="' + modalid + '_overlay" class="ui-spedmon-multiselect-modal-overlay">' +
                '<div id="' + modalid + '" class="ui-spedmon-multiselect-modal">' +
                '<div class="ui-spedmon-multiselect-modal-header">' +
                '<span class="ui-spedmon-multiselect-modal-title">' + $opts.expandModalTitle +
                '<span class="ui-spedmon-multiselect-modal-count"></span>' +
                '</span>' +
                '<button type="button" class="ui-spedmon-multiselect-modal-close" title="Close">&times;</button>' +
                '</div>' +
                '<div class="ui-spedmon-multiselect-modal-body">' +
                '<div class="ui-spedmon-multiselect-modal-tags"></div>' +
                '</div>' +
                '</div>' +
                '</div>');
            $('body').append($modalOverlay);

            var $modal              = $('#' + modalid);
            var $modalTagsContainer = $modal.find('.ui-spedmon-multiselect-modal-tags');
            var $modalCount         = $modal.find('.ui-spedmon-multiselect-modal-count');

            /*-----------------------------------------------------------------------
             * open modal window
             *-----------------------------------------------------------------------*/

            var fnOpenModal = function () {
                fnUpdateModalTags();
                $modalOverlay.addClass('ui-spedmon-multiselect-modal-visible');
            };

            /*-----------------------------------------------------------------------
             * close modal window
             *-----------------------------------------------------------------------*/

            var fnCloseModal = function () {
                $modalOverlay.removeClass('ui-spedmon-multiselect-modal-visible');
            };

            /*-----------------------------------------------------------------------
             * update modal tags display
             *-----------------------------------------------------------------------*/

            var fnUpdateModalTags = function () {

                $modalTagsContainer.empty();
                $modalCount.text('(' + multiSelListNamesValues.length + ')');

                $.each(multiSelListNamesValues, function (idx, item) {

                    if (!item.name || item.name === '' || item.name.trim() === '') {
                        return true;
                    }

                    var $modalTag = $('<span class="ui-spedmon-multiselect-modal-tag" data-value="' + item.value + '">' +
                        '<span class="ui-spedmon-multiselect-modal-tag-label">' +
                        '<span class="ui-spedmon-multiselect-modal-tag-marquee">' + item.name + '</span>' +
                        '</span>' +
                        '<span class="ui-spedmon-multiselect-modal-tag-remove" title="' + $opts.multiSelectTagRemoveTitle + '">&times;</span>' +
                        '</span>');

                    $modalTagsContainer.append($modalTag);
                });

                setTimeout(function () {
                    $modalTagsContainer.find('.ui-spedmon-multiselect-modal-tag').each(function () {
                        var $tag     = $(this);
                        var $label   = $tag.find('.ui-spedmon-multiselect-modal-tag-label');
                        var $marquee = $tag.find('.ui-spedmon-multiselect-modal-tag-marquee');
                        var labelEl  = $label[0];

                        if (labelEl && labelEl.scrollWidth > labelEl.clientWidth) {
                            $tag.addClass('ui-spedmon-multiselect-modal-tag-overflow');
                            var originalText = $marquee.text();
                            $marquee.html(originalText + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + originalText + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;');
                        }
                    });
                }, 50);

                $modalTagsContainer.find('.ui-spedmon-multiselect-modal-tag-remove').off('click').on('click', function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    var tagValue = $(this).closest('.ui-spedmon-multiselect-modal-tag').attr('data-value');
                    fnRemoveTag(tagValue);
                    fnUpdateModalTags();
                    fnRefreshDropdown();
                    fnUpdateExpandButtonVisibility();
                    $opts.multiSelectOnChange(meValues, meNames);

                    if (multiSelListNamesValues.length === 0) {
                        fnCloseModal();
                    }

                    return false;
                });
            };

            /*-----------------------------------------------------------------------
             * bind modal close handlers
             *-----------------------------------------------------------------------*/

            $modal.find('.ui-spedmon-multiselect-modal-close').on('click', function (e) {
                e.preventDefault();
                e.stopPropagation();
                fnCloseModal();
                return false;
            });

            $modalOverlay.on('click', function (e) {
                if ($(e.target).hasClass('ui-spedmon-multiselect-modal-overlay')) {
                    fnCloseModal();
                }
            });

            /*-----------------------------------------------------------------------
             * close modal on escape key
             *-----------------------------------------------------------------------*/

            $(document).on('keydown', function (e) {
                if (e.keyCode === 27 && $modalOverlay.hasClass('ui-spedmon-multiselect-modal-visible')) {
                    fnCloseModal();
                }
            });

            /*-----------------------------------------------------------------------
             * bind expand button click
             *-----------------------------------------------------------------------*/

            $expandButton.on('click', function (e) {
                e.preventDefault();
                e.stopPropagation();
                fnOpenModal();
                return false;
            });

            /*-----------------------------------------------------------------------
             * update tags display
             *-----------------------------------------------------------------------*/

            var fnUpdateTags = function () {

                $tagsContainer.empty();

                if ($opts.multiSelectShowTags == true) {
                    $.each(multiSelListNamesValues, function (idx, item) {

                        if (!item.name || item.name === '' || item.name.trim() === '') {
                            return true;
                        }

                        var $tag = $('<span class="ui-spedmon-multiselect-tag" data-value="' + item.value + '">' +
                            '<span class="ui-spedmon-multiselect-tag-label">' +
                            '<span class="ui-spedmon-multiselect-tag-marquee">' + item.name + '</span>' +
                            '</span>' +
                            '<span class="ui-spedmon-multiselect-tag-remove" title="' + $opts.multiSelectTagRemoveTitle + '">&times;</span>' +
                            '</span>');

                        $tagsContainer.append($tag);
                    });

                    setTimeout(function () {
                        $tagsContainer.find('.ui-spedmon-multiselect-tag').each(function () {
                            var $tag     = $(this);
                            var $label   = $tag.find('.ui-spedmon-multiselect-tag-label');
                            var $marquee = $tag.find('.ui-spedmon-multiselect-tag-marquee');
                            var labelEl  = $label[0];

                            if (labelEl && labelEl.scrollWidth > labelEl.clientWidth) {
                                $tag.addClass('ui-spedmon-multiselect-tag-overflow');
                                var originalText = $marquee.text();
                                $marquee.html(originalText + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + originalText + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;');
                            }
                        });
                    }, 10);

                    $tagsContainer.find('.ui-spedmon-multiselect-tag-remove').off('click').on('click', function (e) {
                        e.preventDefault();
                        e.stopPropagation();
                        var tagValue = $(this).closest('.ui-spedmon-multiselect-tag').attr('data-value');
                        fnRemoveTag(tagValue);
                        fnRefreshDropdown();
                        fnUpdateExpandButtonVisibility();
                        $opts.multiSelectOnChange(meValues, meNames);
                        return false;
                    });
                }

                if ($opts.multiSelectShowCount == true && multiSelListNamesValues.length > 0) {
                    var $count = $('<span class="ui-spedmon-multiselect-count">' + multiSelListNamesValues.length + ' selected</span>');
                    $tagsContainer.append($count);
                }

                if (multiSelListNamesValues.length == 0 && $opts.multiSelectEmptyText != '') {
                    var $empty = $('<span class="ui-spedmon-multiselect-empty">' + $opts.multiSelectEmptyText + '</span>');
                    $tagsContainer.append($empty);
                }

                fnUpdateExpandButtonVisibility();
            };

            /*-----------------------------------------------------------------------
             * update expand button visibility and wrapper border highlight
             *-----------------------------------------------------------------------*/

            var fnUpdateExpandButtonVisibility = function () {
                if (multiSelListNamesValues.length >= $opts.expandButtonThreshold) {
                    $expandButton.addClass('ui-spedmon-multiselect-expand-visible');
                    $inputWrapper.addClass('ui-spedmon-multiselect-expand-active');
                } else {
                    $expandButton.removeClass('ui-spedmon-multiselect-expand-visible');
                    $inputWrapper.removeClass('ui-spedmon-multiselect-expand-active');
                }
            };

            /*-----------------------------------------------------------------------
             * remove tag function
             *-----------------------------------------------------------------------*/

            var fnRemoveTag = function (value) {
                var removedItem = null;
                for (var i = 0; i < multiSelListNamesValues.length; i++) {
                    if (String(multiSelListNamesValues[i].value) === String(value)) {
                        removedItem = multiSelListNamesValues[i];
                        multiSelListNamesValues.splice(i, 1);
                        break;
                    }
                }
                fnUpdateMultipleSelections();
                if (removedItem) {
                    $opts.multiSelectOnRemove(removedItem);
                }
            };

            /*-----------------------------------------------------------------------
             * update multiple selections - rebuild arrays
             *-----------------------------------------------------------------------*/
            var fnUpdateMultipleSelections = function () {

                meNames         = [];
                meValues        = [];
                meContextLabels = [];

                $.each(multiSelListNamesValues, function (key, val) {
                    var nameToUse = val.name;
                    if (/^\d+$/.test(val.name)) {
                       
                        nameToUse = val.name; 
                    }

                    meNames.push(nameToUse);
                    meValues.push(val.value);
                    meContextLabels.push(val.contextlabel);
                });

                $me.val(meValues.join(",")).change();
                $melbl = meNames.join("|");


                var namesFieldId = meid + 'names';

                var $namesField = $('#' + namesFieldId);
               
                if ($namesField.length > 0) {
                    $namesField.val($melbl);
                }

                fnUpdateTags();
            };

            /*-----------------------------------------------------------------------
             * fire data selected event
             *-----------------------------------------------------------------------*/

            var fnFireDataSelected = function () {
                fnUpdateMultipleSelections();
                jQuery.spedmonWebUI.fireDataSelected($me, { id: $me.attr('id'), label: $melbl, value: $me.val() });
            };

            /*-----------------------------------------------------------------------
             * clear data function
             *-----------------------------------------------------------------------*/

            var fnClearData = function () {
                $me.val('');
                meNames         = [];
                meValues        = [];
                meContextLabels = [];
                $($input).val('');
                multiSelListNamesValues.splice(0, multiSelListNamesValues.length);
                fnUpdateMultipleSelections();
            };

            /*-----------------------------------------------------------------------
             * load single item
             *-----------------------------------------------------------------------*/

            var fnLoadItem = function (name, value, contextlabel) {

                if (!value && value !== 0) {
                    return null;
                }

                var actualName = name;
                if (!name || name.trim() === '' || /^\d+$/.test(name.trim())) {
                    actualName = '[ID: ' + value + ']';
                }

                var newItem = {
                    name:         actualName,
                    value:        value,
                    contextlabel: contextlabel || ''
                };

                var alreadySelected = false;
                for (var i = 0; i < multiSelListNamesValues.length; i++) {
                    if (String(multiSelListNamesValues[i].value) === String(newItem.value)) {
                        alreadySelected = true;
                        break;
                    }
                }

                if ($opts.multiSelectMaxSelections > 0 && multiSelListNamesValues.length >= $opts.multiSelectMaxSelections) {
                    return null;
                }

                if (!alreadySelected) {
                    multiSelListNamesValues.push(newItem);
                    fnUpdateMultipleSelections();
                    return newItem;
                }

                return null;
            };

            /*-----------------------------------------------------------------------
             * load multiple items from delimited strings
             *-----------------------------------------------------------------------*/

            var fnLoadItems = function (names, values, contextlabels) {
              
                if (!values || values === '') {
                    return;
                }
                var newVals = values.split(',');

                var newNames       = [];
                var namesAreValid  = false;

                if (names && names !== '') {
                    newNames = names.split('|');

                    var hasRealName = false;
                    for (var i = 0; i < newNames.length; i++) {
                        var trimmedName = newNames[i].trim();
                        if (trimmedName !== '' && !/^\d+$/.test(trimmedName)) {
                            hasRealName = true;
                            break;
                        }
                    }
                    namesAreValid = hasRealName;
                }

                if (!namesAreValid) {             
                    newNames = [];
                    for (var j = 0; j < newVals.length; j++) {
                        newNames.push('[Select to update - ID: ' + newVals[j] + ']');
                    }
                }

         
                var newContextLabels = null;
                var useContext       = false;

                if (contextlabels != 'null' && contextlabels != '' && contextlabels) {
                    newContextLabels = contextlabels.split('|');
                    useContext       = true;
                }

                /*-------------------------------------------------------------------
                 * Load each item
                 *-------------------------------------------------------------------*/

                for (var i = 0; i < newVals.length; i++) {
                    var itemName = newNames[i] || '[ID: ' + newVals[i] + ']';
                    var itemVal  = newVals[i];

                    if (!itemVal) {
                        continue;
                    }

                    fnLoadItem(itemName, itemVal, useContext ? newContextLabels[i] : '');
                }
            };

            /*-----------------------------------------------------------------------
             * refresh dropdown checkboxes without closing
             *-----------------------------------------------------------------------*/

            var fnRefreshDropdown = function () {
                var $ul = $input.autocomplete("widget");
                if ($ul.is(":visible")) {
                    $ul.find('.ui-menu-item').each(function () {
                        var $li      = $(this);
                        var itemData = $li.data("item.autocomplete");
                        if (itemData) {
                            var isChecked = false;
                            for (var i = 0; i < multiSelListNamesValues.length; i++) {
                                if (String(multiSelListNamesValues[i].value) === String(itemData.id)) {
                                    isChecked = true;
                                    break;
                                }
                            }
                            var $checkbox = $li.find('.ui-spedmon-multiselect-dropdown-checkbox');
                            if (isChecked) {
                                $checkbox.addClass('checked');
                                $li.addClass('ui-spedmon-multiselect-item-selected');
                            } else {
                                $checkbox.removeClass('checked');
                                $li.removeClass('ui-spedmon-multiselect-item-selected');
                            }
                        }
                    });
                }
            };

            /*-----------------------------------------------------------------------
             * hide original input
             *-----------------------------------------------------------------------*/

            $me.hide();

            /*-----------------------------------------------------------------------
             * inline label (optional)
             *-----------------------------------------------------------------------*/

            if ($opts.showSelectControlLabel == true) {
                $('<label class="mba-web-ui mba-web-ui-inline ui-spedmon-multiselect-ctrl-label">' + $opts.selectControlLabel + '</label>').insertBefore($inputWrapper);
            }

            /*-----------------------------------------------------------------------
             * create hidden input for autocomplete
             *-----------------------------------------------------------------------*/

            var $input_opts       = {};
            $input_opts.useHover  = false;
            $input_opts.useLabel  = false;
            $input_opts.useBorder = false;

            $input = $("<input id='" + meid + "_selection' name='" + menm + "_selection' value='' title='" + metitle + "' class='" + $.spedmonWebUI.field.NO_SUBMIT + " ui-spedmon-multiselect-input' type='text' autocomplete='off'/>")
                .appendTo($inputWrapper)
                .spedmonInput($input_opts);

            /*-----------------------------------------------------------------------
             * create action button (dropdown chevron)
             *-----------------------------------------------------------------------*/

            var $button = $("<button class='ui-spedmon-multiselect-action-btn' id='" + meid + "_button' type='button'></button>")
                .attr("tabindex", -1);

            if ($opts.selectType == $.fn.spedmonSelectBoxMultiSelect.constants.SELECT_TYPE_COMBO_BOX) {
                $($button).html('<span class="ui-spedmon-multiselect-chevron">&#9662;</span>')
                    .attr("title", "Click here to select from a list");

                if (!$opts.selectAll)
                    $($button).hide();
            }

            $($button).appendTo($inputWrapper);

            /*-----------------------------------------------------------------------
             * create inline status
             *-----------------------------------------------------------------------*/

            var $status = $("<ul id='" + meid + "_status' class='ui-spedmon-multiselect-status'></ul>")
                .addClass('details-inline')
                .insertAfter($inputWrapper);

            /*-----------------------------------------------------------------------
             * setup autocomplete plugin source of data
             *-----------------------------------------------------------------------*/

            if ($opts.sourceIsLocalData == false) {

                var $xhr;

                $opts.source = function (request, response) {

                    var ajaxopts = {};

                    ajaxopts.url  = $opts.ajaxopts.url;
                    ajaxopts.data = '{term:"' + request.term + '"';

                    $.each($opts.ajaxopts.data, function (idx, val) {
                        var prmid = "#" + val.id;
                        var prm   = $(prmid);
                        if (prm.length > 0)
                            ajaxopts.data = ajaxopts.data + "," + prm.attr("name") + ":'" + prm.attr("value") + "'";
                        else
                            ajaxopts.data = ajaxopts.data + "," + val.id + ":''";
                    });

                    if ($opts.ajaxopts.namevalues) {
                        $.each($opts.ajaxopts.namevalues, function (idx, namevalue) {
                            ajaxopts.data = ajaxopts.data + "," + namevalue.name + ":'" + namevalue.value + "'";
                        });
                    }

                    var newnamevaluesFn = $opts.ajaxopts.getnamevaluesfn;
                    if (newnamevaluesFn) {
                        var newnamevalues = newnamevaluesFn();
                        $.each(newnamevalues, function (idx, namevalue) {
                            ajaxopts.data = ajaxopts.data + "," + namevalue.name + ":'" + namevalue.value + "'";
                        });
                    }

                    ajaxopts.data = ajaxopts.data + "}";

                    ajaxopts.success = function (rd) {
                        if (rd.status == 0) {
                            if (rd.data.SelRecs != null) {
                                response(rd.data.SelRecs);
                            } else {
                                response({});
                            }
                        } else {
                            response({});
                        }
                    };

                    ajaxopts.beforesend = function () { };

                    ajaxopts.complete = function () {
                        if ($opts.selectType == $.fn.spedmonSelectBoxMultiSelect.constants.SELECT_TYPE_COMBO_BOX) {
                            if ($opts.selectAll) {
                                $input.autocomplete("option", "minLength", 1);
                                $input.autocomplete("option", "delay", 600);
                                $input.autocomplete("option", "selectFirst", true);
                            }
                        }
                    };

                    ajaxopts.error = function () {
                        response({});
                    };

                    if ($xhr) $xhr.abort();

                    $xhr = $.spedmonWebUI.ajax($input, $opts.ajaxopts.url, ajaxopts.data, 'json', ajaxopts.beforesend, ajaxopts.success, ajaxopts.error, $status, true, null, ajaxopts.complete);
                };
            }

            /*-----------------------------------------------------------------------
             * selection handler
             *-----------------------------------------------------------------------*/

            $opts.select = function (event, ui) {

    

                if ($opts.multiSelect == true) {

                    event.preventDefault();
                    event.stopPropagation();

                    var alreadySelected = false;
                    var selectedIndex   = -1;

                    for (var i = 0; i < multiSelListNamesValues.length; i++) {
                        if (String(multiSelListNamesValues[i].value) === String(ui.item.id)) {
                            alreadySelected = true;
                            selectedIndex   = i;
                            break;
                        }
                    }

                    if (alreadySelected) {

                        var removedItem = multiSelListNamesValues[selectedIndex];
                        multiSelListNamesValues.splice(selectedIndex, 1);
                        fnUpdateMultipleSelections();
                        $opts.multiSelectOnRemove(removedItem);

                    } else {

                       

                        var selObj = fnLoadItem(ui.item.label, ui.item.id, ui.item.context1);


                        if (selObj) {
                            $opts.multiSelectOnAdd(selObj);
                        }
                    }

                    $opts.multiSelectOnChange(meValues, meNames);

                 
                    $input.val('');

                    setTimeout(function () {
                        fnRefreshDropdown();
                    }, 10);

                    return false;

                } else {

                    $opts.onSelect(event, ui);
                    $me.val(ui.item.id);

                    meValues        = [];
                    meValues.push(ui.item.id);
                    meNames         = [];
                    meNames.push(ui.item.label);
                    meContextLabels = [];
                    meContextLabels.push(ui.item.context1);

                    jQuery.spedmonWebUI.fireDataSelected($me, ui.item);

                    if ($opts.singleSelectClearAfterSelection === true) {
                        $(this).val('');
                        return false;
                    }
                }
            };

            /*-----------------------------------------------------------------------
             * create autocomplete and custom render
             *-----------------------------------------------------------------------*/

            $input.autocomplete($opts);

            var ac = $input.data("autocomplete");

            /*-----------------------------------------------------------------------
             * position dropdown attached to input wrapper
             *-----------------------------------------------------------------------*/

            $input.autocomplete("option", "appendTo", $mecont);
            $input.autocomplete("option", "position", {
                my:        "left top",
                at:        "left bottom",
                of:        $inputWrapper,
                collision: "none"
            });

            /*-----------------------------------------------------------------------
             * set dropdown width to match input wrapper
             *-----------------------------------------------------------------------*/

            $input.on("autocompleteopen", function (event, ui) {
                var $ul = $input.autocomplete("widget");
                $ul.css("width", $inputWrapper.outerWidth() + "px");
            });

            /*-----------------------------------------------------------------------
             * custom render item
             *-----------------------------------------------------------------------*/

            ac._renderItem = function ($ul, item) {

                $ul.addClass('ui-spedmon-multiselect-dropdown');

                var isChecked = false;
                for (var i = 0; i < multiSelListNamesValues.length; i++) {
                    if (String(multiSelListNamesValues[i].value) === String(item.id)) {
                        isChecked = true;
                        break;
                    }
                }

                var checkboxHtml = '';
                if ($opts.multiSelect == true) {
                    var checkedClass = isChecked ? ' checked' : '';
                    checkboxHtml     = '<span class="ui-spedmon-multiselect-dropdown-checkbox' + checkedClass + '">' +
                        '<svg viewBox="0 0 12 12"><path d="M2 6l3 3 5-5"/></svg></span>';
                }

                var selectedClass = isChecked ? ' ui-spedmon-multiselect-item-selected' : '';

                var contextHtml = '';
                if (item.context1 != null && item.context1 != '') {
                    contextHtml = '<span class="ui-spedmon-multiselect-dropdown-context">' + item.context1 + '</span>';
                }

                var $renderedli = $("<li class='ui-spedmon-multiselect-item" + selectedClass + "'></li>")
                    .data("item.autocomplete", item)
                    .append("<a>" + checkboxHtml + "<span class='ui-spedmon-multiselect-dropdown-label'>" + item.label + "</span>" + contextHtml + "</a>");

                $renderedli = $opts.afterRenderItem(item, $renderedli);
                $($renderedli).appendTo($ul);
                return $renderedli;
            };

            /*-----------------------------------------------------------------------
             * override close for multiselect - keep dropdown open
             *-----------------------------------------------------------------------*/

            if ($opts.multiSelect == true) {
                var origClose = ac.close;
                ac.close = function (e) {
                    if (dropdownOpen) {
                        return false;
                    }
                    return origClose.apply(this, arguments);
                };
            }

            /*-----------------------------------------------------------------------
             * setup action button click
             *-----------------------------------------------------------------------*/

            if ($opts.selectType == $.fn.spedmonSelectBoxMultiSelect.constants.SELECT_TYPE_COMBO_BOX) {

                $button.on('mousedown', function (e) {
                    e.preventDefault();
                    e.stopPropagation();

                    var $widget = $input.autocomplete("widget");

                    if ($widget.is(":visible")) {
                        dropdownOpen = false;
                        ac.close();
                    } else {
                        dropdownOpen = true;
                        if ($opts.selectAll) {
                            $input.autocomplete("option", "minLength", 0);
                            $input.autocomplete("option", "delay", 0);
                            $input.autocomplete("option", "selectFirst", false);
                        }
                        $input.autocomplete("search", "");
                        $input.focus();
                    }

                    return false;
                });
            }

            /*-----------------------------------------------------------------------
             * click on wrapper opens dropdown
             *-----------------------------------------------------------------------*/

            $inputWrapper.on('click', function (e) {
                if (!$(e.target).hasClass('ui-spedmon-multiselect-tag-remove') &&
                    !$(e.target).closest('.ui-spedmon-multiselect-action-btn').length &&
                    !$(e.target).closest('.ui-spedmon-multiselect-expand-btn').length) {

                    var $widget = $input.autocomplete("widget");
                    if (!$widget.is(":visible")) {
                        dropdownOpen = true;
                        if ($opts.selectAll) {
                            $input.autocomplete("option", "minLength", 0);
                            $input.autocomplete("option", "delay", 0);
                            $input.autocomplete("option", "selectFirst", false);
                        }
                        $input.autocomplete("search", "");
                    }
                    $input.focus();
                }
            });

            /*-----------------------------------------------------------------------
             * handle input focus/blur for wrapper styling
             *-----------------------------------------------------------------------*/

            $input.on('focus', function () {
                $inputWrapper.addClass('ui-spedmon-multiselect-focused');
            });

            $input.on('blur', function () {
                $inputWrapper.removeClass('ui-spedmon-multiselect-focused');
            });

            /*-----------------------------------------------------------------------
             * close dropdown only when clicking outside
             *-----------------------------------------------------------------------*/

            $(document).on('mousedown', function (e) {
                var $widget = $input.autocomplete("widget");
                if ($widget.is(":visible")) {
                    var clickedInWrapper  = $(e.target).closest($inputWrapper).length > 0;
                    var clickedInDropdown = $(e.target).closest($widget).length > 0;
                    if (!clickedInWrapper && !clickedInDropdown) {
                        dropdownOpen = false;
                        ac.close();
                    }
                }
            });

            /*-----------------------------------------------------------------------
             * keyboard navigation
             *-----------------------------------------------------------------------*/

            if ($opts.multiSelectAllowKeyboardNav == true) {
                $input.on('keydown', function (e) {

                    if (e.keyCode === 8 && $(this).val() === '' && multiSelListNamesValues.length > 0) {
                        var lastItem = multiSelListNamesValues[multiSelListNamesValues.length - 1];
                        fnRemoveTag(lastItem.value);
                        fnUpdateExpandButtonVisibility();
                        $opts.multiSelectOnChange(meValues, meNames);
                    }

                    if (e.keyCode === 27) {
                        dropdownOpen = false;
                        ac.close();
                    }
                });
            }

            /*-----------------------------------------------------------------------
             * init - load existing values
             *-----------------------------------------------------------------------*/

            if ($opts.multiSelect == true) {
                if ($opts.multiSelectLoad == true) {
                    fnLoadItems($opts.multiSelectNames, $opts.multiSelectValues, $opts.multiSelectContextLabels);
                }
                fnUpdateMultipleSelections();
            } else {
                meValues.push($opts.singleSelectValue);
                meNames.push($opts.singleSelectName);
                meContextLabels.push("");
            }

            /*-----------------------------------------------------------------------
             * clean up any empty items that may have been loaded
             *-----------------------------------------------------------------------*/

            for (var i = multiSelListNamesValues.length - 1; i >= 0; i--) {
                var item = multiSelListNamesValues[i];
                if (!item.name || item.name === '' || item.name.trim() === '') {
                    multiSelListNamesValues.splice(i, 1);
                }
            }
            fnUpdateTags();

            /*-----------------------------------------------------------------------
             * set values function
             *-----------------------------------------------------------------------*/

            var fnSetValues = function (multiSelectNames, multiSelectValues, multiSelectContextLabels) {
                if ($opts.multiSelect == true) {
                    $opts.multiSelectNames         = multiSelectNames;
                    $opts.multiSelectValues        = multiSelectValues;
                    $opts.multiSelectContextLabels = multiSelectContextLabels;
                    fnLoadItems($opts.multiSelectNames, $opts.multiSelectValues, $opts.multiSelectContextLabels);
                }
                fnUpdateMultipleSelections();
            };

            /*-----------------------------------------------------------------------
             * create references for helper functions
             *-----------------------------------------------------------------------*/

            var selBoxCtrl = {};

            selBoxCtrl.meid                = meid;
            selBoxCtrl.clear               = fnClearData;
            selBoxCtrl.names               = fnGetNames;
            selBoxCtrl.values              = fnGetValues;
            selBoxCtrl.contextLabels       = fnGetContextLabels;
            selBoxCtrl.setValues           = fnSetValues;
            selBoxCtrl.ctrlRefMe           = $me;
            selBoxCtrl.ctrlRefNewInp       = $input;
            selBoxCtrl.ctrlRefSelectButton = $button;
            selBoxCtrl.ctrlRefExpandButton = $expandButton;
            selBoxCtrl.openModal           = fnOpenModal;
            selBoxCtrl.closeModal          = fnCloseModal;
            selBoxCtrl.updateTags          = fnUpdateTags;

            $.data(this, 'spedmonSelectBoxMultiSelect', selBoxCtrl);

        });
    };

    /*-------------------------------------------------------------------------
     * constants
     *-------------------------------------------------------------------------*/

    $.fn.spedmonSelectBoxMultiSelect.constants = {
        SELECT_TYPE_SEARCH_BOX: 0,
        SELECT_TYPE_COMBO_BOX:  1
    };

    /*-------------------------------------------------------------------------
     * parameter defaults
     *-------------------------------------------------------------------------*/

    $.fn.spedmonSelectBoxMultiSelect.defaults = {
        displayInline:                   false,
        showSelectControlLabel:          false,
        selectControlLabel:              'Select',
        multiSelect:                     true,
        multiSelectListTitle:            'Selected Records',
        multiSelectLoad:                 false,
        multiSelectNames:                '',
        multiSelectValues:               '',
        multiSelectContextLabels:        'null',
        multiSelectDisplayContextLabels: false,
        multiSelectOnAdd:                function (selObj) { },
        multiSelectOnRemove:             function (selObj) { },
        multiSelectOnChange:             function (values, names) { },
        multiSelectShowOK:               false,
        multiSelectShowTags:             true,
        multiSelectShowClearAll:         false,
        multiSelectShowCount:            false,
        multiSelectMaxSelections:        0,
        multiSelectEmptyText:            '',
        multiSelectTagRemoveTitle:       'Remove',
        multiSelectAllowKeyboardNav:     true,
        expandButtonThreshold:           4,
        expandButtonTitle:               'View all selections',
        expandModalTitle:                'Selected Items',
        minLength:                       1,
        delay:                           600,
        singleSelectName:                '',
        singleSelectValue:               '',
        singleSelectClearAfterSelection: false,
        selectType:                      1,
        selectAll:                       true,
        selectFirst:                     true,
        onSelect:                        function (event, ui) { },
        sourceIsLocalData:               false,
        ajaxopts:                        {},
        source:                          function (request, response) { },
        search:                          function (event, ui) { },
        response:                        function (event, ui) { },
        select:                          function (event, ui) { },
        afterRenderItem:                 function (item, $li) { return $li; }
    };

    /*-------------------------------------------------------------------------
     * clear value
     *-------------------------------------------------------------------------*/

    $.fn.spedmonSelectBoxMultiSelect_clear = function () {
        return this.each(function () {
            var $me   = $(this);
            var $ctrl = $($me).data('spedmonSelectBoxMultiSelect');
            if ($ctrl) {
                $ctrl.clear();
            }
        });
    };

    /*-------------------------------------------------------------------------
     * disable
     *-------------------------------------------------------------------------*/

    $.fn.spedmonSelectBoxMultiSelect_disable = function () {
        return this.each(function () {
            var $me   = $(this);
            var $ctrl = $($me).data('spedmonSelectBoxMultiSelect');
            if ($ctrl) {
                MBA.ComponentCommon.fnDisableElement($ctrl.ctrlRefNewInp);
                MBA.ComponentCommon.fnDisableElement($ctrl.ctrlRefSelectButton);
                MBA.ComponentCommon.fnDisableElement($ctrl.ctrlRefExpandButton);
            }
        });
    };

    /*-------------------------------------------------------------------------
     * enable
     *-------------------------------------------------------------------------*/

    $.fn.spedmonSelectBoxMultiSelect_enable = function () {
        return this.each(function () {
            var $me   = $(this);
            var $ctrl = $($me).data('spedmonSelectBoxMultiSelect');
            if ($ctrl) {
                MBA.ComponentCommon.fnEnableElement($ctrl.ctrlRefNewInp);
                MBA.ComponentCommon.fnEnableElement($ctrl.ctrlRefSelectButton);
                MBA.ComponentCommon.fnEnableElement($ctrl.ctrlRefExpandButton);
            }
        });
    };

    /*-------------------------------------------------------------------------
     * open expand modal
     *-------------------------------------------------------------------------*/

    $.fn.spedmonSelectBoxMultiSelect_openModal = function () {
        return this.each(function () {
            var $me   = $(this);
            var $ctrl = $($me).data('spedmonSelectBoxMultiSelect');
            if ($ctrl && $ctrl.openModal) {
                $ctrl.openModal();
            }
        });
    };

    /*-------------------------------------------------------------------------
     * close expand modal
     *-------------------------------------------------------------------------*/

    $.fn.spedmonSelectBoxMultiSelect_closeModal = function () {
        return this.each(function () {
            var $me   = $(this);
            var $ctrl = $($me).data('spedmonSelectBoxMultiSelect');
            if ($ctrl && $ctrl.closeModal) {
                $ctrl.closeModal();
            }
        });
    };

})(jQuery);