defmodule BoatNoodle.BN.Category do
  use Ecto.Schema
  import Ecto.Changeset


  schema "category" do
    field :category_description, :string
    field :category_name, :string
    field :is_default_menu, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:category_name, :category_description, :is_default_menu])
    |> validate_required([:category_name, :category_description, :is_default_menu])
  end
end
