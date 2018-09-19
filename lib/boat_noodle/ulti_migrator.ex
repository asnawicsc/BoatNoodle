defmodule BoatNoodle.UltiMigrator do
  use Task
  require IEx
  import Ecto.Query

  def compare_sales_data() do
    branches =
      BoatNoodle.Repo.all(
        from(b in BoatNoodle.BN.Branch, where: b.brand_id == ^1 and b.branchid != ^0)
      )

    # diff =
    #   for branch <- branches do
    #     # Task.start_link(__MODULE__, :checking, [
    #     #   branch
    #     # ])
    #     checking(branch)
    #   end
    #   |> List.flatten()

    image_path = Application.app_dir(:boat_noodle, "priv/static/images")

    new_path = image_path <> "/not_tally_is_void_my.csv"

    # for dif <- diff do
    #   if File.exists?(new_path) do
    #     data = File.read!(new_path)
    #     list = String.split(data, "\r\n")

    #     list =
    #       List.insert_at(list, 0, "#{dif}")
    #       |> Enum.map(fn x -> x <> "\r\n" end)
    #       |> Enum.join()

    #     File.write(new_path, list)
    #     # Enum.into(list, file)
    #   else
    #     list = []

    #     list =
    #       List.insert_at(list, 0, "#{dif}")
    #       |> Enum.map(fn x -> x <> "\r\n" end)
    #       |> Enum.join()

    #     File.write(new_path, list)
    #     # Enum.into(list, file)
    #   end
    # end

    bin = File.read!(new_path)

    salesids = bin |> String.split("\r\n")

    for salesid <- salesids do
      v1s = BoatNoodle.RepoGeop.get_by(BoatNoodle.BN.Sales_v1, salesid: salesid)
      v2s = BoatNoodle.Repo.get_by(BoatNoodle.BN.Sales, brand_id: 1, salesid: salesid)

      cg =
        BoatNoodle.BN.Sales.changeset(v2s, %{
          is_void: 1,
          voidreason: v1s.voidreason,
          void_by: v1s.void_by
        })

      case BoatNoodle.Repo.update(cg) do
        {:ok, v2s} ->
          true

        {:error, cg} ->
          IEx.pry()
      end
    end
  end

  def checking(branch) do
    s_d = NaiveDateTime.from_iso8601!("2018-08-01T00:00:01")
    e_d = NaiveDateTime.from_iso8601!("2018-09-18T23:59:59")

    data =
      BoatNoodle.RepoGeop.all(
        from(
          s in BoatNoodle.BN.Sales_v1,
          # left_join: sd in BoatNoodle.BN.SalesPayment,
          # on: sd.salesid == s.salesid,
          where:
            s.branchid == ^Integer.to_string(branch.branchid) and s.salesdatetime >= ^s_d and
              s.salesdatetime <= ^e_d and s.is_void == ^1,
          select: s.salesid
        )
      )

    data2 =
      BoatNoodle.Repo.all(
        from(
          s in BoatNoodle.BN.Sales,
          # left_join: sd in BoatNoodle.BN.SalesPayment,
          # on: sd.salesid == s.salesid,
          where:
            s.branchid == ^Integer.to_string(branch.branchid) and s.salesdatetime >= ^s_d and
              s.salesdatetime <= ^e_d and s.brand_id == ^1 and s.is_void == ^1,
          select: s.salesid
        )
      )

    diff = data -- data2
  end
end
