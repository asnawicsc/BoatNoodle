defmodule BoatNoodleWeb.DiscountController do
  use BoatNoodleWeb, :controller
require IEx
  alias BoatNoodle.BN
  alias BoatNoodle.BN.Discount
  alias BoatNoodle.BN.DiscountItem
  alias BoatNoodle.BN.ItemCat
  alias BoatNoodle.BN.DiscountType
  alias BoatNoodle.BN.ItemSubcat


  def index(conn, _params) do
    discount = BN.list_discount()

    discount_details =
      Repo.all(
        from(
          s in Discount,
          select: %{
            discountid: s.discountid,
            discount_name: s.discname,
            discount_description: s.descriptions,
            activate: s.disc_qty
          }
        )
      )

       discount_items =
      Repo.all(
        from(
          s in DiscountItem,
          left_join: b in Discount, where: b.discountid==s.discountid,
          left_join: c in ItemCat, where: s.target_cat==c.itemcatid,
          left_join: d in ItemSubcat, where: s.is_targetmenuitems==d.subcatid,
          select: %{
            discountitemsid: s.discountitemsid,
            discitemsname: s.discitemsname,
            description: s.descriptions,
            discamtpercentage: s.discamtpercentage,
            discountcategory: b.discname,
            target_menu_category: c.itemcatname,
            target_menu_item: d.itemname,
            activate: s.disc_qty
          }
        )
      )

      discount_catalog =
      Repo.all(
        from(
          s in DiscountCatalog,
          select: %{
            id: s.id,
            name: s.name
          }
        )
      )
    render(conn, "index.html",discount_catalog: discount_catalog,discount_items: discount_items,discount_details: discount_details, discount: discount)
  end

   def discount_category_details(conn, %{"id" => id}) do

    discount=BN.get_discount!(id)

    disc_type=Repo.all(from s in DiscountType)

   
   
    render(conn, "discount_category_details.html",disc_type: disc_type,discount: discount, id: id)
  end

   def edit_discount_detail(conn, params) do
   IEx.pry
  end

  def new(conn, _params) do
    changeset = BN.change_discount(%Discount{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"discount" => discount_params}) do
    case BN.create_discount(discount_params) do
      {:ok, discount} ->
        conn
        |> put_flash(:info, "Discount created successfully.")
        |> redirect(to: discount_path(conn, :show, discount))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    discount = BN.get_discount!(id)
    render(conn, "show.html", discount: discount)
  end

  def edit(conn, %{"id" => id}) do
    discount = BN.get_discount!(id)
    changeset = BN.change_discount(discount)
    render(conn, "edit.html", discount: discount, changeset: changeset)
  end

  def update(conn, %{"id" => id, "discount" => discount_params}) do
    discount = BN.get_discount!(id)

    case BN.update_discount(discount, discount_params) do
      {:ok, discount} ->
        conn
        |> put_flash(:info, "Discount updated successfully.")
        |> redirect(to: discount_path(conn, :show, discount))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", discount: discount, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    discount = BN.get_discount!(id)
    {:ok, _discount} = BN.delete_discount(discount)

    conn
    |> put_flash(:info, "Discount deleted successfully.")
    |> redirect(to: discount_path(conn, :index))
  end
end
