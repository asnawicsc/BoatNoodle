defmodule BoatNoodle.BN.StaffLogSession do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "staff_log_session" do
    field :branch_id, :integer
    field :id, :integer, primary_key: true
    field :log_id, :integer
    field :log_in, :utc_datetime
    field :log_out, :utc_datetime
    field :staff_id, :integer

  end

  @doc false
  def changeset(staff_log_session, attrs) do
    staff_log_session
    |> cast(attrs, [:log_id, :id, :branch_id, :staff_id, :log_in, :log_out])
  end
end
