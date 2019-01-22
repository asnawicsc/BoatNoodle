defmodule BoatNoodle.BN.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  require IEx

  @primary_key false
  schema "tag_tbl" do
    field(:tagid, :integer, primary_key: true)
    field(:branch_id, :integer)
    field(:subcat_ids, :string, default: "")
    field(:combo_item_ids, :string, default: "")
    field(:tagdesc, :string)
    field(:printer, :string)
    field(:printer_ip, :string)
    field(:port_no, :string)
    field(:tagname, :string)
    field(:updated_at, :utc_datetime)
    field(:created_at, :utc_datetime)
    field(:brand_id, :integer, primary_key: true)
  end

  @doc false
  def changeset(tag, attrs, user_id, action) do
    tag =
      tag
      |> cast(attrs, [
        :brand_id,
        :combo_item_ids,
        :subcat_ids,
        :branch_id,
        :printer_ip,
        :created_at,
        :updated_at,
        :tagid,
        :tagname,
        :tagdesc,
        :printer,
        :port_no
      ])

    if action == "new" or action == "edit" do
    else
      if action == "Update" do
        attrs = Map.put(attrs, "tagid", tag.data.tagid)
      end

      BoatNoodle.BN.ModalLog.changeset(%BoatNoodle.BN.ModalLog{}, %{
        name: "tag",
        user_id: user_id,
        description: Poison.encode!(attrs),
        action: action
      })
      |> BoatNoodle.Repo.insert()
    end

    tag
  end
end
