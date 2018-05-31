defmodule BoatNoodle.CheckMonthlySales do
  use Task
  import Ecto.Query
  alias BoatNoodle.Repo
  require IEx

  def start_link(branch_name, branch_id, s_date, e_date) do
    Task.start_link(__MODULE__, :run, [branch_name, branch_id, s_date, e_date])
  end

  def run(branch_name, branch_id, s_date, e_date) do
      s_date = Timex.beginning_of_month(Date.utc_today)
      e_date = Timex.end_of_month(Date.utc_today)
      total_transaction =
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: sp.salesid == s.salesid,
            where:
              s.branchid == ^branch_id and s.salesdate >= ^s_date and
                s.salesdate <= ^e_date,
            select: %{
              gst_charge: sp.gst_charge,
              grand_total: sp.grand_total,
              salesid: s.salesid,
              pax: s.pax
            }
          )
        )
# IEx.pry
      res = total_transaction |> Enum.map(fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum() |> :erlang.float_to_binary(decimals: 2)
      %{branch_name: branch_name, grand_total: res}
  end

end

# brand_ids = Repo.all(BoatNoodle.BN.Branch) |> Enum.map(fn x -> Integer.to_string(x.branchid) end)