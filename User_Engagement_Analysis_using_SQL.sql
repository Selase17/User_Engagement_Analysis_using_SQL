
-- User Engagement Analysis: Problem Statement
-- Write SQL queries to gain insights into user engagement by addressing the following problems:

-- 1. Retrieve the comprehensive count of likes, comments, and shares garnered by a specific post identified by its unique post ID.
-- 2. Calculate the mean number of reactions, encompassing likes, comments, and shares, per distinct user within a designated time period.
-- 3. Identify the three most engaging posts, measured by the aggregate sum of reactions, within the preceding week.

-- Below are the input tables for solving these problems:

-- Posts:
-- +---------+-----------------------------------------+---------------------+
-- | post_id | post_content                            | post_date           |
-- +---------+-----------------------------------------+---------------------+
-- |       1 | Lorem ipsum dolor sit amet...           | 2023-08-25 10:00:00 |
-- |       2 | Exploring the beauty of nature...       | 2023-08-26 15:30:00 |
-- |       3 | Unveiling the latest tech trends...     | 2023-08-27 12:00:00 |
-- |       4 | Journey into the world of literature... | 2023-08-28 09:45:00 |
-- |       5 | Capturing the essence of city life...   | 2023-08-29 16:20:00 |
-- +---------+-----------------------------------------+---------------------+

-- UserReactions:
-- +-------------+---------+---------+---------------+---------------------+
-- +-------------+---------+---------+---------------+---------------------+
-- |           1 |     101 |       1 | like          | 2023-08-25 10:15:00 |
-- |           2 |     102 |       1 | comment       | 2023-08-25 11:30:00 |
-- |           3 |     103 |       1 | share         | 2023-08-26 12:45:00 |
-- |           4 |     101 |       2 | like          | 2023-08-26 15:45:00 |
-- |           5 |     102 |       2 | comment       | 2023-08-27 09:20:00 |
-- |           6 |     104 |       2 | like          | 2023-08-27 10:00:00 |
-- |           7 |     105 |       3 | comment       | 2023-08-27 14:30:00 |
-- |           8 |     101 |       3 | like          | 2023-08-28 08:15:00 |
-- |           9 |     103 |       4 | like          | 2023-08-28 10:30:00 |
-- |          10 |     105 |       4 | share         | 2023-08-29 11:15:00 |
-- |          11 |     104 |       5 | like          | 2023-08-29 16:30:00 |
-- |          12 |     101 |       5 | comment       | 2023-08-30 09:45:00 |
-- +-------------+---------+---------+---------------+---------------------+


-- SOLUTION

-- CREATING THE TABLES FOR THE SQL DATABASE

-- Posts:
drop table Posts;
create table Posts(
post_id int primary key,
post_content text,
post_date datetime
);

-- UserReactions:

drop table UserReactions;
create table UserReactions(
reaction_id int primary key,
user_id int,
post_id int,
reaction_type enum('like', 'comment', 'share'),
reaction_date datetime,
foreign key(post_id) references Posts(post_id)
);

-- POPULATING THE TABLES
-- Posts values
insert into Posts values(1, 'Lorem ipsum dolor sit amet...', '2023-08-25 10:00:00');
insert into Posts values(2, 'Exploring the beauty of nature...', '2023-08-26 15:30:00');
insert into Posts values(3, 'Unveiling the latest tech trends...', '2023-08-27 12:00:00');
insert into Posts values(4, 'Journey into the world of literature...', '2023-08-28 09:45:00');
insert into Posts values(5, 'Capturing the essence of city life...', '2023-08-29 16:20:00');

-- UserReactions values
insert into UserReactions values(1, 101, 1, 'like','2023-08-25 10:15:00');
insert into UserReactions values(2, 102, 1, 'comment','2023-08-25 11:30:00');
insert into UserReactions values(3, 103, 1, 'share','2023-08-26 12:45:00');
insert into UserReactions values(4, 101, 2, 'like','2023-08-26 15:45:00');
insert into UserReactions values(5, 102, 2, 'comment','2023-08-27 09:20:00');
insert into UserReactions values(6, 104, 2, 'like','2023-08-27 10:00:00');
insert into UserReactions values(7, 105, 3, 'comment','2023-08-27 14:30:00');
insert into UserReactions values(8, 101, 3, 'like','2023-08-28 08:15:00');
insert into UserReactions values(9, 103, 4, 'like','2023-08-28 10:30:00');
insert into UserReactions values(10, 105, 4, 'share','2023-08-29 11:15:00');
insert into UserReactions values(11, 104, 5, 'like','2023-08-29 16:30:00');
insert into UserReactions values(12, 101, 5, 'comment','2023-08-30 09:45:00');

SELECT * from userreactions;

-- 1. Retrieve the comprehensive count of likes, comments, and shares garnered by a specific post identified by its unique post ID.

SELECT p.post_id, p.post_content,
    count(case when ur.reaction_type = 'like' then 1 end) as num_likes,
    count(case when ur.reaction_type = 'comment' then 1 END) as num_comments,
    count(case when ur.reaction_type = 'share' THEN 1 END) as num_shares
from
    posts p
LEFT JOIN
    userreactions ur on p.post_id = ur.post_id
WHERE
    p.post_id = 3
GROUP BY
    p.post_id, p.post_content;


-- Calculating the mean number of reactions, encompassing likes, comments, and shares, per distinct user within a designated time period:

SELECT
    date(ur.reaction_date) as reaction_day,
    count(distinct ur.user_id) AS distinct_users,
    count(*) as total_reactions,
    avg(count(*)) over (PARTITION BY date(ur.reaction_date)) as avg_reations_per_user
FROM
    UserReactions ur
WHERE
    ur.reaction_date BETWEEN '2023-08-25' AND '2023-08-31'
GROUP BY
    reaction_day;


-- Identifying the three most engaging posts, measured by the aggregate sum of reactions, within the preceding week:

SELECT
    p.post_id,
    p.post_content,
    SUM(CASE WHEN ur.reaction_type = 'like' THEN 1 ELSE 0 END +
        CASE WHEN ur.reaction_type = 'comment' THEN 1 ELSE 0 END +
        CASE WHEN ur.reaction_type = 'share' THEN 1 ELSE 0 END) AS total_reactions
FROM
    Posts p
LEFT JOIN
    UserReactions ur ON p.post_id = ur.post_id
WHERE
    ur.reaction_date BETWEEN DATE_SUB(NOW(), INTERVAL 1 WEEK) AND NOW()
GROUP BY
    p.post_id, p.post_content
ORDER BY
    total_reactions DESC
LIMIT
    3; -- Retrieve the top 3 most engaging posts
