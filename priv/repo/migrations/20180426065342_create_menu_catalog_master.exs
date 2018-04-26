defmodule BoatNoodle.Repo.Migrations.CreateMenuCatalogMaster do
  use Ecto.Migration

  def change do
    create table(:menu_catalog_master) do
      add :catalog_name, :string

      timestamps()
    end

  end
end
