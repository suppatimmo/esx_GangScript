INSERT INTO `addon_account` (name, label, shared) VALUES 
	('society_gang', 'gang', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES 
	('society_gang', 'Gang', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES 
	('society_gang', 'Gang', 1)
;

INSERT INTO `jobs` (`name`, `label`, `whitelisted`) VALUES
('gang', 'Gang', 1);


-- make sure to add it for each gang :P 
INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('gang', 0, 'rank1', 'rank1name', 1500, '{}', '{}'),
('gang', 1, 'rank2', 'rank2name', 1800, '{}', '{}'),
('gang', 2, 'rank3', 'rank3name', 2100, '{}', '{}'),
('gang', 3, 'rank4', 'rank4name', 2700, '{}', '{}');