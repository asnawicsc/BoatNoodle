defmodule BoatNoodle.Repo.Migrations.CreateRptHourlyOutlet do
  use Ecto.Migration

  def change do
    create table(:rpt_hourly_outlet) do
      add :salesyear, :integer
      add :salesmonth, :integer
      add :salesquarter, :integer
      add :salesdate, :naive_datetime
      add :branchid, :integer
      add :brachcode, :string
      add :branchname, :string
      add :saleshour, :integer
      add :sales, :decimal
      add :pax, :integer
      add :transaction, :string
      add :integer, :string

      timestamps()
    end

  end
end
