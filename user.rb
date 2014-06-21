class User
  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM users')
    results.map {|result| User.new(result)}
  end
  
  attr_accessor :id, :fname, :lname
  
  def initialize(options = {})
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end
  
  def save
    return update unless @id.nil?
    
    QuestionsDatabase.instance.execute(
      <<-SQL, fname, lname)
      INSERT INTO
        users(fname, lname)
      VALUES
        (?, ?)
      SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end
  
  def update
    QuestionsDatabase.instance.execute(
    <<-SQL, fname, lname, id)
    UPDATE
      users
    SET
      fname = (?),
      lname = (?)
    
    WHERE
      id =(?)
    SQL
  end
  
  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        users.id = (?)
      SQL
      
      process_results(results)
  end
  
  def self.find_by_name(fname, lname)
    results = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = (?) AND lname = (?)
      SQL
      
      process_results(results)
  end
    
  def self.process_results(results)
    raise 'not found' if results.nil?
    User.new(results.first)
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end
  
  def authored_replies
    Reply.find_by_user_id(@id)
  end
  
  def followed_questions
    QuestionFollower.followed_questions_for_user_id(@id)
  end
  
  def like_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end
  
  def average_karma
    
    result = QuestionsDatabase.instance.execute(<<-SQL, @id)
    
      SELECT
        (CAST(COUNT(like_user_id) AS FLOAT) / CAST(COUNT(DISTINCT(questions.id)) AS FLOAT)) AS Answer
      FROM
        questions
      LEFT OUTER JOIN
        question_likes
      ON
        questions.id = question_likes.like_question_id
      WHERE
        questions.author_id = (?)
      GROUP BY
        questions.author_id
      SQL
      
      result.first['Answer']
  end

end