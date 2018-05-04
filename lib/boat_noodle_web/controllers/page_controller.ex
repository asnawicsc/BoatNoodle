defmodule BoatNoodleWeb.PageController do
  use BoatNoodleWeb, :controller
  import Ecto.Query
require IEx

  def index(conn, _params) do

    
    # total=Repo.all(from s in BoatNoodle.BN.Sales, where: s.branchid== "1")
    # pax=Enum.map(total,fn x -> x.pax end)|>Enum.sum()

    # total_order=Repo.all(from sm in BoatNoodle.BN.SalesMaster,
    # left_join: s in BoatNoodle.BN.Sales, on: s.salesid== sm.salesid,
    # where: s.branchid== "1",
    # select: %{ orderid: sm.orderid})
    # order=Enum.map(total_order,fn x -> x.orderid end)|>Enum.count()
# IEx.pry
    total_transaction=Repo.all(from sp in BoatNoodle.BN.SalesPayment, left_join: s in BoatNoodle.BN.Sales,on: sp.salesid==s.salesid, where: s.branchid == ^"1" and s.salesdate == ^"2016-12-07")


    trasaction=Enum.map(total_transaction,fn x -> x.salesid end)|>Enum.count()

    tax=:erlang.float_to_binary(Enum.map(total_transaction,fn x -> Decimal.to_float(x.gst_charge) end) |> Enum.sum(), decimals: 2)

    grand_total=:erlang.float_to_binary(Enum.map(total_transaction,fn x -> Decimal.to_float(x.grand_total) end) |> Enum.sum(), decimals: 2)

    # outlet_sales_information=Repo.all(from sp in BoatNoodle.BN.SalesPayment,
    # left_join: s in BoatNoodle.BN.Sales,on: sp.salesid==s.salesid,
    # left_join: b in BoatNoodle.BN.Branch,on: s.branchid==b.branchid,
    #  where: s.branchid== "1",
    #  select: %{ branchname: b.branchname,
    #   sub_total: sp.sub_total,
    #    service_charge: sp.service_charge,
    #    gst_charge: sp.gst_charge,
    #    disc_amt: sp.disc_amt,
    #    grand_total: sp.grand_total,
    #    pax: sp.pax
    #    })
    # osi=Enum.map(outlet_sales_information,fn x -> x end)|>Enum.sum()


    render(conn, "index.html",trasaction: trasaction, tax: tax,grand_total: grand_total)
  end
 # render(conn, "index.html", pax: pax, order: order,trasaction: trasaction, tax: tax,grand_total: grand_total)

end
