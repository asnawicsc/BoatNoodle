defmodule BoatNoodle.Repo.Migrations.CreateItemSubcat do
  use Ecto.Migration

  def change do
    create table(:item_subcat) do
      add :subcatid, :integer
      add :itemcatid, :string
      add :itemname, :string
      add :itemcode, :string
      add :product_code, :string
      add :price_code, :string
      add :part_code, :string
      add :itemdesc, :string
      add :itemprice, :decimal
      add :itemimage, :binary
      add :is_categorize, :integer
      add :is_activate, :integer
      add :is_combo, :integer
      add :is_comboitem, :integer
      add :is_default_combo, :integer
      add :is_delete, :integer
      add :enable_disc, :integer
      add :include_spend, :integer
      add :is_print, :integer
      add :updated_at, :naive_datetime
      add :created_at, :naive_datetime

      timestamps()
    end

  end
end
