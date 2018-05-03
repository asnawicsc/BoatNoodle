defmodule BoatNoodle.Repo.Migrations.CreateVoiditems do
  use Ecto.Migration

  def change do
    create table(:voiditems) do
      add :itemcode, :string
      add :itemname, :string
      add :quantity, :integer
      add :price, :decimal
      add :tableid, :integer
      add :itemid, :integer
      add :displayprice, :string
      add :is_print, :integer
      add :discount, :float
      add :priceafterdiscount, :decimal
      add :qtyafterdisc, :integer
      add :itempriceperqty, :decimal
      add :takeawayid, :string
      add :discountitemsid, :integer
      add :remark, :string
      add :is_void, :integer
      add :void_by, :integer
      add :voidreason, :string
      add :orderid, :string

      timestamps()
    end

  end
end
