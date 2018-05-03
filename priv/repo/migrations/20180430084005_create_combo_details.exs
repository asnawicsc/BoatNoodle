defmodule BoatNoodle.Repo.Migrations.CreateComboDetails do
  use Ecto.Migration

  def change do
    create table(:combo_details) do
      add :id, :integer
      add :menu_cat_id, :integer
      add :combo_id, :integer
      add :combo_qty, :integer
      add :combo_item_id, :integer
      add :combo_item_name, :string
      add :combo_item_code, :string
      add :combo_item_qty, :integer
      add :update_qty, :integer
      add :unit_price, :decimal
      add :top_up, :decimal

      timestamps()
    end

  end
end
