defmodule BoatNoodle.Repo.Migrations.CreateMenuItem do
  use Ecto.Migration

  def change do
    create table(:menu_item) do
      add :item_code, :string
      add :item, :string
      add :item_name, :string
      add :item_description, :string
      add :price, :decimal
      add :item_image, :string
      add :category, :string
      add :part_code, :string
      add :price_code, :string
      add :active, :boolean, default: false, null: false
      add :enable_discount, :boolean, default: false, null: false
      add :is_included_in_minimum_spend, :boolean, default: false, null: false
      add :tags, :string
      add :menu_catalogs, :string

      timestamps()
    end

  end
end
