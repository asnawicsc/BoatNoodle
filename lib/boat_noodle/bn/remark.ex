defmodule BoatNoodle.BN.Remark do
  use Ecto.Schema
  import Ecto.Changeset


  schema "remark" do
    field :remark_description, :string
    field :target_category, :string
    field :target_item, :string

    timestamps()
  end

  @doc false
  def changeset(remark, attrs) do
    remark
    |> cast(attrs, [:remark_description, :target_category, :target_item])
    |> validate_required([:remark_description, :target_category, :target_item])
  end
end
