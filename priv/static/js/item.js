$(document).ready(function() {

  $("input[name='item_create']").click(function(){
    var fr = $("form[aria-label='item_form']").serializeArray();
    channel3.push("submit_item_form", {map: fr})
  })

  channel3.on("inserted_item_subcat", payload => {
    $("div[aria-label='add_new_item']").fadeOut()
    $("a[href='#menu_item']").click()
    $("div[aria-label='menu_item_content']").fadeIn()
  })

    $("button.item_cat").click(function() {

        $("#backdrop").fadeIn()

        var item_cat_id = $(this).attr("id")
        console.log("item category id = " + item_cat_id)
        channel3.push("list_items", {
            item_cat_id: item_cat_id
        })
    })

    channel3.on("populate_table_items", payload => {
        console.log(payload.items)
        var data = payload.items

        $("table#items").DataTable({
            destroy: true,
            data: data,
            columns: [{
                    data: 'itemcode'
                },
                
                {
                    data: 'itemname'
                },
                
                {
                    data: 'is_activate',
                    render: function(data, type, row, meta){
                      if (data == "1") {
                        var html = '<span class="badge badge-success">Activated</span>'
                      } else {
                        var html = '<span class="badge badge-danger">Deactivated</span>'
                      }
                    return html
                    } 
                }
            ]
        });

        $("#backdrop").delay(500).fadeOut()
    })

});