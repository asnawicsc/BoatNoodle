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

  pipeline :management do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", BoatNoodleWeb do
    # Use the default browser stack
    pipe_through(:management)

    get("/management_login", UserController, :login_management)
  end

  # Other scopes may use custom stacks.
  scope "/:brand/api", BoatNoodleWeb do
    pipe_through(:api)
    get("/sales", PageController, :webhook_get)
    post("/sales", PageController, :webhook_post)
  end

  scope "/:brand", BoatNoodleWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    post("/sales_graph_by_year", PageController, :sales_graph_by_year)
    post("/sales_bar_graph_by_year", SalesMasterController, :sales_bar_graph_by_year)

    resources("/menu_item", MenuItemController)
    resources("/brand", BrandController)
    post("/update_brand", BrandController, :update_brand)
    post("/update_brand_logo", BrandController, :update_brand_logo)
    get("/combos", MenuItemController, :combos)
    resources("/category", CategoryController)
    resources("/remark", RemarkController)
    resources("/menu_catalog", MenuCatalogController)
    resources("/menu_catalog_master", MenuCatalogMasterController)
    resources("/discount_category", DiscountCategoryController)
    resources("/discount_item", DiscountItemController)
    resources("/discount_catalog_master", DiscountCatalogMasterController)
    resources("/discount_catalog", DiscountCatalogController)
    get("/discount_discounts_items", DiscountCatalogController, :discount_discounts_items)
    resources("/discount", DiscountController)
    get("/discount_category_details/:id", DiscountController, :discount_category_details)
    get("/discount_item_details/:id", DiscountController, :discount_item_details)
    get("/discount_catalog_details/:id", DiscountController, :discount_catalog_details)
    post("/edit_discount_detail", DiscountController, :edit_discount_detail)

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
    get("/edit_combo/:subcatid/:price_code", ItemSubcatController, :edit_combo)
    post("/edit_combo_detail", ItemSubcatController, :edit_combo_detail)
    post("/combos/new", ItemSubcatController, :combo_create)
    post("/combos/combo_create_price", ItemSubcatController, :combo_create_price)
    post("/combos/combo_create_price_update", ItemSubcatController, :combo_create_price_update)
    post("/combos/combo_create_price_unselect", ItemSubcatController, :combo_create_price_unselect)
    post("/combos/branch", ItemSubcatController, :combo_branch)
    post("/combos/unselect", ItemSubcatController, :combo_unselect)
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
end
