var socket = new Phoenix.Socket("/socket", {
    params: {
        token: window.userToken
    }
});
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


$(document).ready(function() {


  $("input[name='previous_category']").click(function(){
    $("div[aria-label='add_new_category']").fadeOut()
    $("div[aria-label='edit_new_category']").fadeOut()
    $("div[aria-label='menu_item_content']").fadeIn()
  })


  $('button[aria-label="edit_category"]').click( function () {
    var table = $("table[aria-label='categories_body']").DataTable()
      
      if ($("table[aria-label='categories_body']").find("tr.selected").length == 1) {
        var rw = $("table[aria-label='categories_body']").find("tr.selected")
        var cat_id = rw.find("td:first").html()
        channel.push("edit_item_category", {cat_id: cat_id})
      }
  });

  channel.on("open_edit_category", payload => {
    
    $("div[aria-label='menu_item_content']").fadeOut()
    $("div[aria-label='edit_new_category']").fadeIn()

    $("input[name='category_update']").attr("id", payload.itemcatid)
    $("form[aria-label='edit_category_form'] input[name='itemcatcode']").val( payload.itemcatcode)
    $("form[aria-label='edit_category_form'] input[name='itemcatname']").val( payload.itemcatname)
    $("form[aria-label='edit_category_form'] input[name='itemcatdesc']").val( payload.itemcatdesc)
    $("form[aria-label='edit_category_form'] .selectpicker").selectpicker('val', payload.category_type);
  })


  $("input[name='category_update']").click(function(){
    var fr = $("form[aria-label='edit_category_form']").serializeArray();
    var cat_id = $("input[name='category_update']").attr("id")
    channel.push("update_category_form", {map: fr, cat_id: cat_id })
  })

  channel.on("updated_item_cat", payload => {

    $("div[aria-label='edit_new_category']").fadeOut()
    $("div[aria-label='menu_item_content']").fadeIn()

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

        $("#backdrop").fadeIn()

        var item_cat_id = $(this).attr("id")
        console.log("item category id = " + item_cat_id)
        channel.push("list_items", {
            item_cat_id: item_cat_id
        })
    })
  });


  $("input[name='item_create']").click(function(){
    var fr = $("form[aria-label='item_form']").serializeArray();
    channel.push("submit_item_form", {map: fr})
  })

  channel.on("inserted_item_subcat", payload => {
    $("div[aria-label='add_new_item']").fadeOut()
    $("a[href='#menu_item']").click()
    $("div[aria-label='menu_item_content']").fadeIn()
  })

  $("input[name='category_create']").click(function(){
    var fr = $("form[aria-label='category_form']").serializeArray();
    channel.push("submit_category_form", {map: fr})
  })

  channel.on("inserted_item_cat", payload => {
    
    $("form[aria-label='category_form'] input[name='itemcatcode']").val("")
    $("form[aria-label='category_form'] input[name='itemcatname']").val("")
    $("form[aria-label='category_form'] input[name='itemcatdesc']").val("")
    $("form[aria-label='category_form'] .selectpicker").selectpicker('val', 'none');
    $("div[aria-label='add_new_category']").fadeOut()
    $("a[href='#menu_categories']").click()
    $("div[aria-label='menu_item_content']").fadeIn()
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
  })

  $("a[href='#menu_categories']").click(function(){
    channel.push("load_all_categories", {user_id: window.currentUser})
  })

  channel.on("dt_show_categories", payload => {

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
      
      if ($("table[aria-label='categories_body']").find("tr.selected").length == 1) {
        var rw = $("table[aria-label='categories_body']").find("tr.selected")
        var cat_id = rw.find("td:first").html()
        channel.push("delete_item_category", {cat_id: cat_id})
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
        table.row('.selected').remove().draw( false );
      }

  });



    $("button#dashboard").click(function() {

        var b_id = $("select#branch_list").val()
        var s_date = $("input[name='start_date']").val()
        var e_date = $("input[name='end_date']").val()
        channel.push("dashboard", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date
        })
    })

    channel.on("populate_dashboard", payload => {

        console.log(payload.grand_total)
        console.log(payload.tax)
        console.log(payload.order)
        console.log(payload.pax)
        console.log(payload.transaction)



        var grand_total = payload.grand_total
        var tax = payload.tax
        var order = payload.order
        var pax = payload.pax
        var transaction = payload.transaction

        $(".huge#dashboard_nett_sales").html(grand_total);
        $(".huge#dashboard_tax").html(tax);
        $(".huge#dashboard_orders").html(order);
        $(".huge#dashboard_pax").html(pax);
        $(".huge#dashboard_transaction").html(transaction);

        console.log(payload.outlet_sales)
        var data = payload.outlet_sales

        $("table#outlet_sales").DataTable({
            destroy: true,
            data: data,
            columns: [{
                    data: 'branchname'
                },
                {
                    data: 'sub_total'
                },
                {
                    data: 'service_charge'
                },
                {
                    data: 'gst_charge'
                },
                {
                    data: 'after_disc'
                },
                {
                    data: 'grand_total'
                },
                {
                    data: 'rounding'
                },
                {
                    data: 'after_disc'
                },
                {
                    data: 'pax'
                }
            ]
        });
    })



    $("button.item_cat").click(function() {

        $("#backdrop").fadeIn()

        var item_cat_id = $(this).attr("id")
        console.log("item category id = " + item_cat_id)
        channel.push("list_items", {
            item_cat_id: item_cat_id
        })
    })

    channel.on("populate_table_items", payload => {
        console.log(payload.items)
        var data = payload.items

        $("table#items").DataTable({
            destroy: true,
            data: data,
            columns: [{
                    data: 'itemcode'
                },
                {
                    data: 'product_code'
                },
                {
                    data: 'itemname'
                },
                {
                    data: 'itemprice'
                },
                {
                    data: 'is_activate'
                }
            ]
        });

        $("#backdrop").delay(500).fadeOut()
    })


    $(".panel-body#sales_transaction").hide();
    $("table#sales_transaction").hide();

    $(".panel-body#hourly_pax_summary").hide();
    $("table#hourly_pax_summary").hide();

    $(".panel-body#hourly_sales_summary").hide();
    $("table#hourly_sales_summary").hide();

    $(".panel-body#hourly_transaction_summary").hide();
    $("table#hourly_transaction_summary").hide();

    $(".panel-body#item_sold").hide();
    $("table#item_sold").hide();

    $(".panel-body#item_sales_detail").hide();
    $("table#item_sales_detail").hide();


    $(".panel-body#discount_receipt").hide();
    $("table#discount_receipt").hide();

    $(".panel-body#discount_summary").hide();
    $("table#discount_summary").hide();

    $(".panel-body#voided_receipt").hide();
    $("table#voided_receipt").hide();

    $(".panel-body#voided_order").hide();
    $("table#voided_order").hide();

    $(".panel-body#morning_sales_summary").hide();
    $("table#morning_sales_summary").hide();

    $(".panel-body#lunch_sales_summary").hide();
    $("table#lunch_sales_summary").hide();


    $(".panel-body#idle_sales_summary").hide();
    $("table#idle_sales_summary").hide();

    $(".panel-body#dinner_sales_summary").hide();
    $("table#dinner_sales_summary").hide();




    $(".nav-link#sales_transaction").click(function() {

        $("#backdrop").fadeIn()

        $(".panel-body#sales_transaction").show();
        $("table#sales_transaction").show();

        $(".panel-body#hourly_pax_summary").hide();
        $("table#hourly_pax_summary").hide();

        $(".panel-body#hourly_sales_summary").hide();
        $("table#hourly_sales_summary").hide();

        $(".panel-body#hourly_transaction_summary").hide();
        $("table#hourly_transaction_summary").hide();

        $(".panel-body#item_sold").hide();
        $("table#item_sold").hide();

        $(".panel-body#item_sales_detail").hide();
        $("table#item_sales_detail").hide();


        $(".panel-body#discount_receipt").hide();
        $("table#discount_receipt").hide();

        $(".panel-body#discount_summary").hide();
        $("table#discount_summary").hide();

        $(".panel-body#voided_receipt").hide();
        $("table#voided_receipt").hide();

        $(".panel-body#voided_order").hide();
        $("table#voided_order").hide();

        $(".panel-body#morning_sales_summary").hide();
        $("table#morning_sales_summary").hide();

        $(".panel-body#lunch_sales_summary").hide();
        $("table#lunch_sales_summary").hide();

        $(".panel-body#idle_sales_summary").hide();
        $("table#idle_sales_summary").hide();

        $(".panel-body#dinner_sales_summary").hide();
        $("table#dinner_sales_summary").hide();

        var b_id = $("select#branch_list").val()
        var s_date = $("input[name='start_date']").val()
        var e_date = $("input[name='end_date']").val()
        channel.push("sales_transaction", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date
        })
    })

    channel.on("populate_table_sales_transaction", payload => {
        console.log(payload.sales_data)
        var data = payload.sales_data

        $("table#sales_transaction").DataTable({
            destroy: true,
            data: data,
            columns: [{
                    data: 'salesdate'
                },
                {
                    data: 'invoiceno'
                },
                {
                    data: 'payment_type'
                },
                {
                    data: 'grand_total'
                },
                {
                    data: 'tbl_no'
                },
                {
                    data: 'pax'
                },
                {
                    data: 'invoiceno',
                    'fnCreatedCell': function(nTd, sData, oData, iRow, iCol) {
                        $(nTd).html("<a href='" + oData.invoiceno + "/detail_invoice'>View Details</a>");
                    }
                },
            ]
        });

        $("#backdrop").delay(500).fadeOut()
    })

    $(".nav-link#hourly_pax_summary").click(function() {

        $("#backdrop").fadeIn()

        $(".panel-body#sales_transaction").hide();
        $("table#sales_transaction").hide();

        $(".panel-body#hourly_pax_summary").show();
        $("table#hourly_pax_summary").show();

        $(".panel-body#hourly_sales_summary").hide();
        $("table#hourly_sales_summary").hide();

        $(".panel-body#hourly_transaction_summary").hide();
        $("table#hourly_transaction_summary").hide();

        $(".panel-body#item_sold").hide();
        $("table#item_sold").hide();

        $(".panel-body#item_sales_detail").hide();
        $("table#item_sales_detail").hide();


        $(".panel-body#discount_receipt").hide();
        $("table#discount_receipt").hide();

        $(".panel-body#discount_summary").hide();
        $("table#discount_summary").hide();

        $(".panel-body#voided_receipt").hide();
        $("table#voided_receipt").hide();

        $(".panel-body#voided_order").hide();
        $("table#voided_order").hide();

        $(".panel-body#morning_sales_summary").hide();
        $("table#morning_sales_summary").hide();

        $(".panel-body#lunch_sales_summary").hide();
        $("table#lunch_sales_summary").hide();

        $(".panel-body#idle_sales_summary").hide();
        $("table#idle_sales_summary").hide();

        $(".panel-body#dinner_sales_summary").hide();
        $("table#dinner_sales_summary").hide();

        var b_id = $("select#branch_list").val()
        var s_date = $("input[name='start_date']").val()
        var e_date = $("input[name='end_date']").val()
        channel.push("hourly_pax_summary", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date
        })
    })

    channel.on("populate_table_hourly_pax_summary", payload => {
        console.log(payload.luck)
        var data = payload.luck

        $("table#hourly_pax_summary").DataTable({
            destroy: true,
            data: data,
            columns: [{
                    data: 'date'
                },
                {
                    data: 'grand_total'
                },
                {
                    data: 'pax'
                },
                {
                    data: 'h24'
                },
                {
                    data: 'h1'
                },
                {
                    data: 'h2'
                },
                {
                    data: 'h3'
                },
                {
                    data: 'h4'
                },
                {
                    data: 'h5'
                },
                {
                    data: 'h6'
                },
                {
                    data: 'h7'
                },
                {
                    data: 'h8'
                },
                {
                    data: 'h9'
                },
                {
                    data: 'h10'
                },
                {
                    data: 'h11'
                },
                {
                    data: 'h12'
                },
                {
                    data: 'h13'
                },
                {
                    data: 'h14'
                },
                {
                    data: 'h15'
                },
                {
                    data: 'h16'
                },
                {
                    data: 'h17'
                },
                {
                    data: 'h18'
                },
                {
                    data: 'h19'
                },
                {
                    data: 'h20'
                },
                {
                    data: 'h21'
                },
                {
                    data: 'h22'
                },
                {
                    data: 'h23'
                },
            ]
        });

        $("#backdrop").delay(500).fadeOut()
    })

    $(".nav-link#hourly_sales_summary").click(function() {

        $("#backdrop").fadeIn()

        $(".panel-body#sales_transaction").hide();
        $("table#sales_transaction").hide();

        $(".panel-body#hourly_pax_summary").hide();
        $("table#hourly_pax_summary").hide();

        $(".panel-body#hourly_sales_summary").show();
        $("table#hourly_sales_summary").show();

        $(".panel-body#hourly_transaction_summary").hide();
        $("table#hourly_transaction_summary").hide();

        $(".panel-body#item_sold").hide();
        $("table#item_sold").hide();

        $(".panel-body#item_sales_detail").hide();
        $("table#item_sales_detail").hide();


        $(".panel-body#discount_receipt").hide();
        $("table#discount_receipt").hide();

        $(".panel-body#discount_summary").hide();
        $("table#discount_summary").hide();

        $(".panel-body#voided_receipt").hide();
        $("table#voided_receipt").hide();

        $(".panel-body#voided_order").hide();
        $("table#voided_order").hide();

        $(".panel-body#morning_sales_summary").hide();
        $("table#morning_sales_summary").hide();

        $(".panel-body#lunch_sales_summary").hide();
        $("table#lunch_sales_summary").hide();

        $(".panel-body#idle_sales_summary").hide();
        $("table#idle_sales_summary").hide();

        $(".panel-body#dinner_sales_summary").hide();
        $("table#dinner_sales_summary").hide();

        var b_id = $("select#branch_list").val()
        var s_date = $("input[name='start_date']").val()
        var e_date = $("input[name='end_date']").val()
        channel.push("hourly_sales_summary", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date
        })
    })

    channel.on("populate_table_hourly_sales_summary", payload => {
        console.log(payload.luck)
        var data = payload.luck

        $("table#hourly_sales_summary").DataTable({
            destroy: true,
            data: data,
            columns: [{
                    data: 'date'
                },
                {
                    data: 'grand_total'
                },
                {
                    data: 'pax'
                },
                {
                    data: 'h24'
                },
                {
                    data: 'h1'
                },
                {
                    data: 'h2'
                },
                {
                    data: 'h3'
                },
                {
                    data: 'h4'
                },
                {
                    data: 'h5'
                },
                {
                    data: 'h6'
                },
                {
                    data: 'h7'
                },
                {
                    data: 'h8'
                },
                {
                    data: 'h9'
                },
                {
                    data: 'h10'
                },
                {
                    data: 'h11'
                },
                {
                    data: 'h12'
                },
                {
                    data: 'h13'
                },
                {
                    data: 'h14'
                },
                {
                    data: 'h15'
                },
                {
                    data: 'h16'
                },
                {
                    data: 'h17'
                },
                {
                    data: 'h18'
                },
                {
                    data: 'h19'
                },
                {
                    data: 'h20'
                },
                {
                    data: 'h21'
                },
                {
                    data: 'h22'
                },
                {
                    data: 'h23'
                },
            ]
        });

        $("#backdrop").delay(500).fadeOut()
    })

    $(".nav-link#hourly_transaction_summary").click(function() {

        $("#backdrop").fadeIn()

        $(".panel-body#sales_transaction").hide();
        $("table#sales_transaction").hide();

        $(".panel-body#hourly_pax_summary").hide();
        $("table#hourly_pax_summary").hide();

        $(".panel-body#hourly_sales_summary").hide();
        $("table#hourly_sales_summary").hide();

        $(".panel-body#hourly_transaction_summary").show();
        $("table#hourly_transaction_summary").show();

        $(".panel-body#item_sold").hide();
        $("table#item_sold").hide();

        $(".panel-body#item_sales_detail").hide();
        $("table#item_sales_detail").hide();


        $(".panel-body#discount_receipt").hide();
        $("table#discount_receipt").hide();

        $(".panel-body#discount_summary").hide();
        $("table#discount_summary").hide();

        $(".panel-body#voided_receipt").hide();
        $("table#voided_receipt").hide();

        $(".panel-body#voided_order").hide();
        $("table#voided_order").hide();

        $(".panel-body#morning_sales_summary").hide();
        $("table#morning_sales_summary").hide();

        $(".panel-body#lunch_sales_summary").hide();
        $("table#lunch_sales_summary").hide();

        $(".panel-body#idle_sales_summary").hide();
        $("table#idle_sales_summary").hide();

        $(".panel-body#dinner_sales_summary").hide();
        $("table#dinner_sales_summary").hide();

        var b_id = $("select#branch_list").val()
        var s_date = $("input[name='start_date']").val()
        var e_date = $("input[name='end_date']").val()
        channel.push("hourly_transaction_summary", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date
        })
    })

    channel.on("populate_table_hourly_transaction_summary", payload => {
        console.log(payload.luck)
        var data = payload.luck

        $("table#hourly_transaction_summary").DataTable({
            destroy: true,
            data: data,
            columns: [{
                    data: 'date'
                },
                {
                    data: 'grand_total'
                },
                {
                    data: 'pax'
                },
                {
                    data: 'h24'
                },
                {
                    data: 'h1'
                },
                {
                    data: 'h2'
                },
                {
                    data: 'h3'
                },
                {
                    data: 'h4'
                },
                {
                    data: 'h5'
                },
                {
                    data: 'h6'
                },
                {
                    data: 'h7'
                },
                {
                    data: 'h8'
                },
                {
                    data: 'h9'
                },
                {
                    data: 'h10'
                },
                {
                    data: 'h11'
                },
                {
                    data: 'h12'
                },
                {
                    data: 'h13'
                },
                {
                    data: 'h14'
                },
                {
                    data: 'h15'
                },
                {
                    data: 'h16'
                },
                {
                    data: 'h17'
                },
                {
                    data: 'h18'
                },
                {
                    data: 'h19'
                },
                {
                    data: 'h20'
                },
                {
                    data: 'h21'
                },
                {
                    data: 'h22'
                },
                {
                    data: 'h23'
                },
            ]
        });

        $("#backdrop").delay(500).fadeOut()
    })

    $(".nav-link#item_sold").click(function() {

        $("#backdrop").fadeIn()

        $(".panel-body#sales_transaction").hide();
        $("table#sales_transaction").hide();

        $(".panel-body#hourly_pax_summary").hide();
        $("table#hourly_pax_summary").hide();

        $(".panel-body#hourly_sales_summary").hide();
        $("table#hourly_sales_summary").hide();

        $(".panel-body#hourly_transaction_summary").hide();
        $("table#hourly_transaction_summary").hide();

        $(".panel-body#item_sold").show();
        $("table#item_sold").show();

        $(".panel-body#item_sales_detail").hide();
        $("table#item_sales_detail").hide();

        $(".panel-body#discount_receipt").hide();
        $("table#discount_receipt").hide();

        $(".panel-body#discount_summary").hide();
        $("table#discount_summary").hide();

        $(".panel-body#voided_receipt").hide();
        $("table#voided_receipt").hide();

        $(".panel-body#voided_order").hide();
        $("table#voided_order").hide();

        $(".panel-body#morning_sales_summary").hide();
        $("table#morning_sales_summary").hide();

        $(".panel-body#lunch_sales_summary").hide();
        $("table#lunch_sales_summary").hide();

        $(".panel-body#idle_sales_summary").hide();
        $("table#idle_sales_summary").hide();

        $(".panel-body#dinner_sales_summary").hide();
        $("table#dinner_sales_summary").hide();


        var b_id = $("select#branch_list").val()
        var s_date = $("input[name='start_date']").val()
        var e_date = $("input[name='end_date']").val()
        channel.push("item_sold", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date
        })
    })

    channel.on("populate_table_item_sold", payload => {
        console.log(payload.item_sold_data)
        var data = payload.item_sold_data

        $("table#item_sold").DataTable({
            destroy: true,
            data: data,
            columns: [{
                    data: 'itemname'
                },
                {
                    data: 'qty'
                },
                {
                    data: 'afterdisc'
                },
                {
                    data: 'itemcatname'
                }
            ]
        });

        $("#backdrop").delay(500).fadeOut()
    })

    $(".nav-link#item_sales_detail").click(function() {

        $("#backdrop").fadeIn()


        $(".panel-body#sales_transaction").hide();
        $("table#sales_transaction").hide();

        $(".panel-body#hourly_pax_summary").hide();
        $("table#hourly_pax_summary").hide();

        $(".panel-body#hourly_sales_summary").hide();
        $("table#hourly_sales_summary").hide();

        $(".panel-body#hourly_transaction_summary").hide();
        $("table#hourly_transaction_summary").hide();

        $(".panel-body#item_sold").hide();
        $("table#item_sold").hide();

        $(".panel-body#item_sales_detail").show();
        $("table#item_sales_detail").show();

        $(".panel-body#discount_receipt").hide();
        $("table#discount_receipt").hide();

        $(".panel-body#discount_summary").hide();
        $("table#discount_summary").hide();

        $(".panel-body#voided_receipt").hide();
        $("table#voided_receipt").hide();

        $(".panel-body#voided_order").hide();
        $("table#voided_order").hide();

        $(".panel-body#morning_sales_summary").hide();
        $("table#morning_sales_summary").hide();

        $(".panel-body#lunch_sales_summary").hide();
        $("table#lunch_sales_summary").hide();

        $(".panel-body#idle_sales_summary").hide();
        $("table#idle_sales_summary").hide();

        $(".panel-body#dinner_sales_summary").hide();
        $("table#dinner_sales_summary").hide();




        var b_id = $("select#branch_list").val()
        var s_date = $("input[name='start_date']").val()
        var e_date = $("input[name='end_date']").val()
        channel.push("item_sales_detail", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date
        })
    })

    channel.on("populate_table_item_sales_detail", payload => {
        console.log(payload.item_sales_detail_data)
        var data = payload.item_sales_detail_data

        $("table#item_sales_detail").DataTable({
            destroy: true,
            data: data,
            columns: [{
                    data: 'itemcatcode'
                },
                {
                    data: 'itemname'
                },
                {
                    data: 'qty'
                },
                {
                    data: 'invoiceno'
                },
                {
                    data: 'tbl_no'
                },
                {
                    data: 'staff_name'
                },
                {
                    data: 'afterdisc'
                },
                {
                    data: 'salesdate'
                }
            ]
        });

        $("#backdrop").delay(500).fadeOut()
    })

    $(".nav-link#discount_receipt").click(function() {

        $("#backdrop").fadeIn()


        $(".panel-body#sales_transaction").hide();
        $("table#sales_transaction").hide();

        $(".panel-body#hourly_pax_summary").hide();
        $("table#hourly_pax_summary").hide();

        $(".panel-body#hourly_sales_summary").hide();
        $("table#hourly_sales_summary").hide();

        $(".panel-body#hourly_transaction_summary").hide();
        $("table#hourly_transaction_summary").hide();

        $(".panel-body#item_sold").hide();
        $("table#item_sold").hide();

        $(".panel-body#item_sales_detail").hide();
        $("table#item_sales_detail").hide();

        $(".panel-body#discount_receipt").show();
        $("table#discount_receipt").show();

        $(".panel-body#discount_summary").hide();
        $("table#hourly_pax_summary").hide();

        $(".panel-body#voided_receipt").hide();
        $("table#voided_receipt").hide();

        $(".panel-body#voided_order").hide();
        $("table#voided_order").hide();

        $(".panel-body#morning_sales_summary").hide();
        $("table#morning_sales_summary").hide();

        $(".panel-body#lunch_sales_summary").hide();
        $("table#lunch_sales_summary").hide();

        $(".panel-body#idle_sales_summary").hide();
        $("table#idle_sales_summary").hide();

        $(".panel-body#dinner_sales_summary").hide();
        $("table#dinner_sales_summary").hide();


        var b_id = $("select#branch_list").val()
        var s_date = $("input[name='start_date']").val()
        var e_date = $("input[name='end_date']").val()
        channel.push("discount_receipt", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date
        })
    })

    channel.on("populate_table_discount_receipt", payload => {
        console.log(payload.discount_receipt_data)
        var data = payload.discount_receipt_data

        $("table#discount_receipt").DataTable({
            destroy: true,
            data: data,
            columns: [{
                    data: 'salesdate'
                },
                {
                    data: 'invoiceno'
                },
                {
                    data: 'after_disc'
                },
                {
                    data: 'discitemsname'
                },
                {
                    data: 'invoiceno'
                }
            ]
        });

        $("#backdrop").delay(500).fadeOut()
    })

    $(".nav-link#discount_summary").click(function() {

        $("#backdrop").fadeIn()

        $(".panel-body#sales_transaction").hide();
        $("table#sales_transaction").hide();

        $(".panel-body#hourly_pax_summary").hide();
        $("table#hourly_pax_summary").hide();

        $(".panel-body#hourly_sales_summary").hide();
        $("table#hourly_sales_summary").hide();

        $(".panel-body#hourly_transaction_summary").hide();
        $("table#hourly_transaction_summary").hide();

        $(".panel-body#item_sold").hide();
        $("table#item_sold").hide();

        $(".panel-body#item_sales_detail").hide();
        $("table#item_sales_detail").hide();

        $(".panel-body#discount_receipt").hide();
        $("table#discount_receipt").hide();

        $(".panel-body#discount_summary").show();
        $("table#discount_summary").show();

        $(".panel-body#voided_receipt").hide();
        $("table#voided_receipt").hide();

        $(".panel-body#voided_order").hide();
        $("table#voided_order").hide();

        $(".panel-body#morning_sales_summary").hide();
        $("table#morning_sales_summary").hide();

        $(".panel-body#lunch_sales_summary").hide();
        $("table#lunch_sales_summary").hide();

        $(".panel-body#idle_sales_summary").hide();
        $("table#idle_sales_summary").hide();

        $(".panel-body#dinner_sales_summary").hide();
        $("table#dinner_sales_summary").hide();



        var b_id = $("select#branch_list").val()
        var s_date = $("input[name='start_date']").val()
        var e_date = $("input[name='end_date']").val()
        channel.push("discount_summary", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date
        })
    })

    channel.on("populate_table_discount_summary", payload => {
        console.log(payload.discount_summary_data)
        var data = payload.discount_summary_data

        $("table#discount_summary").DataTable({
            destroy: true,
            data: data,
            columns: [{
                    data: 'discname'
                },
                {
                    data: 'total'
                },
                {
                    data: 'after_disc'
                }
            ]
        });

        $("#backdrop").delay(500).fadeOut()
    })

    $(".nav-link#voided_receipt").click(function() {

        $("#backdrop").fadeIn()

        $(".panel-body#sales_transaction").hide();
        $("table#sales_transaction").hide();

        $(".panel-body#hourly_pax_summary").hide();
        $("table#hourly_pax_summary").hide();

        $(".panel-body#hourly_sales_summary").hide();
        $("table#hourly_sales_summary").hide();

        $(".panel-body#hourly_transaction_summary").hide();
        $("table#hourly_transaction_summary").hide();

        $(".panel-body#item_sold").hide();
        $("table#item_sold").hide();

        $(".panel-body#item_sales_detail").hide();
        $("table#item_sales_detail").hide();


        $(".panel-body#discount_receipt").hide();
        $("table#discount_receipt").hide();

        $(".panel-body#discount_summary").hide();
        $("table#discount_summary").hide();

        $(".panel-body#voided_receipt").show();
        $("table#voided_receipt").show();

        $(".panel-body#voided_order").hide();
        $("table#voided_order").hide();

        $(".panel-body#morning_sales_summary").hide();
        $("table#morning_sales_summary").hide();

        $(".panel-body#lunch_sales_summary").hide();
        $("table#lunch_sales_summary").hide();

        $(".panel-body#idle_sales_summary").hide();
        $("table#idle_sales_summary").hide();

        $(".panel-body#dinner_sales_summary").hide();
        $("table#dinner_sales_summary").hide();

        var b_id = $("select#branch_list").val()
        var s_date = $("input[name='start_date']").val()
        var e_date = $("input[name='end_date']").val()
        channel.push("voided_receipt", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date
        })
    })

    channel.on("populate_table_voided_receipt_data", payload => {
        console.log(payload.voided_receipt_data)
        var data = payload.voided_receipt_data

        $("table#voided_receipt").DataTable({
            destroy: true,
            data: data,
            columns: [{
                    data: 'salesdate'
                },
                {
                    data: 'invoiceno'
                },
                {
                    data: 'total'
                },
                {
                    data: 'table'
                },
                {
                    data: 'pax'
                },
                {
                    data: 'staff'
                }
            ]
        });

        $("#backdrop").delay(500).fadeOut()
    })

    $(".nav-link#voided_order").click(function() {

        $("#backdrop").fadeIn()

        $(".panel-body#sales_transaction").hide();
        $("table#sales_transaction").hide();

        $(".panel-body#hourly_pax_summary").hide();
        $("table#hourly_pax_summary").hide();

        $(".panel-body#hourly_sales_summary").hide();
        $("table#hourly_sales_summary").hide();

        $(".panel-body#hourly_transaction_summary").hide();
        $("table#hourly_transaction_summary").hide();

        $(".panel-body#item_sold").hide();
        $("table#item_sold").hide();

        $(".panel-body#item_sales_detail").hide();
        $("table#item_sales_detail").hide();


        $(".panel-body#discount_receipt").hide();
        $("table#discount_receipt").hide();

        $(".panel-body#discount_summary").hide();
        $("table#discount_summary").hide();

        $(".panel-body#voided_receipt").hide();
        $("table#voided_receipt").hide();

        $(".panel-body#voided_order").show();
        $("table#voided_order").show();

        $(".panel-body#morning_sales_summary").hide();
        $("table#morning_sales_summary").hide();

        $(".panel-body#lunch_sales_summary").hide();
        $("table#lunch_sales_summary").hide();

        $(".panel-body#idle_sales_summary").hide();
        $("table#idle_sales_summary").hide();

        $(".panel-body#dinner_sales_summary").hide();
        $("table#dinner_sales_summary").hide();

        var b_id = $("select#branch_list").val()
        var s_date = $("input[name='start_date']").val()
        var e_date = $("input[name='end_date']").val()
        channel.push("voided_order", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date
        })
    })

    channel.on("populate_table_voided_order_data", payload => {
        console.log(payload.voided_order_data)
        var data = payload.voided_order_data

        $("table#voided_order").DataTable({
            destroy: true,
            data: data,
            columns: [{
                    data: 'salesdate'
                },
                {
                    data: 'itemname'
                },
                {
                    data: 'unit_price'
                },
                {
                    data: 'quantity'
                },
                {
                    data: 'totalprice'
                },
                {
                    data: 'staff'
                }
            ]
        });

        $("#backdrop").delay(500).fadeOut()
    })

    $(".nav-link#morning_sales_summary").click(function() {

        $("#backdrop").fadeIn()

        $(".panel-body#sales_transaction").hide();
        $("table#sales_transaction").hide();

        $(".panel-body#hourly_pax_summary").hide();
        $("table#hourly_pax_summary").hide();

        $(".panel-body#hourly_sales_summary").hide();
        $("table#hourly_sales_summary").hide();

        $(".panel-body#hourly_transaction_summary").hide();
        $("table#hourly_transaction_summary").hide();

        $(".panel-body#item_sold").hide();
        $("table#item_sold").hide();

        $(".panel-body#item_sales_detail").hide();
        $("table#item_sales_detail").hide();


        $(".panel-body#discount_receipt").hide();
        $("table#discount_receipt").hide();

        $(".panel-body#discount_summary").hide();
        $("table#discount_summary").hide();

        $(".panel-body#voided_receipt").hide();
        $("table#voided_receipt").hide();

        $(".panel-body#voided_order").hide();
        $("table#voided_order").hide();

        $(".panel-body#morning_sales_summary").show();
        $("table#morning_sales_summary").show();


        $(".panel-body#lunch_sales_summary").hide();
        $("table#lunch_sales_summary").hide();

        $(".panel-body#idle_sales_summary").hide();
        $("table#idle_sales_summary").hide();

        $(".panel-body#dinner_sales_summary").hide();
        $("table#dinner_sales_summary").hide();

        var b_id = $("select#branch_list").val()
        var s_date = $("input[name='start_date']").val()
        var e_date = $("input[name='end_date']").val()
        channel.push("morning_sales_summary", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date
        })
    })

    channel.on("populate_table_morning_sales_summary_data", payload => {
        console.log(payload.morning_sales_summary)
        var data = payload.morning_sales_summary

        var total_pax = payload.total_pax
        var total_sales = payload.total_sales

        $(".morning#total_pax").html(total_pax);

        $(".morning#total_sales").html(total_sales);

        $("table#morning_sales_summary").DataTable({
            destroy: true,
            data: data,
            columns: [{
                    data: 'branchname'
                },
                {
                    data: 'pax'
                },
                {
                    data: 'totalprice'
                },
                {
                    data: 'type'
                },
                {
                    data: 'salesdatetime'
                }
            ]
        });

        $("#backdrop").delay(500).fadeOut()
    })

    $(".nav-link#lunch_sales_summary").click(function() {

        $("#backdrop").fadeIn()

        $(".panel-body#sales_transaction").hide();
        $("table#sales_transaction").hide();

        $(".panel-body#hourly_pax_summary").hide();
        $("table#hourly_pax_summary").hide();

        $(".panel-body#hourly_sales_summary").hide();
        $("table#hourly_sales_summary").hide();

        $(".panel-body#hourly_transaction_summary").hide();
        $("table#hourly_transaction_summary").hide();

        $(".panel-body#item_sold").hide();
        $("table#item_sold").hide();

        $(".panel-body#item_sales_detail").hide();
        $("table#item_sales_detail").hide();


        $(".panel-body#discount_receipt").hide();
        $("table#discount_receipt").hide();

        $(".panel-body#discount_summary").hide();
        $("table#discount_summary").hide();

        $(".panel-body#voided_receipt").hide();
        $("table#voided_receipt").hide();

        $(".panel-body#voided_order").hide();
        $("table#voided_order").hide();

        $(".panel-body#morning_sales_summary").hide();
        $("table#morning_sales_summary").hide();

        $(".panel-body#lunch_sales_summary").show();
        $("table#lunch_sales_summary").show();

        $(".panel-body#idle_sales_summary").hide();
        $("table#idle_sales_summary").hide();

        $(".panel-body#dinner_sales_summary").hide();
        $("table#dinner_sales_summary").hide();

        var b_id = $("select#branch_list").val()
        var s_date = $("input[name='start_date']").val()
        var e_date = $("input[name='end_date']").val()
        channel.push("lunch_sales_summary", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date
        })
    })

    channel.on("populate_table_lunch_sales_summary_data", payload => {
        console.log(payload.lunch_sales_summary)
        var data = payload.lunch_sales_summary

        var total_pax = payload.total_pax
        var total_sales = payload.total_sales

        $(".lunch#total_pax").html(total_pax);

        $(".lunch#total_sales").html(total_sales);

        $("table#lunch_sales_summary").DataTable({
            destroy: true,
            data: data,
            columns: [{
                    data: 'branchname'
                },
                {
                    data: 'pax'
                },
                {
                    data: 'totalprice'
                },
                {
                    data: 'type'
                },
                {
                    data: 'salesdate'
                }
            ]
        });

        $("#backdrop").delay(500).fadeOut()
    })


    $(".nav-link#idle_sales_summary").click(function() {

        $("#backdrop").fadeIn()

        $(".panel-body#sales_transaction").hide();
        $("table#sales_transaction").hide();

        $(".panel-body#hourly_pax_summary").hide();
        $("table#hourly_pax_summary").hide();

        $(".panel-body#hourly_sales_summary").hide();
        $("table#hourly_sales_summary").hide();

        $(".panel-body#hourly_transaction_summary").hide();
        $("table#hourly_transaction_summary").hide();

        $(".panel-body#item_sold").hide();
        $("table#item_sold").hide();

        $(".panel-body#item_sales_detail").hide();
        $("table#item_sales_detail").hide();


        $(".panel-body#discount_receipt").hide();
        $("table#discount_receipt").hide();

        $(".panel-body#discount_summary").hide();
        $("table#discount_summary").hide();

        $(".panel-body#voided_receipt").hide();
        $("table#voided_receipt").hide();

        $(".panel-body#voided_order").hide();
        $("table#voided_order").hide();

        $(".panel-body#morning_sales_summary").hide();
        $("table#morning_sales_summary").hide();

        $(".panel-body#lunch_sales_summary").hide();
        $("table#lunch_sales_summary").hide();

        $(".panel-body#idle_sales_summary").show();
        $("table#idle_sales_summary").show();

        $(".panel-body#dinner_sales_summary").hide();
        $("table#dinner_sales_summary").hide();

        var b_id = $("select#branch_list").val()
        var s_date = $("input[name='start_date']").val()
        var e_date = $("input[name='end_date']").val()
        channel.push("idle_sales_summary", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date
        })
    })

    channel.on("populate_table_idle_sales_summary_data", payload => {
        console.log(payload.idle_sales_summary)
        var data = payload.idle_sales_summary

        var total_pax = payload.total_pax
        var total_sales = payload.total_sales

        $(".idle#total_pax").html(total_pax);

        $(".idle#total_sales").html(total_sales);

        $("table#idle_sales_summary").DataTable({
            destroy: true,
            data: data,
            columns: [{
                    data: 'branchname'
                },
                {
                    data: 'pax'
                },
                {
                    data: 'totalprice'
                },
                {
                    data: 'type'
                },
                {
                    data: 'salesdate'
                }
            ]
        });

        $("#backdrop").delay(500).fadeOut()
    })


    $(".nav-link#dinner_sales_summary").click(function() {

        $("#backdrop").fadeIn()

        $(".panel-body#sales_transaction").hide();
        $("table#sales_transaction").hide();

        $(".panel-body#hourly_pax_summary").hide();
        $("table#hourly_pax_summary").hide();

        $(".panel-body#hourly_sales_summary").hide();
        $("table#hourly_sales_summary").hide();

        $(".panel-body#hourly_transaction_summary").hide();
        $("table#hourly_transaction_summary").hide();

        $(".panel-body#item_sold").hide();
        $("table#item_sold").hide();

        $(".panel-body#item_sales_detail").hide();
        $("table#item_sales_detail").hide();


        $(".panel-body#discount_receipt").hide();
        $("table#discount_receipt").hide();

        $(".panel-body#discount_summary").hide();
        $("table#discount_summary").hide();

        $(".panel-body#voided_receipt").hide();
        $("table#voided_receipt").hide();

        $(".panel-body#voided_order").hide();
        $("table#voided_order").hide();

        $(".panel-body#morning_sales_summary").hide();
        $("table#morning_sales_summary").hide();

        $(".panel-body#lunch_sales_summary").hide();
        $("table#lunch_sales_summary").hide();

        $(".panel-body#idle_sales_summary").hide();
        $("table#idle_sales_summary").hide();

        $(".panel-body#dinner_sales_summary").show();
        $("table#dinner_sales_summary").show();

        var b_id = $("select#branch_list").val()
        var s_date = $("input[name='start_date']").val()
        var e_date = $("input[name='end_date']").val()
        channel.push("dinner_sales_summary", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date
        })
    })

    channel.on("populate_table_dinner_sales_summary_data", payload => {
        console.log(payload.dinner_sales_summary)
        var data = payload.dinner_sales_summary

        var total_pax = payload.total_pax
        var total_sales = payload.total_sales

        $(".dinner#total_pax").html(total_pax);

        $(".dinner#total_sales").html(total_sales);

        $("table#dinner_sales_summary").DataTable({
            destroy: true,
            data: data,
            columns: [{
                    data: 'branchname'
                },
                {
                    data: 'pax'
                },
                {
                    data: 'totalprice'
                },
                {
                    data: 'type'
                },
                {
                    data: 'salesdate'
                }
            ]
        });

        $("#backdrop").delay(500).fadeOut()
    })




    $("button#tax").click(function() {

        $("#backdrop").fadeIn()

        var b_id = $("select#branch_list").val()
        var s_date = $("input[name='start_date']").val()
        var e_date = $("input[name='end_date']").val()
        channel.push("tax", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date
        })
    })

    channel.on("populate_tax_data", payload => {

        console.log(payload.tax_data)
        console.log(payload.tax_total)




        var tax = payload.tax_data
        var tax_total = payload.tax_total


        var all = parseFloat(tax_total) - parseFloat(tax)



        $(".tax#tax_data").html(tax);

        $(".tax#total_tax").html(all.toFixed(2));

        console.log(payload.tax_details)
        var data = payload.tax_details

        $("table#tax_details").DataTable({
            destroy: true,
            data: data,
            columns: [{
                    data: 'salesdatetime'
                },
                {
                    data: 'invoiceno'
                },
                {
                    data: 'tax'
                },
                {
                    data: 'after_disc'
                }
            ]
        });

        $("#backdrop").delay(500).fadeOut()


        Highcharts.chart("monthly_tax", {

            title: {
                text: 'Tax Report'
            },

            subtitle: {
                text: 'Tax and Sales before Tax'
            },

            yAxis: {
                title: {
                    text: 'Values'
                }
            },
            legend: {
                layout: 'horizontal',
                align: 'center',
                verticalAlign: 'bottom'
            },

            plotOptions: {
                series: {
                    label: {
                        connectorAllowed: false
                    },
                    pointStart: ['dates', ]
                }
            },
            series: [{
                name: 'Tax',
                data: ['<%=cash_in_graph%>', ]
            }, {
                name: 'Amount after Tax',
                data: ['<%=cash_out_graph%>', ]
            }],

            responsive: {
                rules: [{
                    condition: {
                        maxWidth: 500
                    },
                    chartOptions: {
                        legend: {
                            layout: 'horizontal',
                            align: 'center',
                            verticalAlign: 'bottom'
                        }
                    }
                }]
            }

        });
    })


    $("button#payment_type").click(function() {

        $("#backdrop").fadeIn()

        var b_id = $("select#branch_list").val()
        var s_date = $("input[name='start_date']").val()
        var e_date = $("input[name='end_date']").val()
        channel.push("payment_type", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date
        })
    })

    channel.on("populate_payment", payload => {

        console.log(payload.payment_type_cash)
        console.log(payload.payment_type_others)

        var cash = payload.payment_type_cash
        var card = payload.payment_type_others


        $(".payment#payment_type1").html(cash);

        $(".payment#payment_type2").html(card);

        console.log(payload.payment)
        var data = payload.payment

        $("table#payment_type").DataTable({
            destroy: true,
            data: data,
            columns: [{
                    data: 'payment_type'
                },
                {
                    data: 'total'
                }
            ]
        });

        $("#backdrop").delay(500).fadeOut()
    })


    $("button#cash_in_out").click(function() {

        $("#backdrop").fadeIn()

        var b_id = $("select#branch_list").val()
        var s_date = $("input[name='start_date']").val()
        var e_date = $("input[name='end_date']").val()
        channel.push("cash_in_out", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date
        })
    })

    channel.on("populate_cash_in_out", payload => {

        console.log(payload.cash_in)
        console.log(payload.cash_out)

        var cash_in = payload.cash_in
        var cash_out = payload.cash_out


        $(".cash#cash_in").html(cash_in);

        $(".cash#cash_out").html(cash_out);

        console.log(payload.cash)
        var data = payload.cash

        $("table#cash_in_out").DataTable({
            destroy: true,
            data: data,
            columns: [{
                    data: 'branchname'
                },
                {
                    data: 'amount'
                },
                {
                    data: 'cashtype'
                },
                {
                    data: 'open'
                }
            ]
        });

        $("#backdrop").delay(500).fadeOut()
    })


});