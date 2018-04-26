defmodule BoatNoodle.Repo.Migrations.CreateOrganization do
  use Ecto.Migration

  def change do
    create table(:organization) do
      add :name, :string
      add :address, :string
      add :company_registration_number, :string
      add :tax_registration_number, :string
      add :contact_number, :string
      add :country, :string

      timestamps()
    end

  end
end
