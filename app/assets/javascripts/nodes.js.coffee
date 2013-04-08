profile = {}
type_node = (node_profile) -> 
	node_form = $.ajax({
		url: '/nodes/node_form',
		data: {node_profile: node_profile }
	})
	node_form.done (data) ->
		return data

$ -> 
	$('.start_node').change ->
		profile["start"] = $('.start_node').val()
	$('.end_node').change ->
		profile["end"] = $('.end_node').val()
	$('.rel_type').change ->
		profile["reltype"] = $('.rel_type').val()
	$('.gen_node_form_button').click ->
		if profile.hasOwnProperty("start") && profile.hasOwnProperty("end") && profile.hasOwnProperty("reltype")
			form = type_node(profile)
		else
			alert 'not all selected yet'