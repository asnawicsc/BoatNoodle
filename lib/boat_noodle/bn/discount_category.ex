defmodule BoatNoodle.BN.DiscountCategory do
  use Ecto.Schema
  import Ecto.Changeset


  schema "discount_category" do
    field :amount_percentage, :integer
    field :description, :string
    field :discount_catalog, :string
    field :discount_type, :string
    field :name, :string
    field :status, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(discount_category, attrs,user_id,action) do
    discount_category=discount_category
    |> cast(attrs, [:name, :description, :discount_type, :amount_percentage, :status, :discount_catalog])

      if action == "new" or action =="edit" do

            
        else

          if action == "Update" do
        attrs = Map.put(attrs, "name", discount_category.data.name)
      end

                  date=Timex.now

      date_time=DateTime.to_string(date)|>String.split_at(19)|>elem(0)


          BoatNoodle.BN.ModalLog.changeset(%BoatNoodle.BN.ModalLog{},%{name: "discount_category", 
            user_id: user_id,
            description: Poison.encode!(attrs),
            action: action,
            inserted_at: date_time,
        updated_at: date_time
        })|>BoatNoodle.Repo.insert()
      end

  discount_category
  end
end
