defmodule BoatNoodle.BN.UnauthorizeMenu do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "unauthorize_menu" do
    field :id, :integer, primary_key: true
    field :branch_id, :integer
    field :brand_id, :integer, primary_key: true
    field :role_id, :integer
    field :url, :string
    field :active, :integer
    field :desc, :string

 
  end

  @doc false
  def changeset(unauthorize_menu, attrs) do
    unauthorize_menu
    |> cast(attrs, [:desc,:active, :id, :url, :branch_id, :brand_id, :role_id])
    |> unique_constraint(:id, name: "PRIMARY")
  end
end
