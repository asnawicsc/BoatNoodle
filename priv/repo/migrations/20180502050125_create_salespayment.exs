defmodule BoatNoodle.Repo.Migrations.CreateSalespayment do
  use Ecto.Migration

  def change do
    create table(:salespayment) do
      add :salespay_id, :integer
      add :salesid, :string
      add :sub_total, :decimal
      add :after_disc, :decimal
      add :service_charge, :decimal
      add :gst_charge, :decimal
      add :rounding, :decimal
      add :grand_total, :decimal
      add :cash, :decimal
      add :changes, :decimal
      add :payment_type, :string
      add :card_no, :integer
      add :taxcode, :string
      add :disc_amt, :decimal
      add :voucher_code, :string
      add :discountid, :string
      add :payment_type_id1, :integer
      add :payment_type_am1, :decimal
      add :payment_code1, :string
      add :payment_type_id2, :integer
      add :payment_type_am2, :decimal
      add :payment_code2, :string
      add :updated_at, :utc_datetime
      add :created_at, :utc_datetime

      timestamps()
    end

  end
end
