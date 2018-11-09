defmodule BoatNoodle.BN.DateDiscount do
  use Ecto.Schema
  import Ecto.Changeset

  schema "discountitems_date" do
    field(:brand_id, :integer)
    field(:end_date, :date)
    field(:discountitems_id, :integer)
    field(:start_date, :date)
    field(:is_delete, :integer, default: 0)

    timestamps()
  end

  @doc false
  def changeset(discount_date, attrs, user_id, action) do
    discount_date =
      discount_date
      |> cast(attrs, [:is_delete, :discountitems_id, :start_date, :end_date, :brand_id])
      |> validate_required([:discountitems_id, :start_date, :end_date, :brand_id])

    if action == "new" or action == "edit" do
    else
      if action == "Update" do
        attrs = Map.put(attrs, "id", discount_date.data.id)
      end

      BoatNoodle.BN.ModalLog.changeset(%BoatNoodle.BN.ModalLog{}, %{
        name: "discount_date",
        user_id: user_id,
        description: Poison.encode!(attrs),
        action: action
      })
      |> BoatNoodle.Repo.insert()
    end

    discount_date
  end
end
