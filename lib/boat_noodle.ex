defmodule BoatNoodle do
  @moduledoc """
  BoatNoodle keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def start_sync do
    {:ok, connection} =
      SftpEx.connect(host: '110.4.42.45', port: 2222, user: 'ubuntu', password: 'scmcapp')

    IO.inspect(connection)
    image_path = Application.app_dir(:boat_noodle, "priv/static/images")

    new_path = image_path <> "/msync.txt"
    # bin = File.read!(new_path)

    # stream =
    #   File.stream!(new_path)
    #   |> Stream.into(SftpEx.stream!(conn, "/boat_noodle/sales.txt"))
    #   |> Stream.run()
    if File.exists?(new_path) do
      SFTP.TransferService.upload(connection, "/boat_noodle/msync.txt", File.read!(new_path))
    end

    SftpEx.disconnect(connection)
  end
end
