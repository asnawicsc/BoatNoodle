defmodule BoatNoodle.BN.ItemSubcat do
  use Ecto.Schema
  import Ecto.Changeset
  require IEx
  @primary_key false
  schema "item_subcat" do
    field(:subcatid, :integer, primary_key: true)
    field(:created_at, :utc_datetime)
    field(:enable_disc, :integer, default: 0)
    field(:include_spend, :integer, default: 0)
    field(:is_activate, :integer, default: 0)
    field(:is_categorize, :integer, default: 0)
    field(:is_comboitem, :integer, default: 0)
    field(:is_default_combo, :integer, default: 0)
    field(:is_delete, :integer, default: 0)
    field(:item_start_hour, :integer, default: 0)
    field(:item_end_hour, :integer, default: 0)
    field(:is_print, :integer, default: 0)
    field(:itemcatid, :string)
    field(:itemcode, :string, default: "UK")
    field(:itemdesc, :string)
    field(:itemimage, :binary, default: "")
    field(:itemname, :string)
    field(:itemprice, :decimal, default: 0)
    field(:part_code, :string)
    field(:price_code, :string, default: "A")
    field(:product_code, :string)
    field(:updated_at, :utc_datetime)
    field(:brand_id, :integer, primary_key: true)
    field(:disc_reminder, :integer, default: 0)
    field(:tagdesc, :string)
    field(:printer, :string)
  end

  @doc false
  def changeset(item_subcat, attrs, user_id, action) do
    item_subcat =
      item_subcat
      |> cast(attrs, [
        :tagdesc,
        :printer,
        :disc_reminder,
        :item_start_hour,
        :item_end_hour,
        :brand_id,
        :subcatid,
        :itemcatid,
        :itemname,
        :itemcode,
        :product_code,
        :price_code,
        :part_code,
        :itemdesc,
        :itemprice,
        :itemimage,
        :is_categorize,
        :is_activate,
        :is_comboitem,
        :is_default_combo,
        :is_delete,
        :enable_disc,
        :include_spend,
        :is_print,
        :updated_at,
        :created_at
      ])
      |> unique_constraint(:subcatid, name: "PRIMARY")

    if action == "new" or action == "edit" do
    else
      if action == "Update" do
        attrs = Map.put(attrs, "subcatid", item_subcat.data.subcatid)
      end

      BoatNoodle.BN.ModalLog.changeset(%BoatNoodle.BN.ModalLog{}, %{
        name: "item_subcat",
        user_id: user_id,
        description: Poison.encode!(attrs),
        action: action
      })
      |> BoatNoodle.Repo.insert()
    end

    item_subcat
  end
end
