defmodule BoatNoodle.BN.Organization do
  use Ecto.Schema
  import Ecto.Changeset


  schema "organization" do
    field :address, :string
    field :company_registration_number, :string
    field :contact_number, :string
    field :country, :string
    field :name, :string
    field :tax_registration_number, :string

    timestamps()
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :address, :company_registration_number, :tax_registration_number, :contact_number, :country])
    |> validate_required([:name, :address, :company_registration_number, :tax_registration_number, :contact_number, :country])
  end
end
