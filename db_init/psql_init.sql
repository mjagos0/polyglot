-- User Accounts
create table users (
    user_id serial primary key,
    user_name varchar(255) not null unique,
    user_password varchar(255) not null, -- hashed
    user_email varchar(255) not null,
    active boolean not null default false,
    last_active timestamp default '1970-01-01 00:00:00',
    admin boolean,
    created_at timestamp default current_timestamp, 
    updated_at timestamp default current_timestamp
);

-- Product inventory
create table categories (
    id serial primary key,
    category varchar(255) not null unique
);

create table vendors (
    id serial primary key,
    vendor varchar(255) not null unique
);

create table product_types (
    id serial primary key,
    product_type varchar(255) not null unique
);

create table product_conditions (
    id serial primary key,
    product_condition varchar(255) not null unique
);

create table products (
    id serial primary key,
    category_id int references categories(id),
    vendor_id int references vendors(id),
    product_type_id int references product_types(id),
    product_condition_id int references product_conditions(id),
    mpn varchar(255) unique not null,
    product_warranty int not null, -- Years
    stock_quantity int not null,
    price real not null, -- Euro
    attributes jsonb, -- JSON to store product attributes (flexible schema)
    created_at timestamp default current_timestamp, 
    updated_at timestamp default current_timestamp
);

-- Index commonly filtered JSONB attributes
CREATE INDEX idx_productattr_processor_name ON products ((attributes->>'Processor Name'));
CREATE INDEX idx_productattr_graphics_card ON products ((attributes->>'Graphics Card'));
CREATE INDEX idx_productattr_screen_size ON products ((attributes->>'Screen Size'));
CREATE INDEX idx_productattr_ram_size ON products ((attributes->>'RAM Size'));
CREATE INDEX idx_productattr_disk_type ON products ((attributes->>'Disk Type'));
CREATE INDEX idx_productattr_disk_storage_size ON products ((attributes->>'Disk Storage Size'));
CREATE INDEX idx_productattr_operating_system ON products ((attributes->>'Operating system'));

-- sequence to assign custom MPNs for refurbished products
create sequence refurbished_mpn as int increment by 1 start with 1;

-- Product images
create table product_images (
    id serial primary key,
    product_id int references products(id),
    image_rank int,
    image_url varchar(255) not null,
    is_primary boolean default false,
    created_at timestamp default current_timestamp, 
    updated_at timestamp default current_timestamp,
    UNIQUE(product_id, image_rank, is_primary)
);

-- function to decrease stock on purchase
create or replace function purchase_item(product_id int, quantity int)
returns int 
language plpgsql
as $$
declare
    current_quantity int;
begin
    select p.quantity into current_quantity
    from products p
    where p.product_id = product_id;

    if current_quantity < quantity then
        return -1;
    else
        update products p
        set p.quantity = p.quantity - quantity
        where p.product_id = product_id;

        return 0;
    end if;
end;
$$;

-- Automatically update timestamps when updating user and products table
create or replace function user_timestamp()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = current_timestamp;
    return new;
end;
$$;

create trigger user_timestamp_trigger
before update on users
for each row
execute function user_timestamp();

create trigger product_timestamp_trigger
before update on products
for each row
execute function user_timestamp();

-- Categories
INSERT INTO categories (category)
VALUES ('Office laptop');

INSERT INTO categories (category)
VALUES ('Gaming laptop');

INSERT INTO categories (category)
VALUES ('Workstation laptop');

INSERT INTO categories (category)
VALUES ('Everyday laptop');

INSERT INTO categories (category)
VALUES ('Chromebook');

-- Vendors
INSERT INTO vendors (vendor)
VALUES ('HP');

INSERT INTO vendors (vendor)
VALUES ('Dell');

INSERT INTO vendors (vendor)
VALUES ('Lenovo');

INSERT INTO vendors (vendor)
VALUES ('ASUS');

INSERT INTO vendors (vendor)
VALUES ('Apple');

-- Product types
INSERT INTO product_types (product_type)
VALUES ('Refurbished Laptop');

INSERT INTO product_types (product_type)
VALUES ('Used Laptop');

-- Product conditions
INSERT INTO product_conditions (product_condition)
VALUES ('Excellent');

INSERT INTO product_conditions (product_condition)
VALUES ('Good');

INSERT INTO product_conditions (product_condition)
VALUES ('Fair');

-- Products
INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 1, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 3, 1, 249, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i5-9400', 'Graphics Card', null, 'Screen Size', 13.3, 'RAM Size', 8, 'Disk Type', 'HDD', 'Disk Storage Size', 2048, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 3, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 3, 12, 689, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i3-10100F', 'Graphics Card', null, 'Screen Size', 12.0, 'RAM Size', 32, 'Disk Type', 'HDD', 'Disk Storage Size', 512, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 4, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 10, 979, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i9-7960X', 'Graphics Card', 'AMD Radeon R5', 'Screen Size', 14.0, 'RAM Size', 4, 'Disk Type', 'SSD', 'Disk Storage Size', 512, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (3, 3, 1, 3, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 9, 149, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Celeron G4920', 'Graphics Card', null, 'Screen Size', 16.0, 'RAM Size', 8, 'Disk Type', 'HDD', 'Disk Storage Size', 4096, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (3, 1, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 2, 1, 829, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i9-9900X', 'Graphics Card', null, 'Screen Size', 15.6, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 256, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (2, 3, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 1, 5, 919, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 9 5900X', 'Graphics Card', null, 'Screen Size', 12.0, 'RAM Size', 8, 'Disk Type', 'HDD', 'Disk Storage Size', 1024, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 2, 1, 3, 'RFBSHLPT-' || nextval('refurbished_mpn'), 2, 14, 739, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i7-7820X', 'Graphics Card', 'AMD Radeon R4', 'Screen Size', 15.6, 'RAM Size', 4, 'Disk Type', 'SSD', 'Disk Storage Size', 1024, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 1, 2, 1, 'mJ2AwfdK', 1, 19, 1039, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 7 3700X', 'Graphics Card', null, 'Screen Size', 12.0, 'RAM Size', 128, 'Disk Type', 'HDD', 'Disk Storage Size', 256, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 4, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 4, 669, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen Threadripper 2990WX', 'Graphics Card', null, 'Screen Size', 14.0, 'RAM Size', 16, 'Disk Type', 'SSD', 'Disk Storage Size', 8192, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (3, 1, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 3, 759, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Celeron J4125', 'Graphics Card', 'Intel HD Graphics 505', 'Screen Size', 15.0, 'RAM Size', 128, 'Disk Type', 'SSD', 'Disk Storage Size', 256, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 3, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 3, 10, 499, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 9 5950X', 'Graphics Card', 'Intel UHD Graphics 605', 'Screen Size', 17.3, 'RAM Size', 128, 'Disk Type', 'HDD', 'Disk Storage Size', 512, 'Operating system', 'No OS', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (3, 4, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 2, 3, 1029, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i7-12700H', 'Graphics Card', null, 'Screen Size', 15.0, 'RAM Size', 16, 'Disk Type', 'SSD', 'Disk Storage Size', 256, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (3, 4, 1, 3, 'RFBSHLPT-' || nextval('refurbished_mpn'), 2, 4, 319, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i5-8265U', 'Graphics Card', 'AMD Radeon R4', 'Screen Size', 17.0, 'RAM Size', 64, 'Disk Type', 'SSD', 'Disk Storage Size', 256, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 4, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 6, 369, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i5-10400F', 'Graphics Card', 'NVIDIA GeForce MX150', 'Screen Size', 14.0, 'RAM Size', 32, 'Disk Type', 'HDD', 'Disk Storage Size', 128, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (2, 1, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 3, 15, 709, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Celeron J4125', 'Graphics Card', 'Intel UHD Graphics 620', 'Screen Size', 17.0, 'RAM Size', 4, 'Disk Type', 'SSD', 'Disk Storage Size', 128, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 4, 1, 3, 'RFBSHLPT-' || nextval('refurbished_mpn'), 3, 2, 619, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i7-1160G7', 'Graphics Card', 'Intel HD Graphics 400', 'Screen Size', 17.0, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 512, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 4, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 1, 2, 849, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Athlon 3000G', 'Graphics Card', null, 'Screen Size', 17.3, 'RAM Size', 64, 'Disk Type', 'HDD', 'Disk Storage Size', 256, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (5, 4, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 1, 12, 1069, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 5 3550H', 'Graphics Card', null, 'Screen Size', 15.0, 'RAM Size', 32, 'Disk Type', 'SSD', 'Disk Storage Size', 128, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 4, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 2, 16, 749, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 5 2600X', 'Graphics Card', 'NVIDIA GeForce MX130', 'Screen Size', 15.6, 'RAM Size', 8, 'Disk Type', 'HDD', 'Disk Storage Size', 1024, 'Operating system', 'Windows 11', 'Color', 'Silver')));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (3, 2, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 1, 0, 299, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i9-11900KF', 'Graphics Card', 'Intel UHD Graphics 605', 'Screen Size', 11.6, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 1024, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 3, 2, 1, 'XNA0fMCr', 2, 2, 409, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i3-10320', 'Graphics Card', 'Intel UHD Graphics 605', 'Screen Size', 17.3, 'RAM Size', 32, 'Disk Type', 'HDD', 'Disk Storage Size', 512, 'Operating system', 'No OS', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 1, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 1, 549, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 3 3200G', 'Graphics Card', null, 'Screen Size', 14.0, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 512, 'Operating system', 'Windows 10', 'Color', 'Gray')));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 4, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 3, 4, 689, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Athlon 200GE', 'Graphics Card', 'Intel UHD Graphics 600', 'Screen Size', 15.0, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 512, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (5, 2, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 3, 6, 989, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i9-7960X', 'Graphics Card', null, 'Screen Size', 14.0, 'RAM Size', 64, 'Disk Type', 'HDD', 'Disk Storage Size', 128, 'Operating system', 'No OS', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 4, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 10, 1059, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 5 1600', 'Graphics Card', 'AMD Radeon R3', 'Screen Size', 15.6, 'RAM Size', 32, 'Disk Type', 'SSD', 'Disk Storage Size', 256, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 3, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 1, 5, 919, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i5-10600K', 'Graphics Card', null, 'Screen Size', 11.6, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 4096, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 4, 2, 2, 'Y2KQ6Bz0', 4, 17, 709, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i7-10875H', 'Graphics Card', 'NVIDIA GeForce MX130', 'Screen Size', 16.0, 'RAM Size', 64, 'Disk Type', 'HDD', 'Disk Storage Size', 256, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 4, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 1, 11, 629, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 9 5950X', 'Graphics Card', 'Intel HD Graphics 400', 'Screen Size', 15.0, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 256, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 1, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 2, 5, 579, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Celeron G4920', 'Graphics Card', 'NVIDIA GeForce MX150', 'Screen Size', 13.3, 'RAM Size', 4, 'Disk Type', 'SSD', 'Disk Storage Size', 2048, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 2, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 1, 3, 549, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i7-7800X', 'Graphics Card', null, 'Screen Size', 15.6, 'RAM Size', 64, 'Disk Type', 'SSD', 'Disk Storage Size', 256, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (3, 4, 1, 3, 'RFBSHLPT-' || nextval('refurbished_mpn'), 2, 16, 639, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 3 PRO 4350G', 'Graphics Card', null, 'Screen Size', 17.0, 'RAM Size', 32, 'Disk Type', 'SSD', 'Disk Storage Size', 256, 'Operating system', 'Windows 11', 'Color', 'White')));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 3, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 4, 649, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i7-10700K', 'Graphics Card', 'Intel HD Graphics 505', 'Screen Size', 17.0, 'RAM Size', 8, 'Disk Type', 'HDD', 'Disk Storage Size', 1024, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 3, 1, 3, 'RFBSHLPT-' || nextval('refurbished_mpn'), 1, 1, 1059, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen Threadripper 2990WX', 'Graphics Card', 'AMD Radeon R5', 'Screen Size', 13.3, 'RAM Size', 8, 'Disk Type', 'HDD', 'Disk Storage Size', 256, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 1, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 2, 5, 379, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i7-9700', 'Graphics Card', null, 'Screen Size', 15.0, 'RAM Size', 64, 'Disk Type', 'Hybrid', 'Disk Storage Size', 256, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 1, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 3, 19, 269, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 3 3300X', 'Graphics Card', 'NVIDIA GeForce MX130', 'Screen Size', 17.0, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 512, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 3, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 1, 14, 559, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Athlon PRO 300GE', 'Graphics Card', null, 'Screen Size', 15.6, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 128, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (5, 1, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 12, 649, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 7 2700X', 'Graphics Card', 'Intel UHD Graphics 620', 'Screen Size', 11.6, 'RAM Size', 16, 'Disk Type', 'Hybrid', 'Disk Storage Size', 512, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 3, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 3, 11, 949, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 5 2400G', 'Graphics Card', 'Intel UHD Graphics 620', 'Screen Size', 17.0, 'RAM Size', 32, 'Disk Type', 'SSD', 'Disk Storage Size', 1024, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 4, 2, 1, '6B4qCjao', 1, 1, 609, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i9-7960X', 'Graphics Card', 'Intel UHD Graphics 620', 'Screen Size', 16.0, 'RAM Size', 128, 'Disk Type', 'SSD', 'Disk Storage Size', 256, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (3, 3, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 1, 7, 959, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 5 5600X', 'Graphics Card', 'Intel UHD Graphics 620', 'Screen Size', 17.3, 'RAM Size', 16, 'Disk Type', 'SSD', 'Disk Storage Size', 256, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 2, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 3, 1, 229, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 5 3550H', 'Graphics Card', null, 'Screen Size', 17.3, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 512, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 3, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 3, 17, 419, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 7 5800X', 'Graphics Card', 'AMD Radeon Vega 8', 'Screen Size', 16.0, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 4096, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (5, 1, 1, 3, 'RFBSHLPT-' || nextval('refurbished_mpn'), 1, 15, 219, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Xeon E-2236', 'Graphics Card', null, 'Screen Size', 13.3, 'RAM Size', 8, 'Disk Type', 'Hybrid', 'Disk Storage Size', 2048, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 3, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 3, 7, 639, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i9-12900KS', 'Graphics Card', 'NVIDIA GeForce MX110', 'Screen Size', 16.0, 'RAM Size', 64, 'Disk Type', 'SSD', 'Disk Storage Size', 128, 'Operating system', 'Windows 11', 'Color', 'Black')));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 3, 2, 1, 'NumvJ3Rb', 3, 12, 359, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i7-11800H', 'Graphics Card', 'AMD Radeon Vega 8', 'Screen Size', 17.3, 'RAM Size', 8, 'Disk Type', 'Hybrid', 'Disk Storage Size', 128, 'Operating system', 'Windows 10', 'Color', 'Black')));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 1, 2, 3, '3DQdrOpA', 1, 2, 949, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 5 1600', 'Graphics Card', null, 'Screen Size', 11.6, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 512, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (3, 2, 1, 3, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 6, 539, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i3-10110U', 'Graphics Card', null, 'Screen Size', 15.0, 'RAM Size', 128, 'Disk Type', 'SSD', 'Disk Storage Size', 128, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (3, 3, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 0, 499, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i7-11800H', 'Graphics Card', 'AMD Radeon R4', 'Screen Size', 15.0, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 512, 'Operating system', 'Windows 10', 'Color', 'Silver')));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (5, 3, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 2, 3, 1049, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i7-9700', 'Graphics Card', 'Intel UHD Graphics 600', 'Screen Size', 14.0, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 2048, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 1, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 3, 9, 709, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i7-12700H', 'Graphics Card', null, 'Screen Size', 15.0, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 128, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 3, 1, 3, 'RFBSHLPT-' || nextval('refurbished_mpn'), 2, 11, 589, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Xeon E5-2697 v3', 'Graphics Card', 'AMD Radeon R5', 'Screen Size', 15.6, 'RAM Size', 4, 'Disk Type', 'HDD', 'Disk Storage Size', 1024, 'Operating system', 'Windows 11', 'Color', 'Pink')));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (3, 3, 2, 1, 'H05o28aV', 2, 2, 689, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 9 3900X', 'Graphics Card', 'Intel HD Graphics 500', 'Screen Size', 17.0, 'RAM Size', 8, 'Disk Type', 'HDD', 'Disk Storage Size', 2048, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 4, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 15, 769, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i5-1135G7', 'Graphics Card', null, 'Screen Size', 12.0, 'RAM Size', 8, 'Disk Type', 'Hybrid', 'Disk Storage Size', 512, 'Operating system', 'Windows 10', 'Color', 'Pink')));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (3, 2, 1, 3, 'RFBSHLPT-' || nextval('refurbished_mpn'), 2, 8, 619, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 5 4500U', 'Graphics Card', null, 'Screen Size', 16.0, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 256, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 1, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 2, 2, 269, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 9 5950X', 'Graphics Card', 'Intel HD Graphics 500', 'Screen Size', 11.6, 'RAM Size', 128, 'Disk Type', 'Hybrid', 'Disk Storage Size', 512, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 3, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 1, 19, 449, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 5 5600X', 'Graphics Card', 'AMD Radeon Vega 3', 'Screen Size', 13.3, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 256, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 1, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 3, 19, 389, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i3-1115G4', 'Graphics Card', null, 'Screen Size', 17.3, 'RAM Size', 128, 'Disk Type', 'SSD', 'Disk Storage Size', 4096, 'Operating system', 'Windows 11', 'Color', 'White')));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 4, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 10, 789, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i7-8550U', 'Graphics Card', 'Intel HD Graphics 400', 'Screen Size', 17.3, 'RAM Size', 32, 'Disk Type', 'HDD', 'Disk Storage Size', 2048, 'Operating system', 'Windows 10', 'Color', 'Pink')));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 2, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 10, 969, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i5-9600KF', 'Graphics Card', 'Intel UHD Graphics 610', 'Screen Size', 15.0, 'RAM Size', 16, 'Disk Type', 'SSD', 'Disk Storage Size', 512, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 4, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 3, 19, 419, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Xeon E-2276M', 'Graphics Card', 'Intel HD Graphics 400', 'Screen Size', 12.0, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 128, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 1, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 3, 819, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i7-8750H', 'Graphics Card', null, 'Screen Size', 15.0, 'RAM Size', 8, 'Disk Type', 'HDD', 'Disk Storage Size', 512, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (5, 3, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 5, 389, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 5 2400G', 'Graphics Card', 'Intel UHD Graphics 605', 'Screen Size', 16.0, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 2048, 'Operating system', 'Windows 11', 'Color', 'Black')));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (3, 1, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 1, 989, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i7-11700KF', 'Graphics Card', 'NVIDIA GeForce MX110', 'Screen Size', 15.6, 'RAM Size', 4, 'Disk Type', 'HDD', 'Disk Storage Size', 128, 'Operating system', 'No OS', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 4, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 1, 6, 949, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen Threadripper 3970X', 'Graphics Card', 'Intel UHD Graphics 605', 'Screen Size', 14.0, 'RAM Size', 4, 'Disk Type', 'Hybrid', 'Disk Storage Size', 256, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 3, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 3, 15, 639, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i3-10100F', 'Graphics Card', null, 'Screen Size', 16.0, 'RAM Size', 4, 'Disk Type', 'SSD', 'Disk Storage Size', 256, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 3, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 2, 7, 329, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 9 5950X', 'Graphics Card', null, 'Screen Size', 17.0, 'RAM Size', 4, 'Disk Type', 'SSD', 'Disk Storage Size', 128, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 2, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 1, 19, 229, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i7-8750H', 'Graphics Card', null, 'Screen Size', 15.0, 'RAM Size', 8, 'Disk Type', 'HDD', 'Disk Storage Size', 2048, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 2, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 3, 3, 399, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i9-12900K', 'Graphics Card', 'Intel UHD Graphics 605', 'Screen Size', 15.6, 'RAM Size', 4, 'Disk Type', 'HDD', 'Disk Storage Size', 128, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (3, 3, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 0, 819, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 5 1600', 'Graphics Card', 'AMD Radeon R5', 'Screen Size', 17.0, 'RAM Size', 4, 'Disk Type', 'SSD', 'Disk Storage Size', 512, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 3, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 1, 8, 859, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i7-8550U', 'Graphics Card', 'Intel UHD Graphics 620', 'Screen Size', 15.6, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 256, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 1, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 17, 949, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 9 3950X', 'Graphics Card', null, 'Screen Size', 14.0, 'RAM Size', 16, 'Disk Type', 'Hybrid', 'Disk Storage Size', 128, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 3, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 9, 599, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Celeron G4920', 'Graphics Card', null, 'Screen Size', 14.0, 'RAM Size', 8, 'Disk Type', 'HDD', 'Disk Storage Size', 2048, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 1, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 1, 3, 759, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i3-8300', 'Graphics Card', null, 'Screen Size', 15.6, 'RAM Size', 4, 'Disk Type', 'HDD', 'Disk Storage Size', 128, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 4, 1, 3, 'RFBSHLPT-' || nextval('refurbished_mpn'), 3, 1, 1049, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i5-9400', 'Graphics Card', 'NVIDIA GeForce MX150', 'Screen Size', 15.6, 'RAM Size', 8, 'Disk Type', 'HDD', 'Disk Storage Size', 128, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 2, 1, 3, 'RFBSHLPT-' || nextval('refurbished_mpn'), 1, 13, 459, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i5-9600KF', 'Graphics Card', null, 'Screen Size', 13.3, 'RAM Size', 4, 'Disk Type', 'HDD', 'Disk Storage Size', 128, 'Operating system', 'Windows 11', 'Color', 'White')));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 3, 2, 1, '17mImZXo', 4, 13, 449, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen Threadripper 3990X', 'Graphics Card', 'Intel HD Graphics 400', 'Screen Size', 14.0, 'RAM Size', 16, 'Disk Type', 'SSD', 'Disk Storage Size', 128, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 3, 1, 3, 'RFBSHLPT-' || nextval('refurbished_mpn'), 3, 19, 329, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i3-10110U', 'Graphics Card', null, 'Screen Size', 14.0, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 128, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (3, 3, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 10, 729, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i9-10900K', 'Graphics Card', null, 'Screen Size', 11.6, 'RAM Size', 8, 'Disk Type', 'HDD', 'Disk Storage Size', 128, 'Operating system', 'No OS', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 3, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 4, 829, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 9 3950X', 'Graphics Card', 'Intel HD Graphics 500', 'Screen Size', 17.3, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 512, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (5, 1, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 1, 7, 189, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i5-8400', 'Graphics Card', null, 'Screen Size', 12.0, 'RAM Size', 32, 'Disk Type', 'SSD', 'Disk Storage Size', 2048, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 2, 1, 3, 'RFBSHLPT-' || nextval('refurbished_mpn'), 3, 18, 509, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen Threadripper 2990WX', 'Graphics Card', 'NVIDIA GeForce MX110', 'Screen Size', 17.0, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 512, 'Operating system', 'No OS', 'Color', 'Pink')));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 3, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 1, 14, 1069, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 7 1700', 'Graphics Card', 'AMD Radeon R4', 'Screen Size', 16.0, 'RAM Size', 32, 'Disk Type', 'HDD', 'Disk Storage Size', 1024, 'Operating system', 'No OS', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 4, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 16, 579, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i7-7800X', 'Graphics Card', null, 'Screen Size', 16.0, 'RAM Size', 64, 'Disk Type', 'SSD', 'Disk Storage Size', 512, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (3, 4, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 3, 719, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 3 3300X', 'Graphics Card', null, 'Screen Size', 14.0, 'RAM Size', 4, 'Disk Type', 'HDD', 'Disk Storage Size', 512, 'Operating system', 'Windows 11', 'Color', 'Gray')));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (3, 3, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 2, 5, 909, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Pentium Gold G6405', 'Graphics Card', 'Intel HD Graphics 500', 'Screen Size', 15.0, 'RAM Size', 16, 'Disk Type', 'HDD', 'Disk Storage Size', 128, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 3, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 1, 11, 259, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i7-7820X', 'Graphics Card', null, 'Screen Size', 14.0, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 1024, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (3, 2, 2, 1, 'CMs12J7E', 2, 0, 499, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 7 4800H', 'Graphics Card', 'AMD Radeon Vega 8', 'Screen Size', 13.3, 'RAM Size', 16, 'Disk Type', 'SSD', 'Disk Storage Size', 2048, 'Operating system', 'Windows 10', 'Color', 'Black')));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (3, 4, 1, 3, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 1, 599, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i7-9700', 'Graphics Card', null, 'Screen Size', 15.0, 'RAM Size', 64, 'Disk Type', 'SSD', 'Disk Storage Size', 8192, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (3, 3, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 3, 11, 679, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen Threadripper 2990WX', 'Graphics Card', 'AMD Radeon Vega 8', 'Screen Size', 17.3, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 128, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 2, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 2, 2, 699, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i7-9700', 'Graphics Card', 'AMD Radeon R5', 'Screen Size', 15.0, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 512, 'Operating system', 'No OS', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 3, 1, 3, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 14, 439, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Xeon E5-2630 v4', 'Graphics Card', null, 'Screen Size', 12.0, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 256, 'Operating system', 'No OS', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 1, 1, 3, 'RFBSHLPT-' || nextval('refurbished_mpn'), 2, 0, 749, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i9-9900X', 'Graphics Card', 'Intel HD Graphics 400', 'Screen Size', 15.0, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 1024, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 4, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 2, 14, 229, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen 5 2600X', 'Graphics Card', 'AMD Radeon R3', 'Screen Size', 17.0, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 256, 'Operating system', 'Windows 11', 'Color', 'Gray')));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (3, 4, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 1, 6, 649, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen Threadripper 3970X', 'Graphics Card', null, 'Screen Size', 15.6, 'RAM Size', 16, 'Disk Type', 'SSD', 'Disk Storage Size', 1024, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (3, 2, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 19, 439, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i7-1165G7', 'Graphics Card', null, 'Screen Size', 15.0, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 2048, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 3, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 2, 10, 249, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i5-9600K', 'Graphics Card', 'AMD Radeon R5', 'Screen Size', 15.0, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 128, 'Operating system', 'Windows 10', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (1, 1, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 1, 10, 779, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i5-10600K', 'Graphics Card', 'Intel UHD Graphics 600', 'Screen Size', 12.0, 'RAM Size', 16, 'Disk Type', 'SSD', 'Disk Storage Size', 256, 'Operating system', 'No OS', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 4, 1, 1, 'RFBSHLPT-' || nextval('refurbished_mpn'), 3, 6, 209, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i9-7980XE', 'Graphics Card', null, 'Screen Size', 13.3, 'RAM Size', 4, 'Disk Type', 'HDD', 'Disk Storage Size', 512, 'Operating system', 'No OS', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (4, 4, 1, 2, 'RFBSHLPT-' || nextval('refurbished_mpn'), 1, 11, 709, 
json_strip_nulls(json_build_object('Processor Name', 'AMD Ryzen Threadripper 3990X', 'Graphics Card', 'NVIDIA GeForce MX130', 'Screen Size', 11.6, 'RAM Size', 16, 'Disk Type', 'SSD', 'Disk Storage Size', 256, 'Operating system', 'Windows 11', 'Color', null)));

INSERT INTO products (category_id, vendor_id, product_type_id, product_condition_id, mpn, product_warranty, stock_quantity, price, attributes)
VALUES (3, 4, 1, 3, 'RFBSHLPT-' || nextval('refurbished_mpn'), 4, 14, 529, 
json_strip_nulls(json_build_object('Processor Name', 'Intel Core i7-11700KF', 'Graphics Card', 'Intel UHD Graphics 600', 'Screen Size', 15.0, 'RAM Size', 8, 'Disk Type', 'SSD', 'Disk Storage Size', 128, 'Operating system', 'Windows 11', 'Color', null)));

-- Users table
INSERT INTO users (USER_NAME, USER_PASSWORD, USER_EMAIL, ADMIN)
VALUES ('admin', 'password', 'admin@email.com', True);

INSERT INTO users (USER_NAME, USER_PASSWORD, USER_EMAIL, ADMIN)
VALUES ('user1', 'password1', 'user1@email.com', False);

INSERT INTO users (USER_NAME, USER_PASSWORD, USER_EMAIL, ADMIN)
VALUES ('user2', 'password2', 'user2@email.com', False);

INSERT INTO users (USER_NAME, USER_PASSWORD, USER_EMAIL, ADMIN)
VALUES ('user3', 'password3', 'user3@email.com', False);

INSERT INTO users (USER_NAME, USER_PASSWORD, USER_EMAIL, ADMIN)
VALUES ('user4', 'password4', 'user4@email.com', False);

INSERT INTO users (USER_NAME, USER_PASSWORD, USER_EMAIL, ADMIN)
VALUES ('user5', 'password5', 'user5@email.com', False);

INSERT INTO users (USER_NAME, USER_PASSWORD, USER_EMAIL, ADMIN)
VALUES ('testuser1', 'password1', 'testuser1@email.com', False);

INSERT INTO users (USER_NAME, USER_PASSWORD, USER_EMAIL, ADMIN)
VALUES ('testuser2', 'password2', 'testuser2@email.com', False);

INSERT INTO users (USER_NAME, USER_PASSWORD, USER_EMAIL, ADMIN)
VALUES ('testuser3', 'password3', 'testuser3@email.com', False);