defmodule BoatNoodle.Repo.Migrations.CreateDiscountCatalogMaster do
  use Ecto.Migration

  def change do
    create table(:discount_catalog_master) do
      add :catalog_name, :string

      timestamps()
    end

  end
end
