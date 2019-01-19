defmodule BoatNoodle.Repo.Migrations.CreateComboCatalog do
  use Ecto.Migration

  def change do
    create table(:combo_catalog) do
      add :combo_id, :integer
      add :combo_item_id, :integer
      add :is_active, :integer
      add :is_combo_header, :integer
      add :brand_id, :integer

      timestamps()
    end

  end
end
