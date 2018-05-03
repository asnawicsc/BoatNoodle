defmodule BoatNoodle.Repo.Migrations.CreateRptCashierEod do
  use Ecto.Migration

  def change do
    create table(:rpt_cashier_eod) do
      add :rptid, :integer
      add :branch_id, :integer
      add :staff_name, :string
      add :time_start, :utc_datetime
      add :time_end, :utc_datetime
      add :duration, :string
      add :open_amt, :decimal
      add :close_amt, :decimal
      add :totalpax, :integer
      add :totalsales, :decimal
      add :voidsales, :float
      add :voiditem, :float
      add :totaltax, :decimal
      add :totalsvc, :decimal
      add :total_round, :decimal
      add :dinein, :decimal
      add :takeaway, :decimal
      add :total_disc, :decimal
      add :total_pymt, :decimal
      add :total_cash, :decimal
      add :total_changes, :decimal
      add :floats, :decimal
      add :deposit, :decimal
      add :cash_in, :decimal
      add :paidout, :decimal
      add :cash, :decimal
      add :drawamt, :decimal
      add :exp_drw_amt, :decimal
      add :total_sr, :decimal
      add :extra, :decimal
      add :branchcode, :string

      timestamps()
    end

  end
end
