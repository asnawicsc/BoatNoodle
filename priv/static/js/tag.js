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

	tag_channel.on("updated_printer", payload => {
    $.notify({
        icon: "notifications",
        message: payload.item_name+" "+payload.action+" "+payload.printer_name

    }, {
        type: payload.alert,
        timer: 100,
        placement: {
            from: 'bottom',
            align: 'right'
        }
    });
	})

})

