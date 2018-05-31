defmodule BoatNoodle.Repo.Migrations.CreatePicture do
  use Ecto.Migration

  def change do
    create table(:picture) do
      add :id, :integer
      add :filename, :string
      add :file_type, :string
      add :bin, :binary
      add :url, :string
      add :gallery_id, :integer

      timestamps()
    end

  end
end
