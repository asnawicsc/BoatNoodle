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

    get("/index", PageController, :index)
    post("/sales_graph_by_year", PageController, :sales_graph_by_year)
    post("/sales_bar_graph_by_year", SalesMasterController, :sales_bar_graph_by_year)

    resources("/menu_item", MenuItemController)
    resources("/category", CategoryController)
    resources("/remark", RemarkController)
    resources("/menu_catalog", MenuCatalogController)
    resources("/menu_catalog_master", MenuCatalogMasterController)
    resources("/discount_category", DiscountCategoryController)
    resources("/discount_item", DiscountItemController)
    resources("/discount_catalog_master", DiscountCatalogMasterController)
    resources("/discount_catalog", DiscountCatalogController)
    resources("/tag", TagController)
    resources("/tag_catalog", TagCatalogController)
    resources("/tag_items", TagItemsController)
    resources("/staff", StaffController)
    resources("/user", UserController)

    get("/edit_user", UserController, :edit_user)
    get("/login", UserController, :login)
    post("/authenticate_login", UserController, :authenticate_login)
    get("/logout", UserController, :logout)

    resources("/organization", OrganizationController)
    resources("/branch", BranchController)
    resources("/payment_type", PaymentTypeController)
    resources("/sales_master", SalesMasterController)
    resources("/sales", SalesController)

    get("/transaction", SalesController, :transaction)

    get("/hourly_pax_summary", SalesController, :hourly_pax_summary)
    post("/get_date", SalesController, :get_date)
    post("/get_hourly_sales", SalesController, :get_hourly_sales)
    post("/get_hourly_transaction", SalesController, :get_hourly_transaction)

    get("/hourly_sales_summary", SalesController, :hourly_sales_summary)
    get("/hourly_transaction_summary", SalesController, :hourly_transaction_summary)

    get("/item_sold", SalesController, :item_sold)
    get("/item_sales_detail", SalesController, :item_sales_detail)
    get("/:id/detail_invoice", SalesController, :detail_invoice)

    get("/discount", SalesController, :discount)
    get("/discount_summary", SalesController, :discount_summary)

    get("/voided_order", SalesController, :voided_order)

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
  end

  # Other scopes may use custom stacks.
  # scope "/api", BoatNoodleWeb do
  #   pipe_through :api
  # end
end
