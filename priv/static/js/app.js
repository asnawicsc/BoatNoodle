
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





$(document).ready(function(){

  if (localStorage.getItem("bn_user") != null) {

  var map = JSON.parse(localStorage.getItem("bn_user"))
  var html = "<img style='border-radius: 50%;  width: 34px; height: 34px;' src='data:image/jpg;base64, "+map.bin +"'>" 
  $("div[aria-lable='photo']").html(html)
  $("span[aria-label='username']").append(map.name)
    } else {
    if (window.currentUser != "lobby") { 
      channel.push("load_user_sidebar", {userid: window.currentUser,brandid: window.currentBrand})
    }

    }

    channel.on("notify_user_brand_changed", payload => {
      $.notify({
          icon: "notifications",
          message: payload.name+" brand access changed to "+payload.brand_name

      }, {
          type: "info",
          timer: 100,
          placement: {
              from: 'bottom',
              align: 'right'
          }
      });
    })

  channel.on("append_api_log", payload => {
    var messages = payload.messages
$("div.jumbotron").html("")
    $(messages).each(function(){
      $("div.jumbotron").append("<p>"+this.time+"<div class='badge badge-warning'>"+this.username+"</div>: <ul aria-label='"+this.id+"'></ul></p>")
        msg = JSON.parse(this.message) 
        var id = this.id
         $(msg).each(function(){
            $.map(this, function(k, i){
               var li = "<li>"+i+":"+k+"</li>"
       
              $("ul[aria-label='"+id+"']").append(li)
            })
         })

    })
  })


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
      var cat2 = $(this).parent().attr("aria-label")

    $("ol#a1[aria-label='"+cat2+"']").append(this)


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

  $("ol#list51").on("click", "li", function(){

    $("ol#list61").append(this)
    var list_ids = [] 
    $("ol#list61 li").each(function(){
    var id = $(this).attr("id")
      list_ids.push(id)
    })
    $("input[name='branc[branch]']").val(list_ids)
  })

  $("ol#list61").on("click", "li", function(){

    $("ol#list51").append(this)
  })

  $("ol#list52").on("click", "li", function(){

    $("ol#list62").append(this)
    var list_ids = [] 
    $("ol#list62 li").each(function(){
    var id = $(this).attr("id")
      list_ids.push(id)
    })
    $("input[name='branc[branch]']").val(list_ids)
  })

  $("ol#list62").on("click", "li", function(){

    $("ol#list52").append(this)
  })

   $("ol#list53").on("click", "li", function(){

    $("ol#list63").append(this)
    var list_ids = [] 
    $("ol#list63 li").each(function(){
    var id = $(this).attr("id")
      list_ids.push(id)
    })
    $("input[name='branc[branch]']").val(list_ids)
  })

  $("ol#list63").on("click", "li", function(){

    $("ol#list53").append(this)
  })

   $("ol#list54").on("click", "li", function(){

    $("ol#list64").append(this)
    var list_ids = [] 
    $("ol#list64 li").each(function(){
    var id = $(this).attr("id")
      list_ids.push(id)
    })
    $("input[name='branc[branch]']").val(list_ids)
  })

  $("ol#list64").on("click", "li", function(){

    $("ol#list54").append(this)
  })

   $("ol#list55").on("click", "li", function(){

    $("ol#list65").append(this)
    var list_ids = [] 
    $("ol#list65 li").each(function(){
    var id = $(this).attr("id")
      list_ids.push(id)
    })
    $("input[name='branc[branch]']").val(list_ids)
  })

  $("ol#list65").on("click", "li", function(){

    $("ol#list55").append(this)
  })


 $("ol#list56").on("click", "li", function(){

    $("ol#list66").append(this)
    var list_ids = [] 
    $("ol#list66 li").each(function(){
    var id = $(this).attr("id")
      list_ids.push(id)
    })
    $("input[name='branc[branch]']").val(list_ids)
  })

  $("ol#list66").on("click", "li", function(){

    $("ol#list56").append(this)
  })

   $("ol#list57").on("click", "li", function(){

    $("ol#list67").append(this)
    var list_ids = [] 
    $("ol#list67 li").each(function(){
    var id = $(this).attr("id")
      list_ids.push(id)
    })
    $("input[name='branc[branch]']").val(list_ids)
  })

  $("ol#list67").on("click", "li", function(){

    $("ol#list57").append(this)
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

  $("ol#dis1").on("click", "li", function(){

    $("ol#dis2").append(this)
    var list_ids = [] 
    $("ol#dis2 li").each(function(){
    var id = $(this).attr("id")
      list_ids.push(id)
    })
    console.log(list_ids)
    $("input[name='cat']").val(list_ids)
  })

  $("ol#dis2").on("click", "li", function(){

    $("ol#dis1").append(this)
  })


       $("ol#dis3").on("click", "li", function(){

    $("ol#dis4").append(this)
    var list_ids = [] 
    $("ol#dis4 li").each(function(){
    var id = $(this).attr("id")
      list_ids.push(id)
    })
    $("input[name='items']").val(list_ids)
  })

  $("ol#dis4").on("click", "li", function(){

    $("ol#dis3").append(this)
  })



  $('button[data-original-title="combo new"]').click(function() {
            var li_list = $('ol#list1').find("li")
             var list_ids = [] 
            $(li_list).each(function() {
              var id = $(this).attr("id")
                 list_ids.push(id)
                var li = $(this);
      
             
              
                $("ol#list2").append(li);
            })

               $("input[name='item[itemcode]']").val(list_ids)


  })



        $('button[data-original-title="un combo new"]').click(function() {
            var li_list = $('ol#list2').find("li")
            $(li_list).each(function() {

                var li = $(this);
           
                
                $("ol#list1").append(li);
            })


        })



  $('button[data-original-title="combo branch"]').click(function() {
            var li_list = $('ol#list5').find("li")
             var list_ids = [] 
            $(li_list).each(function() {
              var id = $(this).attr("id")
                 list_ids.push(id)
                var li = $(this);
      
             
              
                $("ol#list6").append(li);
            })

               $("input[name='branc[branch]']").val(list_ids)


  })



        $('button[data-original-title="un combo branch"]').click(function() {
            var li_list = $('ol#list6').find("li")
            $(li_list).each(function() {

                var li = $(this);
           
                
                $("ol#list5").append(li);
            })


        })



  $('button[data-original-title="combo branch2"]').click(function() {
            var li_list = $('ol#list7').find("li")
             var list_ids = [] 
            $(li_list).each(function() {
              var id = $(this).attr("id")
                 list_ids.push(id)
                var li = $(this);
      
             
              
                $("ol#list8").append(li);
            })

               $("input[name='branc[branch]']").val(list_ids)


  })



        $('button[data-original-title="un combo branch2"]').click(function() {
            var li_list = $('ol#list8').find("li")
            $(li_list).each(function() {

                var li = $(this);
           
                
                $("ol#list7").append(li);
            })


        })



          $('button[data-original-title="dis"]').click(function() {
            var li_list = $('ol#dis1').find("li")
             var list_ids = [] 
            $(li_list).each(function() {
              var id = $(this).attr("id")
                 list_ids.push(id)
                var li = $(this);
      
             
              
                $("ol#dis2").append(li);
            })

               $("input[name='cat']").val(list_ids)


  })



        $('button[data-original-title="un dis"]').click(function() {
            var li_list = $('ol#dis2').find("li")
            $(li_list).each(function() {

                var li = $(this);
           
                
                $("ol#dis1").append(li);
            })


        })


 $('button[data-original-title="diss"]').click(function() {
            var li_list = $('ol#dis3').find("li")
             var list_ids = [] 
            $(li_list).each(function() {
              var id = $(this).attr("id")
                 list_ids.push(id)
                var li = $(this);
      
             
              
                $("ol#dis4").append(li);
            })

               $("input[name='items']").val(list_ids)


  })



        $('button[data-original-title="un diss"]').click(function() {
            var li_list = $('ol#dis4').find("li")
            $(li_list).each(function() {

                var li = $(this);
           
                
                $("ol#dis3").append(li);
            })


        })

$('select[name="branchid"]').on('hidden.bs.select', function (e) {
 var d = $("select#branch_list").val()

  var branch_id=  localStorage.setItem("new_brand", d);


    window.location.reload();
     
});


$('select[name="year"]').on('hidden.bs.select', function (e) {
 var d = $("select#year").val()

  var year=  localStorage.setItem("year", d);


    window.location.reload();
     
});

 

});




