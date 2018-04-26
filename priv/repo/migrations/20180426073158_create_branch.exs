defmodule BoatNoodle.Repo.Migrations.CreateBranch do
  use Ecto.Migration

  def change do
    create table(:branch) do
      add :branch_name, :string
      add :branch_code, :string
      add :branch_contact, :string
      add :branch_address, :string
      add :organization, :string
      add :goverment_tax_percentage, :integer
      add :service_tax_percentage, :integer
      add :branch_manager, :string
      add :number_of_staff, :integer
      add :report_class, :string

      timestamps()
    end

  end
end
