defmodule BoatNoodleWeb.TagController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.Tag
  require IEx

  def toggle_printer_combo(conn, params) do

  user =BoatNoodle.Repo.get_by(BoatNoodle.BN.User, id: conn.private.plug_session["user_id"])
    
     admin_menus = BoatNoodle.Repo.all(from b in BoatNoodle.BN.UnauthorizeMenu,
     left_join: g in BoatNoodle.BN.User, on: b.role_id==g.roleid,
     left_join: c in BoatNoodle.BN.UserRole, on: g.roleid==c.roleid,
      where: g.id == ^user.id and b.active==1)|> Enum.map(fn x -> x.url end)

      path=conn.path_info|>List.delete_at(2)|>List.to_string
      status=conn.path_info|>List.last


    if Enum.any?(admin_menus, fn x -> x == conn.request_path end) do
         


         s="on";
    

         

         end

         if s=="on" do


          tuple =
            params["item_tag"]
            |> String.replace("[", "")
            |> String.replace("]", ",")
            |> String.split(",")
            |> Enum.reject(fn x -> x == "" end)
            |> List.to_tuple()

          subcat_id = elem(tuple, 0)
          subcat = Repo.get_by(ItemSubcat, subcatid: subcat_id, brand_id: BN.get_brand_id(conn))
          tag_id = elem(tuple, 1)

          tag = Repo.get_by(Tag, tagid: tag_id, brand_id: BN.get_brand_id(conn))


            action = "fail to Inserted due to Unautorize Access in"
            alert = "danger"



          map =
            %{
              printer_name: tag.tagname,
              item_name: subcat.itemname,
              action: action,
              alert: alert
            }
            |> Poison.encode!()
              send_resp(conn, 200, map)

       else

          tuple =
            params["item_tag"]
            |> String.replace("[", "")
            |> String.replace("]", ",")
            |> String.split(",")
            |> Enum.reject(fn x -> x == "" end)
            |> List.to_tuple()

          subcat_id = elem(tuple, 0)
          subcat = Repo.get_by(ItemSubcat, subcatid: subcat_id, brand_id: BN.get_brand_id(conn))
          tag_id = elem(tuple, 1)
          combo_item_id = elem(tuple,2)|> String.trim
          tag = Repo.get_by(Tag, tagid: tag_id, brand_id: BN.get_brand_id(conn))
          combo_detail = Repo.get_by(ComboDetails, combo_item_id: combo_item_id)


          if tag.combo_item_ids != nil do
            items = tag.combo_item_ids
          else
            items = ""
          end

          combo_item_ids = String.split(items, ",")

          if Enum.any?(combo_item_ids, fn x -> x == combo_item_id end) do
            new_subcatids =
              List.delete(combo_item_ids, combo_item_id) |> Enum.sort() |> Enum.reject(fn x -> x == "" end)
              |> Enum.join(",")

            action = "removed from"
            alert = "danger"
          else
            new_subcatids =
              List.insert_at(combo_item_ids, 0, combo_item_id)
              |> Enum.sort()
              |> Enum.reject(fn x -> x == "" end)
              |> Enum.join(",")

            action = "added to"
            alert = "success"
          end

          Repo.update(Tag.changeset(tag, %{combo_item_ids: new_subcatids}))

          map =
            %{
              printer_name: tag.tagname,
              item_name: combo_detail.combo_item_name,
              action: action,
              alert: alert
            }
            |> Poison.encode!()

          send_resp(conn, 200, map)
        end
  end

  def toggle_printer(conn, params) do


   user =BoatNoodle.Repo.get_by(BoatNoodle.BN.User, id: conn.private.plug_session["user_id"])
    
     admin_menus = BoatNoodle.Repo.all(from b in BoatNoodle.BN.UnauthorizeMenu,
     left_join: g in BoatNoodle.BN.User, on: b.role_id==g.roleid,
     left_join: c in BoatNoodle.BN.UserRole, on: g.roleid==c.roleid,
      where: g.id == ^user.id and b.active==1)|> Enum.map(fn x -> x.url end)

      path=conn.path_info|>List.delete_at(2)|>List.to_string
      status=conn.path_info|>List.last


    if Enum.any?(admin_menus, fn x -> x == conn.request_path end) do
         


         s="on";
    

         

         end

         if s=="on" do
           
     

          tuple =
            params["item_tag"]
            |> String.replace("[", "")
            |> String.replace("]", ",")
            |> String.split(",")
            |> Enum.reject(fn x -> x == "" end)
            |> List.to_tuple()

          subcat_id = elem(tuple, 0)
          subcat = Repo.get_by(ItemSubcat, subcatid: subcat_id, brand_id: BN.get_brand_id(conn))
          tag_id = elem(tuple, 1)

          tag = Repo.get_by(Tag, tagid: tag_id, brand_id: BN.get_brand_id(conn))


            action = "fail to Inserted due to Unautorize Access in"
            alert = "danger"



          map =
            %{
              printer_name: tag.tagname,
              item_name: subcat.itemname,
              action: action,
              alert: alert
            }
            |> Poison.encode!()
              send_resp(conn, 200, map)

   else

    tuple =
      params["item_tag"]
      |> String.replace("[", "")
      |> String.replace("]", ",")
      |> String.split(",")
      |> Enum.reject(fn x -> x == "" end)
      |> List.to_tuple()

    subcat_id = elem(tuple, 0)
    subcat = Repo.get_by(ItemSubcat, subcatid: subcat_id, brand_id: BN.get_brand_id(conn))
    tag_id = elem(tuple, 1)

    tag = Repo.get_by(Tag, tagid: tag_id, brand_id: BN.get_brand_id(conn))

    if tag.subcat_ids != nil do
      items = tag.subcat_ids
    else
      items = ""
    end

    subcat_ids = String.split(items, ",")

    if Enum.any?(subcat_ids, fn x -> x == subcat_id end) do
      new_subcatids =
        List.delete(subcat_ids, subcat_id) 
        |> Enum.sort() 
        |> Enum.reject(fn x -> x == "" end)
        |> Enum.join(",")

      action = "removed from"
      alert = "danger"
    else
      new_subcatids =
        List.insert_at(subcat_ids, 0, subcat_id)
        |> Enum.sort()
        |> Enum.reject(fn x -> x == "" end)
        |> Enum.join(",")

      action = "added to"
      alert = "success"
    end

    Repo.update(Tag.changeset(tag, %{subcat_ids: new_subcatids}))

    map =
      %{
        printer_name: tag.tagname,
        item_name: subcat.itemname,
        action: action,
        alert: alert
      }
      |> Poison.encode!()

    send_resp(conn, 200, map)

       end
  end

  def list_printer(conn, %{"subcat_id" => subcat_id}) do
    # will have subcat id 
    # need to list all available printers

    tags_original =
      Repo.all(
        from(
          t in Tag,
          left_join: b in Branch,
          on: t.branch_id == b.branchid,
          left_join: s in BN.UserBranchAccess, on: s.userid==^conn.private.plug_session["user_id"],
          where:
            t.brand_id == ^BN.get_brand_id(conn) and t.branch_id != 0 and
              b.brand_id == ^BN.get_brand_id(conn) and b.branchid==s.branchid,
          select: %{
            tag_id: t.tagid,
            branchname: b.branchname,
            tagname: t.tagname,
            items: t.subcat_ids,
            combos: t.combo_item_ids
          }
        )
      )
      |> Enum.map(fn x -> Map.put(x, :items, String.split(x.items, ",")) end)
      |> Enum.map(fn x -> Map.put(x, :combos, String.split(x.combos, ",")) end)
      |> Enum.group_by(fn x -> x.branchname end)


    json = tags_original |> Poison.encode!()

    send_resp(conn, 200, json)
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
    id=id|>String.to_integer

    tag = Repo.get_by(Tag,tagid: id,brand_id: BN.get_brand_id(conn))
    changeset = BN.change_tag(tag)
    render(conn, "edit.html", tag: tag, changeset: changeset)
  end

  def update(conn, %{"id" => id, "tag" => tag_params}) do

      id=id|>String.to_integer

      tag = Repo.get_by(Tag,tagid: id,brand_id: BN.get_brand_id(conn))

      case BN.update_tag(tag, tag_params) do
        {:ok, tag} ->

          conn
          |> put_flash(:info, "Printer updated successfully.")
          |> redirect(to: branch_path(conn, :printers,BN.get_domain(conn), tag.branch_id))

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
