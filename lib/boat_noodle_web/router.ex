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

  pipeline :report_layout do
    plug(:put_layout, {BoatNoodleWeb.LayoutView, :report_layout})
  end

  # Other scopes may use custom stacks.
  scope "/api", BoatNoodleWeb do
    pipe_through(:api)
    get("/:code/get_api2", BranchController, :get_api2)
    get("/sales", ApiController, :webhook_get)
    post("/sales", ApiController, :webhook_post)
    post("/sales_v2", ApiController, :webhook_post_v2)
    post("/operations", ApiController, :webhook_post_operations)
  end

  scope "/", BoatNoodleWeb do
    # Use the default browser stack
    pipe_through([:management, :report_layout])

    get("/", PageController, :report_login)
    get("/reports/logout", PageController, :logout)
    post("/report_authenticate_login", PageController, :authenticate_login)
    get("/get_brands", PageController, :get_brands)
    get("/reports", PageController, :report_index)
    get("/top_sales", SalesController, :top_sales)
    get("/logout", UserController, :logout)
    get("/forget_password", UserController, :forget_password)
    post("/forget_password_email", UserController, :forget_password_email)
  end

  scope "/:brand", BoatNoodleWeb do
    pipe_through(:browser)

    get("/data_source/:query", SalesController, :query)

    get("/", PageController, :index2)
    post("/sales_graph_by_year", PageController, :sales_graph_by_year)
    post("/sales_bar_graph_by_year", SalesMasterController, :sales_bar_graph_by_year)
    resources("/history_data", HistoryDataController)
    resources("/menu_item", MenuItemController)
    resources("/brand", BrandController)
    post("/create", BrandController, :create)
    post("/update_brand", BrandController, :update_brand)
    post("/update_brand_logo", BrandController, :update_brand_logo)
    get("/tbl_syn", BranchController, :tbl_syn)
    get("/tbl_syn_combo", BranchController, :tbl_syn_combo)
    get("/combos", MenuItemController, :combos)
    resources("/category", CategoryController)
    resources("/remark", RemarkController)
    resources("/menu_catalog", MenuCatalogController)
    get("/list_printer", TagController, :list_printer)
    get("/list_menu_catalog", MenuCatalogController, :list_menu_catalog)
    get("/insert_into_catalog", MenuCatalogController, :insert_into_catalog)
    get("/remove_from_catalog", MenuCatalogController, :remove_from_catalog)
    get("/list_menu_catalog_combo", MenuCatalogController, :list_menu_catalog_combo)
    get("/insert_into_catalog_combo", MenuCatalogController, :insert_into_catalog_combo)
    get("/remove_from_catalog_combo", MenuCatalogController, :remove_from_catalog_combo)
    resources("/menu_catalog_master", MenuCatalogMasterController)
    resources("/discount_category", DiscountCategoryController)
    resources("/discount_item", DiscountItemController)
    resources("/discount_catalog_master", DiscountCatalogMasterController)
    resources("/discount_catalog", DiscountCatalogController)
    get("/discount_discounts_items", DiscountCatalogController, :discount_discounts_items)
    resources("/discount", DiscountController)
    get("/discount_category/:id/edits", DiscountController, :discount_category_details)
    get("/discount_category_new", DiscountController, :discount_category_new)
    get("/discount_catalog_new", DiscountController, :discount_catalog_new)
    get("/discount_item_new", DiscountController, :discount_item_new)
    get("/discount_item/:id/edits", DiscountController, :discount_item_details)
    get("/discount_catalog/:id/edits", DiscountController, :discount_catalog_details)
    post("/edit_discount_detail", DiscountController, :edit_discount_detail)
    post("/create_discount_category_new", DiscountController, :create_discount_category_new)
    post("/create_discount_item_new", DiscountController, :create_discount_item_new)
    post("/create_discount_catalog_new", DiscountController, :create_discount_catalog_new)
    get("/list_discount_catalog", DiscountCatalogController, :list_discount_catalog)
    get("/discount_insert_into_catalog", DiscountCatalogController, :discount_insert_into_catalog)
    get("/discount_remove_from_catalog", DiscountCatalogController, :discount_remove_from_catalog)
    get("/list_discount_catalog2", DiscountCatalogController, :list_discount_catalog2)
    get("/list_discount_catalog3", DiscountCatalogController, :list_discount_catalog3)
    get("/show_voucher", ItemSubcatController, :show_voucher)
    post("/upload_voucher", DiscountController, :upload_voucher)
    get("/csv", MenuItemController, :export)
    get("/sync_to_client", MenuItemController, :sync_to_client)
    get("/csv_discount", DiscountController, :export)
    get("/quickbook", SalesController, :quickbook)
    get("/sql_accounting", SalesController, :sql_accounting)
    get("/excel", SalesController, :excel)
    get("/tables", SalesController, :tables)
    post("/item_sales_report_csv", SalesController, :item_sales_report_csv)
    post("/item_sales_outlet_csv", SalesController, :item_sales_outlet_csv)
    post("/item_sales_outlet_csv_v2", SalesController, :item_sales_outlet_csv_v2)
    # post("/combo_item_sales_csv", SalesController, :combo_item_sales_csv)
    post("/combo_item_sales_csv", SalesController, :item_sales_outlet_csv2)
    post("/discount_item_report_csv", SalesController, :discount_item_report_csv)
    post("/discount_item_detail_report_csv", SalesController, :discount_item_detail_report_csv)
    get("/item_transaction_report", SalesController, :item_transaction_report)
    get("/export_to_csv_group_by_branch", SalesController, :export_to_csv_group_by_branch)

    get("/export_to_csv_summary", SalesController, :export_to_csv_summary)
    get("/monthly_sales_csv", SalesController, :monthly_sales_csv)

    get(
      "/discount_insert_into_catalog3",
      DiscountCatalogController,
      :discount_insert_into_catalog3
    )

    get(
      "/discount_remove_from_catalog3",
      DiscountCatalogController,
      :discount_remove_from_catalog3
    )

    get("/list_discount_catalog4", DiscountCatalogController, :list_discount_catalog4)

    get(
      "/discount_insert_into_catalog4",
      DiscountCatalogController,
      :discount_insert_into_catalog4
    )

    get(
      "/discount_remove_from_catalog4",
      DiscountCatalogController,
      :discount_remove_from_catalog4
    )

    get("/discount_catalog_copy/:id", DiscountController, :discount_catalog_copy)
    post("/create_discount_catalog_copy", DiscountController, :create_discount_catalog_copy)

    get(
      "/discount_insert_into_catalog2",
      DiscountCatalogController,
      :discount_insert_into_catalog2
    )

    get(
      "/discount_remove_from_catalog2",
      DiscountCatalogController,
      :discount_remove_from_catalog2
    )

    resources("/unauthorize_menu", UnauthorizeMenuController)
    get("/menu", UnauthorizeMenuController, :menu)
    post("/update_menu", UnauthorizeMenuController, :update_menu)

    post("/edit_discount_catalog_detail", DiscountController, :edit_discount_catalog_detail)
    post("/edit_discount_category_detail", DiscountController, :edit_discount_category_detail)
    post("/edit_discount_item_details", DiscountController, :edit_discount_item_details)

    resources("/tag", TagController)
    get("/check_printer", TagController, :check_printer)
    get("/toggle_printer/edit", TagController, :toggle_printer)
    get("/toggle_printer_combo/edit", TagController, :toggle_printer_combo)
    resources("/tag_catalog", TagCatalogController)
    resources("/tag_items", TagItemsController)
    resources("/staff", StaffController)
    get("/staff/:id/regenerate_pin", StaffController, :regenerate_pin)
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
    get("/branches_status", BranchController, :statuses)

    get("/branch/:id/printers", BranchController, :printers)
    get("/branch/:id/api_log", BranchController, :api_log)
    get("/branch/:id/populate_printers", BranchController, :populate_printers)
    resources("/payment_type", PaymentTypeController)
    resources("/sales_master", SalesMasterController)
    resources("/sales", SalesController)
    get("/payment_type_v2", PaymentTypeController, :payment_type_v2)
    get("/payment_types", PaymentTypeController, :payment_types)
    get("/summary", SalesController, :summary)
    get("/item_sales", SalesController, :item_sales)
    get("/discounts", SalesController, :discounts)
    get("/voided", SalesController, :voided)
    get("/sales_chart", SalesController, :sales_chart)
    get("/payment_type/:id/edits", PaymentTypeController, :edits)
    post("/edit_payment_type", PaymentTypeController, :edit_payment_type)

    get("/detail_invoice/:branchid/:invoiceno", SalesController, :detail_invoice)
    get("/report", SalesController, :report)

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
    get("/items/:subcatid/date_prices", ItemSubcatController, :date_prices)
    post("/items/:subcatid/date_prices/new_date_price", ItemSubcatController, :new_date_prices)

    get("/discount/:discountitemsid/date_discount", DiscountController, :date_discount)

    get(
      "/items/:subcatid/date_prices/delete_date_price/:id",
      ItemSubcatController,
      :delete_date_price
    )

    post(
      "/discount/:discountitemsid/discount_date/new_discount_date",
      DiscountController,
      :new_discount_date
    )

    get(
      "/discount/:discountitemsid/discount_date/delete_discount_date/:id",
      DiscountController,
      :delete_discount_date
    )

    get("/items/:subcatid/edit", ItemSubcatController, :item_edit)
    get("/combos/new", ItemSubcatController, :combo_new)
    get("/combos/:subcatid/add_item", ItemSubcatController, :add_item)
    post("/combos/:subcatid/post_item", ItemSubcatController, :post_add_item)
    get("/combos/:subcatid", ItemSubcatController, :combo_show)

    get("/combos/:subcatid/date_prices", ItemSubcatController, :combo_date_prices)

    post(
      "/combos/:subcatid/date_prices/new_date_price",
      ItemSubcatController,
      :combo_new_date_prices
    )

    get(
      "/combos/:subcatid/date_prices/delete_date_price/:id",
      ItemSubcatController,
      :combo_delete_date_price
    )

    get("/edit_combo/:subcatid/:price_code", ItemSubcatController, :edit_combo)
    post("/edit_combo_detail", ItemSubcatController, :edit_combo_detail)
    post("/combos/new", ItemSubcatController, :combo_create)
    post("/combos/combo_create_price", ItemSubcatController, :combo_create_price)
    post("/combos/combo_create_price_update", ItemSubcatController, :combo_create_price_update)
    post("/user_branch_accesss", UserBranchAccessController, :update_branch_access)

    post(
      "/combos/combo_create_price_unselect",
      ItemSubcatController,
      :combo_create_price_unselect
    )

    post("/combos/branch", ItemSubcatController, :combo_branch)
    post("/combos/unselect", ItemSubcatController, :combo_unselect)
    post("/combos/finish", ItemSubcatController, :combo_finish)

    resources("/itemcat", ItemCatController)
    resources("/branch", BranchController)
    resources("/payment_type", PaymentTypeController)
    post("/create_payment_type", PaymentTypeController, :create_payment_type)
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
    resources("/api_log", ApiLogController)
    resources("/vouchers", VoucherController)
    resources("/modal_logs", ModalLogController)
    get("/advance", PageController, :advance)
    post("/upload_menu_item", ItemSubcatController, :upload_menu_item)

    get("/combo/combo_item_report_csv", SalesController, :combo_item_report_csv)
    get("/experiment", PageController, :experiment)
    get("/experiment2", PageController, :experiment2)
    get("/experiment3", PageController, :experiment3)
    get("/experiment4", PageController, :experiment4)

    resources("/reports", ReportController)
    get("/*path", PageController, :no_page_found)
  end
end
