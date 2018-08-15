# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     BoatNoodle.Repo.insert!(%BoatNoodle.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

BoatNoodle.UltiMigrator.test_api()
q = from(i in ItemSubcat, where: is_nil(i.itemimage))
Repo.update_all(q, set: [itemimage: ""])
"
ALTER TABLE `posgb_boatnoodle`.`tag_tbl` 
ADD COLUMN `branch_id` INT NOT NULL AFTER `created_at`,
ADD COLUMN `subcat_ids` BINARY NULL AFTER `branch_id`,
ADD COLUMN `printer_IP` VARCHAR(255) NULL AFTER `subcat_ids`;


ALTER TABLE `posgb_boatnoodle`.`tag_tbl` 
CHANGE COLUMN `subcat_ids` `subcat_ids` TEXT NULL DEFAULT NULL ;

ALTER TABLE `posgb_boatnoodle`.`tag_tbl` 
ADD COLUMN `combo_item_ids` LONGTEXT NULL DEFAULT NULL AFTER `printer_IP`;


ALTER TABLE `chillchi_db`.`cash_in_out` 
CHANGE COLUMN `cash_type_id` `CashType` VARCHAR(50) NOT NULL ;


ALTER TABLE `posgb_boatnoodle`.`staff_log_session` 
ADD COLUMN `brand_id` INT NULL DEFAULT 1 AFTER `log_out`;


"

alias BoatNoodle.Repo
import Ecto.Query
alias BoatNoodle.BN

alias BoatNoodle.BN.{
  Discount,
  DiscountCatalog,
  DiscountCatalogMaster,
  DiscountCategory,
  DiscountItem,
  DiscountType,
  ItemCat,
  MenuCatalogMaster,
  Organization,
  PaymentType,
  Remark,
  Sales,
  SalesDetailCust,
  SalesMaster,
  SalesPayment,
  Staff,
  StaffType,
  Tag,
  TagCatalog,
  TagItems,
  Tax,
  User,
  UserBranchAccess,
  UserRole,
  VoidItems,
  ComboMap,
  ComboDetails,
  Category,
  MenuCatalog,
  ItemSubcat,
  Branch,
  Tag,
  Brand,
  ApiLog,
  Voucher
}

# find the tagitem ids from tag catalog

# for tag_id <- tag_ids do
# 	tag = Repo.get_by(Tag, tagid: tag_id, brand_id: 1)
#   Tag.changeset(%Tag{}, %{tagdesc: tag.tagdesc, printer: tag.printer, tagname: tag.tagname, branch_id: 31}, 0, "new") |> Repo.insert()
# end

tagitem_ids =
  Repo.all(from(t in TagCatalog, where: t.description == "Ikon", select: t.tagitems))
  |> hd()
  |> String.split(",")
  |> Enum.sort()
  |> Enum.reject(fn x -> x == "" end)

tag_ids =
  Repo.all(from(t in TagCatalog, where: t.description == "Ikon", select: t.tags))
  |> hd()
  |> String.split(",")
  |> Enum.sort()
  |> Enum.reject(fn x -> x == "" end)

for tag_id <- tag_ids do
  subcat_ids =
    Repo.all(
      from(
        t in TagItems,
        where: t.tagitemid in ^tagitem_ids and t.tagid == ^tag_id,
        select: t.itemcustomid
      )
    )

  old_tag = Repo.get_by(Tag, tagid: tag_id, brand_id: 1)

  if subcat_ids != [] do
    for subcat_id <- subcat_ids do
      new_tag =
        Repo.get_by(Tag, branch_id: 31, printer: old_tag.printer, tagname: old_tag.tagname)

      if new_tag == nil do
        Tag.changeset(
          %Tag{},
          %{
            tagdesc: old_tag.tagdesc,
            printer: old_tag.printer,
            tagname: old_tag.tagname,
            branch_id: 31
          },
          0,
          "new"
        )
        |> Repo.insert()
      end

      if String.length(subcat_id) > 6 do
        old_ids =
          if old_tag.combo_item_ids == nil do
            ""
          else
            old_tag.combo_item_ids
          end

        ids = old_ids |> String.split(",")
        ids = List.insert_at(ids, 0, subcat_id)
        new_ids = Enum.join(ids, ",")

        a = Tag.changeset(new_tag, %{combo_item_ids: new_ids}, 0, "Update") |> Repo.update()
      else
        old_ids =
          if old_tag.subcat_ids == nil do
            ""
          else
            old_tag.subcat_ids
          end

        ids = old_ids |> String.split(",")
        ids = List.insert_at(ids, 0, subcat_id)
        new_ids = Enum.join(ids, ",")

        a = Tag.changeset(new_tag, %{subcat_ids: new_ids}, 0, "Update") |> Repo.update()
      end
    end
  end
end

# beverage 151
subcat_ids =
  Repo.all(
    from(
      t in TagItems,
      where: t.tagitemid in ^tagitem_ids and t.tagid == ^"1",
      select: t.itemcustomid
    )
  )

for subcat_id <- subcat_ids do
  tag = Repo.get_by(Tag, branch_id: 31, tagid: 151)

  if String.length(subcat_id) > 6 do
    ids = tag.combo_item_ids |> String.split(",")
    ids = List.insert_at(ids, 0, subcat_id)
    new_ids = Enum.join(ids, ",")

    a = Tag.changeset(tag, %{combo_item_ids: new_ids}, 0, "Update") |> Repo.update()
  else
    ids = tag.subcat_ids |> String.split(",")
    ids = List.insert_at(ids, 0, subcat_id)
    new_ids = Enum.join(ids, ",")

    a = Tag.changeset(tag, %{subcat_ids: new_ids}, 0, "Update") |> Repo.update()
  end
end

# beverage 152

subcat_ids =
  Repo.all(
    from(
      t in TagItems,
      where: t.tagitemid in ^tagitem_ids and t.tagid == ^"2",
      select: t.itemcustomid
    )
  )

for subcat_id <- subcat_ids do
  tag = Repo.get_by(Tag, branch_id: 31, tagid: 152)

  if String.length(subcat_id) > 6 do
    ids = tag.combo_item_ids |> String.split(",")
    ids = List.insert_at(ids, 0, subcat_id)
    new_ids = Enum.join(ids, ",")

    a = Tag.changeset(tag, %{combo_item_ids: new_ids}, 0, "Update") |> Repo.update()
  else
    ids = tag.subcat_ids |> String.split(",")
    ids = List.insert_at(ids, 0, subcat_id)
    new_ids = Enum.join(ids, ",")

    a = Tag.changeset(tag, %{subcat_ids: new_ids}, 0, "Update") |> Repo.update()
  end
end

# beverage 153

subcat_ids =
  Repo.all(
    from(
      t in TagItems,
      where: t.tagitemid in ^tagitem_ids and t.tagid == ^"3",
      select: t.itemcustomid
    )
  )

for subcat_id <- subcat_ids do
  tag = Repo.get_by(Tag, branch_id: 31, tagid: 153)

  if String.length(subcat_id) > 6 do
    ids = tag.combo_item_ids |> String.split(",")
    ids = List.insert_at(ids, 0, subcat_id)
    new_ids = Enum.join(ids, ",")

    a = Tag.changeset(tag, %{combo_item_ids: new_ids}, 0, "Update") |> Repo.update()
  else
    ids = tag.subcat_ids |> String.split(",")
    ids = List.insert_at(ids, 0, subcat_id)
    new_ids = Enum.join(ids, ",")

    a = Tag.changeset(tag, %{subcat_ids: new_ids}, 0, "Update") |> Repo.update()
  end
end

# beverage 154

subcat_ids =
  Repo.all(
    from(
      t in TagItems,
      where: t.tagitemid in ^tagitem_ids and t.tagid == ^"4",
      select: t.itemcustomid
    )
  )

for subcat_id <- subcat_ids do
  tag = Repo.get_by(Tag, branch_id: 31, tagid: 154)

  if String.length(subcat_id) > 6 do
    ids = tag.combo_item_ids |> String.split(",")
    ids = List.insert_at(ids, 0, subcat_id)
    new_ids = Enum.join(ids, ",")

    a = Tag.changeset(tag, %{combo_item_ids: new_ids}, 0, "Update") |> Repo.update()
  else
    ids = tag.subcat_ids |> String.split(",")
    ids = List.insert_at(ids, 0, subcat_id)
    new_ids = Enum.join(ids, ",")

    a = Tag.changeset(tag, %{subcat_ids: new_ids}, 0, "Update") |> Repo.update()
  end
end

# beverage 155

subcat_ids =
  Repo.all(
    from(
      t in TagItems,
      where: t.tagitemid in ^tagitem_ids and t.tagid == ^"5",
      select: t.itemcustomid
    )
  )

for subcat_id <- subcat_ids do
  tag = Repo.get_by(Tag, branch_id: 31, tagid: 155)

  if String.length(subcat_id) > 6 do
    ids = tag.combo_item_ids |> String.split(",")
    ids = List.insert_at(ids, 0, subcat_id)
    new_ids = Enum.join(ids, ",")

    a = Tag.changeset(tag, %{combo_item_ids: new_ids}, 0, "Update") |> Repo.update()
  else
    ids = tag.subcat_ids |> String.split(",")
    ids = List.insert_at(ids, 0, subcat_id)
    new_ids = Enum.join(ids, ",")

    a = Tag.changeset(tag, %{subcat_ids: new_ids}, 0, "Update") |> Repo.update()
  end
end

Repo.all(from(t in Tag, where: t.branch_id == ^31 and t.tagid == 155))

Repo.get_by(Tag, branch_id: 31, tagid: 152)
Repo.get_by(Tag, branch_id: 31, tagid: 153)
Repo.get_by(Tag, branch_id: 31, tagid: 154)
Repo.get_by(Tag, branch_id: 31, tagid: 155)
