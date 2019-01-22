defmodule BoatNoodle.BN.ComboCatalog do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false
  schema "combo_catalog" do
    field(:id, :integer, primary_key: true)
    field(:brand_id, :integer)
    field(:subcat_id, :integer)
    field(:combo_item_id, :integer)
    field(:is_active, :integer)
    field(:start_date, :date)
    field(:end_date, :date)
    field(:price, :decimal)
    field(:to_up, :decimal)
    field(:catalog_id, :integer)
  end

  @doc false
  def changeset(combo_catalog, attrs) do
    combo_catalog
    |> cast(attrs, [
      :id,
      :subcat_id,
      :combo_item_id,
      :is_active,
      :price,
      :brand_id,
      :start_date,
      :end_date,
      :to_up,
      :catalog_id
    ])
  end
end
