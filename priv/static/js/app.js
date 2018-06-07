$(document).ready(function(){

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


        var title = $("h1.page-header").html()
        var rw =  $("h1.page-header").parent(".col-lg-12") 
        var dv =  $("h1.page-header").parent(".row") 
        $("a.navbar-brand").html(title)
        rw.remove()
        dv.remove()


        $("button[aria-label='add_new_item']").click(function(){
          $("div[aria-label='menu_item_content']").fadeOut()
          $("div[aria-label='add_new_item']").fadeIn()
        })

        $("input[name='previous_item']").click(function(){
          $("div[aria-label='menu_item_content']").fadeIn()
          $("div[aria-label='add_new_item']").fadeOut()
        })

        $("button[aria-label='add_new_category']").click(function(){
          $("div[aria-label='menu_item_content']").fadeOut()
          $("div[aria-label='add_new_category']").fadeIn()
        })

        $("input[name='previous_category']").click(function(){
          $("div[aria-label='menu_item_content']").fadeIn()
          $("div[aria-label='add_new_category']").fadeOut()
        })

    
        var pathname = window.location.pathname;
        switch(pathname) {
            case "/":
                var p = $("a[href='/']").parent("li.nav-item").eq(0)
                p.toggleClass("active")
                break;

            case "/sales":
                $("a[href='#sales']").click()
                var p = $("a[href='/sales']").parent("li.nav-item").eq(0)
                p.toggleClass("active")
                break;

            case "/sales_chart":
                $("a[href='#sales']").click()
                var p = $("a[href='/sales_chart']").parent("li.nav-item").eq(0)
                p.toggleClass("active")
                break;

            case "/tax":
                $("a[href='#sales']").click()
                var p = $("a[href='/tax']").parent("li.nav-item").eq(0)
                p.toggleClass("active")
                break;


            case "/salespayment":
                $("a[href='#sales']").click()
                var p = $("a[href='/salespayment']").parent("li.nav-item").eq(0)
                p.toggleClass("active")
                break;
                
            case "/cash_in_out":
                $("a[href='#sales']").click()
                var p = $("a[href='/cash_in_out']").parent("li.nav-item").eq(0)
                p.toggleClass("active")
                break;

            case "/menu_item":
                $("a[href='#menus']").click()
                var p = $("a[href='/menu_item']").parent("li.nav-item").eq(0)
                p.toggleClass("active")
                $("a[href='#menu_item']").click()
                break;
   
            default:
                console.log("default")
              }

    $("a.menu_catalog_item").click(function(){

      var id = $(this).attr("aria-label")
      $(".menu_catalog_item.tab-pane").attr("class", "menu_catalog_item tab-pane")
      $("div#"+id+".menu_catalog_item.tab-pane").toggleClass("active show")
    })

    $("table.data").DataTable()



   var sum = 0;

   var dataTable = document.getElementById("myTable");

   // use querySelector to find all second table cells
   var cells = document.querySelectorAll("#f_addon_ind");

 

      for (var i = 1; i < cells.length; i++){
  
         initial =parseFloat(cells[i-1].firstChild.data)
         sum= parseFloat(cells[i].firstChild.data)- initial

          var newColums = document.createElement("td");
          var secondCell = document.createElement("tr");
          var secondCellText = document.createTextNode(sum);
           secondCell.appendChild(secondCellText);
           newColums.appendChild(secondCell);

           dataTable.appendChild(newColums);
   
       };

    
    


  // $( "ol.item" ).sortable({
  //     connectWith: "ol.item",
  //     dropOnEmpty: true,
  //     scroll: true,
  //     stop: function( event, ui ) {
  //       var child_id = $(ui.item)[0].id
  //       var parent_id = $(ui.item)[0].parentElement.id

  //     }
  //   }).disableSelection();

  $("ol#list1").on("click", "li", function(){

    $("ol#list2").append(this)
    var list_ids = [] 
    $("ol#list2 li").each(function(){
    var id = $(this).attr("id")
      list_ids.push(id)
    })
    $("input[name='item[itemcode]']").val(list_ids)
  })

  $("ol#list2").on("click", "li", function(){

    $("ol#list1").append(this)

  })

});

