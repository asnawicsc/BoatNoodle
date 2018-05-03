defmodule BoatNoodle.Repo.Migrations.CreateRptTransaction do
  use Ecto.Migration

  def change do
    create table(:rpt_transaction) do
      add :salesid, :string
      add :salesyear, :integer
      add :salesmonth, :integer
      add :salesdate, :utc_datetime
      add :saleshour, :integer
      add :salestime, :utc_datetime
      add :quarter, :integer
      add :branchid, :integer
      add :branchcode, :string
      add :invoiceno, :string
      add :sub_total, :decimal
      add :after_disc, :string
      add :decimal, :string
      add :gst_charge, :string
      add :decimal, :string
      add :service_charge, :decimal
      add :rounding, :decimal
      add :grand_total, :decimal
      add :pax, :integer
      add :payment_type, :string
      add :cash, :decimal
      add :changes, :decimal
      add :tbl_no, :integer
      add :type, :string
      add :staffid, :integer
      add :staffname, :string
      add :is_void, :integer
      add :void_by, :string
      add :voidreason, :string
      add :remark, :string

      timestamps()
    end

  end
end
