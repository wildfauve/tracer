form = "<%= escape_javascript(render(:partial => 'attr_form' )) %>"
$("#rel-attr-form").hide
$("#rel-attr-form").html(form)
$("#rel-attr-form").slideDown('slow')