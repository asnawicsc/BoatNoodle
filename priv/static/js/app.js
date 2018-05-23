// for phoenix_html support, including form and button helpers
// copy the following scripts into your javascript bundle:
// * https://raw.githubusercontent.com/phoenixframework/phoenix_html/v2.10.0/priv/static/phoenix_html.js


      $(document).ready(function(){


         $('.datepicker').datetimepicker({
            format: 'YYYY-MM-DD',
            icons: {
                time: "fa fa-clock-o",
                date: "fa fa-calendar",
                up: "fa fa-chevron-up",
                down: "fa fa-chevron-down",
                previous: 'fa fa-chevron-left',
                next: 'fa fa-chevron-right',
                today: 'fa fa-screenshot',
                clear: 'fa fa-trash',
                close: 'fa fa-remove'
            }
         });

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


   
            default:
                console.log("default")
        }





      })
