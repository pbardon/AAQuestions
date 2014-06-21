class Reply
  def self.all
    results = QuestionsDatabase.instance.execute(
      'SELECT 
        * 
      FROM 
        replies'
      )
      results.map{ |result| Reply.new(result) }
  end
  
  attr_accessor :id, :body, :r_parent_id, :r_user_id, :r_question_id
  
  def initialize(options = {})
    @id = options['id']
    @body = options['body']
    @r_parent_id = options['r_parent_id']
    @r_user_id = options['r_user_id']
    @r_question_id = options['r_question_id']
  end
  
  def save
    return update unless @id.nil?
    
    QuestionsDatabase.instance.execute(
      <<-SQL, body, r_parent_id, r_user_id, r_question_id)
      INSERT INTO
        replies( body, r_parent_id, r_user_id, r_question_id )
      VALUES
        (?, ?, ?, ?)
      SQL
      
    @id = QuestionsDatabase.instance.last_insert_row_id
  end
  
  def update
    QuestionsDatabase.instance.execute(
      <<-SQL, r_parent_id, r_user_id, r_question_id, id)
      UPDATE
        replies
      SET
        r_parent_id = (?),
        r_user_id = (?),
        r_question_id = (?)
    
      WHERE
        id =(?)
      SQL
  end
  
  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.id = (?)
      SQL
      
    raise 'not found' if results.nil?
    Reply.new(results.first)
  end
  
  def self.find_by_question_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        r_question_id = (?) 
      SQL
      
      results.map{ |result| Reply.find_by_id(result['id'])}
  end
  
  def self.find_by_user_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        r_user_id = (?) 
      SQL
      
      results.map{ |result| Reply.find_by_id(result['id'])}
    end
    
    def author
      User.find_by_id(@r_user_id)
    end
    
    def question
      Question.find_by_id(@r_question_id)
    end
    
    def parent_reply
      Reply.find_by_id(@r_parent_id)
    end
    
    def child_replies
      results = QuestionsDatabase.instance.execute(<<-SQL, @id)
        SELECT
          *
        FROM
          replies
        WHERE
          r_parent_id = (?)
        SQL
        
      results.map{ |result| Reply.find_by_id(result['id'])}  
    end
      
end