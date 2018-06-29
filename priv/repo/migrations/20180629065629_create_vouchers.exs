defmodule BoatNoodle.Repo.Migrations.CreateVouchers do
  use Ecto.Migration

  def change do
    create table(:vouchers) do
      add :code_number, :string
      add :discount_name, :string
      add :is_used, :boolean, default: false, null: false
      add :branchid, :integer

      timestamps()
    end

  end
end
