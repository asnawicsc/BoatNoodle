defmodule BoatNoodleWeb.TagHelper do
  use BoatNoodleWeb, :channel
  require IEx

  def join("tag:" <> user_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("query_branch_subcats", %{"id" => id}, socket) do
    branch = BN.get_branch!(id)
    menu_cat = Repo.get(MenuCatalog, branch.menu_catalog)

    item_ids = menu_cat.items |> String.split(",") |> Enum.reject(fn x -> x == "" end)
    combo_ids = menu_cat.combo_items |> String.split(",") |> Enum.reject(fn x -> x == "" end)

    subcats =
      Repo.all(
        from(
          s in ItemSubcat,
          where: s.subcatid in ^item_ids,
          select: %{
            id: s.subcatid,
            name: s.itemname
          },
          order_by: [asc: s.itemname]
        )
      )

    html =
      Phoenix.View.render_to_string(
        BoatNoodleWeb.TagView,
        "subcat_checkbox.html",
        subcats: subcats
      )

    broadcast(socket, "show_branch_subcats", %{item_ids: item_ids, html: html})
    {:noreply, socket}
  end

  def handle_in("toggle_printer", %{"info" => info}, socket) do
    tuple_data =
      info
      |> String.replace("][", ",")
      |> String.replace("[", ",")
      |> String.replace("]", ",")
      |> String.split(",")
      |> List.to_tuple()

    tagid = elem(tuple_data, 1)
    subcatid = elem(tuple_data, 2)

    tag = Repo.get(Tag, tagid)
    subcat = Repo.get(ItemSubcat, subcatid)
    existing_subcats = tag.subcat_ids |> String.split(",")

    if Enum.any?(existing_subcats, fn x -> x == subcatid end) do
      new_subcatids = List.delete(existing_subcats, subcatid) |> Enum.sort() |> Enum.join(",")
      action = "removed from"
      alert = "danger"
    else
      new_subcatids =
        List.insert_at(existing_subcats, 0, subcatid) |> Enum.sort() |> Enum.join(",")

      action = "added to"
      alert = "success"
    end

    cg = Tag.changeset(tag, %{subcat_ids: new_subcatids})

    case Repo.update(cg) do
      {:ok, tag} ->
        broadcast(socket, "updated_printer", %{
          printer_name: tag.tagname,
          item_name: subcat.itemname,
          action: action,
          alert: alert
        })

      _ ->
        IO.puts("printer update failed")
        true
    end

    {:noreply, socket}
  end

  def handle_in("toggle_user_branch", %{"info" => info}, socket) do
    tuple_data =
      info
      |> String.replace("][", ",")
      |> String.replace("[", ",")
      |> String.replace("]", ",")
      |> String.split(",")
      |> List.to_tuple()

    user_id = elem(tuple_data, 1)
    branch_id = elem(tuple_data, 2)

    user = Repo.get(User, user_id)
    branch = Repo.get(Branch, branch_id)

    # Repo.all(
    #   from(u in UserBranchAccess, where: u.userid == ^user_id and u.branch_id == ^branch_id)
    # )
    uba = Repo.get_by(UserBranchAccess, userid: user_id, branchid: branch_id)

    if uba != nil do
      Repo.delete(uba)
      action = "removed from"
      alert = "danger"
    else
      cg =
        UserBranchAccess.changeset(%UserBranchAccess{}, %{userid: user_id, branchid: branch_id})

      Repo.insert(cg)
      action = "added to"
      alert = "success"
    end

    broadcast(socket, "updated_branch_access", %{
      user_name: user.username,
      branch_name: branch.branchname,
      action: action,
      alert: alert
    })

    {:noreply, socket}
  end

  defp authorized?(_payload) do
    true
  end
end
