@profile = {}

@accumulate_node_form = (node_profile) -> 
	node_form = $.ajax({
		url: '/noderelations/accumulate_node_form',
		data: {node_profile: node_profile }
	})
	node_form.done (data) ->
		return data


@type_node = (node_profile) -> 
	node_form = $.ajax({
		url: '/noderelations/node_form',
		data: {node_profile: node_profile }
	})
	node_form.done (data) ->
		return data

@rel_list = (nodetype, position, context) ->
	rel_select = $.ajax({
		url: '/types/' + nodetype + '/type_relations',
		data: { 
			context: context,
			position: position 
		}
	})
	rel_select.done (data) ->
		return data
	

@node_set_status = (node_name) ->
	$('#node-create-status').append(', ' + node_name)

$ -> 
	if $('div[data-sn]').length != 0
		profile["start"] = {'inst': $('div[data-sn]').data().sn}
		node_set_status('Start')
		selects = rel_list($('div[data-sn-type]').data().snType, 'start_node', 'node_type')
		form = accumulate_node_form(profile)		
	$('.start_node').change ->
		profile["start"] = {'type': $('.start_node').val()}
		node_set_status('Start')
		selects = rel_list($('.start_node').val(), 'start_node', 'node_type')
		form = accumulate_node_form(profile)
#	$('.end_node').change ->
#		profile["end"] = {'type': $('.end_node').val()}
#		node_set_status('End')
#		form = accumulate_node_form(profile)		
#	$('.rel_type').change ->
#		alert('rel')
#		profile["reltype"] = $('.rel_type').val()
#		node_set_status('Rel')
#		selects = rel_list($('.rel_type').val(), 'rel')		
#		form = accumulate_node_form(profile)			
	$('.end_node_inst').change ->
		profile["end"] = {'inst': $('.end_node_inst').val()}
		node_set_status('End Inst')	
	$('.start_node_inst').change ->
		profile["start"] = {'inst': $('.start_node_inst').val()}
		node_set_status('Start Inst')
		selects = rel_list($('.start_node_inst').val(), 'start_node', 'node_inst')		
		form = accumulate_node_form(profile)				
	$('#gen_node_form_button').click ->
		if profile.hasOwnProperty("start") && profile.hasOwnProperty("end") && profile.hasOwnProperty("reltype")
			form = type_node(profile)
		else
			alert 'not all selected yet'
	$('.single_node').change ->
		node_form = $.ajax({
			url: '/nodes/node_form',
			data: {node_type: $('.single_node').val() }
		})
		node_form.done (data) ->
			return