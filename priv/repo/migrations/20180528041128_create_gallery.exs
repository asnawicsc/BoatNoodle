defmodule BoatNoodle.Repo.Migrations.CreateGallery do
  use Ecto.Migration

  def change do
    create table(:gallery) do
      add :id, :integer

      timestamps()
    end

  end
end
