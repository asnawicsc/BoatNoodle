defmodule BoatNoodleWeb.Router do
  use BoatNoodleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BoatNoodleWeb do
    pipe_through :browser # Use the default browser stack

    get "/index", PageController, :index

    resources "/menu_item", MenuItemController
    resources "/category", CategoryController
    resources "/remark", RemarkController
    resources "/menu_catalog", MenuCatalogController
    resources "/menu_catalog_master", MenuCatalogMasterController
    resources "/discount_category", DiscountCategoryController
    resources "/discount_item", DiscountItemController
    resources "/discount_catalog_master", DiscountCatalogMasterController
    resources "/discount_catalog", DiscountCatalogController
    resources "/tag", TagController
    resources "/tag_catalog", TagCatalogController
    resources "/tag_items", TagItemsController
    resources "/staff", StaffController
    resources "/user", UserController

    get "/edit_user", UserController, :edit_user

    resources "/organization", OrganizationController
    resources "/branch", BranchController
    resources "/payment_type", PaymentTypeController
    resources "/sales_master", SalesMasterController
    resources "/sales", SalesController
    resources "/tax", TaxController
    resources "/cash_in_out", CashInOutController














  end

  # Other scopes may use custom stacks.
  # scope "/api", BoatNoodleWeb do
  #   pipe_through :api
  # end
end
