
// Now that you are connected, you can join channels with a topic:
var topic = "dashboard_channel:" + window.currentBrand
// Join the topic
let dashboard_channel = socket.channel(topic, {})
dashboard_channel.join()


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

dashboard_channel.on("dashboard_1", payload => {

console.log(payload.nett_sales)
console.log(payload.taxes)
console.log(payload.order)
console.log(payload.pax)
console.log(payload.transaction)
console.log(payload.table)

var nett_sales = payload.nett_sales
var taxes = payload.taxes
var order = payload.order
var pax = payload.pax
var transaction = payload.transaction

$("div#nett_sales").html(nett_sales);  
$("div#tax").html(taxes);      
$("div#order").html(order);     
$("div#pax").html(pax);      
$("div#transaction").html(transaction);
})

      function format(n, sep, decimals) {
            sep = sep || "."; // Default to period as decimal separator
            decimals = decimals || 2; // Default to 2 decimals

            return n.toLocaleString().split(sep)[0]
                + sep
                + n.toFixed(decimals).split(sep)[1];
        }

      dashboard_channel.on("dashboard", payload => {
        

        localStorage.setItem('table_branch_daily_sales_sumary', payload.table_branch_daily_sales_sumary)

        var data = JSON.parse(payload.table_branch_daily_sales_sumary)

        var gross_sales = []
        $(data).each(function(){
         var ts = this.gross_sales
         gross_sales.push(parseFloat(ts.replace(",", "")))
        })

     
        var gross_saless_data = 0;
 
        $.each(gross_sales, function(idx, num){
            gross_saless_data += parseFloat(num)
        })
     
        $("td#gross_saless_data").html(format(gross_saless_data))


        var service_charge = []
        $(data).each(function(){
         var ts = this.service_charge
         service_charge.push(parseFloat(ts.replace(",", "")))
        })

        var service_charge_data = 0;
          $.each(service_charge, function(idx, num){
            service_charge_data += parseFloat(num)
        })
         $("td#service_charge_data").html(format(service_charge_data))

        var gst = []
        $(data).each(function(){
         var ts = this.gst
         gst.push(parseFloat(ts.replace(",", "")))
        })

        var gst_data = 0;
          $.each(gst, function(idx, num){
            gst_data += parseFloat(num)
        })
         $("td#gst_data").html(format(gst_data))


        var discount = []
        $(data).each(function(){
         var ts = this.discount
         discount.push(parseFloat(ts.replace(",", "")))
        })

        var discount_data = 0;
          $.each(discount, function(idx, num){
            discount_data += parseFloat(num)
        })
         $("td#discount_data").html(format(discount_data))


        var nett_sales = []
        $(data).each(function(){
         var ts = this.nett_sales
         nett_sales.push(parseFloat(ts.replace(",", "")))
        })

        var nett_sales_data = 0;
          $.each(nett_sales, function(idx, num){
            nett_sales_data += parseFloat(num)
        })
         $("td#nett_sales_data").html(format(nett_sales_data))



        //  var roundings = []
        // $(data).each(function(){
        //  var ts = this.roundings
        //  roundings.push(parseFloat(ts.replace(",", "")))
        // })

        // var roundings_data = 0;
        //   $.each(roundings, function(idx, num){
        //     roundings_data += parseFloat(num)
        // })
        //  $("td#roundings_data").html(format(roundings_data))




         var total_sales = []
        $(data).each(function(){
         var ts = this.total_sales
         total_sales.push(parseFloat(ts.replace(",", "")))
        })

        var total_sales_data = 0;
          $.each(total_sales, function(idx, num){
            total_sales_data += parseFloat(num)
        })
         $("td#total_sales_data").html(format(total_sales_data))

        var pax = []
        $(data).each(function(){
         var ts = this.pax
         pax.push(parseFloat(ts))
        })

        var pax_data = 0;
          $.each(pax, function(idx, num){
            pax_data += parseFloat(num)
        })
         $("td#pax_data").html(format(pax_data))

       $("table#outlet_sales_information").DataTable({

            destroy: true,
            data: data,
            dom: 'BlTfgitp',
            buttons: [
                'copy', 'csv', 'excel', 'pdf', 'print'
            ],
            columns: [{
                    data: 'branchname'
                },
                {
                    data: 'gross_sales'
                },
                 {
                    data: 'service_charge'
                },
                 {
                    data: 'gst'
                },
                {
                    data: 'discount'
                },
                 {
                   data: 'nett_sales'
                },
                 {
                    data: 'roundings'
                },
                 {
                    data: 'total_sales'
                },
                 {
                    data: 'pax'
                }
            ]
        });



       localStorage.setItem('branch_daily_sales_sumary',payload.branch_daily_sales_sumary)


        var maps = JSON.parse(payload.branch_daily_sales_sumary)

        var date = []
        var total_discount = []
        var total_sales = []
        var total_service_charge = []
        var total_taxes = []
        var total_transaction = []



        $(maps).each(function() {
            date.push(this.date)
        })

        $(maps).each(function() {
            total_discount.push(this.total_discount)
        })
          $(maps).each(function() {
            total_service_charge.push(this.total_service_charge)
        })
        $(maps).each(function() {
            total_taxes.push(this.total_taxes)
        })
          $(maps).each(function() {
            total_sales.push(this.total_sales)

        })
        $(maps).each(function() {
            total_transaction.push(this.total_transaction)
        })



        Highcharts.chart('branch_daily_sales_barchart', {
            chart: {
                type: 'line'
            },
            title: {
                text: 'Branch Daily Summary'
            },
            xAxis: {
                categories: date,
            },
            tooltip: {
                headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
                pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
                    '<td style="padding:0"><b> {point.y:.2f} </b></td></tr>',
                footerFormat: '</table>',
                shared: true,
                useHTML: true
            },
            credits: {
                enabled: false
            },
            series: [{
                name: 'Nett Sales',
                data: total_sales
            },
            {
                name: 'Taxes',
                data: total_taxes
            },
            {
                name: 'Discount',
                data: total_discount
            },
            {
                name: 'Service Charge',
                data: total_service_charge
            },
            {
                name: 'Transaction',
                data: total_transaction
            }]
        });

        localStorage.setItem('top_10_selling',payload.top_10_selling)

        var maps2 = JSON.parse(payload.top_10_selling)

         console.log(maps2)




					Highcharts.chart('top_10_selling', {
					  chart: {
					    plotBackgroundColor: null,
					    plotBorderWidth: null,
					    plotShadow: false,
					    type: 'pie'
					  },
					  title: {
					    text: ''
					  },
					  tooltip: {
					 pointFormat: '<b>{point.y} </b>(<b>{point.percentage:.2f}%</b>)'
					  },
					  plotOptions: {
					    pie: {
					      allowPointSelect: true,
					      cursor: 'pointer',
					      dataLabels: {
					        enabled: true,
					        format: '<b>{point.name}</b>: {point.percentage:.2f} %',
					        style: {
					          color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
					        }
					      }
					    }
					  },
					  series: [{
					    name: 'Total',
					    colorByPoint: true,
					    data: maps2
					  }]
					});


                     localStorage.setItem('top_10_selling_revenue',payload.top_10_selling_revenue)
					        var maps3 = JSON.parse(payload.top_10_selling_revenue)
    
         console.log(maps3)




					Highcharts.chart('top_10_selling_revenue', {
					  chart: {
					    plotBackgroundColor: null,
					    plotBorderWidth: null,
					    plotShadow: false,
					    type: 'pie'
					  },
					  title: {
					    text: ''
					  },
					  tooltip: {
					    pointFormat: '<b>{point.y} </b>(<b>{point.percentage:.2f}%</b>)'
					  },
					  plotOptions: {
					    pie: {
					      allowPointSelect: true,
					      cursor: 'pointer',
					      dataLabels: {
					        enabled: true,
					        format: '<b>{point.name}</b>: {point.percentage:.2f} %',
					        style: {
					          color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
					        }
					      }
					    }
					  },
					  series: [{
					    name: 'Total',
					    colorByPoint: true,
					    data: maps3
					  }]
					});

                    localStorage.setItem('top_10_selling_revenue',payload.top_10_selling_revenue)

					  var maps4 = JSON.parse(payload.top_10_selling_category)
    
         console.log(maps4)




					Highcharts.chart('top_10_selling_category', {
					  chart: {
					    plotBackgroundColor: null,
					    plotBorderWidth: null,
					    plotShadow: false,
					    type: 'pie'
					  },
					  title: {
					    text: ''
					  },
					  tooltip: {
					    pointFormat: '<b>{point.y} </b>(<b>{point.percentage:.2f}%</b>)'
					  },
					  plotOptions: {
					    pie: {
					      allowPointSelect: true,
					      cursor: 'pointer',
					      dataLabels: {
					        enabled: true,
					        format: '<b>{point.name}</b>: {point.percentage:.2f} %',
					        style: {
					          color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
					        }
					      }
					    }
					  },
					  series: [{
					    name: 'Brands',
					    colorByPoint: true,
					    data: maps4
					  }]
					});





         $("#backdrop").delay(500).fadeOut()
    })



      dashboard_channel.on("yearly", payload => {

 localStorage.setItem('yearly',payload.yearly)

        var maps = JSON.parse(payload.yearly)
        var grand_total = []
        var gst = []
        var month = []
        var pax = []
       
        

        $(maps).each(function() {
            grand_total.push(this.grand_total)
        })
        $(maps).each(function() {
            gst.push(this.gst)
        })
          $(maps).each(function() {
            pax.push(this.pax)
        })
        $(maps).each(function() {
            month.push(this.month)
        })
          
        Highcharts.chart('yearly', {
            chart: {
                type: 'line'
            },
            title: {
                text: 'Month to Month Comparison Summary'
            },
            xAxis: {
                categories: month,
            },
            tooltip: {
                headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
                pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
                    '<td style="padding:0"><b> {point.y:.2f} </b></td></tr>',
                footerFormat: '</table>',
                shared: true,
                useHTML: true
            },
            credits: {
                enabled: false
            },
            series: [{
                name: 'Total Sales',
                data: grand_total
            },
            {
                name: 'Total Taxes',
                data: gst
            },
            {
                name: 'Total Pax',
                data: pax
            }]
        });

    })



})