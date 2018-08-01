
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
                    data: 'year'
                },
                {
                    data: 'month'
                },
                 {
                    data: 'grand_total1'
                }
            ]
        });




        var maps = JSON.parse(payload.st_graph)
        var month = []
        var grand_total = []
        

        $(maps).each(function() {
            month.push(this.month)
        })
        $(maps).each(function() {
            grand_total.push(this.grand_total)
        })

        Highcharts.chart('st_barchart', {
            chart: {
                type: 'column'
            },
            title: {
                text: 'Sales Trend Chart in (RM)'
            },
            xAxis: {
                categories: month,
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
                data: grand_total
            }]
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
                    data: 'year'
                },
                {
                    data: 'month'
                },
                 {
                    data: 'grand_total1'
                }
            ]
        });

        var maps = JSON.parse(payload.ad_graph)
        var month = []
        var grand_total = []
        

        $(maps).each(function() {
            month.push(this.month)
        })
        $(maps).each(function() {
            grand_total.push(this.grand_total)
        })

        Highcharts.chart('ad_barchart', {
            chart: {
                type: 'column'
            },
            title: {
                text: 'Average Daily Sales Trend Chart in (RM)'
            },
            xAxis: {
                categories: month,
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
                data: grand_total
            }]
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
                    data: 'year'
                },
                {
                    data: 'month'
                },
                 {
                    data: 'pax'
                }
            ]
        });



        var maps = JSON.parse(payload.pt_graph)
        var month = []
        var pax = []
        

        $(maps).each(function() {
            month.push(this.month)
        })
        $(maps).each(function() {
            pax.push(this.pax)
        })

        Highcharts.chart('pt_barchart', {
            chart: {
                type: 'column'
            },
            title: {
                text: 'Pax Trend Chart in (QTY)'
            },
            xAxis: {
                categories: month,
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
                name: 'Pax',
                data: pax
            }]
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
                    data: 'year'
                },
                {
                    data: 'month'
                },
                 {
                    data: 'pax'
                }
            ]
        });

        var maps = JSON.parse(payload.adp_graph)
        var month = []
        var pax = []
        

        $(maps).each(function() {
            month.push(this.month)
        })
        $(maps).each(function() {
            pax.push(this.pax)
        })

        Highcharts.chart('adp_barchart', {
            chart: {
                type: 'column'
            },
            title: {
                text: 'Average Daily Pax Trend Chart in (QTY)'
            },
            xAxis: {
                categories: month,
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
                name: 'Pax',
                data: pax
            }]
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
                    data: 'year'
                },
                {
                    data: 'month'
                },
                 {
                    data: 'grand_total1'
                }
            ]
        });

        var maps = JSON.parse(payload.pps_graph)
        var month = []
        var grand_total = []
        

        $(maps).each(function() {
            month.push(this.month)
        })
        $(maps).each(function() {
            grand_total.push(this.grand_total)
        })

        Highcharts.chart('pps_barchart', {
            chart: {
                type: 'column'
            },
            title: {
                text: 'Per Pax Spending Trend Chart in (QTY)'
            },
            xAxis: {
                categories: month,
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
                data: grand_total
            }]
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

       var maps = JSON.parse(payload.pvt_graph)
        var day = []
        var pax = []
        

        $(maps).each(function() {
            day.push(this.day)
        })
        $(maps).each(function() {
            pax.push(this.pax)
        })

        Highcharts.chart('pvt_barchart', {
            chart: {
                type: 'line'
            },
            title: {
                text: 'Pax Visiting Trend Chart in (QTY)'
            },
            xAxis: {
                categories: day,
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
                data: pax
            }]
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
                    data: 'year'
                },
                 {
                    data: 'month'
                },
                {
                    data: 'category'
                },
                {
                    data: 'grand_total1'
                }
            ]
        });

       var maps = JSON.parse(payload.ct_graph)
        var month = []
        var noodle = []
        var rice = []
        var sidedish = []
        var beverages = []
        var add_on = []
        var toppings = []


        $(maps).each(function() {
            noodle.push(this.noodle)
        })
        $(maps).each(function() {
            rice.push(this.rice)
        })
         $(maps).each(function() {
            sidedish.push(this.sidedish)
        })
        $(maps).each(function() {
            beverages.push(this.beverages)
        })
         $(maps).each(function() {
            add_on.push(this.add_on)
        })
             $(maps).each(function() {
            toppings.push(this.toppings)
        })
      
         $(maps).each(function() {
            month.push(this.month)
        })

        Highcharts.chart('ct_barchart', {
            chart: {
                type: 'line'
            },
            title: {
                text: 'Categories Trend Chart in (RM)'
            },
            xAxis: {
                categories: month,
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
                name: 'Noodle',
                data: noodle
            },
            {
                name: 'Rice',
                data: rice
            },
            {
                name: 'SideDish',
                data: sidedish
            },
            {
                name: 'Beverages',
                data: beverages
            },
            {
                name: 'Add On',
                data: add_on
            },
             {
                name: 'Toppings',
                data: toppings
            }]
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
                    data: 'year'
                },
                 {
                    data: 'month'
                },
                {
                    data: 'category'
                },
                {
                    data: 'grand_total1'
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
                    data: 'year'
                },
                 {
                    data: 'month'
                },
                {
                    data: 'category'
                },
                {
                    data: 'grand_total1'
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
                    data: 'year'
                },
                 {
                    data: 'month'
                },
                {
                    data: 'category'
                },
                {
                    data: 'grand_total1'
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
                    data: 'year'
                },
                 {
                    data: 'month'
                },
                {
                    data: 'category'
                },
                {
                    data: 'grand_total1'
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
                    data: 'year'
                },
                 {
                    data: 'month'
                },
                {
                    data: 'category'
                },
                {
                    data: 'grand_total1'
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
                    data: 'year'
                },
                 {
                    data: 'month'
                },
                {
                    data: 'category'
                },
                {
                    data: 'grand_total1'
                },
                {
                    data: 'percentage'
                }
            ]
        });

        var maps = JSON.parse(payload.cct_graph)
        var month = []
        var noodle = []
        var rice = []
        var sidedish = []
        var beverages = []
        var add_on = []
        var toppings = []


        $(maps).each(function() {
            noodle.push(this.noodle)
        })
        $(maps).each(function() {
            rice.push(this.rice)
        })
         $(maps).each(function() {
            sidedish.push(this.sidedish)
        })
        $(maps).each(function() {
            beverages.push(this.beverages)
        })
         $(maps).each(function() {
            add_on.push(this.add_on)
        })
             $(maps).each(function() {
            toppings.push(this.toppings)
        })
      
         $(maps).each(function() {
            month.push(this.month)
        })

 


Highcharts.chart('cct_barchart', {
  chart: {
    type: 'column'
  },
  title: {
    text: 'Categories Contribute Trend Chart in (RM)'
  },
  xAxis: {
    categories: month,
  },
  yAxis: {
    min: 0,
    title: {
      text: 'Total fruit consumption'
    },
    stackLabels: {
      enabled: true,
      style: {
        fontWeight: 'bold',
        color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
      }
    }
  },
  legend: {
    align: 'right',
    x: -30,
    verticalAlign: 'top',
    y: 25,
    floating: true,
    backgroundColor: (Highcharts.theme && Highcharts.theme.background2) || 'white',
    borderColor: '#CCC',
    borderWidth: 1,
    shadow: false
  },
  tooltip: {
    headerFormat: '<b>{point.x}</b><br/>',
    pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}'
  },
  plotOptions: {
    column: {
      stacking: 'normal',
      dataLabels: {
        enabled: true,
        color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
      }
    }
  },
  series: [{
                name: 'Noodle',
                data: noodle
            },
            {
                name: 'Rice',
                data: rice
            },
            {
                name: 'SideDish',
                data: sidedish
            },
            {
                name: 'Beverages',
                data: beverages
            },
            {
                name: 'Add On',
                data: add_on
            },
             {
                name: 'Toppings',
                data: toppings
            }]
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
                    data: 'year'
                },
                 {
                    data: 'month'
                },
                {
                    data: 'itemname'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'grand_total1'
                }
            ]
        });
  $("#backdrop").delay(500).fadeOut()

       var maps = JSON.parse(payload.stbrn_graph)
        var month = []
        var n01 = []
        var n02 = []
        var n03 = []
        var n04 = []
        var n05 = []
        var n06 = []
        var n07 = []
        var n08 = []
        var n09 = []
        var n10 = []
        var n11 = []
        var n12 = []

    $(maps).each(function() {
        month.push(this.month)
        })
        $(maps).each(function() {
            n01.push(this.n01)
        })
        $(maps).each(function() {
            n02.push(this.n02)
        })
         $(maps).each(function() {
            n03.push(this.n03)
        })
        $(maps).each(function() {
            n04.push(this.n04)
        })
        $(maps).each(function() {
            n05.push(this.n05)
        })
        $(maps).each(function() {
            n06.push(this.n06)
        })
        $(maps).each(function() {
            n07.push(this.n07)
        })
        $(maps).each(function() {
            n08.push(this.n08)
        })
        $(maps).each(function() {
            n09.push(this.n09)
        })
        $(maps).each(function() {
            n10.push(this.n10)
        })
        $(maps).each(function() {
            n11.push(this.n11)
        })
        $(maps).each(function() {
            n12.push(this.n12)
        })



Highcharts.chart('stbrn_graph', {
  chart: {
    type: 'column'
  },
  title: {
    text: 'Sales Trend By Category Chart in (RM)'
  },
  xAxis: {
    categories: month,
  },
  yAxis: {
    min: 0,
    title: {
      text: 'Total fruit consumption'
    },
    stackLabels: {
      enabled: true,
      style: {
        fontWeight: 'bold',
        color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
      }
    }
  },
  legend: {
    align: 'right',
    x: -30,
    verticalAlign: 'top',
    y: 25,
    floating: true,
    backgroundColor: (Highcharts.theme && Highcharts.theme.background2) || 'white',
    borderColor: '#CCC',
    borderWidth: 1,
    shadow: false
  },
  tooltip: {
    headerFormat: '<b>{point.x}</b><br/>',
    pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}'
  },
  plotOptions: {
    column: {
      stacking: 'normal',
      dataLabels: {
        enabled: true,
        color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
      }
    }
  },
  series: [{
                name: 'N01 P. Beef Thai Rice Noodle',
                data: n01
            },
            {
                name: 'N02 A. Beef Thai Rice Noodle',
                data: n02
            },
            {
                name: 'N03 P. Chick Thai Rice Noodle',
                data: n03
            },
            {
                name: 'N04 A. Chick Thai Rice Noodle',
                data: n04
            },
            {
                name: 'N05 P. Beef Thai Egg Noodle',
                data: n05
            },
             {
                name: 'N06 A. Beef Thai Egg Noodle',
                data: n06
            },
            {
                name: 'N07 P. Chick Thai Egg Noodle',
                data: n07
            },
            {
                name: 'N08 A. Chick Thai Egg Noodle',
                data: n08
            },
            {
                name: 'N09 P. Beef Springy Noodle',
                data: n09
            },
            {
                name: 'N10 A. Beef Springy Noodle',
                data: n10
            },
            {
                name: 'N11 P. Chick Springy  Noodle',
                data: n11
            },
            {
                name: 'N12 A. Chick Springy Noodle',
                data: n12
            }]
});
      
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
                    data: 'grand_total1'
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
                    data: 'grand_total1'
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
                    data: 'grand_total1'
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
                    data: 'grand_total1'
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
                    data: 'year'
                },
                 {
                    data: 'month'
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

        var maps = JSON.parse(payload.stbqn_graph)
        var month = []
        var n01 = []
        var n02 = []
        var n03 = []
        var n04 = []
        var n05 = []
        var n06 = []
        var n07 = []
        var n08 = []
        var n09 = []
        var n10 = []
        var n11 = []
        var n12 = []

    $(maps).each(function() {
        month.push(this.month)
        })
        $(maps).each(function() {
            n01.push(this.n01)
        })
        $(maps).each(function() {
            n02.push(this.n02)
        })
         $(maps).each(function() {
            n03.push(this.n03)
        })
        $(maps).each(function() {
            n04.push(this.n04)
        })
        $(maps).each(function() {
            n05.push(this.n05)
        })
        $(maps).each(function() {
            n06.push(this.n06)
        })
        $(maps).each(function() {
            n07.push(this.n07)
        })
        $(maps).each(function() {
            n08.push(this.n08)
        })
        $(maps).each(function() {
            n09.push(this.n09)
        })
        $(maps).each(function() {
            n10.push(this.n10)
        })
        $(maps).each(function() {
            n11.push(this.n11)
        })
        $(maps).each(function() {
            n12.push(this.n12)
        })



Highcharts.chart('stbqn_graph', {
  chart: {
    type: 'column'
  },
  title: {
    text: 'Sales Trend By Category Chart in (RM)'
  },
  xAxis: {
    categories: month,
  },
  yAxis: {
    min: 0,
    title: {
      text: 'Total fruit consumption'
    },
    stackLabels: {
      enabled: true,
      style: {
        fontWeight: 'bold',
        color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
      }
    }
  },
  legend: {
    align: 'right',
    x: -30,
    verticalAlign: 'top',
    y: 25,
    floating: true,
    backgroundColor: (Highcharts.theme && Highcharts.theme.background2) || 'white',
    borderColor: '#CCC',
    borderWidth: 1,
    shadow: false
  },
  tooltip: {
    headerFormat: '<b>{point.x}</b><br/>',
    pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}'
  },
  plotOptions: {
    column: {
      stacking: 'normal',
      dataLabels: {
        enabled: true,
        color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
      }
    }
  },
  series: [{
                name: 'N01 P. Beef Thai Rice Noodle',
                data: n01
            },
            {
                name: 'N02 A. Beef Thai Rice Noodle',
                data: n02
            },
            {
                name: 'N03 P. Chick Thai Rice Noodle',
                data: n03
            },
            {
                name: 'N04 A. Chick Thai Rice Noodle',
                data: n04
            },
            {
                name: 'N05 P. Beef Thai Egg Noodle',
                data: n05
            },
             {
                name: 'N06 A. Beef Thai Egg Noodle',
                data: n06
            },
            {
                name: 'N07 P. Chick Thai Egg Noodle',
                data: n07
            },
            {
                name: 'N08 A. Chick Thai Egg Noodle',
                data: n08
            },
            {
                name: 'N09 P. Beef Springy Noodle',
                data: n09
            },
            {
                name: 'N10 A. Beef Springy Noodle',
                data: n10
            },
            {
                name: 'N11 P. Chick Springy  Noodle',
                data: n11
            },
            {
                name: 'N12 A. Chick Springy Noodle',
                data: n12
            }]
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
                   data: 'year'
                },
                 {
                    data: 'month'
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
                   data: 'year'
                },
                 {
                    data: 'month'
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
                     data: 'year'
                },
                 {
                    data: 'month'
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
                   data: 'year'
                },
                 {
                    data: 'month'
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
                 data: 'year'
                },
                 {
                    data: 'month'
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

               var maps = JSON.parse(payload.compare_trend_rm_graph)
        var month = []
        var alacart = []
        var combo = []

        $(maps).each(function() {
        month.push(this.month)
        })
        $(maps).each(function() {
            alacart.push(this.alacart)
        })
        $(maps).each(function() {
            combo.push(this.combo)
        })
       



Highcharts.chart('compare_trend_rm_graph', {
  chart: {
    type: 'column'
  },
  title: {
    text: 'Noodle Sales Trend By Category Chart'
  },
  xAxis: {
    categories: month,
  },
  yAxis: {
    min: 0,
    title: {
      text: 'Total fruit consumption'
    },
    stackLabels: {
      enabled: true,
      style: {
        fontWeight: 'bold',
        color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
      }
    }
  },
  legend: {
    align: 'right',
    x: -30,
    verticalAlign: 'top',
    y: 25,
    floating: true,
    backgroundColor: (Highcharts.theme && Highcharts.theme.background2) || 'white',
    borderColor: '#CCC',
    borderWidth: 1,
    shadow: false
  },
  tooltip: {
    headerFormat: '<b>{point.x}</b><br/>',
    pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}'
  },
  plotOptions: {
    column: {
      stacking: 'normal',
      dataLabels: {
        enabled: true,
        color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
      }
    }
  },
  series: [{
                name: 'ALA CART',
                data: alacart
            },
            {
                name: 'COMBO',
                data: combo
            }]
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
                  data: 'year'
                },
                 {
                    data: 'month'
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

                             var maps = JSON.parse(payload.compare_trend_rm_rice_graph)
        var month = []
        var alacart = []
        var combo = []

        $(maps).each(function() {
        month.push(this.month)
        })
        $(maps).each(function() {
            alacart.push(this.alacart)
        })
        $(maps).each(function() {
            combo.push(this.combo)
        })
       



Highcharts.chart('compare_trend_rm_rice_graph', {
  chart: {
    type: 'column'
  },
  title: {
    text: 'Rice Sales Trend By Category Chart'
  },
  xAxis: {
    categories: month,
  },
  yAxis: {
    min: 0,
    title: {
      text: 'Total fruit consumption'
    },
    stackLabels: {
      enabled: true,
      style: {
        fontWeight: 'bold',
        color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
      }
    }
  },
  legend: {
    align: 'right',
    x: -30,
    verticalAlign: 'top',
    y: 25,
    floating: true,
    backgroundColor: (Highcharts.theme && Highcharts.theme.background2) || 'white',
    borderColor: '#CCC',
    borderWidth: 1,
    shadow: false
  },
  tooltip: {
    headerFormat: '<b>{point.x}</b><br/>',
    pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}'
  },
  plotOptions: {
    column: {
      stacking: 'normal',
      dataLabels: {
        enabled: true,
        color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
      }
    }
  },
  series: [{
                name: 'ALA CART',
                data: alacart
            },
            {
                name: 'COMBO',
                data: combo
            }]
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
                  data: 'year'
                },
                 {
                    data: 'month'
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

                             var maps = JSON.parse(payload.compare_trend_rm_beverage_graph)
        var month = []
        var alacart = []
        var combo = []

        $(maps).each(function() {
        month.push(this.month)
        })
        $(maps).each(function() {
            alacart.push(this.alacart)
        })
        $(maps).each(function() {
            combo.push(this.combo)
        })
       



Highcharts.chart('compare_trend_rm_beverage_graph', {
  chart: {
    type: 'column'
  },
  title: {
    text: 'Beverage Sales Trend By Category Chart'
  },
  xAxis: {
    categories: month,
  },
  yAxis: {
    min: 0,
    title: {
      text: 'Total fruit consumption'
    },
    stackLabels: {
      enabled: true,
      style: {
        fontWeight: 'bold',
        color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
      }
    }
  },
  legend: {
    align: 'right',
    x: -30,
    verticalAlign: 'top',
    y: 25,
    floating: true,
    backgroundColor: (Highcharts.theme && Highcharts.theme.background2) || 'white',
    borderColor: '#CCC',
    borderWidth: 1,
    shadow: false
  },
  tooltip: {
    headerFormat: '<b>{point.x}</b><br/>',
    pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}'
  },
  plotOptions: {
    column: {
      stacking: 'normal',
      dataLabels: {
        enabled: true,
        color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
      }
    }
  },
  series: [{
                name: 'ALA CART',
                data: alacart
            },
            {
                name: 'COMBO',
                data: combo
            }]
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
                  data: 'year'
                },
                 {
                    data: 'month'
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

                             var maps = JSON.parse(payload.compare_trend_rm_dessert_graph)
        var month = []
        var alacart = []
        var combo = []

        $(maps).each(function() {
        month.push(this.month)
        })
        $(maps).each(function() {
            alacart.push(this.alacart)
        })
        $(maps).each(function() {
            combo.push(this.combo)
        })
       



Highcharts.chart('compare_trend_rm_dessert_graph', {
  chart: {
    type: 'column'
  },
  title: {
    text: 'Dessert Sales Trend By Category Chart'
  },
  xAxis: {
    categories: month,
  },
  yAxis: {
    min: 0,
    title: {
      text: 'Total fruit consumption'
    },
    stackLabels: {
      enabled: true,
      style: {
        fontWeight: 'bold',
        color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
      }
    }
  },
  legend: {
    align: 'right',
    x: -30,
    verticalAlign: 'top',
    y: 25,
    floating: true,
    backgroundColor: (Highcharts.theme && Highcharts.theme.background2) || 'white',
    borderColor: '#CCC',
    borderWidth: 1,
    shadow: false
  },
  tooltip: {
    headerFormat: '<b>{point.x}</b><br/>',
    pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}'
  },
  plotOptions: {
    column: {
      stacking: 'normal',
      dataLabels: {
        enabled: true,
        color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
      }
    }
  },
  series: [{
                name: 'ALA CART',
                data: alacart
            },
            {
                name: 'COMBO',
                data: combo
            }]
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
                   data: 'year'
                },
                 {
                    data: 'month'
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

                             var maps = JSON.parse(payload.compare_trend_rm_others_graph)
        var month = []
        var alacart = []
        var combo = []

        $(maps).each(function() {
        month.push(this.month)
        })
        $(maps).each(function() {
            alacart.push(this.alacart)
        })
        $(maps).each(function() {
            combo.push(this.combo)
        })
       



Highcharts.chart('compare_trend_rm_others_graph', {
  chart: {
    type: 'column'
  },
  title: {
    text: 'Others Sales Trend By Category Chart'
  },
  xAxis: {
    categories: month,
  },
  yAxis: {
    min: 0,
    title: {
      text: 'Total fruit consumption'
    },
    stackLabels: {
      enabled: true,
      style: {
        fontWeight: 'bold',
        color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
      }
    }
  },
  legend: {
    align: 'right',
    x: -30,
    verticalAlign: 'top',
    y: 25,
    floating: true,
    backgroundColor: (Highcharts.theme && Highcharts.theme.background2) || 'white',
    borderColor: '#CCC',
    borderWidth: 1,
    shadow: false
  },
  tooltip: {
    headerFormat: '<b>{point.x}</b><br/>',
    pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}'
  },
  plotOptions: {
    column: {
      stacking: 'normal',
      dataLabels: {
        enabled: true,
        color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
      }
    }
  },
  series: [{
                name: 'ALA CART',
                data: alacart
            },
            {
                name: 'COMBO',
                data: combo
            }]
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
                  data: 'year'
                },
                 {
                    data: 'month'
                },
                {
                    data: 'category'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'grand_total1'
                }
            ]
        });


                      var maps = JSON.parse(payload.compare_trend_qty_graph)
        var month = []
        var alacart = []
        var combo = []

        $(maps).each(function() {
        month.push(this.month)
        })
        $(maps).each(function() {
            alacart.push(this.alacart)
        })
        $(maps).each(function() {
            combo.push(this.combo)
        })
       



Highcharts.chart('compare_trend_qty_graph', {
  chart: {
    type: 'column'
  },
  title: {
    text: 'Noodle Sales Trend By Category Chart'
  },
  xAxis: {
    categories: month,
  },
  yAxis: {
    min: 0,
    title: {
      text: 'Total fruit consumption'
    },
    stackLabels: {
      enabled: true,
      style: {
        fontWeight: 'bold',
        color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
      }
    }
  },
  legend: {
    align: 'right',
    x: -30,
    verticalAlign: 'top',
    y: 25,
    floating: true,
    backgroundColor: (Highcharts.theme && Highcharts.theme.background2) || 'white',
    borderColor: '#CCC',
    borderWidth: 1,
    shadow: false
  },
  tooltip: {
    headerFormat: '<b>{point.x}</b><br/>',
    pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}'
  },
  plotOptions: {
    column: {
      stacking: 'normal',
      dataLabels: {
        enabled: true,
        color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
      }
    }
  },
  series: [{
                name: 'ALA CART',
                data: alacart
            },
            {
                name: 'COMBO',
                data: combo
            }]
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
                   data: 'year'
                },
                 {
                    data: 'month'
                },
                {
                    data: 'category'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'grand_total1'
                }
            ]
        });



                      var maps = JSON.parse(payload.compare_trend_qty_rice_graph)
        var month = []
        var alacart = []
        var combo = []

        $(maps).each(function() {
        month.push(this.month)
        })
        $(maps).each(function() {
            alacart.push(this.alacart)
        })
        $(maps).each(function() {
            combo.push(this.combo)
        })
       



Highcharts.chart('compare_trend_qty_rice_graph', {
  chart: {
    type: 'column'
  },
  title: {
    text: 'Rice Sales Trend By Category Chart'
  },
  xAxis: {
    categories: month,
  },
  yAxis: {
    min: 0,
    title: {
      text: 'Total fruit consumption'
    },
    stackLabels: {
      enabled: true,
      style: {
        fontWeight: 'bold',
        color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
      }
    }
  },
  legend: {
    align: 'right',
    x: -30,
    verticalAlign: 'top',
    y: 25,
    floating: true,
    backgroundColor: (Highcharts.theme && Highcharts.theme.background2) || 'white',
    borderColor: '#CCC',
    borderWidth: 1,
    shadow: false
  },
  tooltip: {
    headerFormat: '<b>{point.x}</b><br/>',
    pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}'
  },
  plotOptions: {
    column: {
      stacking: 'normal',
      dataLabels: {
        enabled: true,
        color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
      }
    }
  },
  series: [{
                name: 'ALA CART',
                data: alacart
            },
            {
                name: 'COMBO',
                data: combo
            }]
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
                    data: 'year'
                },
                 {
                    data: 'month'
                },
                {
                    data: 'category'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'grand_total1'
                }
            ]
        });


                      var maps = JSON.parse(payload.compare_trend_qty_beverage_graph)
        var month = []
        var alacart = []
        var combo = []

        $(maps).each(function() {
        month.push(this.month)
        })
        $(maps).each(function() {
            alacart.push(this.alacart)
        })
        $(maps).each(function() {
            combo.push(this.combo)
        })
       



Highcharts.chart('compare_trend_qty_beverage_graph', {
  chart: {
    type: 'column'
  },
  title: {
    text: 'Beverage Sales Trend By Category Chart'
  },
  xAxis: {
    categories: month,
  },
  yAxis: {
    min: 0,
    title: {
      text: 'Total fruit consumption'
    },
    stackLabels: {
      enabled: true,
      style: {
        fontWeight: 'bold',
        color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
      }
    }
  },
  legend: {
    align: 'right',
    x: -30,
    verticalAlign: 'top',
    y: 25,
    floating: true,
    backgroundColor: (Highcharts.theme && Highcharts.theme.background2) || 'white',
    borderColor: '#CCC',
    borderWidth: 1,
    shadow: false
  },
  tooltip: {
    headerFormat: '<b>{point.x}</b><br/>',
    pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}'
  },
  plotOptions: {
    column: {
      stacking: 'normal',
      dataLabels: {
        enabled: true,
        color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
      }
    }
  },
  series: [{
                name: 'ALA CART',
                data: alacart
            },
            {
                name: 'COMBO',
                data: combo
            }]
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
                  data: 'year'
                },
                 {
                    data: 'month'
                },
                {
                    data: 'category'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'grand_total1'
                }
            ]
        });


                      var maps = JSON.parse(payload.compare_trend_qty_dessert_graph)
        var month = []
        var alacart = []
        var combo = []

        $(maps).each(function() {
        month.push(this.month)
        })
        $(maps).each(function() {
            alacart.push(this.alacart)
        })
        $(maps).each(function() {
            combo.push(this.combo)
        })
       



Highcharts.chart('compare_trend_qty_dessert_graph', {
  chart: {
    type: 'column'
  },
  title: {
    text: 'Rice Sales Trend By Category Chart'
  },
  xAxis: {
    categories: month,
  },
  yAxis: {
    min: 0,
    title: {
      text: 'Total fruit consumption'
    },
    stackLabels: {
      enabled: true,
      style: {
        fontWeight: 'bold',
        color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
      }
    }
  },
  legend: {
    align: 'right',
    x: -30,
    verticalAlign: 'top',
    y: 25,
    floating: true,
    backgroundColor: (Highcharts.theme && Highcharts.theme.background2) || 'white',
    borderColor: '#CCC',
    borderWidth: 1,
    shadow: false
  },
  tooltip: {
    headerFormat: '<b>{point.x}</b><br/>',
    pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}'
  },
  plotOptions: {
    column: {
      stacking: 'normal',
      dataLabels: {
        enabled: true,
        color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
      }
    }
  },
  series: [{
                name: 'ALA CART',
                data: alacart
            },
            {
                name: 'COMBO',
                data: combo
            }]
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
                    data: 'year'
                },
                 {
                    data: 'month'
                },
                {
                    data: 'category'
                },
                {
                    data: 'percentage'
                },
                {
                    data: 'grand_total1'
                }
            ]
        });


                      var maps = JSON.parse(payload.compare_trend_qty_others_graph)
        var month = []
        var alacart = []
        var combo = []

        $(maps).each(function() {
        month.push(this.month)
        })
        $(maps).each(function() {
            alacart.push(this.alacart)
        })
        $(maps).each(function() {
            combo.push(this.combo)
        })
       



Highcharts.chart('compare_trend_qty_others_graph', {
  chart: {
    type: 'column'
  },
  title: {
    text: 'Rice Sales Trend By Category Chart'
  },
  xAxis: {
    categories: month,
  },
  yAxis: {
    min: 0,
    title: {
      text: 'Total fruit consumption'
    },
    stackLabels: {
      enabled: true,
      style: {
        fontWeight: 'bold',
        color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
      }
    }
  },
  legend: {
    align: 'right',
    x: -30,
    verticalAlign: 'top',
    y: 25,
    floating: true,
    backgroundColor: (Highcharts.theme && Highcharts.theme.background2) || 'white',
    borderColor: '#CCC',
    borderWidth: 1,
    shadow: false
  },
  tooltip: {
    headerFormat: '<b>{point.x}</b><br/>',
    pointFormat: '{series.name}: {point.y}<br/>Total: {point.stackTotal}'
  },
  plotOptions: {
    column: {
      stacking: 'normal',
      dataLabels: {
        enabled: true,
        color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
      }
    }
  },
  series: [{
                name: 'ALA CART',
                data: alacart
            },
            {
                name: 'COMBO',
                data: combo
            }]
});
        $("#backdrop").delay(500).fadeOut()
    })                                                                                  

})