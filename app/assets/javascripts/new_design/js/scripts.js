$(function(){   $(".header select,.standart_select").ikSelect({		autoWidth: false	});	$(".filter select").ikSelect({		autoWidth: false,		customClass: "filter_select",		ddCustomClass: "filter_select"	});	$(".airline_select").ikSelect({		autoWidth: false,		customClass: "airline_select",		ddCustomClass: "airline_select"	});	$(".payment").ikSelect({		autoWidth: false,		customClass: "payment_select",		ddCustomClass: "payment_select"	});	$(".flight_from_select").ikSelect({		autoWidth: false,		customClass: "flight_from_select",		ddCustomClass: "flight_from_select"	});	$(".tour_operator_select").ikSelect({		autoWidth: false,		customClass: "tour_operator_select",		ddCustomClass: "tour_operator_select"	});	$(".route_select").ikSelect({		autoWidth: false,		customClass: "route_select",		ddCustomClass: "route_select"	});	$(".resort_select").ikSelect({		autoWidth: false,		customClass: "resort_select",		ddCustomClass: "resort_select"	});	$(".pagination select").ikSelect({		autoWidth: false,		customClass: "pagination_select",		ddCustomClass: "pagination_select"	});	$(".reservations tr:odd").addClass("odd");	$(".reservations td p").hover(function(){		$(this).find(".hide_text").fadeToggle(500);	});	$("label.checkbox").click(function(){		$(this).toggleClass('active');	});/*** Float_panel ***/        var a = function() {            var b = $(window).scrollTop();            var not_h = parseInt($('.all').height());            var window_h = parseInt($(window).height());            var wrapper = $(".wrapper");            window_h=not_h-window_h;            //alert(window_h);            var c = $(".float_panel");            //$(".float_panel").html('b='+b+' '+window_h);            if (b >= window_h ) {                c.css({position:"fixed",bottom:"90px"})                //wrapper.css({margin: "18px 0 100px 0"})            } else {                c.css({position:"fixed",bottom:"0"})                wrapper.css({margin: "18px 0 100px 0"})            }        };        $(window).scroll(a);a()});