defmodule BoatNoodleWeb.TagController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.Tag
  require IEx

  def list_printer(conn, %{"subcat_id" => subcat_id}) do
    # will have subcat id 
    # need to list all available printers
    tags_original =
      Repo.all(
        from(
          t in Tag,
          left_join: b in Branch,
          on: t.branch_id == b.branchid,
          where:
            t.brand_id == ^BN.get_brand_id(conn) and t.branch_id != 0 and
              b.brand_id == ^BN.get_brand_id(conn),
          select: %{
            tag_id: t.tagid,
            branchname: b.branchname,
            tagname: t.tagname,
            items: t.subcat_ids
          }
        )
      )
      |> Enum.map(fn x -> Map.put(x, :items, String.split(x.items, ",")) end)
      |> Enum.group_by(fn x -> x.branchname end)

    # tags =
    #   for tag <- tags_original do
    #     if Enum.any?(tag.items, fn x -> x == subcat_id end) do
    #       tag
    #     else
    #       nil
    #     end
    #   end
    #   |> Enum.reject(fn x -> x == nil end)
    #   |> Enum.map(fn x -> %{tag_id: x.tag_id, branchname: x.branchname} end)

    # all_tags =
    #   tags_original |> Enum.map(fn x -> %{tag_id: x.tag_id, branchname: x.branchname} end)

    # not_selected = all_tags -- tags

    json = tags_original |> Poison.encode!()
    # json = %{selected: tags, not_selected: not_selected} |> Poison.encode!()

    send_resp(conn, 200, json)
  end

  def printer_has_item(items, subcatid) do
  end

  def check_printer(conn, %{"name" => name, "id" => id}) do
    item_subcat = Repo.get_by(ItemSubcat, subcatid: id, brand_id: BN.get_brand_id(conn))

    same_items =
      Repo.all(
        from(
          s in ItemSubcat,
          where:
            s.itemcode == ^item_subcat.itemcode and s.is_comboitem == ^0 and s.is_delete == ^0,
          order_by: [asc: s.price_code]
        )
      )

    item_codes_str =
      same_items |> Enum.map(fn x -> x.subcatid end) |> Enum.map(fn x -> Integer.to_string(x) end)
      |> Enum.sort()

    branchname =
      name
      |> String.split("[")
      |> Enum.map(fn x -> String.replace(x, "]", "") end)
      |> List.to_tuple()
      |> elem(1)

    branch = Repo.get_by(Branch, branchname: branchname)

    tags =
      Repo.all(
        from(
          t in Tag,
          where: t.branch_id == ^branch.branchid and t.brand_id == ^BN.get_brand_id(conn)
        )
      )

    a =
      for tag <- tags do
        subcat_ids = tag.subcat_ids |> String.split(",")
        myers = List.myers_difference(item_codes_str, subcat_ids)

        answer = myers |> Keyword.get(:eq)

        if answer != nil do
          answer = hd(answer)
          Integer.to_string(tag.tagid)
        else
          nil
        end
      end

    final_answer = a |> Enum.reject(fn x -> x == nil end)

    if final_answer != [] do
      tagid = final_answer |> hd()
    else
      tagid = hd(a)
    end

    json = %{name: name, tag_id: tagid} |> Poison.encode!()

    # will pass in the branch id, brand id, and single subitem id 
    send_resp(conn, 200, json)
  end

  def index(conn, _params) do
    tag = BN.list_tag()
    render(conn, "index.html", tag: tag)
  end

  def new(conn, _params) do
    changeset = BN.change_tag(%Tag{})

    branches =
      BN.list_branch()
      |> Enum.map(fn x -> {x.branchname, x.branchid} end)
      |> Enum.reject(fn x -> elem(x, 1) == 0 end)
      |> Enum.sort_by(fn x -> elem(x, 0) end)

    render(conn, "new.html", changeset: changeset, branches: branches)
  end

  def create(conn, %{"tag" => tag_params}) do
    subcat_ids =
      conn.params["subcat_ids"]
      |> Map.keys()
      |> Enum.map(fn x -> String.to_integer(x) end)
      |> Enum.sort()
      |> Enum.map(fn x -> Integer.to_string(x) end)
      |> Enum.join(",")

    tag_params = Map.put(tag_params, "subcat_ids", subcat_ids)
    tag_params = Map.put(tag_params, "branch_id", String.to_integer(tag_params["branch_id"]))
    tag_params = Map.put(tag_params, "brand_id", BN.get_brand_id(conn))

    case BN.create_tag(tag_params) do
      {:ok, tag} ->
        conn
        |> put_flash(:info, "Printer created successfully.")
        |> redirect(
          to: branch_path(conn, :printers, BN.get_domain(conn), tag_params["branch_id"])
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Printer creation error.")
        |> redirect(to: tag_path(conn, :index, BN.get_domain(conn)))
    end
  end

  def show(conn, %{"id" => id}) do
    tag = BN.get_tag!(id)
    render(conn, "show.html", tag: tag)
  end

  def edit(conn, %{"id" => id}) do
    tag = BN.get_tag!(id)
    changeset = BN.change_tag(tag)
    render(conn, "edit.html", tag: tag, changeset: changeset)
  end

  def update(conn, %{"id" => id, "tag" => tag_params}) do
    tag = BN.get_tag!(id)

    case BN.update_tag(tag, tag_params) do
      {:ok, tag} ->
        conn
        |> put_flash(:info, "Printer updated successfully.")
        |> redirect(to: branch_path(conn, :printers, tag.branch_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", tag: tag, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    tag = BN.get_tag!(id)
    {:ok, _tag} = BN.delete_tag(tag)

    conn
    |> put_flash(:info, "Tag deleted successfully.")
    |> redirect(to: tag_path(conn, :index, BN.get_domain(conn)))
  end
end
