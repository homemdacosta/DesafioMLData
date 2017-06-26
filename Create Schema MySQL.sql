CREATE SCHEMA `dw_ml` DEFAULT CHARACTER SET latin1 ;
USE `dw_ml`;

# START: Create dimension tables
DROP TABLE IF EXISTS `dw_ml`.`dim_brand`;
CREATE TABLE `dw_ml`.`dim_brand` (
  `id_brand` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id_brand`));

DROP TABLE IF EXISTS `dw_ml`.`dim_seller`;
CREATE TABLE `dw_ml`.`dim_seller` (
  `id_seller` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id_seller`));

DROP TABLE IF EXISTS `dw_ml`.`dim_state_city`;
CREATE TABLE `dw_ml`.`dim_state_city` (
  `id_state_city` INT NOT NULL AUTO_INCREMENT,
  `sk_state_city` VARCHAR(255) NOT NULL,
  `state` VARCHAR(255) NOT NULL,
  `city` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id_state_city`));

DROP TABLE IF EXISTS `dw_ml`.`dim_product`;
CREATE TABLE `dw_ml`.`dim_product` (
  `id_product` VARCHAR(40) NOT NULL,
  `category` VARCHAR(255) NOT NULL,
  `sub_category` VARCHAR(255) NOT NULL,
  `id_brand` int not null,
  `id_seller` int not null,
PRIMARY KEY (`id_product`),
FOREIGN KEY (`id_brand`) REFERENCES dim_brand(`id_brand`),
FOREIGN KEY (`id_seller`) REFERENCES dim_seller(`id_seller`)
);

DROP TABLE IF EXISTS `dw_ml`.`dim_date`;
CREATE TABLE `dw_ml`.`dim_date` (
  `id_date` INT, 
  `date` DATE,
  `year` INT ,
  `month` INT,
  `month_name` CHAR(10) ,
  `month_day` INT , 
  `day_name` CHAR(10) ,
  `weekday` CHAR(10) DEFAULT "Weekday",
  `quarter` INT,
  PRIMARY KEY (`id_date`));

# time span
SET @d0 = "2016-01-01";
SET @d1 = "2018-12-31";
 
SET @date = date_sub(@d0, interval 1 day);

DROP TABLE IF EXISTS `T`;
CREATE TABLE `T` (
`n` int(11)
);

INSERT INTO `T`(n) SELECT @row := @row + 1 as row FROM
(select 0 union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) t,
(select 0 union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) t2,
(select 0 union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) t3,
(select 0 union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) t4,
(select 0 union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) t5,
(select 0 union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) t6,
(SELECT @row:=0) t7;

# populate the table with dates
INSERT INTO `dw_ml`.`dim_date`
SELECT 
	year(@date)*10000+month(@date)*100+day(@date) as id_date,
	@date := date_add(@date, interval 1 day) as date,
    # integer ID that allows immediate understanding
    year(@date) as year,
    month(@date) as month,
    monthname(@date) as m_name,
    day(@date) as month_day,
    dayname(@date) as day_name,
    weekday(@date)+1 as weekday,
    quarter(@date) as quarter
FROM T
WHERE date_add(@date, interval 1 day) <= @d1
ORDER BY date;
# END: Create dimension tables

# START: Create staging tables
DROP TABLE IF EXISTS `dw_ml`.`stage_orders`;
CREATE TABLE `dw_ml`.`stage_orders` (
	order_id varchar(40) ,
	customer_id varchar(40) ,
	total decimal(10,5) ,
	shipping_price decimal(10,5) ,
	city varchar(255) ,
	state varchar(255) ,
	status varchar(255) ,
	order_date datetime ,
	last_update datetime,
	PRIMARY KEY (`order_id`));

DROP TABLE IF EXISTS `dw_ml`.`stage_orderitem`;
CREATE TABLE `dw_ml`.`stage_orderitem` (
	id int,
	order_id varchar(40),
	product_id varchar(40),
	selling_price decimal(10,5),
	PRIMARY KEY (`id`)	);
# END: Create staging tables

# START: Create fact tables
DROP TABLE IF EXISTS `dw_ml`.`fact_order_quantitative`;
CREATE TABLE `dw_ml`.`fact_order_quantitative` (
  `order_id` varchar(40),
  `customer_id` varchar(40),
  `state_city_id` INT,
  `status`varchar(255),
  `order_date_id` INT,
  `last_update_id` INT,
  `shipping_price` decimal(10,5),
  `total` decimal(10,5),
  PRIMARY KEY (`order_id`),
  FOREIGN KEY (`state_city_id`) REFERENCES dim_state_city(`id_state_city`),
  FOREIGN KEY (`order_date_id`) REFERENCES dim_date(`id_date`),
  FOREIGN KEY (`last_update_id`) REFERENCES dim_date(`id_date`)
  );
  
DROP TABLE IF EXISTS `dw_ml`.`fact_order_qualitative`;
CREATE TABLE `dw_ml`.`fact_order_qualitative` (
	id int,
	order_id varchar(40) ,
	product_id varchar(40) ,
	state_city_id int ,
	order_date_id int ,
	selling_price decimal(10,5),
	PRIMARY KEY (`id`),
    FOREIGN KEY (`product_id`) REFERENCES dim_product(`id_product`),
	FOREIGN KEY (`state_city_id`) REFERENCES dim_state_city(`id_state_city`),
	FOREIGN KEY (`order_date_id`) REFERENCES dim_date(`id_date`)
);

DROP TABLE IF EXISTS `dw_ml`.`fact_mail`;
CREATE TABLE `dw_ml`.`fact_mail` (
	event_id varchar(255),
    event_type varchar(50),
    `datetime` bigint,
    `date` int,
    device varchar(50),
    os varchar(50),
    email varchar(100),
	`subject` varchar(255),
    partner varchar(255)
	,PRIMARY KEY (`event_id`,`event_type`,`datetime`)
);
# END: Create fact tables

# Create user
CREATE USER 'integration'@'localhost' IDENTIFIED BY 'integration';
GRANT ALL PRIVILEGES ON dw_ml.* TO 'integration'@'localhost';