$(document).ready(function(){
	

	$('select[name="tag[branch_id]"]').on('hide.bs.select', function (e) {
	var id = $('select[name="tag[branch_id]"]').val()
	  tag_channel.push("query_branch_subcats", {id: id})
	});

	tag_channel.on("show_branch_subcats", payload => {
		var html = payload.html
		$("div#subcat_checkbox").html(html)
	})

	$("input.printer_subcat").click(function(){
		var info = $(this).attr("name")
		tag_channel.push("toggle_printer", {info: info})
	})

})

