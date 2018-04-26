defmodule BoatNoodle.Repo.Migrations.CreateSalesMaster do
  use Ecto.Migration

  def change do
    create table(:sales_master) do
      add :receipt_no, :integer
      add :payment, :string
      add :total_amount, :decimal
      add :table, :integer
      add :pax, :integer
      add :casher, :string

      timestamps()
    end

  end
end
