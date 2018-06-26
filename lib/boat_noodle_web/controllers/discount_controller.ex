defmodule BoatNoodleWeb.DiscountController do
  use BoatNoodleWeb, :controller
  require IEx
  alias BoatNoodle.BN
  alias BoatNoodle.BN.Discount
  alias BoatNoodle.BN.DiscountItem
  alias BoatNoodle.BN.ItemCat
  alias BoatNoodle.BN.DiscountType
  alias BoatNoodle.BN.ItemSubcat

  def index(conn, _params) do
    discount = BN.list_discount()

    discount_details =
      Repo.all(
        from(
          s in Discount,
          select: %{
            discountid: s.discountid,
            discount_name: s.discname,
            discount_description: s.descriptions,
            activate: s.disc_qty
          }
        )
      )

    discount_items =
      Repo.all(
        from(
          s in DiscountItem,
          left_join: b in Discount,
          where: b.discountid == s.discountid,
          left_join: c in ItemCat,
          where: s.target_cat == c.itemcatid,
          left_join: d in ItemSubcat,
          where: s.is_targetmenuitems == d.subcatid,
          select: %{
            discountitemsid: s.discountitemsid,
            discitemsname: s.discitemsname,
            description: s.descriptions,
            discamtpercentage: s.discamtpercentage,
            discountcategory: b.discname,
            target_menu_category: c.itemcatname,
            target_menu_item: d.itemname,
            activate: s.disc_qty
          }
        )
      )

    discount_catalog =
      Repo.all(
        from(
          s in DiscountCatalog,
          select: %{
            id: s.id,
            name: s.name
          }
        )
      )

    render(
      conn,
      "index.html",
      discount_catalog: discount_catalog,
      discount_items: discount_items,
      discount_details: discount_details,
      discount: discount
    )
  end

  def discount_category_new(conn, params) do
   
 discount_catalog=Repo.all(from m in BoatNoodle.BN.DiscountCatalog, select: %{id: m.id, name: m.name})
  discount=Repo.all(from s in BoatNoodle.BN.Discount, select: %{id: s.discountid, name: s.discname})


    render(
      conn,
      "discount_category_new.html",discount: discount, discount_catalog: discount_catalog
    
    )
  end

   def create_discount_category_new(conn, params) do

    item=params["item"]
    discname=item["discount_name"]
     if item["amount_percentage"] =="" do
      discamtpercentage=0
    else
      discamtpercentage=item["amount_percentage"]
      
    end
    descriptions=item["description"]
    if item["status"] =="on" do
      is_visable=1
    else
      is_visable=0
      
    end

     discountid =
        Repo.all(from(c in Discount, select: %{discountid: c.discountid}))
        |> Enum.map(fn x -> Integer.to_string(x.discountid) end)
        |> List.last()

        new_discount_id= String.to_integer(discountid) + 1



  cat =BN.create_discount(%{discname: discname,discamtpercentage: discamtpercentage, descriptions: descriptions,is_visable: is_visable}) 
   

      discount=Repo.get_by(Discount,discname: discname,discamtpercentage: discamtpercentage,is_visable: is_visable)
   

      branch_ids=params["branc"]["branch"]|>String.split(",")

      for id <- branch_ids do

        id=id|>String.to_integer
        branch=Repo.get_by(DiscountCatalog, id: id,brand_id: BN.get_brand_id(conn))
        dis_categories=branch.categories
        disc_cat=dis_categories|>String.split(",")
 
        disc_id=discount.discountid|>Integer.to_string()
        all_discount_categories=List.insert_at(disc_cat,0,disc_id)
        new_categories=all_discount_categories|>Enum.join(",") 

       BN.update_discount_catalog(branch, %{categories: new_categories}) 
      end



        conn
        |> put_flash(:info, "Discount Category created successfully.")
        |> redirect(to: discount_path(conn, :index, BN.get_domain(conn)))

 


  end

  def discount_catalog_new(conn, params) do
   
 discount=Repo.all(from m in BoatNoodle.BN.Discount, select: %{discountid: m.discountid, discname: m.discname})
 discount_items=Repo.all(from m in BoatNoodle.BN.DiscountItem, left_join: d in BoatNoodle.BN.Discount, where: d.discountid==m.discountid, select: %{discname: d.discname,discountitemsid: m.discountid, discitemname: m.discitemsname})
    render(
      conn,
      "discount_catalog_new.html", discount: discount,discount_items: discount_items
    
    )
  end

    def create_discount_catalog_new(conn, params) do
       brand = BN.get_brand_id(conn)
   name=params["name"]
     categories=params["cat"]
       discounts=params["items"]

BN.create_discount_catalog(%{name: name,categories: categories, discounts: discounts,brand_id: brand}) 
   

        conn
        |> put_flash(:info, "Discount Catalog created successfully.")
        |> redirect(to: discount_path(conn, :index, BN.get_domain(conn)))

 

  end

 def discount_item_new(conn, params) do
  brand = BN.get_brand_id(conn)


 discount_catalog=Repo.all(from m in BoatNoodle.BN.DiscountCatalog, select: %{id: m.id, name: m.name})

 discount=Repo.all(from m in BoatNoodle.BN.Discount, select: %{discountid: m.discountid, discname: m.discname})
discount_type=Repo.all(from s in BoatNoodle.BN.DiscountType)

item_subcat=Repo.all(from b in BoatNoodle.BN.ItemSubcat, select: %{subcatid: b.subcatid, itemname: b.itemname,itemprice: b.itemprice,price_code: b.price_code})

  categories=Repo.all(from s in BoatNoodle.BN.ItemCat,where: s.brand_id==^brand, select: %{id: s.itemcatid, name: s.itemcatname})
    render(
      conn,
      "discount_item_new.html",discount_catalog: discount_catalog,item_subcat: item_subcat,categories: categories, discount: discount,discount_type: discount_type
    
    )
  end

   def create_discount_item_new(conn, params) do


    item=params["item"]

     discountid=item["discount_category"]|>String.to_integer
    descriptions=item["description"]
   discamtpercentage=item["discount_amount"]
    discitemsname=item["discount_item"]
    discount_percentage=item["discount_percentage"]
   
     disc_qty=item["discount_quantity"]
     type=item["discount_type"]|>String.to_integer
     all_disc_type=Repo.get_by(DiscountType,disctypeid: type)
     disc_type=all_disc_type.disctypename
    

    
    if item["target_category"] =="" do
      target_cat=0
    else
      target_cat=item["target_category"]|>String.to_integer
      
    end

     if item["discount_amount"] =="" do
      discamtpercentage=0
    else
      discamtpercentage=item["discount_amount"]
      
    end

    if item["target_item"] =="" do
      is_targetmenuitems=0
    else
      is_targetmenuitems=item["target_item"]|>String.to_integer
      
    end


    if item["status"] =="on" do
      is_used=1
    else
      is_used=0
      
    end

    min_spend=item["minimum_spend"]



  cat =BN.create_discount_item(%{discountid: discountid,discitemsname: discitemsname,
    descriptions: descriptions,discamtpercentage: discamtpercentage,
    target_cat: target_cat,disc_qty: disc_qty,disctype: disc_type,
    is_targetmenuitems: is_targetmenuitems,is_used: is_used,min_spend: min_spend}) 

  discountitem=Repo.get_by(DiscountItem,discountid: discountid,discitemsname: discitemsname,descriptions: descriptions)
   

      branch_ids=params["branc"]["branch"]|>String.split(",")

      for id <- branch_ids do

        id=id|>String.to_integer
        branch=Repo.get_by(DiscountCatalog, id: id,brand_id: BN.get_brand_id(conn))
        dis_discount=branch.discounts
        disc_discount=dis_discount|>String.split(",")
 
        disc_id=discountitem.discountitemsid|>Integer.to_string()
        all_discount_discounts=List.insert_at(disc_discount,0,disc_id)
        new_discounts=all_discount_discounts|>Enum.join(",") 

       BN.update_discount_catalog(branch, %{discounts: new_discounts}) 
      end


   
     conn
        |> put_flash(:info, "Discount Item  successfully created.")
        |> redirect(to: discount_path(conn, :index, BN.get_domain(conn)))
    
   
  end

  def discount_category_details(conn, %{"id" => id}) do
    # discount = BN.get_discount!(id)

    discount = Repo.get_by(Discount, brand_id: BN.get_brand_id(conn), discountid: id)

    disc_type = Repo.all(from(s in DiscountType))

    render(
      conn,
      "discount_category_details.html",
      disc_type: disc_type,
      discount: discount,
      id: id
    )
  end

  def edit_discount_detail(conn, params) do
   IEx.pry
  end

  def discount_item_details(conn, %{"id" => id}) do

  
    discount_items = Repo.get_by(BN.DiscountItem, brand_id: BN.get_brand_id(conn), discountitemsid: id)

     discount_a =
      Repo.all(
        from(
          s in DiscountItem,
          left_join: b in Discount,
          where: b.discountid == s.discountid,
          left_join: c in ItemCat,
          where: s.target_cat == c.itemcatid,
          left_join: d in ItemSubcat,
          where: s.is_targetmenuitems == d.subcatid and s.discountitemsid==^discount_items.discountitemsid,
          select: %{
            discountitemsid: s.discountitemsid,
            discitemsname: s.discitemsname,
            description: s.descriptions,
            disctype: s.disctype,
            discountcategory: b.discname,
            disc_qty: s.disc_qty,
            target_menu_category: c.itemcatname,
            target_menu_item: d.itemname,
            activate: s.disc_qty,
            min_spend: s.min_spend
          }
        )
      )|>hd




    render(
      conn,
      "discount_item_details.html",
      discount_items: discount_items,discount_a: discount_a
    
    )
  end

   def discount_catalog_details(conn, %{"id" => id}) do

  
    discount_catalog = Repo.get_by(DiscountCatalog, brand_id: BN.get_brand_id(conn), id: id)

      discounts = BN.list_discount()


      all_discount_catalog=Repo.all(from DiscountCatalog)

       


    render(
      conn,
      "discount_catalog_details.html",
      discount_catalog: discount_catalog,discounts: discounts,all_discount_catalog: all_discount_catalog
    
    )
  end

  def new(conn, _params) do
    changeset = BN.change_discount(%Discount{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"discount" => discount_params}) do
    case BN.create_discount(discount_params) do
      {:ok, discount} ->
        conn
        |> put_flash(:info, "Discount created successfully.")
        |> redirect(to: discount_path(conn, :show, discount))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    discount = BN.get_discount!(id)
    render(conn, "show.html", discount: discount)
  end

  def edit(conn, %{"id" => id}) do
    discount = BN.get_discount!(id)
    changeset = BN.change_discount(discount)
    render(conn, "edit.html", discount: discount, changeset: changeset)
  end

  def update(conn, %{"id" => id, "discount" => discount_params}) do
    discount = BN.get_discount!(id)

    case BN.update_discount(discount, discount_params) do
      {:ok, discount} ->
        conn
        |> put_flash(:info, "Discount updated successfully.")
        |> redirect(to: discount_path(conn, :show, discount))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", discount: discount, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    discount = BN.get_discount!(id)
    {:ok, _discount} = BN.delete_discount(discount)

    conn
    |> put_flash(:info, "Discount deleted successfully.")
    |> redirect(to: discount_path(conn, :index, BN.get_domain(conn)))
  end
end
