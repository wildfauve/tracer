<% if @position == "start_node" %>
  rel_select = "<%= escape_javascript(render(:partial => 'noderelations/node_rel_sel')) %>"
  $('#node_rel_select').append(rel_select)
  $('.rel_type').change ->
    selects = rel_list($('.rel_type').val(), 'rel', 'rel_type')
    profile["reltype"] = $('.rel_type').val()   
    form = accumulate_node_form(profile)
<% else %>
  end_select = "<%= escape_javascript(render(:partial => 'noderelations/node_end_sel')) %>"
  $('#node_end_select').append(end_select)
  $('.end_node').change ->
    profile["end"] = {'type': $('.end_node').val()}
    form = accumulate_node_form(profile)    
  $('.end_node_instance').change ->
    profile["end"] = {'inst': $('.end_node_instance').val()}
    form = accumulate_node_form(profile)        
<% end %> 
