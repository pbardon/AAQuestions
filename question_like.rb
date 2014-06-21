class QuestionLike
  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM question_likes')
    results.map{ |result| QuestionLike.new(result) }
  end
  
  attr_accessor :id, :likes_question, :like_user_id, :like_question_id
  
  def initialize(options = {})
    @id = options['id']
    @likes_question = options['likes_question']
    @like_user_id = options['like_user_id']
    @like_question_id = options['like_question_id']
  end
  
  def save
    return update unless @id.nil?
    
    QuestionsDatabase.instance.execute(
      <<-SQL, likes_question, like_user_id, like_question_id)
      INSERT INTO
        question_likes(likes_question, like_user_id, like_question_id)
      VALUES
        (?, ?, ?)
      SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end
  
  def update
    QuestionsDatabase.instance.execute(
    <<-SQL, likes_question, like_user_id, like_question_id, id)
    UPDATE
      question_likes
    SET
      likes_question = (?),
      like_user_id = (?),
      like_question_id = (?)
    
    WHERE
      id =(?)
    SQL
  end
  
  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        question_likes.id = (?)
      SQL
      
    raise 'not found' if results.nil?
    QuestionLike.new(results.first)
  end
  
  def self.likers_for_question_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      JOIN
        question_likes
      ON
        users.id = question_likes.like_user_id
      WHERE
        like_question_id = (?)
      SQL
      
      results.map{ |result| User.find_by_id(result['id']) }
  end
  
  def self.num_likes_for_question(question_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        Count(users.id) as likes
      FROM
        users
      JOIN
        question_likes
      ON 
        users.id = question_likes.like_user_id
      WHERE
        like_question_id = (?)
      GROUP BY
        like_question_id
      SQL
    return 0 if result.nil?
    result.first['likes']
  end
  
  def self.liked_questions_for_user_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      JOIN
        question_likes
      ON
        questions.id = like_question_id
      WHERE
        like_user_id = (?)
      SQL
      
      results.map{ |result| Question.find_by_id(result['id']) }
  end
  
  def self.most_liked_questions(n)
    results = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *, Count(users.id) as likes
      FROM
        users
      JOIN
        question_likes
      ON 
        users.id = question_likes.like_user_id
      GROUP BY
        like_question_id
      ORDER BY
        likes DESC
      SQL

    
    results.take(n).map{ |result| Question.find_by_id(result['id']) }
  end
end