defmodule BoatNoodleWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use BoatNoodleWeb, :controller
      use BoatNoodleWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: BoatNoodleWeb
      import Plug.Conn
      import BoatNoodleWeb.Router.Helpers
      import BoatNoodleWeb.Gettext

      alias BoatNoodle.Repo
      alias BoatNoodle.View
      import Ecto.Query
      alias BoatNoodle.BN

      alias BoatNoodle.BN.{
        Discount,
        DiscountCatalog,
        DiscountCatalogMaster,
        DiscountCategory,
        DiscountItem,
        DiscountType,
        ItemCat,
        MenuCatalogMaster,
        Organization,
        PaymentType,
        Remark,
        Sales,
        SalesDetailCust,
        SalesMaster,
        SalesPayment,
        Staff,
        StaffType,
        Tag,
        TagCatalog,
        TagItems,
        Tax,
        User,
        UserBranchAccess,
        UserRole,
        VoidItems,
        ComboMap,
        ComboDetails,
        Category,
        MenuCatalog,
        ItemSubcat,
        Branch,
        Tag,
        Brand,
        ApiLog,
        Voucher,
        HistoryData,
        ModalLog,
        DatePrice
      }
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/boat_noodle_web/templates",
        namespace: BoatNoodleWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import BoatNoodleWeb.Router.Helpers
      import BoatNoodleWeb.ErrorHelpers
      import BoatNoodleWeb.Gettext
      import Ecto.Query
      alias BoatNoodle.Repo
      alias BoatNoodle.BN

      alias BoatNoodle.BN.{
        Discount,
        DiscountCatalog,
        DiscountCatalogMaster,
        DiscountCategory,
        DiscountItem,
        DiscountType,
        ItemCat,
        MenuCatalogMaster,
        Organization,
        PaymentType,
        Remark,
        Sales,
        SalesDetailCust,
        SalesMaster,
        SalesPayment,
        Staff,
        StaffType,
        Tag,
        TagCatalog,
        TagItem,
        Tax,
        User,
        UserBranchAccess,
        UserRole,
        VoidItems,
        ComboMap,
        ComboDetails,
        Category,
        MenuCatalog,
        ItemSubcat,
        Branch,
        Tag,
        Brand,
        ApiLog,
        Voucher,
        HistoryData,
        DatePrice
      }
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import BoatNoodleWeb.Gettext
      alias BoatNoodle.Repo
      alias BoatNoodle.BN

      alias BoatNoodle.BN.{
        Discount,
        DiscountCatalog,
        DiscountCatalogMaster,
        DiscountCategory,
        DiscountItem,
        DiscountType,
        ItemCat,
        MenuCatalogMaster,
        Organization,
        PaymentType,
        Remark,
        Sales,
        SalesDetailCust,
        SalesMaster,
        SalesPayment,
        Staff,
        StaffType,
        Tag,
        TagCatalog,
        TagItem,
        Tax,
        User,
        UserBranchAccess,
        UserRole,
        VoidItems,
        ComboMap,
        ComboDetails,
        Category,
        MenuCatalog,
        ItemSubcat,
        Branch,
        Tag,
        Brand,
        ApiLog,
        Voucher,
        HistoryData,
        DatePrice
      }

      import Ecto.Query
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
