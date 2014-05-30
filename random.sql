CREATE TABLE random_table
(
	id SMALLINT UNSIGNED NOT NULL,
	random_value INT UNSIGNED NOT NULL,
	PRIMARY KEY USING BTREE (id)
) ENGINE = INNODB
COMMENT = 'pick random id by random_value'
;

DROP PROCEDURE IF EXISTS pick_id;

delimiter $

CREATE PROCEDURE pick_id
(
)
--
BEGIN

	DECLARE var_sum INT UNSIGNED;
	DECLARE var_rand INT UNSIGNED;

	DECLARE var_err_i INT SIGNED;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
		BEGIN
			SELECT IFNULL(var_err_i,-1) AS errno;
		END;

	SET @a = 1;

	SELECT
		SUM(random_value)
	INTO
		var_sum
	FROM
		random_table;

	SET var_rand = FLOOR(1 + RAND() * var_sum);

	SELECT
		id
	FROM
		(
		SELECT
			id,
			@a AS sp,
			@a := @a + random_value AS ep
		FROM
			random_table
		) AS r
	WHERE
		r.sp <= var_rand
		AND r.ep > var_rand;

END
$
delimiter ;

CALL pick_id();
