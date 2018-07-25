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


if (localStorage.getItem('year') == null) 
{  
    localStorage.setItem('year',2018);


} 
else
{ 
     localStorage.getItem('year')}
    



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
    ;

        var s_date = localStorage.getItem('start_date')
        var e_date = localStorage.getItem('end_date')
        channel.push("dashboard", {
            user_id: window.currentUser,
            branch_id: b_id,
            s_date: s_date,
            e_date: e_date,
            brand_id: window.currentBrand
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
            dom: 'Bfrtip',
            buttons: [
                'copy', 'csv', 'print'
            ],
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


});
