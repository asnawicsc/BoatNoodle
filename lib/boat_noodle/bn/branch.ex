defmodule BoatNoodle.BN.Branch do
  use Ecto.Schema
  import Ecto.Changeset


  schema "branch" do
    field :branch_address, :string
    field :branch_code, :string
    field :branch_contact, :string
    field :branch_manager, :string
    field :branch_name, :string
    field :goverment_tax_percentage, :integer
    field :number_of_staff, :integer
    field :organization, :string
    field :report_class, :string
    field :service_tax_percentage, :integer

    timestamps()
  end

  @doc false
  def changeset(branch, attrs) do
    branch
    |> cast(attrs, [:branch_name, :branch_code, :branch_contact, :branch_address, :organization, :goverment_tax_percentage, :service_tax_percentage, :branch_manager, :number_of_staff, :report_class])
    |> validate_required([:branch_name, :branch_code, :branch_contact, :branch_address, :organization, :goverment_tax_percentage, :service_tax_percentage, :branch_manager, :number_of_staff, :report_class])
  end
end
