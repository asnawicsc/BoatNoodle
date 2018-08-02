defmodule BoatNoodle.BN.UserBranchAccess do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "user_brnch_access" do
    field(:branchid, :integer)
    field(:userbranchid, :integer, primary_key: true)
    field(:userid, :integer)
  end

  @doc false
  def changeset(user_brnch_access, attrs,user_id,action) do
    user_brnch_access=user_brnch_access
    |> cast(attrs, [:userbranchid, :userid, :branchid])

         if action == "new" or action =="edit" do
    
       else

          if action == "Update" do
        attrs = Map.put(attrs, "userbranchid", user_brnch_access.data.userbranchid)
      end


       BoatNoodle.BN.ModalLog.changeset(%BoatNoodle.BN.ModalLog{},%{name: "user_brnch_access", user_id: user_id,description: Poison.encode!(attrs),action: action})|>BoatNoodle.Repo.insert()
      end

    user_brnch_access

  end
end
