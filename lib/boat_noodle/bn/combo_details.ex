defmodule BoatNoodle.BN.ComboDetails do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "combo_details" do
    field :combo_id, :integer, primary_key: true
    field :combo_item_code, :string
    field :combo_item_id, :integer
    field :combo_item_name, :string
    field :combo_item_qty, :integer
    field :combo_qty, :integer
    field :id, :integer
    field :menu_cat_id, :integer
    field :top_up, :decimal
    field :unit_price, :decimal
    field :update_qty, :integer

  end

  @doc false
  def changeset(combo_details, attrs) do
    combo_details
    |> cast(attrs, [:id, :menu_cat_id, :combo_id, :combo_qty, :combo_item_id, :combo_item_name, :combo_item_code, :combo_item_qty, :update_qty, :unit_price, :top_up])
    |> validate_required([:id, :menu_cat_id, :combo_id, :combo_qty, :combo_item_id, :combo_item_name, :combo_item_code, :combo_item_qty, :update_qty, :unit_price, :top_up])
  end
end
