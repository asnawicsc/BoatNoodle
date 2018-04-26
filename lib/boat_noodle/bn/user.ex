defmodule BoatNoodle.BN.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "user" do
    field :branch_access, :string
    field :email, :string
    field :password, :string
    field :user_role, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password, :email, :user_role, :branch_access])
    |> validate_required([:username, :password, :email, :user_role, :branch_access])
  end
end
