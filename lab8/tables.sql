CREATE TABLE member (
	id SERIAL PRIMARY KEY,
	name varchar(10) NOT NULL UNIQUE 
);

CREATE TABLE adult (
	id integer PRIMARY KEY,
	FOREIGN KEY(id) REFERENCES member(id) ON DELETE CASCADE
);

CREATE TABLE budget (
	id integer PRIMARY KEY,
	amount money not null,
	CHECK(amount >= 0::money),
	FOREIGN KEY(id) REFERENCES member(id) ON DELETE CASCADE 
);

CREATE TABLE income (
	id SERIAL PRIMARY KEY,
	mem_id integer REFERENCES member(id) ON DELETE RESTRICT,
	amount money not null,
	CHECK(amount >= 0::money),
	date date not null,
	type in_type not null
);

CREATE TABLE spending (
	id SERIAL PRIMARY KEY,
	mem_id integer REFERENCES member(id) ON DELETE RESTRICT,
	amount money not null,
	CHECK(amount >= 0::money),
	date date not null,
	type sp_type not null
);
