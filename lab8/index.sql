CREATE INDEX in_types_ind ON income USING hash (type);
CREATE INDEX in_dates_ind ON income USING btree (date);
CREATE INDEX in_amount_ind ON income USING btree (amount);

CREATE INDEX sp_types_ind ON spending USING hash (type);
CREATE INDEX sp_dates_ind ON spending USING btree (date);
CREATE INDEX sp_amount_ind ON spending USING btree (amount);
