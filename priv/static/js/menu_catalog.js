$(document).ready(function(){
	$("span[aria-label='badge']").click(function(){
		var price = $(this).html() 
		var id = $(this).attr('id').split("-")
		var menu_catalog_id = id[0]
		var subcat_id = id[1]
		

		menu_catalog_channel.push("open_modal", {menu_catalog_id: menu_catalog_id,user_id: window.currentUser, subcat_id: subcat_id, brand_id: window.currentBrand})
	})

	menu_catalog_channel.on("show_modal", payload => {
		$("#modal_form").html(payload.html);
		$("button#submit_edit_form").click(function(event){
			event.preventDefault();
			var fr = $("form[aria-label='edit_price_form']").serializeArray();

			menu_catalog_channel.push("update_catalog_price",{map: fr,user_id: window.currentUser, brand_id: window.currentBrand})
		})

		$("button#delete_item").click(function(event){
			event.preventDefault();
			var fr = $("form[aria-label='edit_price_form']").serializeArray();

			menu_catalog_channel.push("delete_item",{map: fr,user_id: window.currentUser, brand_id: window.currentBrand})
		})
	})

	menu_catalog_channel.on("deleted_item", payload =>{
		$('#exampleModal').modal('toggle');
		location.reload();
	})

	menu_catalog_channel.on("updated_catalog_price", payload => {
		$('#exampleModal').modal('toggle');
		
		$("span#"+payload.menucat_id+"-"+payload.subcat_id+"[aria-label='badge']").attr("class", "badge badge-"+payload.style)
		$("span#"+payload.menucat_id+"-"+payload.subcat_id+"[aria-label='badge']").html(payload.price)
		$("span#"+payload.menucat_id+"-"+payload.subcat_id+"[aria-label='badge']").attr("id", payload.menucat_id+"-"+payload.new_id	)
	})

	$("a.add_price").click(function(){
		var id = $(this).attr('id').split("-")
		var item_code = id[1]
		var menu_catalog_id = id[0]

		menu_catalog_channel.push("open_add_modal", {item_code: item_code,user_id: window.currentUser, menu_catalog_id: menu_catalog_id, brand_id: window.currentBrand})

	})

	menu_catalog_channel.on("show_add_modal", payload => {
		$("#modal_form2").html(payload.html);
		$("button#submit_add_form").click(function(event){
			event.preventDefault()
			var fr = $("form[aria-label='add_price_form']").serializeArray();
			
			menu_catalog_channel.push("update_added_price",{map: fr,user_id: window.currentUser, brand_id: window.currentBrand})
		})
	})

	menu_catalog_channel.on("updated_added_price", payload => {
		$('#exampleModal2').modal('toggle');
		location.reload();
	})


})