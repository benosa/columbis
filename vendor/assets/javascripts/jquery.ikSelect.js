// ikSelect 0.8.6
// Copyright (c) 2012 Igor Kozlov
// i10k.ru

;(function($, window, document, undefined){
  var $window = $(window);
  var defaults = {
    syntax: "<div class=\"ik_select_link\"><span class=\"ik_select_link_text\"></span></div><div class=\"ik_select_block\"><div class=\"ik_select_list\"></div></div>",
    autoWidth: true,
    ddFullWidth: true,
    customClass: "",
    ddCustomClass: "",
    ddMaxHeight: 200,
    editable: false, // can be a string, means selector wich has to match this select
    useSelectClasses: false
  };

  var selectOpened = $([]); // currently opened select
  var shownOnPurpose = false; // true if show_dropdown was called using API
  var scrollbarWidth = -1;

  $.browser.mobile = (/iphone|ipad|ipod|android/i.test(navigator.userAgent.toLowerCase()));
  $.browser.android = (/android/i.test(navigator.userAgent.toLowerCase()));
  $.browser.operamini = Object.prototype.toString.call(window.operamini) === "[object OperaMini]";

  function IkSelect(element, options){
    var ikselect = this;

    ikselect.element = element;

    ikselect.options = $.extend({}, defaults, options);

    ikselect._defaults = defaults;

    if(ikselect.element === undefined){
      return ikselect;
    }

    if (typeof ikselect.options.editable == 'string')
      ikselect.editable = $(ikselect.element).is(ikselect.options.editable);
    else
      ikselect.editable = ikselect.options.editable

    if (ikselect.editable && ikselect.options.syntax == defaults.syntax)
      ikselect.options.syntax = "<div class=\"ik_select_link\"><div class=\"ik_select_link_inner\"><input class=\"ik_select_link_text\" /></div></div><div class=\"ik_select_block\"><div class=\"ik_select_list\"></div></div>";

    ikselect.fakeSelect = $("<div class=\"ik_select" + (ikselect.editable ? " ik_select_editable" : "") + "\">" + ikselect.options.syntax + "</div>"); // fake select object made with passed syntax
    ikselect.select = $(ikselect.element); // original select
    ikselect.link = $(".ik_select_link", ikselect.fakeSelect); // fake select
    ikselect.linkText = $(".ik_select_link_text", ikselect.fakeSelect); // fake select's text
    ikselect.block = $(".ik_select_block", ikselect.fakeSelect); // fake select's dropdown
    ikselect.list = $(".ik_select_list", ikselect.fakeSelect); // fake select's list inside of dropdown
    ikselect.listInner = $("<div class=\"ik_select_list_inner\"/>"); // support block for scroll

    ikselect.active = $([]);
    ikselect.hover = $([]);
    ikselect.hoverIndex = -1;

    ikselect.listItems = $([]);

    ikselect.init();
  }

  $.extend(IkSelect.prototype, {
    init: function(){
      var ikselect = this;

      var fakeSelect = ikselect.fakeSelect;
      var select = ikselect.select;
      var link = ikselect.link;
      var block = ikselect.block;
      var list = ikselect.list;
      var listInner = ikselect.listInner;
      var linkText = ikselect.linkText;

      list.append(listInner);

      fakeSelect.addClass(ikselect.options.customClass);
      block.addClass(ikselect.options.ddCustomClass);

      if (ikselect.options.useSelectClasses) {
        var classes = select.attr('class');
        fakeSelect.addClass(classes);
        block.addClass(classes);
      }

      //creating fake option list
      ikselect.reset_all();

      if(select.attr("disabled")){
        ikselect.disable_select();
      }

      // click event for fake select
      link.bind("click.ikSelect", function(e){
        if(fakeSelect.data("ik_select_disabled")){
          return this;
        }
        if (!ikselect.editable) {
          if(selectOpened.length){
            selectOpened.data("plugin_ikSelect").hide_block();
          }
          if(!$.browser.mobile){
            ikselect.show_block();
          }
          select.focus();
        } else if (!$(e.target).is('.ik_select_link_text'))
          linkText.focus();
      });

      // when focus is on original select add "focus" class to the fake one
      select.bind("focus.ikSelect", function(){
        if(fakeSelect.data("ik_select_disabled")){
          return this;
        }
        link.addClass("ik_select_focus");

        // scoll the window so that focused select is visible
        if((fakeSelect.offset().top + fakeSelect.height() > $window.scrollTop() + $window.height()) || (fakeSelect.offset().top + fakeSelect.height() < $window.scrollTop())){
          $window.scrollTop(fakeSelect.offset().top - $window.height()/2);
        }
      });

      // when focus lost remove "focus" class from the fake one
      select.bind("blur.ikSelect", function(){
        if(fakeSelect.data("ik_select_disabled")){
          return this;
        }
        link.removeClass("ik_select_focus");
      });

      // sync fake select on mobile devices and a way to outplay the changing of select on scroll anywhere in IE6
      select.bind("change.ikSelect", function(){
        ikselect._select_fake_option();
      });

      // keyboard controls for the fake select and fake dropdown
      var keyboard_controller = function(event){
        var listItems = ikselect.listItems;

        if(ikselect.hoverIndex < 0){
          ikselect.hoverIndex = listItems.index(ikselect.hover);
        }

        var keycode = event.which;
        var type = event.type;

        switch(keycode){
          case 40: //down
            if(type === "keydown"){
              event.preventDefault();
              var next;

              if(ikselect.hoverIndex < listItems.length - 1){
                next = listItems.eq(++ikselect.hoverIndex);

                while(next && next.hasClass("ik_select_option_disabled")){
                  next = listItems.filter(":eq("+ (++ikselect.hoverIndex) +")");
                }
              }

              if(next){
                ikselect._move_to(next);
              }
            }
            break;
          case 38: //up
            if(type === "keydown"){
              event.preventDefault();
              var prev;
              if(ikselect.hoverIndex > 0){
                prev = listItems.eq(--ikselect.hoverIndex);

                while(prev && prev.hasClass("ik_select_option_disabled")){
                  prev = listItems.filter(":eq("+ (--ikselect.hoverIndex) +")");
                }
              }

              if(prev){
                ikselect._move_to(prev);
              }
            }
            break;
          case 33: //page up
          case 36: //home
            if(type === "keydown"){
              event.preventDefault();
              ikselect._move_to(listItems.filter(".not(ik_select_option_disabled):first"));
            }
            break;
          case 34: //page down
          case 35: //end
            if(type === "keydown"){
              event.preventDefault();
              ikselect._move_to(listItems.filter(".not(ik_select_option_disabled):last"));
            }
            break;
          case 32: //space
            if(type === "keydown"){
              event.preventDefault();
              if(! block.is(":visible")){
                ikselect.show_block();
              } else{
                ikselect._select_real_option();
              }
            }
            break;
          case 13: //enter
            if(type === "keydown" && block.is(":visible")){
              event.preventDefault();
              ikselect._select_real_option();
            }
            break;
          case 27: //esc
            if(type === "keydown"){
              event.preventDefault();
              ikselect.hide_block();
            }
            break;
          case 9: //tab
            if(type === "keydown"){
              if($.browser.webkit && block.is(":visible")){
                event.preventDefault();
              } else{
                ikselect.hide_block();
              }
            }
            break;
          default:
            if(type === "keyup"){
              ikselect._select_fake_option();
            }
            break;
        }
      };
      select.bind("keydown.ikSelect keyup.ikSelect", keyboard_controller);

      // if it's editable, bind handlers for link text input
      if (ikselect.editable) {

        // keyboard controls for the input field
        linkText.bind("keydown.editable.ikSelect keyup.editable.ikSelect", function(event){
          var keycode = event.which;
          var type = event.type;
          switch(keycode) {
            case 13: //enter
              if(type === "keyup"){
                event.preventDefault();
                var value = ikselect._escape_html_entities(this.value),
                    real_option = ikselect._search_real_option(value);
                if (!real_option) {
                  var options = {};
                  options[value] = value;
                  ikselect.add_options(options);
                }
                ikselect.make_selection(value);
                if(selectOpened.length){
                  selectOpened.data("plugin_ikSelect").hide_block();
                }
                select.focus();
              }
              break;
            case 40: //down
            case 38: //up
            case 33: //page up
            case 36: //home
            case 34: //page down
            case 35: //end
            case 27: //esc
            case 9: //tab
              keyboard_controller(event);
              break;
          }
        });

        // when focus is on input show options
        linkText.bind("focus.editable.ikSelect", function(){
          if(fakeSelect.data("ik_select_disabled")){
            return this;
          }
          if(selectOpened.length){
            selectOpened.data("plugin_ikSelect").hide_block();
          }
          if(!$.browser.mobile){
            ikselect.show_block();
          }
          link.addClass("ik_select_focus");
          $(this).select();
        });

        // when focus left from input clear it, if there is no options with input value
        linkText.bind("blur.editable.ikSelect", function(){
          if(fakeSelect.data("ik_select_disabled")){
            return this;
          }
          var option = $('option:selected', ikselect.select);
          this.value = option.html();
          // ikselect.hide_block();
          // link.removeClass("ik_select_focus");
        });
      }

      // appending fake select right after the original one
      select.after(fakeSelect);

      // set correct dimensions
      ikselect.redraw();

      select.appendTo(fakeSelect);
    },

    redraw: function(){
      var ikselect = this;
      var select = ikselect.select;
      var fakeSelect = ikselect.fakeSelect;
      var block = ikselect.block;
      var list = ikselect.list;
      var listInner = ikselect.listInner;

      var autoWidth = ikselect.options.autoWidth; // set select width according to the longest option
      var ddFullWidth = ikselect.options.ddFullWidth; // set dropdown width according to the longest option

      // width calculations for the fake select when "autoWidth" is "true"
      if(autoWidth || ddFullWidth){
        listInner.width("auto");
        $("ul", listInner).width("auto");
        fakeSelect.width("auto");

        block.show().width(9999);
        listInner.css("float", "left");
        list.css("position", "absolute");
        var maxWidthOuter = list.outerWidth(true);
        var maxWidthInner = list.width();
        list.css("position", "static");
        block.hide().css("width", "100%");
        listInner.css("float", "none");

        if(scrollbarWidth === -1){
          var calculationContent = $("<div style=\"width:50px; height:50px; overflow:hidden; position:absolute; top:-200px; left:-200px;\"><div style=\"height:100px;\"></div>");
          $("body").append(calculationContent);
          var w1 = $("div", calculationContent).innerWidth();
          calculationContent.css("overflow", "auto");
          var w2 = $("div", calculationContent).innerWidth();
          $(calculationContent).remove();
          scrollbarWidth = w1 - w2;
        }

        var parentWidth = fakeSelect.parent().width();
        if(ddFullWidth){
          block.width(maxWidthOuter);
          listInner.width(maxWidthInner);
          $("ul", listInner).width(maxWidthInner);
        }
        if(maxWidthOuter > parentWidth){
          maxWidthOuter = parentWidth;
        }
        if(autoWidth){
          fakeSelect.width(maxWidthOuter);
        }
      }

      ikselect._fix_height();

      // hide the original select
      select.css({
        position: "absolute",
        margin: 0,
        padding: 0,
        left: -9999,
        top: 0
      });

      // show the original select in Android browsers
      if($.browser.android){
        select.css({
          opacity: 0,
          left: 0,
          height: fakeSelect.height()
        });
      }
    },

    // creates or recreates dropdown and sets selected options's text into fake select
    reset_all: function(){
      var ikselect = this;
      var select = ikselect.select;
      var linkText = ikselect.linkText;
      var listInner = ikselect.listInner;

      // init fake select's text
      ikselect._set_link_text(select.html());

      listInner.empty();

      // creating an ul->li list identical to original dropdown
      var newOptions = "";

      newOptions += "<ul>";
      select.children().each(function(){
        if(this.tagName === "OPTGROUP"){
          var optgroup = $(this);
          newOptions += "<li class=\"ik_select_optgroup"+ (optgroup.is(":disabled") ? " ik_select_optgroup_disabled" : "") +"\">";

          newOptions += "<div class=\"ik_select_optgroup_label\">"+ optgroup.attr("label") +"</div>";

          newOptions += "<ul>";
          $("option", optgroup).each(function(){
            var option = $(this);
            newOptions += "<li"+ (option.is(":disabled") ? " class=\"ik_select_option_disabled\"" : "") +"><span class=\"ik_select_option\" title=\""+ option.val() +"\">"+ option.html() +"</span></li>";
          });
          newOptions += "</ul>";

          newOptions += "</li>";
        } else{
          var option = $(this);
          newOptions += "<li"+ (option.is(":disabled") ? " class=\"ik_select_option_disabled\"" : "") +"><span class=\"ik_select_option\" title=\""+ option.val() +"\">"+ option.html() +"</span></li>";
        }
      });
      newOptions += "</ul>";
      listInner.append(newOptions);
      ikselect._select_fake_option();

      ikselect.listItems = $("li:not(.ik_select_optgroup)", listInner);

      ikselect._attach_list_events(ikselect.listItems);
    },

    // binds click and mouseover events to dropdown's options
    _attach_list_events: function(jqObj){
      var ikselect = this;
      var select = ikselect.select;
      var linkText = ikselect.linkText;

      var listItemsEnabled = jqObj.not(".ik_select_option_disabled");

      // click events for the fake select's options
      listItemsEnabled.bind("click.ikSelect", function(){

        ikselect._set_link_text($(".ik_select_option", this).html());
        select.val($(".ik_select_option", this).attr("title"));
        ikselect.active.removeClass("ik_select_active");
        ikselect.active = $(this).addClass("ik_select_active");
        ikselect.hide_block();
        select.change();
        select.focus();
      });

      // hover event for the fake options
      listItemsEnabled.bind("mouseover.ikSelect", function(){
        ikselect.hoverIndex = -1;
        ikselect.hover.removeClass("ik_select_hover");
        ikselect.hover = $(this).addClass("ik_select_hover");
      });

      listItemsEnabled.addClass("ik_select_has_events");
    },

    // unbinds click and mouseover events from dropdown's options
    _detach_list_events: function(jqObj){
      jqObj.unbind(".ikSelect");

      jqObj.removeClass("ik_select_has_events");
    },


    // change the defaults for all new instances
    set_defaults: function(settings){
      $.extend(this._defaults, settings || {});
      return this;
    },

    // hides dropdown
    hide_block: function(){
      var fakeSelect = this.fakeSelect;
      var block = this.block;
      var select = this.select;

      block.hide().appendTo(fakeSelect).css({
        "left": "",
        "top": ""
      });

      selectOpened = $([]);

      select.focus();
    },

    // shows dropdown
    show_block: function(){
      var ikselect = this;
      var select = ikselect.select;

      if($.browser.mobile && !$.browser.android){
        select.focus();
        return ikselect;
      }

      if(selectOpened.is(ikselect.select)){
        return ikselect;
      } else if(selectOpened.length){
        selectOpened.data("plugin_ikSelect").hide_block();
      }

      var fakeSelect = ikselect.fakeSelect;
      var block = ikselect.block;
      var list = ikselect.list;
      var listInner = ikselect.listInner;
      var hover = ikselect.hover;
      var active = ikselect.active;
      var listItems = ikselect.listItems;

      block.show();
      var ind = $("option", select).index($("option:selected", select));
      hover.removeClass("ik_select_hover");
      active.removeClass("ik_select_active");
      var next = listItems.eq(ind);
      next.addClass("ik_select_hover ik_select_active");
      ikselect.hover = next;
      ikselect.active = next;
      ikselect.hoverIndex = ikselect.listItems.index(next);

      // if the dropdown's right border is beyond window's edge then move the dropdown to the left so that it fits
      block.removeClass("ik_select_block_right");
      block.css("left", "");
      if(ikselect.options.ddFullWidth && fakeSelect.offset().left + block.outerWidth(true) > $window.width()){
        block.addClass("ik_select_block_right");
        block.css("left", (block.offset().left + block.outerWidth(true) - $window.width()) * (-1));
      }

      // if the dropdown's bottom border is beyond window's edge then move the dropdown to the left so that it fits
      block.removeClass("ik_select_block_up");
      block.css("top", "");
      if(block.offset().top + block.outerHeight(true) > $window.scrollTop() + $window.height()){
        block.addClass("ik_select_block_up");
        block.css("top", ((block.offset().top + block.outerHeight(true) - parseInt(block.css("top"), 10)) - ($window.scrollTop() + $window.height())) * (-1));
      }

      var left = block.offset().left;
      if(left < 0){
        left = 0;
      }
      var top = block.offset().top;
      block.width(block.width());
      block.appendTo("body").css({
        "left": left,
        "top": top
      });

      var scrollTop = $(".ik_select_active", list).position().top - list.height()/2;
      list.data("ik_select_scrollTop", scrollTop);
      listInner.scrollTop(scrollTop);

      selectOpened = select;
    },

    // add options to the list
    add_options: function(args){
      var ikselect = this;
      var select = ikselect.select;
      var listInner = ikselect.listInner;

      var fakeSelectHtml = "", selectHtml = "";

      $.each(args, function(index, value){
        if(typeof value === "string"){
          fakeSelectHtml += "<li><span class=\"ik_select_option\" title=\""+ index +"\">"+ value +"</span></li>";
          selectHtml += "<option value=\""+ index +"\">"+ value +"</option>";
        } else if(typeof value === "object"){
          var ul = $("> ul > li.ik_select_optgroup:eq("+ index +") > ul", listInner); // 'index' - optgroup index

          var optgroup = $("optgroup:eq("+ index +")", select);
          var newOptions = value; // 'value' - new option objects

          $.each(newOptions, function(index, value){
            fakeSelectHtml += "<li><span class=\"ik_select_option\" title=\""+ index +"\">"+ value +"</span></li>";
            selectHtml += "<option value=\""+ index +"\">"+ value +"</option>";
          });

          ul.append(fakeSelectHtml);
          optgroup.append(selectHtml);
          fakeSelectHtml = "";
          selectHtml = "";
        }
      });

      if(selectHtml !== ""){
        $(":first", listInner).append(fakeSelectHtml);
        select.append(selectHtml);
      }

      ikselect._fix_height();

      ikselect.listItems = $("li:not(.ik_select_optgroup)", listInner);

      ikselect._attach_list_events(ikselect.listItems);
    },

    // remove options from the list
    remove_options: function(args){
      var ikselect = this;
      var select = ikselect.select;
      var listItems = ikselect.listItems;
      var removeList = $([]);

      $.each(args, function(index, value){
        $("option", select).each(function(index){
          if($(this).val() === value){
            removeList = removeList.add($(this)).add(listItems.eq(index));
          }
        });
      });

      ikselect.listItems = listItems.not(removeList);
      removeList.remove();
      ikselect._select_fake_option();

      ikselect._fix_height();
    },

    // sync selected option in the fake select with the original one
    _select_real_option: function(){
      var hover = this.hover;
      var active = this.active;

      active.removeClass("ik_select_active");
      hover.addClass("ik_select_active").click();
    },

    // sync selected option in the original select with the fake one
    _select_fake_option: function(){
      var ikselect = this;
      var select = ikselect.select;
      var linkText = ikselect.linkText;
      var listItems = ikselect.listItems;

      var selected = $(":selected", select);
      var ind = $("option", select).index(selected);
      ikselect._set_link_text(selected.html());
      ikselect.hover = listItems.removeClass("ik_select_hover ik_select_active").eq(ind).addClass("ik_select_hover ik_select_active");
      ikselect.active = ikselect.hover;
    },

    // disables select
    disable_select: function(){
      var fakeSelect = this.fakeSelect;
      var select = this.select;

      select.attr("disabled", "disabled");
      fakeSelect.addClass("ik_select_disabled")
        .data("ik_select_disabled", true);
    },

    // enables select
    enable_select: function(){
      var fakeSelect = this.fakeSelect;
      var select = this.select;

      select.removeAttr("disabled");
      fakeSelect.removeClass("ik_select_disabled")
        .data("ik_select_disabled", false);
    },

    // toggles select
    toggle_select: function(){
      var ikselect = this;
      var fakeSelect = ikselect.fakeSelect;

      if(fakeSelect.data("ik_select_disabled")){
        ikselect.enable_select();
      } else{
        ikselect.disable_select();
      }
    },

    // make option selected by value
    make_selection: function(args){
      var ikselect = this;
      var select = ikselect.select;

      select.val(args);
      ikselect._select_fake_option();
    },

    // disables optgroups
    disable_optgroups: function(args){
      var ikselect = this;
      var select = ikselect.select;
      var list = ikselect.list;

      $.each(args, function(index, value){
        var optgroup = $("optgroup:eq("+ value +")", select);
        optgroup.attr("disabled", "disabled");
        $(".ik_select_optgroup:eq("+ value +")", list).addClass("ik_select_optgroup_disabled");

        ikselect.disable_options($("option", optgroup));
      });

      ikselect._select_fake_option();
    },

    // enables optgroups
    enable_optgroups: function(args){
      var ikselect = this;
      var select = ikselect.select;
      var list = ikselect.list;

      $.each(args, function(index, value){
        var optgroup = $("optgroup:eq("+ value +")", select);
        optgroup.removeAttr("disabled");
        $(".ik_select_optgroup:eq("+ value +")", list).removeClass("ik_select_optgroup_disabled");

        ikselect.enable_options($("option", optgroup));
      });

      ikselect._select_fake_option();
    },

    // disables options
    disable_options: function(args){
      var ikselect = this;
      var select = ikselect.select;
      var listItems = ikselect.listItems;

      var optionSet = $("option", select);

      $.each(args, function(index, value){
        if(typeof value === "object"){
          $(this).attr("disabled", "disabled");
          var option_index = optionSet.index(this);
          var fakeOption = listItems.eq(option_index).addClass("ik_select_option_disabled");
          ikselect._detach_list_events(fakeOption);
        } else{
          optionSet.each(function(index){
            if($(this).val() === value){
              $(this).attr("disabled", "disabled");
              var fakeOption = listItems.eq(index).addClass("ik_select_option_disabled");
              ikselect._detach_list_events(fakeOption);
              return this;
            }
          });
        }
      });

      ikselect._select_fake_option();
    },

    // disables options
    enable_options: function(args){
      var ikselect = this;
      var select = ikselect.select;
      var listItems = ikselect.listItems;

      var optionSet = $("option", select);

      $.each(args, function(index, value){
        if(typeof value === "object"){
          $(this).removeAttr("disabled");
          var option_index = optionSet.index(this);
          var fakeOption = listItems.eq(option_index).removeClass("ik_select_option_disabled");
          ikselect._attach_list_events(fakeOption);
        } else{
          optionSet.each(function(index){
            if($(this).val() === value){
              $(this).removeAttr("disabled");
              var fakeOption = listItems.eq(index).removeClass("ik_select_option_disabled");
              ikselect._attach_list_events(fakeOption);
              return this;
            }
          });
        }
      });

      ikselect._select_fake_option();
    },

    // detaching plugin from the orignal select
    detach_plugin: function(){
      var ikselect = this;
      var select = ikselect.select;
      var fakeSelect = ikselect.fakeSelect;

      select.unbind(".ikSelect").css({
        "width": "",
        "height": "",
        "left": "",
        "top": "",
        "position": "",
        "margin": "",
        "padding": ""
      });

      fakeSelect.before(select);
      fakeSelect.remove();
    },

    // controls class changes for options (hover/active states)
    _move_to: function(jqObj){
      var ikselect = this;
      var select = ikselect.select;
      var linkText = ikselect.linkText;
      var block = ikselect.block;
      var list = ikselect.list;
      var listInner = ikselect.listInner;

      if(! block.is(":visible") && $.browser.webkit){
        ikselect.show_block();
        return this;
      }

      ikselect.hover.removeClass("ik_select_hover");
      jqObj.addClass("ik_select_hover");
      ikselect.hover = jqObj;
      if(! $.browser.webkit){
        ikselect.active.removeClass("ik_select_active");
        jqObj.addClass("ik_select_active");
        ikselect.active = jqObj;
      }
      if(! block.is(":visible") || $.browser.mozilla){
        if(! $.browser.mozilla){
          select.val($(".ik_select_option", jqObj).attr("title"));
          select.change();
        }
        ikselect._set_link_text($(".ik_select_option", jqObj).html());
      }

      var jqObjTopLine = jqObj.offset().top - list.offset().top - parseInt(list.css("paddingTop"), 10);
      var jqObjBottomLine = jqObjTopLine + jqObj.outerHeight();
      if(jqObjBottomLine > list.height()){
        listInner.scrollTop(listInner.scrollTop() + jqObjBottomLine - list.height());
      } else if(jqObjTopLine < 0){
        listInner.scrollTop(listInner.scrollTop() + jqObjTopLine);
      }
    },

    // sets fixed height to dropdown if it's bigger than ddMaxHeight
    _fix_height: function(){
      var ikselect = this;
      var block = ikselect.block;
      var listInner = ikselect.listInner;
      var ddMaxHeight = ikselect.options.ddMaxHeight;
      var ddFullWidth = ikselect.options.ddFullWidth;

      block.show();
      listInner.css("height", "auto");
      if(listInner.height() > ddMaxHeight){
        listInner.css({
          overflow: "auto",
          height: ddMaxHeight,
          position: "relative"
        });

        if(! $.data(listInner, "ik_select_hasScrollbar")){
          if(ddFullWidth){
            block.width(block.width() + scrollbarWidth);
            listInner.width(listInner.width() + scrollbarWidth);
          }
        }

        $.data(listInner, "ik_select_hasScrollbar", true);
      } else{
        if($.data(listInner, "ik_select_hasScrollbar")){
          listInner.css({
            overflow: "",
            height: "auto"
          });
          listInner.width(listInner.width() - scrollbarWidth);
          block.width(block.width() - scrollbarWidth);
        }
      }
      block.hide();
    },

    // sets linkText html or value, if it's editable
    _set_link_text: function(text) {
      var ikselect = this,
          linkText = ikselect.linkText;
      if (!ikselect.editable)
        linkText.html(text);
      else
        linkText.val(text);
    },

    _search_real_option: function(text) {
      var ikselect = this;
      var select = ikselect.select;

      var option = $('option[value="' + text + '"]', select);
      return option.length > 0 ? option : false;
    },

    _escape_html_entities: function(str) {
      // escaping html charachters in input value by native browser escape, but it requeres replacing quotes and double qoutes explicitly
      // return $('<div>').text(str).html().replace(/['"]/g, '&quot;'),
      var esc = {'&':'&amp;', '<':'&lt;', '>':'&gt;', '"':'&quot;', "'":'&#039;'};
      return str.replace( /[&<>'"]/g, function(s) { return esc[s]; } );
    }

  });

  $.fn.ikSelect = function(options){
    //do nothing if opera mini
    if($.browser.operamini){
      return this;
    }

    var args = Array.prototype.slice.call(arguments);

    return this.each(function(){
      if (!$.data(this, "plugin_ikSelect")){
        $.data(this, "plugin_ikSelect", new IkSelect(this, options));
      } else if(typeof options === "string"){
        var ikselect = $.data(this, "plugin_ikSelect");
        switch(options){
          case "reset":               ikselect.reset_all(); break;
          case "hide_dropdown":       ikselect.hide_block(); break;
          case "show_dropdown":       shownOnPurpose = true; ikselect.select.focus(); ikselect.show_block(); break;
          case "add_options":         ikselect.add_options(args[1]); break;
          case "remove_options":      ikselect.remove_options(args[1]); break;
          case "enable":              ikselect.enable_select(); break;
          case "disable":             ikselect.disable_select(); break;
          case "toggle":              ikselect.toggle_select(); break;
          case "select":              ikselect.make_selection(args[1]); break;
          case "set_defaults":        ikselect.set_defaults(args[1]); break;
          case "redraw":              ikselect.redraw(); break;
          case "disable_options":     ikselect.disable_options(args[1]); break;
          case "enable_options":      ikselect.enable_options(args[1]); break;
          case "disable_optgroups":   ikselect.disable_optgroups(args[1]); break;
          case "enable_optgroups":    ikselect.enable_optgroups(args[1]); break;
          case "detach":              ikselect.detach_plugin(); break;
        }
      }
    });
  };

  // singleton instance
  $.ikSelect = new IkSelect();

  // hide fake select list when clicking outside of it
  $(document).bind("click.ikSelect", function(event){
    if(! shownOnPurpose && selectOpened.length && ! $(event.target).parents(".ik_select").length){
      selectOpened.ikSelect("hide_dropdown");
      selectOpened = $([]);
    }
    if(shownOnPurpose){
      shownOnPurpose = false;
    }
  });
})(jQuery, window, document);