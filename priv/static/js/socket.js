var socket = new Phoenix.Socket("/socket", {params: {token: window.userToken}});
socket.connect()
// Now that you are connected, you can join channels with a topic:
var topic = "user:" + window.currentUser
// Join the topic
let channel = socket.channel(topic, {})
channel.join()

  .receive("ok", data => {
    console.log("Joined topic", topic)
  })

  .receive("error", resp => {
    console.log("Unable to join topic", topic)
  })


$(document).ready(function(){

	$("button.item_cat").click(function(){
		var item_cat_id = $(this).attr("id")
		console.log("item category id = "+item_cat_id)
		channel.push("list_items", {item_cat_id: item_cat_id})
	})

	channel.on("populate_table_items", payload => {
		console.log(payload.items)
		var data = payload.items

		$("table#items").DataTable({
			destroy: true,
    	data: data,
    	columns: [
    	{data: 'itemcode'},
    	{data: 'product_code'},
  		{data: 'itemname'},
  		{data: 'itemprice'},
  		{data: 'is_activate'}
    	]
			});
		})


  $("button#sales_transaction").click(function(){
var b_id = $("select#branch_list").val()
var s_date =  $("input[name='start_date']").val()
var e_date =  $("input[name='end_date']").val()
    channel.push("sales_transaction", {user_id: window.currentUser, branch_id: b_id, s_date: s_date, e_date: e_date})
  })

  channel.on("populate_table_sales_transaction", payload => {
    console.log(payload.sales_data)
    var data = payload.sales_data

    $("table#sales_transaction").DataTable({
      destroy: true,
      data: data,
      columns: [
      {data: 'grand_total'},
      {data: 'invoiceno'},
      {data: 'pax'},
      {data: 'payment_type'},
      {data: 'salesdatetime'},
      {data: 'staff_name'},
      {data: 'tbl_no'},
      ]
      });
    })
});

