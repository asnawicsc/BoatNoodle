defmodule BoatNoodle.BN.Branch do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "branch" do
    field(:branchid, :integer, primary_key: true)
    field(:b_address, :string)
    field(:branchcode, :string)
    field(:b_phoneno, :string)
    field(:manager, :integer)
    field(:branchname, :string)
    field(:tax_percent, :decimal)
    field(:num_staff, :integer)
    field(:org_id, :string)
    field(:report_class, :string)
    field(:service_charge, :decimal)
    field(:qb_custref, :string)
    field(:qb_dep2acc, :string)
    field(:currency, :string)

    field(:sync_status, :integer)
    field(:remain_sync, :integer)
    field(:menu_catalog, :integer)
    field(:disc_catalog, :integer)
    field(:tag_catalog, :integer)
    field(:combo_catalog, :integer)
    field(:version, :string)
    field(:payment_catalog, :string)
    field(:updated_at, :utc_datetime)
    field(:created_at, :utc_datetime)
      field(:api_key, :string)
    field(:brand_id, :integer, primary_key: true)
  end

  @doc false
  def changeset(branch, attrs) do
    branch
    |> cast(attrs, [
      :api_key,
      :brand_id,
      :created_at,
      :updated_at,
      :payment_catalog,
      :version,
      :combo_catalog,
      :tag_catalog,
      :disc_catalog,
      :menu_catalog,
      :remain_sync,
      :sync_status,
      :currency,
      :qb_dep2acc,
      :qb_custref,
      :branchid,
      :branchname,
      :branchcode,
      :b_phoneno,
      :b_address,
      :org_id,
      :tax_percent,
      :service_charge,
      :manager,
      :num_staff,
      :report_class
    ])
  end
end
