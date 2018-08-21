defmodule BoatNoodle.Repo.Migrations.CreateHistoryData do
  use Ecto.Migration

  def change do
    create table(:history_data) do
      add :start_date, :date
      add :end_date, :date
      add :json_map, :binary
      add :brand_id, :integer
      add :branch_id, :integer

      timestamps()
    end

  end
end
