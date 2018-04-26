defmodule BoatNoodle.Repo.Migrations.CreateDiscountCatalog do
  use Ecto.Migration

  def change do
    create table(:discount_catalog) do
      add :discount_catalog_master_id, :integer
      add :name, :string
      add :discount_categories, :string
      add :discount_category, :string
      add :discount_name, :string

      timestamps()
    end

  end
end
