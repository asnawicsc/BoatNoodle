defmodule BoatNoodle.Repo.Migrations.CreateSalesdetailcust do
  use Ecto.Migration

  def change do
    create table(:salesdetailcust) do
      add :salescustid, :integer
      add :orderid, :string
      add :custom_name, :string
      add :customer_price, :decimal
      add :updated_at, :utc_datetime
      add :created_at, :utc_datetime

      timestamps()
    end

  end
end
