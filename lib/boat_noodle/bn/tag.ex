defmodule BoatNoodle.BN.Tag do
  use Ecto.Schema
  import Ecto.Changeset


  schema "tag" do
    field :description, :string
    field :printer_name, :string
    field :tag_name, :string

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:tag_name, :description, :printer_name])
    |> validate_required([:tag_name, :description, :printer_name])
  end
end
