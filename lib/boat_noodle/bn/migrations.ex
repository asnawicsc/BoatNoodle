defmodule BoatNoodle.BN.Migrations do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "migrations" do
    field :batch,:integer, primary_key: true
    field :migration, :string

  end

  @doc false
  def changeset(migrations, attrs) do
    migrations
    |> cast(attrs, [:migration, :batch])

  end
end
