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

ALTER TABLE `posgb_boatnoodle`.`tag_tbl` 
ADD COLUMN `combo_item_ids` LONGTEXT NULL DEFAULT NULL AFTER `printer_IP`;


CREATE TABLE `posgb_boatnoodle`.`brand` (
  `brand_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`brand_id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC));

ALTER TABLE `posgb_boatnoodle`.`brand` 
ADD COLUMN `domain_name` VARCHAR(45) NOT NULL AFTER `name`,
ADD UNIQUE INDEX `domain_name_UNIQUE` (`domain_name` ASC);

ALTER TABLE `posgb_boatnoodle`.`branch` 
ADD COLUMN `brand_ID` INT NOT NULL DEFAULT 1 AFTER `created_at`;

ALTER TABLE `posgb_boatnoodle`.`branch` 
ADD INDEX `brand_id` (`brand_ID` ASC);
ALTER TABLE `posgb_boatnoodle`.`branch` 
ADD CONSTRAINT `fk_branch_brand`
  FOREIGN KEY (`brand_ID`)
  REFERENCES `posgb_boatnoodle`.`brand` (`brand_id`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;


ALTER TABLE `posgb_boatnoodle`.`combo_details` 
ADD COLUMN `brand_ID` INT NOT NULL DEFAULT 1;

ALTER TABLE `posgb_boatnoodle`.`combo_details` 
ADD INDEX `combo_detail_brand_idx` (`brand_ID` ASC);
ALTER TABLE `posgb_boatnoodle`.`combo_details` 
ADD CONSTRAINT `combo_detail_brand`
  FOREIGN KEY (`brand_ID`)
  REFERENCES `posgb_boatnoodle`.`brand` (`brand_id`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE `posgb_boatnoodle`.`discount` 
ADD COLUMN `brand_ID` INT(11) NOT NULL DEFAULT '1' ;

ALTER TABLE `posgb_boatnoodle`.`discount` 
ADD CONSTRAINT `disc_brand`
  FOREIGN KEY (`brand_ID`)
  REFERENCES `posgb_boatnoodle`.`brand` (`brand_id`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE `posgb_boatnoodle`.`discount_catalog` 
ADD COLUMN `brand_ID` INT(11) NOT NULL DEFAULT '1';

ALTER TABLE `posgb_boatnoodle`.`discount_catalog` 
ADD CONSTRAINT `disc_cat_brand`
  FOREIGN KEY (`brand_ID`)
  REFERENCES `posgb_boatnoodle`.`brand` (`brand_id`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE `posgb_boatnoodle`.`discountitems` 
ADD COLUMN `brand_ID` INT(11) NOT NULL DEFAULT '1';

ALTER TABLE `posgb_boatnoodle`.`discountitems` 
ADD CONSTRAINT `disc_item_brand`
  FOREIGN KEY (`brand_ID`)
  REFERENCES `posgb_boatnoodle`.`brand` (`brand_id`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE `posgb_boatnoodle`.`item_cat` 
ADD COLUMN `brand_ID` INT(11) NOT NULL DEFAULT '1';

ALTER TABLE `posgb_boatnoodle`.`item_cat` 
ADD CONSTRAINT `item_cat_brand`
  FOREIGN KEY (`brand_ID`)
  REFERENCES `posgb_boatnoodle`.`brand` (`brand_id`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE `posgb_boatnoodle`.`itemsremak` 
ADD COLUMN `brand_ID` INT(11) NOT NULL DEFAULT '1';

ALTER TABLE `posgb_boatnoodle`.`itemsremak` 
ADD CONSTRAINT `itemsremak_brand`
  FOREIGN KEY (`brand_ID`)
  REFERENCES `posgb_boatnoodle`.`brand` (`brand_id`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;
"
