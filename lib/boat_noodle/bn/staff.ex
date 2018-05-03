defmodule BoatNoodle.BN.Staff do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "staffs" do
    field :staff_id, :integer, primary_key: true
    field :branchid, :string
    field :staff_contact, :string
    field :staff_email, :string
    field :prof_img, :string
    field :staff_pin, :integer
    field :staff_name, :string
    field :staff_type_id, :integer
    field :branch_access, :string

  end

  @doc false
  def changeset(staffs, attrs) do
    staffs
    |> cast(attrs, [:staffid, :branch_access,:staff_name, :staff_contact, :staff_email, :staff_pin, :branchid, :staff_type_id, :prof_img])
  end
end
