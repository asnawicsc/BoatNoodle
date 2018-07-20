
// Now that you are connected, you can join channels with a topic:
var topic = "report_channel:" + window.currentUser
// Join the topic
let report_channel = socket.channel(topic, {})
report_channel.join()


    .receive("ok", data => {
        console.log("Joined topic", topic)
    })


    .receive("error", resp => {
        console.log("Unable to join topic", topic)
    })


$(document).ready(function() {


if (localStorage.getItem('start_date') == null) 
{   var start = moment().subtract(6, 'days');
    var end = moment();

    localStorage.setItem('start_date',start.format('YYYY-MM-DD'));
    localStorage.setItem('end_date',end.format('YYYY-MM-DD'));

} 
else
{ 
     st= localStorage.getItem('start_date')
     en= localStorage.getItem('end_date')  
    
    var start = moment(st);
    var end = moment(en);
}


if (localStorage.getItem('new_brand') == null) {
   localStorage.setItem('new_brand',1);
}


      function cb(start, end){
          $('#reportrange span').html(start.format('MMMM D, YYYY') + ' - ' + end.format('MMMM D, YYYY'));

          $("input[name='start_date']").val(localStorage.getItem('start_date'))
          $("input[name='end_date']").val(localStorage.getItem('end_date'))

        
           $('#reportrange').on('hide.daterangepicker', function(ev, picker) {
             localStorage.setItem('start_date', start.format('YYYY-MM-DD'));
                  localStorage.setItem('end_date', end.format('YYYY-MM-DD'));
         location.reload();
          });  
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



         $(".nav-link#sales_trend").click(function() {
          $("#backdrop").fadeIn()
         $(".tab-pane#link1").show();
         $(".tab-pane#link2").hide();
          $(".tab-pane#link3").hide();
          $(".tab-pane#link4").hide();
          $(".tab-pane#link5").hide();
          $(".tab-pane#link6").hide();
          $(".tab-pane#link7").hide();
          $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
          $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
         $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
         $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").show();
         $("table#average_daily").hide();
         $("table#pax_trend_table").hide();
          $("table#average_daily_pax_table").hide();
          $("table#per_pax_spending_trend_table").hide();
          $("table#pax_visit_trend_table").hide();
          $("table#category_trend").hide();
           $("table#category_trend_noodle").hide();
           $("table#category_trend_rice").hide();
           $("table#category_trend_others").hide();
           $("table#category_trend_dessert").hide();
           $("table#category_trend_beverage").hide();
           $("table#category_contribute_trend").hide();
           $("table#top_10_items_qty").hide();
           $("table#top_10_items_value").hide();
            $("table#sales_trend_by_qty_rice").hide();
            $("table#sales_trend_by_qty_beverage").hide();
            $("table#sales_trend_by_qty_dessert").hide();
            $("table#sales_trend_by_qty_others").hide();
                    $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
                  $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("sales_trend", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })





        report_channel.on("sales_trend", payload => {
        console.log(payload.sales_trend)

        var data = payload.sales_trend


       $("table#sales_trend_table").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                {
                    data: 'year'
                },
                 {
                    data: 'grand_total'
                }
            ]
        });

         $("#backdrop").delay(500).fadeOut()
    })



 $(".nav-link#average_daily").click(function() {
           $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").show();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
         $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").show();
         $("table#pax_trend_table").hide();
          $("table#average_daily_pax_table").hide();
          $("table#per_pax_spending_trend_table").hide();
          $("table#pax_visit_trend_table").hide();
          $("table#category_trend").hide();
           $("table#category_trend_noodle").hide();
           $("table#category_trend_rice").hide();
           $("table#category_trend_others").hide();
           $("table#category_trend_dessert").hide();
           $("table#category_trend_beverage").hide();
           $("table#category_contribute_trend").hide();
           $("table#top_10_items_qty").hide();
           $("table#top_10_items_value").hide();
            $("table#sales_trend_by_qty_rice").hide();
            $("table#sales_trend_by_qty_beverage").hide();
            $("table#sales_trend_by_qty_dessert").hide();
            $("table#sales_trend_by_qty_others").hide();
                    $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
                  $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("average_daily", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })

 report_channel.on("average_daily", payload => {
        console.log(payload.average_daily)

        var data = payload.average_daily


       $("table#average_daily_table").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                {
                    data: 'year'
                },
                 {
                    data: 'grand_total'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    })

  $(".nav-link#pax_trend").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").show();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
                  $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").show();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
          $("table#category_trend_noodle").hide();
          $("table#category_trend_rice").hide();
          $("table#category_trend_others").hide();
          $("table#category_trend_dessert").hide();
          $("table#category_contribute_trend").hide();
          $("table#top_10_items_qty").hide();
          $("table#top_10_items_value").hide();
           $("table#sales_trend_by_qty_rice").hide();
           $("table#sales_trend_by_qty_beverage").hide();
           $("table#sales_trend_by_qty_dessert").hide();
           $("table#sales_trend_by_qty_others").hide();
                   $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
                  $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();


        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("pax_trend", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })
       
  report_channel.on("pax_trend", payload => {
        console.log(payload.pax_trend)

        var data = payload.pax_trend


       $("table#pax_trend_table").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                {
                    data: 'year'
                },
                 {
                    data: 'pax'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    })


  $(".nav-link#average_daily_pax").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").show();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
                  $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").show();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
          $("table#category_trend_noodle").hide();
          $("table#category_trend_rice").hide();
          $("table#category_trend_others").hide();
          $("table#category_trend_dessert").hide();
          $("table#category_trend_beverage").hide();
          $("table#category_contribute_trend").hide();
          $("table#top_10_items_qty").hide();
          $("table#top_10_items_value").hide();
           $("table#sales_trend_by_qty_rice").hide();
           $("table#sales_trend_by_qty_beverage").hide();
           $("table#sales_trend_by_qty_dessert").hide();
           $("table#sales_trend_by_qty_others").hide();
                   $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
                  $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("average_daily_pax", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })

    report_channel.on("average_daily_pax", payload => {
        console.log(payload.average_daily_pax)

        var data = payload.average_daily_pax


       $("table#average_daily_pax_table").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                {
                    data: 'year'
                },
                 {
                    data: 'pax'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    })  

      $(".nav-link#per_pax_speding_trend").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").show();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
                  $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").show();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
          $("table#category_trend_noodle").hide();
          $("table#category_trend_rice").hide();
          $("table#category_trend_others").hide();
          $("table#category_trend_dessert").hide();
          $("table#category_trend_beverage").hide();
          $("table#category_contribute_trend").hide();
          $("table#top_10_items_qty").hide();
          $("table#top_10_items_value").hide();
           $("table#sales_trend_by_qty_rice").hide();
           $("table#sales_trend_by_qty_beverage").hide();
           $("table#sales_trend_by_qty_dessert").hide();
           $("table#sales_trend_by_qty_others").hide();
                   $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
                  $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("per_pax_spending_trend", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    }) 

       report_channel.on("per_pax_spending_trend", payload => {
        console.log(payload.per_pax_spending_trend)

        var data = payload.per_pax_spending_trend


       $("table#per_pax_spending_trend_table").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                {
                    data: 'year'
                },
                 {
                    data: 'grand_total'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    }) 


   $(".nav-link#pax_visit_trend").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").show();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
                  $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").show();
         $("table#category_trend").hide();
          $("table#category_trend_noodle").hide();
          $("table#category_trend_rice").hide();
          $("table#category_trend_others").hide();
          $("table#category_trend_dessert").hide();
          $("table#category_trend_beverage").hide();
          $("table#category_contribute_trend").hide();
          $("table#top_10_items_qty").hide();
          $("table#top_10_items_value").hide();
           $("table#sales_trend_by_qty_rice").hide();
           $("table#sales_trend_by_qty_beverage").hide();
           $("table#sales_trend_by_qty_dessert").hide();
           $("table#sales_trend_by_qty_others").hide();
                   $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
                  $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("pax_visit_trend", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    }) 
 

    report_channel.on("pax_visit_trend", payload => {
        console.log(payload.pax_visit_trend)

        var data = payload.pax_visit_trend


       $("table#pax_visit_trend_table").DataTable({
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
                    data: 'pax'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    }) 


       $(".nav-link#category_trend").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").show();
         $(".tab-pane#a").show();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
                  $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").show();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
          $("table#sales_trend_by_qty_rice").hide();
          $("table#sales_trend_by_qty_beverage").hide();
          $("table#sales_trend_by_qty_dessert").hide();
          $("table#sales_trend_by_qty_others").hide();
                  $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
                  $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("category_trend", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    }) 

        report_channel.on("category_trend", payload => {
        console.log(payload.category_trend)

        var data = payload.category_trend


       $("table#category_trend").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'category'
                },
                {
                    data: 'grand_total'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    }) 

$(".nav-link#category_trend_noodle").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").show();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").show();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
                  $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").show();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
          $("table#sales_trend_by_qty_rice").hide();
          $("table#sales_trend_by_qty_beverage").hide();
          $("table#sales_trend_by_qty_dessert").hide();
          $("table#sales_trend_by_qty_others").hide();
                  $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
                  $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("category_trend_noodle", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })

    }) 



        report_channel.on("category_trend_noodle", payload => {
        console.log(payload.category_trend_noodle)

        var data = payload.category_trend_noodle


       $("table#category_trend_noodle").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'category'
                },
                {
                    data: 'grand_total'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    }) 


        $(".nav-link#category_trend_rice").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").show();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").show();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
                  $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").show();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
          $("table#sales_trend_by_qty_rice").hide();
          $("table#sales_trend_by_qty_beverage").hide();
          $("table#sales_trend_by_qty_dessert").hide();
          $("table#sales_trend_by_qty_others").hide();
                  $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
                  $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();




        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("category_trend_rice", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    }) 


    report_channel.on("category_trend_rice", payload => {
        console.log(payload.category_trend_rice)

        var data = payload.category_trend_rice


       $("table#category_trend_rice").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'category'
                },
                {
                    data: 'grand_total'
                }
            ]
        });
           $("#backdrop").delay(500).fadeOut()
    })


    $(".nav-link#category_trend_others").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").show();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").show();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
                  $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").show();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
          $("table#sales_trend_by_qty_rice").hide();
          $("table#sales_trend_by_qty_beverage").hide();
          $("table#sales_trend_by_qty_dessert").hide();
          $("table#sales_trend_by_qty_others").hide();
                  $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
                  $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();





        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("category_trend_others", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    }) 


        report_channel.on("category_trend_others", payload => {
        console.log(payload.category_trend_others)

        var data = payload.category_trend_others


       $("table#category_trend_others").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'category'
                },
                {
                    data: 'grand_total'
                }
            ]
        });
           $("#backdrop").delay(500).fadeOut()
    })

   $(".nav-link#category_trend_dessert").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").show();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").show();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
                  $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").show();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
          $("table#sales_trend_by_qty_rice").hide();
          $("table#sales_trend_by_qty_beverage").hide();
          $("table#sales_trend_by_qty_dessert").hide();
          $("table#sales_trend_by_qty_others").hide();
                  $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
                  $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("category_trend_dessert", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    }) 


    report_channel.on("category_trend_dessert", payload => {
        console.log(payload.category_trend_dessert)

        var data = payload.category_trend_dessert


       $("table#category_trend_dessert").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'category'
                },
                {
                    data: 'grand_total'
                }
            ]
        });
           $("#backdrop").delay(500).fadeOut()
    })



     $(".nav-link#category_trend_beverage").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").show();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").show();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
                  $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").show();
          $("table#category_contribute_trend").hide();
          $("table#top_10_items_qty").hide();
          $("table#top_10_items_value").hide();
           $("table#sales_trend_by_qty_rice").hide();
           $("table#sales_trend_by_qty_beverage").hide();
           $("table#sales_trend_by_qty_dessert").hide();
           $("table#sales_trend_by_qty_others").hide();
                   $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
                  $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("category_trend_beverage", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })


     report_channel.on("category_trend_beverage", payload => {
        console.log(payload.category_trend_beverage)

        var data = payload.category_trend_beverage


       $("table#category_trend_beverage").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'category'
                },
                {
                    data: 'grand_total'
                }
            ]
        });
           $("#backdrop").delay(500).fadeOut()
    })


    $(".nav-link#category_contribute_trend").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").show();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
                  $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").show();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
          $("table#sales_trend_by_qty_rice").hide();
          $("table#sales_trend_by_qty_beverage").hide();
          $("table#sales_trend_by_qty_dessert").hide();
          $("table#sales_trend_by_qty_others").hide();
                  $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
                  $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("category_contribute_trend", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })

    }) 

     report_channel.on("category_contribute_trend", payload => {
        console.log(payload.category_contribute_trend)

        var data = payload.category_contribute_trend


       $("table#category_contribute_trend").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'category'
                },
                {
                    data: 'grand_total'
                },
                {
                    data: 'percentage'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    })
  

    $(".nav-link#top_10_items_qty").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
          $(".tab-pane#link8").hide();
         $(".tab-pane#link9").show();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
                  $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").show();
         $("table#top_10_items_value").show();
          $("table#sales_trend_by_qty_rice").hide();
          $("table#sales_trend_by_qty_beverage").hide();
          $("table#sales_trend_by_qty_dessert").hide();
          $("table#sales_trend_by_qty_others").hide();
                  $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
                  $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("top_10_items_qty", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    }) 


      report_channel.on("top_10_items_qty", payload => {
        console.log(payload.top_10_items_qty)
        console.log(payload.top_10_items_value)

        var data = payload.top_10_items_qty
        var data2 = payload.top_10_items_value


       $("table#top_10_items_qty").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'itemname'
                },
                 {
                    data: 'qty'
                }
            ]
        });

       $("table#top_10_items_value").DataTable({
             destroy: true,
            data: data2,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'itemname'
                },
                 {
                    data: 'value'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    }) 


     $(".nav-link#sales_trend_by_qty").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").show();
         $(".tab-pane#9").show();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
                  $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
         $("table#sales_trend_by_qty").show();
         $("table#sales_trend_by_qty_rice").hide();
         $("table#sales_trend_by_qty_beverage").hide();
         $("table#sales_trend_by_qty_dessert").hide();
         $("table#sales_trend_by_qty_others").hide();
                 $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
                  $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("sales_trend_by_qty", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })

    report_channel.on("sales_trend_by_qty", payload => {
        console.log(payload.sales_trend_by_qty)

        var data = payload.sales_trend_by_qty


       $("table#sales_trend_by_qty").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'itemname'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'grand_total'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    }) 

    $(".nav-link#sales_trend_by_qty_rice").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").show();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").show();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
                  $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
         $("table#sales_trend_by_qty").hide();
         $("table#sales_trend_by_qty_rice").show();
         $("table#sales_trend_by_qty_beverage").hide();
         $("table#sales_trend_by_qty_dessert").hide();
         $("table#sales_trend_by_qty_others").hide();
                 $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
                  $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();




        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("sales_trend_by_qty_rice", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })


     report_channel.on("sales_trend_by_qty_rice", payload => {
        console.log(payload.sales_trend_by_qty_rice)

        var data = payload.sales_trend_by_qty_rice


       $("table#sales_trend_by_qty_rice").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'itemname'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'grand_total'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    })


       $(".nav-link#sales_trend_by_qty_beverage").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").show();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").show();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
                  $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
         $("table#sales_trend_by_qty").hide();
         $("table#sales_trend_by_qty_rice").hide();
         $("table#sales_trend_by_qty_beverage").show();
         $("table#sales_trend_by_qty_dessert").hide();
         $("table#sales_trend_by_qty_others").hide();
                 $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
                  $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();




        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("sales_trend_by_qty_beverage", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })

    report_channel.on("sales_trend_by_qty_beverage", payload => {
        console.log(payload.sales_trend_by_qty_beverage)

        var data = payload.sales_trend_by_qty_beverage


       $("table#sales_trend_by_qty_beverage").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'itemname'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'grand_total'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    })

           $(".nav-link#sales_trend_by_qty_dessert").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").show();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").show();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
                  $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
         $("table#sales_trend_by_qty").hide();
         $("table#sales_trend_by_qty_rice").hide();
         $("table#sales_trend_by_qty_beverage").hide();
         $("table#sales_trend_by_qty_dessert").show();
         $("table#sales_trend_by_qty_others").hide();
         $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
                  $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();




        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("sales_trend_by_qty_dessert", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })

    report_channel.on("sales_trend_by_qty_dessert", payload => {
        console.log(payload.sales_trend_by_qty_dessert)

        var data = payload.sales_trend_by_qty_dessert


       $("table#sales_trend_by_qty_dessert").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'itemname'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'grand_total'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    })


    $(".nav-link#sales_trend_by_qty_others").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").show();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").show();
         $(".tab-pane#link11").hide();
         $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
         $("table#sales_trend_by_qty").hide();
         $("table#sales_trend_by_qty_rice").hide();
         $("table#sales_trend_by_qty_beverage").hide();
         $("table#sales_trend_by_qty_dessert").hide();
         $("table#sales_trend_by_qty_others").show();
         $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
                  $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("sales_trend_by_qty_others", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })

     report_channel.on("sales_trend_by_qty_others", payload => {
        console.log(payload.sales_trend_by_qty_others)

        var data = payload.sales_trend_by_qty_others


       $("table#sales_trend_by_qty_others").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'itemname'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'grand_total'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    })


     $(".nav-link#sales_trend_by_rm").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").show();
         $(".tab-pane#a1").show();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
         $("table#sales_trend_by_qty").hide();
         $("table#sales_trend_by_qty_rice").hide();
         $("table#sales_trend_by_qty_beverage").hide();
         $("table#sales_trend_by_qty_dessert").hide();
         $("table#sales_trend_by_qty_others").hide();
         $("table#sales_trend_by_rm").show();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
                  $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("sales_trend_by_rm", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })

     report_channel.on("sales_trend_by_rm", payload => {
        console.log(payload.sales_trend_by_rm)

        var data = payload.sales_trend_by_rm


       $("table#sales_trend_by_rm").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'itemname'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'qty'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    })


         $(".nav-link#sales_trend_by_rm_rice").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").show();
         $(".tab-pane#a1").hide();
         $(".tab-pane#a2").show();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
         $("table#sales_trend_by_qty").hide();
         $("table#sales_trend_by_qty_rice").hide();
         $("table#sales_trend_by_qty_beverage").hide();
         $("table#sales_trend_by_qty_dessert").hide();
         $("table#sales_trend_by_qty_others").hide();
         $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").show();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
                  $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("sales_trend_by_rm_rice", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })

     report_channel.on("sales_trend_by_rm_rice", payload => {
        console.log(payload.sales_trend_by_rm_rice)

        var data = payload.sales_trend_by_rm_rice


       $("table#sales_trend_by_rm_rice").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'itemname'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'qty'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    })



         $(".nav-link#sales_trend_by_rm_beverage").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").show();
         $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").show();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
         $("table#sales_trend_by_qty").hide();
         $("table#sales_trend_by_qty_rice").hide();
         $("table#sales_trend_by_qty_beverage").hide();
         $("table#sales_trend_by_qty_dessert").hide();
         $("table#sales_trend_by_qty_others").hide();
         $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").show();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
                  $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("sales_trend_by_rm_beverage", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })

     report_channel.on("sales_trend_by_rm_beverage", payload => {
        console.log(payload.sales_trend_by_rm_beverage)

        var data = payload.sales_trend_by_rm_beverage


       $("table#sales_trend_by_rm_beverage").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'itemname'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'qty'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    }) 


             $(".nav-link#sales_trend_by_rm_dessert").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").show();
         $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").show();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
         $("table#sales_trend_by_qty").hide();
         $("table#sales_trend_by_qty_rice").hide();
         $("table#sales_trend_by_qty_beverage").hide();
         $("table#sales_trend_by_qty_dessert").hide();
         $("table#sales_trend_by_qty_others").hide();
         $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").show();
         $("table#sales_trend_by_rm_others").hide();
         $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("sales_trend_by_rm_dessert", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })

     report_channel.on("sales_trend_by_rm_dessert", payload => {
        console.log(payload.sales_trend_by_rm_dessert)

        var data = payload.sales_trend_by_rm_dessert


       $("table#sales_trend_by_rm_dessert").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'itemname'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'qty'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    })



             $(".nav-link#sales_trend_by_rm_others").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").show();
         $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").show();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
         $("table#sales_trend_by_qty").hide();
         $("table#sales_trend_by_qty_rice").hide();
         $("table#sales_trend_by_qty_beverage").hide();
         $("table#sales_trend_by_qty_dessert").hide();
         $("table#sales_trend_by_qty_others").hide();
         $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").show();
         $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("sales_trend_by_rm_others", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })

     report_channel.on("sales_trend_by_rm_others", payload => {
        console.log(payload.sales_trend_by_rm_others)

        var data = payload.sales_trend_by_rm_others


       $("table#sales_trend_by_rm_others").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'itemname'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'qty'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    })




             $(".nav-link#compare_sales_trend_rm").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
         $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").show();
         $(".tab-pane#b1").show();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
         $("table#sales_trend_by_qty").hide();
         $("table#sales_trend_by_qty_rice").hide();
         $("table#sales_trend_by_qty_beverage").hide();
         $("table#sales_trend_by_qty_dessert").hide();
         $("table#sales_trend_by_qty_others").hide();
         $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
         $("table#compare_sales_trend_rm").show();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("compare_sales_trend_rm", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })

     report_channel.on("compare_sales_trend_rm", payload => {
        console.log(payload.compare_sales_trend_rm)

        var data = payload.compare_sales_trend_rm


       $("table#compare_sales_trend_rm").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'category'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'qty'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    })


    $(".nav-link#compare_sales_trend_rm_rice").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
         $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").show();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").show();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
         $("table#sales_trend_by_qty").hide();
         $("table#sales_trend_by_qty_rice").hide();
         $("table#sales_trend_by_qty_beverage").hide();
         $("table#sales_trend_by_qty_dessert").hide();
         $("table#sales_trend_by_qty_others").hide();
         $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
         $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").show();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("compare_sales_trend_rm_rice", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })

     report_channel.on("compare_sales_trend_rm_rice", payload => {
        console.log(payload.compare_sales_trend_rm_rice)

        var data = payload.compare_sales_trend_rm_rice


       $("table#compare_sales_trend_rm_rice").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'category'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'qty'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    })

    $(".nav-link#compare_sales_trend_rm_beverage").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
         $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").show();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").show();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
         $("table#sales_trend_by_qty").hide();
         $("table#sales_trend_by_qty_rice").hide();
         $("table#sales_trend_by_qty_beverage").hide();
         $("table#sales_trend_by_qty_dessert").hide();
         $("table#sales_trend_by_qty_others").hide();
         $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
         $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").show();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("compare_sales_trend_rm_beverage", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })

     report_channel.on("compare_sales_trend_rm_beverage", payload => {
        console.log(payload.compare_sales_trend_rm_beverage)

        var data = payload.compare_sales_trend_rm_beverage


       $("table#compare_sales_trend_rm_beverage").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'category'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'qty'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    })


        $(".nav-link#compare_sales_trend_rm_dessert").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
         $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").show();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").show();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
         $("table#sales_trend_by_qty").hide();
         $("table#sales_trend_by_qty_rice").hide();
         $("table#sales_trend_by_qty_beverage").hide();
         $("table#sales_trend_by_qty_dessert").hide();
         $("table#sales_trend_by_qty_others").hide();
         $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
         $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").show();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("compare_sales_trend_rm_dessert", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })

     report_channel.on("compare_sales_trend_rm_dessert", payload => {
        console.log(payload.compare_sales_trend_rm_dessert)

        var data = payload.compare_sales_trend_rm_dessert


       $("table#compare_sales_trend_rm_dessert").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'category'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'qty'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    })

            $(".nav-link#compare_sales_trend_rm_others").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
         $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").show();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").show();
         $(".tab-pane#link13").hide();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
         $("table#sales_trend_by_qty").hide();
         $("table#sales_trend_by_qty_rice").hide();
         $("table#sales_trend_by_qty_beverage").hide();
         $("table#sales_trend_by_qty_dessert").hide();
         $("table#sales_trend_by_qty_others").hide();
         $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
         $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").show();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("compare_sales_trend_rm_others", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })

     report_channel.on("compare_sales_trend_rm_others", payload => {
        console.log(payload.compare_sales_trend_rm_others)

        var data = payload.compare_sales_trend_rm_others


       $("table#compare_sales_trend_rm_others").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'category'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'qty'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    })


      $(".nav-link#compare_sales_trend_qty").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
         $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").show();
         $(".tab-pane#c1").show();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
         $("table#sales_trend_by_qty").hide();
         $("table#sales_trend_by_qty_rice").hide();
         $("table#sales_trend_by_qty_beverage").hide();
         $("table#sales_trend_by_qty_dessert").hide();
         $("table#sales_trend_by_qty_others").hide();
         $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
         $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").show();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("compare_sales_trend_qty", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })

     report_channel.on("compare_sales_trend_qty", payload => {
        console.log(payload.compare_sales_trend_qty)

        var data = payload.compare_sales_trend_qty


       $("table#compare_sales_trend_qty").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'category'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'grand_total'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    })


          $(".nav-link#compare_sales_trend_qty_rice").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
         $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").show();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").show();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
         $("table#sales_trend_by_qty").hide();
         $("table#sales_trend_by_qty_rice").hide();
         $("table#sales_trend_by_qty_beverage").hide();
         $("table#sales_trend_by_qty_dessert").hide();
         $("table#sales_trend_by_qty_others").hide();
         $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
         $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").show();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("compare_sales_trend_qty_rice", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })

     report_channel.on("compare_sales_trend_qty_rice", payload => {
        console.log(payload.compare_sales_trend_qty_rice)

        var data = payload.compare_sales_trend_qty_rice


       $("table#compare_sales_trend_qty_rice").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'category'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'grand_total'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    })


              $(".nav-link#compare_sales_trend_qty_beverage").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
         $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").show();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").show();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
         $("table#sales_trend_by_qty").hide();
         $("table#sales_trend_by_qty_rice").hide();
         $("table#sales_trend_by_qty_beverage").hide();
         $("table#sales_trend_by_qty_dessert").hide();
         $("table#sales_trend_by_qty_others").hide();
         $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
         $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").show();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("compare_sales_trend_qty_beverage", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })

     report_channel.on("compare_sales_trend_qty_beverage", payload => {
        console.log(payload.compare_sales_trend_qty_beverage)

        var data = payload.compare_sales_trend_qty_beverage


       $("table#compare_sales_trend_qty_beverage").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'category'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'grand_total'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    }) 


    $(".nav-link#compare_sales_trend_qty_dessert").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
         $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").show();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").show();
         $(".tab-pane#c5").hide();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
         $("table#sales_trend_by_qty").hide();
         $("table#sales_trend_by_qty_rice").hide();
         $("table#sales_trend_by_qty_beverage").hide();
         $("table#sales_trend_by_qty_dessert").hide();
         $("table#sales_trend_by_qty_others").hide();
         $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
         $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").show();
         $("table#compare_sales_trend_qty_others").hide();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("compare_sales_trend_qty_dessert", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })

     report_channel.on("compare_sales_trend_qty_dessert", payload => {
        console.log(payload.compare_sales_trend_qty_dessert)

        var data = payload.compare_sales_trend_qty_dessert


       $("table#compare_sales_trend_qty_dessert").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'category'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'grand_total'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    })



    $(".nav-link#compare_sales_trend_qty_others").click(function() {
 $("#backdrop").fadeIn()
         $(".tab-pane#link1").hide();
         $(".tab-pane#link2").hide();
         $(".tab-pane#link3").hide();
         $(".tab-pane#link4").hide();
         $(".tab-pane#link5").hide();
         $(".tab-pane#link6").hide();
         $(".tab-pane#link7").hide();
         $(".tab-pane#a").hide();
         $(".tab-pane#b").hide();
         $(".tab-pane#c").hide();
         $(".tab-pane#d").hide();
         $(".tab-pane#e").hide();
         $(".tab-pane#f").hide();
         $(".tab-pane#link8").hide();
         $(".tab-pane#link9").hide();
         $(".tab-pane#link10").hide();
         $(".tab-pane#9").hide();
         $(".tab-pane#8").hide();
         $(".tab-pane#7").hide();
         $(".tab-pane#6").hide();
         $(".tab-pane#5").hide();
         $(".tab-pane#link11").hide();
         $(".tab-pane#a1").hide();
         $(".tab-pane#a2").hide();
         $(".tab-pane#a3").hide();
         $(".tab-pane#a4").hide();
         $(".tab-pane#a5").hide();
                  $(".tab-pane#link12").hide();
         $(".tab-pane#b1").hide();
         $(".tab-pane#b2").hide();
         $(".tab-pane#b3").hide();
         $(".tab-pane#b4").hide();
         $(".tab-pane#b5").hide();
         $(".tab-pane#link13").show();
         $(".tab-pane#c1").hide();
         $(".tab-pane#c2").hide();
         $(".tab-pane#c3").hide();
         $(".tab-pane#c4").hide();
         $(".tab-pane#c5").show();
         $("table#sales_trend_table").hide();
         $("table#average_daily_table").hide();
         $("table#pax_trend_table").hide();
         $("table#average_daily_pax_table").hide();
         $("table#per_pax_spending_trend_table").hide();
         $("table#pax_visit_trend_table").hide();
         $("table#category_trend").hide();
         $("table#category_trend_noodle").hide();
         $("table#category_trend_rice").hide();
         $("table#category_trend_others").hide();
         $("table#category_trend_dessert").hide();
         $("table#category_trend_beverage").hide();
         $("table#category_contribute_trend").hide();
         $("table#top_10_items_qty").hide();
         $("table#top_10_items_value").hide();
         $("table#sales_trend_by_qty").hide();
         $("table#sales_trend_by_qty_rice").hide();
         $("table#sales_trend_by_qty_beverage").hide();
         $("table#sales_trend_by_qty_dessert").hide();
         $("table#sales_trend_by_qty_others").hide();
         $("table#sales_trend_by_rm").hide();
         $("table#sales_trend_by_rm_rice").hide();
         $("table#sales_trend_by_rm_beverage").hide();
         $("table#sales_trend_by_rm_dessert").hide();
         $("table#sales_trend_by_rm_others").hide();
         $("table#compare_sales_trend_rm").hide();
         $("table#compare_sales_trend_rm_rice").hide();
         $("table#compare_sales_trend_rm_beverage").hide();
         $("table#compare_sales_trend_rm_dessert").hide();
         $("table#compare_sales_trend_rm_others").hide();
         $("table#compare_sales_trend_qty").hide();
         $("table#compare_sales_trend_qty_rice").hide();
         $("table#compare_sales_trend_qty_beverage").hide();
         $("table#compare_sales_trend_qty_dessert").hide();
         $("table#compare_sales_trend_qty_others").show();



        var b_id = $("select#branch_list").val()

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        report_channel.push("compare_sales_trend_qty_others", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
        })
    })

     report_channel.on("compare_sales_trend_qty_others", payload => {
        console.log(payload.compare_sales_trend_qty_others)

        var data = payload.compare_sales_trend_qty_others


       $("table#compare_sales_trend_qty_others").DataTable({
             destroy: true,
            data: data,
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'month'
                },
                 {
                    data: 'year'
                },
                {
                    data: 'category'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'grand_total'
                }
            ]
        });
        $("#backdrop").delay(500).fadeOut()
    })                                                                                  

})