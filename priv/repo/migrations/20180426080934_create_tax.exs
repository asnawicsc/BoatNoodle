defmodule BoatNoodle.Repo.Migrations.CreateTax do
  use Ecto.Migration

  def change do
    create table(:tax) do
      add :sales_time, :naive_datetime
      add :receipt_no, :string
      add :tax, :decimal
      add :standard_supply_rate, :decimal

      timestamps()
    end

  end
end
