defmodule BoatNoodle.BN.Remark do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "itemsremak" do
    field(:itemsremarkid, :integer, primary_key: true)
    field(:remark, :string)
    field(:target_cat, :integer)
    field(:target_item, :integer)
    field(:brand_id, :integer, primary_key: true)
  end

  @doc false
  def changeset(remark, attrs) do
    remark
    |> cast(attrs, [:brand_id, :itemsremarkid, :remark, :target_cat, :target_item])
  end
end
