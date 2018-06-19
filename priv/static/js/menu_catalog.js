$(document).ready(function(){
	$("span[aria-label='badge']").click(function(){
		var price = $(this).html() 
		var id = $(this).attr('id').split("-")
		var menu_catalog_id = id[0]
		var subcat_id = id[1]
		

		menu_catalog_channel.push("open_modal", {menu_catalog_id: menu_catalog_id, subcat_id: subcat_id})
	})

	menu_catalog_channel.on("show_modal", payload => {
		$("#modal_form").html(payload.html);
		$("button#submit_edit_form").click(function(event){
			event.preventDefault();
			var fr = $("form[aria-label='edit_price_form']").serializeArray();

			menu_catalog_channel.push("update_catalog_price",{map: fr})
		})
	})

	menu_catalog_channel.on("updated_catalog_price", payload => {
		$('#exampleModal').modal('toggle');
		console.log("span#"+payload.menucat_id+"-"+payload.subcat_id+"[aria-label='badge']")
		$("span#"+payload.menucat_id+"-"+payload.subcat_id+"[aria-label='badge']").attr("class", "badge badge-"+payload.style)
		$("span#"+payload.menucat_id+"-"+payload.subcat_id+"[aria-label='badge']").html(payload.price)
		$("span#"+payload.menucat_id+"-"+payload.subcat_id+"[aria-label='badge']").attr("id", payload.menucat_id+"-"+payload.new_id	)
	})

})