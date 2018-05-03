defmodule BoatNoodle.Repo.Migrations.CreatePasswordResets do
  use Ecto.Migration

  def change do
    create table(:password_resets) do
      add :email, :string
      add :token, :string
      add :created_at, :utc_datetime

      timestamps()
    end

  end
end
