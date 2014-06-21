class QuestionFollower
  def self.all
    results = QuestionsDatabase.instance.execute(
      'SELECT 
        * 
      FROM 
        question_follower'
      )
      results.map{ |result| QuestionFollower.new(result) }
    end
    
    attr_accessor :id, :question_id, :user_id
    
    def initialize(options = {})
      @id = options['id']
      @question_id = options['question_id']
      @user_id = options['user_id']
    end
    
    def save
      return update unless @id.nil?
      
      QuestionsDatabase.instance.execute(
        <<-SQL, question_id, user_id)
        INSERT INTO
          question_followers(question_id, user_id)
        VALUES
          (?, ?)
        SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    end
    
    def update
      QuestionsDatabase.instance.execute(
        <<-SQL, question_id, user_id, id)
        UPDATE
          question_followers
        SET
          question_id = (?),
          user_id = (?)
        WHERE
          id =(?)
        SQL
    end
    
    def self.find_by_id(id)
      results = QuestionsDatabase.instance.execute(<<-SQL, id)
        SELECT
          *
        FROM
          question_followers
        WHERE
          question_followers.id = (?)
        SQL
      
      raise 'not found' if results.nil?
      QuestionFollower.new(results.first)
    end
    
    #returns array of Users
    def self.followers_for_question_id(question_id)
      results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
        SELECT
          *
        FROM
          question_followers
        JOIN
          users
        ON
          question_followers.user_id = users.id
        WHERE
          question_id = (?)
        SQL
        results.map{|result|User.find_by_id(result['id'])}
    end
    
    def self.followed_questions_for_user_id(user_id)
      results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
        SELECT
          *
        FROM
          question_followers
        JOIN
          questions
        ON
          question_followers.question_id = questions.id
        WHERE
          user_id =(?)
        SQL
      results.map{|result|Question.find_by_id(result['id'])}
    end
    
    def self.most_followed_questions(n)
      results = QuestionsDatabase.instance.execute(<<-SQL)
        SELECT
          *, COUNT(user_id)
        FROM
          questions
        JOIN
          question_followers
        ON
          questions.id = question_followers.question_id
        GROUP BY
          question_id
        ORDER BY
          COUNT(user_id) DESC
        SQL
        
      results.take(n).map{|result|Question.find_by_id(result['id'])}
    end
end