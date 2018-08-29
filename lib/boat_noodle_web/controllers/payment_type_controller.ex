defmodule BoatNoodleWeb.PaymentTypeController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.PaymentType

  def index(conn, _params) do
       branches =
      Repo.all(
        from(
          s in BoatNoodle.BN.UserBranchAccess,
          left_join: g in BoatNoodle.BN.Branch, on: s.branchid==g.branchid,
          where: s.brand_id == ^BN.get_brand_id(conn) and g.brand_id == ^BN.get_brand_id(conn) and s.userid==^conn.private.plug_session["user_id"],
          select: %{branchid: s.branchid,branchname: g.branchname},
          order_by: g.branchname
        )
      )
    render(conn, "index.html", branches: branches)
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
