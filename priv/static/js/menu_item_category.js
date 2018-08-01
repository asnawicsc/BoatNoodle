$(document).ready(function() {

  $("input[name='previous_category']").click(function(){
    $("div[aria-label='add_new_category']").hide()
    $("div[aria-label='edit_new_category']").hide()
    $("div[aria-label='menu_item_content']").show()
  })


  $('button[aria-label="edit_category"]').click( function () {
    var table = $("table[aria-label='categories_body']").DataTable()
      
      if ($("table[aria-label='categories_body']").find("tr.selected").length == 1) {
        var rw = $("table[aria-label='categories_body']").find("tr.selected")
        var cat_id = rw.find("td:first").html()
        channel2.push("edit_item_category", {cat_id: cat_id})
      }
  });

  channel2.on("open_edit_category", payload => {
    
    $("div[aria-label='menu_item_content']").hide()
    $("div[aria-label='edit_new_category']").show()

    $("input[name='category_update']").attr("id", payload.itemcatid)
    $("form[aria-label='edit_category_form'] input[name='itemcatcode']").val( payload.itemcatcode)
    $("form[aria-label='edit_category_form'] input[name='itemcatname']").val( payload.itemcatname)
    $("form[aria-label='edit_category_form'] input[name='itemcatdesc']").val( payload.itemcatdesc)
    $("form[aria-label='edit_category_form'] .selectpicker").selectpicker('val', payload.category_type);

    $("form[aria-label='edit_category_form'] input[name='itemcatcode']").focus()
  })


  $("input[name='category_update']").click(function(){
    var fr = $("form[aria-label='edit_category_form']").serializeArray();
    var cat_id = $("input[name='category_update']").attr("id")
    channel2.push("update_category_form", {map: fr,user_id: window.currentUser, cat_id: cat_id, brand_id: window.currentBrand })
  })

  channel2.on("updated_item_cat", payload => {

    $("div[aria-label='edit_new_category']").hide()
    $("div[aria-label='menu_item_content']").show()

    $("form[aria-label='edit_category_form'] input[name='itemcatcode']").val("")
    $("form[aria-label='edit_category_form'] input[name='itemcatname']").val("")
    $("form[aria-label='edit_category_form'] input[name='itemcatdesc']").val("")
    $("form[aria-label='edit_category_form'] .selectpicker").selectpicker('val', 'none');

    var data = payload.categories
    var table = $("table[aria-label='categories_body']").DataTable({
      ordering: true,  // Column ordering
      order: [0, 'desc'],
      destroy: true,
      data: data,
      columns: [
      {data: 'itemcatid'},
      {data: 'itemcatname'},
      {data: 'itemcatcode'},
      {data: 'itemcatdesc'},
      {data: 'category_type'},
      {data: 'is_default'},
      ]
    }); 

    $.notify({
        icon: "notifications",
        message: "Category updated!"

    }, {
        type: 'success',
        timer: 100,
        placement: {
            from: 'bottom',
            align: 'right'
        }
    });

    $("div#category_sidebar").html(payload.html)

    $("button.item_cat").click(function() {

        $("#backdrop").show()

        var item_cat_id = $(this).attr("id")
        console.log("item category id = " + item_cat_id)
        channel2.push("list_items", {
            item_cat_id: item_cat_id
        })
    })
  });



  $("input[name='category_create']").click(function(){
    var fr = $("form[aria-label='category_form']").serializeArray();
    channel2.push("submit_category_form", {map: fr,user_id: window.currentUser,brand_id: window.currentBrand})
  })

  channel2.on("inserted_item_cat", payload => {
    
    $("form[aria-label='category_form'] input[name='itemcatcode']").val("")
    $("form[aria-label='category_form'] input[name='itemcatname']").val("")
    $("form[aria-label='category_form'] input[name='itemcatdesc']").val("")
    $("form[aria-label='category_form'] .selectpicker").selectpicker('val', 'none');
    $("div[aria-label='add_new_category']").hide()
    $("a[href='#menu_categories']").click()
    $("div[aria-label='menu_item_content']").show()
          $.notify({
              icon: "notifications",
              message: "Category created!"

          }, {
              type: 'rose',
              timer: 100,
              placement: {
                  from: 'bottom',
                  align: 'right'
              }
          });

    $("div#category_sidebar").html(payload.html)

    $("button.item_cat").click(function() {

    

        var item_cat_id = $(this).attr("id")
        console.log("item category id = " + item_cat_id)
        channel2.push("list_items", {
            item_cat_id: item_cat_id, brand_id: window.currentBrand
        })
    })
  })

  $("a[href='#menu_categories']").click(function(){
    channel2.push("load_all_categories", {user_id: window.currentUser, brand_id: window.currentBrand})
  })

  channel2.on("dt_show_categories", payload => {

    var data = payload.categories
    var table = $("table[aria-label='categories_body']").DataTable({
      ordering: true,  // Column ordering
      order: [0, 'desc'],
      destroy: true,
      data: data,
      columns: [
      {data: 'itemcatid'},
      {data: 'itemcatname'},
      {data: 'itemcatcode'},
      {data: 'itemcatdesc'},
      {data: 'category_type'},
      {data: 'is_default'},
      ]
    }); 
  });


  $("table[aria-label='categories_body']").on( "click", "tr", function () {
    var table = $("table[aria-label='categories_body']").DataTable()
      if ( $(this).hasClass("selected") ) {
          $(this).removeClass("selected");

      }
      else {
          table.$("tr.selected").removeClass("selected");
          $(this).addClass("selected");
          console.log($(this).find("td:first").html())

      }
  });


  $('button[aria-label="delete_category"]').click( function () {
    var table = $("table[aria-label='categories_body']").DataTable()
      
      if ($("table[aria-label='categories_body']").find("tr.selected").length == 1)
       {

        var rw = $("table[aria-label='categories_body']").find("tr.selected")
        var map = rw.html()
        var cat_id = rw.find("td:first").html()
        channel2.push("delete_item_category", {user_id: window.currentUser,map: map,cat_id: cat_id})

        table.row('.selected').remove().draw( false );
      }

  });


  channel2.on("deleted_category", payload => {
    $.notify({
        icon: "notifications",
        message: "Category removed."

    }, {
        type: 'danger',
        timer: 100,
        placement: {
            from: 'bottom',
            align: 'right'
        }
    });
    $("div#category_sidebar").html(payload.html)

    $("button.item_cat").click(function() {

 

        var item_cat_id = $(this).attr("id")
        console.log("item category id = " + item_cat_id)
        channel2.push("list_items", {
            item_cat_id: item_cat_id
        })
    })

  })


    channel2.on("populate_table_items", payload => {
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