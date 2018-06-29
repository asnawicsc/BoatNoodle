$(document).ready(function() {

    var start = moment().subtract(29, 'days');
    var end = moment();

      function cb(start, end) {
          $('#reportrange span').html(start.format('MMMM D, YYYY') + ' - ' + end.format('MMMM D, YYYY'));

          $("input[name='start_date']").val(start.format('YYYY-MM-DD'))
          $("input[name='end_date']").val(end.format('YYYY-MM-DD'))
      }


    $('#reportrange').daterangepicker({
        startDate: start,
        endDate: end,
        ranges: {
           'Today': [moment(), moment()],
           'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
           'Last 7 Days': [moment().subtract(6, 'days'), moment()],
           'Last 30 Days': [moment().subtract(29, 'days'), moment()],
           'This Month': [moment().startOf('month'), moment().endOf('month')],
           'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]

        }
    }, cb);

    cb(start, end);

$("a[aria-label='organization_name']").click(function(){

  var name = $(this).attr("href")
    console.log(name)
    channel.push("find_organization", {name: name})
})



channel.on("display_organization_details", payload => {
var brand = location.pathname.split("/")[1];
    var firstpart = '/'+brand+'/organization/'
    var lastpart = '/edit'
    var newhref = firstpart + payload.organizationid + lastpart
    $("a[aria-label='edit_organization']").attr("href", newhref)

  $("li[aria-label='"+payload.name+"'].name").html(payload.name)
  $("li[aria-label='"+payload.name+"'].address").html(payload.address)
  $("li[aria-label='"+payload.name+"'].phone").html(payload.phone)
  $("li[aria-label='"+payload.name+"'].country").html(payload.country)
  $("li[aria-label='"+payload.name+"'].registernumber").html(payload.registernumber)
  $("li[aria-label='"+payload.name+"'].gstregisternumber").html(payload.gstregisternumber)




})

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

    $(".panel-body#sales_summary").hide();
    $("table#sales_summary").hide();

    $(".panel-body#pax_summary").hide();
    $("table#pax_summary").hide();




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

        $(".panel-body#sales_summary").hide();
        $("table#sales_summary").hide();

        $(".panel-body#pax_summary").hide();
        $("table#pax_summary").hide();


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
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
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
                    data: 'staff_name'
                },
                {
                    data: 'invoiceno',
                    'fnCreatedCell': function(nTd, sData, oData, iRow, iCol) {
                        $(nTd).html("<a href='/boatnoodle/detail_invoice/"+ oData.branchid +"/"+ oData.invoiceno +"' target='_blank' >View Details</a>");
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

        $(".panel-body#sales_summary").hide();
        $("table#sales_summary").hide();

        $(".panel-body#pax_summary").hide();
        $("table#pax_summary").hide();


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
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
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

        $(".panel-body#sales_summary").hide();
        $("table#sales_summary").hide();

        $(".panel-body#pax_summary").hide();
        $("table#pax_summary").hide();


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
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
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

        $(".panel-body#sales_summary").hide();
        $("table#sales_summary").hide();

        $(".panel-body#pax_summary").hide();
        $("table#pax_summary").hide();


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
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
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

        $(".panel-body#sales_summary").hide();
        $("table#sales_summary").hide();

        $(".panel-body#pax_summary").hide();
        $("table#pax_summary").hide();



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

        $(".panel-body#sales_summary").hide();
        $("table#sales_summary").hide();

        $(".panel-body#pax_summary").hide();
        $("table#pax_summary").hide();




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

        $(".panel-body#sales_summary").hide();
        $("table#sales_summary").hide();

        $(".panel-body#pax_summary").hide();
        $("table#pax_summary").hide();



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
                   data: 'invoiceno',
                    'fnCreatedCell': function(nTd, sData, oData, iRow, iCol) {
                        $(nTd).html("<a href='/boatnoodle/detail_invoice/"+ oData.branchid +"/"+ oData.invoiceno +"'  target='_blank'>View Details</a>");
                    }
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

        $(".panel-body#sales_summary").hide();
        $("table#sales_summary").hide();

        $(".panel-body#pax_summary").hide();
        $("table#pax_summary").hide();




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

        $(".panel-body#sales_summary").hide();
        $("table#sales_summary").hide();

        $(".panel-body#pax_summary").hide();
        $("table#pax_summary").hide();


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

        $(".panel-body#sales_summary").hide();
        $("table#sales_summary").hide();

        $(".panel-body#pax_summary").hide();
        $("table#pax_summary").hide();


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

        $(".panel-body#sales_summary").hide();
        $("table#sales_summary").hide();

        $(".panel-body#pax_summary").hide();
        $("table#pax_summary").hide();


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

    $(".nav-link#sales_summary").click(function() {

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

        $(".panel-body#sales_summary").show();
        $("table#sales_summary").show();

        $(".panel-body#pax_summary").hide();
        $("table#pax_summary").hide();

        var b_id = $("select#branch_list").val()
        var s_date = $("input[name='start_date']").val()
        var e_date = $("input[name='end_date']").val()
        channel.push("sales_summary", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date
        })
    })

    channel.on("populate_table_sales_summary", payload => {
        console.log(payload.luck)
        var data = payload.luck


        $("table#sales_summary").DataTable({
            destroy: true,
            data: data,
            columns: [{
                    data: 'date'
                },
                {
                    data: 'grand_total'
                },
                {
                    data: 'morning'
                },
                {
                    data: 'lunch'
                },
                {
                    data: 'idle'
                },
                {
                    data: 'dinner'
                }
            ]
        });

        $("#backdrop").delay(500).fadeOut()
    })


    $(".nav-link#pax_summary").click(function() {

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


        $(".panel-body#sales_summary").hide();
        $("table#sales_summary").hide();

        $(".panel-body#pax_summary").show();
        $("table#pax_summary").show();

        var b_id = $("select#branch_list").val()
        var s_date = $("input[name='start_date']").val()
        var e_date = $("input[name='end_date']").val()
        channel.push("pax_summary", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date
        })
    })

    channel.on("populate_table_pax_summary", payload => {
        console.log(payload.luck)
        var data = payload.luck


        $("table#pax_summary").DataTable({
            destroy: true,
            data: data,
            columns: [{
                    data: 'date'
                },
                {
                    data: 'pax'
                },
                {
                    data: 'morning'
                },
                {
                    data: 'lunch'
                },
                {
                    data: 'idle'
                },
                {
                    data: 'dinner'
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



        localStorage.setItem("taxes_data", payload.map);

        var maps = JSON.parse(localStorage.getItem("taxes_data"))
        var salesdate = []
        var tax = []
        var aat = []
        $(maps).each(function() {
            salesdate.push(this.salesdate)
        })
        $(maps).each(function() {
            tax.push(this.tax)
        })
        $(maps).each(function() {
            aat.push(this.aat)
        })
        Highcharts.chart('taxBarChart', {
            chart: {
                type: 'line'
            },
            title: {
                text: 'Tax Reports(RM)'
            },

            xAxis: {
                categories: salesdate,
                title: {
                    text: null
                }
            },
            yAxis: {
                min: 0,
                title: {
                    text: 'Values',
                    align: 'middle'
                },
                labels: {
                    overflow: 'justify'
                }
            },
            tooltip: {
                headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
                pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
                    '<td style="padding:0"><b> {point.y:.1f} </b></td></tr>',
                footerFormat: '</table>',
                shared: true,
                useHTML: true
            },
            plotOptions: {
                bar: {
                    dataLabels: {
                        enabled: true
                    }
                }
            },

            credits: {
                enabled: false
            },
            series: [{
                    name: "Total Tax",
                    data: tax
                },
                {
                    name: "Among After Tax",
                    data: aat
                }
            ]

        });


        $("#backdrop").delay(500).fadeOut()

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

        localStorage.setItem("payment_data", payload.map);

        var maps = JSON.parse(localStorage.getItem("payment_data"))
        var salesdate = []
        var cash = []
        var card = []
        $(maps).each(function() {
            salesdate.push(this.salesdate)
        })
        $(maps).each(function() {
            cash.push(this.cash)
        })
        $(maps).each(function() {
            card.push(this.card)
        })
        Highcharts.chart('paymentBarChart', {
            chart: {
                type: 'line'
            },
            title: {
                text: 'Payment Reports(RM)'
            },

            xAxis: {
                categories: salesdate,
                title: {
                    text: null
                }
            },
            yAxis: {
                min: 0,
                title: {
                    text: 'Values',
                    align: 'middle'
                },
                labels: {
                    overflow: 'justify'
                }
            },
            tooltip: {
                headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
                pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
                    '<td style="padding:0"><b> {point.y:.1f} </b></td></tr>',
                footerFormat: '</table>',
                shared: true,
                useHTML: true
            },
            plotOptions: {
                bar: {
                    dataLabels: {
                        enabled: true
                    }
                }
            },

            credits: {
                enabled: false
            },
            series: [{
                    name: "Total Sales by Cash",
                    data: cash
                },
                {
                    name: "Total Sales by Card",
                    data: card
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

        localStorage.setItem("cashinout", payload.map);

        var maps = JSON.parse(localStorage.getItem("cashinout"))
        var salesdate = []
        var cash_in = []
        var cash_out = []
        var open_drawer = []
        $(maps).each(function() {
            salesdate.push(this.salesdate)
        })
        $(maps).each(function() {
            cash_in.push(this.cash_in)
        })
        $(maps).each(function() {
            cash_out.push(this.cash_out)
        })
        $(maps).each(function() {
            open_drawer.push(this.open_drawer)
        })
        Highcharts.chart('cashinoutBarChart', {
            chart: {
                type: 'line'
            },
            title: {
                text: 'Cash In Out Reports'
            },

            xAxis: {
                categories: salesdate,
                title: {
                    text: null
                }
            },
            tooltip: {
                headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
                pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
                    '<td style="padding:0"><b> {point.y:.1f} </b></td></tr>',
                footerFormat: '</table>',
                shared: true,
                useHTML: true
            },
            yAxis: {
                min: 0,
                title: {
                    text: 'Values',
                    align: 'middle'
                },
                labels: {
                    overflow: 'justify'
                }
            },
            plotOptions: {
                bar: {
                    dataLabels: {
                        enabled: true
                    }
                }
            },

            credits: {
                enabled: false
            },
            series: [{
                    name: "Total Cash In",
                    data: cash_in
                },
                {
                    name: "Total Cash Out",
                    data: cash_out
                },
                {
                    name: "Open Drawer",
                    data: open_drawer
                }
            ]

        });


        $("#backdrop").delay(500).fadeOut()
    })

    $("button#chart_btn").click(function() {

        $("#backdrop").fadeIn()

        var b_id = $("select#branch_list").val()
        var s_date = $("input[name='start_date']").val()
        var e_date = $("input[name='end_date']").val()
        channel.push("chart_btn", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date
        })
    })

    channel.on("populate_chart", payload => {

        localStorage.setItem("bar_chart_sales_data", payload.map0);

        var maps = JSON.parse(localStorage.getItem("bar_chart_sales_data"))
        var bulan = []
        var sales = []
        var tax = []
        var service_charge = []

        $(maps).each(function() {
            bulan.push(this.bulan)
        })
        $(maps).each(function() {
            sales.push(this.sales)
        })
        $(maps).each(function() {
            tax.push(this.tax)
        })
        $(maps).each(function() {
            service_charge.push(this.service_charge)
        })

        Highcharts.chart('chart2', {
            chart: {
                type: 'column'
            },
            title: {
                text: 'Branch Monthly Comparison Chart'
            },
            xAxis: {
                categories: bulan,
            },
            tooltip: {
                headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
                pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
                    '<td style="padding:0"><b> {point.y:.1f} </b></td></tr>',
                footerFormat: '</table>',
                shared: true,
                useHTML: true
            },
            credits: {
                enabled: false
            },
            series: [{
                name: 'Sales',
                data: sales
            }, {
                name: 'Tax',
                data: tax
            }, {
                name: 'Service Charge',
                data: service_charge
            }]
        });

        localStorage.setItem("chart_data", payload.map);

        var maps = JSON.parse(localStorage.getItem("chart_data"))
        var salesdate = []
        var grand_total = []
        var tax = []
        var service_charge = []

        $(maps).each(function() {
            salesdate.push(this.salesdate)
        })
        $(maps).each(function() {
            grand_total.push(this.grand_total)
        })
        $(maps).each(function() {
            tax.push(this.tax)
        })
        $(maps).each(function() {
            service_charge.push(this.service_charge)
        })

        Highcharts.chart('chart', {
            chart: {
                type: 'line'
            },
            title: {
                text: 'Daily Sales Report(RM)'
            },

            xAxis: {
                categories: salesdate,
                title: {
                    text: null
                }
            },
            yAxis: {
                min: 0,
                title: {
                    text: 'Values',
                    align: 'middle'
                },
                labels: {
                    overflow: 'justify'
                }
            },
            tooltip: {
                headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
                pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
                    '<td style="padding:0"><b> {point.y:.1f} </b></td></tr>',
                footerFormat: '</table>',
                shared: true,
                useHTML: true
            },
            plotOptions: {
                bar: {
                    dataLabels: {
                        enabled: true
                    }
                }
            },

            credits: {
                enabled: false
            },
            series: [{
                    name: "Sales",
                    data: grand_total
                },
                {
                    name: "Tax",
                    data: tax
                },
                {
                    name: "Service Charge",
                    data: service_charge
                }
            ]

        });


        localStorage.setItem("hourly_sales_chart_data", payload.map2);

        var maps = JSON.parse(localStorage.getItem("hourly_sales_chart_data"))
        var sales = []
        var tax = []
        var service_charge = []
        var time = []

        $(maps).each(function() {
            sales.push(this.sales)
        })
        $(maps).each(function() {
            tax.push(this.tax)
        })
        $(maps).each(function() {
            service_charge.push(this.service_charge)
        })
        $(maps).each(function() {
            time.push(this.time)
        })


        Highcharts.chart('hourly_sales_chart', {
            chart: {
                type: 'line'
            },
            title: {
                text: 'Current Hourly Sales Reports(RM)'
            },

            xAxis: {
                categories: time,
                title: {
                    text: null
                }
            },
            tooltip: {
                headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
                pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
                    '<td style="padding:0"><b> {point.y:.1f} </b></td></tr>',
                footerFormat: '</table>',
                shared: true,
                useHTML: true
            },
            yAxis: {
                min: 0,
                title: {
                    text: 'Values',
                    align: 'middle'
                },
                labels: {
                    overflow: 'justify'
                }
            },
            plotOptions: {
                bar: {
                    dataLabels: {
                        enabled: true
                    }
                }
            },

            credits: {
                enabled: false
            },
            series: [{
                    name: "Sales",
                    data: sales
                },
                {
                    name: "Tax",
                    data: tax
                },
                {
                    name: "Service Charge",
                    data: service_charge
                }
            ]

        });


        localStorage.setItem("hourly_pax_chart_data", payload.map3);

        var maps = JSON.parse(localStorage.getItem("hourly_pax_chart_data"))
        var pax = []
        var transaction = []
        var time = []

        $(maps).each(function() {
            pax.push(this.pax)
        })
        $(maps).each(function() {
            transaction.push(this.transaction)
        })
        $(maps).each(function() {
            time.push(this.time)
        })


        Highcharts.chart('hourly_pax_chart', {
            chart: {
                type: 'line'
            },
            title: {
                text: 'Current Hourly Pax Reports'
            },

            xAxis: {
                categories: time,
                title: {
                    text: null
                }
            },
            tooltip: {
                headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
                pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
                    '<td style="padding:0"><b> {point.y:.1f} </b></td></tr>',
                footerFormat: '</table>',
                shared: true,
                useHTML: true
            },
            yAxis: {
                min: 0,
                title: {
                    text: 'Values',
                    align: 'middle'
                },
                labels: {
                    overflow: 'justify'
                }
            },
            plotOptions: {
                bar: {
                    dataLabels: {
                        enabled: true
                    }
                }
            },

            credits: {
                enabled: false
            },
            series: [{
                    name: "Pax",
                    data: pax
                },
                {
                    name: "Transaction",
                    data: transaction
                }
            ]

        });

        $("#backdrop").delay(500).fadeOut()


    })

    $("button#generate_sales_charts").click(function(){

        $("#backdrop").fadeIn()

        var b_id = $("select#branch_list").val()
        var year = $("select#year").val()

        channel.push("generate_sales_charts", {
            user_id: window.currentUser,
            branch_id: b_id,
            year: year
        })
    })

    channel.on("show_sales_chart", payload => {
        $("div#show_sales_chart").html(payload.html)
        var monthly_sales = JSON.parse(payload.monthly_sales)
        var months = []
        var grand_totals = []
        $(monthly_sales).each(function(){ months.push(this.month) })
        $(monthly_sales).each(function(){ grand_totals.push(this.grand_total) })
        console.log(months)
        console.log(grand_totals)
        Highcharts.chart('monthly_chart', {
            chart: {
                type: 'column'
            },
            title: {
                text: payload.branchname +' Monthly Sales in ' + payload.year
            },
            subtitle: {
                text: ''
            },
            xAxis: {
                categories: months,
                crosshair: true
            },
            yAxis: {
                min: 0,
                title: {
                    text: 'Sales (RM)'
                }
            },
            tooltip: {
                headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
                pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
                    '<td style="padding:0"><b>RM {point.y:.1f} </b></td></tr>',
                footerFormat: '</table>',
                shared: true,
                useHTML: true
            },
            plotOptions: {
                column: {
                    pointPadding: 0.2,
                    borderWidth: 0
                }
            },
            series: [{
                name: 'Sales',
                data: grand_totals

            }]
        });

        $("#backdrop").delay(500).fadeOut()

    })

$('select#disc').on('change', function() {

     var disc= $("#disc option:selected").val();

  channel.push("generate_discount_items", {
            disc: disc
           
        })
})

  channel.on("generate_discount_item2", payload => {
        console.log(payload.discount)
        var data = payload.discount

        $("table#discount_items").DataTable({
            destroy: true,
            data: data,
            columns: [{
                    data: 'discitemsname'
                },
                {
                    data: 'disctype'
                },
                {
                    data: 'is_visable'
                }
            ]
        });

        $("#backdrop").delay(500).fadeOut()
    })





  $("button[aria-label='price']").click(function(){
    var price = $(this).html() 
    var id = $(this).attr('id')
    var price_code = $(this).attr('name')

    var subcat_id = id
    

    channel.push("combo_edit", {price_code: price_code, subcat_id: subcat_id, brand_id: window.currentBrand})
  })

  channel.on("show_combo_modal", payload => {
    $("#modal_form1").html(payload.html);
    $("button#submit_edit_form_combo").click(function(event){
      event.preventDefault();
      var fr= []
      var fr = $("form[aria-label='edit_combo_price_form']").serializeArray();

      channel.push("update_combo_price",{map: fr, brand_id: window.currentBrand})
    })
  })

  channel.on("updated_combo_price", payload => {
    $('#model1').modal('toggle');
    $("#backdrop").fadeIn()
     location.reload();
     $("#backdrop").delay(500).fadeOut()
   
  })


$("select#select_target_category").select(function(){

  var selectBox = document.getElementById("select_target_category");
  var selectedValue = selectBox.options[selectBox.selectedIndex].value;

     channel.push("select_target_cat", {selectedValue: selectedValue, brand_id: window.currentBrand})

   })



 $("button[aria-label='upload_voucher']").click(function(){
   

    channel.push("upload_voucher", { brand_id: window.currentBrand})
  })

   channel.on("show_voucher", payload => {
    $("#modal_form5").html(payload.html);
    $("button#submit_upload_voucher").click(function(event){
      event.preventDefault();
  
    })
  })

     channel.on("upload_all_code", payload => {
    $('#model1').modal('toggle');
    $("#backdrop").fadeIn()
     location.reload();
     $("#backdrop").delay(500).fadeOut()
   
  })


});
