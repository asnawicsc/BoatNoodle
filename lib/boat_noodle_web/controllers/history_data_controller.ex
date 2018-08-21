defmodule BoatNoodleWeb.HistoryDataController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.HistoryData

  def index(conn, _params) do
    history_data = BN.list_history_data()
    render(conn, "index.html", history_data: history_data)
  end
end
