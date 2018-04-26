defmodule BoatNoodle.BN.Staff do
  use Ecto.Schema
  import Ecto.Changeset


  schema "staff" do
    field :branch, :string
    field :contact_number, :string
    field :email, :string
    field :photo, :string
    field :pin_number, :integer
    field :staff_name, :string
    field :staff_role, :string

    timestamps()
  end

  @doc false
  def changeset(staff, attrs) do
    staff
    |> cast(attrs, [:staff_name, :contact_number, :email, :pin_number, :branch, :staff_role, :photo])
    |> validate_required([:staff_name, :contact_number, :email, :pin_number, :branch, :staff_role, :photo])
  end
end
