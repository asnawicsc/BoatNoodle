defmodule BoatNoodle.BN.Branch do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "branch" do
    field(:branchid, :integer, primary_key: true)
    field(:b_address, :string, default: "")
    field(:branchcode, :string)
    field(:b_phoneno, :string, default: "")
    field(:manager, :integer)
    field(:branchname, :string)
    field(:tax_percent, :decimal, default: 0.00)
    field(:num_staff, :integer)
    field(:org_id, :string)
    field(:report_class, :string)
    field(:service_charge, :decimal, default: 0.00)
    field(:qb_custref, :string)
    field(:qb_dep2acc, :string)
    field(:currency, :string)

    field(:sync_status, :integer, default: 0)
    field(:remain_sync, :integer)
    field(:menu_catalog, :integer)
    field(:disc_catalog, :integer)
    field(:tag_catalog, :integer)
    field(:def_open_amt, :decimal, default: 300.00)
    field(:version, :string)
    field(:payment_catalog, :string)
    field(:updated_at, :utc_datetime)
    field(:created_at, :utc_datetime)
    field(:api_key, :string)
    field(:brand_id, :integer, primary_key: true)
  end

  @doc false
  def changeset(branch, attrs, user_id, action) do
    branch =
      branch
      |> cast(attrs, [
        :def_open_amt,
        :api_key,
        :brand_id,
        :created_at,
        :updated_at,
        :payment_catalog,
        :version,
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
      |> unique_constraint(:branchid, name: "PRIMARY")

    if action == "new" or action == "edit" do
    else
      if action == "Update" do
        attrs = Map.put(attrs, "brand_id", branch.data.brand_id)
      end

      BoatNoodle.BN.ModalLog.changeset(%BoatNoodle.BN.ModalLog{}, %{
        name: "branch",
        user_id: user_id,
        description: Poison.encode!(attrs),
        action: action
      })
      |> BoatNoodle.Repo.insert()
    end

    branch
  end
end
