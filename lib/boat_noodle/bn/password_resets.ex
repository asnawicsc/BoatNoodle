defmodule BoatNoodle.BN.PasswordResets do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "password_resets" do
    field :created_at, :utc_datetime
    field :email, :string, primary_key: true
    field :token, :string

  end

  @doc false
  def changeset(password_resets, attrs) do
    password_resets
    |> cast(attrs, [:email, :token, :created_at])

  end
end
