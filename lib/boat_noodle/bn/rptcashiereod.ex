defmodule BoatNoodle.BN.RPTCASHIEREOD do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "rpt_cashier_eod" do
    field :branch_id, :integer
    field :branchcode, :string
    field :cash, :decimal
    field :cash_in, :decimal
    field :close_amt, :decimal
    field :deposit, :decimal
    field :dinein, :decimal
    field :drawamt, :decimal
    field :duration, :string, default: ""
    field :exp_drw_amt, :decimal
    field :extra, :decimal
    field :floats, :decimal
    field :open_amt, :decimal
    field :paidout, :decimal
    field :rptid, :integer, primary_key: true
    field :staff_name, :string
    field :takeaway, :decimal
    field :time_end, :utc_datetime
    field :time_start, :utc_datetime
    field :total_cash, :decimal
    field :total_changes, :decimal
    field :total_disc, :decimal
    field :total_pymt, :decimal
    field :total_round, :decimal
    field :total_sr, :decimal
    field :totalpax, :integer
    field :totalsales, :decimal
    field :totalsvc, :decimal
    field :totaltax, :decimal
    field :voiditem, :float
    field :voidsales, :float

  end

  @doc false
  def changeset(rptcashiereod, attrs) do
    rptcashiereod
    |> cast(attrs, [
        :rptid, 
        :branch_id,
        :staff_name,
        :time_start, 
        :time_end, 
        :duration, 
        :open_amt, 
        :close_amt, 
        :totalpax,
        :totalsales,
        :voidsales, 
        :voiditem,
        :totaltax,
        :totalsvc, 
        :total_round, 
        :dinein,
        :takeaway, 
        :total_disc, 
        :total_pymt,
        :total_cash, 
        :total_changes, 
        :floats, 
        :deposit, 
        :cash_in, 
        :paidout,
        :cash, 
        :drawamt,
        :exp_drw_amt,
        :total_sr, 
        :extra,
        :branchcode
                   ])     |> validate_required([      
 
        :branch_id,
        :staff_name,
        :time_start, 
  
     
        :open_amt, 
        :close_amt, 
        :totalpax,
        :totalsales,
        :voidsales, 
        :voiditem,
        :totaltax,
        :totalsvc, 
        :total_round, 
        :dinein,
        :takeaway, 
        :total_disc, 
        :total_pymt,
        :total_cash, 
        :total_changes, 
        :floats, 
        :deposit, 
        :cash_in, 
        :paidout,
        :cash, 
        :drawamt,
        :exp_drw_amt,
        :total_sr, 
        :extra,
        :branchcode
      ])
  end

end
