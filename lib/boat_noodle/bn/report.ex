defmodule BoatNoodle.BN.Report do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reports" do
    field(:bin, :binary)
    field(:filename, :string)
    field(:url_path, :string)
    field(:brand_id, :integer)
    field(:branch_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(report, attrs) do
    report
    |> cast(attrs, [:brand_id, :branch_id, :filename, :url_path, :bin, :updated_at])
    |> validate_required([:filename, :url_path])
  end
end
