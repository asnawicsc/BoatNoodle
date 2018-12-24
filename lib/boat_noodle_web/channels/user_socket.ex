defmodule BoatNoodleWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  # channel "room:*", BoatNoodleWeb.RoomChannel
  channel("user:*", BoatNoodleWeb.UserChannel)
  channel("menu_item:*", BoatNoodleWeb.CategoryHelper)
  channel("item:*", BoatNoodleWeb.ItemHelper)
  channel("tag:*", BoatNoodleWeb.TagHelper)
  channel("menu_catalog:*", BoatNoodleWeb.MenuCatalog)
  channel("sales:*", BoatNoodleWeb.SalesChannel)
  channel("report_channel:*", BoatNoodleWeb.ReportChannel)
  channel("dashboard_channel:*", BoatNoodleWeb.DashboardChannel)
  channel("restaurant:*", BoatNoodleWeb.RestaurantChannel)

  ## Transports
  transport(:websocket, Phoenix.Transports.WebSocket)
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(_params, socket) do
    {:ok, socket}
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     BoatNoodleWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
