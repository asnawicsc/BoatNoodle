defmodule BoatNoodle.Repo.Migrations.CreateMenuCatalog do
  use Ecto.Migration

  def change do
    create table(:menu_catalog) do
      add :menu_catalog_master_id, :integer
      add :item_code, :string
      add :item_name, :string
      add :price_code, :string
      add :price, :decimal
      add :active, :boolean, default: false, null: false
      add :category_item, :string

      timestamps()
    end

  end
end
