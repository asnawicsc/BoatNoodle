defmodule BoatNoodle.BN.ModalLog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "modal_logs" do
    field(:action, :string)
    field(:description, :binary)
    field(:name, :string)
    field(:user_id, :integer)
    timestamps()
  end

  @doc false
  def changeset(modal_log, attrs) do
    modal_log
    |> cast(attrs, [:name, :user_id, :description, :action, :inserted_at, :updated_at])
  end
end
