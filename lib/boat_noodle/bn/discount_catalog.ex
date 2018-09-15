defmodule BoatNoodle.BN.DiscountCatalog do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "discount_catalog" do
    field(:id, :integer, primary_key: true)
    field(:name, :string)
    field(:categories, :string)
    field(:discounts, :string)
    field(:brand_id, :integer, primary_key: true)
  end

  @doc false
  def changeset(discount_catalog, attrs, user_id, action) do
    discount_catalog =
      discount_catalog
      |> cast(attrs, [:brand_id, :id, :name, :categories, :discounts])
      |> unique_constraint(:id, name: "PRIMARY")

    if action == "new" or action == "edit" do
    else
      if action == "Update" do
        attrs = Map.put(attrs, "id", discount_catalog.data.id)
      end



            date=Timex.now

      date_time=DateTime.to_string(date)|>String.split_at(19)|>elem(0)

      BoatNoodle.BN.ModalLog.changeset(%BoatNoodle.BN.ModalLog{}, %{
        name: "discount_catalog",
        user_id: user_id,
        description: Poison.encode!(attrs),
        action: action,
        inserted_at: date_time,
        updated_at: date_time
      })
      |> BoatNoodle.Repo.insert()
    end

    discount_catalog
  end
end
