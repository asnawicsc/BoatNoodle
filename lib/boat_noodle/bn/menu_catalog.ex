defmodule BoatNoodle.BN.MenuCatalog do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "menu_catalog" do
    field(:id, :integer, primary_key: true)
    field(:name, :string)
    field(:categories, :string, default: "")
    field(:items, :string, default: "")
    field(:combo_items, :string, default: "")
    field(:brand_id, :integer, primary_key: true)
  end

  @doc false
  def changeset(menu_catalog, attrs,user_id,action) do
    menu_catalog=menu_catalog
    |> cast(attrs, [:brand_id, :id, :name, :categories, :items, :combo_items])


     if action == "new" or action =="edit" do

      
     else

           attrs =if action == "Update" do
        Map.put(attrs, "id", menu_catalog.data.id)
      end


                  date=Timex.now

      date_time=DateTime.to_string(date)|>String.split_at(19)|>elem(0)

    BoatNoodle.BN.ModalLog.changeset(%BoatNoodle.BN.ModalLog{},%{name: "menu_catalog",
     user_id: user_id,
     description: Poison.encode!(attrs),
     action: action,
     inserted_at: date_time,
     updated_at: date_time})|>BoatNoodle.Repo.insert()
    end

  menu_catalog
  end
end
