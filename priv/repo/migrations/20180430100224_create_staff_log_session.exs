defmodule BoatNoodle.Repo.Migrations.CreateStaffLogSession do
  use Ecto.Migration

  def change do
    create table(:staff_log_session) do
      add :log_id, :integer
      add :id, :integer
      add :branch_id, :integer
      add :staff_id, :integer
      add :log_in, :utc_datetime
      add :log_out, :utc_datetime

      timestamps()
    end

  end
end
