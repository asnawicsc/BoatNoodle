defmodule BoatNoodle.Repo.Migrations.CreateModalLogs do
  use Ecto.Migration

  def change do
    create table(:modal_logs) do
      add :name, :string
      add :user_id, :integer
      add :description, :binary
      add :action, :string

      timestamps()
    end

  end
end
