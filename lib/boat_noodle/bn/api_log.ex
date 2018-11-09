defmodule BoatNoodle.BN.ApiLog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "api_log" do
    field(:message, :string)
    field(:username, :string)
    field(:brand_id, :integer, default: 0)
    field(:branch_id, :integer, default: 0)
    timestamps()
  end

  @doc false
  def changeset(api_log, attrs) do
    api_log
    |> cast(attrs, [:brand_id, :branch_id, :message, :username])
    |> validate_required([:message, :username])
  end
end
