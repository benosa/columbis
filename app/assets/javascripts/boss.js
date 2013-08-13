//= require highcharts
//= require highcharts/modules/funnel
//= require widgets
//= require_tree ./boss
$(function(){
  $('a#filter_reset').on('click', function(){
    reset_select_filters('period', 'month');
    reset_select_filters('margin_types', 'profit_acc');
  });
});

function reset_select_filters(id, value) {
    $('#'+ id).attr('data-default', value);
    // set default options
    $('#'+ id +' option').removeAttr('selected');
    $('#'+ id +' option[value = '+ value +']').attr('selected', 'selected');
    var name = $('#' + id + ' option[value = '+ value +']').text();
    $('#'+ id).parent().find('ul li').removeClass('ik_select_hover ik_select_active');
    $('#'+ id).parent().find('ul li span[title = '+ value +']').parent().addClass('ik_select_hover ik_select_active');
    $('#'+ id).parent().find('span.ik_select_link_text').text(name);
};