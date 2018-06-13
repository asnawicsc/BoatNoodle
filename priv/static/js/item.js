$(document).ready(function() {

 

    $("button.item_cat").click(function() {



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

      
    })


    

});