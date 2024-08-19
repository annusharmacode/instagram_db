USE instagram;

##QUES 1. How many times does the average user post?

SELECT ROUND( 
(SELECT COUNT(*) FROM photos) *1.0 / (SELECT COUNT(*) FROM users),2) AS average_posts_per_user;


## QUES 2. Retrieve users who have not posted any photos

SELECT id, username from users
WHERE id NOT IN(SELECT DISTINCT user_id FROM photos);


##QUES 3. Find the top 5 most used hashtags.

SELECT t.tag_name, COUNT(*) AS count
FROM tags t
INNER JOIN photo_tags p
ON t.id = p.tag_id
GROUP BY t.id
ORDER BY count DESC
LIMIT 5;



##QUES 4. Find users who have liked every single photo on the site.

SELECT u.username,
    COUNT(*) AS num_likes
FROM
    users u
JOIN
    likes l ON u.id = l.user_id
GROUP BY
    l.user_id
HAVING
    num_likes = (
        SELECT COUNT(*) 
        FROM photos
    ); 


##QUES 5. Retrieve a list of users along with their usernames and the rank of their account creation, ordered by the creation date in ascending order.

SELECT username , created_at,
RANK() OVER (ORDER BY created_at ASC) AS creation_rank
FROM users 
ORDER BY created_at ASC;


##QUES 6. List the comments made on photos with their comment texts, photo URLs, and usernames of users who posted the comments. Include the comment count for each photo

SELECT
    c.comment_text,
    p.image_url,
    u.username AS commenter_username,
    COUNT(c.id) OVER (PARTITION BY p.id) AS comment_count
FROM
    comments c
JOIN
    photos p ON c.photo_id = p.id
JOIN
    users u ON c.user_id = u.id
    ORDER BY
    comment_count DESC;
    



##QUES 7. For each tag, show the tag name and the number of photos associated with that tag. Rank the tags by the number of photos in descending order.

SELECT t.tag_name, COUNT(pt.photo_id) AS num_photos,
DENSE_RANK() OVER (ORDER BY COUNT(pt.photo_id) DESC) AS tag_rank
FROM tags t
INNER JOIN photo_tags pt ON t.id = pt.tag_id
GROUP BY t.tag_name
ORDER BY num_photos DESC;



##QUES 8. List the usernames of users who have posted photos along with the count of photos they have posted. Rank them by the number of photos in descending order.

SELECT u.username, COUNT(p.id) AS num_photos,
DENSE_RANK() OVER (ORDER BY COUNT(p.id) DESC) AS user_rank
FROM users u
INNER JOIN photos p ON u.id = p.user_id
GROUP BY u.id, u.username
ORDER BY num_photos DESC;



##QUES 9. Display the username of each user along with the creation date of their first posted photo and the creation date of their next posted photo.


WITH ranked_photos AS (
    SELECT
        u.id AS user_id,
        u.username,
        p.created_at,
        ROW_NUMBER() OVER (PARTITION BY u.id ORDER BY p.created_at) AS photo_rank
    FROM
        users u
    LEFT JOIN
        photos p ON u.id = p.user_id
)
SELECT
    user_id,
    username,
    MIN(CASE WHEN photo_rank = 1 THEN created_at END) AS first_photo_creation_date,
    MIN(CASE WHEN photo_rank = 2 THEN created_at END) AS next_photo_creation_date
FROM
    ranked_photos
GROUP BY
    user_id, username
ORDER BY
    user_id;


##QUES 10. For each comment, show the comment text, the username of the commenter, and the comment text of the previous comment made on the same photo.


WITH CommentDetails AS (
    SELECT
        c.id AS comment_id,
        c.comment_text,
        c.photo_id,
        c.user_id AS commenter_id,
        u.username AS commenter_username,
        LAG(c.comment_text) OVER (PARTITION BY c.photo_id ORDER BY c.created_at) AS prev_comment_text
    FROM
        comments c
    INNER JOIN
        users u ON c.user_id = u.id
)
SELECT
    comment_id,
    comment_text,
    commenter_username,
    prev_comment_text
FROM
    CommentDetails
ORDER BY
    photo_id, comment_id;


