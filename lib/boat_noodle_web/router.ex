defmodule BoatNoodleWeb.Router do
  use BoatNoodleWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(BoatNoodle.Authorization)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", BoatNoodleWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    post("/sales_graph_by_year", PageController, :sales_graph_by_year)
    post("/sales_bar_graph_by_year", SalesMasterController, :sales_bar_graph_by_year)

    resources("/menu_item", MenuItemController)
    get("/combos", MenuItemController, :combos)
    resources("/category", CategoryController)
    resources("/remark", RemarkController)
    resources("/menu_catalog", MenuCatalogController)
    resources("/menu_catalog_master", MenuCatalogMasterController)
    resources("/discount_category", DiscountCategoryController)
    resources("/discount_item", DiscountItemController)
    resources("/discount_catalog_master", DiscountCatalogMasterController)
    resources("/discount_catalog", DiscountCatalogController)
    resources("/discount", DiscountController)

    resources("/tag", TagController)
    resources("/tag_catalog", TagCatalogController)
    resources("/tag_items", TagItemsController)
    resources("/staff", StaffController)
    resources("/user", UserController)

    get("/edit_user", UserController, :edit_user)
    get("/login", UserController, :login)
    post("/authenticate_login", UserController, :authenticate_login)
    get("/logout", UserController, :logout)
    get("/edit_profile/:id", UserController, :edit)
    post("/update_profile", UserController, :update_profile)
    get("/forget_password", UserController, :forget_password)
    post("/forget_password_email", UserController, :forget_password_email)

    resources("/organization", OrganizationController)
    resources("/branch", BranchController)
    get("/branch/:id/printers", BranchController, :printers)
    resources("/payment_type", PaymentTypeController)
    resources("/sales_master", SalesMasterController)
    resources("/sales", SalesController)

    get("/summary", SalesController, :summary)
    get("/item_sales", SalesController, :item_sales)
    get("/discounts", SalesController, :discounts)
    get("/voided", SalesController, :voided)
    get("/sales_chart", SalesController, :sales_chart)

    get("/detail_invoice/:branchid/:invoiceno", SalesController, :detail_invoice)

    get("/csv_compare_category_qty", SalesController, :csv_compare_category_qty)
    post("/create_cv", SalesController, :create_cv)

    resources("/gallery", GalleryController)
    resources("/picture", PictureController)
    post("/update_profile_picture/:id", UserController, :update_profile_picture)

    resources("/tax", TaxController)
    resources("/cash_in_out", CashInOutController)
    resources("/branch_item_deactivate", BranchItemDeactivateController)
    resources("/cashier_session", CashierSessionController)
    resources("/cash_in_out_type", CashInOutTypeController)
    resources("/combo_details", ComboDetailsController)
    resources("/combo_map", ComboMapController)
    resources("/discount_type", DiscountTypeController)
    resources("/item_customized", ItemCustomizedController)
    resources("/migrations", MigrationsController)
    resources("/password_resets", PasswordResetsController)
    resources("/rpt_cashier_eod", RPTCASHIEREODController)
    resources("/rpt_hourly_outlet", RPTHOURLYOUTLETController)
    resources("/rpt_transaction", RPTTRANSACTIONController)
    resources("/salesdetailcust", SalesDetailCustController)
    resources("/staff_log_session", StaffLogSessionController)
    resources("/staff_type", StaffTypeController)
    resources("/user_branch_access", UserBranchAccessController)
    resources("/user_pwd", UserPwdController)
    resources("/user_role", UserRoleController)
    resources("/voiditems", VoidItemsController)
    resources("/salespayment", SalesPaymentController)
    resources("/item_subcat", ItemSubcatController)
    get("/items/:subcatid", ItemSubcatController, :item_show)
    get("/items/:subcatid/edit", ItemSubcatController, :item_edit)
    get("/combos/new", ItemSubcatController, :combo_new)
    get("/combos/:subcatid", ItemSubcatController, :combo_show)
    get("/edit_combo/:subcatid", ItemSubcatController, :edit_combo)
    post("/combos/new", ItemSubcatController, :combo_create)
    post("/combos/combo_create_price", ItemSubcatController, :combo_create_price)
    post("/combos/combo_create_price_update", ItemSubcatController, :combo_create_price_update)
    post("/combos/finish", ItemSubcatController, :combo_finish)
    resources("/itemcat", ItemCatController)
    resources("/organization", OrganizationController)
    resources("/branch", BranchController)
    resources("/payment_type", PaymentTypeController)
    resources("/sales_master", SalesMasterController)
    resources("/sales", SalesController)
    resources("/tax", TaxController)
    resources("/cash_in_out", CashInOutController)
    resources("/branch_item_deactivate", BranchItemDeactivateController)
    resources("/cashier_session", CashierSessionController)
    resources("/cash_in_out_type", CashInOutTypeController)
    resources("/combo_details", ComboDetailsController)
    resources("/combo_map", ComboMapController)
    resources("/discount_type", DiscountTypeController)
    resources("/item_customized", ItemCustomizedController)
    resources("/migrations", MigrationsController)
    resources("/password_resets", PasswordResetsController)
    resources("/rpt_cashier_eod", RPTCASHIEREODController)
    resources("/rpt_hourly_outlet", RPTHOURLYOUTLETController)
    resources("/rpt_transaction", RPTTRANSACTIONController)
    resources("/salesdetailcust", SalesDetailCustController)
    resources("/staff_log_session", StaffLogSessionController)
    resources("/staff_type", StaffTypeController)
    resources("/user_branch_access", UserBranchAccessController)
    resources("/user_pwd", UserPwdController)
    resources("/user_role", UserRoleController)
    resources("/voiditems", VoidItemsController)
    resources("/salespayment", SalesPaymentController)
    get("/*path", PageController, :no_page_found)
  end

  # Other scopes may use custom stacks.
  # scope "/api", BoatNoodleWeb do
  #   pipe_through :api
  # end
end
