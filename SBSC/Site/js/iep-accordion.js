; var MBA = MBA || {};

/*------------------------------------------------------------------*/

MBA.IEPPresentTabAccordion = (function ($) {
    'use strict';

    /*------------------------------------------------------------------*/

    var SELECTORS = {
        accordion: '.iep-present-tab-accordion',
        header:    '.iep-present-tab-accordion__header',
        content:   '.iep-present-tab-accordion__content',
        chevron:   '.iep-present-tab-accordion__chevron'
    };

    var CLASSES = {
        collapsed: 'iep-present-tab-accordion--collapsed',
        na:        'iep-present-tab-accordion--na'
    };

    var initialized = false;

    /*------------------------------------------------------------------*/

    function toggleAccordion($accordion) {
        if ($accordion.hasClass(CLASSES.collapsed)) {
            $accordion.removeClass(CLASSES.collapsed);
            $accordion.find(SELECTORS.header).attr('aria-expanded', 'true');
        } else {
            $accordion.addClass(CLASSES.collapsed);
            $accordion.find(SELECTORS.header).attr('aria-expanded', 'false');
        }
    }

    function expandAccordion($accordion) {
        $accordion.removeClass(CLASSES.collapsed);
        $accordion.find(SELECTORS.header).attr('aria-expanded', 'true');
    }

    function collapseAccordion($accordion) {
        $accordion.addClass(CLASSES.collapsed);
        $accordion.find(SELECTORS.header).attr('aria-expanded', 'false');
    }

    function updateNAState($accordion, isNA) {
        if (isNA) {
            $accordion.addClass(CLASSES.na);
        } else {
            $accordion.removeClass(CLASSES.na);
        }
    }

    function bindHeaderClick() {
        $(document).on('click', SELECTORS.header, function (e) {
            var $header    = $(this);
            var $accordion = $header.closest(SELECTORS.accordion);
            toggleAccordion($accordion);
        });
    }

    function bindKeyboardNav() {
        $(document).on('keydown', SELECTORS.header, function (e) {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                var $header    = $(this);
                var $accordion = $header.closest(SELECTORS.accordion);
                toggleAccordion($accordion);
            }
        });
    }

    function bindNACheckboxes() {
        $(document).on('change', SELECTORS.accordion + ' input[type="checkbox"]', function (e) {
            var $checkbox  = $(this);
            var checkboxId = $checkbox.attr('id') || '';

            if (checkboxId.toLowerCase().indexOf('reviewedna') === -1) {
                return;
            }

            var $accordion = $checkbox.closest(SELECTORS.accordion);
            var isChecked  = $checkbox.is(':checked');
            updateNAState($accordion, isChecked);
        });

        $(document).on('spedmoninputdata', SELECTORS.accordion + ' input[type="text"]', function (e) {
            var $input    = $(this);
            var inputName = $input.attr('name') || '';

            if (inputName.toLowerCase().indexOf('reviewedna') === -1) {
                return;
            }

            var $accordion = $input.closest(SELECTORS.accordion);
            var isChecked  = $input.val() === 'true';
            updateNAState($accordion, isChecked);
        });
    }

    function initializeNAStates() {
        $(SELECTORS.accordion).each(function () {
            var $accordion   = $(this);
            var $hiddenInput = $accordion.find('input[type="text"]').filter(function () {
                var name = $(this).attr('name') || '';
                return name.toLowerCase().indexOf('reviewedna') > -1;
            });

            if ($hiddenInput.length && $hiddenInput.val() === 'true') {
                updateNAState($accordion, true);
            }
        });
    }

    /*------------------------------------------------------------------*/


    function init() {
        if (initialized) {
            return;
        }

        bindHeaderClick();
        bindKeyboardNav();
        bindNACheckboxes();
        initializeNAStates();

        initialized = true;
    }

    function expandAll() {
        $(SELECTORS.accordion).each(function () {
            expandAccordion($(this));
        });
    }

    function collapseAll() {
        $(SELECTORS.accordion).each(function () {
            collapseAccordion($(this));
        });
    }

    function toggle(element) {
        var $clicked   = $(element);
        var $accordion = $clicked.hasClass('iep-present-tab-accordion')
            ? $clicked
            : $clicked.closest(SELECTORS.accordion);

        if ($accordion.length) {
            toggleAccordion($accordion);
        }
    }

    function expand(accordionElement) {
        var $accordion = $(accordionElement).closest(SELECTORS.accordion);
        if ($accordion.length) {
            expandAccordion($accordion);
        }
    }

    function collapse(accordionElement) {
        var $accordion = $(accordionElement).closest(SELECTORS.accordion);
        if ($accordion.length) {
            collapseAccordion($accordion);
        }
    }

    function isExpanded(accordionElement) {
        var $accordion = $(accordionElement).closest(SELECTORS.accordion);
        return $accordion.length && !$accordion.hasClass(CLASSES.collapsed);
    }

    function refresh() {
        initializeNAStates();
    }


    /*------------------------------------------------------------------*/

    return {
        init:        init,
        expandAll:   expandAll,
        collapseAll: collapseAll,
        toggle:      toggle,
        expand:      expand,
        collapse:    collapse,
        isExpanded:  isExpanded,
        refresh:     refresh
    };

})(jQuery);

/*------------------------------------------------------------------*/

function fnInitIEPPresentTabAccordions() {
    MBA.IEPPresentTabAccordion.init();
}

function fnExpandAllIEPPresentTabAccordions() {
    MBA.IEPPresentTabAccordion.expandAll();
}

function fnCollapseAllIEPPresentTabAccordions() {
    MBA.IEPPresentTabAccordion.collapseAll();
}

function fnToggleIEPAccordion(element) {
    MBA.IEPPresentTabAccordion.toggle(element);
}

function fnRefreshIEPPresentTabAccordions() {
    MBA.IEPPresentTabAccordion.refresh();
}