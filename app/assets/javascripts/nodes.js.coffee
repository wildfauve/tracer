profile = {}
type_node = (node_profile) -> 
	node_form = $.ajax({
		url: '/noderelations/node_form',
		data: {node_profile: node_profile }
	})
	node_form.done (data) ->
		return data

node_set_status = (node_name) ->
	$('#node-create-status').append(', ' + node_name)

$ -> 
	if $('div[data-sn]').length != 0
		profile["start"] = {'node': $('div[data-sn]').data().sn}
		node_set_status('Start')
	$('.start_node').change ->
		profile["start"] = {'type': $('.start_node').val()}
		node_set_status('Start')		
	$('.end_node').change ->
		profile["end"] = {'type': $('.end_node').val()}
		node_set_status('End')		
	$('.rel_type').change ->
		profile["reltype"] = $('.rel_type').val()
		node_set_status('Rel')		
	$('.gen_node_form_button').click ->
		if profile.hasOwnProperty("start") && profile.hasOwnProperty("end") && profile.hasOwnProperty("reltype")
			form = type_node(profile)
		else
			alert 'not all selected yet'