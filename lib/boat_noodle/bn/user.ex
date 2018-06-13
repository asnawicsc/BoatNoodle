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
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
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
  end
end
