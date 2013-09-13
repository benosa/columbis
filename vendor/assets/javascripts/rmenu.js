/*
Simple Responsive Mega Menu
Licensed under http://creativecommons.org/licenses/by-sa/3.0/
*/


(function($) {


    $.rMenu = function(element, options) {


        var defaults = {

        };

        var plugin = this;

        plugin.options = {}

        var $element = $(element);
        var element = element;

            var menuItem = $element.children('li'),
                menuDropDown = $element.find('.rmenu_dropdown'),
                menuDropdownRight = $element.find('.rmenu_dropdown_right');


        plugin.init = function() {

            plugin.options = $.extend({}, options, options);

            megaMenuEvents();

        }


        var megaMenuEvents = function(){

            if ("ontouchstart" in document.documentElement) {

                megaMenuToggleElements();

                $(menuItem).unbind('mouseenter mouseleave').click(function () {

                    var $this = $(this);
                    $this.siblings().removeClass('active').addClass('noactive')
                        .find(menuDropDown).hide(0);
                    $this.toggleClass('active noactive').find(menuDropDown).first().toggle(0)
                        .click(function (event) {
                            event.stopPropagation();
                        });
                });

                $(document).click(function () {
                    $(menuItem).addClass('noactive');
                    $(menuDropDown).hide(0);
                });
                $element.click(function(event) {
                    event.stopPropagation();
                });
                $(window).bind('orientationchange', function () {
                    megaMenuToggleElements();
                    $(menuItem).addClass('noactive');
                });

                return;

                $(element).click(function(event) {
                    $('body').click(function() {
                        $(menuDropDown).hide(0);
                    });
                    event.stopPropagation();
                });

            }

        }


        var megaMenuToggleElements = function(){

            $(menuItem).removeClass('active').addClass('noactive');
            $(menuDropDown).css({'left': 'auto', 'opacity' : '1'}).hide(0);
            $(menuDropdownRight).css({'right': '0'}).hide(0);

        }


        plugin.init();

    }


    $.fn.rMenu = function(options) {


        return this.each(function() {

            if (undefined == $(this).data('rMenu')) {

                var plugin = new $.rMenu(this, options);
                $(this).data('rMenu', plugin);

            }

        });


    }


})(jQuery);

