defmodule BoatNoodle.Repo.Migrations.CreateSubcatCatalog do
  use Ecto.Migration

  def change do
    create table(:subcat_catalog) do
      add :subcat_id, :integer
      add :catalog_id, :integer
      add :start_date, :date
      add :end_date, :date
      add :price, :decimal

      timestamps()
    end

  end
end
