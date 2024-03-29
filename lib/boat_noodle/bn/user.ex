defmodule BoatNoodle.BN.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "users" do
    field(:id, :integer, primary_key: true)
    field(:manager_access, :integer)
    field(:email, :string)
    field(:password, :string)
    field(:roleid, :integer)
    field(:username, :string)
    field(:remember_token, :string)
    field(:updated_at, :utc_datetime)
    field(:created_at, :utc_datetime)
    field(:last_login, :utc_datetime)
    field(:last_logout, :utc_datetime)
    field(:gall_id, :integer)
    field(:brand_id, :integer)
    field(:read_report_only, :integer)
  end

  @doc false
  def changeset(user, attrs, user_id, action) do
    user =
      user
      |> cast(attrs, [
        :read_report_only,
        :brand_id,
        :last_logout,
        :last_login,
        :created_at,
        :updated_at,
        :remember_token,
        :id,
        :username,
        :password,
        :email,
        :roleid,
        :manager_access,
        :gall_id
      ])

    if action == "new" or action == "edit" do
    else
      if action == "Update" do
        attrs = Map.put(attrs, "id", user.data.id)
      end

      BoatNoodle.BN.ModalLog.changeset(%BoatNoodle.BN.ModalLog{}, %{
        name: "user",
        user_id: user_id,
        description: Poison.encode!(attrs),
        action: action
      })
      |> BoatNoodle.Repo.insert()
    end

    user
  end
end
