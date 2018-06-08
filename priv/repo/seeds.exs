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

"
ALTER TABLE `posgb_boatnoodle`.`tag_tbl` 
ADD COLUMN `branch_id` INT NOT NULL AFTER `created_at`,
ADD COLUMN `subcat_ids` BINARY NULL AFTER `branch_id`,
ADD COLUMN `printer_IP` VARCHAR(255) NULL AFTER `subcat_ids`;

ALTER TABLE `posgb_boatnoodle`.`tag_tbl` 
CHANGE COLUMN `subcat_ids` `subcat_ids` TEXT NULL DEFAULT NULL ;


"
