defmodule BoatNoodle.BN.Discount do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "discount" do
    field(:descriptions, :string)
    field(:disc_qty, :integer)
    field(:discamtpercentage, :decimal)
    field(:discname, :string)
    field(:discountid, :integer, primary_key: true)
    field(:disctype, :string)
    field(:is_categorize, :integer)
    field(:is_delete, :integer)
    field(:is_used, :integer)
    field(:is_visable, :integer)
    field(:target_itemcode, :string)
    field(:target_cat, :integer)
    field(:brand_id, :integer, primary_key: true)
  end

  @doc false
  def changeset(discount, attrs, user_id, action) do
    discount =
      discount
      |> cast(attrs, [
        :discountid,
        :brand_id,
        :discname,
        :descriptions,
        :discamtpercentage,
        :target_cat,
        :is_used,
        :disc_qty,
        :target_itemcode,
        :disctype,
        :is_categorize,
        :is_visable,
        :is_delete
      ])
      |> unique_constraint(:discountid, name: "PRIMARY")

    if action == "new" or action == "edit" do
    else
      if action == "Update" do
        attrs = Map.put(attrs, "discountid", discount.data.discountid)
      end


            date=Timex.now

      date_time=DateTime.to_string(date)|>String.split_at(19)|>elem(0)

      BoatNoodle.BN.ModalLog.changeset(%BoatNoodle.BN.ModalLog{}, %{
        name: "discount",
        user_id: user_id,
        description: Poison.encode!(attrs),
        action: action,
         inserted_at: date_time,
        updated_at: date_time
      })
      |> BoatNoodle.Repo.insert()
    end

    discount
  end
end
