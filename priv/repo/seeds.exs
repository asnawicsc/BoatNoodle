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


BoatNoodle.UltiMigrator.test_api
q = from i in ItemSubcat, where: is_nil(i.itemimage)
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
