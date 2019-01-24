defmodule BoatNoodle.Repo.Migrations.CreateSalesDetailCombo do
  use Ecto.Migration

  def change do
    create table(:sales_detail_combo) do
      add :sales_details_combo, :integer
      add :order_id, :string
      add :sales_id, :string
      add :itemname, :string
      add :qty, :integer
      add :order_price, :decimal
      add :is_void, :integer
      add :void_by, :string
      add :void_reason, :string
      add :remark, :string
      add :afterdisc, :decimal
      add :unit_price, :decimal
      add :created_at, :naive_datetime
      add :updated_at, :naive_datetime
      add :top_up, :decimal
      add :is_combo_header, :integer
      add :brand_id, :integer

      timestamps()
    end

  end
end
