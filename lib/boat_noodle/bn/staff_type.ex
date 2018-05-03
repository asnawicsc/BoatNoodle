defmodule BoatNoodle.BN.StaffType do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "staff_type" do
    field :description, :string
    field :id, :integer, primary_key: true
    field :name, :string

  end

  @doc false
  def changeset(staff_type, attrs) do
    staff_type
    |> cast(attrs, [:id, :name, :description])

  end
end
