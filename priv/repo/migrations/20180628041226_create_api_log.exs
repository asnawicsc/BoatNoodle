defmodule BoatNoodle.Repo.Migrations.CreateApiLog do
  use Ecto.Migration

  def change do
    create table(:api_log) do
      add :message, :string

      timestamps()
    end

  end
end
