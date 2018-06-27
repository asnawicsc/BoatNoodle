if (localStorage.getItem("bn_user") != null) {

  var map = JSON.parse(localStorage.getItem("bn_user"))
  var html = "<img style='border-radius: 50%;  width: 34px; height: 34px;' src='data:image/jpg;base64, "+map.bin +"'>" 
  $("div[aria-lable='photo']").html(html)
  $("span[aria-label='username']").append(map.name)
} else {

  channel.push("load_user_sidebar", {userid: window.currentUser})


}

$(document).ready(function(){

    $("a#logout").click(function(){
      localStorage.removeItem("bn_user")
    })

    channel.on("save_user_local_storage", payload => {

      localStorage.setItem("bn_user", payload.map)


  var map = JSON.parse(localStorage.getItem("bn_user"))
  var html = "<img style='border-radius: 50%;  width: 34px; height: 34px;' src='data:image/jpg;base64, "+map.bin +"'>" 
  $("div[aria-lable='photo']").html(html)
  $("span[aria-label='username']").append(map.name)
    })

    $("button[aria-label='go_back']").click(function(){
       window.history.back();
    })
    $("div[aria-label='go_back']").click(function(){
       window.history.back();
    })

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



   
 var list ={}  
  $("ol#a1").on("click", "li", function(){
    var cat = $(this).parent().attr("aria-label")
    $("ol#a2[aria-label='"+cat+"']").append(this)

    var sublist =[]
    $("ol#a2[aria-label='"+cat+"'] li").each(function(){
          var id = $(this).attr("id")
          sublist.push(id)
          list[cat]=sublist;
    })

    console.log(list[cat])
    $("input[name='a["+cat+"][all_item]'").val(list[cat])

    })

 
  $("ol#a2").on("click", "li", function(){
      var cat = $(this).parent().attr("aria-label")

    $("ol#a1[aria-label='"+cat+"']").append(this)
  })
           

    
  $("ol#list5").on("click", "li", function(){

    $("ol#list6").append(this)
    var list_ids = [] 
    $("ol#list6 li").each(function(){
    var id = $(this).attr("id")
      list_ids.push(id)
    })
    $("input[name='branc[branch]']").val(list_ids)
  })

  $("ol#list6").on("click", "li", function(){

    $("ol#list5").append(this)
  })


   $("ol#edit1").on("click", "li", function(){

    $("ol#edit2").append(this)
    var list_ids = [] 
    $("ol#edit2 li").each(function(){
    var id = $(this).attr("id")
      list_ids.push(id)
    })
    $("input[name='a[branch]']").val(list_ids)
  })

  $("ol#edit2").on("click", "li", function(){

    $("ol#edit1").append(this)
  })

  $("ol#list0").on("click", "li", function(){

    $("ol#list9").append(this)
    var list_ids = [] 
    $("ol#list9 li").each(function(){
    var id = $(this).attr("id")
      list_ids.push(id)
    })
    $("input[name='cat']").val(list_ids)
  })

  $("ol#list9").on("click", "li", function(){

    $("ol#list0").append(this)
  })

  
  $("ol#list7").on("click", "li", function(){

    $("ol#list8").append(this)
    var list_ids = [] 
    $("ol#list8 li").each(function(){
    var id = $(this).attr("id")
      list_ids.push(id)
    })
    $("input[name='items']").val(list_ids)
  })

  $("ol#list8").on("click", "li", function(){

    $("ol#list7").append(this)
  })




});

      
