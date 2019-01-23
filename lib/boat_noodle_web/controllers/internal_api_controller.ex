defmodule BoatNoodleWeb.InternalApiController do
  use BoatNoodleWeb, :controller
  use Task
  import Ecto.Query
  require IEx

  def webhook_get(conn, params) do
    case params["scope"] do
      "submit_item_remark" ->
        nil

        # create the item remark

        changeset =
          BoatNoodle.BN.Remark.changeset(
            %BoatNoodle.BN.Remark{},
            params,
            BN.current_user(conn),
            "Create"
          )

        case Repo.insert(changeset) do
          {:ok, rm} ->
            # return a list of remarks...

            json_map =
              Repo.all(
                from(
                  i in Remark,
                  where:
                    i.target_item == ^params["target_item"] and i.brand_id == ^params["brand_id"],
                  select: %{
                    id: i.itemsremarkid,
                    name: i.remark,
                    price: i.price
                  }
                )
              )
              |> Poison.encode!()

            conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, json_map)

          {:error, changeset} ->
            nil
        end

      "delete_item_remark" ->
        rm = Repo.get_by(Remark, itemsremarkid: params["id"], brand_id: params["brand_id"])
        Repo.delete(rm)

        json_map =
          Repo.all(
            from(
              i in Remark,
              where: i.target_item == ^params["target_item"] and i.brand_id == ^params["brand_id"],
              select: %{
                id: i.itemsremarkid,
                name: i.remark,
                price: i.price
              }
            )
          )
          |> Poison.encode!()

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, json_map)
    end
  end
end
