defmodule BoatNoodle.Repo.Migrations.CreateDiscount do
  use Ecto.Migration

  def change do
    create table(:discount) do
      add :discount_id, :integer
      add :discname, :string
      add :descriptions, :string
      add :discamtpercentage, :decimal
      add :target_cat, :integer
      add :is_used, :integer
      add :disc_qty, :integer
      add :targer_itemcode, :string
      add :disctype, :string
      add :is_categorize, :integer
      add :is_visible, :integer
      add :is_delete, :integer

      timestamps()
    end

  end
end
