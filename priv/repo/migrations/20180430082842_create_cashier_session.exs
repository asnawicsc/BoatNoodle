defmodule BoatNoodle.Repo.Migrations.CreateCashierSession do
  use Ecto.Migration

  def change do
    create table(:cashier_session) do
      add :csid, :integer
      add :staffid, :string
      add :branchid, :string
      add :time_start, :utc_datetime
      add :time_end, :utc_datetime
      add :floatamt, :decimal
      add :open_amt, :decimal
      add :close_amt, :decimal
      add :cash_in, :decimal
      add :cash_out, :decimal
      add :duration, :integer
      add :deposits, :decimal
      add :paidout, :decimal

      timestamps()
    end

  end
end
