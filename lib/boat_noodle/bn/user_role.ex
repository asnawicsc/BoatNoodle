defmodule BoatNoodle.BN.UserRole do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "user_role" do
    field :role_desc, :string
    field :role_name, :string
    field :roleid, :integer, primary_key: true

  end

  @doc false
  def changeset(user_role, attrs) do
    user_role
    |> cast(attrs, [:roleid, :role_name, :role_desc])

  end
end
