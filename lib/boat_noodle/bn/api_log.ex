defmodule BoatNoodle.BN.ApiLog do
  use Ecto.Schema
  import Ecto.Changeset


  schema "api_log" do
    field :message, :string
      field :username, :string
    timestamps()
  end

  @doc false
  def changeset(api_log, attrs) do
    api_log
    |> cast(attrs, [:message, :username])
    |> validate_required([:message, :username])
  end
end
