CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,
  
  FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_followers (
  id INTEGER PRIMARY KEY,
  
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  
  body TEXT NOT NULL,
  r_parent_id INTEGER,
  r_user_id INTEGER NOT NULL,
  r_question_id INTEGER NOT NULL,
  
  FOREIGN KEY (r_user_id) REFERENCES users(id)
  FOREIGN KEY (r_parent_id) REFERENCES replies(id)
  FOREIGN KEY (r_question_id) REFERENCES questions(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  
  likes_question VARCHAR(10),
  like_user_id INTEGER NOT NULL,
  like_question_id INTEGER NOT NULL,
  
  FOREIGN KEY (like_user_id) REFERENCES users(id)
  FOREIGN KEY (like_question_id) REFERENCES questions(id)
);

INSERT INTO
  users(fname, lname)
VALUES
  ('Peter', 'Bardon'),
  ('Calvin', 'Rachuy'),
  ('Jessie', 'James'),
  ('Barack', 'Obama'),
  ('Quincy', 'Jones'),
  ('Ronda', 'Rousey');
  
INSERT INTO
  questions(title, body, author_id)
VALUES
  ('First Question', 'What is the meaning of life?', 
    (SELECT id FROM users WHERE fname = 'Peter')),
  ('Third Question', 'What is three?', 
    (SELECT id FROM users WHERE fname = 'Barack')),
  ('Date', 'Go out with me?', 
    (SELECT id FROM users WHERE fname = 'Quincy')),  
  ('Second Question', 'What is the best burger?',
    (SELECT id FROM users WHERE lname = "Rachuy"));
    
INSERT INTO
  question_followers(question_id, user_id)
VALUES
  ((SELECT id FROM questions WHERE id = 1),
    (SELECT id FROM users WHERE id = 1)),
  ((SELECT id FROM questions WHERE id = 1),
    (SELECT id FROM users WHERE id = 2)),
  ((SELECT id FROM questions WHERE id = 1),
    (SELECT id FROM users WHERE id = 3)),
  ((SELECT id FROM questions WHERE id = 2),
      (SELECT id FROM users WHERE id = 3));
    
INSERT INTO
  replies(body, r_parent_id, r_user_id, r_question_id)
VALUES
  ('whoah deep man', NULL,
    (SELECT id FROM users WHERE fname = 'Calvin'),
    (SELECT id FROM questions  WHERE title LIKE 'First%')),
    /*2*/
  ('2whoah deep man2', 1,
    (SELECT id FROM users WHERE fname = 'Peter'),
    (SELECT id FROM questions  WHERE title LIKE 'First%')),
  ('3whoah deep man3', 2,
    (SELECT id FROM users WHERE fname = 'Quincy'),
    (SELECT id FROM questions  WHERE title LIKE 'First%')),
    
  ('Who are you asking out?', NULL,
    (SELECT id FROM users WHERE fname = 'Calvin'),
    (SELECT id FROM questions  WHERE title LIKE 'Date%'));
    
INSERT INTO
  question_likes(likes_question, like_user_id, like_question_id)
VALUES
  ('yes',
    (SELECT id FROM users WHERE fname = 'Peter'),
    (SELECT id FROM questions  WHERE body LIKE '%burger%')),
  ('yes',
    (SELECT id FROM users WHERE fname = 'Ronda'),
    (SELECT id FROM questions  WHERE title LIKE 'Date%')),
  ('yes',
    (SELECT id FROM users WHERE fname = 'Barack'),
    (SELECT id FROM questions  WHERE title LIKE 'Date%'));