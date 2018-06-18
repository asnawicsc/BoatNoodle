defmodule BoatNoodle.BN.ItemCat do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "item_cat" do
    field(:category_type, :string)
    field(:created_at, :utc_datetime)
    field(:is_default, :integer)
    field(:is_delete, :integer)
    field(:itemcatcode, :string)
    field(:itemcatdesc, :string)
    field(:itemcatid, :integer, primary_key: true)
    field(:itemcatname, :string)
    field(:updated_at, :utc_datetime)
    field(:brand_id, :integer, primary_key: true)
  end

  @doc false
  def changeset(item_cat, attrs) do
    item_cat
    |> cast(attrs, [
      :brand_id,
      :itemcatid,
      :itemcatcode,
      :itemcatname,
      :itemcatdesc,
      :is_default,
      :category_type,
      :is_delete,
      :created_at,
      :updated_at
    ])
  end
end
