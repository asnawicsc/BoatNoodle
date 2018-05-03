defmodule BoatNoodle.BN.MenuItem do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "item_cat" do
    field :itemcatid, :integer, primary_key: true
    field :itemcatcode, :string
    field :itemcatname, :string
    field :itemcatdesc, :string
    field :is_default, :integer
    field :category_type, :string
    field :is_delete, :integer
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime

  end

  @doc false
  def changeset(menu_item, attrs) do
    menu_item
    |> cast(attrs, [:itemcatid, :itemcatcode, :itemcatname, :itemcatdesc, :is_default, :category_type, :is_delete, :created_at, :updated_at])
   
    end
end
