defmodule BoatNoodle.BN.DatePrice do
  use Ecto.Schema
  import Ecto.Changeset

  schema "item_subcat_date_price" do
    field(:brand_id, :integer)
    field(:end_date, :date)
    field(:item_subcat_id, :integer)
    field(:start_date, :date)
    field(:unit_price, :decimal)
    field(:is_delete, :integer, default: 0)

    timestamps()
  end

  @doc false
  def changeset(date_price, attrs, user_id, action) do
    date_price =
      date_price
      |> cast(attrs, [:is_delete, :item_subcat_id, :start_date, :end_date, :unit_price, :brand_id])
      |> validate_required([:item_subcat_id, :start_date, :end_date, :unit_price, :brand_id])

    if action == "new" or action == "edit" do
    else
      if action == "Update" do
        attrs = Map.put(attrs, "id", date_price.data.id)
      end

      BoatNoodle.BN.ModalLog.changeset(%BoatNoodle.BN.ModalLog{}, %{
        name: "date_price",
        user_id: user_id,
        description: Poison.encode!(attrs),
        action: action
      })
      |> BoatNoodle.Repo.insert()
    end

    date_price
  end
end
