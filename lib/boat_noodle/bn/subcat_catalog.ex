defmodule BoatNoodle.BN.SubcatCatalog do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false
  schema "subcat_catalog" do
    field(:id, :integer, primary_key: true)
    field(:catalog_id, :integer, default: 0)
    field(:end_date, :date)
    field(:price, :decimal)
    field(:start_date, :date)
    field(:subcat_id, :integer)
    field(:is_active, :integer, default: 0)
    field(:is_combo, :integer, default: 0)
    field(:brand_id, :integer)
  end

  @doc false
  def changeset(subcat_catalog, attrs) do
    subcat_catalog
    |> cast(attrs, [
      :id,
      :brand_id,
      :is_active,
      :subcat_id,
      :catalog_id,
      :start_date,
      :end_date,
      :is_combo,
      :price
    ])
  end
end
