defmodule BoatNoodle.Repo.Migrations.CreateItemSubcatDatePrice do
  use Ecto.Migration

  def change do
    create table(:item_subcat_date_price) do
      add :item_subcat_id, :integer
      add :start_date, :date
      add :end_date, :date
      add :unit_price, :decimal
      add :brand_id, :integer

      timestamps()
    end

  end
end
