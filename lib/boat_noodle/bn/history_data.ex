defmodule BoatNoodle.BN.HistoryData do
  use Ecto.Schema
  import Ecto.Changeset

  schema "history_data" do
    field(:branch_id, :integer)
    field(:brand_id, :integer)
    field(:end_date, :date)
    field(:json_map, :binary)
    field(:start_date, :date)
    field(:name, :string)

    timestamps()
  end

  @doc false
  def changeset(history_data, attrs) do
    history_data
    |> cast(attrs, [:name, :start_date, :end_date, :json_map, :brand_id, :branch_id])
    |> validate_required([:name, :start_date, :end_date, :brand_id, :branch_id])
  end
end
