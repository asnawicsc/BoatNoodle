defmodule BoatNoodle.BN.Remark do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "itemsremak" do
    field(:itemsremarkid, :integer, primary_key: true)
    field(:remark, :string)
    field(:target_cat, :integer)
    field(:target_item, :integer)
    field(:brand_id, :integer, primary_key: true)
    field(:price, :decimal)
  end

  @doc false
  def changeset(remark, attrs, user_id, action) do
    remark =
      remark
      |> cast(attrs, [:price, :brand_id, :itemsremarkid, :remark, :target_cat, :target_item])

    if action == "new" or action == "edit" do
    else
      if action == "Update" do
        attrs = Map.put(attrs, "itemsremarkid", remark.data.itemsremarkid)
      end

      BoatNoodle.BN.ModalLog.changeset(%BoatNoodle.BN.ModalLog{}, %{
        name: "itemsremak",
        user_id: user_id,
        description: Poison.encode!(attrs),
        action: action
      })
      |> BoatNoodle.Repo.insert()
    end

    remark
  end
end
