create database quanlybanhang;
use quanlybanhang;

create table customers(
	customer_id int primary key auto_increment,
    customer_name varchar(100) not null,
    phone varchar(20) unique not null,
    address varchar(255)
);

create table products(
	product_id int primary key auto_increment,
    product_name varchar(100) not null unique,
    price decimal(10,2) not null,
    quantity int not null check(quantity > 0),
    category varchar(50) not null
);

create table employees(
	employee_id int primary key auto_increment,
    employee_name varchar(100) not null,
    birthday date,
    position varchar(50) not null,
    salary decimal(10,2) not null,
    revenue decimal(10,2) default 0
);

create table orders(
	order_id int primary key auto_increment,
    customer_id int,
    employee_id int,
    foreign key (customer_id) references customers(customer_id),
    foreign key (employee_id) references employees(employee_id),
    order_date datetime default current_timestamp,
    total_amount decimal(10,2) default 0
);

create table order_details(
	order_detail_id int primary key auto_increment,
    order_id int,
    product_id int,
    foreign key (order_id) references orders(order_id),
    foreign key (product_id) references products(product_id),
    quantity int not null check(quantity > 0),
    unit_price decimal(10,2) not null
);

-- 3
alter table customers
add column email varchar(100) not null unique; 

alter table employees
drop column birthday;

-- 4
-- Insert data into customers
INSERT INTO customers (customer_name, phone, address, email) VALUES
('Nguyen Van A', '0987654321', 'Hanoi', 'nguyenvana@example.com'),
('Tran Thi B', '0912345678', 'Ho Chi Minh', 'tranthib@example.com'),
('Le Van C', '0978123456', 'Da Nang', 'levanc@example.com'),
('Pham Thi D', '0965123789', 'Hai Phong', 'phamthid@example.com'),
('Hoang Van E', '0956789123', 'Can Tho', 'hoangvane@example.com');

-- Insert data into products
INSERT INTO products (product_name, price, quantity, category) VALUES
('Laptop Dell', 15000000, 10, 'Electronics'),
('iPhone 14', 25000000, 15, 'Electronics'),
('Samsung Washing Machine', 7000000, 5, 'Home Appliances'),
('Mechanical Keyboard', 1200000, 20, 'Accessories'),
('Gaming Mouse', 800000, 25, 'Accessories');

-- Insert data into employees
INSERT INTO employees (employee_name, position, salary, revenue) VALUES
('Nguyen Huu K', 'Sales Staff', 1000000, 5000000),
('Tran Minh L', 'Manager', 2000000, 10000000),
('Le Thi M', 'Customer Support', 9000000, 3000000),
('Hoang Van N', 'Accountant', 1500000, 7000000),
('Pham Thi O', 'Delivery Staff', 800000, 2000000);

-- Insert data into orders
INSERT INTO orders (customer_id, employee_id, total_amount) VALUES
(1, 1, 1500000),
(2, 2, 2500000),
(3, 3, 700000),
(4, 4, 120000),
(4, 5, 800000);

-- Insert data into order_details
INSERT INTO order_details (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 100, 1500000),
(2, 2, 50, 2500000),
(3, 3, 200, 700000),
(4, 4, 45, 120000),
(5, 5, 30, 800000);

-- 5
-- 5.1
select customer_id, customer_name, email, phone, address from customers;

-- 5.2
update products
set product_name = 'Laptop Dell XPS', price = 99.99
where product_id = 1;

-- 5.3
select o.order_id, c.customer_name, e.employee_name, o.total_amount, o.order_date
from customers c
join orders o on o.customer_id = c.customer_id
join employees e on e.employee_id = o.employee_id; 

-- 6
-- 6.1
select c.customer_id, c.customer_name, count(o.customer_id) as total_orders
from customers c
join orders o on o.customer_id = c.customer_id
group by c.customer_id;

-- 6.2
select e.employee_id, e.employee_name, sum(o.total_amount) as total_revenue
from employees e
join orders o on o.employee_id = e.employee_id
where o.order_date > '2025-01-01'
group by e.employee_id;

-- 6.3 
select p.product_id, p.product_name, sum(od.quantity) as count_quantity
from products p
join order_details od on od.product_id = p.product_id
join orders o on o.order_id = od.order_id
where month(o.order_date) = 2
group by p.product_id, p.product_name
having sum(od.quantity) > 100;

-- 7
-- 7.1
select c.customer_id, c.customer_name  
from customers c
left join orders o on o.customer_id = c.customer_id
where o.customer_id is null;

-- 7.2
select product_name, price from products
where price > (select avg(price) from products);

-- 7.3
select c.customer_id, c.customer_name, sum(o.total_amount) as total_amounts
from customers c
join orders o on o.customer_id = c.customer_id
group by c.customer_id, c.customer_name
having total_amounts = (select sum(total_amount) from orders group by customer_id order by sum(total_amount) desc limit 1);

-- 8
-- 8.1 
create view view_order_list
as
	select o.order_id, c.customer_name, e.employee_name, o.total_amount, o.order_date
    from customers c
    join orders o on o.customer_id = c.customer_id
    join employees e on e.employee_id = o.employee_id
    order by o.order_date desc;

-- 8.2
create view view_order_detail_product
as
	select od.order_detail_id, p.product_name, od.quantity, od.unit_price
    from products p
    join order_details od on od.product_id = p.product_id;
    
-- 9
-- 9.1
delimiter &&
create procedure proc_insert_employee(employee_name varchar(100), position varchar(50), salary decimal(10,2))
begin
	insert into employees(employee_name, position, salary)
    values(employee_name, position, salary);
end &&
delimiter &&  

call proc_insert_employee('Quỳnh', 'Manager', 2000000);

-- 9.2
delimiter &&
create procedure proc_get_orderdetails(orderId int)
begin
	select * from order_details
    where order_id = orderId;
end &&
delimiter && 

call proc_get_orderdetails(2);

-- 9.3
delimiter &&
create procedure proc_cal_total_amount_by_order(orderId int)
begin
	select p.product_name, sum(od.quantity) as quantity 
    from products p
    join order_details od on od.product_id = p.product_id
    where od.order_id = orderId
    group by od.product_id;
end &&
delimiter && 

call proc_cal_total_amount_by_order(4);

-- 10
delimiter &&
create trigger trigger_after_insert_order_details after insert on order_details
for each row
begin
	declare stock_quantity int;
    
    select quantity into stock_quantity
    from products
    where product_id = NEW.product_id;
    
    if stock_quantity < NEW.quantity then
		signal sqlstate '45000'
        set message_text = 'Số lượng sản phẩm trong kho không đủ';
	else
		update products
        set quantity = quantity - NEW.quantity
        where product_id = NEW.product_id;
    end if;
end &&
delimiter && 

drop trigger trigger_after_insert_order_details;

-- 11
delimiter && 
create procedure proc_insert_order_details(	
	orderId_in int,
    productId_in int,
    new_quantity int,
    price decimal(10,2)
)
begin
	declare orderId int;
    
    start transaction;
    
    select order_id into orderId from orders
    where order_id = orderId_in;
    
    if orderId is null then
		rollback;
		signal sqlstate '45000'
        set message_text = 'Không tồn tại mã hóa đơn';
	else
		insert into order_details(order_id, product_id, quantity, unit_price)
        values(orderId_in, productId_in, new_quantity, price);
        
        update orders
        set total_amount = total_amount + new_quantity * price
        where order_id = orderId_in;
        
        commit;
    end if;
end &&
delimiter && 

call proc_insert_order_details(3, 2, 10, 500000);