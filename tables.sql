--USERS TABLE
CREATE TABLE users(
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	username VARCHAR(30) NOT NULL,
	bio VARCHAR(400),
	avatar VARCHAR(200),
	phone VARCHAR(15),		--storing phone in varchar as we don't need any calculation on it.
	email VARCHAR(40),
	password VARCHAR(50),
	status VARCHAR(15),
	CHECK (COALESCE(phone, email) IS NOT NULL)
);

--POSTS TABLE
CREATE TABLE posts(
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	url VARCHAR(200) NOT NULL,
	caption VARCHAR(240),
	lat REAL CHECK(lat is NULL OR (lat>=-90 AND lat<=90)),
	--if you don't give us a lat then it is fine, if you give us then it should satisfy our constraints.
	long REAL CHECK(long IS NULL OR(long>=-180 and long<=180)),
	user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE
	-- if a user is deleted, find all the posts associated with it and delete it.
);

--COMMENTS TABLE
CREATE TABLE comments(
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	contents VARCHAR(230) NOT NULL,
	user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	post_id INTEGER NOT NULL REFERENCES posts(id) on DELETE CASCADE
);

--LIKE TABLE
CREATE TABLE likes(
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
	comment_id INTEGER NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
	CHECK(
		COALESCE((post_id)::BOOLEAN::INTEGER, 0) --COALESCE returns first not null value.
		+
		COALESCE((comment_id)::BOOLEAN::INTEGER,0)
		=1
	),
	--this fn checks either post or comment should be defined. true::INTEGER is 1.
	-- null::BOOLEAN::INTEGER is just null.
	UNIQUE(user_id, post_id, comment_id)
	--so that  same user can't like multiple times. it will concatenate the result and it check
	-- the whole table that same row doesn't exists.
);

--PHOTO_TAGS TABLE
CREATE TABLE photo_tags(
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
	x INTEGER NOT NULL, -- to track the location of the tag, so that if we click on that pos
	y INTEGER NOT NULL, -- we get the tagged person only there
	UNIQUE(user_id, post_id) -- so that user can be mentioned in a photo only 1 time.
);

--CAPTION_TAGS TABLE
CREATE TABLE caption_tags(
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
	UNIQUE(user_id, post_id) -- so that user can be mentioned in a caption only 1 time
	-- it can be mentioned multiple times with @ but we want to store it just once.
);

--HASHTAGS TABLE
--just to store the tags onle, otherwise it will be repeated and it will affect the performance
-- of that
CREATE TABLE hashtags(
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	title VARCHAR(20) NOT NULL UNIQUE
);

--HASHTAGS_POSTS TABLE
--this table is used to track the posts and the ids of the hashtags stored in hashtags table.
CREATE TABLE hashtags_posts(
	id SERIAL PRIMARY KEY,
	hashtag_id INTEGER NOT NULL REFERENCES hashtags(id) ON DELETE CASCADE,
	post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
	--if a post is deleted delete all hashtags related to it.
	UNIQUE(hashtag_id, post_id)
	-- we can write multiple same hashtags but only want to store it once.
);

--FOLLOWERS TABLE
CREATE TABLE followers(
	id SERIAL PRIMARY KEY,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	leader_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	--leader id is deleted, delete the follower record of that also
	follower_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	--follower id is deleted, delete the particular follower record 
	UNIQUE(leader_id, follower_id)
	--so same person cannot follow other twice.
);

