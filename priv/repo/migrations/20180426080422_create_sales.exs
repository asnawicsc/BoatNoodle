defmodule BoatNoodle.Repo.Migrations.CreateSales do
  use Ecto.Migration

  def change do
    create table(:sales) do
      add :sales_master_id, :integer
      add :item_id, :integer
      add :quantity, :integer

      timestamps()
    end

  end
end
