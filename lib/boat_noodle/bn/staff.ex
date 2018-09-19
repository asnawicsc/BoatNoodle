defmodule BoatNoodle.BN.Staff do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "staffs" do
    field(:staff_id, :integer, primary_key: true)
    field(:branchid, :string, default: "0")
    field(:staff_contact, :string)
    field(:staff_email, :string, default: "")
    field(:prof_img, :string)
    field(:staff_pin, :integer)
    field(:staff_name, :string)
    field(:staff_type_id, :integer)
    field(:branch_access, :string)
    field(:brand_id, :integer, primary_key: true)
  end

  @doc false
  def changeset(staffs, attrs, user_id, action) do
    staffs =
      staffs
      |> cast(attrs, [
        :brand_id,
        :staff_id,
        :branch_access,
        :staff_name,
        :staff_contact,
        :staff_email,
        :staff_pin,
        :branchid,
        :staff_type_id,
        :prof_img
      ])
      |> unique_constraint(:staff_id, name: "PRIMARY")

    if action == "new" or action == "edit" do
    else
      attrs =
        if action == "Update" do
          Map.put(attrs, "staff_id", staffs.data.staff_id)
        else
        end

      BoatNoodle.BN.ModalLog.changeset(%BoatNoodle.BN.ModalLog{}, %{
        name: "staffs",
        user_id: user_id,
        description: Poison.encode!(attrs),
        action: action
      })
      |> BoatNoodle.Repo.insert()
    end

    staffs
  end
end
