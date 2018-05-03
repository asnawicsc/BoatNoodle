defmodule BoatNoodle.BN.UserPwd do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "user_pwd" do
    field :name, :string, primary_key: true
    field :pass, :string

  end

  @doc false
  def changeset(user_pwd, attrs) do
    user_pwd
    |> cast(attrs, [:name, :pass])

  end
end
