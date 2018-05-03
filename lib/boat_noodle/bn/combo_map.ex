defmodule BoatNoodle.BN.ComboMap do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "combo_map" do
    field :linkid, :integer, primary_key: true
    field :subcatid, :integer

  end

  @doc false
  def changeset(combo_map, attrs) do
    combo_map
    |> cast(attrs, [:subcatid, :linkid])

  end
end
