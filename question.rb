class Question
  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM questions')
    results.map {|result| Question.new(result)}
  end
  
  attr_accessor :id, :title, :body, :author_id
  
  def initialize(options = {})
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end
  
  def save
    return update unless @id.nil?
    
    QuestionsDatabase.instance.execute(
      <<-SQL, title, body, author_id)
      INSERT INTO
        questions(title, body, author_id)
      VALUES
        (?, ?, ?)
      SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end
  
  def update
    QuestionsDatabase.instance.execute(
      <<-SQL, title, body, author_id, id)
    UPDATE
      questions
    SET
      title = (?),
      body = (?),
      author_id = (?)
    
    WHERE
      id =(?)
    SQL
  end
  
  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.id = (?)
      SQL
      
    raise 'not found' if results.nil?
    Question.new(results.first)
  end
  
  def self.find_by_author_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.author_id = (?)
      SQL
      
    raise 'not found' if results.nil?
    results.map{|result| Question.find_by_id(result['id'])}
  end
  
  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end
  
  def author
    User.find_by_id(@author_id)
  end
  
  def replies
    Reply.find_by_question_id(@id)
  end
  
  def followers
    QuestionFollower.followers_for_question_id(@id)
  end
  
  def likers
    QuestionLike.likers_for_question_id(@id)
  end
  
  def num_likes
    QuestionLike.num_likes_for_question(@id)
  end
end