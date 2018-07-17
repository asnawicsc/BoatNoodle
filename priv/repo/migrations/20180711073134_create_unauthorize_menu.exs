defmodule BoatNoodle.Repo.Migrations.CreateUnauthorizeMenu do
  use Ecto.Migration

  def change do
    create table(:unauthorize_menu) do
      add :url, :string
      add :branch_id, :integer
      add :brand_id, :integer
      add :role_id, :integer

      timestamps()
    end

  end
end
