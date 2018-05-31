defmodule BoatNoodle.Email do
  use Bamboo.Phoenix, view: BoatNoodleWeb.EmailView
  require IEx

  # def welcome_text_email(email_address) do
  #   new_email()
  #   |> to(email_address)
  #   |> from("yithanglee@gmail.com")
  #   |> subject("Welcome!")
  #   |> put_text_layout({EcomBackendWeb.LayoutView, "email.text"})
  #   |> render("welcome.text")
  # end

  def forget_password(email_address, password, name, password_not_set) do
    if password_not_set == true do
      new_email()
      |> to(email_address)
      |> from("gummy_v2@support.com")
      |> subject("Your temporary password is here! ")
      |> put_html_layout({BoatNoodleWeb.LayoutView, "email.html"})
      |> render(
        "temporary_password.html",
        password: password,
        user_name: name
      )
    else
      new_email()
      |> to(email_address)
      |> from("gummy_v2@support.com")
      |> subject("Your password is here! ")
      |> put_html_layout({BoatNoodleWeb.LayoutView, "email.html"})
      |> render(
        "forget_password_email.html",
        password: password,
        user_name: name
      )
    end
  end

  # def inform_customer_email(customer_email, message, name) do
  #  new_email()
  #  |> to("resertech3@gmail.com")
  #  |> from("system@li6rary.net")
  #  |> subject("Contact us from Li6rary!")
  #  |> put_html_layout({BoatNoodleWeb.LayoutView, "email.html"})
  #  |> render(
  #    "contact_us.html",
  #    customer_email: customer_email,
  #    message: message,
  #    name: name
  #  )
  # end
end
