defmodule BoatNoodleWeb.PaymentTypeController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.PaymentType
  require IEx

  def index(conn, _params) do
    branches =
      Repo.all(
        from(
          s in BoatNoodle.BN.UserBranchAccess,
          left_join: g in BoatNoodle.BN.Branch,
          on: s.branchid == g.branchid,
          where:
            s.brand_id == ^BN.get_brand_id(conn) and g.brand_id == ^BN.get_brand_id(conn) and
              s.userid == ^conn.private.plug_session["user_id"],
          select: %{branchid: s.branchid, branchname: g.branchname},
          order_by: g.branchname
        )
      )

    brand_id = BN.get_brand_id(conn)
    render(conn, "index.html", branches: branches, brand_id: brand_id)
  end

  def create_payment_type(conn, params) do
    brand_id = params["brand_id"]

    is_delivery =
      if params["is_delivery"] == nil do
        0
      else
        1
      end

    is_card_no =
      if params["is_card_no"] == nil do
        0
      else
        1
      end

    is_payment_code =
      if params["is_payment_code"] == nil do
        0
      else
        1
      end

    is_default =
      if params["is_default"] == nil do
        0
      else
        1
      end

    is_visible =
      if params["is_visible"] == nil do
        0
      else
        1
      end

    payment_type_params = %{
      payment_type_name: params["payment_type_name"],
      payment_type_code: params["payment_type_code"],
      is_delivery: is_delivery,
      is_card_no: is_card_no,
      is_payment_code: is_payment_code,
      is_default: is_default,
      is_visible: is_visible,
      brand_id: params["brand_id"]
    }

    case BN.create_payment_type(payment_type_params) do
      {:ok, payment_type} ->
        conn
        |> put_flash(:info, "Payment type created successfully.")
        |> redirect(to: payment_type_path(conn, :index, BN.get_domain(conn)))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def new(conn, _params) do
    changeset = BN.change_payment_type(%PaymentType{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"payment_type" => payment_type_params}) do
    case BN.create_payment_type(payment_type_params) do
      {:ok, payment_type} ->
        conn
        |> put_flash(:info, "Payment type created successfully.")
        |> redirect(to: payment_type_path(conn, :show, payment_type))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    payment_type = BN.get_payment_type!(id)
    render(conn, "show.html", payment_type: payment_type)
  end

  def edit(conn, %{"id" => id}) do
    payment_type = BN.get_payment_type!(id)
    changeset = BN.change_payment_type(payment_type)
    render(conn, "edit.html", payment_type: payment_type, changeset: changeset)
  end

  def update(conn, %{"id" => id, "payment_type" => payment_type_params}) do
    payment_type = BN.get_payment_type!(id)

    case BN.update_payment_type(payment_type, payment_type_params) do
      {:ok, payment_type} ->
        conn
        |> put_flash(:info, "Payment type updated successfully.")
        |> redirect(to: payment_type_path(conn, :show, payment_type))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", payment_type: payment_type, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    payment_type = BN.get_payment_type!(id)
    {:ok, _payment_type} = BN.delete_payment_type(payment_type)

    conn
    |> put_flash(:info, "Payment type deleted successfully.")
    |> redirect(to: payment_type_path(conn, :index, BN.get_domain(conn)))
  end
end
